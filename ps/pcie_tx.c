/*
 * pcie_tx.c
 * PCIe 发射系统 PS 侧配置
 *
 * 功能：中频频点配置（BPSK/QPSK）、发射初始化
 */

#include "pcie_tx.h"
#include "AdhocSoft.h"
#include <math.h>

/*
 * DDS 频点配置公共函数
 * pinc_addr : 频率增量寄存器地址
 * poff_base : 相位偏移寄存器基地址（步长 2，共 DDS_PARALLEL_NUM 路）
 * freq_point: 频点（MHz）
 */
static void dds_set_frequency(u16 pinc_addr, u16 poff_base, double freq_point)
{
    printf("frequency point : %lf MHz \r\n", freq_point);

    double data;
    double fs = DDS_CLOCK_MHZ * (1e+6);
    data = 65536 * freq_point * (1e+6) / fs;

    u16 writeData;
    int i;

    emc_write(DDS_REG_RESET, 0);    /* dds 复位 */

    /* 频率增量 */
    writeData = (u16)(data + 0.5);
    emc_write(pinc_addr, writeData);
    printf("write pinc : 0x%x \r\n", writeData);

    /* 各通道相位偏移 */
    for (i = 0; i < DDS_PARALLEL_NUM; i++)
    {
        writeData = (u16)((data * i / (double)DDS_PARALLEL_NUM) + 0.5);
        emc_write((u16)(poff_base + 2 * i), writeData);
        printf("write poff[%d] : 0x%x \r\n", i, writeData);
    }

    emc_write(DDS_REG_RESET, 1);    /* 解除 dds 复位 */
    xil_printf("dds frequency is configured successfully! \r\n");
}

/* bpsk 中频频点设置（单位：MHz） */
void set_dds_frequency_bpsk(double freq_point)
{
    dds_set_frequency(DDS_REG_PINC_BPSK, DDS_REG_POFF_BPSK_BASE, freq_point);
}

/* qpsk 中频频点设置（单位：MHz） */
void set_dds_frequency_qpsk(double freq_point)
{
    dds_set_frequency(DDS_REG_PINC_QPSK, DDS_REG_POFF_QPSK_BASE, freq_point);
}

/*
 * 数字衰减配置（dB -> Q1.14 系数）
 * atten_db : 衰减量（dB），正值表示衰减，0 表示 0dB（无衰减）
 * 系数 = round(16384 * 10^(-atten_db/20))
 * 例：0dB -> 0x4000（1.0），6dB -> 0x2013，12dB -> 0x1013，20dB -> 0x0666
 *     精确 -6dB 增益是 0.501187 而非 0.5，所以系数不是规整的 0x2000
 * 注意：本函数仅用于衰减（增益 <= 1.0）；负 dB（放大）会被钳位到 0x4000，
 *       因为 RTL 端系数 > 1.0 时 16 位输出会溢出回绕。
 */
static u16 atten_db_to_q114(double atten_db)
{
    double gain = pow(10.0, -atten_db / 20.0);   /* 幅度线性增益 */
    long   tmp  = (long)(gain * 16384.0 + 0.5);  /* Q1.14 系数（四舍五入），先按有符号钳位 */
    u16    coeff;

    if (tmp > 0x4000) tmp = 0x4000;  /* 钳位：0dB，不做放大 */
    if (tmp < 0)      tmp = 0;       /* 钳位：完全静音 */
    coeff = (u16)tmp;
    return coeff;
}

/* bpsk 数字衰减（dB）：转换为 Q1.14 系数后写入 0x704 */
void set_attenuation_bpsk(double atten_db)
{
    u16 coeff = atten_db_to_q114(atten_db);
    printf("bpsk attenuation : %lf dB -> coeff 0x%04x \r\n", atten_db, coeff);
    emc_write(TX_REG_ATTEN_BPSK, coeff);
}

/* qpsk 数字衰减（dB）：转换为 Q1.14 系数后写入 0x706 */
void set_attenuation_qpsk(double atten_db)
{
    u16 coeff = atten_db_to_q114(atten_db);
    printf("qpsk attenuation : %lf dB -> coeff 0x%04x \r\n", atten_db, coeff);
    emc_write(TX_REG_ATTEN_QPSK, coeff);
}

/* bpsk/qpsk 符号表初始化数据（32 x 16bit） */
#define RAM_INIT_LEN    (32)
static const u16 ram_init_data[RAM_INIT_LEN] = {
    0x8688, 0xC67C, 0x26B3, 0x917E, 0x9EFB, 0x3D91, 0x6813, 0x003A, 0x81ED, 0xAB6E, 0x6145, 0x0A93, 0x67FA, 0x84F3, 0xA1CB, 0x4252, 0x2F02, 0x3E85, 0x2C5B, 0x0854, 0xAAD7, 0x3882, 0x0EB2, 0x92DA, 0x0BBA, 0x7616, 0xDD41, 0xED37, 0x3064, 0xEC34, 0xB0B3, 0xBE57
};

/*
 * bpsk 符号表 RAM 写
 * data : 符号表数据（每字 16bit，写地址由硬件自动递增）
 * len  : 写入字数（应与 RAM 深度 32 一致）
 */
void write_bpsk_ram(const u16 *data, u16 len)
{
    u16 i;
    for (i = 0; i < len; i++)
    {
        emc_write(TX_REG_RAM_WDATA_BPSK, data[i]);
    }
    printf("bpsk ram write done: %d words\r\n", len);
}

/*
 * qpsk 符号表 RAM 写
 * data : 符号表数据（每字 16bit，写地址由硬件自动递增）
 * len  : 写入字数（应与 RAM 深度 32 一致）
 */
void write_qpsk_ram(const u16 *data, u16 len)
{
    u16 i;
    for (i = 0; i < len; i++)
    {
        emc_write(TX_REG_RAM_WDATA_QPSK, data[i]);
    }
    printf("qpsk ram write done: %d words\r\n", len);
}

/* 发射初始化 */
void tx_init(void)
{
    printf("Tx initializing ... \r\n");

    emc_write(TX_REG_RESET, 0);     /* tx 复位 */
    emc_write(TX_REG_RAM_EN, 0);    /* ram 读使能关闭 */

    /* 默认频点配置 */
    set_dds_frequency_bpsk(100);    /* bpsk 中频 */
    set_dds_frequency_qpsk(200);    /* qpsk 中频 */

    /* 默认衰减配置：0dB */
    set_attenuation_bpsk(0.0);    /* bpsk 数字衰减 */
    set_attenuation_qpsk(0.0);    /* qpsk 数字衰减 */

    /* 符号表 RAM 初始化 */
    write_bpsk_ram(ram_init_data, RAM_INIT_LEN);
    write_qpsk_ram(ram_init_data, RAM_INIT_LEN);

    emc_write(TX_REG_RESET, 1);     /* 解除 tx 复位 */
    emc_write(TX_REG_BPSK_ENABLE, 1);  /* bpsk 使能 */
    emc_write(TX_REG_QPSK_ENABLE, 1);  /* qpsk 使能 */
    emc_write(TX_REG_RAM_EN, 1);    /* ram 读使能 */

    printf("Tx has been initialized. \r\n");
}

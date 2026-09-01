/*
 * pcie_tx.c
 * PCIe 发射系统 PS 侧配置
 *
 * 功能：中频频点配置（BPSK/QPSK）、发射初始化
 */

#include "pcie_tx.h"

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

/* 发射初始化 */
void tx_init(void)
{
    printf("Tx initializing ... \r\n");

    emc_write(TX_REG_RESET, 0);     /* tx 复位 */
    emc_write(TX_REG_ENABLE, 0);    /* tx 使能关闭 */

    /* 默认频点配置 */
    set_dds_frequency_bpsk(100);    /* bpsk 中频 */
    set_dds_frequency_qpsk(200);    /* qpsk 中频 */

    /* 默认幅度配置（右移 0~15） */
    emc_write(TX_REG_ATTEN_BPSK, 0);  /* bpsk 数字衰减 */
    emc_write(TX_REG_ATTEN_QPSK, 0);  /* qpsk 数字衰减 */

    emc_write(TX_REG_RESET, 1);     /* 解除 tx 复位 */
    emc_write(TX_REG_ENABLE, 1);    /* tx 使能 */

    printf("Tx has been initialized. \r\n");
}

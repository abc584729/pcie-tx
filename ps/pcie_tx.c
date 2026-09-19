/*
 * pcie_tx.c
 * PCIe 发射系统 PS 侧配置
 *
 * 功能：中频频点配置（BPSK/QPSK）、发射初始化
 */

#include "pcie_tx.h"
#include "AdhocSoft.h"
#include <math.h>

/* config state owned by adhocSoft.c //20260902: 频点/衰减/使能/速率是 case 133（tx_configure.py），
 * 单次发/符号数/起始时基是 case 135（tx_start.py） */
extern double fre_bpsk, fre_qpsk, atten_bpsk, atten_qpsk;
extern u8     ctrl_bpsk, ctrl_qpsk;
extern u8     tx_rate_sel;
extern u8     tx_bpsk_single_shot;   /* bpsk 发射模式：0 循环发（默认），1 单次发 */
extern u32    tx_bpsk_sym_num;       /* bpsk 单次发符号数，0 = 不发。case 135 给的是数据文件
                                     * 大小(kB)，adhocSoft.c 按每符号 1 bit 换算成 bit 数 */
extern u16    tx_bpsk_time_sel;      /* bpsk 起始时基（整符号部分）：0..1023，1024 个符号一圈，时基走到
                                     * 该值那一圈才开读门（0 = 尽快开始）；实际第一个符号落在
                                     * 时基位置 time_sel + 1，圈内偏移由 tx_bpsk_clock_sel 给出 */
extern u16    tx_bpsk_clock_sel;     /* bpsk 圈内开闸点：0..count_max-1，写 >= count_max 按末拍处理。
                                     * case 135 把上位机给的 double 按 tx_rate_sel 拆出来，
                                     * tx_start() 在复位窗口里和 time_sel 一起写下去 */

/*
 * DDS 频点配置公共函数
 * pinc_addr : 频率增量寄存器地址
 * poff_base : 相位偏移寄存器基地址（步长 2，共 DDS_PARALLEL_NUM 路）
 * freq_point: 频点（MHz）
 */
static void dds_set_frequency(u16 pinc_addr, u16 poff_base, double freq_point)
{
    printf("frequency point : %lf MHz \r\n", freq_point);

    double fs = DDS_CLOCK_MHZ * (1e+6);
    double data = 4294967296.0 * freq_point * (1e+6) / fs;   /* 2^32 归一化，满量程对应 2^32 */

    int  i;
    long long inc, poff;    /* 32 位字放不进 long（Zynq 上 long 是 32 位），必须用 64 位中间量 */

    emc_write(DDS_REG_RESET, 0);    /* dds 复位 */

    /* 频率控制字：32 位，按高/低 16 位分两次写 */
    inc = (data >= 0.0) ? (long long)(data + 0.5) : (long long)(data - 0.5);  /* 四舍五入 */
    inc &= 0xFFFFFFFFLL;                                      /* mod 2^32 回绕 */
    emc_write(pinc_addr,            (u16)((inc >> 16) & 0xFFFFLL));   /* 高 16 位 */
    emc_write((u16)(pinc_addr + 2), (u16)(inc & 0xFFFFLL));           /* 低 16 位 */
    printf("write pinc : 0x%08lx \r\n", (unsigned long)inc);

    /* 各通道相位偏移：同样 32 位，每路步长 4（高 16 位在 +0，低 16 位在 +2） */
    for (i = 0; i < DDS_PARALLEL_NUM; i++)
    {
        poff = (data >= 0.0) ? (long long)(data*i/(double)DDS_PARALLEL_NUM + 0.5)
                             : (long long)(data*i/(double)DDS_PARALLEL_NUM - 0.5);  /* 四舍五入 */
        poff &= 0xFFFFFFFFLL;
        emc_write((u16)(poff_base + 4 * i),     (u16)((poff >> 16) & 0xFFFFLL));
        emc_write((u16)(poff_base + 4 * i + 2), (u16)(poff & 0xFFFFLL));
        printf("write poff[%d] : 0x%08lx \r\n", i, (unsigned long)poff);
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

/*
 * 发射速率选择
 * sel = 0 -> bpsk 450 kHz / qpsk 4.5 MHz（原速率）
 * sel = 1 -> bpsk 400 kHz / qpsk 6.667 MHz
 * 该位同时决定 bpsk/qpsk 的符号速率和 add 的截位方式，切换后需重新灌符号表
 */
void set_rate_sel(u8 sel)
{
    emc_write(TX_REG_RATE_SEL, (u16)(sel & 0x1));
    printf("tx rate select : %d \r\n", (int)(sel & 0x1));
}

/* bpsk 发射使能（寄存器 0x70C）：运行时可改 */
void set_bpsk_enable(u8 en)
{
    emc_write(TX_REG_BPSK_ENABLE, (u16)(en & 0x1));
    printf("bpsk enable : %d \r\n", (int)(en & 0x1));
}

/* qpsk 发射使能（寄存器 0x70E）：运行时可改 */
void set_qpsk_enable(u8 en)
{
    emc_write(TX_REG_QPSK_ENABLE, (u16)(en & 0x1));
    printf("qpsk enable : %d \r\n", (int)(en & 0x1));
}

/*
 * 运行时可改的部分：频点、衰减、速率。
 * tx_start() 和 case 133（tx_configure.py）共用 —— case 133 拿来直接下发，
 * tx_start() 在复位窗口里再写一遍，保证每次都从已知状态起播。
 */
static void tx_apply_runtime_cfg(void)
{
    set_dds_frequency_bpsk(fre_bpsk);    /* bpsk 中频 */
    set_dds_frequency_qpsk(fre_qpsk);    /* qpsk 中频 */
    set_attenuation_bpsk(atten_bpsk);    /* bpsk 数字衰减 */
    set_attenuation_qpsk(atten_qpsk);    /* qpsk 数字衰减 */
    set_rate_sel(tx_rate_sel);           /* 速率选择 */
}

/*
 * 运行中直接下发配置（case 133 / tx_configure.py）。
 * 不碰 TX_REG_RESET：读指针、符号计数器、done、时基一个都不动，正在发的
 * 那一串也不中断，所以这四项随时可以改。改完立刻生效，不需要重发 case 135。
 * 注意 rate_sel 会同时改符号速率和 add 的截位方式，切了要重新灌符号表。
 */
void tx_apply_config(void)
{
    tx_apply_runtime_cfg();
    set_bpsk_enable(ctrl_bpsk);
    set_qpsk_enable(ctrl_qpsk);
    printf("tx config applied at runtime. \r\n");
}
void set_bpsk_burst(unsigned long sym_num, unsigned char single_shot)
{
    emc_write(TX_REG_BPSK_SYM_NUM_L,   (u16)(sym_num & 0xFFFFUL));
    emc_write(TX_REG_BPSK_SYM_NUM_H,   (u16)((sym_num >> 16) & 0x7FUL));
    emc_write(TX_REG_BPSK_SINGLE_SHOT, (u16)(single_shot & 0x1));

    if (single_shot & 0x1)
        printf("bpsk burst : sym_num = %lu, mode = single shot \r\n", sym_num);
    else if (sym_num == 0)
        printf("bpsk burst : mode = cyclic, whole table (%lu symbols) per turn \r\n",
               4194304UL);
void set_bpsk_time_sel(u16 tsel)
{
    emc_write(TX_REG_BPSK_TIME_SEL, (u16)(tsel & 0x3FF));
    printf("bpsk time sel : %u \r\n", (unsigned)(tsel & 0x3FF));
}

/*
 * bpsk 圈内开闸点（寄存器 0x71C）
 * csel : 0..count_max-1（450k 一圈 400 拍、400k 一圈 450 拍）。写 >= count_max 时
 *        bpsk_ram 按末拍处理，等于加这个寄存器之前"分频脉冲那一拍开闸"的老行为；
 *        复位值是 511，所以不写它也是老行为，一个复位值管住两种速率。
 * 和 0x718 一起决定读门什么时候开，配成一个时间校准点，必须一起写。
 */
void set_bpsk_clock_sel(u16 csel)
{
    emc_write(TX_REG_BPSK_CLOCK_SEL, (u16)(csel & 0x1FF));
    printf("bpsk clock sel : %u \r\n", (unsigned)(csel & 0x1FF));
}
    emc_write(TX_REG_BPSK_TIME_SEL, (u16)(tsel & 0x3FF));
    printf("bpsk time sel : %u \r\n", (unsigned)(tsel & 0x3FF));
}

/*
 * bpsk 发射状态（只读，0x71A bit0）：1 = 正在发射，0 = 空闲。
 * 单次发发完（done 锁住）或 0x702 拉低之后落 0；0x702 拉高、但还在等时基
 * 窗口的那段（最长 1024 个符号）它已经是 1 了 —— 它回答的是"读门开着且这
 * 一轮没发完"，不是"此刻真的有波出"。
 */
unsigned short tx_get_bpsk_busy(void)
{
    return (unsigned short)(emc_read(TX_REG_BPSK_BUSY) & 0x1);
}

void write_bpsk_ram(const u16 *data, unsigned long len)
{
    unsigned long i;
    for (i = 0; i < len; i++)
    {
        emc_write(TX_REG_RAM_WDATA_BPSK, data[i]);
    }
    printf("bpsk ram write done: %lu words\r\n", len);
}

void write_qpsk_ram(const u16 *data, unsigned long len)
{
    unsigned long i;
    for (i = 0; i < len; i++)
    {
        emc_write(TX_REG_RAM_WDATA_QPSK, data[i]);
    }
    printf("qpsk ram write done: %lu words\r\n", len);
}

/* 发射初始化 */
void tx_start(void)
{
    printf("Tx starting ... \r\n");

    emc_write(TX_REG_RESET, 1);     
    emc_write(TX_REG_RAM_EN, 0);    /* ram 读使能关闭 */

    tx_apply_runtime_cfg();
    
    set_bpsk_burst(tx_bpsk_sym_num, tx_bpsk_single_shot);  

    set_bpsk_time_sel(tx_bpsk_time_sel);
    set_bpsk_clock_sel(tx_bpsk_clock_sel);  /* 和 time_sel 配成一个开闸点，必须一起写 */

    set_bpsk_enable(ctrl_bpsk);     /* bpsk 使能 */
    set_qpsk_enable(ctrl_qpsk);     /* qpsk 使能 */
    emc_write(TX_REG_RAM_EN, 1);    /* ram 读使能 */

    printf("Tx has been started. \r\n");
}

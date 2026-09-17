#ifndef PCIE_TX_H
#define PCIE_TX_H

/*
 * pcie_tx.h
 * PCIe 发射系统 PS 侧配置接口头文件
 */

/* ================= 寄存器地址定义 ================= */

/* 发射控制寄存器 */
#define TX_REG_RESET            (0x700)    /* tx 复位：0 复位，1 解除复位 */
#define TX_REG_RAM_EN           (0x702)    /* 符号表 RAM 读使能：0 关闭，1 使能     */
#define TX_REG_ATTEN_BPSK       (0x704)    /* bpsk 数字衰减（Q1.14 系数，0x4000=0dB）   */
#define TX_REG_ATTEN_QPSK       (0x706)    /* qpsk 数字衰减（Q1.14 系数，0x4000=0dB）   */
#define TX_REG_RAM_WDATA_BPSK   (0x708)    /* bpsk 符号表写数据（写地址自动递增） */
#define TX_REG_RAM_WDATA_QPSK   (0x70A)    /* qpsk 符号表写数据（写地址自动递增） */
#define TX_REG_BPSK_ENABLE      (0x70C)    /* bpsk 使能：0 关闭，1 使能     */
#define TX_REG_QPSK_ENABLE      (0x70E)    /* qpsk 使能：0 关闭，1 使能     */
#define TX_REG_RATE_SEL         (0x710)    /* 发射速率选择：0 -> bpsk 450k / qpsk 4.5M，1 -> bpsk 400k / qpsk 6.667M */
#define TX_REG_BPSK_SYM_NUM_L   (0x712)    /* bpsk 单次发符号数低 16 位（0x714 = 高 7 位） */
#define TX_REG_BPSK_SYM_NUM_H   (0x714)    /* bpsk 单次发符号数高 7 位（仅 bit6:0 有效，整表 4194304 个符号） */
#define TX_REG_BPSK_SINGLE_SHOT (0x716)    /* bpsk 发射模式：bit0 = 0 循环发（默认），1 单次发满符号数就停 */

/* DDS 中频配置寄存器 */
#define DDS_REG_RESET           (0x800)    /* dds 复位：0 复位，1 解除复位 */
#define DDS_REG_PINC_BPSK       (0x802)    /* bpsk 频率增量高 16 位（0x804 = 低 16 位） */
#define DDS_REG_POFF_BPSK_BASE  (0x806)    /* bpsk 相位偏移基址（步长 4，共 8 路；+2 为低 16 位） */
#define DDS_REG_PINC_QPSK       (0x902)    /* qpsk 频率增量高 16 位（0x904 = 低 16 位） */
#define DDS_REG_POFF_QPSK_BASE  (0x906)    /* qpsk 相位偏移基址（步长 4，共 8 路；+2 为低 16 位） */

/* DDS 参数 */
#define DDS_PARALLEL_NUM        (8)        /* 并行 DDS 路数 */
#define DDS_CLOCK_MHZ           (180.0)    /* DDS 工作时钟（MHz） */

/* ================= 对外接口 ================= */

/* bpsk 中频频点设置（单位：MHz） */
void set_dds_frequency_bpsk(double freq_point);

/* qpsk 中频频点设置（单位：MHz） */
void set_dds_frequency_qpsk(double freq_point);

/* 数字衰减（dB -> Q1.14 系数，写寄存器） */
void set_attenuation_bpsk(double atten_db);
void set_attenuation_qpsk(double atten_db);

/* 发射速率选择：sel = 0 -> bpsk 450k / qpsk 4.5M，sel = 1 -> bpsk 400k / qpsk 6.667M */
void set_rate_sel(unsigned char sel);

/*
 * bpsk 循环发 / 单次发配置
 * sym_num     : 单次发要发的符号数，1..4194304；0 表示一个符号都不发
 *               （整表 4194304 = 2^22 个符号，所以 23 位够用；> 表长则整表重复）
 * single_shot : 0 = 循环发（默认，sym_num 无意义），1 = 单次发
 * 注意：写 sym_num 要分两次写寄存器，不是原子操作；请在 tx 复位期间
 *       （emc_write(TX_REG_RESET, 0) 之后、写 1 之前）调用。发完后再发一次
 *       必须先脉冲 TX_REG_RESET 清读指针，再让 TX_REG_RAM_EN 为高。
 */
void set_bpsk_burst(unsigned long sym_num, unsigned char single_shot);

/* ================= RAM 符号表写函数 ================= */

/* bpsk 符号表 RAM 写（写地址由硬件自动递增，整表 262144 字 = 512 KB） */
void write_bpsk_ram(const unsigned short *data, unsigned long len);

/* qpsk 符号表 RAM 写（写地址由硬件自动递增，整表 32768 字 = 64 KB） */
void write_qpsk_ram(const unsigned short *data, unsigned long len);

/* 发射初始化 */
void tx_init(void);

#endif /* PCIE_TX_H */

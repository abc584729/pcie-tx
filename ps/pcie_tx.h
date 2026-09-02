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

/* DDS 中频配置寄存器 */
#define DDS_REG_RESET           (0x800)    /* dds 复位：0 复位，1 解除复位 */
#define DDS_REG_PINC_BPSK       (0x802)    /* bpsk 频率增量 */
#define DDS_REG_POFF_BPSK_BASE  (0x804)    /* bpsk 相位偏移基址（步长 2，共 8 路） */
#define DDS_REG_PINC_QPSK       (0x902)    /* qpsk 频率增量 */
#define DDS_REG_POFF_QPSK_BASE  (0x904)    /* qpsk 相位偏移基址（步长 2，共 8 路） */

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

/* ================= RAM 符号表写函数 ================= */

/* bpsk 符号表 RAM 写（写地址由硬件自动递增） */
void write_bpsk_ram(const unsigned short *data, unsigned short len);

/* qpsk 符号表 RAM 写（写地址由硬件自动递增） */
void write_qpsk_ram(const unsigned short *data, unsigned short len);

/* 发射初始化 */
void tx_init(void);

#endif /* PCIE_TX_H */

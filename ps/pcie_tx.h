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
#define TX_REG_BPSK_TIME_SEL    (0x718)    /* bpsk 起始时基（整符号部分）：0..1023，1024 个符号一圈，
                                            * 时基计数走到该值那一圈才打开读门。和 0x71C 一起用，
                                            * 两个都写进 bpsk_ram 才决定开闸点 */
#define TX_REG_BPSK_CLOCK_SEL   (0x71C)    /* bpsk 圈内开闸点：0..count_max-1（450k 0..399，400k 0..449），
                                            * 时基走到 time_sel 那一圈、圈内第 clock_sel 拍才开读门。
                                            * 写 >= count_max 按末拍处理 = 老的"分频脉冲那一拍"行为。
                                            * 复位值 511，所以不写它就是加这个寄存器之前的行为。
                                            * 上位机给的是 double（单位 = 符号），adhocSoft.c 的
                                            * case 135 按 tx_rate_sel 拆成 0x718 + 0x71C 两个值 */
#define TX_REG_BPSK_BUSY        (0x71A)    /* bpsk 发射状态（只读）：bit0 = 1 正在发射，0 空闲。
                                            * 判据是"0x702 有效且这一轮没发完"：单次发发完
                                            * （done 锁住）或 0x702 拉低后落 0。注意它不等于
                                            * "真的有波出"——0x702 拉高后等时基窗口的那段它已经是 1 */

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

/* 发射使能（0x70C / 0x70E）：0 关闭，1 使能。运行时可改 */
void set_bpsk_enable(unsigned char en);
void set_qpsk_enable(unsigned char en);

/*
 * 运行中直接下发配置：频点、衰减、速率、使能。
 * 这四项都是运行时可改的，本函数**不碰 TX_REG_RESET** —— 读指针、符号计数器、
 * done 和时基都不受影响，正在发的这一串也不中断，改完下一拍就生效。
 * case 133（tx_configure.py）走这条路径，随时可以重发。
 * 单次发/循环发、符号数、起始时基不在这里：那三项必须在复位窗口里写，
 * 只能由 tx_start() 落下去。
 */
void tx_apply_config(void);

/*
 * bpsk 循环发 / 单次发配置
 * sym_num     : 一轮要发的符号数，1..8388607（23 位）。0 在循环发下当作整表
 *               4194304，在单次发下表示一个符号都不发。大于表长（4194304）时
 *               整表重复 —— 读指针低 22 位回卷，高位继续进位。
 * single_shot : 0 = 循环发（默认）：每轮发 sym_num 个，数满回到第 0 个符号接着
 *               下一轮，一直循环；1 = 单次发：数满就停（done 锁住）。
/*
 * bpsk 起始时基（寄存器 0x718）+ 圈内开闸点（寄存器 0x71C）
 * tsel : 0x718，整符号部分 0..1023，1024 个符号为一圈（0 = 尽快开始）。
 * csel : 0x71C，圈内第几拍开闸，0..count_max-1。450k 一圈 400 拍、400k 一圈 450 拍，
 *        和 bpsk_ram 的 COUNT_MAX_450K / COUNT_MAX_400K 一致。写 >= count_max
 *        按末拍处理，也就是加这两个寄存器之前"分频脉冲那一拍开门"的老行为。
 * 两个一起决定读门什么时候开：时基走到 tsel 那一圈的 csel 拍。时基和读脉冲同源，
 * 开闸那一拍本身不读表，所以实际发出的第一个符号落在时基位置 tsel + 1，圈内偏移
 * 由 csel 给出 —— 时间校准粒度是 1 拍，不再是 1/Rs。
 * 时基只在 rst_n（tx 复位）时清零，写晚了要等这一圈走完才轮到这个值。
 * 所以 tx_start()（case 135）在复位窗口里把两个都写下去。
 */
void set_bpsk_time_sel(unsigned short tsel);
void set_bpsk_clock_sel(unsigned short csel);
 * bpsk 起始时基（寄存器 0x718）
 * tsel : 0..1023，1024 个符号为一圈。时基和读脉冲同源，所以匹配上的那个
 *        脉冲用来开读门、本身不读表：实际发出的第一个符号落在时基位置
 *        tsel+1。写 0 = 复位后第一拍就开门，等于尽快开始。
 *        时基只在 rst_n（tx 复位）时清零，写晚了要等这一圈走完才轮到这个值。
 *        所以 tx_start()（case 135）在复位窗口里写它。
 */
void set_bpsk_time_sel(unsigned short tsel);

/*
 * 读 bpsk 发射状态（寄存器 0x71A bit0，只读）
 * 返回 1 = 正在发射，0 = 空闲（"单次发已经发完"和"0x702 关着"都算空闲）。
 * 只有 bit0 有意义，其余位读回 0。
 * 注意这是一次 PL 侧的 EMC 读事务（不是内存访问），别在紧循环里猛刷。
 */
unsigned short tx_get_bpsk_busy(void);

/* ================= RAM 符号表写函数 ================= */

/* bpsk 符号表 RAM 写（写地址由硬件自动递增，整表 262144 字 = 512 KB） */
void write_bpsk_ram(const unsigned short *data, unsigned long len);

/* qpsk 符号表 RAM 写（写地址由硬件自动递增，整表 32768 字 = 64 KB） */
void write_qpsk_ram(const unsigned short *data, unsigned long len);

/* 发射初始化 */
void tx_start(void);

#endif /* PCIE_TX_H */

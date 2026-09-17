----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/08/23 15:22:07
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use work.rx_data_types.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
Port (
----    ----------------------------50M参考时钟--------------------------------
--    REF_CLK_50M                 : in    STD_LOGIC;
--    ----------------------------SI5341 SPI 配置--------------------------------
    SI5341_locked               : in    std_logic;      -- LOL_B 锁定信号 --    
    SI5341_MISO    	            : in   std_logic;       -- SDO 读入信号 --      
    SI5341_MOSI                 : out   std_logic;      -- SDIO 输出信号 --
    SI5341_SCLK                 : out   std_logic;      -- SCLK 时钟信号 --
    SI5341_SCS                  : out   std_logic;      -- CSB 片选信号 --

    ----------------------------SI5340 clock output 256M--------------------------------
    REFCLK1_P_ADC0_SI5341        : in     std_logic;
    REFCLK1_N_ADC0_SI5341        : in     std_logic;
    REFCLK1_P_ADC2_SI5341        : in     std_logic;
    REFCLK1_N_ADC2_SI5341        : in     std_logic;
    REFCLK1_P_ADC3_SI5341        : in     std_logic;
    REFCLK1_N_ADC3_SI5341        : in     std_logic;
    REFCLK1_P_DAC0_SI5341        : in     std_logic;
    REFCLK1_N_DAC0_SI5341        : in     std_logic; 
    REFCLK1_P_DAC2_SI5341        : in     std_logic;
    REFCLK1_N_DAC2_SI5341        : in     std_logic;   
    ----------------------------RF DATA CONVENTER VIN--------------------------------
    RX0_0_N_RF_ADC                : in     std_logic;
    RX0_0_P_RF_ADC                : in     std_logic;
    RX0_1_N_RF_ADC                : in     std_logic;
    RX0_1_P_RF_ADC                : in     std_logic;
    RX1_0_N_RF_ADC                : in     std_logic;
    RX1_0_P_RF_ADC                : in     std_logic;
    RX1_1_N_RF_ADC                : in     std_logic; 
    RX1_1_P_RF_ADC                : in     std_logic; 
    RX2_0_N_RF_ADC                : in     std_logic; 
    RX2_0_P_RF_ADC                : in     std_logic; 
    RX2_1_N_RF_ADC                : in     std_logic; 
    RX2_1_P_RF_ADC                : in     std_logic; 
    RX3_0_N_RF_ADC                : in     std_logic; 
    RX3_0_P_RF_ADC                : in     std_logic; 
    RX3_1_N_RF_ADC                : in     std_logic; 
    RX3_1_P_RF_ADC                : in     std_logic; 
    
    TX0_0_N_RF_DAC                : out    std_logic;
    TX0_0_P_RF_DAC                : out    std_logic;
    TX2_0_N_RF_DAC                : out    std_logic;
    TX2_0_P_RF_DAC                : out    std_logic;        
    ----------------------------SI5340 clock output 128M-------------------------------
    REFCLK0_P_PL                : in     std_logic;
    REFCLK0_N_PL                : in     std_logic;
--    REFCLK1_P_PL                : in     std_logic;
--    REFCLK1_N_PL                : in     std_logic;

--    ENABLE_POWER_OCXO_RFSOC     : out     std_logic;
    EN_PWR_CPT                  : out     std_logic;
    SEL_REFCLK_PLL_RF           : out     std_logic;
--    ----------------------------射频信号控制------------------------------------------
--    PA_TTL  : out    std_logic;
--    T_R_TTL : out    std_logic;
--    LNA_TTL : out    std_logic;
--    SW_R0: out    std_logic;
--    SW_R1: out    std_logic;
--    SW_R2: out    std_logic;
    
--    SW_T :   out    std_logic;
    
--    SEL0_TX: out    std_logic;
--    SEL1_TX: out    std_logic;
    
--    R0_C0   : out    std_logic;
--    R0_C1   : out    std_logic;
--    R0_C2   : out    std_logic;
--    R0_C3   : out    std_logic;
--    R0_C4   : out    std_logic;
--    R0_C5   : out    std_logic;
    
--    R1_C0   : out    std_logic;
--    R1_C1   : out    std_logic;
--    R1_C2   : out    std_logic;
--    R1_C3   : out    std_logic;
--    R1_C4   : out    std_logic;
--    R1_C5   : out    std_logic;
    
--    R2_C0   : out    std_logic;
--    R2_C1   : out    std_logic;
--    R2_C2   : out    std_logic;
--    R2_C3   : out    std_logic;
--    R2_C4   : out    std_logic;
--    R2_C5   : out    std_logic;
    
--    T_C0    : out    std_logic;
--    T_C1    : out    std_logic;
--    T_C2    : out    std_logic;
--    T_C3    : out    std_logic;
--    T_C4    : out    std_logic;
--    T_C5    : out    std_logic;
    
    
    -----------------输出管脚测试-------------------
--    test_PA_TTL_in       : out    std_logic;--C14
--    test_T_R_TTL_in      : out    std_logic;--C13
--    test_LNA_TTL_in      : out    std_logic; --K14
--    test_interve         : in    std_logic;  --J14
--    flag_timeslot_switch                      : out std_logic; --J14
--    clk_observe : out    std_logic
--    ---------------GPS管脚---------------------
--    gps_rxd  : out std_logic;  --GPS接收信号
--    gps_txd  : out std_logic;   --GPS发送信号
--    en_gps   : out std_logic;   --GPS使能
--    gps_1PPS : in std_logic;  --秒脉冲，据此给ps上中断
    ---------------灯开关---------------------
--    gpio_warning    : out std_logic;    --D14
--    gpio_power      : out std_logic;    --C14
--    gpio_tx         : out std_logic;    --C13  
--    gpio_rx         : out std_logic;    --E14

    ---- pcie ----
    pcie_7x_mgt_rtl_0_rxn : in STD_LOGIC_VECTOR  ( 7 downto 0 );
    pcie_7x_mgt_rtl_0_rxp : in STD_LOGIC_VECTOR  ( 7 downto 0 );
    pcie_7x_mgt_rtl_0_txn : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_7x_mgt_rtl_0_txp : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_ref_clk_n : in STD_LOGIC_VECTOR ( 0 to 0 );
    pcie_ref_clk_p : in STD_LOGIC_VECTOR ( 0 to 0 );
--    reset_rtl_0 : in STD_LOGIC;
    axi_aclk : out STD_LOGIC;
--    pcie_clk_test : out std_logic;
    
    ---------------秒脉冲输出-------------------
    time_pulse_sync                                 : out std_logic ; ----精秒脉冲
	time_pulse_sync_cu                              : out std_logic ; ----粗秒脉冲
	
	pps1_sync                                       : in std_logic;
	
    LED2_test                                       : out std_logic ;
    lock_1pps_cpt                                   : in  std_logic ;
    lock_refclk_cpt                                 : in  std_logic ;
    In_1pps_cpt                                     : in  std_logic ;
    Out_1pps_cpt                                    : out  std_logic ;
    CA53_RXD                                        : OUT  std_logic ;
    CA53_TXD                                        : IN   std_logic                              
 );
end top;

architecture Behavioral of top is

signal sys_rst_n_0 : std_logic;
component xdma_reset is
  port (
    clk             : in std_logic;
    user_lnk_up     : in std_logic;
    sys_rst_n       : out std_logic
  );
end component;

signal CA53_EXTERNAL_TXD:std_logic;
signal CA53_EXTERNAL_RXD:std_logic;
signal gps_rxd  :  std_logic;
signal gps_txd  :  std_logic;
signal en_gps   :  std_logic;
signal gps_1PPS :  std_logic;
--signal time_pulse_sync:  std_logic;
signal flag_timeslot_switch :  std_logic;

--signal time_pulse_sync_cu : std_logic;
---------------灯开关---------------------
signal    gpio_warning_internal    : std_logic;    --D14
signal    gpio_power_internal    : std_logic;    --C14
signal    gpio_tx_internal    : std_logic;    --C13  
signal    gpio_rx_internal    : std_logic;    --E14
signal    cnt_gpio_tx      :std_logic_vector(25 downto 0);
signal    en_cnt_gpio_tx    : std_logic;

 signal gpio_warning    : std_logic;
 signal gpio_power      : std_logic;
 signal gpio_tx         : std_logic;
 signal gpio_rx         : std_logic;

---------射频信号--------
signal    PA_TTL_in  :     std_logic;
signal    T_R_TTL_in :     std_logic;
signal    LNA_TTL_in :     std_logic;
signal    SW_R0_in      :     std_logic; 
signal    SW_R1_in      :     std_logic; 
signal    SW_R2_in      :     std_logic; 
signal    SW_T_in       :     std_logic; 
signal    SEL0_TX_in    :     std_logic; 
signal    SEL1_TX_in    :     std_logic; 

signal    R0_C0_in   :     std_logic;
signal    R0_C1_in   :     std_logic;
signal    R0_C2_in   :     std_logic;
signal    R0_C3_in   :     std_logic;
signal    R0_C4_in  :      std_logic;
signal    R0_C5_in  :      std_logic;
signal    R1_C0_in   :     std_logic;
signal    R1_C1_in   :     std_logic;
signal    R1_C2_in   :     std_logic;
signal    R1_C3_in   :     std_logic;
signal    R1_C4_in  :      std_logic;
signal    R1_C5_in  :      std_logic;
signal    R2_C0_in   :     std_logic;
signal    R2_C1_in   :     std_logic;
signal    R2_C2_in   :     std_logic;
signal    R2_C3_in   :     std_logic;
signal    R2_C4_in  :      std_logic;
signal    R2_C5_in  :      std_logic;
signal    T_C0_in    :     std_logic;
signal    T_C1_in    :     std_logic;  
signal    T_C2_in    :     std_logic;
signal    T_C3_in    :     std_logic;
signal    T_C4_in    :     std_logic;
signal    T_C5_in    :     std_logic;
signal    T_C0_ps    :     std_logic;
signal    T_C1_ps    :     std_logic;  
signal    T_C2_ps    :     std_logic;  
signal    T_C3_ps    :     std_logic;
signal    T_C4_ps    :     std_logic;
signal    T_C5_ps    :     std_logic;

COMPONENT vio_SEL
  PORT (
    clk : IN STD_LOGIC;
    probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

COMPONENT vio_ENABLE_POWER
  PORT (
    clk : IN STD_LOGIC;
    probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

COMPONENT vio_Out_1pps_cpt
  PORT (
    clk : IN STD_LOGIC;
    probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

COMPONENT ila_emc
PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe3 : IN STD_LOGIC_VECTOR(11 DOWNTO 0); 
	probe4 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	probe5 : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
);
END COMPONENT  ;


---- 测试用ila
COMPONENT ila_RX_TX_DATA
PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe4 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe5 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe6 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe7 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe8 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe9 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe10 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe11 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe12 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe13 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe14 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe15 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe16 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe17 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe18 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe19 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe20 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe21 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe22 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe23 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe24 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe25 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe26 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe27 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe28 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe29 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe30 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe31 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe32 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe33 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe34 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT  ;

signal		tx_rstn       :   STD_LOGIC_VECTOR(0 downto 0);   
signal		ram_en        :   STD_LOGIC_VECTOR(0 downto 0);   
signal		bpsk_en       :   STD_LOGIC_VECTOR(0 downto 0);   
signal		qpsk_en       :   STD_LOGIC_VECTOR(0 downto 0);   
signal		rate_sel       :   STD_LOGIC_VECTOR(0 downto 0);   
signal		dds_rstn      :   STD_LOGIC_VECTOR(0 downto 0);   
signal		dds_pinc_bpsk :   STD_LOGIC_VECTOR(31 downto 0);   
signal		dds_pinc_qpsk :   STD_LOGIC_VECTOR(31 downto 0);   
signal		dds_poff_bpsk :   STD_LOGIC_VECTOR(255 downto 0);   
signal		dds_poff_qpsk :   STD_LOGIC_VECTOR(255 downto 0); 
signal		atten_bpsk :   STD_LOGIC_VECTOR(15 downto 0);
signal		atten_qpsk :   STD_LOGIC_VECTOR(15 downto 0);

---- PCIe TX PS 侧信号 ----
signal		tx_rstn_ps     :   STD_LOGIC;
signal		ram_en_ps      :   STD_LOGIC;
signal		bpsk_en_ps     :   STD_LOGIC;
signal		qpsk_en_ps     :   STD_LOGIC;
signal		rate_sel_ps    :   STD_LOGIC;
signal		dds_rstn_ps    :   STD_LOGIC;
signal		dds_pinc_bpsk_ps :   STD_LOGIC_VECTOR(31 downto 0);
signal		dds_pinc_qpsk_ps :   STD_LOGIC_VECTOR(31 downto 0);
signal		dds_poff_bpsk_ps :   STD_LOGIC_VECTOR(255 downto 0);
signal		dds_poff_qpsk_ps :   STD_LOGIC_VECTOR(255 downto 0);
signal		atten_bpsk_ps :   STD_LOGIC_VECTOR(15 downto 0);
signal		atten_qpsk_ps :   STD_LOGIC_VECTOR(15 downto 0);
signal		ram_w_en_bpsk_ps    :   STD_LOGIC;
signal		ram_w_addr_bpsk_ps  :   STD_LOGIC_VECTOR(17 downto 0);
signal		ram_w_data_bpsk_ps  :   STD_LOGIC_VECTOR(15 downto 0);
signal		ram_w_en_qpsk_ps    :   STD_LOGIC;
signal		ram_w_addr_qpsk_ps  :   STD_LOGIC_VECTOR(14 downto 0);
signal		ram_w_data_qpsk_ps  :   STD_LOGIC_VECTOR(15 downto 0);
----    bpsk 循环发/单次发    ----
-- sym_num 只在 single_shot=1 时有用；single_shot 是模式位，和 rate_sel 一样走 vio/ps mux，
-- 保证 VIO 模式（上电默认）下行为与改动前逐拍一致。
signal		bpsk_sym_num_ps      :   STD_LOGIC_VECTOR(22 downto 0);
signal		bpsk_single_shot_ps  :   STD_LOGIC;
signal		bpsk_single_shot_mux :   STD_LOGIC;

-- vio/ps 选择信号（0:使用 vio_tx，1:使用 PS）
signal      tx_sel_vio_ps : STD_LOGIC_VECTOR(0 downto 0);

-- mux 后信号
signal      tx_rstn_mux       : STD_LOGIC;
signal      ram_en_mux        : STD_LOGIC;
signal      bpsk_en_mux       : STD_LOGIC;
signal      qpsk_en_mux       : STD_LOGIC;
signal      rate_sel_mux      : STD_LOGIC;
signal      dds_rstn_mux      : STD_LOGIC;
signal      dds_pinc_bpsk_mux : STD_LOGIC_VECTOR(31 downto 0);
signal      dds_pinc_qpsk_mux : STD_LOGIC_VECTOR(31 downto 0);
signal      dds_poff_bpsk_mux : STD_LOGIC_VECTOR(255 downto 0);
signal      dds_poff_qpsk_mux : STD_LOGIC_VECTOR(255 downto 0);
signal      atten_bpsk_mux : STD_LOGIC_VECTOR(15 downto 0);
signal      atten_qpsk_mux : STD_LOGIC_VECTOR(15 downto 0);

COMPONENT vio_tx
  PORT (
    clk : IN STD_LOGIC;
    probe_in0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out1 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out2 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out3 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe_out4 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe_out5 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    probe_out6 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    probe_out7 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out8 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe_out9 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe_out10 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out11 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out12 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

signal		iq :   STD_LOGIC_VECTOR(255 downto 0);   
-- bpsk/qpsk 并行链数据有效（8 路复乘 valid 相或），供顶层观察/使用
signal		bpsk_sig_valid :   STD_LOGIC;   
signal		qpsk_sig_valid :   STD_LOGIC;   
-- 送 DAC 的 axis tvalid：两条链的数据有效相或（各自被 bpsk_en/qpsk_en 门控）
signal		dac_sig_valid :   STD_LOGIC;   
COMPONENT tx_top
  PORT (
    clk : IN STD_LOGIC;
    rst_n : IN STD_LOGIC;
    ram_en : IN STD_LOGIC;
    bpsk_en : IN STD_LOGIC;
    qpsk_en : IN STD_LOGIC;
    rate_sel : IN STD_LOGIC;
    dds_rstn : IN STD_LOGIC;
    dds_pinc_bpsk : in  STD_LOGIC_VECTOR(31 DOWNTO 0);
    dds_pinc_qpsk : in STD_LOGIC_VECTOR(31 DOWNTO 0);
    dds_poff_bpsk : in STD_LOGIC_VECTOR(255 DOWNTO 0);
    dds_poff_qpsk : in STD_LOGIC_VECTOR(255 DOWNTO 0);
    atten_bpsk : in STD_LOGIC_VECTOR(15 DOWNTO 0);
    atten_qpsk : in STD_LOGIC_VECTOR(15 DOWNTO 0);
    ram_w_en_bpsk   : in STD_LOGIC;
    ram_w_addr_bpsk : in STD_LOGIC_VECTOR(17 DOWNTO 0);
    ram_w_data_bpsk : in STD_LOGIC_VECTOR(15 DOWNTO 0);
    ram_w_en_qpsk   : in STD_LOGIC;
    ram_w_addr_qpsk : in STD_LOGIC_VECTOR(14 DOWNTO 0);
    ram_w_data_qpsk : in STD_LOGIC_VECTOR(15 DOWNTO 0);
    bpsk_sym_num    : in STD_LOGIC_VECTOR(22 DOWNTO 0);
    bpsk_single_shot: in STD_LOGIC;
    iq: OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
    bpsk_sig_valid: OUT STD_LOGIC;
    qpsk_sig_valid: OUT STD_LOGIC
  );
 
END COMPONENT;

COMPONENT ila_tx

PORT (
	clk : IN STD_LOGIC;



	probe0 : IN STD_LOGIC_VECTOR(255 DOWNTO 0)
);
END COMPONENT  ;





COMPONENT ila_RX_TX_DATA_DUOBAO

PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe4 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe5 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe6 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe7 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe8 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe9 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe10 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe11 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe12 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe13 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe14 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe15 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe16 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe17 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe18 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe19 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe20 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe21 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe22 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe23 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe24 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe25 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe26 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe27 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe28 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe29 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe30 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe31 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe32 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe33 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe34 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe35 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe36 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe37 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe38 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe39 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe40 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe41 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe42 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe43 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT  ;

component SI5341
Port ( 
    ----    SI 5341相关    ----
		reset 						   : in  STD_LOGIC;                          	--	复位信号
		clk 						   : in  STD_LOGIC;							    --	由50MHz晶振产生
		flag_SI5341_config             : in  std_logic;
        reg_SI5341_config_wrdata       : in  std_logic_vector(15 downto 0);        --	SPI配置字写入
        reg_SI5341_config_rddata       : out std_logic_vector(15 downto 0);		--	SPI配置字读回
        reg_SPI_SI5341_config_state    : out std_logic_vector(15 downto 0);		--	SPI发射器状态 "AAAA" 表示空闲 "0000" 表示忙
		SI5341_MISO					   : in  STD_LOGIC;                             -- SDO 读入信号 --  
		SI5341_MOSI 				   : out STD_LOGIC;                             -- SDIO 输出信号 -- 
		SI5341_SCLK 				   : out STD_LOGIC;                             -- SCLK 时钟信号，最高20MHz -- 
		SI5341_SCS 					   : out STD_LOGIC;                             -- CSB 片选信号，低有效 --  
        SI5341_locked                  : in  std_logic                              -- LOL_B 锁定信号 --  
          );
end component;
--si5341 configuration
signal flag_SI5341_config 			:  std_logic;						
signal reg_SI5341_config_wrdata     :  std_logic_vector (15 downto 0);    
signal reg_SI5341_config_rddata     :  std_logic_vector (15 downto 0);
signal reg_SPI_SI5341_config_state  :  std_logic_vector (15 downto 0);    



component design_1_wrapper is
  port (
    CLK_IN_D_0_clk_n : in STD_LOGIC_VECTOR ( 0 to 0 );
    CLK_IN_D_0_clk_p : in STD_LOGIC_VECTOR ( 0 to 0 );
    adc0_clk_0_clk_n : in STD_LOGIC;
    adc0_clk_0_clk_p : in STD_LOGIC;
    adc2_clk_0_clk_n : in STD_LOGIC;
    adc2_clk_0_clk_p : in STD_LOGIC;
    adc3_clk_0_clk_n : in STD_LOGIC;
    adc3_clk_0_clk_p : in STD_LOGIC;
    bram_addr_a_0 : out STD_LOGIC_VECTOR ( 11 downto 0 );
    bram_addr_a_1 : out STD_LOGIC_VECTOR ( 12 downto 0 );
    bram_addr_b_0 : out STD_LOGIC_VECTOR ( 11 downto 0 );
    bram_addr_b_1 : out STD_LOGIC_VECTOR ( 19 downto 0 );
    bram_addr_b_2 : out STD_LOGIC_VECTOR ( 19 downto 0 );
    bram_addr_b_3 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    bram_addr_b_4 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    bram_addr_b_5 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    bram_addr_b_6 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    bram_addr_b_7 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    bram_clk_a_0 : out STD_LOGIC;
    bram_clk_a_1 : out STD_LOGIC;
    bram_clk_b_0 : out STD_LOGIC;
    bram_clk_b_1 : out STD_LOGIC;
    bram_clk_b_2 : out STD_LOGIC;
    bram_clk_b_3 : out STD_LOGIC;
    bram_clk_b_4 : out STD_LOGIC;
    bram_clk_b_5 : out STD_LOGIC;
    bram_clk_b_6 : out STD_LOGIC;
    bram_clk_b_7 : out STD_LOGIC;
    bram_en_a_0 : out STD_LOGIC;
    bram_en_a_1 : out STD_LOGIC;
    bram_en_b_0 : out STD_LOGIC;
    bram_en_b_1 : out STD_LOGIC;
    bram_en_b_2 : out STD_LOGIC;
    bram_en_b_3 : out STD_LOGIC;
    bram_en_b_4 : out STD_LOGIC;
    bram_en_b_5 : out STD_LOGIC;
    bram_en_b_6 : out STD_LOGIC;
    bram_en_b_7 : out STD_LOGIC;
    bram_rddata_a_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_a_1 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_b_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_b_1 : in STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_rddata_b_2 : in STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_rddata_b_3 : in STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_rddata_b_4 : in STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_rddata_b_5 : in STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_rddata_b_6 : in STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_rddata_b_7 : in STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_rst_a_0 : out STD_LOGIC;
    bram_rst_a_1 : out STD_LOGIC;
    bram_rst_b_0 : out STD_LOGIC;
    bram_rst_b_1 : out STD_LOGIC;
    bram_rst_b_2 : out STD_LOGIC;
    bram_rst_b_3 : out STD_LOGIC;
    bram_rst_b_4 : out STD_LOGIC;
    bram_rst_b_5 : out STD_LOGIC;
    bram_rst_b_6 : out STD_LOGIC;
    bram_rst_b_7 : out STD_LOGIC;
    bram_we_a_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    bram_we_a_1 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    bram_we_b_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    bram_we_b_1 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    bram_we_b_2 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    bram_we_b_3 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    bram_we_b_4 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    bram_we_b_5 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    bram_we_b_6 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    bram_we_b_7 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    bram_wrdata_a_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_wrdata_a_1 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_wrdata_b_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_wrdata_b_1 : out STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_wrdata_b_2 : out STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_wrdata_b_3 : out STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_wrdata_b_4 : out STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_wrdata_b_5 : out STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_wrdata_b_6 : out STD_LOGIC_VECTOR ( 511 downto 0 );
    bram_wrdata_b_7 : out STD_LOGIC_VECTOR ( 511 downto 0 );
    cdma_introut_0 : out STD_LOGIC;
    clk_100M : out STD_LOGIC;
    clk_adc0_0 : out STD_LOGIC;
    clk_adc1_0 : out STD_LOGIC;
    clk_adc2_0 : out STD_LOGIC;
    clk_adc3_0 : out STD_LOGIC;
    clk_dac0_0 : out STD_LOGIC;
    clk_dac2_0 : out STD_LOGIC;
    dac0_clk_0_clk_n : in STD_LOGIC;
    dac0_clk_0_clk_p : in STD_LOGIC;
    dac2_clk_0_clk_n : in STD_LOGIC;
    dac2_clk_0_clk_p : in STD_LOGIC;
    emio_uart0_rxd_0 : in STD_LOGIC;
    emio_uart0_txd_0 : out STD_LOGIC;
    gpio_io_i_0 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    gpio_io_i_1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    irq_0 : out STD_LOGIC;
    m00_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m00_axis_tready_0 : in STD_LOGIC;
    m00_axis_tvalid_0 : out STD_LOGIC;
    m01_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m01_axis_tready_0 : in STD_LOGIC;
    m01_axis_tvalid_0 : out STD_LOGIC;
    m02_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m02_axis_tready_0 : in STD_LOGIC;
    m02_axis_tvalid_0 : out STD_LOGIC;
    m03_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m03_axis_tready_0 : in STD_LOGIC;
    m03_axis_tvalid_0 : out STD_LOGIC;
    m0_axis_aclk_0 : in STD_LOGIC;
    m0_axis_aresetn_0 : in STD_LOGIC;
    m10_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m10_axis_tready_0 : in STD_LOGIC;
    m10_axis_tvalid_0 : out STD_LOGIC;
    m11_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m11_axis_tready_0 : in STD_LOGIC;
    m11_axis_tvalid_0 : out STD_LOGIC;
    m12_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m12_axis_tready_0 : in STD_LOGIC;
    m12_axis_tvalid_0 : out STD_LOGIC;
    m13_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m13_axis_tready_0 : in STD_LOGIC;
    m13_axis_tvalid_0 : out STD_LOGIC;
    m1_axis_aclk_0 : in STD_LOGIC;
    m1_axis_aresetn_0 : in STD_LOGIC;
    m20_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m20_axis_tready_0 : in STD_LOGIC;
    m20_axis_tvalid_0 : out STD_LOGIC;
    m21_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m21_axis_tready_0 : in STD_LOGIC;
    m21_axis_tvalid_0 : out STD_LOGIC;
    m22_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m22_axis_tready_0 : in STD_LOGIC;
    m22_axis_tvalid_0 : out STD_LOGIC;
    m23_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m23_axis_tready_0 : in STD_LOGIC;
    m23_axis_tvalid_0 : out STD_LOGIC;
    m2_axis_aclk_0 : in STD_LOGIC;
    m2_axis_aresetn_0 : in STD_LOGIC;
    m30_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m30_axis_tready_0 : in STD_LOGIC;
    m30_axis_tvalid_0 : out STD_LOGIC;
    m31_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m31_axis_tready_0 : in STD_LOGIC;
    m31_axis_tvalid_0 : out STD_LOGIC;
    m32_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m32_axis_tready_0 : in STD_LOGIC;
    m32_axis_tvalid_0 : out STD_LOGIC;
    m33_axis_tdata_0 : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m33_axis_tready_0 : in STD_LOGIC;
    m33_axis_tvalid_0 : out STD_LOGIC;
    m3_axis_aclk_0 : in STD_LOGIC;
    m3_axis_aresetn_0 : in STD_LOGIC;
    mem_a_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    mem_a_1 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    mem_cen_0 : out STD_LOGIC_VECTOR ( 0 to 0 );
    mem_cen_1 : out STD_LOGIC_VECTOR ( 0 to 0 );
    mem_dq_i_0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    mem_dq_i_1 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    mem_dq_o_0 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    mem_dq_o_1 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    mem_oen_0 : out STD_LOGIC_VECTOR ( 0 to 0 );
    mem_oen_1 : out STD_LOGIC_VECTOR ( 0 to 0 );
    mem_wen_0 : out STD_LOGIC;
    mem_wen_1 : out STD_LOGIC;
    pcie_mgt_0_rxn : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_mgt_0_rxp : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_mgt_0_txn : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_mgt_0_txp : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ps_aresten_100M : out STD_LOGIC_VECTOR ( 0 to 0 );
    s00_axis_tdata_0 : in STD_LOGIC_VECTOR ( 255 downto 0 );
    s00_axis_tready_0 : out STD_LOGIC;
    s00_axis_tvalid_0 : in STD_LOGIC;
    s0_axis_aclk_0 : in STD_LOGIC;
    s0_axis_aresetn_0 : in STD_LOGIC;
    s20_axis_tdata_0 : in STD_LOGIC_VECTOR ( 255 downto 0 );
    s20_axis_tready_0 : out STD_LOGIC;
    s20_axis_tvalid_0 : in STD_LOGIC;
    s2_axis_aclk_0 : in STD_LOGIC;
    s2_axis_aresetn_0 : in STD_LOGIC;
    sys_rst_n_0 : in STD_LOGIC;
    user_lnk_up_0 : out STD_LOGIC;
    usr_irq_ack_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    usr_irq_req_0 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    vin0_01_0_v_n : in STD_LOGIC;
    vin0_01_0_v_p : in STD_LOGIC;
    vin0_23_0_v_n : in STD_LOGIC;
    vin0_23_0_v_p : in STD_LOGIC;
    vin1_01_0_v_n : in STD_LOGIC;
    vin1_01_0_v_p : in STD_LOGIC;
    vin1_23_0_v_n : in STD_LOGIC;
    vin1_23_0_v_p : in STD_LOGIC;
    vin2_01_0_v_n : in STD_LOGIC;
    vin2_01_0_v_p : in STD_LOGIC;
    vin2_23_0_v_n : in STD_LOGIC;
    vin2_23_0_v_p : in STD_LOGIC;
    vin3_01_0_v_n : in STD_LOGIC;
    vin3_01_0_v_p : in STD_LOGIC;
    vin3_23_0_v_n : in STD_LOGIC;
    vin3_23_0_v_p : in STD_LOGIC;
    vout00_0_v_n : out STD_LOGIC;
    vout00_0_v_p : out STD_LOGIC;
    vout20_0_v_n : out STD_LOGIC;
    vout20_0_v_p : out STD_LOGIC
  );
end component;
------ emc read and write -------
signal  mem_a_0                     :  STD_LOGIC_VECTOR ( 31 downto 0 );
signal  mem_cen_0                    :  STD_LOGIC_VECTOR ( 0 to 0 );
signal  mem_dq_i_0                  :  STD_LOGIC_VECTOR ( 15 downto 0 );
signal  mem_dq_o_0                  :  STD_LOGIC_VECTOR ( 15 downto 0 );
signal  mem_oen_0                   :  STD_LOGIC_VECTOR ( 0 to 0 );
signal  mem_wen_0                   :  STD_LOGIC;
signal  mem_a_1                     :  STD_LOGIC_VECTOR ( 31 downto 0 );
signal  mem_cen_1                    :  STD_LOGIC_VECTOR ( 0 to 0 );
signal  mem_dq_i_1                  :  STD_LOGIC_VECTOR ( 15 downto 0 );
signal  mem_dq_o_1                  :  STD_LOGIC_VECTOR ( 15 downto 0 );
signal  mem_oen_1                   :  STD_LOGIC_VECTOR ( 0 to 0 );
signal  mem_wen_1                   :  STD_LOGIC;
----- gpio ------
signal  gpio_rtl_tri_i_0            :  STD_LOGIC_VECTOR ( 1 downto 0 );
signal  gpio_rtl_tri_i_1            :  STD_LOGIC;
----- rfsoc data converter -- adc ------
signal  adc1_clk_0_clk_n            :  STD_LOGIC;
signal  adc1_clk_0_clk_p            :  STD_LOGIC;

signal  irq_0                       :  STD_LOGIC;


signal  clk_adc0_0                  :  STD_LOGIC;
signal  clk_adc1_0                  :  STD_LOGIC;
signal  clk_adc2_0                  :  STD_LOGIC;
signal  clk_adc3_0                  :  STD_LOGIC;
signal  m00_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m00_axis_tready_0           :  STD_LOGIC;
signal  m00_axis_tvalid_0           :  STD_LOGIC;
signal  m01_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m01_axis_tready_0           :  STD_LOGIC;
signal  m01_axis_tvalid_0           :  STD_LOGIC;
signal  m02_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m02_axis_tready_0           :  STD_LOGIC;
signal  m02_axis_tvalid_0           :  STD_LOGIC;
signal  m03_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m03_axis_tready_0           :  STD_LOGIC;
signal  m03_axis_tvalid_0           :  STD_LOGIC;
signal  m0_axis_aclk_0              :  STD_LOGIC;
signal  m0_axis_aresetn_0           :  STD_LOGIC;
signal  m10_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m10_axis_tready_0           :  STD_LOGIC;
signal  m10_axis_tvalid_0           :  STD_LOGIC;
signal  m11_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m11_axis_tready_0           :  STD_LOGIC;
signal  m11_axis_tvalid_0           :  STD_LOGIC;
signal  m12_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m12_axis_tready_0           :  STD_LOGIC;
signal  m12_axis_tvalid_0           :  STD_LOGIC;
signal  m13_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m13_axis_tready_0           :  STD_LOGIC;
signal  m13_axis_tvalid_0           :  STD_LOGIC;
signal  m1_axis_aclk_0              :  STD_LOGIC;
signal  m1_axis_aresetn_0           :  STD_LOGIC;
signal  m20_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m20_axis_tready_0           :  STD_LOGIC;
signal  m20_axis_tvalid_0           :  STD_LOGIC;
signal  m21_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m21_axis_tready_0           :  STD_LOGIC;
signal  m21_axis_tvalid_0           :  STD_LOGIC;
signal  m22_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m22_axis_tready_0           :  STD_LOGIC;
signal  m22_axis_tvalid_0           :  STD_LOGIC;
signal  m23_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m23_axis_tready_0           :  STD_LOGIC;
signal  m23_axis_tvalid_0           :  STD_LOGIC;
signal  m2_axis_aclk_0              :  STD_LOGIC;
signal  m2_axis_aresetn_0           :  STD_LOGIC;
signal  m30_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m30_axis_tready_0           :  STD_LOGIC;
signal  m30_axis_tvalid_0           :  STD_LOGIC;
signal  m31_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m31_axis_tready_0           :  STD_LOGIC;
signal  m31_axis_tvalid_0           :  STD_LOGIC;
signal  m32_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m32_axis_tready_0           :  STD_LOGIC;
signal  m32_axis_tvalid_0           :  STD_LOGIC;
signal  m33_axis_tdata_0            :  STD_LOGIC_VECTOR ( 127 downto 0 );
signal  m33_axis_tready_0           :  STD_LOGIC;
signal  m33_axis_tvalid_0           :  STD_LOGIC;
signal  m3_axis_aclk_0              :  STD_LOGIC;
signal  m3_axis_aresetn_0           :  STD_LOGIC;


signal  vin1_01_0_v_n               :  STD_LOGIC;
signal  vin1_01_0_v_p               :  STD_LOGIC;
signal  vin1_23_0_v_n               :  STD_LOGIC;
signal  vin1_23_0_v_p               :  STD_LOGIC;
signal  vin2_23_0_v_n               :  STD_LOGIC;
signal  vin2_23_0_v_p               :  STD_LOGIC;
----- rfsoc data converter -- dac ------
signal  dac0_clk_0_clk_n              :  STD_LOGIC;
signal  dac0_clk_0_clk_p              :  STD_LOGIC;
signal  dac2_clk_0_clk_n              :  STD_LOGIC;
signal  dac2_clk_0_clk_p              :  STD_LOGIC;
signal  s00_axis_tdata_0            :  STD_LOGIC_VECTOR ( 255 downto 0 );
signal  s00_axis_tready_0           :  STD_LOGIC;
signal  s00_axis_tvalid_0           :  STD_LOGIC;
signal  s0_axis_aclk_0              :  STD_LOGIC;
signal  s0_axis_aresetn_0           :  STD_LOGIC;
signal  s20_axis_tdata_0            :  STD_LOGIC_VECTOR ( 255 downto 0 );
signal  s20_axis_tready_0           :  STD_LOGIC;
signal  s20_axis_tvalid_0           :  STD_LOGIC;
signal  s2_axis_aclk_0              :  STD_LOGIC;
signal  s2_axis_aresetn_0           :  STD_LOGIC;
signal  vout00_n_0                  :  STD_LOGIC;
signal  vout00_p_0                  :  STD_LOGIC;
signal  clk_dac0_0                  :  STD_LOGIC;
signal  clk_dac2_0                  :  STD_LOGIC;
----- BRAM AND CDMA ------
signal  bram_addr_a_0               :  STD_LOGIC_VECTOR ( 12 downto 0 );
signal  bram_clk_a_0                :  STD_LOGIC;
signal  bram_en_a_0                 :  STD_LOGIC;
signal  bram_rddata_a_0             :  STD_LOGIC_VECTOR ( 31 downto 0 );
signal  bram_rst_a_0                :  STD_LOGIC;
signal  bram_we_a_0                 : STD_LOGIC_VECTOR ( 3 downto 0 );
signal  bram_wrdata_a_0             :  STD_LOGIC_VECTOR ( 31 downto 0 );
signal  cdma_introut_0              :  STD_LOGIC;


component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  -- Status and control signals
  resetn             : in     std_logic;
  locked            : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;

component clk_wiz_1
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  -- Status and control signals
  resetn             : in     std_logic;
  locked            : out    std_logic;
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic
 );
end component;

signal  clk_100M_ps            :  STD_LOGIC;
signal  clk_100M               :  STD_LOGIC;
signal  resetn_ps_100M 	       :  STD_LOGIC;

component ps_interface_0 is
    Port ( clk   : in STD_LOGIC;
           rsten : in STD_LOGIC;
           ----    EMC interface    ----
           ps_oen  : in std_logic;
           ps_wen  : in std_logic;
           ps_cen  : in std_logic;
           ps_din  : out std_logic_vector(15 downto 0);
           ps_dout : in std_logic_vector(15 downto 0);
           ps_addr : in std_logic_vector(11 downto 0);
           ----    PS reset    ----
           global_rst : out STD_LOGIC;
           ----    SI 5341相关    ----
           flag_SI5341_config : out std_logic;
           reg_SI5341_config_wrdata : out std_logic_vector(15 downto 0);
           reg_SI5341_config_rddata : in std_logic_vector(15 downto 0);
           reg_SPI_SI5341_config_state : in std_logic_vector(15 downto 0);
           SI5341_locked : in std_logic;
           mmcm_locked : in std_logic
            );
end component;
signal global_rst :std_logic;
signal SI5341_locked_internal :std_logic;

component ps_interface_1 is
    Port ( 
		reset 		: in  STD_LOGIC;
		clk_128M   	: in  STD_LOGIC;
		resetn_ps 	: in  STD_LOGIC;
		clk_100M 	: in  STD_LOGIC;
		----    EMC interface    ----
		ps_oen  : in    std_logic;
		ps_wen  : in    std_logic;
		ps_cen  : in    std_logic;
		ps_din  : out   std_logic_vector(15 downto 0);
		ps_dout : in    std_logic_vector(15 downto 0);
		ps_addr : in    std_logic_vector(11 downto 0);

--		----    AD9520相关    ----
--		flag_AD9520_config             : out   std_logic;
--		reg_AD9520_config_wrdata       : out   std_logic_vector(23 downto 0);
--        reset_PLL       : out   std_logic;
--		 reg_AD9520_config_rddata 	    : in 	std_logic;
--		reg_SPI_AD9520_config_state    : in    std_logic_vector(15 downto 0);

--		----    AD9680相关    ----
--		flag_AD9680_config             : out   std_logic;
--		reg_AD9680_config_wrdata       : out   std_logic_vector(15 downto 0);
--		reg_AD9680_config_rddata       : in    std_logic_vector(15 downto 0);
--		reg_SPI_AD9680_config_state    : in    std_logic_vector(15 downto 0);

--        ----    AD9680_2相关    ----
--        flag_AD9680_2_config             : out   std_logic;
--        reg_AD9680_2_config_wrdata       : out   std_logic_vector(15 downto 0);
--        reg_AD9680_2_config_rddata       : in    std_logic_vector(15 downto 0);
--        reg_SPI_AD9680_2_config_state    : in    std_logic_vector(15 downto 0);

--		jesd_reset						: out std_logic;
--		jesd_reset_n					: out std_logic;
--		ps_ReSync						: out std_logic;
--		data_valid						: in std_logic;
--        jesd_ByteIsAligned : in  STD_LOGIC_VECTOR (7 downto 0);
----		data_valid_k7                   : in std_logic;
--		----    AD9739相关    ----
--		flag_AD9739_config             : out   std_logic;
--		reg_AD9739_config_wrdata       : out   std_logic_vector(15 downto 0);
--		reg_AD9739_config_rddata       : in    std_logic_vector(15 downto 0);
--		reg_SPI_AD9739_config_state    : in    std_logic_vector(15 downto 0);
		
--		----    AD5XXX相关    ----  
--		flag_AD5XXX_config : out  STD_LOGIC;
--		reg_AD5XXX_wrdata  : out  STD_LOGIC_VECTOR (15 downto 0);
--		reg_AD5XXX_mode     : out std_logic_vector(3 downto 0);
--        reg_LDAC        : out  STD_LOGIC;
	
		contrl_8506 : out STD_LOGIC_VECTOR (15 downto 0);       ---- 光纤配置
		----	ARM写	----
		reg_initial_reset : out  STD_LOGIC_VECTOR (2 downto 0);
		reg_tx_mode : out  STD_LOGIC_VECTOR (7 downto 0);
		reg_tx_mode_para : out  STD_LOGIC_VECTOR (7 downto 0); 
		
		-----  功率检测模式  ------
		agc_control_mode   : out  STD_LOGIC_vector(15 downto 0);
		-----  agc_control  ------
		agc_arm_ctrl_mode : out  STD_LOGIC_VECTOR (15 downto 0);				--- 0正常，1arm控
		agc_arm_ctrl_DVGA4 : out  STD_LOGIC_vector(5 downto 0);
		agc_arm_ctrl_12 : out  STD_LOGIC;
		flag_agc_arm_ctrl_DVGA4 : out  STD_LOGIC;
		THRESHOLD_WIDTH: out  STD_LOGIC_VECTOR (15 downto 0); 
        THRESHOLD_INSIDE: out  STD_LOGIC_VECTOR (15 downto 0);
        THRESHOLD_CENTER: out  STD_LOGIC_VECTOR (15 downto 0);
        RESPONSE_TIME		: out  STD_LOGIC_VECTOR (15 downto 0);

--		agc_arm_ctrl_mode : out  STD_LOGIC_VECTOR (15 downto 0);	--- 0正常，1arm控
		agc_arm_ctrl_DVGA1 : out  STD_LOGIC_vector(5 downto 0);
		agc_arm_ctrl_DVGA2 : out  STD_LOGIC_vector(5 downto 0);
--		agc_arm_ctrl_12 : out  STD_LOGIC;
		agc_arm_ctrl_DVGA3 : out  STD_LOGIC_vector(5 downto 0);
--		agc_arm_ctrl_DVGA4 : out  STD_LOGIC_vector(5 downto 0);
		agc_arm_ctrl_34 : out  STD_LOGIC;
		
		----------------------------数字衰减----------------
        shift_config_value : out std_logic_vector(3 downto 0);
		shift_din_value    : out std_logic_vector(3 downto 0);
		

		ram_PN_sync_we : out  STD_LOGIC;
		ram_PN_sync_din : out  STD_LOGIC_VECTOR(15 downto 0);
		ram_PN_PAn_we : out  STD_LOGIC;
		ram_PN_PAn_din : out  STD_LOGIC_VECTOR(15 downto 0);
		ram_PN_scramble_we : out  STD_LOGIC;
		ram_PN_scramble_din : out  STD_LOGIC_VECTOR(15 downto 0);
		ram_PN_interleave_we : out  STD_LOGIC;
		ram_PN_interleave_din : out  STD_LOGIC_VECTOR(15 downto 0);
		ram_tx_interface_buffer_we : out  STD_LOGIC;
		ram_tx_interface_buffer_din : out  STD_LOGIC_VECTOR (15 downto 0);
		ram_tx_interface_buffer_din_type : out  STD_LOGIC_VECTOR (1 downto 0);
		ram_tx_interface_buffer_we_1 : out  STD_LOGIC;
		ram_tx_interface_buffer_din_1 : out  STD_LOGIC_VECTOR (15 downto 0);
		ram_tx_interface_buffer_din_type_1 : out  STD_LOGIC_VECTOR (1 downto 0);
		ram_tx_interface_buffer_we_2 : out  STD_LOGIC;
		ram_tx_interface_buffer_din_2 : out  STD_LOGIC_VECTOR (15 downto 0);
		ram_tx_interface_buffer_din_type_2 : out  STD_LOGIC_VECTOR (1 downto 0);
		flag_rd_arm_onepacket : out  STD_LOGIC;
		flag_rd_arm_oneint : out  STD_LOGIC;  
		flag_rd_srio_onepacket : out std_logic;     ----K7 SRIO
        flag_rd_srio_oneint : out std_logic;
		falg_irq_k_end : out std_logic;
		falg_irq_k_end_k : out std_logic;
		flag_tx_nread  : out std_logic;		
		Antenna_switch_local : out  std_logic_vector(15 downto 0);
		packet_time_interval : out std_logic_vector(31 downto 0);
		pulse_framer_length : out std_logic_vector(15 downto 0);

		----	ARM读	----		                  
		reg_tx_interface_buffer_num_0 : in  STD_LOGIC_VECTOR (11 downto 0);
		reg_tx_interface_buffer_num_1 : in  STD_LOGIC_VECTOR (11 downto 0);
		reg_tx_interface_buffer_num_2 : in  STD_LOGIC_VECTOR (11 downto 0);
		flag_monitor_cancel : out  STD_LOGIC;
		reg_state : in  STD_LOGIC_VECTOR(15 downto 0);
		reg_monitor : in  STD_LOGIC_VECTOR(15 downto 0);
		flag_rd_arm_onetime : out  STD_LOGIC;    
		dout_rx_arm_interface : in  STD_LOGIC_VECTOR (15 downto 0);
		num_buffer_rx_arm_interface : in  STD_LOGIC_VECTOR (3 downto 0);
		flag_rd_srio_onetime : out  std_logic;        ----K7 srio读
        num_buffer_rx_srio_interface : in std_logic_vector(3 downto 0);
        dout_rx_srio_interface : in std_logic_vector(15 downto 0) ;
		
		MEASURED_TEMP_ZYNQ : in std_logic_vector(11 downto 0);
--		MEASURED_TEMP_K7 : in std_logic_vector(7 downto 0);
--		clk_lock_state : in std_logic_vector(7 downto 0);
		----   K7 版本号    ----
--		Version_K7  :  in std_logic_vector(2 downto 0);
		----   k7 FPGA加载相关   ----
		PROGRAM_CONFIG_FPGA2 : out std_logic;
--		DONE_CONFIG_FPGA2 : in std_logic;		
		----    K7 时间同步计数器清零标志    ----
		reset_time            :  out std_logic;		
		----    K7 读取寄存器标志    ----
	    falg_rx_resp  :  in std_logic;
	    rx_resp_data  :  in STD_LOGIC_vector(15 downto 0);
	    falg_rd_respdata_complete  :  out std_logic;
		
		----   配置接收参数   ---
		arm_config_sync_head_array : out sync_bits_array_type(0 to 14);
		arm_config_sync_tail_array : out sync_bits_array_type(0 to 14);
		arm_config_matrix_pattern_freq_x1 : out  std_logic_vector (47 downto 0);
		arm_config_matrix_pattern_freq_x2 : out  std_logic_vector (47 downto 0);
		arm_config_matrix_pattern_freq_x3 : out  std_logic_vector (47 downto 0);
		arm_config_matrix_pattern_freq_x4 : out  std_logic_vector (47 downto 0);
		arm_config_addr_offset_x1 : out addr_offset_array_type(0 to 14);
		arm_config_addr_offset_x2 : out addr_offset_array_type(0 to 14);
		arm_config_addr_offset_x3 : out addr_offset_array_type(0 to 14);
		arm_config_addr_offset_x4 : out addr_offset_array_type(0 to 14);
		arm_config_PN_deinterleave_array : out PN_deinterleave_array_type(0 to 11);
		arm_config_rx_rate_mode : out std_logic_vector(1 downto 0);
		arm_config_rx_filter_sel : out  STD_LOGIC;
		ram_PN_descramble_we : out  STD_LOGIC;
		ram_PN_descramble_din : out  STD_LOGIC_VECTOR (15 downto 0);
		threshold_pulse_num : out  STD_LOGIC_VECTOR (4 downto 0);
		threshold_sync_xcorr : out  STD_LOGIC_VECTOR (15 downto 0);
		rdy_rx : out  STD_LOGIC;
		flag_start_rx : out  STD_LOGIC;
		point_test_rx : out  STD_LOGIC_VECTOR (13 downto 0);
		----   K7接收参数     ----
		flag_agc_arm_ctrl_mode : out std_logic;----k7
		sync_bit_pre_rx_s : out std_logic_vector(23 downto 0);--k7
		flag_wr_sync_bit_pre : out std_logic;
		sync_bit_post_rx_s : out std_logic_vector(23 downto 0);--k7
		flag_wr_sync_bit_post : out std_logic;
		
		flag_pattern_freq_rx_x1 : out std_logic;----k7
		flag_pattern_freq_rx_x2 : out std_logic;
		flag_pattern_freq_rx_x3 : out std_logic;
		flag_pattern_freq_rx_x4 : out std_logic;
		time_hopping_rx_x1_s : out std_logic_vector(13 downto 0);----k7
		flag_time_hoppong_rx_x1 : out std_logic;
		time_hopping_rx_x2_s : out std_logic_vector(13 downto 0);
		flag_time_hoppong_rx_x2 : out std_logic;
		time_hopping_rx_x3_s : out std_logic_vector(13 downto 0);
		flag_time_hoppong_rx_x3 : out std_logic;
		time_hopping_rx_x4_s : out std_logic_vector(13 downto 0);
		flag_time_hoppong_rx_x4 : out std_logic;
		PN_deinterleave_s : out std_logic_vector(15 downto 0);--k7
		flag_PN_deinterleave : out std_logic;
		flag_arm_config_rx_rate_mode_sel : out std_logic;
		-- flag_arm_config_rx_filter_sel : out std_logic;
		flag_ram_PN_descramble_din : out std_logic;
		flag_threshold_pulse_num : out std_logic;
		flag_threshold_sync_xcorr : out std_logic;
		flag_rdy_rx : out std_logic;
		-- flag_flag_start_rx : out std_logic;
		flag_point_test_rx : out std_logic;
		flag_channel_busy_threshold : out std_logic;
		flag_channel_capure_threshold : out std_logic;
		flag_Antenna_switch_local :out std_logic;
        jesd_reset_AD2 : out std_logic;
		flag_jesd_reset_AD2 : out std_logic;
		
		----	信道负载	-----
		channel_busy_threshold : out std_logic_vector(15 downto 0);			---- 信道负载判决门限
		channel_load : in std_logic_vector(15 downto 0);					---- 表征信道负载
		
		channel_capure_threshold : out std_logic_vector(15 downto 0);		---- 24位捕获寄存器判决门限
		----   频点择优模式   ----
		dds_clr : out  STD_LOGIC;
		dds_freq_para_local : out  dds_para_array_type(15 downto 0);
		counter_switch : out std_logic;
		counter_2M:in std_logic_vector(15 downto 0);
		counter_500k:in std_logic_vector(15 downto 0);
		----	TEST	----	
		arm_config_power_control : out std_logic_vector(3 downto 0);
		arm_config_switch : out std_logic_vector(2 downto 0);
--		TX_LE : out  STD_LOGIC;		
		
		LNA_switch_hand_1 : out  STD_LOGIC;	
        LNA_switch_hand_2 : out  STD_LOGIC;    
        PA_switch_hand : out  STD_LOGIC;          
        
		--***********************时间同步***************************
		----    发射时间戳    ----
        send_timestamp_2    : in std_logic_vector(15 downto 0);
        send_timestamp_1    : in std_logic_vector(15 downto 0);
        send_timestamp_0    : in std_logic_vector(15 downto 0);
        ----  捕获时标计数器数值----
        send_timestamp_cor_2                     : in std_logic_vector(15 downto 0);
        send_timestamp_cor_1                     : in std_logic_vector(15 downto 0);
        send_timestamp_cor_0                     : in std_logic_vector(15 downto 0);
        -----  捕获时 时标计数器周期新旧值标志-----
        flag_send_timestamp_cor                      : in std_logic;
        ----    发射时间戳更新标志    ----
        flag_tx_time_renew                       : in  std_logic;
        ----    发射时间戳读取标志    ----
        flag_tx_timestamp_read                   : out std_logic;
        ----    time offset    ----
        offset_time_2            : out std_logic_vector(15 downto 0);
        offset_time_1            : out std_logic_vector(15 downto 0);
        offset_time_0            : out std_logic_vector(15 downto 0);
        flag_offset_time_adjust  : out std_logic;
 		----    time offset    ----
        offset_time_2_k7            : out std_logic_vector(15 downto 0);
        offset_time_1_k7            : out std_logic_vector(15 downto 0);
        offset_time_0_k7            : out std_logic_vector(15 downto 0);
        flag_offset_time_adjust_k7  : out std_logic;  
		----    物理层时间上传    ----
	    reg_phy_time             : in  std_logic_vector(47 downto 0);
        STATUS_ADHOC  :  out std_logic;
        
       ----   PLL   ----
      flag_RF_PLL_TxRx_configuration : out  STD_LOGIC;
      flag_RF_PLL_CLK_configuration : out  STD_LOGIC;
      data_RF_PLL_configuration : out  STD_LOGIC_VECTOR (31 downto 0);        
--      RF_PLL_CEN1 : out  STD_LOGIC;
--      RF_PLL_CEN2 : out  STD_LOGIC;    
      
		----jesd配置
		jesd_ila               :  out  std_logic_vector(7 downto 0);
		flag_jesd_ila          :  out  std_logic;
		jesd_src               :  out  std_logic_vector(7 downto 0);
		flag_jesd_src          :  out  std_logic;
		jesd_mod               :  out  std_logic_vector(7 downto 0);
		flag_jesd_mod          :  out  std_logic;
		jesd_f                 :  out  std_logic_vector(7 downto 0);
		flag_jesd_f            :  out  std_logic;
		jesd_k                 :  out  std_logic_vector(7 downto 0);
		flag_jesd_k            :  out  std_logic;
		jesd_lanes             :  out  std_logic_vector(7 downto 0);
		flag_jesd_lanes        :  out  std_logic;
		jesd_subclass          :  out  std_logic_vector(7 downto 0);
		flag_jesd_subclass     :  out  std_logic;
		jesd_delay             :  out  std_logic_vector(7 downto 0);
		flag_jesd_delay        :  out  std_logic;
		jesd_erro              :  out  std_logic_vector(7 downto 0);
		flag_jesd_erro         :  out  std_logic;
		jesd_erroo             :  out  std_logic_vector(15 downto 0);
		flag_jesd_erroo        :  out  std_logic;
		EN_timestamp_cor : out  STD_LOGIC;
        flag_timestamp_cor : out  STD_LOGIC;
        value_timestamp_cor : out  STD_LOGIC_VECTOR (47 downto 0);	
        polarity_cor : out  STD_LOGIC;
        times_timestamp_cor : in  STD_LOGIC_VECTOR (15 downto 0);
        
        doppler_freq :out std_logic_vector(15 downto 0);
        doppler_freq_init0 :out std_logic_vector(15 downto 0);
        doppler_freq_init1 :out std_logic_vector(15 downto 0);
        doppler_freq_init2 :out std_logic_vector(15 downto 0);
        doppler_freq_init3 :out std_logic_vector(15 downto 0);
        doppler_freq_init4 :out std_logic_vector(15 downto 0);
        doppler_freq_init5 :out std_logic_vector(15 downto 0);
        doppler_freq_init6 :out std_logic_vector(15 downto 0);
        doppler_freq_init7 :out std_logic_vector(15 downto 0);
        
        pl_mod : out std_logic;
        board_mod   : out std_logic_vector(1 downto 0); ---板间通信和板内自环通信
        wave_mod : out std_logic ;  ---发射单载波还是发包
        data_en : out std_logic  ;  ---单载波发射控制开关
        ---------- 射频控制----------------
        work_mod : out STD_LOGIC_VECTOR (1 downto 0);
        PA_switch_ps : out std_logic;
        T_R_TTL_ps : out    std_logic;
        LNA_switch_ps: out std_logic;
        SW_R0_in_ps    : out    std_logic;
        SW_R1_in_ps    : out    std_logic;
        SW_R2_in_ps    : out    std_logic;
        SW_T_in_ps     : out    std_logic;
        SEL0_TX_in_ps  : out    std_logic;
        SEL1_TX_in_ps  : out    std_logic;
        R0_C0_ps   : out    std_logic;
        R0_C1_ps   : out    std_logic;
        R0_C2_ps   : out    std_logic;
        R0_C3_ps   : out    std_logic;
        R0_C4_ps   : out    std_logic;
        R0_C5_ps   : out    std_logic;
        R1_C0_ps   : out    std_logic;
        R1_C1_ps   : out    std_logic;
        R1_C2_ps   : out    std_logic;
        R1_C3_ps   : out    std_logic;
        R1_C4_ps   : out    std_logic;
        R1_C5_ps   : out    std_logic;
        R2_C0_ps   : out    std_logic;
        R2_C1_ps   : out    std_logic;
        R2_C2_ps   : out    std_logic;
        R2_C3_ps   : out    std_logic;
        R2_C4_ps   : out    std_logic;
        R2_C5_ps   : out    std_logic;
        T_C0_ps    : out    std_logic;
        T_C1_ps    : out    std_logic;
        T_C2_ps    : out    std_logic;
        T_C3_ps    : out    std_logic;
        T_C4_ps    : out    std_logic;
        T_C5_ps    : out    std_logic;
        ------ 初始化完成状态标志位  -------
        initial_complete_state : out    std_logic;
        ---------灯-------------------------
        gpio_warning_internal       : out std_logic   ;
        gpio_power_internal         : out std_logic   ;
        ----   dds 相位赋值 (100M DA输出)  ----
        flag_10M_start                 : out STD_LOGIC;
        s_axis_phase_inc               : out   std_logic_vector(15 downto 0);     
        s_axis_phase_offset_0          : out   std_logic_vector(15 downto 0);
        s_axis_phase_offset_1          : out   std_logic_vector(15 downto 0);
        s_axis_phase_offset_2          : out   std_logic_vector(15 downto 0);
        s_axis_phase_offset_3          : out   std_logic_vector(15 downto 0);
        s_axis_phase_offset_4          : out   std_logic_vector(15 downto 0);
        s_axis_phase_offset_5          : out   std_logic_vector(15 downto 0);
        s_axis_phase_offset_6          : out   std_logic_vector(15 downto 0);
        s_axis_phase_offset_7          : out   std_logic_vector(15 downto 0);
         -- PS 读标志 ----
        flag_lock_reg_PS_read_tx              : out std_logic;      
        flag_lock_reg_PS_read_rx              : out std_logic;
        EN_time_hopping                      : out   std_logic_vector(3 downto 0);
        ----  定频模式切换与选择   ----
        flag_freq_hopping_control             : out std_logic;
        freq_hopping_select                   : out std_logic_vector(3 downto 0);
        
        -----------------------TDMA控制信号-----------------------
        speed_control: out STD_LOGIC_VECTOR (1 downto 0);
        EN_timebase : out  STD_LOGIC;
        num_frame_timeslot : out  STD_LOGIC_VECTOR (9 downto 0);					
        num_preframe_timeslot : out  STD_LOGIC_VECTOR (9 downto 0);				
        num_payloadframe_timeslot : out  STD_LOGIC_VECTOR (9 downto 0);			
        num_timeslot : out  STD_LOGIC_VECTOR (9 downto 0);							
        we_RAM_timeslot_confiuration : out  STD_LOGIC;								
        din_RAM_timeslot_confiuration : out  STD_LOGIC_VECTOR (7 downto 0);
        flag_timeslot_adj : out  STD_LOGIC;											
        value_timeslot_adj : out  STD_LOGIC_VECTOR (9 downto 0);
        state_timeslot_adj : in  STD_LOGIC;
        master_or_slave           : out std_logic_vector(1 downto 0);
        length_mod                : out  std_logic_vector(15 downto 0);--配置帧单元bit数
        length_mod_offset         : out  std_logic_vector(15 downto 0);--配置帧单元bit数
        TDMA_SPMA_switch          : out  STD_LOGIC;	-- TDMA为0，SPMA为1
        ----  GPS使能   ----
        en_gps                                : out std_logic     ;
        ------精时间同步校正次数被读走标志 ------
         flag_times_timestamp_cor_read: out std_logic  ;
         
        ----    fft     ----
        irq1_valid   : out std_logic;
        fft_bram_reset : out std_logic;
        flag_fft_rdy : out std_logic;
        fft_data            : in std_logic_vector(15 downto 0);
        flag_fft_bram_addrb : out std_logic;
        
        reset_DDS_fft : out STD_LOGIC;
        phase_PINC_fft : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_0_fft : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_1_fft : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_2_fft : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_3_fft : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_4_fft : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_5_fft : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_6_fft : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_7_fft : out STD_LOGIC_VECTOR (31 downto 0);
        reg_fft_tap_select : out std_logic_vector(2 downto 0);
        num_valid          : out std_logic_vector(13 downto 0);
        addup_N            : out std_logic_vector(15 downto 0);
        fft_stop           : out std_logic;
        shift_bits_fft     : out std_logic_vector(4 downto 0);
        
        --- wideband ---
        flag_rdy_wideband : out std_logic;
        flag_xdma_test_rdy : out std_logic;
        xdma_stop : out std_logic;
         ---------定频模式任意频率相位字配置---------- 
        configurable_freq_hopping_phase_inc               : out   std_logic_vector(15 downto 0);     
        configurable_freq_hopping_phase_offset_0          : out   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_1          : out   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_2          : out   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_3          : out   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_4          : out   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_5          : out   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_6          : out   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_7          : out   std_logic_vector(15 downto 0);
        ----    PCIe TX (tx_top) PS 配置    ----
        tx_rstn_ps       : out STD_LOGIC;
        ram_en_ps        : out STD_LOGIC;
        bpsk_en_ps       : out STD_LOGIC;
        qpsk_en_ps       : out STD_LOGIC;
        rate_sel_ps      : out STD_LOGIC;
        dds_rstn_ps      : out STD_LOGIC;
        dds_pinc_bpsk_ps : out STD_LOGIC_VECTOR(31 downto 0);
        dds_pinc_qpsk_ps : out STD_LOGIC_VECTOR(31 downto 0);
        dds_poff_bpsk_ps : out STD_LOGIC_VECTOR(255 downto 0);
        dds_poff_qpsk_ps : out STD_LOGIC_VECTOR(255 downto 0);
        atten_bpsk_ps : out STD_LOGIC_VECTOR(15 downto 0);
        atten_qpsk_ps : out STD_LOGIC_VECTOR(15 downto 0);
        ram_w_en_bpsk_ps    : out STD_LOGIC;
        ram_w_addr_bpsk_ps  : out STD_LOGIC_VECTOR(17 downto 0);
        ram_w_data_bpsk_ps  : out STD_LOGIC_VECTOR(15 downto 0);
        ram_w_en_qpsk_ps    : out STD_LOGIC;
        ram_w_addr_qpsk_ps  : out STD_LOGIC_VECTOR(14 downto 0);
        ram_w_data_qpsk_ps  : out STD_LOGIC_VECTOR(15 downto 0);
        bpsk_sym_num_ps     : out STD_LOGIC_VECTOR(22 downto 0);
        bpsk_single_shot_ps : out STD_LOGIC
  );
end component;

signal pl_mod : std_logic;
signal board_mod : std_logic_vector(1 downto 0);
signal wave_mod : std_logic;
signal data_en : std_logic;
signal doppler_freq : std_logic_vector(15 downto 0);
signal doppler_freq_init0 : std_logic_vector(15 downto 0);
signal doppler_freq_init1 : std_logic_vector(15 downto 0);
signal doppler_freq_init2 : std_logic_vector(15 downto 0);
signal doppler_freq_init3 : std_logic_vector(15 downto 0);
signal doppler_freq_init4 : std_logic_vector(15 downto 0);
signal doppler_freq_init5 : std_logic_vector(15 downto 0);
signal doppler_freq_init6 : std_logic_vector(15 downto 0);
signal doppler_freq_init7 : std_logic_vector(15 downto 0);
signal initial_complete_state : std_logic;
 ---------定频模式任意频率相位字配置---------- 
 signal   configurable_freq_hopping_phase_inc               :   std_logic_vector(15 downto 0);     
 signal   configurable_freq_hopping_phase_offset_0          :   std_logic_vector(15 downto 0);
 signal   configurable_freq_hopping_phase_offset_1          :   std_logic_vector(15 downto 0);
 signal   configurable_freq_hopping_phase_offset_2          :   std_logic_vector(15 downto 0);
 signal   configurable_freq_hopping_phase_offset_3          :   std_logic_vector(15 downto 0);
 signal   configurable_freq_hopping_phase_offset_4          :   std_logic_vector(15 downto 0);
 signal   configurable_freq_hopping_phase_offset_5          :   std_logic_vector(15 downto 0);
 signal   configurable_freq_hopping_phase_offset_6          :   std_logic_vector(15 downto 0);
 signal   configurable_freq_hopping_phase_offset_7          :   std_logic_vector(15 downto 0);

----   dds 相位赋值 (100M DA输出)  ----
signal  s_axis_phase_inc       :  std_logic_vector(15 downto 0);     
signal  s_axis_phase_offset_0  :  std_logic_vector(15 downto 0);
signal  s_axis_phase_offset_1  :  std_logic_vector(15 downto 0);
signal  s_axis_phase_offset_2  :  std_logic_vector(15 downto 0);
signal  s_axis_phase_offset_3  :  std_logic_vector(15 downto 0);
signal  s_axis_phase_offset_4  :  std_logic_vector(15 downto 0);
signal  s_axis_phase_offset_5  :  std_logic_vector(15 downto 0);
signal  s_axis_phase_offset_6  :  std_logic_vector(15 downto 0);
signal  s_axis_phase_offset_7  :  std_logic_vector(15 downto 0);
signal  flag_lock_reg_PS_read_tx :  std_logic;
signal  flag_lock_reg_PS_read_rx :  std_logic;
signal EN_time_hopping :  std_logic_vector(3 downto 0);
----  定频模式切换与选择   ----
signal  flag_freq_hopping_control :  std_logic;
signal  freq_hopping_select :  std_logic_vector(3 downto 0);
signal  flag_times_timestamp_cor_read : std_logic;
signal  flag_xdma_test_rdy : std_logic;
signal  xdma_stop : std_logic;
component tx_module is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
--              clk_DAC_500M : in  STD_LOGIC;
--			  clk_DAC_250M : in  STD_LOGIC;
--			  clk_DAC_125M : in  STD_LOGIC;
--			  reset_DAC_interface : in std_logic;
			  ----	PN	----
			  reg_initial : in  STD_LOGIC; 
			  ram_PN_sync_we : in  STD_LOGIC;
			  ram_PN_sync_din : in  STD_LOGIC_VECTOR (15 downto 0);
			  ram_PN_PAn_we : in  STD_LOGIC;
			  ram_PN_PAn_din : in  STD_LOGIC_VECTOR (15 downto 0);
			  ram_PN_scramble_we : in  STD_LOGIC;
			  ram_PN_scramble_din : in  STD_LOGIC_VECTOR (15 downto 0);
			  ram_PN_interleave_we : in  STD_LOGIC;
			  ram_PN_interleave_din : in  STD_LOGIC_VECTOR (15 downto 0);
			  ----	tx	----
			  wave_mod : in STD_LOGIC;
			  data_en : in STD_LOGIC;
			  reg_tx_mode : in  STD_LOGIC_VECTOR (7 downto 0);
			  reg_tx_mode_para : in  STD_LOGIC_VECTOR (7 downto 0); 	
			  flag_start_rx : in  STD_LOGIC;
			  flag_start_tx_ila : out  STD_LOGIC;
			  ram_tx_interface_buffer_we : in  STD_LOGIC;
			  ram_tx_interface_buffer_din : in  STD_LOGIC_VECTOR (15 downto 0);
			  ram_tx_interface_buffer_din_type : in  STD_LOGIC_VECTOR (1 downto 0);
			  ram_tx_interface_buffer_we_1 : in  STD_LOGIC;
			  ram_tx_interface_buffer_din_1 : in  STD_LOGIC_VECTOR (15 downto 0);
			  ram_tx_interface_buffer_din_type_1 : in  STD_LOGIC_VECTOR (1 downto 0);
			  ram_tx_interface_buffer_we_2 : in  STD_LOGIC;
			  ram_tx_interface_buffer_din_2 : in  STD_LOGIC_VECTOR (15 downto 0);
			  ram_tx_interface_buffer_din_type_2 : in  STD_LOGIC_VECTOR (1 downto 0);			  
			  
			  reg_tx_interface_buffer_num_0 : out  STD_LOGIC_VECTOR (11 downto 0);
			  reg_tx_interface_buffer_num_1 : out  STD_LOGIC_VECTOR (11 downto 0);
			  reg_tx_interface_buffer_num_2 : out  STD_LOGIC_VECTOR (11 downto 0);
			  rate_mode : in std_logic_vector(1 downto 0);
              packet_time_interval : in std_logic_vector(31 downto 0);
			  pulse_framer_length : in std_logic_vector(15 downto 0);
			  ----   频点择优模式   ----
			  dds_clr : in  STD_LOGIC;
			  dds_freq_para_local : in  dds_para_array_type(15 downto 0);
			  ----	output	----
			  RX_SW_R0  : out  STD_LOGIC;
              RX_SW_R1  : out  STD_LOGIC;
              RX_SW_R2  : out  STD_LOGIC;
              TX_SW_T   : out  STD_LOGIC;
			  TX_switch : out  STD_LOGIC;
			  PA_switch : out  STD_LOGIC;
			  LNA_switch : out  STD_LOGIC;
			  PA_switch_delay : out  STD_LOGIC;
			  dout_mod_I_0 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_Q_0 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_I_1 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_Q_1 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_I_2 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_Q_2 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_I_3 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_Q_3 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_I_4 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_Q_4 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_I_5 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_Q_5 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_I_6 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_Q_6 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_I_7 : out  STD_LOGIC_VECTOR(15 downto 0);
			  dout_mod_Q_7 : out  STD_LOGIC_VECTOR(15 downto 0);
			  ----------------移位参数----------------------------------
			  shift_config_value : in std_logic_vector(3 downto 0);
--			  DAC_DBE_P : out  STD_LOGIC_VECTOR (13 downto 0);	
--			  DAC_DBE_N : out  STD_LOGIC_VECTOR (13 downto 0);			  
--		      DAC_DBO_P : out  STD_LOGIC_VECTOR (13 downto 0);	
--			  DAC_DBO_N : out  STD_LOGIC_VECTOR (13 downto 0);
--			  DAC_DCIP : out  STD_LOGIC;
--			  DAC_DCIN : out  STD_LOGIC;
			  
			  ----  发射天线选择参数  ----
			  Antenna_switch_tx : out  STD_LOGIC_VECTOR (1 downto 0);
			  ----  时间同步所需信号  ----
			  flag_one_packet_tx : out std_logic;
			  ----  时间同步标志  ----
              reg_tx_timesync_type : out std_logic;
              ----	多普勒相位	----
			  doppler_freq : in STD_LOGIC_VECTOR (15 downto 0);
			  doppler_freq_init0 :in std_logic_vector(15 downto 0);
              doppler_freq_init1 :in std_logic_vector(15 downto 0);
              doppler_freq_init2 :in std_logic_vector(15 downto 0);
              doppler_freq_init3 :in std_logic_vector(15 downto 0);
              doppler_freq_init4 :in std_logic_vector(15 downto 0);
              doppler_freq_init5 :in std_logic_vector(15 downto 0);
              doppler_freq_init6 :in std_logic_vector(15 downto 0);
              doppler_freq_init7 :in std_logic_vector(15 downto 0);
              ----   用CDMA读取写入数据  ----
              bram_addr_a_0 : in STD_LOGIC_VECTOR ( 12 downto 0 );
              bram_clk_a_0 : in STD_LOGIC;
              bram_en_a_0 : in STD_LOGIC;
              bram_we_a_0 : in STD_LOGIC_VECTOR ( 3 downto 0 );
              bram_wrdata_a_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
              ----   切换turbo编码方式（1/3，1/6，1/10，1/20）  ----
              encode_type_tx : out  STD_LOGIC_VECTOR (1 downto 0);
              -- PS 读标志 ----          
			  flag_lock_reg_PS_read_tx : in std_logic;
			  
			  ----    TDMA时基   ----
		      flag_timebase_frame_start : in std_logic;
              flag_timebase_frame_head  : in std_logic;
              master_or_slave                           : in std_logic_vector(1 downto 0); 
			  ----  定频模式切换与选择   ----
              flag_freq_hopping_control  : in std_logic;
              freq_hopping_select        : in std_logic_vector(3 downto 0);
               ---------定频模式任意频率相位字配置---------- 
              configurable_freq_hopping_phase_inc               : in   std_logic_vector(15 downto 0);     
              configurable_freq_hopping_phase_offset_0          : in   std_logic_vector(15 downto 0);
              configurable_freq_hopping_phase_offset_1          : in   std_logic_vector(15 downto 0);
              configurable_freq_hopping_phase_offset_2          : in   std_logic_vector(15 downto 0);
              configurable_freq_hopping_phase_offset_3          : in   std_logic_vector(15 downto 0);
              configurable_freq_hopping_phase_offset_4          : in   std_logic_vector(15 downto 0);
              configurable_freq_hopping_phase_offset_5          : in   std_logic_vector(15 downto 0);
              configurable_freq_hopping_phase_offset_6          : in   std_logic_vector(15 downto 0);
              configurable_freq_hopping_phase_offset_7          : in   std_logic_vector(15 downto 0)
 
              
			  );
--			  DAC_SYNC_INP : out  STD_LOGIC;
--			  DAC_SYNC_INN : out  STD_LOGIC );
end component;

component rx_module is
	port( 
		reset : in  STD_LOGIC;
		clk : in  STD_LOGIC;
		----------- ADC　------------------------------
--		clk_ADC_128M : in STD_LOGIC;
--		data_valid : in  STD_LOGIC;
--		sample1 : in  STD_LOGIC_VECTOR (13 downto 0);
--		sample2 : in  STD_LOGIC_VECTOR (13 downto 0);
--		sample3 : in  STD_LOGIC_VECTOR (13 downto 0);
--		sample4 : in  STD_LOGIC_VECTOR (13 downto 0);
--		sample5 : in  STD_LOGIC_VECTOR (13 downto 0);
--		sample6 : in  STD_LOGIC_VECTOR (13 downto 0);
--		sample7 : in  STD_LOGIC_VECTOR (13 downto 0);
--		sample8 : in  STD_LOGIC_VECTOR (13 downto 0);

        din_rx_I_0 : in std_logic_vector(15 downto 0); 
        din_rx_Q_0 : in std_logic_vector(15 downto 0);  
        din_rx_I_1 : in std_logic_vector(15 downto 0); 
        din_rx_Q_1 : in std_logic_vector(15 downto 0); 
        din_rx_I_2 : in std_logic_vector(15 downto 0); 
        din_rx_Q_2 : in std_logic_vector(15 downto 0);  
        din_rx_I_3 : in std_logic_vector(15 downto 0); 
        din_rx_Q_3 : in std_logic_vector(15 downto 0); 
        din_rx_I_4 : in std_logic_vector(15 downto 0); 
        din_rx_Q_4 : in std_logic_vector(15 downto 0);  
        din_rx_I_5 : in std_logic_vector(15 downto 0); 
        din_rx_Q_5 : in std_logic_vector(15 downto 0); 
        din_rx_I_6 : in std_logic_vector(15 downto 0); 
        din_rx_Q_6 : in std_logic_vector(15 downto 0);  
        din_rx_I_7 : in std_logic_vector(15 downto 0); 
        din_rx_Q_7 : in std_logic_vector(15 downto 0); 
        pl_mod : in std_logic;

		arm_config_sync_head_array : in sync_bits_array_type(0 to 14);
		arm_config_sync_tail_array : in sync_bits_array_type(0 to 14);
		arm_config_matrix_pattern_freq_x1 : in  STD_LOGIC_VECTOR (47 downto 0);
		arm_config_matrix_pattern_freq_x2 : in  STD_LOGIC_VECTOR (47 downto 0);
		arm_config_matrix_pattern_freq_x3 : in  STD_LOGIC_VECTOR (47 downto 0);
		arm_config_matrix_pattern_freq_x4 : in  STD_LOGIC_VECTOR (47 downto 0);
		arm_config_addr_offset_x1 : in addr_offset_array_type(0 to 14);
		arm_config_addr_offset_x2 : in addr_offset_array_type(0 to 14);
		arm_config_addr_offset_x3 : in addr_offset_array_type(0 to 14);
		arm_config_addr_offset_x4 : in addr_offset_array_type(0 to 14);
		arm_config_PN_deinterleave_array : in PN_deinterleave_array_type(0 to 11);
		
		rate_mode : in  STD_LOGIC_VECTOR (1 downto 0);			----"00":2M; "01":250k
		filter_sel : in  STD_LOGIC;									----'0':CIC;'1':FIR
		flag_start_rx : in  STD_LOGIC;
		ram_PN_descramble_we : in  STD_LOGIC;
		ram_PN_descramble_din : in  STD_LOGIC_VECTOR (15 downto 0);		
		threshold_pulse_num : in  STD_LOGIC_VECTOR (4 downto 0);
		threshold_sync_xcorr : in  STD_LOGIC_VECTOR (15 downto 0);
		channel_busy_threshold : in std_logic_vector(15 downto 0);			---- 信道负载判决门限
		channel_load : out std_logic_vector(15 downto 0);					---- 表征信道负载
		PA_switch_local : in  STD_LOGIC;									---- 统计发射脉冲数
		channel_capure_threshold : in std_logic_vector(15 downto 0);		---- 24位捕获寄存器判决门限
		point_test_rx : in  STD_LOGIC_VECTOR (13 downto 0);
		rdy_rx : in  STD_LOGIC;
		
		agc_control_mode: in std_logic_vector(15 downto 0);
        agc_arm_ctrl_mode : in  STD_LOGIC_VECTOR (15 downto 0);				--- 0正常，1arm控
		agc_arm_ctrl_DVGA4 : in  STD_LOGIC_vector(5 downto 0);
		agc_arm_ctrl_12 : in  STD_LOGIC;
		flag_agc_arm_ctrl_DVGA4 : in  STD_LOGIC;			
		DVGA_ctrl_4 : out std_logic_vector(5 downto 0);
		THRESHOLD_WIDTH: in  STD_LOGIC_VECTOR (15 downto 0);
		THRESHOLD_INSIDE: in  STD_LOGIC_VECTOR (15 downto 0);
		THRESHOLD_CENTER: in  STD_LOGIC_VECTOR (15 downto 0);
		RESPONSE_TIME		: in  STD_LOGIC_VECTOR (15 downto 0);
		
--		agc_arm_ctrl_mode : in STD_LOGIC_VECTOR (15 downto 0);			--- 0正常，1arm控
		agc_arm_ctrl_DVGA1 : in  STD_LOGIC_vector(5 downto 0);
		agc_arm_ctrl_DVGA2 : in  STD_LOGIC_vector(5 downto 0);
--		agc_arm_ctrl_12 : in  STD_LOGIC;
		agc_arm_ctrl_DVGA3 : in  STD_LOGIC_vector(5 downto 0);
--		agc_arm_ctrl_DVGA4 : in  STD_LOGIC_vector(5 downto 0);
		agc_arm_ctrl_34 : in  STD_LOGIC;	
		-- DVGA_ctrl_1 : out  STD_LOGIC_VECTOR (5 downto 0);
		-- DVGA_ctrl_2 : out  STD_LOGIC_VECTOR (5 downto 0);
		-- DVGA_ctrl_3 : out  STD_LOGIC_VECTOR (5 downto 0);
--		DVGA_ctrl_4 : out  STD_LOGIC_VECTOR (5 downto 0);
		----   频点择优模式   ----
		dds_clr : in  STD_LOGIC;
		dds_freq_para_local : in  dds_para_array_type(15 downto 0);
		----	ARM读信号  ----
		read_ram_err_count			: in  STD_LOGIC;
		flag_rd_arm_onetime : in  STD_LOGIC;
		flag_rd_arm_onepacket : in  STD_LOGIC;
		flag_rd_arm_oneint : in  STD_LOGIC;
		int_rx_arm : out  STD_LOGIC;
		counter_switch : in std_logic;
		counter_2M:out std_logic_vector(15 downto 0);
		num_buffer_rx_arm_interface : out  STD_LOGIC_VECTOR (3 downto 0);
		dout_rx_arm_interface : out  STD_LOGIC_VECTOR (15 downto 0);
		rx_jiewei : in std_logic_vector(7 downto 0);
		----  时间同步所需信号  ----
        rdy_sync_acquisition_time                : out std_logic;
        sync_time_offest                         : out std_logic_vector(2 downto 0);
        wraddr_base_I_ram_demod_data_buffer_time : out std_logic_vector(1 downto 0);
        rdaddr_base_I_ram_demod_data_buffer_time : out std_logic_vector(1 downto 0);
        we_I_ram_demod_data_buffer_time          : out std_logic_vector(0 downto 0);
        ----   接收时间戳  ----
        rx_timestamp_in                          : in std_logic_vector(47 downto 0);
        ---- 接受时间戳时标计数器值------
        rx_timestamp_cor_out                     : in std_logic_vector(47 downto 0);
        -----  捕获时 时标计数器周期新旧值标志-----
        flag_rx_timestamp                      : in std_logic;
        crc_result  :  out std_logic;
        ----   将数据存入bram并用CDMA读取  ----
        bram_addr_a_0 : in STD_LOGIC_VECTOR ( 12 downto 0 );
        bram_clk_a_0 : in STD_LOGIC;
        bram_rst_a_0 : in STD_LOGIC;
        bram_en_a_0 : in STD_LOGIC;
        bram_we_a_0 : in STD_LOGIC_VECTOR ( 3 downto 0 );
        bram_rddata_a_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
        ----   切换turbo编码方式（1/3，1/6，1/10，1/20）  ----
        encode_type_rx : in  STD_LOGIC_VECTOR (1 downto 0);
        -- PS 读标志 ----          
		flag_lock_reg_PS_read_rx : in std_logic;
		EN_time_hopping                      : in   std_logic_vector(3 downto 0);
		-------TDMA------------------
		flag_CRC_timebase_adj                     : out  std_logic_vector(1 downto 0);
		flag_brd_acquisition                      : out std_logic;
		rdy_sync_acquisition                      : out std_logic;
		master_or_slave                           : in std_logic_vector(1 downto 0);
        ----  定频模式切换与选择   ----
        flag_freq_hopping_control  : in std_logic;
        freq_hopping_select        : in std_logic_vector(3 downto 0);
         ---------定频模式任意频率相位字配置---------- 
        configurable_freq_hopping_phase_inc               : in   std_logic_vector(15 downto 0);     
        configurable_freq_hopping_phase_offset_0          : in   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_1          : in   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_2          : in   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_3          : in   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_4          : in   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_5          : in   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_6          : in   std_logic_vector(15 downto 0);
        configurable_freq_hopping_phase_offset_7          : in   std_logic_vector(15 downto 0)  
	);
end component;


signal irq_fft_valid    :   std_logic;
signal flag_fft_bram_addrb   :   std_logic;
signal fft_bram_rddata  :   std_logic_vector(15 downto 0);
signal irq_fft          :   std_logic;
signal irq_wideband     :   std_logic_vector(1 downto 0);
signal flag_fft_rdy     :   std_logic;
signal flag_rdy_wideband     :   std_logic;
   


component timestamp_module is
port ( 
    clk1                                      : in std_logic;
     clk2                                      : in std_logic;
    reset                                    : in std_logic;
	reset_time                               : in std_logic;
    ----  接收  ----
    rdy_sync_acquisition_time                : in std_logic;
    sync_time_offest                         : in std_logic_vector(2 downto 0);
    wraddr_base_I_ram_demod_data_buffer_time : in std_logic_vector(1 downto 0);
    rdaddr_base_I_ram_demod_data_buffer_time : in std_logic_vector(1 downto 0);
    we_I_ram_demod_data_buffer_time          : in std_logic_vector(0 downto 0);
    ---- 接收时间戳  ----
    rx_timestamp_in                          : out std_logic_vector(47 downto 0);
    ---- 接受时间戳时标计数器值------
    rx_timestamp_cor_out                     : out std_logic_vector(47 downto 0);
    -----  捕获时 时标计数器周期新旧值标志-----
    flag_rx_timestamp                      : out std_logic;
    ----  发射  ----
    flag_one_packet_tx                       : in std_logic;
    reg_tx_timesync_type                     : in std_logic;
    ----  发射时间戳  ----
    send_timestamp_2                         : out std_logic_vector(15 downto 0);
    send_timestamp_1                         : out std_logic_vector(15 downto 0);
    send_timestamp_0                         : out std_logic_vector(15 downto 0);
    ----  发射时间戳时标计数器值  ----
    send_timestamp_cor_2                     : out std_logic_vector(15 downto 0);
    send_timestamp_cor_1                     : out std_logic_vector(15 downto 0);
    send_timestamp_cor_0                     : out std_logic_vector(15 downto 0);
    ----  发射时，时标计数器周期值新旧标志----
    flag_send_timestamp_cor                  : out std_logic;
   
	----  时间同步sync  ----
	TEST0_EXT_ZYNQ                           : out std_logic;
    ----  发射时间更新标准 ----
    flag_tx_time_renew                       : out std_logic;
    ----  发射时间窗口更新标准  ----
    flag_tx_timestamp_read                   : in std_logic;
    ----    time offset    ----
    offset_time_2                            : in std_logic_vector(15 downto 0);
    offset_time_1                            : in std_logic_vector(15 downto 0);
    offset_time_0                            : in std_logic_vector(15 downto 0);
    flag_offset_time_adjust                  : in std_logic;
	----   物理层时间    ----
	reg_phy_time                             : out std_logic_vector(47 downto 0);
	ps_oen                                   : in    std_logic;
    ps_cen                                   : in    std_logic;
    
    ----------- 精同步 -----------
    EN_timestamp_cor : in  STD_LOGIC;									--时标计数器周期校正使能，在时间同步过程中，禁止时标周期校正
    flag_timestamp_cor : in  STD_LOGIC;							--时标周期校正值标志
    value_timestamp_cor : in  STD_LOGIC_VECTOR (47 downto 0);		--时标周期校正值，即调整1个采样点（8ns）所需的计数值
    polarity_cor : in  STD_LOGIC;	                        --时标周期校正值的正负
    times_timestamp_cor : out  STD_LOGIC_VECTOR (15 downto 0);        --时间同步周期内，周期校正次数
    
	----    标记    ----
	led_sync                                 : out std_logic;
	------精时间同步校正次数被读走标志 ------
    flag_times_timestamp_cor_read       : in std_logic  ;
	time_pulse_sync                                 : out std_logic ; ----精秒脉冲
	time_pulse_sync_cu                              : out std_logic  ----粗秒脉冲
);
end component;



signal EN_timebase : STD_LOGIC;
signal num_frame_timeslot :  STD_LOGIC_VECTOR (9 downto 0);					
signal num_preframe_timeslot :   STD_LOGIC_VECTOR (9 downto 0);				
signal num_payloadframe_timeslot :   STD_LOGIC_VECTOR (9 downto 0);			
signal num_timeslot :   STD_LOGIC_VECTOR (9 downto 0);							
signal we_RAM_timeslot_confiuration :   STD_LOGIC;								
signal din_RAM_timeslot_confiuration :   STD_LOGIC_VECTOR (7 downto 0);	
signal flag_timeslot_adj  :   STD_LOGIC;											
signal value_timeslot_adj :   STD_LOGIC_VECTOR (9 downto 0);	
signal state_timeslot_adj :   STD_LOGIC;
signal flag_brd_acquisition :  std_logic;
signal flag_CRC_timebase_adj                     : std_logic_vector(1 downto 0);
signal speed_control: STD_LOGIC_VECTOR (1 downto 0);
signal flag_timebase_frame_start : std_logic; 
signal flag_timebase_frame_head : std_logic; 
signal rdy_sync_acquisition                      : std_logic;
signal master_or_slave : STD_LOGIC_VECTOR (1 downto 0);
signal length_mod      :   std_logic_vector(15 downto 0);--配置帧单元bit数
signal length_mod_offset         :  std_logic_vector(15 downto 0);
signal TDMA_SPMA_switch          :  STD_LOGIC;	-- TDMA为0，SPMA为1



component timebase_control is
    port(
    reset : in  STD_LOGIC;                                             
    clk : in  STD_LOGIC;                                               
    EN_timebase : in  STD_LOGIC;												
    ----	配置参数	----                                                     
    num_frame_timeslot : in  STD_LOGIC_VECTOR (9 downto 0);					
    num_preframe_timeslot : in  STD_LOGIC_VECTOR (9 downto 0);				
    num_payloadframe_timeslot : in  STD_LOGIC_VECTOR (9 downto 0);			
    num_timeslot : in  STD_LOGIC_VECTOR (9 downto 0);							
    we_RAM_timeslot_confiuration : in  STD_LOGIC;								
    din_RAM_timeslot_confiuration : in  STD_LOGIC_VECTOR (7 downto 0);	
    ----	时隙号修正	----	                                                   
    flag_timeslot_adj : in  STD_LOGIC;											
    value_timeslot_adj : in  STD_LOGIC_VECTOR (9 downto 0);					
    state_timeslot_adj : out  STD_LOGIC;										
    ----	时基修正	----	                                                    
    flag_acquisition_timebase_adj : in  STD_LOGIC;								
    flag_CRC_timebase_adj : in  STD_LOGIC_VECTOR (1 downto 0);		
    
    flag_timeslot_switch                      : out std_logic;		
    length_mod                                : in  std_logic_vector(15 downto 0);--配置帧单元bit数
    length_mod_offset                         : in  std_logic_vector(15 downto 0);--配置帧单元bit数	
    TDMA_SPMA_switch          : in STD_LOGIC;	-- TDMA为0，SPMA为1							
    ----	时标信号输出	----	                                                  
    													
    flag_frame_tx : out  STD_LOGIC;											
    flag_frame_head_tx : out  STD_LOGIC;
    rx_timestamp_frame_num                    : out  std_logic_vector(15 downto 0);
    rdy_sync_acquisition                      : in std_logic;
    speed_control: in STD_LOGIC_VECTOR (1 downto 0)                                                                      
                                 
);
end component;



signal rx_time                           : std_logic_vector(65 downto 0);
signal rx_timestamp_frame_num : std_logic_vector(15 downto 0);

COMPONENT vio_1
  PORT (
    clk : IN STD_LOGIC;
    probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out1 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out2 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out3 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0) 
  );
END COMPONENT;
signal CLK_50M : STD_LOGIC;

----    时间同步相关    ----
signal flag_one_packet_tx : std_logic;
signal reg_tx_timesync_type : std_logic;

----    AD9520相关    ----
signal flag_AD9520_config             : std_logic;
signal reg_AD9520_config_wrdata       : std_logic_vector(23 downto 0);
signal reg_AD9520_config_rddata 	: std_logic;
signal reg_SPI_AD9520_config_state    : std_logic_vector(15 downto 0);

----    AD9680相关    ----
signal flag_AD9680_config             : std_logic;
signal reg_AD9680_config_wrdata       : std_logic_vector(15 downto 0);
signal reg_AD9680_config_rddata       : std_logic_vector(15 downto 0);
signal reg_SPI_AD9680_config_state    : std_logic_vector(15 downto 0);

----    AD9680_2相关    ----
signal flag_AD9680_2_config             : std_logic;
signal reg_AD9680_2_config_wrdata       : std_logic_vector(15 downto 0);
signal reg_AD9680_2_config_rddata       : std_logic_vector(15 downto 0);
signal reg_SPI_AD9680_2_config_state    : std_logic_vector(15 downto 0);

----    AD9739相关    ----
signal flag_AD9739_config             : std_logic;
signal reg_AD9739_config_wrdata       : std_logic_vector(15 downto 0);
signal reg_AD9739_config_rddata       : std_logic_vector(15 downto 0);
signal reg_SPI_AD9739_config_state     : std_logic_vector(15 downto 0);

----    AD5XXX相关    ----   
signal flag_AD5XXX_config 	: STD_LOGIC;
signal reg_AD5XXX_wrdata 	: STD_LOGIC_VECTOR (15 downto 0);
signal reg_AD5XXX_mode      :  std_logic_vector(3 downto 0);
signal reg_LDAC        : STD_LOGIC;

----k7 参数
signal flag_agc_arm_ctrl_mode : std_logic;
signal sync_bit_pre_rx_s :  std_logic_vector(23 downto 0);
signal flag_wr_sync_bit_pre :  std_logic;
signal sync_bit_post_rx_s : std_logic_VECTOR(23 downto 0);
signal flag_wr_sync_bit_post : std_logic;
signal flag_pattern_freq_rx_x1 : std_logic;----k7
signal flag_pattern_freq_rx_x2 : std_logic;
signal flag_pattern_freq_rx_x3 : std_logic;
signal flag_pattern_freq_rx_x4 : std_logic;
signal time_hopping_rx_x1_s : std_logic_vector(13 downto 0);----k7
signal flag_time_hoppong_rx_x1 : std_logic;
signal time_hopping_rx_x2_s : std_logic_vector(13 downto 0);
signal flag_time_hoppong_rx_x2 : std_logic;
signal time_hopping_rx_x3_s : std_logic_vector(13 downto 0);
signal flag_time_hoppong_rx_x3 : std_logic;
signal time_hopping_rx_x4_s : std_logic_vector(13 downto 0);
signal flag_time_hoppong_rx_x4 : std_logic;
signal PN_deinterleave_s : std_logic_vector(15 downto 0);--k7
signal flag_PN_deinterleave : std_logic;
signal flag_arm_config_rx_rate_mode_sel : std_logic;

signal flag_ram_PN_descramble_din : std_logic;
signal flag_threshold_pulse_num : std_logic;
signal flag_threshold_sync_xcorr : std_logic;
signal flag_rdy_rx : std_logic;
signal flag_flag_start_rx :  std_logic;
signal flag_point_test_rx : std_logic;
signal flag_channel_busy_threshold : std_logic;
signal flag_channel_capure_threshold : std_logic;
signal flag_Antenna_switch_local : std_logic;
signal jesd_reset_AD2 : std_logic;
signal flag_jesd_reset_AD2 : std_logic;

----k7 jesd
signal jesd_ila           :  std_logic_vector(7 downto 0);
signal flag_jesd_ila      :  std_logic;
signal jesd_src           :  std_logic_vector(7 downto 0);
signal flag_jesd_src      :  std_logic;
signal jesd_mod           :  std_logic_vector(7 downto 0);
signal flag_jesd_mod      :  std_logic;
signal jesd_f             :  std_logic_vector(7 downto 0);
signal flag_jesd_f        :  std_logic;
signal jesd_k             :  std_logic_vector(7 downto 0);
signal flag_jesd_k        :  std_logic;
signal jesd_lanes         :  std_logic_vector(7 downto 0);
signal flag_jesd_lanes    :  std_logic;
signal jesd_subclass      :  std_logic_vector(7 downto 0);
signal flag_jesd_subclass :  std_logic;
signal jesd_delay         :  std_logic_vector(7 downto 0);
signal flag_jesd_delay    :  std_logic;
signal jesd_erro          :  std_logic_vector(7 downto 0);
signal flag_jesd_erro     :  std_logic;
signal jesd_erroo         :  std_logic_vector(15 downto 0);
signal flag_jesd_erroo    :  std_logic;

signal reset_time         :  std_logic;

signal LNA_switch_hand_1 : std_logic;
signal LNA_switch_hand_2 : std_logic;
signal PA_switch_hand : std_logic;

----    时间同步相关    ----
signal send_timestamp_2 : std_logic_vector(15 downto 0);
signal send_timestamp_1 : std_logic_vector(15 downto 0);
signal send_timestamp_0 : std_logic_vector(15 downto 0);
signal send_timestamp_cor_2     : std_logic_vector(15 downto 0);
signal send_timestamp_cor_1     : std_logic_vector(15 downto 0);
signal send_timestamp_cor_0     : std_logic_vector(15 downto 0);
signal flag_rx_timestamp      : std_logic;
signal flag_send_timestamp_cor      : std_logic;

signal flag_tx_time_renew     : std_logic;
signal flag_tx_timestamp_read : std_logic;

signal reg_phy_time     : std_logic_vector(47 downto 0);


signal read_ram_err_count : STD_LOGIC;
signal Antenna_switch_local : STD_LOGIC_VECTOR (15 downto 0);
signal Antenna_switch_tx : STD_LOGIC_VECTOR (1 downto 0);
signal clk_125M : std_logic;
signal clk_DAC_500M :  std_logic;
signal clk_DAC_250M : std_logic;
signal clk_DAC_125M : std_logic;

signal reset_n : std_logic := '1';

signal resetn_PLL : std_logic;


signal counter_switch : std_logic;
signal counter_2M: std_logic_vector(15 downto 0);
signal counter_64k: std_logic_vector(15 downto 0);
signal reset_DAC_interface : std_logic;

signal reg_initial_reset : std_logic_vector(2 downto 0); 
signal reg_tx_mode : std_logic_vector(7 downto 0); 
signal reg_tx_mode_para : std_logic_vector(7 downto 0);
signal ram_PN_sync_we : std_logic;
signal ram_PN_sync_din : std_logic_vector(15 downto 0);
signal ram_PN_PAn_we : std_logic;
signal ram_PN_PAn_din : std_logic_vector(15 downto 0);
signal ram_PN_scramble_we : std_logic;
signal ram_PN_scramble_din : std_logic_vector(15 downto 0);
signal ram_PN_interleave_we : std_logic;
signal ram_PN_interleave_din : std_logic_vector(15 downto 0);
signal ram_tx_interface_buffer_we : std_logic;
signal ram_tx_interface_buffer_din : std_logic_vector(15 downto 0);
signal ram_tx_interface_buffer_din_type : std_logic_vector(1 downto 0);
signal ram_tx_interface_buffer_we_1 :   STD_LOGIC;
signal ram_tx_interface_buffer_din_1 :   STD_LOGIC_VECTOR (15 downto 0);
signal ram_tx_interface_buffer_din_type_1 :   STD_LOGIC_VECTOR (1 downto 0);
signal ram_tx_interface_buffer_we_2 :   STD_LOGIC;
signal ram_tx_interface_buffer_din_2 :   STD_LOGIC_VECTOR (15 downto 0);
signal ram_tx_interface_buffer_din_type_2 :   STD_LOGIC_VECTOR (1 downto 0);
signal reg_tx_interface_buffer_num_0 : std_logic_vector(11 downto 0);
signal reg_tx_interface_buffer_num_1 : std_logic_vector(11 downto 0);
signal reg_tx_interface_buffer_num_2 : std_logic_vector(11 downto 0);
signal flag_monitor_cancel : std_logic;
signal reg_state : std_logic_vector(15 downto 0);
--signal agc_arm_ctrl_mode : STD_LOGIC_VECTOR (15 downto 0);			--- 0正常，1arm控
signal agc_arm_ctrl_DVGA1 : STD_LOGIC_vector(5 downto 0);
signal agc_arm_ctrl_DVGA2 : STD_LOGIC_vector(5 downto 0);
--signal agc_arm_ctrl_12 : STD_LOGIC;
signal agc_arm_ctrl_DVGA3 : STD_LOGIC_vector(5 downto 0);
--signal agc_arm_ctrl_DVGA4 : STD_LOGIC_vector(5 downto 0);
signal agc_arm_ctrl_34 : STD_LOGIC;	
signal DVGA_ctrl_1 : std_logic_vector(5 downto 0);		----数控衰减器1
signal DVGA_ctrl_2 : std_logic_vector(5 downto 0);		----数控衰减器2
signal DVGA_ctrl_3 : std_logic_vector(5 downto 0);		----数控衰减器3
--signal DVGA_ctrl_4 : std_logic_vector(5 downto 0);		----数控衰减器4
signal DVGA_ctrl_1_local : std_logic_vector(5 downto 0);		----数控衰减器1
signal DVGA_ctrl_2_local : std_logic_vector(5 downto 0);		----数控衰减器2
signal DVGA_ctrl_3_local : std_logic_vector(5 downto 0);		----数控衰减器3
signal DVGA_ctrl_4_local : std_logic_vector(5 downto 0);		----数控衰减器4
signal TX_POWER : std_logic_vector(3 downto 0);
signal reg_monitor : std_logic_vector(15 downto 0);
signal threshold_pulse_num : std_logic_vector(4 downto 0);
signal threshold_sync_xcorr : std_logic_vector(15 downto 0);
signal rdy_rx : std_logic;
signal flag_start_rx : std_logic;
signal flag_start_tx_ila : std_logic;
signal point_test_rx : std_logic_vector(13 downto 0);
signal arm_config_sync_head_array : sync_bits_array_type(0 to 14);
signal arm_config_sync_tail_array : sync_bits_array_type(0 to 14);
signal arm_config_matrix_pattern_freq_x1 : std_logic_vector (47 downto 0) := (others => '0');
signal arm_config_matrix_pattern_freq_x2 : std_logic_vector (47 downto 0) := (others => '0');
signal arm_config_matrix_pattern_freq_x3 : std_logic_vector (47 downto 0) := (others => '0');
signal arm_config_matrix_pattern_freq_x4 : std_logic_vector (47 downto 0) := (others => '0');
signal arm_config_addr_offset_x1 : addr_offset_array_type(0 to 14);
signal arm_config_addr_offset_x2 : addr_offset_array_type(0 to 14);
signal arm_config_addr_offset_x3 : addr_offset_array_type(0 to 14);
signal arm_config_addr_offset_x4 : addr_offset_array_type(0 to 14);
signal arm_config_PN_deinterleave_array : PN_deinterleave_array_type(0 to 11);
signal ram_PN_descramble_we : std_logic;
signal ram_PN_descramble_din : std_logic_vector(15 downto 0);
signal arm_config_rx_rate_mode : std_logic_vector(1 downto 0) := (others => '0');
signal arm_config_rx_filter_sel : std_logic;
signal arm_config_switch : std_logic_vector(2 downto 0);

signal RX_SW_R0     : std_logic ;
signal RX_SW_R1     : std_logic ;
signal RX_SW_R2     : std_logic ;
signal TX_SW_T      : std_logic ;
signal TX_switch_local : std_logic ;
signal PA_switch_local : std_logic ;
signal PA_switch_internal : std_logic := '0';
signal LNA_switch_local : std_logic ;
signal LNA_switch : std_logic := '1';
signal LNA_switch_Q : std_logic:= '0';
signal CLK0N_PLL:std_logic;
signal LNA_switch_1 : std_logic := '1';
signal LNA_switch_2 : std_logic:= '0';
signal count_RDY_SP : std_logic_VECTOR(15 downto 0);
SIGNAL ByteIsAligned : STD_LOGIC_VECTOR (7 downto 0);

signal crc_result : std_logic;
----    时间同步相关    ----
signal rdy_sync_acquisition_time                : std_logic;
signal sync_time_offest                         :  std_logic_vector(2 downto 0);
signal wraddr_base_I_ram_demod_data_buffer_time : std_logic_vector(1 downto 0);
signal rdaddr_base_I_ram_demod_data_buffer_time : std_logic_vector(1 downto 0);
signal we_I_ram_demod_data_buffer_time          : std_logic_vector(0 downto 0);
signal rx_timestamp_in                          : std_logic_vector(47 downto 0);
signal rx_timestamp_cor_out                          : std_logic_vector(47 downto 0);

----   PLL            ----
signal flag_RF_PLL_TxRx_configuration : std_logic;
signal flag_RF_PLL_CLK_configuration : std_logic;
signal data_RF_PLL_configuration : std_logic_vector(31 downto 0);
----    时间同步相关    ----
signal offset_time_2 : std_logic_vector(15 downto 0);
signal offset_time_1 : std_logic_vector(15 downto 0);
signal offset_time_0 : std_logic_vector(15 downto 0);
signal flag_offset_time_adjust : std_logic;

----    time offset    ----
signal offset_time_2_k7            : std_logic_vector(15 downto 0);
signal offset_time_1_k7            : std_logic_vector(15 downto 0);
signal offset_time_0_k7            : std_logic_vector(15 downto 0);
signal flag_offset_time_adjust_k7  : std_logic;  

signal jesd_reset						: std_logic;
signal jesd_reset_n					: std_logic;

signal flag_rd_arm_onepacket : std_logic; 
signal flag_rd_arm_oneint : std_logic;
signal flag_rd_arm_onetime : std_logic; 
signal dout_rx_arm_interface : STD_LOGIC_VECTOR (15 downto 0);
signal num_buffer_rx_arm_interface : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
----   频点择优模式   ----
signal dds_clr : STD_LOGIC;
signal dds_freq_para_local : dds_para_array_type(15 downto 0);
signal packet_time_interval : std_logic_vector(31 downto 0);
signal pulse_framer_length : std_logic_vector(15 downto 0);

signal channel_busy_threshold : std_logic_vector(15 downto 0);			---- 信道负载判决门限
signal channel_load : std_logic_vector(15 downto 0);					---- 表征信道负载

signal channel_capure_threshold : std_logic_vector(15 downto 0);		---- 24位捕获寄存器判决门限

signal contrl_8506 : STD_LOGIC_VECTOR (15 downto 0);

signal ADC_DCLK_RSTP:std_logic;
signal ADC_DCLK_RSTN:std_logic;
signal DAC_SYNC_INP:std_logic;
signal DAC_SYNC_INN:std_logic;
signal DAC_SYNC_OUTP:std_logic;
signal DAC_SYNC_OUTN:std_logic;
SIGNAL PLL_REF_SEL:STD_LOGIC;


----    K7 读取寄存器标志    ----
signal falg_rx_resp  :   std_logic;
signal rx_resp_data  :   STD_LOGIC_vector(15 downto 0);
signal falg_rd_respdata_complete  :  std_logic;

SIGNAL ps_ReSync : STD_LOGIC;
SIGNAL data_valid : STD_LOGIC;

signal flag_rd_srio_onepacket : std_logic;
signal flag_rd_srio_onetime : std_logic;
signal flag_rd_srio_oneint : std_logic;
signal num_buffer_rx_srio_interface : std_logic_vector(3 downto 0);
signal dout_rx_srio_interface : std_logic_vector(15 downto 0);

signal srio_address :  STD_LOGIC_VECTOR ( 31 downto 0 );        
signal srio_cen :  STD_LOGIC;        
signal srio_dq_i :  STD_LOGIC_VECTOR ( 15 downto 0 );        
signal srio_dq_o :  STD_LOGIC_VECTOR ( 15 downto 0 );        
signal srio_oen :  STD_LOGIC;        
signal srio_wen :  STD_LOGIC;
signal flag_tx_nread :  STD_LOGIC;

signal clk_lock_out : std_logic;
signal falg_irq_end :std_logic;
signal falg_irq_end_k : std_logic;

signal MEASURED_TEMP_ZYNQ      : STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port

signal TEST0_EXT_ZYNQ : std_logic;
signal led_sync       : std_logic;

--signal int_rx_arm_ZYNQ : STD_LOGIC;
signal EN_timestamp_cor : std_logic;
signal flag_timestamp_cor : std_logic;
signal value_timestamp_cor : std_logic_vector (47 downto 0);
signal polarity_cor : std_logic;
signal times_timestamp_cor : std_logic_vector(15 downto 0);



signal		PA_switch :   STD_LOGIC;
signal		PA_switch_delay :   STD_LOGIC;
signal		PA_switch_delay_400ns :   STD_LOGIC;
constant    count_pa_delay  : integer := 51;
signal      sig_delay    : std_logic_vector(count_pa_delay-1 downto 0) := (others =>'0');
signal      T_R_TTL_switch :   STD_LOGIC;
signal		dout_mod_I_0 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		dout_mod_Q_0 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		dout_mod_I_1 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		dout_mod_Q_1 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		dout_mod_I_2 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		dout_mod_Q_2 :   STD_LOGIC_VECTOR(15 downto 0);        
signal		dout_mod_I_3 :   STD_LOGIC_VECTOR(15 downto 0);        
signal		dout_mod_Q_3 :   STD_LOGIC_VECTOR(15 downto 0);        
signal		dout_mod_I_4 :   STD_LOGIC_VECTOR(15 downto 0);        
signal		dout_mod_Q_4 :   STD_LOGIC_VECTOR(15 downto 0);        
signal		dout_mod_I_5 :   STD_LOGIC_VECTOR(15 downto 0);        
signal		dout_mod_Q_5 :   STD_LOGIC_VECTOR(15 downto 0);        
signal		dout_mod_I_6 :   STD_LOGIC_VECTOR(15 downto 0);        
signal		dout_mod_Q_6 :   STD_LOGIC_VECTOR(15 downto 0);        
signal		dout_mod_I_7 :   STD_LOGIC_VECTOR(15 downto 0);        
signal		dout_mod_Q_7 :   STD_LOGIC_VECTOR(15 downto 0);        

signal		din_rx_I_0 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		din_rx_Q_0 :   STD_LOGIC_VECTOR(15 downto 0);     
signal		din_rx_I_1 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		din_rx_Q_1 :   STD_LOGIC_VECTOR(15 downto 0);   
signal		din_rx_I_2 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		din_rx_Q_2 :   STD_LOGIC_VECTOR(15 downto 0);   
signal		din_rx_I_3 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		din_rx_Q_3 :   STD_LOGIC_VECTOR(15 downto 0);   
signal		din_rx_I_4 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		din_rx_Q_4 :   STD_LOGIC_VECTOR(15 downto 0);   
signal		din_rx_I_5 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		din_rx_Q_5 :   STD_LOGIC_VECTOR(15 downto 0);   
signal		din_rx_I_6 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		din_rx_Q_6 :   STD_LOGIC_VECTOR(15 downto 0);   
signal		din_rx_I_7 :   STD_LOGIC_VECTOR(15 downto 0);                 
signal		din_rx_Q_7 :   STD_LOGIC_VECTOR(15 downto 0); 
signal    PA_switch_out :  std_logic;
signal    int_rx_arm_ZYNQ : STD_LOGIC;


signal clk_locked_0 :STD_LOGIC;
signal mmcm_locked :STD_LOGIC;
signal pl_rsten : STD_LOGIC;
signal clk_128M :STD_LOGIC;
signal clk_128M_0 :STD_LOGIC;
signal clk_512M :STD_LOGIC;

signal fft_rsten : STD_LOGIC;



--------射频相关--------
signal work_mod : std_logic_vector(1 downto 0);
signal PA_switch_ps :  std_logic;
signal LNA_switch_ps :  std_logic;
signal T_R_TTL_ps :  std_logic;
signal SW_R0_in_ps   :  std_logic;
signal SW_R1_in_ps   :  std_logic;
signal SW_R2_in_ps   :  std_logic;
signal SW_T_in_ps    :  std_logic;
signal SEL0_TX_in_ps :  std_logic;
signal SEL1_TX_in_ps :  std_logic;

signal R0_C0_ps   :     std_logic;
signal R0_C1_ps   :     std_logic;
signal R0_C2_ps   :     std_logic;
signal R0_C3_ps   :     std_logic;
signal R0_C4_ps   :     std_logic;
signal R0_C5_ps   :     std_logic;
signal R1_C0_ps   :     std_logic;
signal R1_C1_ps   :     std_logic;
signal R1_C2_ps   :     std_logic;
signal R1_C3_ps   :     std_logic;
signal R1_C4_ps   :     std_logic;
signal R1_C5_ps   :     std_logic;
signal R2_C0_ps   :     std_logic;
signal R2_C1_ps   :     std_logic;
signal R2_C2_ps   :     std_logic;
signal R2_C3_ps   :     std_logic;
signal R2_C4_ps   :     std_logic;
signal R2_C5_ps   :     std_logic;
signal R2_C0_switch   :     std_logic;
signal R2_C1_switch   :     std_logic;
signal R2_C2_switch   :     std_logic;
signal R2_C3_switch   :     std_logic;
signal R2_C4_switch   :     std_logic;
signal R2_C5_switch   :     std_logic;

---------------------agc相关-----------------------------
signal agc_control_mode  : STD_LOGIC_vector(15 downto 0);-----  功率检测模式 
signal agc_arm_ctrl_mode :   STD_LOGIC_VECTOR (15 downto 0);				--- 0正常，1arm控
signal agc_arm_ctrl_DVGA4 :  STD_LOGIC_vector(5 downto 0);
signal agc_arm_ctrl_12 :   STD_LOGIC;
signal flag_agc_arm_ctrl_DVGA4 :   STD_LOGIC;              
signal DVGA_ctrl_4 :  std_logic_vector(5 downto 0);
signal THRESHOLD_WIDTH:   STD_LOGIC_VECTOR (15 downto 0); 
signal THRESHOLD_INSIDE:   STD_LOGIC_VECTOR (15 downto 0);
signal THRESHOLD_CENTER:   STD_LOGIC_VECTOR (15 downto 0);
signal RESPONSE_TIME		:   STD_LOGIC_VECTOR (15 downto 0); 
----------------------------数字衰减----------------
signal shift_config_value :  std_logic_vector(3 downto 0);

----   切换turbo编码方式（1/3，1/6，1/10，1/20）  ----
signal encode_type :  STD_LOGIC_VECTOR (1 downto 0);


signal iq_switch : std_logic;

------------------截位----------------------
signal SHIFT_BITS : natural range 0 to 15 := 1;  -- 默认1位移位

signal shift_din_value :  std_logic_vector(3 downto 0);----接收灵敏度

signal din_mod_I_final_0 : std_logic_vector(15 downto 0);
signal din_mod_Q_final_0 : std_logic_vector(15 downto 0);
signal din_mod_I_final_1 : std_logic_vector(15 downto 0);
signal din_mod_Q_final_1 : std_logic_vector(15 downto 0);
signal din_mod_I_final_2 : std_logic_vector(15 downto 0);
signal din_mod_Q_final_2 : std_logic_vector(15 downto 0);
signal din_mod_I_final_3 : std_logic_vector(15 downto 0);
signal din_mod_Q_final_3 : std_logic_vector(15 downto 0);
signal din_mod_I_final_4 : std_logic_vector(15 downto 0);
signal din_mod_Q_final_4 : std_logic_vector(15 downto 0);
signal din_mod_I_final_5 : std_logic_vector(15 downto 0);
signal din_mod_Q_final_5 : std_logic_vector(15 downto 0);
signal din_mod_I_final_6 : std_logic_vector(15 downto 0);
signal din_mod_Q_final_6 : std_logic_vector(15 downto 0);
signal din_mod_I_final_7 : std_logic_vector(15 downto 0);
signal din_mod_Q_final_7 : std_logic_vector(15 downto 0);
signal din_mod_final_0 : std_logic_vector(31 downto 0);
signal din_mod_final_1 : std_logic_vector(31 downto 0);
signal din_mod_final_2 : std_logic_vector(31 downto 0);
signal din_mod_final_3 : std_logic_vector(31 downto 0);
signal din_mod_final_4 : std_logic_vector(31 downto 0);
signal din_mod_final_5 : std_logic_vector(31 downto 0);
signal din_mod_final_6 : std_logic_vector(31 downto 0);
signal din_mod_final_7 : std_logic_vector(31 downto 0);

signal irq1_valid      :std_logic;
signal fft_bram_reset  :std_logic;

signal din_rx_I_Q_0     : std_logic_vector(31 downto 0);
signal din_rx_I_Q_1     : std_logic_vector(31 downto 0);
signal din_rx_I_Q_2     : std_logic_vector(31 downto 0);
signal din_rx_I_Q_3     : std_logic_vector(31 downto 0);
signal din_rx_I_Q_4     : std_logic_vector(31 downto 0);
signal din_rx_I_Q_5     : std_logic_vector(31 downto 0);
signal din_rx_I_Q_6     : std_logic_vector(31 downto 0);
signal din_rx_I_Q_7     : std_logic_vector(31 downto 0);







 
 


COMPONENT vio_iq
  PORT (
    clk : IN STD_LOGIC;
    probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

COMPONENT ila_locked

PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT  ;

COMPONENT ila_tx_rx_gpio

PORT (
	clk : IN STD_LOGIC;



	probe0 : IN STD_LOGIC_VECTOR(25 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT  ;

COMPONENT ila_DATA_CONVENTER

PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe4 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe5 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe6 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe7 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe8 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe9 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe10 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe11 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe12 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe13 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe14 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe15 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe16 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe17 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe18 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe19 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe20 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe21 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe22 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe23 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe24 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe25 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe26 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe27 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe28 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe29 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe30 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe31 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe32 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe33 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT  ;


COMPONENT ila_data_converter_state
PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(9 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(9 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	probe3 : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	probe4 : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	probe5 : IN STD_LOGIC;
	probe6 : IN STD_LOGIC;
	probe7 : IN STD_LOGIC;
	probe8 : IN STD_LOGIC;
	probe9 : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
);
END COMPONENT  ;

----   通过计数器查看data_converter配置状态  ----
signal COUNTER_128M :STD_LOGIC_VECTOR(9 downto 0);
signal COUNTER_ADC_0:STD_LOGIC_VECTOR(9 downto 0);
signal COUNTER_ADC_1:STD_LOGIC_VECTOR(9 downto 0);
signal COUNTER_DAC_0:STD_LOGIC_VECTOR(9 downto 0);
signal COUNTER_DAC_1:STD_LOGIC_VECTOR(9 downto 0);
signal flag_10M_start : STD_LOGIC;

component dds_DA_input is
  Port ( 
       clk              : IN STD_LOGIC;
       reset            : IN STD_LOGIC;
       ----   dds 相位赋值   ----
       flag_10M_start                 : IN STD_LOGIC;
        s_axis_phase_inc               : in   std_logic_vector(15 downto 0);     
        s_axis_phase_offset_0          : in   std_logic_vector(15 downto 0);
        s_axis_phase_offset_1          : in   std_logic_vector(15 downto 0);
        s_axis_phase_offset_2          : in   std_logic_vector(15 downto 0);
        s_axis_phase_offset_3          : in   std_logic_vector(15 downto 0);
        s_axis_phase_offset_4          : in   std_logic_vector(15 downto 0);
        s_axis_phase_offset_5          : in   std_logic_vector(15 downto 0);
        s_axis_phase_offset_6          : in   std_logic_vector(15 downto 0);
        s_axis_phase_offset_7          : in   std_logic_vector(15 downto 0);
        ----   输出至DAC的数据   ----
        dout_mod_I_0_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_Q_0_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_I_1_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_Q_1_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_I_2_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_Q_2_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_I_3_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_Q_3_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_I_4_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_Q_4_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_I_5_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_Q_5_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_I_6_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_Q_6_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_I_7_100M              : out  STD_LOGIC_VECTOR(15 downto 0); 
        dout_mod_Q_7_100M              : out  STD_LOGIC_VECTOR(15 downto 0)
  );
end component;

component pcie_test_ram is
Port ( 
    clk : in std_logic;
    reset : in std_logic;
    
    --- data_out ---
    clkb_0 : in std_logic;
    addrb_0 : in std_logic_vector(17 downto 0);
    data_out_0 : out std_logic_vector(255 downto 0);
    enb_0 : in std_logic;
    
    clkb_1 : in std_logic;
    addrb_1 : in std_logic_vector(17 downto 0);
    data_out_1 : out std_logic_vector(255 downto 0);
    enb_1 : in std_logic;
    
    irq1_clean          : in std_logic;
    irq2_clean          : in std_logic;      
    usr_irq_ack_0       : in std_logic_vector(1 downto 0);
    irq : out std_logic_vector(1 downto 0)
);
end component;

component pcie_test is
Port ( 
    clk : in std_logic;
    reset : in std_logic;
    
    --- data_out ---
    clkb_0 : in std_logic;
    addrb_0 : in std_logic_vector(17 downto 0);
    data_out_0 : out std_logic_vector(255 downto 0);
    enb_0 : in std_logic;
    
    clkb_1 : in std_logic;
    addrb_1 : in std_logic_vector(17 downto 0);
    data_out_1 : out std_logic_vector(255 downto 0);
    enb_1 : in std_logic;
        
    usr_irq_ack_0       : in std_logic_vector(1 downto 0);
    irq : out std_logic_vector(1 downto 0)
);
end component;

COMPONENT pio_interface
PORT(
    clk                 : in std_logic;
    clka                : in std_logic;
    clkb                : in std_logic;
    bram_addr_pio_a     : in std_logic_vector(11 downto 0);
    bram_addr_pio_b     : in std_logic_vector(11 downto 0);
    bram_en_pio_a       : in std_logic;
    bram_en_pio_b       : in std_logic;
    bram_rddata_pio_a   : out std_logic_vector(31 downto 0);
    bram_rddata_pio_b   : out std_logic_vector(31 downto 0);
    bram_rst_pio_a      : in std_logic;
    bram_rst_pio_b      : in std_logic;
    bram_we_pio_a       : in std_logic_vector(3 downto 0);
    bram_we_pio_b       : in std_logic_vector(3 downto 0);
    bram_wrdata_pio_a   : in std_logic_vector(31 downto 0);
    bram_wrdata_pio_b   : in std_logic_vector(31 downto 0);
    irq1_clean          : out std_logic;
    irq2_clean          : out std_logic;
    flag_rdy            : out std_logic;
    data_source_select  : out std_logic;
    reset_DDS_0              : out std_logic;                     
    phase_PINC_0             : out std_logic_vector(31 downto 0); 
    phase_POFF_0_tunnel0     : out std_logic_vector(31 downto 0); 
    phase_POFF_1_tunnel0     : out std_logic_vector(31 downto 0); 
    phase_POFF_2_tunnel0     : out std_logic_vector(31 downto 0); 
    phase_POFF_3_tunnel0     : out std_logic_vector(31 downto 0); 
    phase_POFF_4_tunnel0     : out std_logic_vector(31 downto 0); 
    phase_POFF_5_tunnel0     : out std_logic_vector(31 downto 0); 
    phase_POFF_6_tunnel0     : out std_logic_vector(31 downto 0); 
    phase_POFF_7_tunnel0     : out std_logic_vector(31 downto 0);                                                  
    reset_DDS_1              : out std_logic;                     
    phase_PINC_1             : out std_logic_vector(31 downto 0); 
    phase_POFF_0_tunnel1     : out std_logic_vector(31 downto 0); 
    phase_POFF_1_tunnel1     : out std_logic_vector(31 downto 0); 
    phase_POFF_2_tunnel1     : out std_logic_vector(31 downto 0); 
    phase_POFF_3_tunnel1     : out std_logic_vector(31 downto 0); 
    phase_POFF_4_tunnel1     : out std_logic_vector(31 downto 0); 
    phase_POFF_5_tunnel1     : out std_logic_vector(31 downto 0); 
    phase_POFF_6_tunnel1     : out std_logic_vector(31 downto 0); 
    phase_POFF_7_tunnel1     : out std_logic_vector(31 downto 0); 
    
                                                         
    reset_DDS_2              : out std_logic;                     
    phase_PINC_2             : out std_logic_vector(31 downto 0); 
    phase_POFF_0_tunnel2     : out std_logic_vector(31 downto 0); 
    phase_POFF_1_tunnel2     : out std_logic_vector(31 downto 0); 
    phase_POFF_2_tunnel2     : out std_logic_vector(31 downto 0); 
    phase_POFF_3_tunnel2     : out std_logic_vector(31 downto 0); 
    phase_POFF_4_tunnel2     : out std_logic_vector(31 downto 0); 
    phase_POFF_5_tunnel2     : out std_logic_vector(31 downto 0); 
    phase_POFF_6_tunnel2     : out std_logic_vector(31 downto 0); 
    phase_POFF_7_tunnel2     : out std_logic_vector(31 downto 0); 
    
                                                           
    reset_DDS_3              : out std_logic;                     
    phase_PINC_3             : out std_logic_vector(31 downto 0); 
    phase_POFF_0_tunnel3     : out std_logic_vector(31 downto 0); 
    phase_POFF_1_tunnel3     : out std_logic_vector(31 downto 0); 
    phase_POFF_2_tunnel3     : out std_logic_vector(31 downto 0); 
    phase_POFF_3_tunnel3     : out std_logic_vector(31 downto 0); 
    phase_POFF_4_tunnel3     : out std_logic_vector(31 downto 0); 
    phase_POFF_5_tunnel3     : out std_logic_vector(31 downto 0); 
    phase_POFF_6_tunnel3     : out std_logic_vector(31 downto 0); 
    phase_POFF_7_tunnel3     : out std_logic_vector(31 downto 0); 
    
                                                           
    reset_DDS_4              : out std_logic;                     
    phase_PINC_4             : out std_logic_vector(31 downto 0); 
    phase_POFF_0_tunnel4     : out std_logic_vector(31 downto 0); 
    phase_POFF_1_tunnel4     : out std_logic_vector(31 downto 0); 
    phase_POFF_2_tunnel4     : out std_logic_vector(31 downto 0); 
    phase_POFF_3_tunnel4     : out std_logic_vector(31 downto 0); 
    phase_POFF_4_tunnel4     : out std_logic_vector(31 downto 0); 
    phase_POFF_5_tunnel4     : out std_logic_vector(31 downto 0); 
    phase_POFF_6_tunnel4     : out std_logic_vector(31 downto 0); 
    phase_POFF_7_tunnel4     : out std_logic_vector(31 downto 0); 
    
                                                       
    reset_DDS_5              : out std_logic;                     
    phase_PINC_5             : out std_logic_vector(31 downto 0); 
    phase_POFF_0_tunnel5     : out std_logic_vector(31 downto 0); 
    phase_POFF_1_tunnel5     : out std_logic_vector(31 downto 0); 
    phase_POFF_2_tunnel5     : out std_logic_vector(31 downto 0); 
    phase_POFF_3_tunnel5     : out std_logic_vector(31 downto 0); 
    phase_POFF_4_tunnel5     : out std_logic_vector(31 downto 0); 
    phase_POFF_5_tunnel5     : out std_logic_vector(31 downto 0); 
    phase_POFF_6_tunnel5     : out std_logic_vector(31 downto 0); 
    phase_POFF_7_tunnel5     : out std_logic_vector(31 downto 0); 
    
                                                       
    reset_DDS_6              : out std_logic;                     
    phase_PINC_6             : out std_logic_vector(31 downto 0); 
    phase_POFF_0_tunnel6     : out std_logic_vector(31 downto 0); 
    phase_POFF_1_tunnel6     : out std_logic_vector(31 downto 0); 
    phase_POFF_2_tunnel6     : out std_logic_vector(31 downto 0); 
    phase_POFF_3_tunnel6     : out std_logic_vector(31 downto 0); 
    phase_POFF_4_tunnel6     : out std_logic_vector(31 downto 0); 
    phase_POFF_5_tunnel6     : out std_logic_vector(31 downto 0); 
    phase_POFF_6_tunnel6     : out std_logic_vector(31 downto 0); 
    phase_POFF_7_tunnel6     : out std_logic_vector(31 downto 0); 
    
                                                       
    reset_DDS_7              : out std_logic;                     
    phase_PINC_7             : out std_logic_vector(31 downto 0); 
    phase_POFF_0_tunnel7     : out std_logic_vector(31 downto 0); 
    phase_POFF_1_tunnel7     : out std_logic_vector(31 downto 0); 
    phase_POFF_2_tunnel7     : out std_logic_vector(31 downto 0); 
    phase_POFF_3_tunnel7     : out std_logic_vector(31 downto 0); 
    phase_POFF_4_tunnel7     : out std_logic_vector(31 downto 0); 
    phase_POFF_5_tunnel7     : out std_logic_vector(31 downto 0); 
    phase_POFF_6_tunnel7     : out std_logic_vector(31 downto 0); 
    phase_POFF_7_tunnel7     : out std_logic_vector(31 downto 0); 
    
                                                       
    reset_DDS_8              : out std_logic;                     
    phase_PINC_8             : out std_logic_vector(31 downto 0); 
    phase_POFF_0_tunnel8     : out std_logic_vector(31 downto 0); 
    phase_POFF_1_tunnel8     : out std_logic_vector(31 downto 0); 
    phase_POFF_2_tunnel8     : out std_logic_vector(31 downto 0); 
    phase_POFF_3_tunnel8     : out std_logic_vector(31 downto 0); 
    phase_POFF_4_tunnel8     : out std_logic_vector(31 downto 0); 
    phase_POFF_5_tunnel8     : out std_logic_vector(31 downto 0); 
    phase_POFF_6_tunnel8     : out std_logic_vector(31 downto 0); 
    phase_POFF_7_tunnel8     : out std_logic_vector(31 downto 0); 
    
                                               
    reset_DDS_9              : out std_logic;                     
    phase_PINC_9             : out std_logic_vector(31 downto 0); 
    phase_POFF_0_tunnel9     : out std_logic_vector(31 downto 0); 
    phase_POFF_1_tunnel9     : out std_logic_vector(31 downto 0); 
    phase_POFF_2_tunnel9     : out std_logic_vector(31 downto 0); 
    phase_POFF_3_tunnel9     : out std_logic_vector(31 downto 0); 
    phase_POFF_4_tunnel9     : out std_logic_vector(31 downto 0); 
    phase_POFF_5_tunnel9     : out std_logic_vector(31 downto 0); 
    phase_POFF_6_tunnel9     : out std_logic_vector(31 downto 0); 
    phase_POFF_7_tunnel9     : out std_logic_vector(31 downto 0); 
    
                                                       
    reset_DDS_10              :out  std_logic;                    
    phase_PINC_10             :out  std_logic_vector(31 downto 0);
    phase_POFF_0_tunnel10     :out  std_logic_vector(31 downto 0);
    phase_POFF_1_tunnel10     :out  std_logic_vector(31 downto 0);
    phase_POFF_2_tunnel10     :out  std_logic_vector(31 downto 0);
    phase_POFF_3_tunnel10     :out  std_logic_vector(31 downto 0);
    phase_POFF_4_tunnel10     :out  std_logic_vector(31 downto 0);
    phase_POFF_5_tunnel10     :out  std_logic_vector(31 downto 0);
    phase_POFF_6_tunnel10     :out  std_logic_vector(31 downto 0);
    phase_POFF_7_tunnel10     :out  std_logic_vector(31 downto 0);
    
                                                        
    reset_DDS_11              :out  std_logic;                    
    phase_PINC_11             :out  std_logic_vector(31 downto 0);
    phase_POFF_0_tunnel11     :out  std_logic_vector(31 downto 0);
    phase_POFF_1_tunnel11     :out  std_logic_vector(31 downto 0);
    phase_POFF_2_tunnel11     :out  std_logic_vector(31 downto 0);
    phase_POFF_3_tunnel11     :out  std_logic_vector(31 downto 0);
    phase_POFF_4_tunnel11     :out  std_logic_vector(31 downto 0);
    phase_POFF_5_tunnel11     :out  std_logic_vector(31 downto 0);
    phase_POFF_6_tunnel11     :out  std_logic_vector(31 downto 0);
    phase_POFF_7_tunnel11     :out  std_logic_vector(31 downto 0);
    
    
    reset_DDS_12              :out  std_logic;                    
    phase_PINC_12             :out  std_logic_vector(31 downto 0);
    phase_POFF_0_tunnel12     :out  std_logic_vector(31 downto 0);
    phase_POFF_1_tunnel12     :out  std_logic_vector(31 downto 0);
    phase_POFF_2_tunnel12     :out  std_logic_vector(31 downto 0);
    phase_POFF_3_tunnel12     :out  std_logic_vector(31 downto 0);
    phase_POFF_4_tunnel12     :out  std_logic_vector(31 downto 0);
    phase_POFF_5_tunnel12     :out  std_logic_vector(31 downto 0);
    phase_POFF_6_tunnel12     :out  std_logic_vector(31 downto 0);
    phase_POFF_7_tunnel12     :out  std_logic_vector(31 downto 0);
    
    
    reset_DDS_13              :out  std_logic;                    
    phase_PINC_13             :out  std_logic_vector(31 downto 0);
    phase_POFF_0_tunnel13     :out  std_logic_vector(31 downto 0);
    phase_POFF_1_tunnel13     :out  std_logic_vector(31 downto 0);
    phase_POFF_2_tunnel13     :out  std_logic_vector(31 downto 0);
    phase_POFF_3_tunnel13     :out  std_logic_vector(31 downto 0);
    phase_POFF_4_tunnel13     :out  std_logic_vector(31 downto 0);
    phase_POFF_5_tunnel13     :out  std_logic_vector(31 downto 0);
    phase_POFF_6_tunnel13     :out  std_logic_vector(31 downto 0);
    phase_POFF_7_tunnel13     :out  std_logic_vector(31 downto 0);
    
    
    reset_DDS_14              :out  std_logic;                    
    phase_PINC_14             :out  std_logic_vector(31 downto 0);
    phase_POFF_0_tunnel14     :out  std_logic_vector(31 downto 0);
    phase_POFF_1_tunnel14     :out  std_logic_vector(31 downto 0);
    phase_POFF_2_tunnel14     :out  std_logic_vector(31 downto 0);
    phase_POFF_3_tunnel14     :out  std_logic_vector(31 downto 0);
    phase_POFF_4_tunnel14     :out  std_logic_vector(31 downto 0);
    phase_POFF_5_tunnel14     :out  std_logic_vector(31 downto 0);
    phase_POFF_6_tunnel14     :out  std_logic_vector(31 downto 0);
    phase_POFF_7_tunnel14     :out  std_logic_vector(31 downto 0);
    tunnel_switch_out         :out  std_logic_vector(3 downto 0);
    write_stop          : out std_logic
);
END COMPONENT;
    signal tunnel_switch       :  std_logic_vector(3 downto 0);

    signal bram_clk_pio_a:  std_logic;
    signal bram_en_pio_a:  std_logic;
    signal bram_we_pio_a:  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal bram_addr_pio_a: STD_LOGIC_VECTOR(11 DOWNTO 0);
    signal bram_wrdata_pio_a: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal bram_rddata_pio_a: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal bram_rst_pio_a    :  std_logic;
    signal bram_clk_pio_b:  std_logic;
    signal bram_en_pio_b:  std_logic;
    signal bram_we_pio_b:  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal bram_addr_pio_b: STD_LOGIC_VECTOR(11 DOWNTO 0);
    signal bram_wrdata_pio_b: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal bram_rddata_pio_b: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal bram_rst_pio_b    :  std_logic;
    
    signal bram_clk_dma_b_0:  std_logic;
    signal bram_clk_dma_b_1:  std_logic;
    signal bram_clk_dma_b_2:  std_logic;
    signal bram_clk_dma_b_3:  std_logic;
    signal bram_clk_dma_b_4:  std_logic;
    signal bram_clk_dma_b_5:  std_logic;
    signal bram_clk_dma_b_6:  std_logic;
    signal bram_en_dma_b_0:  std_logic;
    signal bram_en_dma_b_1:  std_logic;
    signal bram_en_dma_b_2:  std_logic;
    signal bram_en_dma_b_3:  std_logic;
    signal bram_en_dma_b_4:  std_logic;
    signal bram_en_dma_b_5:  std_logic;
    signal bram_en_dma_b_6:  std_logic;
    signal bram_we_dma_b_0:  STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal bram_we_dma_b_1:  STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal bram_we_dma_b_2:  STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal bram_we_dma_b_3:  STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal bram_we_dma_b_4:  STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal bram_we_dma_b_5:  STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal bram_we_dma_b_6:  STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal bram_addr_dma_b_0: STD_LOGIC_VECTOR(19 DOWNTO 0);
    signal bram_addr_dma_b_1: STD_LOGIC_VECTOR(19 DOWNTO 0);
    signal bram_addr_dma_b_2: STD_LOGIC_VECTOR(17 DOWNTO 0);
    signal bram_addr_dma_b_3: STD_LOGIC_VECTOR(17 DOWNTO 0);
    signal bram_addr_dma_b_4: STD_LOGIC_VECTOR(17 DOWNTO 0);
    signal bram_addr_dma_b_5: STD_LOGIC_VECTOR(17 DOWNTO 0);
    signal bram_addr_dma_b_6: STD_LOGIC_VECTOR(17 DOWNTO 0);
    signal bram_wrdata_dma_b_0: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_wrdata_dma_b_1: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_wrdata_dma_b_2: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_wrdata_dma_b_3: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_wrdata_dma_b_4: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_wrdata_dma_b_5: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_wrdata_dma_b_6: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_rddata_dma_b_0: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_rddata_dma_b_1: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_rddata_dma_b_2: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_rddata_dma_b_3: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_rddata_dma_b_4: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_rddata_dma_b_5: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_rddata_dma_b_6: STD_LOGIC_VECTOR(511 DOWNTO 0);
    signal bram_rst_dma_b_0    :  std_logic;
    signal bram_rst_dma_b_1    :  std_logic;
    signal bram_rst_dma_b_2    :  std_logic;
    signal bram_rst_dma_b_3    :  std_logic;
    signal bram_rst_dma_b_4    :  std_logic;
    signal bram_rst_dma_b_5    :  std_logic;
    signal bram_rst_dma_b_6    :  std_logic;
    
    signal user_lnk_up_0     :  std_logic;
    
    signal irq_ram          : std_logic_vector(1 downto 0);
    
    signal reset_rtl_0      : std_logic;
    signal axi_aresetn      : std_logic;
    
    signal flag_rdy     : std_logic;
    signal write_stop   : std_logic;
--    signal axi_aclk     : std_logic;
    signal usr_irq_ack_0            : std_logic_vector(7 downto 0);
    signal irq_xdma                 : std_logic_vector(7 downto 0);
    signal msi_enable_0             : std_logic;
    signal msi_vector_width_0       : STD_LOGIC_VECTOR ( 2 downto 0 );
    
    signal write_en1_out            : std_logic;                     
    signal write_en2_out            : std_logic;                     
    signal addr_write_out           : std_logic_vector(17 downto 0); 
    signal irq_internal1_out        : std_logic;                     
    signal irq_internal2_out        : std_logic;                     
    signal bram1_en_out             : std_logic;                     
    signal bram2_en_out             : std_logic;                     
    signal write_stop_out           : std_logic;                     
    signal flag_rdy_data_out        : std_logic;                     
    signal data_in_FFT_valid_out    : std_logic;                     
    signal vio_valid_out            : std_logic;                     
    
    signal irq1_clean               : std_logic;
    signal irq2_clean               : std_logic;

component fft_polyphase is
    Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           reset_DDS : in STD_LOGIC;
           phase_PINC : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_0 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_1 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_2 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_3 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_4 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_5 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_6 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_7 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_0 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_1 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_2 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_3 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_4 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_5 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_6 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_7 : in STD_LOGIC_VECTOR (31 downto 0);
           reg_fft_tap_select : in STD_LOGIC_VECTOR (2 downto 0);
           flag_rdy : in std_logic;
           num_valid : in std_logic_vector(13 downto 0);
           addup_N  : in std_logic_vector(15 downto 0);
           shift_bits             : in std_logic_vector(4 downto 0);
           fft_stop : in std_logic;
           bram_addr_fft          : in std_logic_vector(17 downto 0);           
           bram_clk_fft           : in std_logic;                        
           bram_rddata_fft        : out std_logic_vector(255 downto 0);  
           bram_en_fft            : in std_logic;
           irq                      : out std_logic
       );
end component;

component wideband_acq
Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           reset_DDS : in STD_LOGIC;
           phase_PINC : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_0 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_1 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_2 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_3 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_4 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_5 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_6 : in STD_LOGIC_VECTOR (31 downto 0);
           phase_POFF_7 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_0 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_1 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_2 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_3 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_4 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_5 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_6 : in STD_LOGIC_VECTOR (31 downto 0);
           data_in_7 : in STD_LOGIC_VECTOR (31 downto 0);
           reg_fft_tap_select : in STD_LOGIC_VECTOR (2 downto 0);
           flag_rdy : in std_logic;
           bram_addr_fft          : in std_logic_vector(17 downto 0);           
           bram_clk_fft           : in std_logic;                        
           bram_rddata_fft        : out std_logic_vector(255 downto 0);  
           bram_en_fft            : in std_logic;
           bram_addr_fft_1          : in std_logic_vector(17 downto 0);           
           bram_clk_fft_1           : in std_logic;                        
           bram_rddata_fft_1        : out std_logic_vector(255 downto 0);  
           bram_en_fft_1            : in std_logic;
           irq                      : out std_logic_vector(1 downto 0)
       );
end component;
COMPONENT ila_dds
PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe5 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe6 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe7 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe8 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe9 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe10 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe11 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe12 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe13 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe14 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe15 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe16 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe17 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe18 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe19 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe20 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe21 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe22 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe23 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe24 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe25 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe26 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe27 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe28 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe29 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe30 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe31 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe32 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe33 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe34 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe35 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe36 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe37 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe38 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe39 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe40 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe41 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe42 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe43 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe44 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe45 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe46 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe47 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe48 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe49 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe50 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe51 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe52 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	probe53 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	probe54 : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END COMPONENT  ;
component data_aquis
port(
    reset : in STD_LOGIC;
    clk : in STD_LOGIC;
    reset_DDS : in STD_LOGIC;
    flag_rdy_data : in std_logic;
    phase_PINC : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_0 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_1 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_2 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_3 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_4 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_5 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_6 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_7 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_0 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_1 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_2 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_3 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_4 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_5 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_6 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_7 : in STD_LOGIC_VECTOR (31 downto 0);
    reg_fft_tap_select : in STD_LOGIC_VECTOR (2 downto 0);
    
    bram_addr_data          : in std_logic_vector(17 downto 0); 
    bram_clk_data           : in std_logic;                     
    bram_rddata_data        : out std_logic_vector(15 downto 0);
       
    bram_reset                  : in std_logic;       
    bram_update                 : in std_logic;  
    irq_data                    : out std_logic
);
end component;

signal reset_DDS_fft : std_logic;
signal phase_PINC_fft : std_logic_vector(31 downto 0);
signal phase_POFF_0_fft : std_logic_vector(31 downto 0);
signal phase_POFF_1_fft : std_logic_vector(31 downto 0);
signal phase_POFF_2_fft : std_logic_vector(31 downto 0);
signal phase_POFF_3_fft : std_logic_vector(31 downto 0);
signal phase_POFF_4_fft : std_logic_vector(31 downto 0);
signal phase_POFF_5_fft : std_logic_vector(31 downto 0);
signal phase_POFF_6_fft : std_logic_vector(31 downto 0);
signal phase_POFF_7_fft : std_logic_vector(31 downto 0);
signal reg_fft_tap_select : std_logic_vector(2 downto 0);
signal num_valid          : std_logic_vector(13 downto 0);
signal fft_stop           : std_logic;
signal addup_N            : std_logic_vector(15 downto 0);
signal shift_bits_fft         : std_logic_vector(4 downto 0);


component pcie_irq_ctrl
port(
    clk : in std_logic;
    clkb0 : in std_logic;
    addrb0 : in std_logic_vector(19 downto 0);
    dout0 : out std_logic_vector(511 downto 0);
    clkb1 : in std_logic;
    addrb1 : in std_logic_vector(19 downto 0);
    dout1 : out std_logic_vector(511 downto 0);
    reset : in std_logic;
    data_in : in std_logic_vector(511 downto 0);
    data_in_valid : in std_logic;
    irq_ctrl : out std_logic_vector(1 downto 0);
    flag_xdma_test_rdy : in std_logic;
    xdma_stop : in std_logic;
    data_source_select : in std_logic;
    irq_ack : in std_logic_vector(1 downto 0)
);
end component;
signal data_512b : std_logic_vector(511 downto 0);
signal zeros_128 : std_logic_vector(127 downto 0);
signal data_source_select : std_logic;

component real_time_process
port(
    reset : in STD_LOGIC;
    clk : in STD_LOGIC;
    reset_DDS : in STD_LOGIC;
    flag_rdy_data : in std_logic;
    phase_PINC : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_0 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_1 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_2 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_3 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_4 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_5 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_6 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_7 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_0 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_1 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_2 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_3 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_4 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_5 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_6 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_7 : in STD_LOGIC_VECTOR (31 downto 0);
    reg_fft_tap_select : in STD_LOGIC_VECTOR (2 downto 0);
    
    bram_addr_b_0   :   in std_logic_vector(18 downto 0);
    bram_addr_b_1   :   in std_logic_vector(18 downto 0);
    bram_clk_b_0    :   in STD_LOGIC;
    bram_clk_b_1    :   in STD_LOGIC;
    bram_en_b_0     :   in STD_LOGIC;
    bram_en_b_1     :   in STD_LOGIC;
    bram_rddata_b_0 :   out STD_LOGIC_VECTOR ( 255 downto 0 );
    bram_rddata_b_1 :   out STD_LOGIC_VECTOR ( 255 downto 0 );
       
    write_stop                  : in std_logic;
    bram_reset                  : in std_logic;       
    bram_update                 : in std_logic;  
    usr_irq_ack_0               : in std_logic_vector( 1 downto 0);
    irq_pcie                    : out std_logic_vector(1 downto 0)
);
end component;

component data_pcie
port(
    reset : in STD_LOGIC;
    clk : in STD_LOGIC;
    reset_DDS : in STD_LOGIC;
    phase_PINC : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_0 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_1 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_2 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_3 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_4 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_5 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_6 : in STD_LOGIC_VECTOR (31 downto 0);
    phase_POFF_7 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_0 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_1 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_2 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_3 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_4 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_5 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_6 : in STD_LOGIC_VECTOR (31 downto 0);
    data_in_7 : in STD_LOGIC_VECTOR (31 downto 0);
    data_out : out std_logic_vector(31 downto 0);
    data_out_valid : out std_logic
);
end component;

signal reset_DDS_0              : std_logic;
signal phase_PINC_0             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel0     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel0     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel0     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel0     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel0     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel0     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel0     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel0     : std_logic_vector(31 downto 0);
signal data_out_tunnel0         : std_logic_vector(31 downto 0);
signal data_out_valid           : std_logic;
signal data_out_valid_in           : std_logic;

signal reset_DDS_1              : std_logic;
signal phase_PINC_1             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel1     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel1     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel1     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel1     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel1     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel1     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel1     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel1     : std_logic_vector(31 downto 0);
signal data_out_tunnel1         : std_logic_vector(31 downto 0);

signal reset_DDS_2              : std_logic;
signal phase_PINC_2             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel2     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel2     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel2     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel2     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel2     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel2     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel2     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel2     : std_logic_vector(31 downto 0);
signal data_out_tunnel2         : std_logic_vector(31 downto 0);

signal reset_DDS_3              : std_logic;
signal phase_PINC_3             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel3     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel3     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel3     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel3     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel3     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel3     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel3     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel3     : std_logic_vector(31 downto 0);
signal data_out_tunnel3         : std_logic_vector(31 downto 0);

signal reset_DDS_4              : std_logic;
signal phase_PINC_4             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel4     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel4     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel4     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel4     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel4     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel4     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel4     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel4     : std_logic_vector(31 downto 0);
signal data_out_tunnel4         : std_logic_vector(31 downto 0);

signal reset_DDS_5              : std_logic;
signal phase_PINC_5             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel5     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel5     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel5     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel5     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel5     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel5     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel5     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel5     : std_logic_vector(31 downto 0);
signal data_out_tunnel5         : std_logic_vector(31 downto 0);

signal reset_DDS_6              : std_logic;
signal phase_PINC_6             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel6     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel6     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel6     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel6     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel6     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel6     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel6     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel6     : std_logic_vector(31 downto 0);
signal data_out_tunnel6         : std_logic_vector(31 downto 0);

signal reset_DDS_7              : std_logic;
signal phase_PINC_7             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel7     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel7     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel7     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel7     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel7     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel7     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel7     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel7     : std_logic_vector(31 downto 0);
signal data_out_tunnel7         : std_logic_vector(31 downto 0);

signal reset_DDS_8              : std_logic;
signal phase_PINC_8             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel8     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel8     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel8     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel8     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel8     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel8     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel8     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel8     : std_logic_vector(31 downto 0);
signal data_out_tunnel8         : std_logic_vector(31 downto 0);

signal reset_DDS_9              : std_logic;
signal phase_PINC_9             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel9     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel9     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel9     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel9     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel9     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel9     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel9     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel9     : std_logic_vector(31 downto 0);
signal data_out_tunnel9         : std_logic_vector(31 downto 0);

signal reset_DDS_10              : std_logic;
signal phase_PINC_10             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel10     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel10     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel10     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel10     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel10     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel10     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel10     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel10     : std_logic_vector(31 downto 0);
signal data_out_tunnel10         : std_logic_vector(31 downto 0);

signal reset_DDS_11              : std_logic;
signal phase_PINC_11             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel11     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel11     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel11     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel11     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel11     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel11     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel11     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel11     : std_logic_vector(31 downto 0);
signal data_out_tunnel11         : std_logic_vector(31 downto 0);

signal reset_DDS_12              : std_logic;
signal phase_PINC_12             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel12     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel12     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel12     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel12     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel12     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel12     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel12     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel12     : std_logic_vector(31 downto 0);
signal data_out_tunnel12         : std_logic_vector(31 downto 0);

signal reset_DDS_13              : std_logic;
signal phase_PINC_13             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel13     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel13     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel13     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel13     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel13     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel13     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel13     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel13     : std_logic_vector(31 downto 0);
signal data_out_tunnel13         : std_logic_vector(31 downto 0);

signal reset_DDS_14              : std_logic;
signal phase_PINC_14             : std_logic_vector(31 downto 0);
signal phase_POFF_0_tunnel14     : std_logic_vector(31 downto 0);
signal phase_POFF_1_tunnel14     : std_logic_vector(31 downto 0);
signal phase_POFF_2_tunnel14     : std_logic_vector(31 downto 0);
signal phase_POFF_3_tunnel14     : std_logic_vector(31 downto 0);
signal phase_POFF_4_tunnel14     : std_logic_vector(31 downto 0);
signal phase_POFF_5_tunnel14     : std_logic_vector(31 downto 0);
signal phase_POFF_6_tunnel14     : std_logic_vector(31 downto 0);
signal phase_POFF_7_tunnel14     : std_logic_vector(31 downto 0);
signal data_out_tunnel14         : std_logic_vector(31 downto 0);

signal gps_pps_counter           : std_logic_vector(31 downto 0);
signal gps_pps_counter_reset     : std_logic;

begin

--pcie_clk_test <= pcie_ref_clk_p(0);
u_xdma_reset: xdma_reset
  port map (
    clk             => clk_100M_ps,
    user_lnk_up     => user_lnk_up_0,
    sys_rst_n       => sys_rst_n_0
  );
  


U_0: design_1_wrapper 
  port map(
    clk_100M => clk_100M_ps,
    ps_aresten_100M(0) => resetn_ps_100M,
    adc0_clk_0_clk_n => REFCLK1_N_ADC0_SI5341,
    adc0_clk_0_clk_p => REFCLK1_P_ADC0_SI5341,
    adc2_clk_0_clk_n => REFCLK1_N_ADC2_SI5341,
    adc2_clk_0_clk_p => REFCLK1_P_ADC2_SI5341,
    adc3_clk_0_clk_n => REFCLK1_N_ADC3_SI5341,
    adc3_clk_0_clk_p => REFCLK1_P_ADC3_SI5341,
    
          
    dac0_clk_0_clk_n => REFCLK1_N_DAC0_SI5341,
    dac0_clk_0_clk_p => REFCLK1_P_DAC0_SI5341,
    dac2_clk_0_clk_n => REFCLK1_N_DAC2_SI5341,
    dac2_clk_0_clk_p => REFCLK1_P_DAC2_SI5341,
    
    clk_adc0_0 => clk_adc0_0,
    clk_adc1_0 => clk_adc1_0,
    clk_adc2_0 => clk_adc2_0, 
    clk_adc3_0 => clk_adc3_0,
    clk_dac0_0 => clk_dac0_0,
    clk_dac2_0 => clk_dac2_0,
    
    m00_axis_tdata_0(127 downto 0) => m00_axis_tdata_0(127 downto 0),
    m00_axis_tready_0 => m00_axis_tready_0,
    m00_axis_tvalid_0 => m00_axis_tvalid_0,
    m01_axis_tdata_0(127 downto 0) => m01_axis_tdata_0(127 downto 0),
    m01_axis_tready_0 => m01_axis_tready_0,
    m01_axis_tvalid_0 => m01_axis_tvalid_0,
    m02_axis_tdata_0(127 downto 0) => m02_axis_tdata_0(127 downto 0),
    m02_axis_tready_0 => m02_axis_tready_0,
    m02_axis_tvalid_0 => m02_axis_tvalid_0,
    m03_axis_tdata_0(127 downto 0) => m03_axis_tdata_0(127 downto 0),
    m03_axis_tready_0 => m03_axis_tready_0,
    m03_axis_tvalid_0 => m03_axis_tvalid_0, 
    m10_axis_tdata_0(127 downto 0) => m10_axis_tdata_0(127 downto 0),
    m10_axis_tready_0 => m10_axis_tready_0,
    m10_axis_tvalid_0 => m10_axis_tvalid_0,
    m11_axis_tdata_0(127 downto 0) => m11_axis_tdata_0(127 downto 0),
    m11_axis_tready_0 => m11_axis_tready_0,
    m11_axis_tvalid_0 => m11_axis_tvalid_0,
    m12_axis_tdata_0(127 downto 0) => m12_axis_tdata_0(127 downto 0),
    m12_axis_tready_0 => m12_axis_tready_0,
    m12_axis_tvalid_0 => m12_axis_tvalid_0,
    m13_axis_tdata_0(127 downto 0) => m13_axis_tdata_0(127 downto 0),
    m13_axis_tready_0 => m13_axis_tready_0,
    m13_axis_tvalid_0 => m13_axis_tvalid_0,
    m20_axis_tdata_0(127 downto 0) => m20_axis_tdata_0(127 downto 0),
    m20_axis_tready_0 => m20_axis_tready_0,
    m20_axis_tvalid_0 => m20_axis_tvalid_0,
    m21_axis_tdata_0(127 downto 0) => m21_axis_tdata_0(127 downto 0),
    m21_axis_tready_0 => m21_axis_tready_0,
    m21_axis_tvalid_0 => m21_axis_tvalid_0,
    m22_axis_tdata_0(127 downto 0) => m22_axis_tdata_0(127 downto 0),
    m22_axis_tready_0 => m22_axis_tready_0,
    m22_axis_tvalid_0 => m22_axis_tvalid_0,
    m23_axis_tdata_0(127 downto 0) => m23_axis_tdata_0(127 downto 0),
    m23_axis_tready_0 => m23_axis_tready_0,
    m23_axis_tvalid_0 => m23_axis_tvalid_0,
    m30_axis_tdata_0(127 downto 0) => m30_axis_tdata_0(127 downto 0),
    m30_axis_tready_0 => m30_axis_tready_0,
    m30_axis_tvalid_0 => m30_axis_tvalid_0,
    m31_axis_tdata_0(127 downto 0) => m31_axis_tdata_0(127 downto 0),
    m31_axis_tready_0 => m31_axis_tready_0,
    m31_axis_tvalid_0 => m31_axis_tvalid_0,
    m32_axis_tdata_0(127 downto 0) => m32_axis_tdata_0(127 downto 0),
    m32_axis_tready_0 => m32_axis_tready_0,
    m32_axis_tvalid_0 => m32_axis_tvalid_0,
    m33_axis_tdata_0(127 downto 0) => m33_axis_tdata_0(127 downto 0),
    m33_axis_tready_0 => m33_axis_tready_0,
    m33_axis_tvalid_0 => m33_axis_tvalid_0,
    
    m0_axis_aclk_0 => clk_128M,
    m0_axis_aresetn_0 => pl_rsten,
    m1_axis_aclk_0 => clk_128M,
    m1_axis_aresetn_0 => pl_rsten,
    m2_axis_aclk_0 => clk_128M,
    m2_axis_aresetn_0 => pl_rsten,
    m3_axis_aclk_0 => clk_128M,
    m3_axis_aresetn_0 => pl_rsten,
    
    
    s00_axis_tdata_0  => s00_axis_tdata_0,
    s00_axis_tready_0 => s00_axis_tready_0,
    s00_axis_tvalid_0 => '1',
    s0_axis_aclk_0    => clk_128M,
    s0_axis_aresetn_0 => pl_rsten,
    
    s20_axis_tdata_0  => s20_axis_tdata_0,
    s20_axis_tready_0 => s20_axis_tready_0,
    -- DAC 数据有效：由 bpsk/qpsk 两条链的数据有效相或驱动（原来钉死 '1'）
    s20_axis_tvalid_0 => dac_sig_valid,
    s2_axis_aclk_0    => clk_128M,
    s2_axis_aresetn_0 => pl_rsten,
    
    vin0_01_0_v_n => RX0_0_N_RF_ADC,
    vin0_01_0_v_p => RX0_0_P_RF_ADC,
    vin0_23_0_v_n => RX0_1_N_RF_ADC,
    vin0_23_0_v_p => RX0_1_P_RF_ADC,
    vin1_01_0_v_n => RX1_0_N_RF_ADC,
    vin1_01_0_v_p => RX1_0_P_RF_ADC,
    vin1_23_0_v_n => RX1_1_N_RF_ADC,
    vin1_23_0_v_p => RX1_1_P_RF_ADC,
    vin2_01_0_v_n => RX2_0_N_RF_ADC,
    vin2_01_0_v_p => RX2_0_P_RF_ADC,
    vin2_23_0_v_n => RX2_1_N_RF_ADC,
    vin2_23_0_v_p => RX2_1_P_RF_ADC,
    vin3_01_0_v_n => RX3_0_N_RF_ADC,
    vin3_01_0_v_p => RX3_0_P_RF_ADC,
    vin3_23_0_v_n => RX3_1_N_RF_ADC,
    vin3_23_0_v_p => RX3_1_P_RF_ADC,
    
        
    vout00_0_v_n => TX0_0_N_RF_DAC,
    vout00_0_v_p => TX0_0_P_RF_DAC,
    vout20_0_v_n => TX2_0_N_RF_DAC,
    vout20_0_v_p => TX2_0_P_RF_DAC,
    irq_0 => irq_0,
     
    mem_a_0    =>  mem_a_0   ,
    mem_cen_0  =>  mem_cen_0  ,
    mem_dq_i_0 =>  mem_dq_i_0,
    mem_dq_o_0 =>  mem_dq_o_0,
    mem_oen_0  =>  mem_oen_0 ,
    mem_wen_0  =>  mem_wen_0 ,
    mem_a_1    =>  mem_a_1   ,
    mem_cen_1  =>  mem_cen_1  ,
    mem_dq_i_1 =>  mem_dq_i_1,
    mem_dq_o_1 =>  mem_dq_o_1,
    mem_oen_1  =>  mem_oen_1 ,
    mem_wen_1  =>  mem_wen_1 ,
    gpio_io_i_0 => gpio_rtl_tri_i_0,
    gpio_io_i_1(0) => gpio_rtl_tri_i_1,
    
    cdma_introut_0 =>cdma_introut_0,
    
    bram_addr_a_1       =>       bram_addr_a_0     ,
    bram_clk_a_1        =>       bram_clk_a_0      ,
    bram_en_a_1         =>       bram_en_a_0       ,
    bram_rddata_a_1     =>       bram_rddata_a_0   ,
    bram_rst_a_1        =>       bram_rst_a_0      ,
    bram_we_a_1         =>       bram_we_a_0       ,
    bram_wrdata_a_1     =>       bram_wrdata_a_0   ,
    emio_uart0_rxd_0    =>       CA53_TXD          ,
    emio_uart0_txd_0    =>       CA53_EXTERNAL_RXD ,
    
    bram_addr_a_0       =>  bram_addr_pio_a         ,
    bram_addr_b_0       =>  bram_addr_pio_b         ,
    bram_addr_b_1       =>  bram_addr_dma_b_0       ,
    bram_addr_b_2       =>  bram_addr_dma_b_1       ,
    bram_addr_b_3       =>  bram_addr_dma_b_2       ,
    bram_addr_b_4       =>  bram_addr_dma_b_3       ,
    bram_addr_b_5       =>  bram_addr_dma_b_4       ,
    bram_addr_b_6       =>  bram_addr_dma_b_5       ,
    bram_addr_b_7       =>  bram_addr_dma_b_6       ,
                                                    
    bram_clk_a_0        =>  bram_clk_pio_a          ,
    bram_clk_b_0        =>  bram_clk_pio_b          ,
    bram_clk_b_1        =>  bram_clk_dma_b_0        ,
    bram_clk_b_2        =>  bram_clk_dma_b_1        ,
    bram_clk_b_3        =>  bram_clk_dma_b_2        ,
    bram_clk_b_4        =>  bram_clk_dma_b_3        ,
    bram_clk_b_5        =>  bram_clk_dma_b_4        ,
    bram_clk_b_6        =>  bram_clk_dma_b_5        ,
    bram_clk_b_7        =>  bram_clk_dma_b_6        ,
    bram_en_a_0         =>  bram_en_pio_a           ,
    bram_en_b_0         =>  bram_en_pio_b           ,
    bram_en_b_1         =>  bram_en_dma_b_0         ,
    bram_en_b_2         =>  bram_en_dma_b_1         ,
    bram_en_b_3         =>  bram_en_dma_b_2         ,
    bram_en_b_4         =>  bram_en_dma_b_3         ,
    bram_en_b_5         =>  bram_en_dma_b_4         ,
    bram_en_b_6         =>  bram_en_dma_b_5         ,
    bram_en_b_7         =>  bram_en_dma_b_6         ,
                                                    
    bram_rddata_a_0     =>  bram_rddata_pio_a       ,
    bram_rddata_b_0     =>  bram_rddata_pio_b       ,
    bram_rddata_b_1     =>  bram_rddata_dma_b_0     ,
    bram_rddata_b_2     =>  bram_rddata_dma_b_1     ,
    bram_rddata_b_3     =>  bram_rddata_dma_b_2     ,
    bram_rddata_b_4     =>  bram_rddata_dma_b_3     ,
    bram_rddata_b_5     =>  bram_rddata_dma_b_4     ,
    bram_rddata_b_6     =>  bram_rddata_dma_b_5     ,
    bram_rddata_b_7     =>  bram_rddata_dma_b_6     ,
                                                    
    bram_rst_a_0        =>  bram_rst_pio_a          ,
    bram_rst_b_0        =>  bram_rst_pio_b          ,
    bram_rst_b_1        =>  bram_rst_dma_b_0        ,
    bram_rst_b_2        =>  bram_rst_dma_b_1        ,
    bram_rst_b_3        =>  bram_rst_dma_b_2        ,
    bram_rst_b_4        =>  bram_rst_dma_b_3        ,
    bram_rst_b_5        =>  bram_rst_dma_b_4        ,
    bram_rst_b_6        =>  bram_rst_dma_b_5        ,
    bram_rst_b_7        =>  bram_rst_dma_b_6        ,
    bram_we_a_0         =>  bram_we_pio_a           ,
    bram_we_b_0         =>  bram_we_pio_b           ,
    bram_we_b_1         =>  bram_we_dma_b_0         ,
    bram_we_b_2         =>  bram_we_dma_b_1         ,
    bram_we_b_3         =>  bram_we_dma_b_2         ,
    bram_we_b_4         =>  bram_we_dma_b_3         ,
    bram_we_b_5         =>  bram_we_dma_b_4         ,
    bram_we_b_6         =>  bram_we_dma_b_5         ,
    bram_we_b_7         =>  bram_we_dma_b_6         ,
    bram_wrdata_a_0     =>  bram_wrdata_pio_a       ,
    bram_wrdata_b_0     =>  bram_wrdata_pio_b       ,
    bram_wrdata_b_1     =>  bram_wrdata_dma_b_0     ,
    bram_wrdata_b_2     =>  bram_wrdata_dma_b_1     ,
    bram_wrdata_b_3     =>  bram_wrdata_dma_b_2     ,
    bram_wrdata_b_4     =>  bram_wrdata_dma_b_3     ,
    bram_wrdata_b_5     =>  bram_wrdata_dma_b_4     ,
    bram_wrdata_b_6     =>  bram_wrdata_dma_b_5     ,
    bram_wrdata_b_7     =>  bram_wrdata_dma_b_6     ,

    pcie_mgt_0_rxn      =>       pcie_7x_mgt_rtl_0_rxn(7 downto 0), 
    pcie_mgt_0_rxp      =>       pcie_7x_mgt_rtl_0_rxp(7 downto 0), 
    pcie_mgt_0_txn      =>       pcie_7x_mgt_rtl_0_txn(7 downto 0), 
    pcie_mgt_0_txp      =>       pcie_7x_mgt_rtl_0_txp(7 downto 0), 
    sys_rst_n_0         =>       sys_rst_n_0,
    CLK_IN_D_0_clk_n    =>       pcie_ref_clk_n,
    CLK_IN_D_0_clk_p    =>       pcie_ref_clk_p,
    user_lnk_up_0       =>       user_lnk_up_0,
    usr_irq_ack_0       =>       usr_irq_ack_0,
    usr_irq_req_0       =>       irq_xdma       

  );
CA53_RXD <= CA53_EXTERNAL_RXD;

reset_rtl_0 <= mmcm_locked;

process(clk_128M,pl_rsten)
begin
    if clk_128M'event and clk_128M = '1' then
        gps_1PPS <= pps1_sync;
    end if;
end process;

process(clk_128M,pl_rsten)
begin
    if pl_rsten = '0' then
        gps_pps_counter <= (others => '0');
    elsif clk_128M'event and clk_128M = '1' then
        if gps_pps_counter_reset = '0' then
            gps_pps_counter <= (others => '0');
        elsif gps_1PPS = '0' then
            gps_pps_counter <= (others => '0');
        else
            gps_pps_counter <= gps_pps_counter + 1;
        end if;
    end if;
end process;

U1 : ps_interface_0 
port map ( 
                            clk   => clk_100M_ps,
                            rsten => resetn_ps_100M,
                            ----    EMC interface    ----
                            ps_oen => mem_oen_0(0),
                            ps_wen => mem_wen_0,
                            ps_cen => mem_cen_0(0),
                            ps_din => mem_dq_i_0,
                            ps_dout => mem_dq_o_0,
                            ps_addr => mem_a_0(11 downto 0),
                            ----    PS reset    ----
                            global_rst => global_rst,
                            ----    SI5341相关    ----
                            flag_SI5341_config => flag_SI5341_config,
                            reg_SI5341_config_wrdata => reg_SI5341_config_wrdata,
                            reg_SI5341_config_rddata => reg_SI5341_config_rddata,
                            reg_SPI_SI5341_config_state => reg_SPI_SI5341_config_state,
                            SI5341_locked => SI5341_locked,
                            mmcm_locked => mmcm_locked        
);

U2 : ps_interface_1 
Port map (
		reset		=> pl_rsten,
		clk_128M   	=> clk_128M,
		resetn_ps 	=> pl_rsten,
		clk_100M   	=> clk_128M,
		----    EMC interface    ----
		ps_oen => mem_oen_1(0),
        ps_wen => mem_wen_1,
        ps_cen => mem_cen_1(0),
        ps_din => mem_dq_i_1,
        ps_dout => mem_dq_o_1,
        ps_addr => mem_a_1(11 downto 0),
--		----    AD9520相关    ----
--		flag_AD9520_config          => flag_AD9520_config,
--		reg_AD9520_config_wrdata    => reg_AD9520_config_wrdata,
--        reset_PLL      => resetn_PLL ,
--		reg_AD9520_config_rddata    => reg_AD9520_config_rddata,
--		reg_SPI_AD9520_config_state => reg_SPI_AD9520_config_state,         

--		----    AD9680相关    ----
--		flag_AD9680_config          => flag_AD9680_config,   
--		reg_AD9680_config_wrdata    => reg_AD9680_config_wrdata,   
--		reg_AD9680_config_rddata    => reg_AD9680_config_rddata,   
--		reg_SPI_AD9680_config_state => reg_SPI_AD9680_config_state,   


--		jesd_reset					=> jesd_reset,
--		jesd_reset_n				=> jesd_reset_n,
--		ps_ReSync					=> ps_ReSync,
--		data_valid					=> data_valid,
----		data_valid_k7               => data_valid_in,
--		----    AD9739相关    ----
--		flag_AD9739_config          => flag_AD9739_config,   
--		reg_AD9739_config_wrdata    => reg_AD9739_config_wrdata,   
--		reg_AD9739_config_rddata    => reg_AD9739_config_rddata,   
--		reg_SPI_AD9739_config_state => reg_SPI_AD9739_config_state,

--		----    AD5XXX相关    ----  
--		flag_AD5XXX_config 			=>	flag_AD5XXX_config,
--		reg_AD5XXX_wrdata 			=>	reg_AD5XXX_wrdata,
--		reg_AD5XXX_mode 			=>	reg_AD5XXX_mode,
--        reg_LDAC                    =>  reg_LDAC,
--		agc_arm_ctrl_mode           => agc_arm_ctrl_mode,
--		agc_arm_ctrl_12              => agc_arm_ctrl_12,
--		agc_arm_ctrl_DVGA1        => agc_arm_ctrl_DVGA1,
--		agc_arm_ctrl_DVGA2        => agc_arm_ctrl_DVGA2,
--		agc_arm_ctrl_34              => agc_arm_ctrl_34,
--		agc_arm_ctrl_DVGA3        => agc_arm_ctrl_DVGA3,
--		agc_arm_ctrl_DVGA4        => agc_arm_ctrl_DVGA4,
		
		contrl_8506 => contrl_8506,

       	----   PLL   ----
		flag_RF_PLL_TxRx_configuration => flag_RF_PLL_TxRx_configuration,
		flag_RF_PLL_CLK_configuration => flag_RF_PLL_CLK_configuration,
		data_RF_PLL_configuration => data_RF_PLL_configuration,

		
		----	ARM写	----

		reg_initial_reset => reg_initial_reset,
		reg_tx_mode => reg_tx_mode,
		reg_tx_mode_para => reg_tx_mode_para,

		ram_PN_sync_we => ram_PN_sync_we,
		ram_PN_sync_din => ram_PN_sync_din,
		ram_PN_PAn_we => ram_PN_PAn_we,
		ram_PN_PAn_din => ram_PN_PAn_din,
		ram_PN_scramble_we => ram_PN_scramble_we,
		ram_PN_scramble_din => ram_PN_scramble_din,
		ram_PN_interleave_we => ram_PN_interleave_we,
		ram_PN_interleave_din => ram_PN_interleave_din,
		ram_tx_interface_buffer_we => ram_tx_interface_buffer_we,
		ram_tx_interface_buffer_din => ram_tx_interface_buffer_din,
		ram_tx_interface_buffer_din_type => ram_tx_interface_buffer_din_type,
		ram_tx_interface_buffer_we_1 => ram_tx_interface_buffer_we_1,
		ram_tx_interface_buffer_din_1 => ram_tx_interface_buffer_din_1,
		ram_tx_interface_buffer_din_type_1 => ram_tx_interface_buffer_din_type_1,
		ram_tx_interface_buffer_we_2 => ram_tx_interface_buffer_we_2,
		ram_tx_interface_buffer_din_2 => ram_tx_interface_buffer_din_2,
		ram_tx_interface_buffer_din_type_2 => ram_tx_interface_buffer_din_type_2,
		
		packet_time_interval => packet_time_interval,
		pulse_framer_length => pulse_framer_length,
		flag_rd_arm_onepacket => flag_rd_arm_onepacket,
		flag_rd_arm_oneint => flag_rd_arm_oneint,

		flag_rd_srio_onepacket => flag_rd_srio_onepacket,
		flag_rd_srio_oneint => flag_rd_srio_oneint,
        falg_irq_k_end => falg_irq_end,	
		falg_irq_k_end_k => falg_irq_end_k,
		flag_tx_nread  => flag_tx_nread,
		Antenna_switch_local => Antenna_switch_local,
		----	ARM读	----
		reg_tx_interface_buffer_num_0  => reg_tx_interface_buffer_num_0,
		reg_tx_interface_buffer_num_1  => reg_tx_interface_buffer_num_1,
		reg_tx_interface_buffer_num_2  => reg_tx_interface_buffer_num_2,
		flag_monitor_cancel => flag_monitor_cancel,
		reg_state => reg_state,
		reg_monitor => reg_monitor,
		flag_rd_arm_onetime => flag_rd_arm_onetime,
		dout_rx_arm_interface => dout_rx_arm_interface,
		num_buffer_rx_arm_interface => num_buffer_rx_arm_interface,
--        jesd_ByteIsAligned => ByteIsAligned,
        
        flag_rd_srio_onetime => flag_rd_srio_onetime,
		dout_rx_srio_interface => dout_rx_srio_interface,
		num_buffer_rx_srio_interface => num_buffer_rx_srio_interface,
		
		MEASURED_TEMP_ZYNQ => MEASURED_TEMP_ZYNQ(15 downto 4),
--		MEASURED_TEMP_K7 => MEASURED_TEMP_K7,

		
--		----   K7 版本号    ----
--		Version_K7  =>  Version_K7,
--		----   k7 FPGA加载相关   ----
--		PROGRAM_CONFIG_FPGA2 => PROGRAM_CONFIG_FPGA2,
--		DONE_CONFIG_FPGA2 => DONE_CONFIG_FPGA2,
		reset_time => reset_time,
		
		
		LNA_switch_hand_1 => LNA_switch_hand_1,
        LNA_switch_hand_2 => LNA_switch_hand_2,
        PA_switch_hand => PA_switch_hand,
		-----  k7读取寄存器标志   -----
		
		falg_rx_resp                 =>  falg_rx_resp,
		rx_resp_data                 =>  rx_resp_data,
		falg_rd_respdata_complete    =>  falg_rd_respdata_complete,
		
		
		----   配置接收参数   ---
		arm_config_sync_head_array => arm_config_sync_head_array,
		arm_config_sync_tail_array => arm_config_sync_tail_array,
		arm_config_matrix_pattern_freq_x1 => arm_config_matrix_pattern_freq_x1,
		arm_config_matrix_pattern_freq_x2 => arm_config_matrix_pattern_freq_x2,
		arm_config_matrix_pattern_freq_x3 => arm_config_matrix_pattern_freq_x3,
		arm_config_matrix_pattern_freq_x4 => arm_config_matrix_pattern_freq_x4,
		arm_config_addr_offset_x1 => arm_config_addr_offset_x1,
		arm_config_addr_offset_x2 => arm_config_addr_offset_x2,
		arm_config_addr_offset_x3 => arm_config_addr_offset_x3,
		arm_config_addr_offset_x4 => arm_config_addr_offset_x4,
		arm_config_PN_deinterleave_array => arm_config_PN_deinterleave_array,
		arm_config_rx_rate_mode => arm_config_rx_rate_mode,
		arm_config_rx_filter_sel => arm_config_rx_filter_sel,

		ram_PN_descramble_we => ram_PN_descramble_we,
		ram_PN_descramble_din => ram_PN_descramble_din,

		threshold_pulse_num => threshold_pulse_num,
		threshold_sync_xcorr => threshold_sync_xcorr,
		rdy_rx => rdy_rx,
		flag_start_rx => flag_start_rx,
		point_test_rx => point_test_rx,
		
		channel_busy_threshold => channel_busy_threshold,
		channel_load => channel_load,
		channel_capure_threshold => channel_capure_threshold,

		dds_clr => dds_clr,
		dds_freq_para_local => dds_freq_para_local,
		counter_switch => counter_switch,
		counter_2M => counter_2M,
		counter_500k => counter_64k,
		----   K7接收参数     ----
		flag_agc_arm_ctrl_mode           =>  flag_agc_arm_ctrl_mode          ,
		sync_bit_pre_rx_s                =>  sync_bit_pre_rx_s               ,
		flag_wr_sync_bit_pre             =>  flag_wr_sync_bit_pre            ,
		sync_bit_post_rx_s               =>  sync_bit_post_rx_s              ,
		flag_wr_sync_bit_post            =>  flag_wr_sync_bit_post           ,
										
		flag_pattern_freq_rx_x1          =>  flag_pattern_freq_rx_x1         ,
		flag_pattern_freq_rx_x2          =>  flag_pattern_freq_rx_x2         ,
		flag_pattern_freq_rx_x3          =>  flag_pattern_freq_rx_x3         ,
		flag_pattern_freq_rx_x4          =>  flag_pattern_freq_rx_x4         ,
		time_hopping_rx_x1_s             =>  time_hopping_rx_x1_s            ,
		flag_time_hoppong_rx_x1          =>  flag_time_hoppong_rx_x1         ,
		time_hopping_rx_x2_s             =>  time_hopping_rx_x2_s            ,
		flag_time_hoppong_rx_x2          =>  flag_time_hoppong_rx_x2         ,
		time_hopping_rx_x3_s             =>  time_hopping_rx_x3_s            ,
		flag_time_hoppong_rx_x3          =>  flag_time_hoppong_rx_x3         ,
		time_hopping_rx_x4_s             =>  time_hopping_rx_x4_s            ,
		flag_time_hoppong_rx_x4          =>  flag_time_hoppong_rx_x4         ,
		PN_deinterleave_s                =>  PN_deinterleave_s               ,
		flag_PN_deinterleave             =>  flag_PN_deinterleave            ,
		flag_arm_config_rx_rate_mode_sel =>  flag_arm_config_rx_rate_mode_sel,
		flag_ram_PN_descramble_din       =>  flag_ram_PN_descramble_din      ,
		flag_threshold_pulse_num         =>  flag_threshold_pulse_num        ,
		flag_threshold_sync_xcorr        =>  flag_threshold_sync_xcorr       ,
		flag_rdy_rx                      =>  flag_rdy_rx                     ,
										
		flag_point_test_rx               =>  flag_point_test_rx              ,
		flag_channel_busy_threshold      =>  flag_channel_busy_threshold     ,
		flag_channel_capure_threshold    =>  flag_channel_capure_threshold   ,
		flag_Antenna_switch_local        =>  flag_Antenna_switch_local       ,
		flag_jesd_reset_AD2              =>  flag_jesd_reset_AD2             ,

		----	TEST	----	
		arm_config_power_control => TX_POWER,
		arm_config_switch => arm_config_switch,
		----    时间同步发射时间戳    ----
		send_timestamp_2       =>       send_timestamp_2,
		send_timestamp_1       =>       send_timestamp_1,
		send_timestamp_0       =>       send_timestamp_0,
		----  捕获时标计数器数值----
       send_timestamp_cor_2                         =>   send_timestamp_cor_2,
       send_timestamp_cor_1                         =>   send_timestamp_cor_1,
       send_timestamp_cor_0                         =>   send_timestamp_cor_0,
    -----  捕获时 时标计数器周期新旧值标志-----
       flag_send_timestamp_cor                          =>   flag_send_timestamp_cor,
		
		 ---- 功率检测模式  -----
		agc_control_mode   => agc_control_mode,
		---- agc_control -----
		agc_arm_ctrl_mode   => agc_arm_ctrl_mode,
		agc_arm_ctrl_12   => agc_arm_ctrl_12,
		flag_agc_arm_ctrl_DVGA4 => flag_agc_arm_ctrl_DVGA4 ,
		agc_arm_ctrl_DVGA4   => agc_arm_ctrl_DVGA4,
		THRESHOLD_WIDTH   =>  THRESHOLD_WIDTH,
        THRESHOLD_INSIDE  =>  THRESHOLD_INSIDE,
        THRESHOLD_CENTER  =>  THRESHOLD_CENTER,
        RESPONSE_TIME		=>   RESPONSE_TIME,
		----------------------------数字衰减----------------
        shift_config_value => shift_config_value ,
        shift_din_value => shift_din_value,
		----  发射时间戳更新标志  ----
        flag_tx_time_renew         =>    flag_tx_time_renew,
        ----  发射时间戳读取标志  ----
        flag_tx_timestamp_read     =>    flag_tx_timestamp_read,
        offset_time_2              =>    offset_time_2         ,
        offset_time_1              =>    offset_time_1         ,
        offset_time_0              =>    offset_time_0         ,
        flag_offset_time_adjust    =>    flag_offset_time_adjust,
        offset_time_2_k7              =>    offset_time_2_k7         ,
        offset_time_1_k7              =>    offset_time_1_k7         ,
        offset_time_0_k7              =>    offset_time_0_k7         ,
        flag_offset_time_adjust_k7    =>    flag_offset_time_adjust_k7,
		----    物理层时间上传    ----
	    reg_phy_time               =>    reg_phy_time,
--        STATUS_ADHOC  =>  STATUS_ADHOC,
		----jesd配置
		jesd_ila           =>  jesd_ila           ,
		flag_jesd_ila      =>  flag_jesd_ila      ,
		jesd_src           =>  jesd_src           ,
		flag_jesd_src      =>  flag_jesd_src      ,
		jesd_mod           =>  jesd_mod           ,
		flag_jesd_mod      =>  flag_jesd_mod      ,
		jesd_f             =>  jesd_f             ,
		flag_jesd_f        =>  flag_jesd_f        ,
		jesd_k             =>  jesd_k             ,
		flag_jesd_k        =>  flag_jesd_k        ,
		jesd_lanes         =>  jesd_lanes         ,
		flag_jesd_lanes    =>  flag_jesd_lanes    ,
		jesd_subclass      =>  jesd_subclass      ,
		flag_jesd_subclass =>  flag_jesd_subclass ,
		jesd_delay         =>  jesd_delay         ,
		flag_jesd_delay    =>  flag_jesd_delay    ,
		jesd_erro          =>  jesd_erro          ,
		flag_jesd_erro     =>  flag_jesd_erro     ,
		jesd_erroo         =>  jesd_erroo        ,
		flag_jesd_erroo    =>  flag_jesd_erroo   ,
		
		EN_timestamp_cor => EN_timestamp_cor,
        flag_timestamp_cor => flag_timestamp_cor,
        value_timestamp_cor => value_timestamp_cor,
        polarity_cor => polarity_cor,
        times_timestamp_cor => times_timestamp_cor,
        
        doppler_freq => doppler_freq ,
        doppler_freq_init0 => doppler_freq_init0,
        doppler_freq_init1 => doppler_freq_init1,
        doppler_freq_init2 => doppler_freq_init2,
        doppler_freq_init3 => doppler_freq_init3,
        doppler_freq_init4 => doppler_freq_init4,
        doppler_freq_init5 => doppler_freq_init5,
        doppler_freq_init6 => doppler_freq_init6,
        doppler_freq_init7 => doppler_freq_init7,
        pl_mod => pl_mod,
        board_mod => board_mod,
        data_en => data_en ,
        work_mod => work_mod,
        wave_mod => wave_mod,
        PA_switch_ps => PA_switch_ps,
        LNA_switch_ps => LNA_switch_ps,
        T_R_TTL_ps => T_R_TTL_ps,
        
        SW_R0_in_ps   => SW_R0_in_ps  ,
        SW_R1_in_ps   => SW_R1_in_ps  ,
        SW_R2_in_ps   => SW_R2_in_ps  ,
        SW_T_in_ps    => SW_T_in_ps   ,
        SEL0_TX_in_ps => SEL0_TX_in_ps,
        SEL1_TX_in_ps => SEL1_TX_in_ps,
        R0_C0_ps   => R0_C0_ps  ,
        R0_C1_ps   => R0_C1_ps  ,
        R0_C2_ps   => R0_C2_ps  ,
        R0_C3_ps   => R0_C3_ps  ,
        R0_C4_ps   => R0_C4_ps  ,
        R0_C5_ps   => R0_C5_ps  ,
        R1_C0_ps   => R1_C0_ps  ,
        R1_C1_ps   => R1_C1_ps  ,
        R1_C2_ps   => R1_C2_ps  ,
        R1_C3_ps   => R1_C3_ps  ,
        R1_C4_ps   => R1_C4_ps  ,
        R1_C5_ps   => R1_C5_ps  ,
        R2_C0_ps   => R2_C0_ps  ,
        R2_C1_ps   => R2_C1_ps  ,
        R2_C2_ps   => R2_C2_ps  ,
        R2_C3_ps   => R2_C3_ps  ,
        R2_C4_ps   => R2_C4_ps  ,
        R2_C5_ps   => R2_C5_ps  ,
        T_C0_ps    => T_C0_ps   ,
        T_C1_ps    => T_C1_ps   ,
        T_C2_ps    => T_C2_ps   ,
        T_C3_ps    => T_C3_ps   ,
        T_C4_ps    => T_C4_ps   ,
        T_C5_ps    => T_C5_ps   ,
        initial_complete_state  =>  initial_complete_state   ,
        ---  dds配置 (100M输出)  ----        
        flag_10M_start           =>   flag_10M_start          ,                        
        s_axis_phase_inc         =>   s_axis_phase_inc        ,   
        s_axis_phase_offset_0    =>   s_axis_phase_offset_0   ,
        s_axis_phase_offset_1    =>   s_axis_phase_offset_1   ,
        s_axis_phase_offset_2    =>   s_axis_phase_offset_2   ,
        s_axis_phase_offset_3    =>   s_axis_phase_offset_3   ,
        s_axis_phase_offset_4    =>   s_axis_phase_offset_4   ,
        s_axis_phase_offset_5    =>   s_axis_phase_offset_5   ,
        s_axis_phase_offset_6    =>   s_axis_phase_offset_6   ,
        s_axis_phase_offset_7    =>   s_axis_phase_offset_7   ,
        -- PS 读标志 ----          
        flag_lock_reg_PS_read_tx  => flag_lock_reg_PS_read_tx,
        flag_lock_reg_PS_read_rx  => flag_lock_reg_PS_read_rx ,
        EN_time_hopping      => EN_time_hopping,
        ----  定频模式切换与选择   ----
        flag_freq_hopping_control  => flag_freq_hopping_control,           
        freq_hopping_select     => freq_hopping_select,
         ---------灯-------------------------             
        gpio_warning_internal      => gpio_warning_internal  ,
        gpio_power_internal        => gpio_power_internal    ,
        
        
        
        
        
        --------------------------TDMA控制信号------------------------------
        speed_control => speed_control,
        EN_timebase => EN_timebase,
        num_frame_timeslot => num_frame_timeslot,
        num_preframe_timeslot => num_preframe_timeslot,    
        num_payloadframe_timeslot => num_payloadframe_timeslot,
        num_timeslot  => num_timeslot,
        we_RAM_timeslot_confiuration => we_RAM_timeslot_confiuration,
        din_RAM_timeslot_confiuration => din_RAM_timeslot_confiuration,
        flag_timeslot_adj => flag_timeslot_adj,
        value_timeslot_adj => value_timeslot_adj,
        state_timeslot_adj => state_timeslot_adj,
        length_mod             => length_mod    ,
        length_mod_offset     => length_mod_offset             ,
        TDMA_SPMA_switch     =>  TDMA_SPMA_switch   ,
        
        ----  GPS使能   ----
        en_gps  =>  en_gps,
        flag_times_timestamp_cor_read => flag_times_timestamp_cor_read ,
        
        
        irq1_valid           =>  irq_fft_valid     ,
        fft_bram_reset       =>  fft_bram_reset ,
        
        fft_data             =>  fft_bram_rddata ,
        flag_fft_bram_addrb  =>  flag_fft_bram_addrb,
        
        reset_DDS_fft       =>  reset_DDS_fft   ,
        phase_PINC_fft      =>  phase_PINC_fft  ,
        phase_POFF_0_fft    =>  phase_POFF_0_fft,
        phase_POFF_1_fft    =>  phase_POFF_1_fft,
        phase_POFF_2_fft    =>  phase_POFF_2_fft,
        phase_POFF_3_fft    =>  phase_POFF_3_fft,
        phase_POFF_4_fft    =>  phase_POFF_4_fft,
        phase_POFF_5_fft    =>  phase_POFF_5_fft,
        phase_POFF_6_fft    =>  phase_POFF_6_fft,
        phase_POFF_7_fft    =>  phase_POFF_7_fft,
        
        reg_fft_tap_select  => reg_fft_tap_select   ,
        num_valid           => num_valid            ,
        addup_N             => addup_N              ,
        flag_fft_rdy        => flag_fft_rdy         ,
        fft_stop            => fft_stop             ,
        shift_bits_fft      => shift_bits_fft       ,
        
        --- wideband ---
        flag_rdy_wideband   => flag_rdy_wideband    ,
        flag_xdma_test_rdy  => flag_xdma_test_rdy   ,
        xdma_stop           => xdma_stop            ,
         ---------定频模式任意频率相位字配置---------- 
        configurable_freq_hopping_phase_inc            => configurable_freq_hopping_phase_inc         , 
        configurable_freq_hopping_phase_offset_0       => configurable_freq_hopping_phase_offset_0    ,
        configurable_freq_hopping_phase_offset_1       => configurable_freq_hopping_phase_offset_1    ,
        configurable_freq_hopping_phase_offset_2       => configurable_freq_hopping_phase_offset_2    ,
        configurable_freq_hopping_phase_offset_3       => configurable_freq_hopping_phase_offset_3    ,
        configurable_freq_hopping_phase_offset_4       => configurable_freq_hopping_phase_offset_4    ,
        configurable_freq_hopping_phase_offset_5       => configurable_freq_hopping_phase_offset_5    ,
        configurable_freq_hopping_phase_offset_6       => configurable_freq_hopping_phase_offset_6    ,
        configurable_freq_hopping_phase_offset_7       => configurable_freq_hopping_phase_offset_7    ,
        ----    PCIe TX (tx_top) PS 配置    ----
        tx_rstn_ps       => tx_rstn_ps,
        ram_en_ps        => ram_en_ps,
        bpsk_en_ps       => bpsk_en_ps,
        qpsk_en_ps       => qpsk_en_ps,
        rate_sel_ps      => rate_sel_ps,
        dds_rstn_ps      => dds_rstn_ps,
        dds_pinc_bpsk_ps => dds_pinc_bpsk_ps,
        dds_pinc_qpsk_ps => dds_pinc_qpsk_ps,
        dds_poff_bpsk_ps => dds_poff_bpsk_ps,
        dds_poff_qpsk_ps => dds_poff_qpsk_ps,
        atten_bpsk_ps => atten_bpsk_ps,
        atten_qpsk_ps => atten_qpsk_ps,
        ram_w_en_bpsk_ps    => ram_w_en_bpsk_ps,
        ram_w_addr_bpsk_ps  => ram_w_addr_bpsk_ps,
        ram_w_data_bpsk_ps  => ram_w_data_bpsk_ps,
        ram_w_en_qpsk_ps    => ram_w_en_qpsk_ps,
        ram_w_addr_qpsk_ps  => ram_w_addr_qpsk_ps,
        ram_w_data_qpsk_ps  => ram_w_data_qpsk_ps,
        bpsk_sym_num_ps     => bpsk_sym_num_ps,
        bpsk_single_shot_ps => bpsk_single_shot_ps
);

---------------灯开关---------------------
gpio_warning  <=    gpio_warning_internal;
gpio_power    <=    gpio_power_internal  ;
-----------射频信号控制 ------------
process(pl_rsten,clk_128M)
begin
	if pl_rsten = '0' then
--		PA_TTL_in   <= '0' ;
--		T_R_TTL_in  <= '0' ; --"0"发射   "1"接收  新"1"发射   "0"接收
--		LNA_TTL_in  <= '1' ;
        SW_R0_in   <= '1' ; 
        SW_R1_in   <= '1' ;
        SW_R2_in   <= '1' ;
        SW_T_in    <= '0' ;
        SEL0_TX_in <= '0' ; -- SEL0_TX_in,SEL1_TX_in共同控制发射天线，00天线1，10天线2，11天线3
        SEL1_TX_in <= '0' ;
        
        R0_C0_in    <= '0';
        R0_C1_in    <= '0';
        R0_C2_in    <= '0';
        R0_C3_in    <= '0';
        R0_C4_in    <= '0';
        R0_C5_in    <= '0';
        R1_C0_in    <= '0';
        R1_C1_in    <= '0';
        R1_C2_in    <= '0';
        R1_C3_in    <= '0';
        R1_C4_in    <= '0';
        R1_C5_in    <= '0';
		R2_C0_in    <= '0' ;
        R2_C1_in    <= '0' ;
        R2_C2_in    <= '0' ;
        R2_C3_in    <= '0' ;
        R2_C4_in    <= '0' ;
        R2_C5_in    <= '0' ;
        T_C0_in     <= '1' ;
        T_C1_in     <= '1' ;
        T_C2_in     <= '1' ;
        T_C3_in     <= '1' ;
        T_C4_in     <= '1' ;
        T_C5_in     <= '1' ;
        
	elsif clk_128M'event and clk_128M = '1' then
		if work_mod = 0 then   ---正常工作自动模式
--            PA_TTL_in   <= PA_switch;
--            T_R_TTL_in  <= T_R_TTL_switch;
--            PA_TTL_in   <= PA_switch_local;
--            PA_TTL_in   <= PA_switch_delay;
--            T_R_TTL_in  <= TX_switch_local;
--            LNA_TTL_in  <= LNA_switch_local;
            SW_R0_in    <= RX_SW_R0        ;
            SW_R1_in    <= RX_SW_R1        ;
            SW_R2_in    <= RX_SW_R2        ;
            SW_T_in     <= TX_SW_T         ;
            SEL0_TX_in  <= SEL0_TX_in_ps   ; 
            SEL1_TX_in  <= SEL1_TX_in_ps   ; 
            R2_C0_in    <= DVGA_ctrl_4(0) ;                 
            R2_C1_in    <= DVGA_ctrl_4(1) ;
            R2_C2_in    <= DVGA_ctrl_4(2) ;
            R2_C3_in    <= DVGA_ctrl_4(3) ;
            R2_C4_in    <= DVGA_ctrl_4(4) ;
            R2_C5_in    <= DVGA_ctrl_4(5) ;
            T_C0_in     <= T_C0_ps         ;
            T_C1_in     <= T_C1_ps         ;
            T_C2_in     <= T_C2_ps         ;
            T_C3_in     <= T_C3_ps         ;
            T_C4_in     <= T_C4_ps         ;
            T_C5_in     <= T_C5_ps         ;
            
            
        elsif work_mod = 1 then   ---正常工作手动模式
--            PA_TTL_in   <= PA_switch_ps;
--            T_R_TTL_in  <= T_R_TTL_ps;
--            LNA_TTL_in  <= LNA_switch_ps;
            SW_R0_in      <= SW_R0_in_ps     ;
            SW_R1_in      <= SW_R1_in_ps     ;
            SW_R2_in      <= SW_R2_in_ps     ;
            SW_T_in       <= SW_T_in_ps      ;
            SEL0_TX_in    <= SEL0_TX_in_ps   ;
            SEL1_TX_in    <= SEL1_TX_in_ps   ;
            R0_C0_in      <= R0_C0_ps        ;
            R0_C1_in      <= R0_C1_ps        ;
            R0_C2_in      <= R0_C2_ps        ;
            R0_C3_in      <= R0_C3_ps        ;
            R0_C4_in      <= R0_C4_ps        ;
            R0_C5_in      <= R0_C5_ps        ;
            R1_C0_in      <= R1_C0_ps        ;
            R1_C1_in      <= R1_C1_ps        ;
            R1_C2_in      <= R1_C2_ps        ;
            R1_C3_in      <= R1_C3_ps        ;
            R1_C4_in      <= R1_C4_ps        ;
            R1_C5_in      <= R1_C5_ps        ;
            R2_C0_in      <= R2_C0_ps        ;
            R2_C1_in      <= R2_C1_ps        ;
            R2_C2_in      <= R2_C2_ps        ;
            R2_C3_in      <= R2_C3_ps        ;
            R2_C4_in      <= R2_C4_ps        ;
            R2_C5_in      <= R2_C5_ps        ;
            T_C0_in       <= T_C0_ps         ;
            T_C1_in       <= T_C1_ps         ;
            T_C2_in       <= T_C2_ps         ;
            T_C3_in       <= T_C3_ps         ;
            T_C4_in       <= T_C4_ps         ;
            T_C5_in       <= T_C5_ps         ;
            
            
--        elsif work_mod = 2 then    --接收测试模式
--		    PA_TTL_in   <= '0';
--            T_R_TTL_in  <= '0';
--            R2_C2_in    <= DVGA_ctrl_4(0) ; 
--            R2_C4_in    <= DVGA_ctrl_4(1) ; 
--            R2_C8_in    <= DVGA_ctrl_4(2) ; 
--            R2_C16_in   <= DVGA_ctrl_4(3) ; 
--            R2_C30_in   <= DVGA_ctrl_4(4) ;     
--		elsif work_mod = 3 then    ---手动控载波模式
--            PA_TTL_in   <= PA_switch_ps;
--            T_R_TTL_in  <= T_R_TTL_ps;
--            R2_C30_in   <= R2_C30_ps ;
--            R2_C2_in    <= R2_C2_ps  ;
--            R2_C4_in    <= R2_C4_ps  ;
--            R2_C8_in    <= R2_C8_ps  ;
--            R2_C16_in   <= R2_C16_ps ;
	   end if;
    end if;   
end process; 


--test_PA_TTL_in     <= PA_TTL_in ; 
--test_T_R_TTL_in    <= T_R_TTL_in; 
--test_LNA_TTL_in    <= LNA_TTL_in; 

--PA_TTL   <= PA_TTL_in ;
--T_R_TTL  <= T_R_TTL_in;
--LNA_TTL  <= LNA_TTL_in;
--SW_R0    <= SW_R0_in   ;
--SW_R1    <= SW_R1_in   ;
--SW_R2    <= SW_R2_in   ;
--SW_T     <= SW_T_in    ;
--SEL0_TX  <= SEL0_TX_in ;
--SEL1_TX  <= SEL1_TX_in ;

--R0_C0    <= R0_C0_in  ;
--R0_C1    <= R0_C1_in  ;
--R0_C2    <= R0_C2_in  ;
--R0_C3    <= R0_C3_in  ;
--R0_C4    <= R0_C4_in ;
--R0_C5    <= R0_C5_in ;
--R1_C0    <= R1_C0_in  ;
--R1_C1    <= R1_C1_in  ;
--R1_C2    <= R1_C2_in  ;
--R1_C3    <= R1_C3_in  ;
--R1_C4    <= R1_C4_in ;
--R1_C5    <= R1_C5_in ;
--R2_C0    <= R2_C0_in  ;
--R2_C1    <= R2_C1_in  ;
--R2_C2    <= R2_C2_in  ;
--R2_C3    <= R2_C3_in  ;
--R2_C4    <= R2_C4_in ;
--R2_C5    <= R2_C5_in ;
--T_C0     <= T_C0_in   ;
--T_C1     <= T_C1_in   ;
--T_C2     <= T_C2_in  ; 
--T_C3     <= T_C3_in   ; 
--T_C4     <= T_C4_in   ;
--T_C5     <= T_C5_in  ; 

process(pl_rsten,clk_128M)
begin
	if pl_rsten = '0' then
		en_cnt_gpio_tx   <= '0' ;
	elsif clk_128M'event and clk_128M = '1' then
		if PA_TTL_in  = '1' and cnt_gpio_tx = 0 then
            en_cnt_gpio_tx <=  '1'; 
        elsif  cnt_gpio_tx >= 37500000 then
            en_cnt_gpio_tx  <= '0';
		end if;
	end if;
end process; 

process(pl_rsten,clk_128M)
begin
	if pl_rsten = '0' then
		cnt_gpio_tx   <= (others =>'0') ;
	elsif clk_128M'event and clk_128M = '1' then
		if en_cnt_gpio_tx = '1'  then
            cnt_gpio_tx <= cnt_gpio_tx + 1; 
        else 
            cnt_gpio_tx  <= (others =>'0');
		end if;
	end if;
end process; 

process(pl_rsten,clk_128M)
begin
	if pl_rsten = '0' then
		gpio_tx_internal   <= '0' ;
	elsif clk_128M'event and clk_128M = '1' then
		if cnt_gpio_tx < 37500000 and en_cnt_gpio_tx = '1'  then
            gpio_tx_internal <= '1'; 
        else 
            gpio_tx_internal  <= '0';
		end if;
	end if;
end process; 

process(pl_rsten,clk_128M)
begin
	if pl_rsten = '0' then
		gpio_rx_internal   <= '1' ;
	elsif clk_128M'event and clk_128M = '1' then
		if gpio_tx_internal = '1'  then
            gpio_rx_internal <= '0'; 
        else 
            gpio_rx_internal  <= '1';
		end if;
	end if;
end process; 
gpio_tx <= gpio_tx_internal;
gpio_rx <= gpio_rx_internal;

U_no_name : ila_tx_rx_gpio
PORT MAP (
	clk => clk_128M,



	probe0 => cnt_gpio_tx, 
	probe1(0) => gpio_tx_internal, 
	probe2(0) => gpio_rx_internal, 
	probe3(0) => en_cnt_gpio_tx,
	probe4(0) => PA_TTL_in
);

--clk_observe <= clk_128M;

---------中断控制 ------------
---- 初始化中断
--process(pl_rsten,clk_128M)
--begin
--	if pl_rsten = '0' then
--		gpio_rtl_tri_i_0   <= (others =>'0') ;
--	elsif clk_128M'event and clk_128M = '1' then
--		if initial_complete_state = '1' then
--            gpio_rtl_tri_i_0(0) <= SI5341_locked; 
--            gpio_rtl_tri_i_0(1) <= mmcm_locked;
--        else 
--            gpio_rtl_tri_i_0(0)  <= '0';
--            gpio_rtl_tri_i_0(1)  <= '0';
--		end if;
--	end if;
--end process; 
--- 接收中断
process(pl_rsten,clk_128M)
begin
	if pl_rsten = '0' then
		gpio_rtl_tri_i_1   <= '0' ;
	elsif clk_128M'event and clk_128M = '1' then
        gpio_rtl_tri_i_1 <= int_rx_arm_ZYNQ;
	end if;
end process; 


--U3 : tx_module port map ( 
--   reset => pl_rsten,
--   clk => clk_128M,
----   clk_DAC_500M => clk_DAC_500M,
----   clk_DAC_250M => clk_DAC_250M,
----   clk_DAC_125M => clk_DAC_125M,
----   reset_DAC_interface => reset_DAC_interface,
    
--   ----	PN	----
--   reg_initial => reg_initial_reset(2),
--   ram_PN_sync_we => ram_PN_sync_we,
--   ram_PN_sync_din => ram_PN_sync_din,
--   ram_PN_PAn_we => ram_PN_PAn_we,
--   ram_PN_PAn_din => ram_PN_PAn_din,
--   ram_PN_scramble_we => ram_PN_scramble_we,
--   ram_PN_scramble_din => ram_PN_scramble_din,
--   ram_PN_interleave_we => ram_PN_interleave_we,
--   ram_PN_interleave_din => ram_PN_interleave_din,
    
--   ----	tx	----
--   wave_mod  =>  wave_mod ,
--   data_en   =>  data_en  ,
--   reg_tx_mode => reg_tx_mode,
--   reg_tx_mode_para => reg_tx_mode_para,
--   flag_start_rx => flag_start_rx,
--   flag_start_tx_ila => flag_start_tx_ila,
--   ram_tx_interface_buffer_we => ram_tx_interface_buffer_we,
--   ram_tx_interface_buffer_din => ram_tx_interface_buffer_din,
--   ram_tx_interface_buffer_din_type => ram_tx_interface_buffer_din_type,
--   ram_tx_interface_buffer_we_1 => ram_tx_interface_buffer_we_1 ,
--   ram_tx_interface_buffer_din_1 => ram_tx_interface_buffer_din_1 ,
--   ram_tx_interface_buffer_din_type_1 => ram_tx_interface_buffer_din_type_1 ,
--   ram_tx_interface_buffer_we_2 => ram_tx_interface_buffer_we_2 ,
--   ram_tx_interface_buffer_din_2 => ram_tx_interface_buffer_din_2 ,
--   ram_tx_interface_buffer_din_type_2 => ram_tx_interface_buffer_din_type_2 ,
--   reg_tx_interface_buffer_num_0  => reg_tx_interface_buffer_num_0,
--   reg_tx_interface_buffer_num_1  => reg_tx_interface_buffer_num_1,
--   reg_tx_interface_buffer_num_2  => reg_tx_interface_buffer_num_2,
--   rate_mode => arm_config_rx_rate_mode,
--   packet_time_interval => packet_time_interval,
--   pulse_framer_length => pulse_framer_length,
    
--   ----   频点择优模式   ----
--   dds_clr => dds_clr,
--   dds_freq_para_local => dds_freq_para_local,
    
--   ----	output	----
--   RX_SW_R0  => RX_SW_R0 ,
--   RX_SW_R1  => RX_SW_R1 ,
--   RX_SW_R2  => RX_SW_R2 ,
--   TX_SW_T   => TX_SW_T  ,
--   TX_switch => TX_switch_local,
--   PA_switch => PA_switch_local,
--   PA_switch_delay => PA_switch_delay,
--   LNA_switch => LNA_switch_local,
--   dout_mod_I_0 => dout_mod_I_0 ,   
--   dout_mod_Q_0 => dout_mod_Q_0 ,   
--   dout_mod_I_1 => dout_mod_I_1 ,   
--   dout_mod_Q_1 => dout_mod_Q_1 ,   
--   dout_mod_I_2 => dout_mod_I_2 ,   
--   dout_mod_Q_2 => dout_mod_Q_2 ,
--   dout_mod_I_3 => dout_mod_I_3 ,
--   dout_mod_Q_3 => dout_mod_Q_3 ,
--   dout_mod_I_4 => dout_mod_I_4 ,
--   dout_mod_Q_4 => dout_mod_Q_4 ,
--   dout_mod_I_5 => dout_mod_I_5 ,
--   dout_mod_Q_5 => dout_mod_Q_5 ,
--   dout_mod_I_6 => dout_mod_I_6 ,
--   dout_mod_Q_6 => dout_mod_Q_6 ,
--   dout_mod_I_7 => dout_mod_I_7 ,
--   dout_mod_Q_7 => dout_mod_Q_7 ,
--   shift_config_value => shift_config_value,
----   DAC_DBE_P => DAC_DBE_P,
----   DAC_DBE_N => DAC_DBE_N,  
----   DAC_DBO_P => DAC_DBO_P,
----   DAC_DBO_N => DAC_DBO_N,
----   DAC_DCIP => DAC_DCIP,
----   DAC_DCIN => DAC_DCIN,
   
--   ----  发射天线选择参数  ----
--   Antenna_switch_tx => Antenna_switch_tx,
--	----    时间同步    ----
--   flag_one_packet_tx => flag_one_packet_tx,
--   reg_tx_timesync_type => reg_tx_timesync_type,
   
--   doppler_freq => doppler_freq ,
--   doppler_freq_init0 => doppler_freq_init0,
--   doppler_freq_init1 => doppler_freq_init1,
--   doppler_freq_init2 => doppler_freq_init2,
--   doppler_freq_init3 => doppler_freq_init3,
--   doppler_freq_init4 => doppler_freq_init4,
--   doppler_freq_init5 => doppler_freq_init5,
--   doppler_freq_init6 => doppler_freq_init6,
--   doppler_freq_init7 => doppler_freq_init7,
   
--   bram_addr_a_0     =>  bram_addr_a_0     ,
--   bram_clk_a_0      =>  bram_clk_a_0      ,
--   bram_en_a_0       =>  bram_en_a_0       ,
--   bram_we_a_0       =>  bram_we_a_0       ,
--   bram_wrdata_a_0   =>  bram_wrdata_a_0   ,
--   ----   切换turbo编码方式（1/3，1/6，1/10，1/20）  ----
--   encode_type_tx    =>  encode_type,
   
--   flag_lock_reg_PS_read_tx => flag_lock_reg_PS_read_tx,
--   ----    TDMA时基发射标志   ----

--   flag_timebase_frame_start => flag_timebase_frame_start,
--   flag_timebase_frame_head  => flag_timebase_frame_head,
--   master_or_slave            => master_or_slave                        ,
   
--   ----  定频模式切换与选择   ----
--   flag_freq_hopping_control  => flag_freq_hopping_control,           
--   freq_hopping_select     => freq_hopping_select ,
--     ---------定频模式任意频率相位字配置---------- 
--   configurable_freq_hopping_phase_inc            => configurable_freq_hopping_phase_inc         , 
--   configurable_freq_hopping_phase_offset_0       => configurable_freq_hopping_phase_offset_0    ,
--   configurable_freq_hopping_phase_offset_1       => configurable_freq_hopping_phase_offset_1    ,
--   configurable_freq_hopping_phase_offset_2       => configurable_freq_hopping_phase_offset_2    ,
--   configurable_freq_hopping_phase_offset_3       => configurable_freq_hopping_phase_offset_3    ,
--   configurable_freq_hopping_phase_offset_4       => configurable_freq_hopping_phase_offset_4    ,
--   configurable_freq_hopping_phase_offset_5       => configurable_freq_hopping_phase_offset_5    ,
--   configurable_freq_hopping_phase_offset_6       => configurable_freq_hopping_phase_offset_6    ,
--   configurable_freq_hopping_phase_offset_7       => configurable_freq_hopping_phase_offset_7  

   
   
   
--);
PA_switch_out <= PA_switch_local;

-- 延迟400ns(即51个时钟周期左右)
process(clk_128M, pl_rsten)
begin
    if pl_rsten = '0' then
        sig_delay <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		sig_delay(0) <= PA_switch_delay;
		sig_delay(count_pa_delay-1 downto 1) <= sig_delay(count_pa_delay-2 downto 0);
	end if;	
end process;
PA_switch_delay_400ns <= sig_delay(count_pa_delay-1);



--u_vio_iq : vio_iq
--  PORT MAP (
--    clk => clk_128M,
--    probe_out0(0) => iq_switch
--  );

-- tx_top 256位 iq（RFDC 格式 {q7,i7,...,q0,i0}）-> DAC tile230 s20_axis 接口
s20_axis_tdata_0 <= iq;
-- DAC 数据有效 = bpsk / qpsk 两条并行链各自的数据有效相或
-- （单发跑完、各级滤波器里的数据泄放干净后自动落低）
dac_sig_valid <= bpsk_sig_valid or qpsk_sig_valid;



process(clk_128M, pl_rsten)
begin
    if pl_rsten = '0' then
        SHIFT_BITS <= 1;  
    elsif clk_128M'event and clk_128M = '1' then
        SHIFT_BITS <= conv_integer(shift_din_value);
    end if;
end process;


process(clk_128M, pl_rsten)
    function shift_left_signed(data : std_logic_vector(15 downto 0); n : natural) 
    return std_logic_vector is
    constant WIDTH : natural := 16;
    variable result : std_logic_vector(WIDTH-1 downto 0);
begin
    if n >= WIDTH then
        result := (others => '0');  -- 或者可以用 data(data'high) 填充以保持符号位
    else
        -- 正确左移操作：
--        result := data(WIDTH-1-n downto 0) & (n-1 downto 0 => '0');
        -- 或者等价写法：
         result(WIDTH-1 downto n) := data(WIDTH-1-n downto 0);  -- 高位部分左移
         result(n-1 downto 0) := (others => '0');               -- 低位补0
    end if;
    return result;
end function;
    
begin
    if pl_rsten = '0' then
		din_mod_I_final_0 <= (others => '0');
		din_mod_Q_final_0 <= (others => '0');
		din_mod_I_final_1 <= (others => '0');
		din_mod_Q_final_1 <= (others => '0');
		din_mod_I_final_2 <= (others => '0');
		din_mod_Q_final_2 <= (others => '0');
		din_mod_I_final_3 <= (others => '0');
		din_mod_Q_final_3 <= (others => '0');
		din_mod_I_final_4 <= (others => '0');
		din_mod_Q_final_4 <= (others => '0');
		din_mod_I_final_5 <= (others => '0');
		din_mod_Q_final_5 <= (others => '0');
		din_mod_I_final_6 <= (others => '0');
		din_mod_Q_final_6 <= (others => '0');
		din_mod_I_final_7 <= (others => '0');
		din_mod_Q_final_7 <= (others => '0');
    elsif clk_128M'event and clk_128M = '1' then
        -- 使用函数进行左移（只需修改这里的移位位数）
        din_mod_I_final_0 <= shift_left_signed(m23_axis_tdata_0(15 downto 0)     , SHIFT_BITS);
        din_mod_Q_final_0 <= shift_left_signed(m22_axis_tdata_0(15 downto 0)     , SHIFT_BITS);
        din_mod_I_final_1 <= shift_left_signed(m23_axis_tdata_0(31 downto 16)     , SHIFT_BITS);
        din_mod_Q_final_1 <= shift_left_signed(m22_axis_tdata_0(31 downto 16)     , SHIFT_BITS);
        din_mod_I_final_2 <= shift_left_signed(m23_axis_tdata_0(47 downto 32)     , SHIFT_BITS);
        din_mod_Q_final_2 <= shift_left_signed(m22_axis_tdata_0(47 downto 32)     , SHIFT_BITS);
        din_mod_I_final_3 <= shift_left_signed(m23_axis_tdata_0(63 downto 48)     , SHIFT_BITS);
        din_mod_Q_final_3 <= shift_left_signed(m22_axis_tdata_0(63 downto 48)     , SHIFT_BITS);
        din_mod_I_final_4 <= shift_left_signed(m23_axis_tdata_0(79 downto 64)     , SHIFT_BITS);
        din_mod_Q_final_4 <= shift_left_signed(m22_axis_tdata_0(79 downto 64)     , SHIFT_BITS);
        din_mod_I_final_5 <= shift_left_signed(m23_axis_tdata_0(95 downto 80)     , SHIFT_BITS);
        din_mod_Q_final_5 <= shift_left_signed(m22_axis_tdata_0(95 downto 80)     , SHIFT_BITS);
        din_mod_I_final_6 <= shift_left_signed(m23_axis_tdata_0(111 downto 96)     , SHIFT_BITS);
        din_mod_Q_final_6 <= shift_left_signed(m22_axis_tdata_0(111 downto 96)     , SHIFT_BITS);
        din_mod_I_final_7 <= shift_left_signed(m23_axis_tdata_0(127 downto 112)     , SHIFT_BITS);
        din_mod_Q_final_7 <= shift_left_signed(m22_axis_tdata_0(127 downto 112)     , SHIFT_BITS);
    end if;
end process;

process(pl_rsten,clk_128M)
begin
    if pl_rsten = '0' then
        din_mod_final_0 <= (others => '0');
        din_mod_final_1 <= (others => '0');
        din_mod_final_2 <= (others => '0');
        din_mod_final_3 <= (others => '0');
        din_mod_final_4 <= (others => '0');
        din_mod_final_5 <= (others => '0');
        din_mod_final_6 <= (others => '0');
        din_mod_final_7 <= (others => '0');
    elsif clk_128M'event and clk_128M = '1' then
        din_mod_final_0 <= din_mod_Q_final_0 & din_mod_I_final_0;
        din_mod_final_1 <= din_mod_Q_final_1 & din_mod_I_final_1;
        din_mod_final_2 <= din_mod_Q_final_2 & din_mod_I_final_2;
        din_mod_final_3 <= din_mod_Q_final_3 & din_mod_I_final_3;
        din_mod_final_4 <= din_mod_Q_final_4 & din_mod_I_final_4;
        din_mod_final_5 <= din_mod_Q_final_5 & din_mod_I_final_5;
        din_mod_final_6 <= din_mod_Q_final_6 & din_mod_I_final_6;
        din_mod_final_7 <= din_mod_Q_final_7 & din_mod_I_final_7;
    end if;
end process;

process(pl_rsten,clk_128M)
begin
	if pl_rsten = '0' then
		din_rx_I_0 <= (others => '0');
        din_rx_Q_0 <= (others => '0');
        din_rx_I_1 <= (others => '0');
        din_rx_Q_1 <= (others => '0');
        din_rx_I_2 <= (others => '0');
        din_rx_Q_2 <= (others => '0');
        din_rx_I_3 <= (others => '0');
        din_rx_Q_3 <= (others => '0');
        din_rx_I_4 <= (others => '0');
        din_rx_Q_4 <= (others => '0');
        din_rx_I_5 <= (others => '0');
        din_rx_Q_5 <= (others => '0');
        din_rx_I_6 <= (others => '0');
        din_rx_Q_6 <= (others => '0');
        din_rx_I_7 <= (others => '0');
        din_rx_Q_7 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
        if board_mod = 0 then
            if (work_mod = 0 and PA_switch_delay_400ns = '0') or (work_mod = 1 and SW_T_in_ps = '0') then
                din_rx_I_0 <= din_mod_I_final_0;
                din_rx_Q_0 <= din_mod_Q_final_0;
                din_rx_I_1 <= din_mod_I_final_1;
                din_rx_Q_1 <= din_mod_Q_final_1;
                din_rx_I_2 <= din_mod_I_final_2;
                din_rx_Q_2 <= din_mod_Q_final_2;
                din_rx_I_3 <= din_mod_I_final_3;
                din_rx_Q_3 <= din_mod_Q_final_3;
                din_rx_I_4 <= din_mod_I_final_4; 
                din_rx_Q_4 <= din_mod_Q_final_4; 
                din_rx_I_5 <= din_mod_I_final_5; 
                din_rx_Q_5 <= din_mod_Q_final_5; 
                din_rx_I_6 <= din_mod_I_final_6; 
                din_rx_Q_6 <= din_mod_Q_final_6; 
                din_rx_I_7 <= din_mod_I_final_7; 
                din_rx_Q_7 <= din_mod_Q_final_7;
             else 
                din_rx_Q_0 <= (others => '0');
                din_rx_Q_1 <= (others => '0');
                din_rx_Q_2 <= (others => '0');
                din_rx_Q_3 <= (others => '0');
                din_rx_Q_4 <= (others => '0');
                din_rx_Q_5 <= (others => '0');
                din_rx_Q_6 <= (others => '0');
                din_rx_Q_7 <= (others => '0');
                din_rx_I_0 <= (others => '0'); 
                din_rx_I_1 <= (others => '0'); 
                din_rx_I_2 <= (others => '0'); 
                din_rx_I_3 <= (others => '0'); 
                din_rx_I_4 <= (others => '0'); 
                din_rx_I_5 <= (others => '0'); 
                din_rx_I_6 <= (others => '0'); 
                din_rx_I_7 <= (others => '0');
             end if;
        elsif board_mod = 1 then
            din_rx_I_0 <= dout_mod_I_0 ;  
            din_rx_Q_0 <= dout_mod_Q_0 ;  
            din_rx_I_1 <= dout_mod_I_1 ;  
            din_rx_Q_1 <= dout_mod_Q_1 ;   
            din_rx_I_2 <= dout_mod_I_2 ; 
            din_rx_Q_2 <= dout_mod_Q_2 ;
            din_rx_I_3 <= dout_mod_I_3 ;
            din_rx_Q_3 <= dout_mod_Q_3 ;
            din_rx_I_4 <= dout_mod_I_4 ;
            din_rx_Q_4 <= dout_mod_Q_4 ;
            din_rx_I_5 <= dout_mod_I_5 ;
            din_rx_Q_5 <= dout_mod_Q_5 ;
            din_rx_I_6 <= dout_mod_I_6 ;
            din_rx_Q_6 <= dout_mod_Q_6 ;
            din_rx_I_7 <= dout_mod_I_7 ;
            din_rx_Q_7 <= dout_mod_Q_7 ;
        elsif board_mod = 2 then
            din_rx_I_0 <= din_mod_I_final_0;
            din_rx_Q_0 <= din_mod_Q_final_0;
            din_rx_I_1 <= din_mod_I_final_1;
            din_rx_Q_1 <= din_mod_Q_final_1; 
            din_rx_I_2 <= din_mod_I_final_2;
            din_rx_Q_2 <= din_mod_Q_final_2;
            din_rx_I_3 <= din_mod_I_final_3;
            din_rx_Q_3 <= din_mod_Q_final_3;
            din_rx_I_4 <= din_mod_I_final_4;
            din_rx_Q_4 <= din_mod_Q_final_4;
            din_rx_I_5 <= din_mod_I_final_5;
            din_rx_Q_5 <= din_mod_Q_final_5;
            din_rx_I_6 <= din_mod_I_final_6;
            din_rx_Q_6 <= din_mod_Q_final_6;
            din_rx_I_7 <= din_mod_I_final_7;
            din_rx_Q_7 <= din_mod_Q_final_7;
		end if;
	end if;
end process;

--U4: rx_module PORT MAP ( 
--		reset => pl_rsten,
--		clk => clk_128M,

--        din_rx_I_0 =>   din_rx_I_0,    
--        din_rx_Q_0 =>   din_rx_Q_0,       
--        din_rx_I_1 =>   din_rx_I_1,     
--        din_rx_Q_1 =>   din_rx_Q_1, 
--        din_rx_I_2 =>   din_rx_I_2,    
--        din_rx_Q_2 =>   din_rx_Q_2,       
--        din_rx_I_3 =>   din_rx_I_3,     
--        din_rx_Q_3 =>   din_rx_Q_3, 
--        din_rx_I_4 =>   din_rx_I_4,    
--        din_rx_Q_4 =>   din_rx_Q_4,       
--        din_rx_I_5 =>   din_rx_I_5,     
--        din_rx_Q_5 =>   din_rx_Q_5, 
--        din_rx_I_6 =>   din_rx_I_6,    
--        din_rx_Q_6 =>   din_rx_Q_6,       
--        din_rx_I_7 =>   din_rx_I_7,     
--        din_rx_Q_7 =>   din_rx_Q_7,  
--        pl_mod  =>   pl_mod,

--		arm_config_sync_head_array => arm_config_sync_head_array,
--		arm_config_sync_tail_array => arm_config_sync_tail_array,
--		arm_config_matrix_pattern_freq_x1 => arm_config_matrix_pattern_freq_x1,
--		arm_config_matrix_pattern_freq_x2 => arm_config_matrix_pattern_freq_x2,
--		arm_config_matrix_pattern_freq_x3 => arm_config_matrix_pattern_freq_x3,
--		arm_config_matrix_pattern_freq_x4 => arm_config_matrix_pattern_freq_x4,
--		arm_config_addr_offset_x1 => arm_config_addr_offset_x1,
--		arm_config_addr_offset_x2 => arm_config_addr_offset_x2,
--		arm_config_addr_offset_x3 => arm_config_addr_offset_x3,
--		arm_config_addr_offset_x4 => arm_config_addr_offset_x4,
--		arm_config_PN_deinterleave_array => arm_config_PN_deinterleave_array,
--		rate_mode => "00",--arm_config_rx_rate_mode,
--		filter_sel => arm_config_rx_filter_sel,
--		flag_start_rx => flag_start_rx,
--		ram_PN_descramble_we => ram_PN_descramble_we,
--		ram_PN_descramble_din => ram_PN_descramble_din,
		
--		threshold_pulse_num => threshold_pulse_num,
--		threshold_sync_xcorr => threshold_sync_xcorr,
--		channel_busy_threshold => channel_busy_threshold,
--		channel_load => channel_load,
--		channel_capure_threshold => channel_capure_threshold,
--		PA_switch_local => PA_switch_local,
		
--		point_test_rx => point_test_rx,
--		rdy_rx => rdy_rx,
--		----- agc -----
--		----- agc -----
		
--		agc_control_mode  =>  agc_control_mode,
--        agc_arm_ctrl_mode  =>  agc_arm_ctrl_mode,
--        agc_arm_ctrl_12  =>  agc_arm_ctrl_12,
--        flag_agc_arm_ctrl_DVGA4 => flag_agc_arm_ctrl_DVGA4 ,
--        agc_arm_ctrl_DVGA4  =>  agc_arm_ctrl_DVGA4,
--        DVGA_ctrl_4  =>  DVGA_ctrl_4,
----        pl_mod => pl_mod , 
--        THRESHOLD_WIDTH   =>   THRESHOLD_WIDTH,
--        THRESHOLD_INSIDE  =>   THRESHOLD_INSIDE,
--        THRESHOLD_CENTER  =>   THRESHOLD_CENTER,
--        RESPONSE_TIME	  =>   RESPONSE_TIME,
        
----		agc_arm_ctrl_mode => agc_arm_ctrl_mode,
--		agc_arm_ctrl_DVGA1 => agc_arm_ctrl_DVGA1,
--		agc_arm_ctrl_DVGA2 => agc_arm_ctrl_DVGA2,
----		agc_arm_ctrl_12 => agc_arm_ctrl_12,
--		agc_arm_ctrl_DVGA3 => agc_arm_ctrl_DVGA3,
----		agc_arm_ctrl_DVGA4 => agc_arm_ctrl_DVGA4,
--		agc_arm_ctrl_34 => agc_arm_ctrl_34,
--		-- DVGA_ctrl_1 => DVGA_ctrl_1,
--		-- DVGA_ctrl_2 => DVGA_ctrl_2,
--		-- DVGA_ctrl_3 => DVGA_ctrl_3,
----		DVGA_ctrl_4 => DVGA_ctrl_4,
--		------ 频点择优模式   ----
--		dds_clr => dds_clr,
--		dds_freq_para_local => dds_freq_para_local,
--		counter_switch => counter_switch,
--		counter_2M=> counter_2M,
--		------ ARM读信号  ----
--		read_ram_err_count => '0',
--		flag_rd_arm_onetime => flag_rd_arm_onetime,
--		flag_rd_arm_onepacket => flag_rd_arm_onepacket,
--		flag_rd_arm_oneint => flag_rd_arm_oneint,
--		int_rx_arm => int_rx_arm_ZYNQ,
--		num_buffer_rx_arm_interface => num_buffer_rx_arm_interface,
--		dout_rx_arm_interface => dout_rx_arm_interface,
--		rx_jiewei => Antenna_switch_local(15 downto 8),
--		----    时间同步相关    ----
--		rdy_sync_acquisition_time                 =>   rdy_sync_acquisition_time               ,
--		sync_time_offest                          =>   sync_time_offest                        ,
--		wraddr_base_I_ram_demod_data_buffer_time  =>   wraddr_base_I_ram_demod_data_buffer_time,
--		rdaddr_base_I_ram_demod_data_buffer_time  =>   rdaddr_base_I_ram_demod_data_buffer_time,
--		we_I_ram_demod_data_buffer_time           =>   we_I_ram_demod_data_buffer_time         ,
--		----    接收时间戳    ----
--       rx_timestamp_in                           =>   rx_timestamp_in  ,
--       ---- 接受时间戳时标计数器值------
--        rx_timestamp_cor_out                  =>    rx_timestamp_cor_out,
--        -----  捕获时 时标计数器周期新旧值标志-----
--        flag_rx_timestamp                     =>    flag_rx_timestamp,
--       crc_result  =>  crc_result,
       
       
--        ----    BRAM    ----
--       bram_addr_a_0       =>       bram_addr_a_0   ,
--       bram_clk_a_0        =>       bram_clk_a_0    ,
--       bram_rst_a_0        =>       bram_rst_a_0    ,
--       bram_en_a_0         =>       bram_en_a_0     ,
--       bram_we_a_0         =>       bram_we_a_0     ,
--       bram_rddata_a_0     =>       bram_rddata_a_0 ,
--       ----   切换turbo编码方式（1/3，1/6，1/10，1/20）  ----
--       encode_type_rx      =>       encode_type,
--       -- PS 读标志 ----    
--       flag_lock_reg_PS_read_rx => flag_lock_reg_PS_read_rx,
--       EN_time_hopping       =>   EN_time_hopping,
--       -----------TDMA-------------
--       flag_CRC_timebase_adj => flag_CRC_timebase_adj,
--       flag_brd_acquisition => flag_brd_acquisition,
--       rdy_sync_acquisition   => rdy_sync_acquisition,
--       master_or_slave => master_or_slave,
--        ----  定频模式切换与选择   ----
--        flag_freq_hopping_control  => flag_freq_hopping_control,           
--        freq_hopping_select     => freq_hopping_select ,
--          ---------定频模式任意频率相位字配置---------- 
--        configurable_freq_hopping_phase_inc            => configurable_freq_hopping_phase_inc         , 
--        configurable_freq_hopping_phase_offset_0       => configurable_freq_hopping_phase_offset_0    ,
--        configurable_freq_hopping_phase_offset_1       => configurable_freq_hopping_phase_offset_1    ,
--        configurable_freq_hopping_phase_offset_2       => configurable_freq_hopping_phase_offset_2    ,
--        configurable_freq_hopping_phase_offset_3       => configurable_freq_hopping_phase_offset_3    ,
--        configurable_freq_hopping_phase_offset_4       => configurable_freq_hopping_phase_offset_4    ,
--        configurable_freq_hopping_phase_offset_5       => configurable_freq_hopping_phase_offset_5    ,
--        configurable_freq_hopping_phase_offset_6       => configurable_freq_hopping_phase_offset_6    ,
--        configurable_freq_hopping_phase_offset_7       => configurable_freq_hopping_phase_offset_7
--	);
    
--U5 : timestamp_module port map(
--       clk1                                      =>  clk_128M                                ,
--      clk2                                      =>  clk_512M                                ,
--      reset                                     =>  pl_rsten                                ,
--	  reset_time                                =>  reset_time                              ,	
--      ----  接收  ----  
--      rdy_sync_acquisition_time                 =>  rdy_sync_acquisition_time               ,
--      sync_time_offest                          =>   sync_time_offest                        ,
--      wraddr_base_I_ram_demod_data_buffer_time  =>  wraddr_base_I_ram_demod_data_buffer_time,
--      rdaddr_base_I_ram_demod_data_buffer_time  =>  rdaddr_base_I_ram_demod_data_buffer_time,
--      we_I_ram_demod_data_buffer_time           =>  we_I_ram_demod_data_buffer_time         ,
--      ---- 接收时间戳输出  ----
--      rx_timestamp_in                           =>  rx_timestamp_in                         ,
--      rx_timestamp_cor_out                      =>  rx_timestamp_cor_out                    ,
--    -----  捕获时 时标计数器周期新旧值标志-----
--     flag_rx_timestamp                          =>  flag_rx_timestamp                       ,
--      ----  发射  ----                         
--      flag_one_packet_tx                        =>  flag_one_packet_tx                      ,
--      reg_tx_timesync_type                      =>  reg_tx_timesync_type                    ,
--      ----  时间戳上传  ----
--      send_timestamp_2                          =>  send_timestamp_2                        ,
--      send_timestamp_1                          =>  send_timestamp_1                        ,
--      send_timestamp_0                          =>  send_timestamp_0                        ,
--     ----  发射时间戳时标计数器值  ----
--      send_timestamp_cor_2                      =>  send_timestamp_cor_2                      ,
--      send_timestamp_cor_1                      =>  send_timestamp_cor_1                      ,
--      send_timestamp_cor_0                      =>  send_timestamp_cor_0                      ,
--    ----  发射时，时标计数器周期值新旧标志----
--      flag_send_timestamp_cor                   =>   flag_send_timestamp_cor                 ,
--	  ----  时间同步sync  ----
--	  TEST0_EXT_ZYNQ                            =>  TEST0_EXT_ZYNQ                          ,
--      ----  发射时间戳更新标志  ----
--      flag_tx_time_renew                        =>  flag_tx_time_renew                      ,
--      ----  发射时间戳读取标志  ----
--      flag_tx_timestamp_read                    =>  flag_tx_timestamp_read                  ,
--      offset_time_2                             =>  offset_time_2                         ,
--      offset_time_1                             =>  offset_time_1                         ,
--      offset_time_0                             =>  offset_time_0                         ,
--      flag_offset_time_adjust                   =>  flag_offset_time_adjust               ,
--	  reg_phy_time                              =>  reg_phy_time                          ,
--      ps_oen                                    =>  mem_oen_1(0),
--	  ps_cen                                    =>  mem_cen_1(0),
	  
--	   EN_timestamp_cor => EN_timestamp_cor,
--        flag_timestamp_cor => flag_timestamp_cor,
--        value_timestamp_cor => value_timestamp_cor,
--        polarity_cor => polarity_cor,
--        times_timestamp_cor => times_timestamp_cor,
	  
--	  led_sync                                  =>  led_sync,
--	  flag_times_timestamp_cor_read             => flag_times_timestamp_cor_read,
--	  time_pulse_sync      =>  time_pulse_sync   ,
--      time_pulse_sync_cu   =>  time_pulse_sync_cu
--);


u_clk_wiz_0 : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_128M_0,
  -- Status and control signals                
   resetn => resetn_ps_100M,
   locked => clk_locked_0,
   -- Clock in ports
   clk_in1 => clk_100M
 );
u_clk_wiz_1 : clk_wiz_1
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_128M,
   clk_out2 => clk_512M,
  -- Status and control signals                
   resetn => SI5341_locked,
   locked => mmcm_locked,
   -- Clock in ports
   clk_in1_p => REFCLK0_P_PL,
   clk_in1_n => REFCLK0_N_PL
 );
pl_rsten <= mmcm_locked;



U6 : SI5341 
port map ( 
    ----    SI 5341相关    ----
    flag_SI5341_config           => flag_SI5341_config           ,
    reg_SI5341_config_wrdata     => reg_SI5341_config_wrdata     ,
    reg_SI5341_config_rddata     => reg_SI5341_config_rddata     ,
    reg_SPI_SI5341_config_state  => reg_SPI_SI5341_config_state  ,
    SI5341_MISO                   =>SI5341_MISO                  ,
    SI5341_MOSI                   =>SI5341_MOSI                  ,
    SI5341_SCLK                   =>SI5341_SCLK                  ,
    SI5341_SCS                    =>SI5341_SCS                   ,
    reset 						  =>global_rst                   ,
    clk                           =>clk_100M                   ,
    SI5341_locked                 =>SI5341_locked
);

u_vio_tx : vio_tx
  PORT MAP (
    clk => clk_128M,
    probe_in0(0) => mmcm_locked,
    probe_out0 => tx_rstn,
    probe_out1 => ram_en,
    probe_out2 => dds_rstn,
    probe_out3 => dds_pinc_bpsk,
    probe_out4 => dds_pinc_qpsk,
    probe_out5 => dds_poff_bpsk,
    probe_out6 => dds_poff_qpsk,
    probe_out7 => tx_sel_vio_ps,
    probe_out8 => atten_bpsk,
    probe_out9 => atten_qpsk,
    probe_out10 => bpsk_en,
    probe_out11 => qpsk_en,
    probe_out12 => rate_sel
  );

-- PCIe TX vio/ps 选择 mux 逻辑
tx_rstn_mux       <= tx_rstn(0)        when tx_sel_vio_ps(0) = '0' else tx_rstn_ps;
ram_en_mux        <= ram_en(0)         when tx_sel_vio_ps(0) = '0' else ram_en_ps;
bpsk_en_mux       <= bpsk_en(0)        when tx_sel_vio_ps(0) = '0' else bpsk_en_ps;
qpsk_en_mux       <= qpsk_en(0)        when tx_sel_vio_ps(0) = '0' else qpsk_en_ps;
rate_sel_mux      <= rate_sel(0)       when tx_sel_vio_ps(0) = '0' else rate_sel_ps;
dds_rstn_mux      <= dds_rstn(0)       when tx_sel_vio_ps(0) = '0' else dds_rstn_ps;
dds_pinc_bpsk_mux <= dds_pinc_bpsk     when tx_sel_vio_ps(0) = '0' else dds_pinc_bpsk_ps;
dds_pinc_qpsk_mux <= dds_pinc_qpsk     when tx_sel_vio_ps(0) = '0' else dds_pinc_qpsk_ps;
dds_poff_bpsk_mux <= dds_poff_bpsk     when tx_sel_vio_ps(0) = '0' else dds_poff_bpsk_ps;
dds_poff_qpsk_mux <= dds_poff_qpsk     when tx_sel_vio_ps(0) = '0' else dds_poff_qpsk_ps;
atten_bpsk_mux <= atten_bpsk     when tx_sel_vio_ps(0) = '0' else atten_bpsk_ps;
atten_qpsk_mux <= atten_qpsk     when tx_sel_vio_ps(0) = '0' else atten_qpsk_ps;
bpsk_single_shot_mux <= '0'          when tx_sel_vio_ps(0) = '0' else bpsk_single_shot_ps;
 
 u_tx_top: tx_top
  PORT MAP (
    clk           => clk_128M,
    rst_n         => tx_rstn_mux,
    ram_en        => ram_en_mux,
    bpsk_en       => bpsk_en_mux,
    qpsk_en       => qpsk_en_mux,
    rate_sel      => rate_sel_mux,
    dds_rstn      => dds_rstn_mux,
    dds_pinc_bpsk => dds_pinc_bpsk_mux,
    dds_pinc_qpsk => dds_pinc_qpsk_mux,
    dds_poff_bpsk => dds_poff_bpsk_mux,
    dds_poff_qpsk => dds_poff_qpsk_mux,
    atten_bpsk => atten_bpsk_mux,
    atten_qpsk => atten_qpsk_mux,
    ram_w_en_bpsk   => ram_w_en_bpsk_ps,
    ram_w_addr_bpsk => ram_w_addr_bpsk_ps,
    ram_w_data_bpsk => ram_w_data_bpsk_ps,
    ram_w_en_qpsk   => ram_w_en_qpsk_ps,
    ram_w_addr_qpsk => ram_w_addr_qpsk_ps,
    ram_w_data_qpsk => ram_w_data_qpsk_ps,
    bpsk_sym_num       => bpsk_sym_num_ps,
    bpsk_single_shot   => bpsk_single_shot_mux,
    iq            => iq,
    bpsk_sig_valid => bpsk_sig_valid,
    qpsk_sig_valid => qpsk_sig_valid
  );
 
 u_ila_tx : ila_tx
PORT MAP (
	clk => clk_128M,
	probe0 => iq
); 

--U7: pcie_test_ram
-- port map(
--    clk         => clk_128M               ,
--    reset       =>   pl_rsten             ,
--    clkb_0        => bram_clk_dma_b_0       ,
--    addrb_0       => bram_addr_dma_b_0      ,
--    data_out_0    => bram_rddata_dma_b_0    ,
--    enb_0         => bram_en_dma_b_0        ,
--    clkb_1        => bram_clk_dma_b_1       ,
--    addrb_1       => bram_addr_dma_b_1      ,
--    data_out_1    => bram_rddata_dma_b_1    ,
--    enb_1         => bram_en_dma_b_1        ,
--    irq1_clean              =>  irq1_clean              ,
--    irq2_clean              =>  irq2_clean              ,
--    usr_irq_ack_0           =>  usr_irq_ack_0(1 downto 0)           ,
--    irq         => irq_ram
-- );
 
-- U7: pcie_test
-- port map(
--    clk         => clk_128M               ,
--    reset       =>   pl_rsten             ,
--    clkb_0        => bram_clk_dma_b_0       ,
--    addrb_0       => bram_addr_dma_b_0      ,
--    data_out_0    => bram_rddata_dma_b_0    ,
--    enb_0         => bram_en_dma_b_0        ,
--    clkb_1        => bram_clk_dma_b_1       ,
--    addrb_1       => bram_addr_dma_b_1      ,
--    data_out_1    => bram_rddata_dma_b_1    ,
--    enb_1         => bram_en_dma_b_1        ,
--    usr_irq_ack_0           =>  usr_irq_ack_0(1 downto 0)           ,
--    irq         => irq_ram
-- );

U7 : pcie_irq_ctrl
PORT MAP(
    clk => clk_128M,
    clkb0 => bram_clk_dma_b_0    ,
    addrb0 =>bram_addr_dma_b_0   ,
    dout0 => bram_rddata_dma_b_0 ,
    clkb1 => bram_clk_dma_b_1    ,
    addrb1 =>bram_addr_dma_b_1   ,
    dout1 => bram_rddata_dma_b_1 ,
    reset => pl_rsten,
    data_in => data_512b ,
    irq_ctrl => irq_ram,
    flag_xdma_test_rdy => flag_rdy,
    xdma_stop => write_stop,
    data_in_valid => data_out_valid_in,
    data_source_select => data_source_select,
    irq_ack => usr_irq_ack_0(1 downto 0)
);
zeros_128 <= (others => '0');
data_512b(511 downto 64) <= (others => '0');
data_512b(63 downto 32)   <= data_out_tunnel0;
data_512b(31 downto 0)   <= (others => '0');
 
  U8 : pio_interface
 port map(
   clk                      =>  clk_512M                ,
   clka                     =>  bram_clk_pio_a          ,
   clkb                     =>  bram_clk_pio_b          ,
   bram_addr_pio_a          =>  bram_addr_pio_a         ,
   bram_addr_pio_b          =>  bram_addr_pio_b         ,
   bram_en_pio_a            =>  bram_en_pio_a           ,
   bram_en_pio_b            =>  bram_en_pio_b           ,
   bram_rddata_pio_a        =>  bram_rddata_pio_a       ,
   bram_rddata_pio_b        =>  bram_rddata_pio_b       ,
   bram_rst_pio_a           =>  pl_rsten                ,
   bram_rst_pio_b           =>  pl_rsten                ,
   bram_we_pio_a            =>  bram_we_pio_a           ,
   bram_we_pio_b            =>  bram_we_pio_b           ,
   bram_wrdata_pio_a        =>  bram_wrdata_pio_a       ,
   bram_wrdata_pio_b        =>  bram_wrdata_pio_b       ,
   irq1_clean               =>  irq1_clean              ,
   irq2_clean               =>  irq2_clean              ,
   flag_rdy                 =>  flag_rdy                ,
   data_source_select       =>  data_source_select      ,
    reset_DDS_0              => reset_DDS_0              ,
    phase_PINC_0             => phase_PINC_0             ,
    phase_POFF_0_tunnel0     => phase_POFF_0_tunnel0     ,
    phase_POFF_1_tunnel0     => phase_POFF_1_tunnel0     ,
    phase_POFF_2_tunnel0     => phase_POFF_2_tunnel0     ,
    phase_POFF_3_tunnel0     => phase_POFF_3_tunnel0     ,
    phase_POFF_4_tunnel0     => phase_POFF_4_tunnel0     ,
    phase_POFF_5_tunnel0     => phase_POFF_5_tunnel0     ,
    phase_POFF_6_tunnel0     => phase_POFF_6_tunnel0     ,
    phase_POFF_7_tunnel0     => phase_POFF_7_tunnel0     ,
    
                          
    reset_DDS_1              => reset_DDS_1              ,
    phase_PINC_1             => phase_PINC_1             ,
    phase_POFF_0_tunnel1     => phase_POFF_0_tunnel1     ,
    phase_POFF_1_tunnel1     => phase_POFF_1_tunnel1     ,
    phase_POFF_2_tunnel1     => phase_POFF_2_tunnel1     ,
    phase_POFF_3_tunnel1     => phase_POFF_3_tunnel1     ,
    phase_POFF_4_tunnel1     => phase_POFF_4_tunnel1     ,
    phase_POFF_5_tunnel1     => phase_POFF_5_tunnel1     ,
    phase_POFF_6_tunnel1     => phase_POFF_6_tunnel1     ,
    phase_POFF_7_tunnel1     => phase_POFF_7_tunnel1     ,
   
                            
    reset_DDS_2              => reset_DDS_2              ,
    phase_PINC_2             => phase_PINC_2             ,
    phase_POFF_0_tunnel2     => phase_POFF_0_tunnel2     ,
    phase_POFF_1_tunnel2     => phase_POFF_1_tunnel2     ,
    phase_POFF_2_tunnel2     => phase_POFF_2_tunnel2     ,
    phase_POFF_3_tunnel2     => phase_POFF_3_tunnel2     ,
    phase_POFF_4_tunnel2     => phase_POFF_4_tunnel2     ,
    phase_POFF_5_tunnel2     => phase_POFF_5_tunnel2     ,
    phase_POFF_6_tunnel2     => phase_POFF_6_tunnel2     ,
    phase_POFF_7_tunnel2     => phase_POFF_7_tunnel2     ,
    
                           
    reset_DDS_3              => reset_DDS_3              ,
    phase_PINC_3             => phase_PINC_3             ,
    phase_POFF_0_tunnel3     => phase_POFF_0_tunnel3     ,
    phase_POFF_1_tunnel3     => phase_POFF_1_tunnel3     ,
    phase_POFF_2_tunnel3     => phase_POFF_2_tunnel3     ,
    phase_POFF_3_tunnel3     => phase_POFF_3_tunnel3     ,
    phase_POFF_4_tunnel3     => phase_POFF_4_tunnel3     ,
    phase_POFF_5_tunnel3     => phase_POFF_5_tunnel3     ,
    phase_POFF_6_tunnel3     => phase_POFF_6_tunnel3     ,
    phase_POFF_7_tunnel3     => phase_POFF_7_tunnel3     ,
    
                            
    reset_DDS_4              => reset_DDS_4              ,
    phase_PINC_4             => phase_PINC_4             ,
    phase_POFF_0_tunnel4     => phase_POFF_0_tunnel4     ,
    phase_POFF_1_tunnel4     => phase_POFF_1_tunnel4     ,
    phase_POFF_2_tunnel4     => phase_POFF_2_tunnel4     ,
    phase_POFF_3_tunnel4     => phase_POFF_3_tunnel4     ,
    phase_POFF_4_tunnel4     => phase_POFF_4_tunnel4     ,
    phase_POFF_5_tunnel4     => phase_POFF_5_tunnel4     ,
    phase_POFF_6_tunnel4     => phase_POFF_6_tunnel4     ,
    phase_POFF_7_tunnel4     => phase_POFF_7_tunnel4     ,
    
                           
    reset_DDS_5              => reset_DDS_5              ,
    phase_PINC_5             => phase_PINC_5             ,
    phase_POFF_0_tunnel5     => phase_POFF_0_tunnel5     ,
    phase_POFF_1_tunnel5     => phase_POFF_1_tunnel5     ,
    phase_POFF_2_tunnel5     => phase_POFF_2_tunnel5     ,
    phase_POFF_3_tunnel5     => phase_POFF_3_tunnel5     ,
    phase_POFF_4_tunnel5     => phase_POFF_4_tunnel5     ,
    phase_POFF_5_tunnel5     => phase_POFF_5_tunnel5     ,
    phase_POFF_6_tunnel5     => phase_POFF_6_tunnel5     ,
    phase_POFF_7_tunnel5     => phase_POFF_7_tunnel5     ,
    
                            
    reset_DDS_6              => reset_DDS_6              ,
    phase_PINC_6             => phase_PINC_6             ,
    phase_POFF_0_tunnel6     => phase_POFF_0_tunnel6     ,
    phase_POFF_1_tunnel6     => phase_POFF_1_tunnel6     ,
    phase_POFF_2_tunnel6     => phase_POFF_2_tunnel6     ,
    phase_POFF_3_tunnel6     => phase_POFF_3_tunnel6     ,
    phase_POFF_4_tunnel6     => phase_POFF_4_tunnel6     ,
    phase_POFF_5_tunnel6     => phase_POFF_5_tunnel6     ,
    phase_POFF_6_tunnel6     => phase_POFF_6_tunnel6     ,
    phase_POFF_7_tunnel6     => phase_POFF_7_tunnel6     ,
    
                            
    reset_DDS_7              => reset_DDS_7              ,
    phase_PINC_7             => phase_PINC_7             ,
    phase_POFF_0_tunnel7     => phase_POFF_0_tunnel7     ,
    phase_POFF_1_tunnel7     => phase_POFF_1_tunnel7     ,
    phase_POFF_2_tunnel7     => phase_POFF_2_tunnel7     ,
    phase_POFF_3_tunnel7     => phase_POFF_3_tunnel7     ,
    phase_POFF_4_tunnel7     => phase_POFF_4_tunnel7     ,
    phase_POFF_5_tunnel7     => phase_POFF_5_tunnel7     ,
    phase_POFF_6_tunnel7     => phase_POFF_6_tunnel7     ,
    phase_POFF_7_tunnel7     => phase_POFF_7_tunnel7     ,
    
                             
    reset_DDS_8              => reset_DDS_8              ,
    phase_PINC_8             => phase_PINC_8             ,
    phase_POFF_0_tunnel8     => phase_POFF_0_tunnel8     ,
    phase_POFF_1_tunnel8     => phase_POFF_1_tunnel8     ,
    phase_POFF_2_tunnel8     => phase_POFF_2_tunnel8     ,
    phase_POFF_3_tunnel8     => phase_POFF_3_tunnel8     ,
    phase_POFF_4_tunnel8     => phase_POFF_4_tunnel8     ,
    phase_POFF_5_tunnel8     => phase_POFF_5_tunnel8     ,
    phase_POFF_6_tunnel8     => phase_POFF_6_tunnel8     ,
    phase_POFF_7_tunnel8     => phase_POFF_7_tunnel8     ,
    
                            
    reset_DDS_9              => reset_DDS_9              ,
    phase_PINC_9             => phase_PINC_9             ,
    phase_POFF_0_tunnel9     => phase_POFF_0_tunnel9     ,
    phase_POFF_1_tunnel9     => phase_POFF_1_tunnel9     ,
    phase_POFF_2_tunnel9     => phase_POFF_2_tunnel9     ,
    phase_POFF_3_tunnel9     => phase_POFF_3_tunnel9     ,
    phase_POFF_4_tunnel9     => phase_POFF_4_tunnel9     ,
    phase_POFF_5_tunnel9     => phase_POFF_5_tunnel9     ,
    phase_POFF_6_tunnel9     => phase_POFF_6_tunnel9     ,
    phase_POFF_7_tunnel9     => phase_POFF_7_tunnel9     ,
    
                            
    reset_DDS_10             => reset_DDS_10             ,
    phase_PINC_10            => phase_PINC_10            ,
    phase_POFF_0_tunnel10    => phase_POFF_0_tunnel10    ,
    phase_POFF_1_tunnel10    => phase_POFF_1_tunnel10    ,
    phase_POFF_2_tunnel10    => phase_POFF_2_tunnel10    ,
    phase_POFF_3_tunnel10    => phase_POFF_3_tunnel10    ,
    phase_POFF_4_tunnel10    => phase_POFF_4_tunnel10    ,
    phase_POFF_5_tunnel10    => phase_POFF_5_tunnel10    ,
    phase_POFF_6_tunnel10    => phase_POFF_6_tunnel10    ,
    phase_POFF_7_tunnel10    => phase_POFF_7_tunnel10    ,
    
                            
    reset_DDS_11             => reset_DDS_11             ,
    phase_PINC_11            => phase_PINC_11            ,
    phase_POFF_0_tunnel11    => phase_POFF_0_tunnel11    ,
    phase_POFF_1_tunnel11    => phase_POFF_1_tunnel11    ,
    phase_POFF_2_tunnel11    => phase_POFF_2_tunnel11    ,
    phase_POFF_3_tunnel11    => phase_POFF_3_tunnel11    ,
    phase_POFF_4_tunnel11    => phase_POFF_4_tunnel11    ,
    phase_POFF_5_tunnel11    => phase_POFF_5_tunnel11    ,
    phase_POFF_6_tunnel11    => phase_POFF_6_tunnel11    ,
    phase_POFF_7_tunnel11    => phase_POFF_7_tunnel11    ,
    
    
    reset_DDS_12             => reset_DDS_12             ,
    phase_PINC_12            => phase_PINC_12            ,
    phase_POFF_0_tunnel12    => phase_POFF_0_tunnel12    ,
    phase_POFF_1_tunnel12    => phase_POFF_1_tunnel12    ,
    phase_POFF_2_tunnel12    => phase_POFF_2_tunnel12    ,
    phase_POFF_3_tunnel12    => phase_POFF_3_tunnel12    ,
    phase_POFF_4_tunnel12    => phase_POFF_4_tunnel12    ,
    phase_POFF_5_tunnel12    => phase_POFF_5_tunnel12    ,
    phase_POFF_6_tunnel12    => phase_POFF_6_tunnel12    ,
    phase_POFF_7_tunnel12    => phase_POFF_7_tunnel12    ,
    
    
    reset_DDS_13             => reset_DDS_13             ,
    phase_PINC_13            => phase_PINC_13            ,
    phase_POFF_0_tunnel13    => phase_POFF_0_tunnel13    ,
    phase_POFF_1_tunnel13    => phase_POFF_1_tunnel13    ,
    phase_POFF_2_tunnel13    => phase_POFF_2_tunnel13    ,
    phase_POFF_3_tunnel13    => phase_POFF_3_tunnel13    ,
    phase_POFF_4_tunnel13    => phase_POFF_4_tunnel13    ,
    phase_POFF_5_tunnel13    => phase_POFF_5_tunnel13    ,
    phase_POFF_6_tunnel13    => phase_POFF_6_tunnel13    ,
    phase_POFF_7_tunnel13    => phase_POFF_7_tunnel13    ,
    
    
    reset_DDS_14             => reset_DDS_14             ,
    phase_PINC_14            => phase_PINC_14            ,
    phase_POFF_0_tunnel14    => phase_POFF_0_tunnel14    ,
    phase_POFF_1_tunnel14    => phase_POFF_1_tunnel14    ,
    phase_POFF_2_tunnel14    => phase_POFF_2_tunnel14    ,
    phase_POFF_3_tunnel14    => phase_POFF_3_tunnel14    ,
    phase_POFF_4_tunnel14    => phase_POFF_4_tunnel14    ,
    phase_POFF_5_tunnel14    => phase_POFF_5_tunnel14    ,
    phase_POFF_6_tunnel14    => phase_POFF_6_tunnel14    ,
    phase_POFF_7_tunnel14    => phase_POFF_7_tunnel14    ,
    
    
    tunnel_switch_out        => tunnel_switch            ,
   write_stop               =>  write_stop
 );
U9_0 : data_pcie
 port map(
    reset           =>  pl_rsten                ,
    clk             =>  clk_128M                ,
    reset_DDS       =>  reset_DDS_0             ,
    phase_PINC      =>  phase_PINC_0            ,
    phase_POFF_0    =>  phase_POFF_0_tunnel0    ,
    phase_POFF_1    =>  phase_POFF_1_tunnel0    ,
    phase_POFF_2    =>  phase_POFF_2_tunnel0    ,
    phase_POFF_3    =>  phase_POFF_3_tunnel0    ,
    phase_POFF_4    =>  phase_POFF_4_tunnel0    ,
    phase_POFF_5    =>  phase_POFF_5_tunnel0    ,
    phase_POFF_6    =>  phase_POFF_6_tunnel0    ,
    phase_POFF_7    =>  phase_POFF_7_tunnel0    ,
    data_in_0       =>  din_mod_final_0         ,
    data_in_1       =>  din_mod_final_1         ,
    data_in_2       =>  din_mod_final_2         ,
    data_in_3       =>  din_mod_final_3         ,
    data_in_4       =>  din_mod_final_4         ,
    data_in_5       =>  din_mod_final_5         ,
    data_in_6       =>  din_mod_final_6         ,
    data_in_7       =>  din_mod_final_7         ,
    data_out        =>  data_out_tunnel0        ,
    data_out_valid  =>  data_out_valid
 );
process(pl_rsten,clk_128M)
begin
	if pl_rsten = '0' then
		data_out_valid_in <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		data_out_valid_in <= data_out_valid;
	end if;
end process;
 
 
--U9 : real_time_process
--PORT MAP(
    
--);

--U10 : fft_polyphase
--PORT MAP(
--    clk => clk_128M,
--    reset => pl_rsten,
--    reset_DDS => reset_DDS_fft,
--    phase_PINC => phase_PINC_fft,
--    phase_POFF_0 => phase_POFF_0_fft,
--    phase_POFF_1 => phase_POFF_1_fft,
--    phase_POFF_2 => phase_POFF_2_fft,
--    phase_POFF_3 => phase_POFF_3_fft,
--    phase_POFF_4 => phase_POFF_4_fft,
--    phase_POFF_5 => phase_POFF_5_fft,
--    phase_POFF_6 => phase_POFF_6_fft,
--    phase_POFF_7 => phase_POFF_7_fft,
--    data_in_0 => din_mod_final_0,
--    data_in_1 => din_mod_final_1,
--    data_in_2 => din_mod_final_2,
--    data_in_3 => din_mod_final_3,
--    data_in_4 => din_mod_final_4,
--    data_in_5 => din_mod_final_5,
--    data_in_6 => din_mod_final_6,
--    data_in_7 => din_mod_final_7,
--    reg_fft_tap_select  => reg_fft_tap_select,
--    flag_rdy            => flag_fft_rdy,
--    fft_stop            => fft_stop,
--    num_valid           => num_valid            ,
--    addup_N             => addup_N              ,
--    shift_bits          => shift_bits_fft       ,
--    bram_addr_fft       => bram_addr_dma_b_2    ,
--    bram_clk_fft        => bram_clk_dma_b_2     ,
--    bram_rddata_fft     => bram_rddata_dma_b_2  ,
--    bram_en_fft         => bram_en_dma_b_2      ,
--    irq                 => irq_fft 
--);

--U11 : wideband_acq
--PORT MAP(
--    clk => clk_128M,
--    reset => pl_rsten,
--    reset_DDS => reset_DDS_fft,
--    phase_PINC => phase_PINC_fft,
--    phase_POFF_0 => phase_POFF_0_fft,
--    phase_POFF_1 => phase_POFF_1_fft,
--    phase_POFF_2 => phase_POFF_2_fft,
--    phase_POFF_3 => phase_POFF_3_fft,
--    phase_POFF_4 => phase_POFF_4_fft,
--    phase_POFF_5 => phase_POFF_5_fft,
--    phase_POFF_6 => phase_POFF_6_fft,
--    phase_POFF_7 => phase_POFF_7_fft,
--    data_in_0 => din_mod_final_0,
--    data_in_1 => din_mod_final_1,
--    data_in_2 => din_mod_final_2,
--    data_in_3 => din_mod_final_3,
--    data_in_4 => din_mod_final_4,
--    data_in_5 => din_mod_final_5,
--    data_in_6 => din_mod_final_6,
--    data_in_7 => din_mod_final_7,
--    reg_fft_tap_select  => reg_fft_tap_select,
--    flag_rdy            => flag_rdy_wideband ,
--    bram_addr_fft       => bram_addr_dma_b_3    ,
--    bram_clk_fft        => bram_clk_dma_b_3     ,
--    bram_rddata_fft     => bram_rddata_dma_b_3  ,
--    bram_en_fft         => bram_en_dma_b_3      ,
--    bram_addr_fft_1     => bram_addr_dma_b_4    ,
--    bram_clk_fft_1      => bram_clk_dma_b_4     ,
--    bram_rddata_fft_1   => bram_rddata_dma_b_4  ,
--    bram_en_fft_1       => bram_en_dma_b_4      ,
--    irq                 => irq_wideband
--);
irq_xdma(1 downto 0) <= irq_ram;
irq_xdma(2) <= irq_fft;
irq_xdma(4 downto 3) <= irq_wideband;


--BUFG_50M : BUFG
--port map (
--    O => CLK_50M, -- 1-bit output: Clock output.
--    I => REF_CLK_50M  -- 1-bit input: Clock input.
--);

BUFG_100M : BUFG
port map (
    O => CLK_100M, -- 1-bit output: Clock output.
    I => CLK_100M_ps  -- 1-bit input: Clock input.
);



--U_ila_RX_TX_DATA_DUOBAO : ila_RX_TX_DATA_DUOBAO
--PORT MAP (
--	clk => clk_128M,
--	probe0 => dout_mod_I_0,
--	probe1 => dout_mod_I_1,     
--	probe2 => s20_axis_tdata_0(15 downto 0),
--	probe3 => s20_axis_tdata_0(31 downto 16),
--	probe4 => dout_mod_I_4, 
--	probe5 => dout_mod_I_5,
--	probe6 => dout_mod_I_6,
--	probe7 => dout_mod_I_7,
--	probe8 =>  dout_mod_Q_0,
--	probe9 =>  dout_mod_Q_1,     
--	probe10 => dout_mod_Q_2,
--	probe11 => dout_mod_Q_3,
--	probe12 => dout_mod_Q_4, 
--	probe13 => dout_mod_Q_5,
--	probe14 => dout_mod_Q_6,
--	probe15 => dout_mod_Q_7,
--	probe16 => din_rx_I_0, 
--	probe17 => din_rx_I_1,    
--	probe18 => din_rx_I_2,  
--	probe19 => din_rx_I_3,    
--	probe20 => din_rx_I_4,  
--	probe21 => din_rx_I_5,    
--	probe22 => m23_axis_tdata_0(15 downto 0),  
--	probe23 => m22_axis_tdata_0(15 downto 0),    
--	probe24 => din_rx_Q_0,  
--	probe25 => din_rx_Q_1,    
--	probe26 => din_rx_Q_2,  
--	probe27 => din_rx_Q_3,    
--	probe28 => din_rx_Q_4,  
--	probe29 => din_rx_Q_5,    
--	probe30 => din_rx_Q_6,  
--	probe31 => din_rx_Q_7,
--	probe32(0) => R0_C0_in,
--	probe33(0) => R1_C0_in,
--	probe34(0) => SW_R2_in,
--	probe35(0) => R2_C0_in,
--	probe36(0) => lock_refclk_cpt,
--	probe37(0) => PA_switch_local,
--    probe38(0) => CA53_TXD,
--	probe39(0) => CA53_EXTERNAL_RXD,
--	probe40(0) => PA_switch_delay_400ns,
--	probe41(0) => lock_1pps_cpt,
--	probe42(0) => '0',
--	probe43(0) => SEL1_TX_in
	
--);

U_ila_locked : ila_locked
PORT MAP (
	clk => clk_100M,
	probe0(0) => SI5341_locked,
	probe1(0) => mmcm_locked
);


process(pl_rsten,clk_128M)
begin
	if pl_rsten = '0' then
		COUNTER_128M <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		COUNTER_128M <= COUNTER_128M + 1;
	end if;
end process;


--process(pl_rsten,clk_adc0_0)
--begin
--	if pl_rsten = '0' then
--		COUNTER_ADC_0 <= (others => '0');
--	elsif clk_adc0_0'event and clk_adc0_0 = '1' then
--		COUNTER_ADC_0 <= COUNTER_ADC_0 + 1;
--	end if;
--end process;

--process(pl_rsten,clk_adc1_0)
--begin
--	if pl_rsten = '0' then
--		COUNTER_ADC_1 <= (others => '0');
--	elsif clk_adc1_0'event and clk_adc1_0 = '1' then
--		COUNTER_ADC_1 <= COUNTER_ADC_1 + 1;
--	end if;
--end process;

--process(pl_rsten,clk_dac0_0)
--begin
--	if pl_rsten = '0' then
--		COUNTER_DAC_0 <= (others => '0');
--	elsif clk_dac0_0'event and clk_dac0_0 = '1' then
--		COUNTER_DAC_0 <= COUNTER_DAC_0 + 1;
--	end if;
--end process;

--process(pl_rsten,clk_dac1_0)
--begin
--	if pl_rsten = '0' then
--		COUNTER_DAC_1 <= (others => '0');
--	elsif clk_dac1_0'event and clk_dac1_0 = '1' then
--		COUNTER_DAC_1 <= COUNTER_DAC_1 + 1;
--	end if;
--end process;


U_ila_data_converter_state : ila_data_converter_state
PORT MAP (
	clk => clk_128M,
	probe0 => COUNTER_128M , 
	probe1 => COUNTER_ADC_0, 
	probe2 => COUNTER_ADC_1,
	probe3 => COUNTER_DAC_0,
	probe4 => COUNTER_DAC_1,
	probe5 => pl_rsten   ,
	probe6 => axi_aresetn  ,
	probe7 => user_lnk_up_0,
	probe8 => gps_1PPS,
	probe9 => gps_pps_counter
);

--CLK_TEST1 <= clk_128M;
--CLK_TEST2 <= clk_adc0_0;
--CLK_TEST3 <= clk_adc1_0;
--CLK_TEST4 <= clk_dac0_0;

--U7 : dds_DA_input 
--port map ( 
--       clk                     =>   clk_128M                ,
--       reset                   =>   pl_rsten                ,
--       flag_10M_start          =>   flag_10M_start          ,
--       s_axis_phase_inc        =>   s_axis_phase_inc        ,   
--       s_axis_phase_offset_0   =>   s_axis_phase_offset_0   ,
--       s_axis_phase_offset_1   =>   s_axis_phase_offset_1   ,
--       s_axis_phase_offset_2   =>   s_axis_phase_offset_2   ,
--       s_axis_phase_offset_3   =>   s_axis_phase_offset_3   ,
--       s_axis_phase_offset_4   =>   s_axis_phase_offset_4   ,
--       s_axis_phase_offset_5   =>   s_axis_phase_offset_5   ,
--       s_axis_phase_offset_6   =>   s_axis_phase_offset_6   ,
--       s_axis_phase_offset_7   =>   s_axis_phase_offset_7   ,
--       dout_mod_I_0_100M       =>   s00_axis_tdata_0(15 downto 0)      ,
--       dout_mod_Q_0_100M       =>   s00_axis_tdata_0(31 downto 16)     ,
--       dout_mod_I_1_100M       =>   s00_axis_tdata_0(47 downto 32)     ,
--       dout_mod_Q_1_100M       =>   s00_axis_tdata_0(63 downto 48)     ,
--       dout_mod_I_2_100M       =>   s00_axis_tdata_0(79 downto 64)     ,
--       dout_mod_Q_2_100M       =>   s00_axis_tdata_0(95 downto 80)     ,
--       dout_mod_I_3_100M       =>   s00_axis_tdata_0(111 downto 96)    ,
--       dout_mod_Q_3_100M       =>   s00_axis_tdata_0(127 downto 112)   ,
--       dout_mod_I_4_100M       =>   s00_axis_tdata_0(143 downto 128)   ,
--       dout_mod_Q_4_100M       =>   s00_axis_tdata_0(159 downto 144)   ,
--       dout_mod_I_5_100M       =>   s00_axis_tdata_0(175 downto 160)   ,
--       dout_mod_Q_5_100M       =>   s00_axis_tdata_0(191 downto 176)   ,
--       dout_mod_I_6_100M       =>   s00_axis_tdata_0(207 downto 192)   ,
--       dout_mod_Q_6_100M       =>   s00_axis_tdata_0(223 downto 208)   ,
--       dout_mod_I_7_100M       =>   s00_axis_tdata_0(239 downto 224)   ,
--       dout_mod_Q_7_100M       =>   s00_axis_tdata_0(255 downto 240)   
--);

--U8: timebase_control 
--port map
--(
--    reset => pl_rsten,                                  
--    clk => clk_128M,
--    EN_timebase => EN_timebase,
--    ----	配置参数	----                                                     
--    num_frame_timeslot => num_frame_timeslot,
--    num_preframe_timeslot => num_preframe_timeslot,    
--    num_payloadframe_timeslot => num_payloadframe_timeslot,
--    num_timeslot  => num_timeslot,
--    we_RAM_timeslot_confiuration => we_RAM_timeslot_confiuration,
--    din_RAM_timeslot_confiuration => din_RAM_timeslot_confiuration,
--    ----	时隙号修正	----	                                                   
----    flag_timeslot_adj => flag_timeslot_adj,
--    flag_timeslot_adj =>flag_brd_acquisition,
--    value_timeslot_adj => value_timeslot_adj,
--    state_timeslot_adj => state_timeslot_adj,
--    ----	时基修正	----	                                                    
--    flag_acquisition_timebase_adj => flag_brd_acquisition,
--    flag_CRC_timebase_adj  => flag_CRC_timebase_adj,
--    flag_timeslot_switch   => flag_timeslot_switch ,
--    length_mod             => length_mod           ,
--    length_mod_offset      => length_mod_offset           ,
--    TDMA_SPMA_switch      =>  TDMA_SPMA_switch   ,
--    ----	时标信号输出	----	                                                  
    
--    flag_frame_tx  => flag_timebase_frame_start,
--    flag_frame_head_tx => flag_timebase_frame_head,
--    rx_timestamp_frame_num  => rx_timestamp_frame_num,
--    rdy_sync_acquisition    => rdy_sync_acquisition,
--    speed_control => speed_control
--);

din_rx_I_Q_0 <= din_rx_Q_0 & din_rx_I_0;
din_rx_I_Q_1 <= din_rx_Q_1 & din_rx_I_1;
din_rx_I_Q_2 <= din_rx_Q_2 & din_rx_I_2;
din_rx_I_Q_3 <= din_rx_Q_3 & din_rx_I_3;
din_rx_I_Q_4 <= din_rx_Q_4 & din_rx_I_4;
din_rx_I_Q_5 <= din_rx_Q_5 & din_rx_I_5;
din_rx_I_Q_6 <= din_rx_Q_6 & din_rx_I_6;
din_rx_I_Q_7 <= din_rx_Q_7 & din_rx_I_7;

fft_rsten <= pl_rsten and LNA_TTL_in;

--U9: fft
--port map
--(
--    reset             =>  pl_rsten,
--    clk               =>  clk_128M,

--    data_in_0         =>     din_rx_I_Q_0,
--    data_in_1         =>     din_rx_I_Q_1,
--    data_in_2         =>     din_rx_I_Q_2,
--    data_in_3         =>     din_rx_I_Q_3,
--    data_in_4         =>     din_rx_I_Q_4,
--    data_in_5         =>     din_rx_I_Q_5,
--    data_in_6         =>     din_rx_I_Q_6,
--    data_in_7         =>     din_rx_I_Q_7,
    
--    reg_fft_tap_select  =>   "001",        
--    flag_rdy            =>   flag_fft_rdy,
--    num_valid           =>   "10000000000000000",
--    irq_fft_valid       =>   irq_fft_valid,
    
--    fft_bram_reset      =>   fft_bram_reset,
--    flag_bram_addr_a_1  =>   flag_fft_bram_addrb,
--    bram_rddata_a_1     =>   fft_bram_rddata,
--    LNA_TTL_in          =>   LNA_TTL_in,

--    irq                 =>   gpio_rtl_tri_i_0(0)

--);

U10_0 : ila_dds
PORT MAP(
    clk => clk_128M,
    probe0  =>  phase_PINC_0            ,
    probe1  =>  phase_POFF_0_tunnel0    ,
    probe2  =>  phase_POFF_1_tunnel0    ,
    probe3  =>  phase_POFF_2_tunnel0    ,
    probe4  =>  phase_POFF_3_tunnel0    ,
    probe5  =>  phase_POFF_4_tunnel0    ,
    probe6  =>  phase_POFF_5_tunnel0    ,
    probe7  =>  phase_POFF_6_tunnel0    ,
    probe8  =>  phase_POFF_7_tunnel0    ,
    probe9  =>  phase_PINC_1            ,
    probe10 =>  phase_POFF_0_tunnel1    ,
    probe11 =>  phase_POFF_1_tunnel1    ,
    probe12 =>  phase_POFF_2_tunnel1    ,
    probe13 =>  phase_POFF_3_tunnel1    ,
    probe14 =>  phase_POFF_4_tunnel1    ,
    probe15 =>  phase_POFF_5_tunnel1    ,
    probe16 =>  phase_POFF_6_tunnel1    ,
    probe17 =>  phase_POFF_7_tunnel1    ,
    probe18 =>  phase_PINC_2            ,
    probe19 =>  phase_POFF_0_tunnel2    ,
    probe20 =>  phase_POFF_1_tunnel2    ,
    probe21 =>  phase_POFF_2_tunnel2    ,
    probe22 =>  phase_POFF_3_tunnel2    ,
    probe23 =>  phase_POFF_4_tunnel2    ,
    probe24 =>  phase_POFF_5_tunnel2    ,
    probe25 =>  phase_POFF_6_tunnel2    ,
    probe26 =>  phase_POFF_7_tunnel2    ,
    probe27 =>  phase_PINC_3            ,
    probe28 =>  phase_POFF_0_tunnel3    ,
    probe29 =>  phase_POFF_1_tunnel3    ,
    probe30 =>  phase_POFF_2_tunnel3    ,
    probe31 =>  phase_POFF_3_tunnel3    ,
    probe32 =>  phase_POFF_4_tunnel3    ,
    probe33 =>  phase_POFF_5_tunnel3    ,
    probe34 =>  phase_POFF_6_tunnel3    ,
    probe35 =>  phase_POFF_7_tunnel3    ,
    probe36 =>  phase_PINC_4            ,
    probe37 =>  phase_POFF_0_tunnel4    ,
    probe38 =>  phase_POFF_1_tunnel4    ,
    probe39 =>  phase_POFF_2_tunnel4    ,
    probe40 =>  phase_POFF_3_tunnel4    ,
    probe41 =>  phase_POFF_4_tunnel4    ,
    probe42 =>  phase_POFF_5_tunnel4    ,
    probe43 =>  phase_POFF_6_tunnel4    ,
    probe44 =>  phase_POFF_7_tunnel4    ,
    probe45 =>  phase_PINC_5            ,
    probe46 =>  phase_POFF_0_tunnel5    ,
    probe47 =>  phase_POFF_1_tunnel5    ,
    probe48 =>  phase_POFF_2_tunnel5    ,
    probe49 =>  phase_POFF_3_tunnel5    ,
    probe50 =>  phase_POFF_4_tunnel5    ,
    probe51 =>  phase_POFF_5_tunnel5    ,
    probe52 =>  phase_POFF_6_tunnel5    ,
    probe53 =>  phase_POFF_7_tunnel5    ,
    probe54 =>  tunnel_switch  
);

U10_1 : ila_dds
PORT MAP(
    clk => clk_128M,
    probe0  =>  phase_PINC_6            ,
    probe1  =>  phase_POFF_0_tunnel6    ,
    probe2  =>  phase_POFF_1_tunnel6    ,
    probe3  =>  phase_POFF_2_tunnel6    ,
    probe4  =>  phase_POFF_3_tunnel6    ,
    probe5  =>  phase_POFF_4_tunnel6    ,
    probe6  =>  phase_POFF_5_tunnel6    ,
    probe7  =>  phase_POFF_6_tunnel6    ,
    probe8  =>  phase_POFF_7_tunnel6    ,
    probe9  =>  phase_PINC_7            ,
    probe10 =>  phase_POFF_0_tunnel7    ,
    probe11 =>  phase_POFF_1_tunnel7    ,
    probe12 =>  phase_POFF_2_tunnel7    ,
    probe13 =>  phase_POFF_3_tunnel7    ,
    probe14 =>  phase_POFF_4_tunnel7    ,
    probe15 =>  phase_POFF_5_tunnel7    ,
    probe16 =>  phase_POFF_6_tunnel7    ,
    probe17 =>  phase_POFF_7_tunnel7    ,
    probe18 =>  phase_PINC_8            ,
    probe19 =>  phase_POFF_0_tunnel8    ,
    probe20 =>  phase_POFF_1_tunnel8    ,
    probe21 =>  phase_POFF_2_tunnel8    ,
    probe22 =>  phase_POFF_3_tunnel8    ,
    probe23 =>  phase_POFF_4_tunnel8    ,
    probe24 =>  phase_POFF_5_tunnel8    ,
    probe25 =>  phase_POFF_6_tunnel8    ,
    probe26 =>  phase_POFF_7_tunnel8    ,
    probe27 =>  phase_PINC_9            ,
    probe28 =>  phase_POFF_0_tunnel9    ,
    probe29 =>  phase_POFF_1_tunnel9    ,
    probe30 =>  phase_POFF_2_tunnel9    ,
    probe31 =>  phase_POFF_3_tunnel9    ,
    probe32 =>  phase_POFF_4_tunnel9    ,
    probe33 =>  phase_POFF_5_tunnel9    ,
    probe34 =>  phase_POFF_6_tunnel9    ,
    probe35 =>  phase_POFF_7_tunnel9    ,
    probe36 =>  phase_PINC_10           ,
    probe37 =>  phase_POFF_0_tunnel10   ,
    probe38 =>  phase_POFF_1_tunnel10   ,
    probe39 =>  phase_POFF_2_tunnel10   ,
    probe40 =>  phase_POFF_3_tunnel10   ,
    probe41 =>  phase_POFF_4_tunnel10   ,
    probe42 =>  phase_POFF_5_tunnel10   ,
    probe43 =>  phase_POFF_6_tunnel10   ,
    probe44 =>  phase_POFF_7_tunnel10   ,
    probe45 =>  phase_PINC_11           ,
    probe46 =>  phase_POFF_0_tunnel11   ,
    probe47 =>  phase_POFF_1_tunnel11   ,
    probe48 =>  phase_POFF_2_tunnel11   ,
    probe49 =>  phase_POFF_3_tunnel11   ,
    probe50 =>  phase_POFF_4_tunnel11   ,
    probe51 =>  phase_POFF_5_tunnel11   ,
    probe52 =>  phase_POFF_6_tunnel11   ,
    probe53 =>  phase_POFF_7_tunnel11   ,
    probe54 =>  tunnel_switch  
);

U_vio_SEL : vio_SEL
  PORT MAP (
    clk => CLK_100M,
    probe_out0(0) => SEL_REFCLK_PLL_RF
  );
  
  U_vio_ENABLE_POWER : vio_ENABLE_POWER
  PORT MAP (
    clk => CLK_100M,
    probe_out0(0) => EN_PWR_CPT
  );

  U_vio_Out_1pps_cpt : vio_Out_1pps_cpt
  PORT MAP (
    clk => CLK_100M,
    probe_out0(0) => gps_pps_counter_reset
  );

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:53:09 10/17/2013 
-- Design Name: 
-- Module Name:    arm_interface_write_1 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity arm_interface_write_1 is
    Port (
		reset 	: in  STD_LOGIC;
		clk 	: in  STD_LOGIC;
        reset_128M 	: in  STD_LOGIC;
		clk_128M   	: in  STD_LOGIC;
		----    EMC interface    ----
		ps_wen_128M  : in    std_logic;
		ps_cen_128M  : in    std_logic;
		ps_dout_128M : in    std_logic_vector(15 downto 0);
		ps_addr_128M : in    std_logic_vector(11 downto 0);
		
		LNA_switch_hand_1 : out  STD_LOGIC;	
        LNA_switch_hand_2 : out  STD_LOGIC;
        PA_switch_hand : out  STD_LOGIC;
		----    K7 FPGA加载标志    ----
		PROGRAM_CONFIG_FPGA2  :  out std_logic;
		----    K7 时间同步计数器清零标志    ----
		reset_time            :  out std_logic;
--		----    AD9520相关    ----
--		flag_AD9520_config             : out   std_logic;
--		reg_AD9520_config_wrdata       : out   std_logic_vector(23 downto 0);
--        reset_PLL       : out   std_logic;

--		----    AD9680相关    ----
--		flag_AD9680_config             : out   std_logic;
--		reg_AD9680_config_wrdata       : out   std_logic_vector(15 downto 0);

--        ----    AD9680_2相关    ----
--        flag_AD9680_2_config             : out   std_logic;
--        reg_AD9680_2_config_wrdata       : out   std_logic_vector(15 downto 0);
		
--		jesd_reset						: out std_logic;
--		jesd_reset_n					: out std_logic;
--		ps_ReSync						: out std_logic;
--		----    AD9739相关    ----
--		flag_AD9739_config             : out   std_logic;
--		reg_AD9739_config_wrdata       : out   std_logic_vector(15 downto 0);
		
--		----    AD5XXX相关    ----   --AD5XXX 用于校准AD9520 ？
--		flag_AD5XXX_config : out  STD_LOGIC;
--		reg_AD5XXX_wrdata : out  STD_LOGIC_VECTOR (15 downto 0);
--		reg_AD5XXX_mode     : out std_logic_vector(3 downto 0);
--        reg_LDAC        : out  STD_LOGIC;
		
		contrl_8506 : out STD_LOGIC_VECTOR (15 downto 0);       ---- 光纤配置

		reg_initial_reset : out  STD_LOGIC_VECTOR (2 downto 0);
		reg_tx_mode : out  STD_LOGIC_VECTOR (7 downto 0);
		reg_tx_mode_para : out  STD_LOGIC_VECTOR (7 downto 0); 			  

		----	初始化		----	 
		ram_PN_sync_we : out  STD_LOGIC;
		ram_PN_sync_din : out  STD_LOGIC_VECTOR (15 downto 0);
		ram_PN_PAn_we : out  STD_LOGIC;
		ram_PN_PAn_din : out  STD_LOGIC_VECTOR (15 downto 0);
		ram_PN_scramble_we : out  STD_LOGIC;
		ram_PN_scramble_din : out  STD_LOGIC_VECTOR (15 downto 0);
		ram_PN_interleave_we : out  STD_LOGIC;
		ram_PN_interleave_din : out  STD_LOGIC_VECTOR (15 downto 0);
		
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
        ----------------------------数字衰减----------------
        shift_config_value : out std_logic_vector(3 downto 0);
		shift_din_value    : out std_logic_vector(3 downto 0);
		----   PLL   ----
--		agc_arm_ctrl_mode : out  STD_LOGIC_VECTOR (15 downto 0);		--- 0正常，1arm控
		agc_arm_ctrl_DVGA1_i : out  STD_LOGIC_vector(5 downto 0);
		agc_arm_ctrl_DVGA2_i : out  STD_LOGIC_vector(5 downto 0);
--		agc_arm_ctrl_i : out  STD_LOGIC;
		agc_arm_ctrl_DVGA1_q : out  STD_LOGIC_vector(5 downto 0);
--		agc_arm_ctrl_DVGA2_q : out  STD_LOGIC_vector(5 downto 0);
		agc_arm_ctrl_q : out  STD_LOGIC;	
		----	发射数据	----
		ram_tx_interface_buffer_we : out  STD_LOGIC;
		ram_tx_interface_buffer_din : out  STD_LOGIC_VECTOR (15 downto 0);
		ram_tx_interface_buffer_din_type : out  STD_LOGIC_VECTOR (1 downto 0);
		ram_tx_interface_buffer_we_1 : out  STD_LOGIC;
		ram_tx_interface_buffer_din_1 : out  STD_LOGIC_VECTOR (15 downto 0);
		ram_tx_interface_buffer_din_type_1 : out  STD_LOGIC_VECTOR (1 downto 0);		
		ram_tx_interface_buffer_we_2 : out  STD_LOGIC;
		ram_tx_interface_buffer_din_2 : out  STD_LOGIC_VECTOR (15 downto 0);
		ram_tx_interface_buffer_din_type_2 : out  STD_LOGIC_VECTOR (1 downto 0);
		
		packet_time_interval : out std_logic_vector(31 downto 0);
		pulse_framer_length : out std_logic_vector(15 downto 0);
		----	接收数据	----
		flag_rd_arm_onepacket : out  STD_LOGIC;
		flag_rd_arm_oneint : out  STD_LOGIC;  
		flag_rd_srio_onepacket : out std_logic;     ----K7 SRIO
        flag_rd_srio_oneint : out std_logic;
		falg_irq_k_end : out std_logic;  
		falg_irq_k_end_k : out std_logic;
		----   配置接收参数   ---
		sync_bit_pre_rx : out  sync_bits_array_type(0 to 14);
		sync_bit_post_rx : out  sync_bits_array_type(0 to 14);
		pattern_freq_rx_x1 : out  std_logic_vector (47 downto 0);
		pattern_freq_rx_x2 : out  std_logic_vector (47 downto 0);
		pattern_freq_rx_x3 : out  std_logic_vector (47 downto 0);
		pattern_freq_rx_x4 : out  std_logic_vector (47 downto 0);
		time_hopping_rx_x1 : out  addr_offset_array_type(0 to 14);
		time_hopping_rx_x2 : out  addr_offset_array_type(0 to 14);
		time_hopping_rx_x3 : out  addr_offset_array_type(0 to 14);
		time_hopping_rx_x4 : out  addr_offset_array_type(0 to 14);
		PN_deinterleave : out  PN_deinterleave_array_type(0 to 11);
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
		flag_tx_nread  : out std_logic;
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
		
		channel_capure_threshold : out std_logic_vector(15 downto 0);		---- 24位捕获寄存器判决门限

		Antenna_switch_local			: out  std_logic_vector(15 downto 0);
		----   频点择优模式   ----
		dds_clr : out  STD_LOGIC;
		dds_freq_para_local : out  dds_para_array_type(15 downto 0);
		counter_switch : out std_logic;
		----	TEST	----
		arm_config_power_control : out std_logic_vector(3 downto 0);
		arm_config_switch : out std_logic_vector(2 downto 0);
--		TX_LE : out  STD_LOGIC;
		----    time offset    ----
        offset_time_2 : out std_logic_vector(15 downto 0);
        offset_time_1 : out std_logic_vector(15 downto 0);
        offset_time_0 : out std_logic_vector(15 downto 0);
        flag_offset_time_adjust  : out std_logic;
 		----    time offset    ----
        offset_time_2_k7            : out std_logic_vector(15 downto 0);
        offset_time_1_k7            : out std_logic_vector(15 downto 0);
        offset_time_0_k7            : out std_logic_vector(15 downto 0);
        flag_offset_time_adjust_k7  : out std_logic;  
        STATUS_ADHOC  :  out std_logic;
        
        		----   PLL   ----
        flag_RF_PLL_TxRx_configuration : out  STD_LOGIC;
        flag_RF_PLL_CLK_configuration : out  STD_LOGIC;
        data_RF_PLL_configuration : out  STD_LOGIC_VECTOR (31 downto 0);        
--        RF_PLL_CEN1 : out  STD_LOGIC;
--        RF_PLL_CEN2 : out  STD_LOGIC;    
        
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
		
		------ 精时间同步  -------
		EN_timestamp_cor : out  STD_LOGIC;
        flag_timestamp_cor : out  STD_LOGIC;
        value_timestamp_cor : out  STD_LOGIC_VECTOR (47 downto 0);	
        polarity_cor : out  STD_LOGIC;
        
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
        work_mod : out STD_LOGIC_VECTOR (1 downto 0); ---自动模式和手动模式
        wave_mod : out std_logic ;  ---发射单载波还是发包
        data_en : out std_logic  ;  ---单载波发射控制开关
        PA_switch_ps : out std_logic;
        LNA_switch_ps: out    std_logic;
        T_R_TTL_ps : out    std_logic;
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
        flag_lock_reg_PS_read_rx              : out std_logic ;
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
        master_or_slave           : out std_logic_vector(1 downto 0);
        length_mod                : out  std_logic_vector(15 downto 0);--配置帧单元bit数
        length_mod_offset         : out  std_logic_vector(15 downto 0);
        TDMA_SPMA_switch          : out  STD_LOGIC;	-- TDMA为0，SPMA为1
        ----  GPS使能   ----
        en_gps                                : out std_logic ;
        
        ----    fft     ----
        irq1_valid          : out std_logic;
        fft_bram_reset      : out std_logic;
        flag_fft_rdy        : out std_logic;
        fft_data            : in std_logic_vector(15 downto 0);
        flag_fft_bram_addrb : out std_logic;
        
        reset_DDS_fft       : out STD_LOGIC;
        phase_PINC_fft      : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_0_fft    : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_1_fft    : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_2_fft    : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_3_fft    : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_4_fft    : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_5_fft    : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_6_fft    : out STD_LOGIC_VECTOR (31 downto 0);
        phase_POFF_7_fft    : out STD_LOGIC_VECTOR (31 downto 0);
        reg_fft_tap_select  : out std_logic_vector(2 downto 0);
        num_valid           : out std_logic_vector(13 downto 0);
        addup_N             : out std_logic_vector(15 downto 0);
        fft_stop            : out std_logic;
        shift_bits_fft      : out std_logic_vector(4 downto 0);
        
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
        configurable_freq_hopping_phase_offset_7          : out   std_logic_vector(15 downto 0)
	);
end arm_interface_write_1;

architecture Behavioral of arm_interface_write_1 is	
------------------------------地址定义-------------------------------------------
----		common
constant ADDR_REG_INITIAL : std_logic_vector(11 downto 0) := x"002";
constant ADDR_REG_TX_MODE : std_logic_vector(11 downto 0) := x"004";
constant ADDR_TX_PACKET_TIME_INTERVAL_low : std_logic_vector(11 downto 0) := x"006";
constant ADDR_TX_PACKET_TIME_INTERVAL_high : std_logic_vector(11 downto 0) := x"206";
constant ADDR_PULSE_NUM_THRESHOLD : std_logic_vector(11 downto 0) := x"008";
constant ADDR_SYNC_XCORR_THRESHOLD : std_logic_vector(11 downto 0) := x"00A";
constant ADDR_counter_switch: std_logic_vector(11 downto 0) := x"00C";
constant ADDR_ANT_SEL: std_logic_vector(11 downto 0) := x"00E";  --天线选择
constant ADDR_PULSE_FRAMER_LENGTH : std_logic_vector(11 downto 0) := x"0E6";
----		DA9739
constant ADDR_REG_AD9739_CONFIG_WRDATA : std_logic_vector(11 downto 0) := x"010";
----		AD9680
constant ADDR_REG_AD9680_CONFIG_WRDATA : std_logic_vector(11 downto 0) := x"012";
constant ADDR_REG_AD9680_2_CONFIG_WRDATA : std_logic_vector(11 downto 0) := x"03C"; --重复使用

----  	RF_PLL
constant ADDR_RF_PLL_TxRx_LOW                                                  : std_logic_vector(11 downto 0) := x"014";
constant ADDR_RF_PLL_TxRx_HIGH                                                 : std_logic_vector(11 downto 0) := x"016";
constant ADDR_RF_PLL_CLK_LOW                                                   : std_logic_vector(11 downto 0) := x"018";
constant ADDR_RF_PLL_CLK_HIGH                                                  : std_logic_vector(11 downto 0) := x"01A";
constant ADDR_RF_PLL_CEN                                                       : std_logic_vector(11 downto 0) := x"01C";
constant ADDR_RF_PLL_BOTH_HIGH                                                 : std_logic_vector(11 downto 0) := x"01E";

----		PN library
constant ADDR_PN_sync : std_logic_vector(11 downto 0) := x"020";
constant ADDR_PN_PAn : std_logic_vector(11 downto 0) := x"022";
constant ADDR_PN_scramble : std_logic_vector(11 downto 0) := x"024";
constant ADDR_PN_interleave : std_logic_vector(11 downto 0) := x"026";
---------AD5XXX-----------------------------
constant ADDR_AD5XXX_DATA:std_logic_vector(11 downto 0) := x"028";
constant ADDR_AD5XXX_mode:std_logic_vector(11 downto 0) := x"02a";
---------AD9520-----------------------------
constant ADDR_REG_AD9520_CONFIG_WRDATA_H:std_logic_vector(11 downto 0) := x"030";
constant ADDR_REG_AD9520_CONFIG_WRDATA_L:std_logic_vector(11 downto 0) := x"032";
constant ADDR_REG_AD9520_RESET_PLL:std_logic_vector(11 downto 0)        := x"034";

---------光纤-----------------------------
constant ADDR_CONTRL_8506:std_logic_vector(11 downto 0)        := x"03e";

----		tx
constant ADDR_TX_DATA : std_logic_vector(11 downto 0) := x"042";
constant ADDR_FREQ_HOPPING_PN_SYNC_ADDR : std_logic_vector(11 downto 0) := x"044";
constant ADDR_TIME_HOPPING : std_logic_vector(11 downto 0) := x"046";	
constant ADDR_TX_PULSE_TYPE : std_logic_vector(11 downto 0) := x"048";
constant ADDR_TX_DATA_1 : std_logic_vector(11 downto 0) := x"0C2";
constant ADDR_FREQ_HOPPING_PN_SYNC_ADDR_1 : std_logic_vector(11 downto 0) := x"0C4";
constant ADDR_TIME_HOPPING_1 : std_logic_vector(11 downto 0) := x"0C6";	
constant ADDR_TX_PULSE_TYPE_1 : std_logic_vector(11 downto 0) := x"0C8";
constant ADDR_TX_DATA_2 : std_logic_vector(11 downto 0) := x"0D2";
constant ADDR_FREQ_HOPPING_PN_SYNC_ADDR_2 : std_logic_vector(11 downto 0) := x"0D4";
constant ADDR_TIME_HOPPING_2 : std_logic_vector(11 downto 0) := x"0D6";	
constant ADDR_TX_PULSE_TYPE_2 : std_logic_vector(11 downto 0) := x"0D8";

----        time sync        ----
constant ADDR_offset_2 : std_logic_vector(11 downto 0) := x"036";
constant ADDR_offset_1 : std_logic_vector(11 downto 0) := x"038";
constant ADDR_offset_0 : std_logic_vector(11 downto 0) := x"03a";
----        time sync k7       ----
constant ADDR_offset_2_k7 : std_logic_vector(11 downto 0) := x"0E0";
constant ADDR_offset_1_k7 : std_logic_vector(11 downto 0) := x"0E2";
constant ADDR_offset_0_k7 : std_logic_vector(11 downto 0) := x"0E4";

----		AGC
constant ADDR_AGC_DVGA_I : std_logic_vector(11 downto 0) := x"0BA";
constant ADDR_AGC_DVGA_Q : std_logic_vector(11 downto 0) := x"0BC";
constant ADDR_AGC_DVGA_MODE : std_logic_vector(11 downto 0) := x"0BE";
----		rx
constant ADDR_RX_DATA : std_logic_vector(11 downto 0) := x"050";
constant ADDR_SYNC_BIT_PRE_RX_LOW : std_logic_vector(11 downto 0) := x"060";
constant ADDR_SYNC_BIT_PRE_RX_HIGH : std_logic_vector(11 downto 0) := x"062";
constant ADDR_SYNC_BIT_POST_RX_LOW : std_logic_vector(11 downto 0) := x"064";
constant ADDR_SYNC_BIT_POST_RX_HIGH : std_logic_vector(11 downto 0) := x"066";
constant ADDR_FLAG_IRQ_END : std_logic_vector(11 downto 0) := x"0B8";


constant ADDR_PATTERN_FREQ_RX_X1_LOW : std_logic_vector(11 downto 0) := x"070";
constant ADDR_PATTERN_FREQ_RX_X1_MIDDLE : std_logic_vector(11 downto 0) := x"072";
constant ADDR_PATTERN_FREQ_RX_X1_HIGH : std_logic_vector(11 downto 0) := x"074";
constant ADDR_TIME_HOPPING_X1 : std_logic_vector(11 downto 0) := x"076";
constant ADDR_PATTERN_FREQ_RX_X3_LOW : std_logic_vector(11 downto 0) := x"078";
constant ADDR_PATTERN_FREQ_RX_X3_MIDDLE : std_logic_vector(11 downto 0) := x"07a";
constant ADDR_PATTERN_FREQ_RX_X3_HIGH : std_logic_vector(11 downto 0) := x"07c";
constant ADDR_TIME_HOPPING_X3 : std_logic_vector(11 downto 0) := x"07e";
constant ADDR_PATTERN_FREQ_RX_X2_LOW : std_logic_vector(11 downto 0) := x"080";
constant ADDR_PATTERN_FREQ_RX_X2_MIDDLE : std_logic_vector(11 downto 0) := x"082";
constant ADDR_PATTERN_FREQ_RX_X2_HIGH : std_logic_vector(11 downto 0) := x"084";
constant ADDR_TIME_HOPPING_X2 : std_logic_vector(11 downto 0) := x"086";
constant ADDR_PATTERN_FREQ_RX_X4_LOW : std_logic_vector(11 downto 0) := x"088";
constant ADDR_PATTERN_FREQ_RX_X4_MIDDLE : std_logic_vector(11 downto 0) := x"08a";
constant ADDR_PATTERN_FREQ_RX_X4_HIGH : std_logic_vector(11 downto 0) := x"08c";
constant ADDR_TIME_HOPPING_X4 : std_logic_vector(11 downto 0) := x"08e";
constant ADDR_PN_DEINTERLEAVE : std_logic_vector(11 downto 0) := x"090";
constant ADDR_RX_PN_DESCRAMBLE : std_logic_vector(11 downto 0) := x"092";
constant ADDR_TX_NREAD : std_logic_vector(11 downto 0) := x"094";--K7
constant ADDR_RX_CONFIG_COMPLETE : std_logic_vector(11 downto 0) := x"06c";--配置完成，开始接受 start_rx
constant ADDR_RX_RATE_MODE : std_logic_vector(11 downto 0) := x"06e"; --100/000
constant ADDR_POINT_TEST_RX : std_logic_vector(11 downto 0) := x"06a";

----	freq_mode
constant ADDR_FREQ_MODE : std_logic_vector(11 downto 0) := x"0a0";
constant ADDR_FREQ_DDS_PARA : std_logic_vector(11 downto 0) := x"0a2";
constant ADDR_FREQ_DDS_NEXT : std_logic_vector(11 downto 0) := x"0a4";
constant ADDR_FREQ_CONFIG_COMPLETE : std_logic_vector(11 downto 0) := x"0a6";

----	TEST
constant ADDR_POWER_CONTROL : std_logic_vector(11 downto 0) := x"0F2";
constant ADDR_PA_SWITCH : std_logic_vector(11 downto 0) := x"0F4";

----   JESD
constant ADDR_REG_jesd_reset : std_logic_vector(11 downto 0) := x"0F6";
constant ADDR_REG_ps_ReSync : std_logic_vector(11 downto 0) := x"0F8";
constant ADDR_CHANNEL_BUSY_THRESHOLD : std_logic_vector(11 downto 0) := x"0FA";
constant ADDR_CHANNEL_CAPTURE_THRESHOLD : std_logic_vector(11 downto 0) := x"0FC";

constant ADDR_STATUS_ADHOC : std_logic_vector(11 downto 0) := x"0FE";
constant ADDR_REG_jesd_reset_AD2 : std_logic_vector(11 downto 0) := x"0B6";

constant ADDR_PROGRAM_CONFIG_FPGA2 : std_logic_vector(11 downto 0) := x"068";
----    K7 时间同步计数器清零标志    ----
constant ADDR_RESET_TIME : std_logic_vector(11 downto 0) := x"0E8";
----K7 jesd
constant ADDR_ILA : std_logic_vector(11 downto 0) := x"052";
constant ADDR_SRC : std_logic_vector(11 downto 0) := x"054";
constant ADDR_MOD : std_logic_vector(11 downto 0) := x"056";
constant ADDR_F : std_logic_vector(11 downto 0) := x"058";
constant ADDR_K : std_logic_vector(11 downto 0) := x"05A";
constant ADDR_LANES : std_logic_vector(11 downto 0) := x"05C";
constant ADDR_SUBCLASS : std_logic_vector(11 downto 0) := x"05E";
constant ADDR_DELAY : std_logic_vector(11 downto 0) := x"0B0";
constant ADDR_ERRO : std_logic_vector(11 downto 0) := x"0B2";
constant ADDR_ERROO : std_logic_vector(11 downto 0) := x"0B4";

constant ADDR_LNA_switch_hand_1 : std_logic_vector(11 downto 0) := x"040"; 
constant ADDR_LNA_switch_hand_2 : std_logic_vector(11 downto 0) := x"04a";
constant ADDR_PA_switch_hand    : std_logic_vector(11 downto 0) := x"04c";

-------------- 初始化完成状态标志位 -----------
constant ADDR_initial_complete_state    : std_logic_vector(11 downto 0) := x"100";


-------------- 精时间同步 -----------
constant ADDR_EN_timestamp_cor                       : std_logic_vector(11 downto 0) := x"152";
constant ADDR_flag_timestamp_cor                     : std_logic_vector(11 downto 0) := x"154";
constant ADDR_polarity_cor                           : std_logic_vector(11 downto 0) := x"156";

--constant ADDR_value_timestamp_cor_0                  : std_logic_vector(11 downto 0) := x"158";
constant ADDR_value_timestamp_cor_0                  : std_logic_vector(11 downto 0) := x"15A";
constant ADDR_value_timestamp_cor_1                  : std_logic_vector(11 downto 0) := x"15C";
constant ADDR_value_timestamp_cor_2                  : std_logic_vector(11 downto 0) := x"15E";



----  多普勒频偏    ----
constant ADDR_DOPPLER_FREQ : std_logic_vector(11 downto 0) := x"160";
constant ADDR_DOPPLER_FREQ_init_0 : std_logic_vector(11 downto 0) := x"164";
constant ADDR_DOPPLER_FREQ_init_1 : std_logic_vector(11 downto 0) := x"166";
constant ADDR_DOPPLER_FREQ_init_2 : std_logic_vector(11 downto 0) := x"168";
constant ADDR_DOPPLER_FREQ_init_3 : std_logic_vector(11 downto 0) := x"16A";
constant ADDR_DOPPLER_FREQ_init_4 : std_logic_vector(11 downto 0) := x"16C";
constant ADDR_DOPPLER_FREQ_init_5 : std_logic_vector(11 downto 0) := x"16E";
constant ADDR_DOPPLER_FREQ_init_6 : std_logic_vector(11 downto 0) := x"170";
constant ADDR_DOPPLER_FREQ_init_7 : std_logic_vector(11 downto 0) := x"172";

--------   射频     --------
constant ADDR_PA_switch_ps : std_logic_vector(11 downto 0) := x"176";
constant ADDR_T_R_TTL : std_logic_vector(11 downto 0) := x"178";
constant ADDR_LNA_switch_ps : std_logic_vector(11 downto 0) := x"18C";
constant ADDR_SW_R0_in_ps   : std_logic_vector(11 downto 0) := x"200";
constant ADDR_SW_R1_in_ps   : std_logic_vector(11 downto 0) := x"202";
constant ADDR_SW_R2_in_ps   : std_logic_vector(11 downto 0) := x"204";
constant ADDR_SW_T_in_ps    : std_logic_vector(11 downto 0) := x"216";
constant ADDR_SEL0_TX_in_ps : std_logic_vector(11 downto 0) := x"218";
constant ADDR_SEL1_TX_in_ps : std_logic_vector(11 downto 0) := x"21A";
constant ADDR_R0 : std_logic_vector(11 downto 0) := x"20A";
constant ADDR_R1 : std_logic_vector(11 downto 0) := x"20C";
constant ADDR_R2 : std_logic_vector(11 downto 0) := x"208";--old20E

constant ADDR_T : std_logic_vector(11 downto 0) := x"17C";
constant ADDR_work_mod : std_logic_vector(11 downto 0) := x"17E";

----- 测试模式 ---------
constant ADDR_pl_mod : std_logic_vector(11 downto 0) := x"162";
constant ADDR_data_en : std_logic_vector(11 downto 0) := x"180";
constant ADDR_board_mod : std_logic_vector(11 downto 0) := x"182";
constant ADDR_wave_mod : std_logic_vector(11 downto 0) := x"184";

------------------agc------------------------------------------------------
constant ADDR_agc_control_mode : std_logic_vector(11 downto 0) := x"18A";
--constant ADDR_mod_envelope : std_logic_vector(11 downto 0) := x"186";
constant ADDR_agc_arm_ctrl_mode : std_logic_vector(11 downto 0) := x"190";		  
constant ADDR_agc_arm_ctrl_12 : std_logic_vector(11 downto 0) := x"192";
constant ADDR_agc_arm_ctrl_DVGA4 : std_logic_vector(11 downto 0) := x"196";

constant ADDR_THRESHOLD_WIDTH : std_logic_vector(11 downto 0) := x"198";
constant ADDR_THRESHOLD_INSIDE : std_logic_vector(11 downto 0) := x"19A";
constant ADDR_THRESHOLD_CENTER : std_logic_vector(11 downto 0) := x"19C";
constant ADDR_RESPONSE_TIME : std_logic_vector(11 downto 0) := x"19E";
----------------------------数字衰减----------------
constant ADDR_shift_config_value :std_logic_vector(11 downto 0) := x"18E";
constant ADDR_shift_din_value:   std_logic_vector(11 downto 0) := x"20E";

---------------------------跳时跳频图案控制----------------------
constant ADDR_EN_time_hopping :   std_logic_vector(11 downto 0) := x"174";

------  DAC 100M输出频率测试    ----
--constant ADDR_flag_10M_start   :  std_logic_vector(11 downto 0) := x"222";
--constant ADDR_DAC_OUTPUT_FREQ_INC : std_logic_vector(11 downto 0) := x"220";
--constant ADDR_DAC_OUTPUT_FREQ_init_0 : std_logic_vector(11 downto 0) := x"224";
--constant ADDR_DAC_OUTPUT_FREQ_init_1 : std_logic_vector(11 downto 0) := x"226";
--constant ADDR_DAC_OUTPUT_FREQ_init_2 : std_logic_vector(11 downto 0) := x"228";
--constant ADDR_DAC_OUTPUT_FREQ_init_3 : std_logic_vector(11 downto 0) := x"22A";
--constant ADDR_DAC_OUTPUT_FREQ_init_4 : std_logic_vector(11 downto 0) := x"22C";
--constant ADDR_DAC_OUTPUT_FREQ_init_5 : std_logic_vector(11 downto 0) := x"22E";
--constant ADDR_DAC_OUTPUT_FREQ_init_6 : std_logic_vector(11 downto 0) := x"230";
--constant ADDR_DAC_OUTPUT_FREQ_init_7 : std_logic_vector(11 downto 0) := x"232";

----  定频模式切换与选择   ----
constant ADDR_flag_freq_hopping_control     : std_logic_vector(11 downto 0) := x"210";
constant ADDR_freq_hopping_select           : std_logic_vector(11 downto 0) := x"212";

----  GPS使能   ----
constant ADDR_en_gps           : std_logic_vector(11 downto 0) := x"214";
---------TDMA---------------
constant ADDR_EN_timebase                               : std_logic_vector(11 downto 0) := x"234";
constant ADDR_num_frame_timeslot                        : std_logic_vector(11 downto 0) := x"236";					
constant ADDR_num_preframe_timeslot                     : std_logic_vector(11 downto 0) := x"238";				
constant ADDR_num_payloadframe_timeslot                 : std_logic_vector(11 downto 0) := x"23A";			
constant ADDR_num_timeslot                              : std_logic_vector(11 downto 0) := x"23C";														
constant ADDR_din_RAM_timeslot_confiuration             : std_logic_vector(11 downto 0) := x"23E";	
constant ADDR_value_timeslot_adj                        : std_logic_vector(11 downto 0) := x"240";	
constant ADDR_speed_control	                            : std_logic_vector(11 downto 0) := x"242";
constant ADDR_master_or_slave                           : std_logic_vector(11 downto 0) := x"244";
constant ADDR_length_mod                                : std_logic_vector(11 downto 0) := x"246";
constant ADDR_length_mod_offset                         : std_logic_vector(11 downto 0) := x"248";
constant ADDR_TDMA_SPMA_switch                          : std_logic_vector(11 downto 0) := x"250";
----  REG_NUM锁存标志    ----
constant ADDR_flag_lock_reg_PS_read           : std_logic_vector(11 downto 0) := x"302";


---- fft ----
constant ADDR_irq1_valid                                      : std_logic_vector(11 downto 0) := x"320";
constant ADDR_fft_bram_reset                                  : std_logic_vector(11 downto 0) := x"322";
constant ADDR_flag_fft_rdy                                    : std_logic_vector(11 downto 0) := x"324";
constant ADDR_fft_data                                        : std_logic_vector(11 downto 0) := x"326";
constant ADDR_flag_fft_bram_addrb                             : std_logic_vector(11 downto 0) := x"328";
constant ADDR_reset_DDS_fft                                   : std_logic_vector(11 downto 0) := x"32A";
constant ADDR_phase_PINC_fft_HIGH                                  : std_logic_vector(11 downto 0) := x"32C";
constant ADDR_phase_PINC_fft_LOW                                   : std_logic_vector(11 downto 0) := x"32E";
constant ADDR_phase_POFF_0_fft_HIGH                                : std_logic_vector(11 downto 0) := x"330";
constant ADDR_phase_POFF_0_fft_LOW                                 : std_logic_vector(11 downto 0) := x"332";
constant ADDR_phase_POFF_1_fft_HIGH                                : std_logic_vector(11 downto 0) := x"334";
constant ADDR_phase_POFF_1_fft_LOW                                 : std_logic_vector(11 downto 0) := x"336";
constant ADDR_phase_POFF_2_fft_HIGH                                : std_logic_vector(11 downto 0) := x"338";
constant ADDR_phase_POFF_2_fft_LOW                                 : std_logic_vector(11 downto 0) := x"33A";
constant ADDR_phase_POFF_3_fft_HIGH                                : std_logic_vector(11 downto 0) := x"33C";
constant ADDR_phase_POFF_3_fft_LOW                                 : std_logic_vector(11 downto 0) := x"33E";
constant ADDR_phase_POFF_4_fft_HIGH                                : std_logic_vector(11 downto 0) := x"340";
constant ADDR_phase_POFF_4_fft_LOW                                 : std_logic_vector(11 downto 0) := x"342";
constant ADDR_phase_POFF_5_fft_HIGH                                : std_logic_vector(11 downto 0) := x"344";
constant ADDR_phase_POFF_5_fft_LOW                                 : std_logic_vector(11 downto 0) := x"346";
constant ADDR_phase_POFF_6_fft_HIGH                                : std_logic_vector(11 downto 0) := x"348";
constant ADDR_phase_POFF_6_fft_LOW                                 : std_logic_vector(11 downto 0) := x"34A";
constant ADDR_phase_POFF_7_fft_HIGH                                : std_logic_vector(11 downto 0) := x"34C";
constant ADDR_phase_POFF_7_fft_LOW                                 : std_logic_vector(11 downto 0) := x"34E";
constant ADDR_reg_fft_tap_select                              : std_logic_vector(11 downto 0) := x"350";
constant ADDR_num_valid                                       : std_logic_vector(11 downto 0) := x"352";
constant ADDR_addup_N                                         : std_logic_vector(11 downto 0) := x"354";
constant ADDR_fft_stop                                        : std_logic_vector(11 downto 0) := x"356";
constant ADDR_shift_bits_fft                                  : std_logic_vector(11 downto 0) := x"358";

constant ADDR_flag_rdy_wideband                               : std_logic_vector(11 downto 0) := x"380";
constant ADDR_flag_xdma_test_rdy                              : std_logic_vector(11 downto 0) := x"400";
constant ADDR_xdma_stop                              : std_logic_vector(11 downto 0) := x"402";

---------灯-------------------------             
constant ADDR_gpio_warning_internal       : std_logic_vector(11 downto 0) := x"316";
constant ADDR_gpio_power_internal         : std_logic_vector(11 downto 0) := x"318";


----  多普勒频偏    ----
constant ADDR_configurable_freq_hopping_phase_inc : std_logic_vector(11 downto 0) := x"220";
constant ADDR_configurable_freq_hopping_phase_init_0 : std_logic_vector(11 downto 0) := x"224";
constant ADDR_configurable_freq_hopping_phase_init_1 : std_logic_vector(11 downto 0) := x"226";
constant ADDR_configurable_freq_hopping_phase_init_2 : std_logic_vector(11 downto 0) := x"228";
constant ADDR_configurable_freq_hopping_phase_init_3 : std_logic_vector(11 downto 0) := x"22A";
constant ADDR_configurable_freq_hopping_phase_init_4 : std_logic_vector(11 downto 0) := x"22C";
constant ADDR_configurable_freq_hopping_phase_init_5 : std_logic_vector(11 downto 0) := x"22E";
constant ADDR_configurable_freq_hopping_phase_init_6 : std_logic_vector(11 downto 0) := x"230";
constant ADDR_configurable_freq_hopping_phase_init_7 : std_logic_vector(11 downto 0) := x"232";


----------TDMA---------------
signal we_RAM_timeslot_confiuration_internal : std_logic;
signal value_timeslot_adj_internal : std_logic;

signal flag_lock_reg_PS_read   :  std_logic_vector(1 downto 0); --- 高位为发射端，低位为接收端
signal counter_sync_bit_pre : std_logic_vector(3 downto 0);
signal counter_sync_bit_post : std_logic_vector(3 downto 0);
signal flag_wr_sync_bit_pre_internal : std_logic;
signal flag_wr_sync_bit_pre_local : std_logic;
signal flag_wr_sync_bit_post_internal : std_logic;
signal flag_wr_sync_bit_post_local : std_logic;

signal flag_pattern_freq_rx_x1_internal : std_logic;
signal flag_pattern_freq_rx_x2_internal : std_logic;
signal flag_pattern_freq_rx_x3_internal : std_logic;
signal flag_pattern_freq_rx_x4_internal : std_logic;

signal counter_time_hopping_x1 : std_logic_vector(3 downto 0);
signal counter_time_hopping_x2 : std_logic_vector(3 downto 0);
signal counter_time_hopping_x3 : std_logic_vector(3 downto 0);
signal counter_time_hopping_x4 : std_logic_vector(3 downto 0);
signal flag_wr_time_hopping_x1_internal : std_logic;
signal flag_wr_time_hopping_x1 : std_logic;
signal flag_wr_time_hopping_x2_internal : std_logic;
signal flag_wr_time_hopping_x2 : std_logic;
signal flag_wr_time_hopping_x3_internal : std_logic;
signal flag_wr_time_hopping_x3 : std_logic;
signal flag_wr_time_hopping_x4_internal : std_logic;
signal flag_wr_time_hopping_x4 : std_logic;

signal counter_PN_deinterleave : std_logic_vector(3 downto 0);
signal flag_wr_PN_deinterleave : std_logic;
signal flag_wr_PN_deinterleave_internal : std_logic;
signal flag_lock_reg_PS_read_tx_internal : std_logic;
signal flag_lock_reg_PS_read_rx_internal : std_logic;


component falling_edge_detector is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           din : in  STD_LOGIC;
           dout : out  STD_LOGIC);
end component;

signal flag_AD9739_config_internal : std_logic;
signal flag_AD9680_config_internal : std_logic;
signal flag_AD9680_2_config_internal : std_logic;
signal ps_ReSync_internal  : std_logic;
signal flag_AD9520_config_internal : std_logic;
signal reg_AD9520_config_wrdata_H : std_logic_vector(15 downto 0);
signal reg_AD9520_config_wrdata_L : std_logic_vector(15 downto 0);



signal flag_RF_PLL_TxRx_internal : std_logic;
signal flag_RF_PLL_CLK_internal : std_logic;

signal TX_pwrctrl_internal_cnt : std_logic_vector(3 downto 0);
signal TX_pwrctrl_internal : std_logic;
signal TX_pwrctrl_internal_en : std_logic;

signal agc_arm_ctrl_i_internal : std_logic;
signal agc_arm_ctrl_q_internal : std_logic;
signal flag_start_rx_internal : std_logic;
signal ram_PN_sync_we_internal : std_logic;
signal ram_PN_PAn_we_internal : std_logic;
signal ram_PN_scramble_we_internal : std_logic;
signal ram_PN_descramble_we_internal : std_logic;
signal ram_PN_interleave_we_internal : std_logic;
signal flag_configuration_rx_complete : std_logic;

signal ram_tx_interface_buffer_we_internal : std_logic;
signal ram_tx_interface_buffer_we_internal_1 : std_logic;
signal ram_tx_interface_buffer_we_internal_2 : std_logic;

signal flag_rd_arm_onepacket_internal : std_logic;
signal flag_rd_arm_oneint_internal : std_logic;
signal flag_rd_srio_onepacket_internal : std_logic;
signal flag_rd_srio_oneint_internal : std_logic;
signal falg_irq_k_end_internal : std_logic;
signal falg_irq_k_end_k_internal : std_logic;
signal flag_AD5XXX_config_internal : std_logic;
----	freq_mode
signal freq_mode: std_logic;									---- 0: normal     1: select
signal dds_num : std_logic_vector(3 downto 0);
signal dds_next_internal : std_logic;
signal dds_next : std_logic;
signal freq_config_complete_internal : std_logic;
signal freq_config_complete : std_logic;

signal dds_freq_para_index : para_index_array_type(14 downto 0);


signal ps_wen  : std_logic;
signal ps_cen  : std_logic;
signal ps_dout : std_logic_vector(15 downto 0);
signal ps_addr : std_logic_vector(11 downto 0);

signal flag_offset_time_adjust_internal : std_logic;
signal flag_offset_time_adjust_internal_k7 : std_logic;
----K7参数
signal flag_agc_arm_ctrl_mode_internal : std_logic;
signal flag_point_test_rx_internal : std_logic;
signal ram_PN_descramble_we_local : std_logic;
signal flag_start_rx_local : std_logic;
signal flag_threshold_pulse_num_internal : std_logic;
signal flag_threshold_sync_xcorr_internal : std_logic;
signal flag_channel_busy_threshold_internal : std_logic;
signal flag_channel_capure_threshold_internal : std_logic;
signal flag_Antenna_switch_local_internal : std_logic;
signal flag_arm_config_rx_rate_mode_sel_internal : std_logic;

----K7 jesd
signal flag_jesd_ila_local : std_logic;
signal flag_jesd_src_local : std_logic;
signal flag_jesd_mod_local : std_logic;
signal flag_jesd_f_local : std_logic;
signal flag_jesd_k_local : std_logic;
signal flag_jesd_lanes_local : std_logic;
signal flag_jesd_subclass_local : std_logic;
signal flag_jesd_delay_local : std_logic;
signal flag_jesd_erro_local : std_logic;
signal flag_jesd_erroo_local : std_logic;
signal flag_jesd_reset_internal : std_logic;
signal flag_tx_nread_internal : std_logic;

signal flag_timestamp_cor_internal : std_logic;

signal flag_SI5341_config_internal : std_logic; 

signal agc_arm_ctrl_12_internal:std_logic;
signal flag_agc_arm_ctrl_DVGA4_internal :std_logic;
signal flag_agc_arm_ctrl_DVGA4_internal_out :std_logic;
signal agc_arm_ctrl_DVGA4_delay : std_logic_vector(5 downto 0); 

COMPONENT ila_ps_write_128M

PORT (
	clk : IN STD_LOGIC;

	probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	probe3 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	probe4 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT  ;

begin

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ps_wen  <= '1';
		ps_cen  <= '1';
		ps_dout <= (others => '0');
		ps_addr <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		ps_wen  <= ps_wen_128M;
		ps_cen  <= ps_cen_128M ;
		ps_dout <= ps_dout_128M;
		ps_addr <= ps_addr_128M;
	end if;
end process;

--u_ila_psinterface_wr : ila_psinterface_wr
--PORT MAP (
--	clk => clk,
--	probe0(0) => ps_wen, 
--	probe1(0) => ps_cen, 
--	probe2 => ps_dout,
--	probe3 => ps_addr
--);


process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		STATUS_ADHOC <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_STATUS_ADHOC then
				STATUS_ADHOC <= ps_dout(0);
			end if;
		end if;
	end if;
end process;



--reverse_data_arm <= DATA_ARM(0) & DATA_ARM(1) & DATA_ARM(2) & DATA_ARM(3)
--						& DATA_ARM(4) & DATA_ARM(5) & DATA_ARM(6) & DATA_ARM(7)
--						& DATA_ARM(8) & DATA_ARM(9) & DATA_ARM(10) & DATA_ARM(11)
--						& DATA_ARM(12) & DATA_ARM(13) & DATA_ARM(14) & DATA_ARM(15);

----------------------------------------------------------------------------
-----------------------------初始化寄存器-------------------------------------
-------------------------x"0000" : 初始化阶段---------------------------------
-------------------------x"0001" : 正常工作阶段--------------------------------
------------------------正常工作阶段PN库的写地址归零----------------------------
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		reg_initial_reset <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_REG_INITIAL then
				reg_initial_reset <= ps_dout(2 downto 0);
			end if;
		end if;
	end if;
end process;

----------------------------------------------------------------------------
---------------------------发射模式寄存器-------------------------------------
-------------------------x"XXJ0" : 正常工作模式,"XX"："0"MSK,"1"GMSK-0.5-----
-------------------------x"XXJ1" : 载波发射模式,"XX"为载波号-------------------
-------------------------x"XXJX" : J 调整输出功率 J代表DA输入截位数 0表示不截位，输出功率最大 7表示截7位 输出功率最小 衰减为7*6dB-------------------
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		reg_tx_mode <= (others => '0');
		reg_tx_mode_para <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_REG_TX_MODE then
				reg_tx_mode <= ps_dout(7 downto 0);	
				reg_tx_mode_para <= ps_dout(15 downto 8);	
			end if;
		end if;
	end if;
end process;

----------------------------------------------------------------------------
-------------------------帧长设置-------------------------------------------
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then		
		pulse_framer_length <= x"1F14";
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PULSE_FRAMER_LENGTH then
				pulse_framer_length <= ps_dout(15 downto 0);		
			end if;
		end if;
	end if;
end process;

----------------------------------------------------------------------------
-------------------------K7 FPGA加载标志-------------------------------------------
----------------------------------------------------------------------------
process(reset,clk)
begin
	if reset = '0' then		
		PROGRAM_CONFIG_FPGA2 <= '0';
	elsif clk'event and clk = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PROGRAM_CONFIG_FPGA2 then
				PROGRAM_CONFIG_FPGA2 <= ps_dout(0);		
			end if;
		end if;
	end if;
end process;

----------------------------------------------------------------------------
-------------------------K7 时间同步计数器清零标志-------------------------------------------
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		reset_time <= '0';		
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RESET_TIME then
				reset_time <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

----------------------------------------------------------------------------
---------------------------接收门限设置寄存器----------------------------------
-------------1. 脉冲数门限寄存器，12个脉冲,前后同步头，最大值24--------------------
--------------------2. 同步相关门限寄存器，最大值约为8464------------------------
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		threshold_pulse_num <= "00011";		----	默认值3
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PULSE_NUM_THRESHOLD then
				threshold_pulse_num <= ps_dout(4 downto 0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		threshold_sync_xcorr <= x"0E10";		----	默认值3600
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SYNC_XCORR_THRESHOLD then
				threshold_sync_xcorr <= ps_dout;	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_threshold_pulse_num_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PULSE_NUM_THRESHOLD then
				flag_threshold_pulse_num_internal <= '1';
			else
				flag_threshold_pulse_num_internal <= '0';
			end if;
		else
			flag_threshold_pulse_num_internal <= '0';
		end if;
	end if;
end process;

U46 : falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => flag_threshold_pulse_num_internal,
									   dout  => flag_threshold_pulse_num );

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_threshold_sync_xcorr_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SYNC_XCORR_THRESHOLD then
				flag_threshold_sync_xcorr_internal <= '1';
			else
				flag_threshold_sync_xcorr_internal <= '0';
			end if;
		else
			flag_threshold_sync_xcorr_internal <= '0';
		end if;
	end if;
end process;

U47 : falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => flag_threshold_sync_xcorr_internal,
									   dout  => flag_threshold_sync_xcorr );

----------------------------------------------------------------------------
-----------------------------	信道负载	-------------------------------
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		channel_busy_threshold <= x"1194";		----	默认值4500
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_CHANNEL_BUSY_THRESHOLD then
				channel_busy_threshold <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_channel_busy_threshold_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_CHANNEL_BUSY_THRESHOLD then
				flag_channel_busy_threshold_internal <= '1';
			else
				flag_channel_busy_threshold_internal <= '0';
			end if;
		else
			flag_channel_busy_threshold_internal <= '0';
		end if;
	end if;
end process;

U48 : falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => flag_channel_busy_threshold_internal,
									   dout  => flag_channel_busy_threshold );

----------------------------------------------------------------------------
-----------------------------	信道捕获 24位脉冲捕获寄存器判决门限	-------------------------------
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		channel_capure_threshold <= x"08FC";		----	默认值2300
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_CHANNEL_CAPTURE_THRESHOLD then
				channel_capure_threshold <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_channel_capure_threshold_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_CHANNEL_CAPTURE_THRESHOLD then
				flag_channel_capure_threshold_internal <= '1';
			else
				flag_channel_capure_threshold_internal <= '0';
			end if;
		else
			flag_channel_capure_threshold_internal <= '0';
		end if;
	end if;
end process;

U49 : falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => flag_channel_capure_threshold_internal,
									   dout  => flag_channel_capure_threshold );

----------------------------------------------------------------------------
---------------------------发射端 每包数据之间的时间间隙----------------------------------
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		packet_time_interval <= (others => '0');		----	默认值0 没有时间间隔
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TX_PACKET_TIME_INTERVAL_low then
				packet_time_interval(15 downto 0) <= ps_dout;
		    elsif ps_addr = ADDR_TX_PACKET_TIME_INTERVAL_high then
		        packet_time_interval(31 downto 16) <= ps_dout;	
			end if;
		end if;
	end if;
end process;



----------------------------------------------------------------------------
-----------------------------	天线选择	-------------------------------
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		Antenna_switch_local <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_ANT_SEL then
				Antenna_switch_local <= ps_dout;	
            end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_Antenna_switch_local_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_ANT_SEL then
				flag_Antenna_switch_local_internal <= '1';
			else
				flag_Antenna_switch_local_internal <= '0';
			end if;
		else
			flag_Antenna_switch_local_internal <= '0';
		end if;
	end if;
end process;

U50 : falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => flag_Antenna_switch_local_internal,
									   dout  => flag_Antenna_switch_local );
									  
----------------------------------------------------------------------------
----------------------------光   纤  -----------------------------------------------------------------
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		contrl_8506 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_CONTRL_8506 then
				contrl_8506 <= ps_dout;	
			end if;
		end if;
	end if;
end process;

----------------------------------------------------------------------------
-----------------------------DAC初始化 AD9739-------------------------------
----------------------------------------------------------------------------
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		reg_AD9739_config_wrdata <= (others => '0');
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_REG_AD9739_CONFIG_WRDATA then
--				reg_AD9739_config_wrdata <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;


--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		flag_AD9739_config_internal <= '0';
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_REG_AD9739_CONFIG_WRDATA then
--				flag_AD9739_config_internal <= '1';
--			else
--				flag_AD9739_config_internal <= '0';
--			end if;
--		else
--			flag_AD9739_config_internal <= '0';
--		end if;
--	end if;
--end process;

--U1 : falling_edge_detector Port map ( reset => reset_128M,
--												  clk => clk_128M,
--												  din => flag_AD9739_config_internal,
--												  dout => flag_AD9739_config );
----------------------------------------------------------------------------
-----------------------------ADC初始化--------------------------------------
-------------------------          AD9680 ----------------------------------
----------------------------------------------------------------------------
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		reg_AD9680_config_wrdata <= (others => '0');
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_REG_AD9680_CONFIG_WRDATA then
--				reg_AD9680_config_wrdata <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;


--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		flag_AD9680_config_internal <= '0';
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_REG_AD9680_CONFIG_WRDATA then
--				flag_AD9680_config_internal <= '1';
--			else
--				flag_AD9680_config_internal <= '0';
--			end if;
--		else
--			flag_AD9680_config_internal <= '0';
--		end if;
--	end if;
--end process;


--U2 : falling_edge_detector Port map ( reset => reset_128M,
--												  clk => clk_128M,
--												  din => flag_AD9680_config_internal,
--												  dout => flag_AD9680_config );	
----------------------------------------------------------------------------
-----------------------------ADC初始化--------------------------------------
-------------------------          AD9680_2 ----------------------------------
----------------------------------------------------------------------------
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		reg_AD9680_2_config_wrdata <= (others => '0');
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_REG_AD9680_2_CONFIG_WRDATA then
--				reg_AD9680_2_config_wrdata <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;


--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		flag_AD9680_2_config_internal <= '0';
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_REG_AD9680_2_CONFIG_WRDATA then
--				flag_AD9680_2_config_internal <= '1';
--			else
--				flag_AD9680_2_config_internal <= '0';
--			end if;
--		else
--			flag_AD9680_2_config_internal <= '0';
--		end if;
--	end if;
--end process;


--U53 : falling_edge_detector Port map ( reset => reset_128M,
--												  clk => clk_128M,
--												  din => flag_AD9680_2_config_internal,
--												  dout => flag_AD9680_2_config );	

                                                  
--jesd_reset
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		jesd_reset <= '0';
--		jesd_reset_n <= '1';
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_REG_jesd_reset then
--				jesd_reset <= ps_dout(0);
--				jesd_reset_n <=  not ps_dout(0);
--			end if;
--		end if;
--	end if;
--end process;

----jesd_reset_ad2
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		jesd_reset_AD2 <= '0';
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_REG_jesd_reset_AD2 then
--				jesd_reset_AD2 <= ps_dout(0);
--			end if;
--		end if;
--	end if;
--end process;

--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		flag_jesd_reset_internal <= '0';
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_REG_jesd_reset_AD2 then
--				flag_jesd_reset_internal <= '1';
--			else
--				flag_jesd_reset_internal <= '0';
--			end if;
--		else
--			flag_jesd_reset_internal <= '0';
--		end if;
--	end if;
--end process;


--U52 : falling_edge_detector Port map ( reset => reset_128M,
--									   clk => clk_128M,
--									   din => flag_jesd_reset_internal,
--									   dout => flag_jesd_reset_AD2 );	

----ps_ReSync
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		ps_ReSync <= '1';
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_REG_ps_ReSync then
--				ps_ReSync <= ps_dout(0);
--			end if;
--		end if;
--	end if;
--end process;

												  
----------------------------------------------------------------------------
-----------------------------PLL初始化--------------------------------------
-------------------------          AD9520 ----------------------------------
----------------------------------------------------------------------------
--process(reset,clk)
--begin
--	if reset = '0' then
--		reg_AD9520_config_wrdata_H <= (others => '0');
--	elsif clk'event and clk = '1' then
--		if ps_cen_100M1 = '0' and ps_wen_100M1 = '0' then
--			if ps_addr_100M1 = ADDR_REG_AD9520_CONFIG_WRDATA_H then
--				reg_AD9520_config_wrdata_H <= ps_dout_100M1;	
--			end if;
--		end if;
--	end if;
--end process;

--reg_AD9520_config_wrdata(23 downto 16) <= reg_AD9520_config_wrdata_H(7 downto 0);

--process(reset,clk)
--begin
--	if reset = '0' then
--		reg_AD9520_config_wrdata_L <= (others => '0');
--	elsif clk'event and clk = '1' then
--		if ps_cen_100M1 = '0' and ps_wen_100M1 = '0' then
--			if ps_addr_100M1 = ADDR_REG_AD9520_CONFIG_WRDATA_L then
--				reg_AD9520_config_wrdata_L <= ps_dout_100M1;	
--			end if;
--		end if;
--	end if;
--end process;

--reg_AD9520_config_wrdata(15 downto 0) <= reg_AD9520_config_wrdata_L(15 downto 0);

--process(reset,clk)
--begin
--	if reset = '0' then
--		flag_AD9520_config_internal <= '0';
--	elsif clk'event and clk = '1' then
--		if ps_cen_100M1 = '0' and ps_wen_100M1 = '0' then
--			if ps_addr_100M1 = ADDR_REG_AD9520_CONFIG_WRDATA_L then
--				flag_AD9520_config_internal <= '1';
--			else
--				flag_AD9520_config_internal <= '0';
--			end if;
--		else
--			flag_AD9520_config_internal <= '0';
--		end if;
--	end if;
--end process;

--U3 : falling_edge_detector Port map ( reset => reset,
--												  clk => clk,
--												  din => flag_AD9520_config_internal,
--												  dout => flag_AD9520_config );
												
                                                
--process(reset,clk)
--begin
--	if reset = '0' then
--		reset_PLL <= '0';
--	elsif clk'event and clk = '1' then
--		if ps_cen_100M1 = '0' and ps_wen_100M1 = '0' then
--			if ps_addr_100M1 = ADDR_REG_AD9520_RESET_PLL then
--				reset_PLL   <= ps_dout_100M1(0);	
--			end if;
--		end if;
--	end if;
--end process;

-------------------------AD5XXX配置，先下发模式，再下发数据-------------
--process(reset,clk)
--begin
--	if reset = '0' then
--		reg_AD5XXX_mode <= (others=>'0');
--        reg_LDAC    <= '1';
--	elsif clk'event and clk = '1' then
--		if ps_cen_100M1 = '0' and ps_wen_100M1 = '0' then
--		  if ps_addr_100M1 = ADDR_AD5XXX_mode then
--		      reg_AD5XXX_mode <= ps_dout(3 downto 0);
--              reg_LDAC        <= ps_dout(15);
--			end if;
--		end if;
--	end if;
--end process;

--process(reset,clk)
--begin
--	if reset = '0' then
--		reg_AD5XXX_wrdata <=(others=>'0');
--	elsif clk'event and clk = '1' then
--		if ps_cen_100M1 = '0' and ps_wen_100M1 = '0' then
--		  if ps_addr_100M1 = ADDR_AD5XXX_DATA then
--		      reg_AD5XXX_wrdata <=ps_dout;
--			end if;
--		end if;
--	end if;
--end process;

--process(reset,clk)
--begin
--	if reset = '0' then
--		flag_AD5XXX_config_internal <= '0';
--	elsif clk'event and clk = '1' then
--		if ps_cen_100M1 = '0' and ps_wen_100M1 = '0' then
--			if ps_addr_100M1 = ADDR_AD5XXX_DATA then
--				flag_AD5XXX_config_internal <= '1';
--			else
--				flag_AD5XXX_config_internal <= '0';
--			end if;
--		else
--			flag_AD5XXX_config_internal <= '0';
--		end if;
--	end if;
--end process;

--U27 : falling_edge_detector Port map ( reset => reset,
--												   clk => clk,
--												   din => flag_AD5XXX_config_internal,
--												   dout => flag_AD5XXX_config);	

----------------------------------------------------------------------------
----------------------------AGC arm控衰减------------------------------------
----------------------------------------------------------------------------
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		agc_arm_ctrl_mode <= (others => '0');
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_AGC_DVGA_MODE then
--				agc_arm_ctrl_mode <= ps_dout;
--			end if;
--		end if;
--	end if;
--end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_agc_arm_ctrl_mode_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_AGC_DVGA_MODE then
				flag_agc_arm_ctrl_mode_internal <= '1';
			else
				flag_agc_arm_ctrl_mode_internal <= '0';
			end if;
		else
			flag_agc_arm_ctrl_mode_internal <= '0';
		end if;
	end if;
end process;

U54 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_agc_arm_ctrl_mode_internal,
									   dout => flag_agc_arm_ctrl_mode);	

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		agc_arm_ctrl_DVGA1_i <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_AGC_DVGA_I then
				agc_arm_ctrl_DVGA1_i <= ps_dout(5 downto 0);
			end if;
		end if;
	end if;
end process;



process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		agc_arm_ctrl_DVGA2_i <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_AGC_DVGA_I then
				agc_arm_ctrl_DVGA2_i <= ps_dout(13 downto 8);
			end if;
		end if;
	end if;
end process;

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		agc_arm_ctrl_i_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_AGC_DVGA_I then
				agc_arm_ctrl_i_internal <= '1';
			else
				agc_arm_ctrl_i_internal <= '0';
			end if;
		else
			agc_arm_ctrl_i_internal <= '0';
		end if;
	end if;
end process;

--U4 : falling_edge_detector Port map ( reset => reset_128M,
--												  clk => clk_128M,
--												  din => agc_arm_ctrl_i_internal,
--												  dout => agc_arm_ctrl_i );
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		agc_arm_ctrl_DVGA1_q <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_AGC_DVGA_Q then
				agc_arm_ctrl_DVGA1_q <= ps_dout(5 downto 0);
			end if;
		end if;
	end if;
end process;

--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		agc_arm_ctrl_DVGA2_q <= (others => '0');
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_AGC_DVGA_Q then
--				agc_arm_ctrl_DVGA2_q <= ps_dout(13 downto 8);
--			end if;
--		end if;
--	end if;
--end process;

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		agc_arm_ctrl_q_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_AGC_DVGA_Q then
				agc_arm_ctrl_q_internal <= '1';
			else
				agc_arm_ctrl_q_internal <= '0';
			end if;
		else
			agc_arm_ctrl_q_internal <= '0';
		end if;
	end if;
end process;

U5 : falling_edge_detector Port map ( reset => reset_128M,
												  clk => clk_128M,
												  din => agc_arm_ctrl_q_internal,
												  dout => agc_arm_ctrl_q );

----------------------------------------------------------------------------
---------------------------PN库初始化----------------------------------------
--------------------        1. sync           ------------------------------
--------------------        2. PAn            ------------------------------
--------------------        3. scramble       ------------------------------
--------------------        4. interleave     ------------------------------
----------------------------------------------------------------------------

--------		1. sync		--------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_PN_sync_din <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PN_sync then
				ram_PN_sync_din <= ps_dout;	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_PN_sync_we_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PN_sync then
				ram_PN_sync_we_internal <= '1';
			else
				ram_PN_sync_we_internal <= '0';
			end if;
		else
			ram_PN_sync_we_internal <= '0';
		end if;
	end if;
end process;

U8 : falling_edge_detector Port map ( reset => reset_128M,
												  clk => clk_128M,
												  din => ram_PN_sync_we_internal,
												  dout => ram_PN_sync_we );	

--------		2. PAn		--------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_PN_PAn_din <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PN_PAn then
				ram_PN_PAn_din <= ps_dout;	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_PN_PAn_we_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PN_PAn then
				ram_PN_PAn_we_internal <= '1';
			else
				ram_PN_PAn_we_internal <= '0';
			end if;
		else
			ram_PN_PAn_we_internal <= '0';
		end if;
	end if;
end process;

U9 : falling_edge_detector Port map ( reset => reset_128M,
												  clk => clk_128M,
												  din => ram_PN_PAn_we_internal,
												  dout => ram_PN_PAn_we );	

--------		3. scramble		--------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_PN_scramble_din <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PN_scramble then
				ram_PN_scramble_din <= ps_dout;	
			end if;
		end if;
	end if;
end process;


process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_PN_scramble_we_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PN_scramble then
				ram_PN_scramble_we_internal <= '1';
			else
				ram_PN_scramble_we_internal <= '0';
			end if;
		else
			ram_PN_scramble_we_internal <= '0';
		end if;
	end if;
end process;

U10 : falling_edge_detector Port map ( reset => reset_128M,
												  clk => clk_128M,
												  din => ram_PN_scramble_we_internal,
												  dout => ram_PN_scramble_we );													  

--------		4. interleave		--------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_PN_interleave_din <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PN_interleave then
				ram_PN_interleave_din <= ps_dout;	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_PN_interleave_we_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PN_interleave then
				ram_PN_interleave_we_internal <= '1';
			else
				ram_PN_interleave_we_internal <= '0';
			end if;
		else
			ram_PN_interleave_we_internal <= '0';
		end if;
	end if;
end process;

U11 : falling_edge_detector Port map ( reset => reset_128M,
												  clk => clk_128M,
												  din => ram_PN_interleave_we_internal,
												  dout => ram_PN_interleave_we );		

----------------------------------------------------------------------------
---------------------------ARM下发数据---------------------------------------
----------------			0. 下发发射请求							-------------------
----------------			1. 下发发射数据							-------------------
----------------			2. 下发跳频参数和sync索引地址	  		-------------------
----------------			3. 下发跳时参数							-------------------
----------------			4. 下发发射类型（也作为结束标志）		-------------------
----------------------------------------------------------------------------

--------		0. 发射请求		--------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_tx_interface_buffer_we_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr(11 downto 4) = x"04" then
				ram_tx_interface_buffer_we_internal <= '1';
			else
				ram_tx_interface_buffer_we_internal <= '0';
			end if;
		else
			ram_tx_interface_buffer_we_internal <= '0';
		end if;
	end if;
end process;

U12 : falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => ram_tx_interface_buffer_we_internal,
									   dout  => ram_tx_interface_buffer_we 
									);
									
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_tx_interface_buffer_din <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr(11 downto 4) = x"04" then
				ram_tx_interface_buffer_din <= ps_dout;
			end if;
		end if;
	end if;
end process;											  

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_tx_interface_buffer_din_type <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TX_DATA then								--------		1.发射数据		----------
				ram_tx_interface_buffer_din_type <= "00";	
			elsif ps_addr = ADDR_FREQ_HOPPING_PN_SYNC_ADDR then	--------		2. 跳频参数和sync索引地址		---------
				ram_tx_interface_buffer_din_type <= "01";	
			elsif ps_addr = ADDR_TIME_HOPPING then					--------		3. 跳时参数		--------
				ram_tx_interface_buffer_din_type <= "10";
			elsif ps_addr = ADDR_TX_PULSE_TYPE then					--------		4. 下发发射类型（也作为结束标志）		--------
				ram_tx_interface_buffer_din_type <= "11";
			end if;
		end if;
	end if;
end process;																						  

--------		0. 发射请求_1		--------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_tx_interface_buffer_we_internal_1 <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr(11 downto 4) = x"0C" then
				ram_tx_interface_buffer_we_internal_1 <= '1';
			else
				ram_tx_interface_buffer_we_internal_1 <= '0';
			end if;
		else
			ram_tx_interface_buffer_we_internal_1 <= '0';
		end if;
	end if;
end process;

U12_1 : falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => ram_tx_interface_buffer_we_internal_1,
									   dout  => ram_tx_interface_buffer_we_1 
									);
									
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_tx_interface_buffer_din_1 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr(11 downto 4) = x"0C" then
				ram_tx_interface_buffer_din_1 <= ps_dout;
			end if;
		end if;
	end if;
end process;											  

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_tx_interface_buffer_din_type_1 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TX_DATA_1 then								--------		1.发射数据		----------
				ram_tx_interface_buffer_din_type_1 <= "00";	
			elsif ps_addr = ADDR_FREQ_HOPPING_PN_SYNC_ADDR_1 then	--------		2. 跳频参数和sync索引地址		---------
				ram_tx_interface_buffer_din_type_1 <= "01";	
			elsif ps_addr = ADDR_TIME_HOPPING_1 then					--------		3. 跳时参数		--------
				ram_tx_interface_buffer_din_type_1 <= "10";
			elsif ps_addr = ADDR_TX_PULSE_TYPE_1 then					--------		4. 下发发射类型（也作为结束标志）		--------
				ram_tx_interface_buffer_din_type_1 <= "11";
			end if;
		end if;
	end if;
end process;																						  
--------		0. 发射请求_2		--------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_tx_interface_buffer_we_internal_2 <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr(11 downto 4) = x"0D" then
				ram_tx_interface_buffer_we_internal_2 <= '1';
			else
				ram_tx_interface_buffer_we_internal_2 <= '0';
			end if;
		else
			ram_tx_interface_buffer_we_internal_2 <= '0';
		end if;
	end if;
end process;

U12_2 : falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => ram_tx_interface_buffer_we_internal_2,
									   dout  => ram_tx_interface_buffer_we_2 
									);
									
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_tx_interface_buffer_din_2 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr(11 downto 4) = x"0D" then
				ram_tx_interface_buffer_din_2 <= ps_dout;
			end if;
		end if;
	end if;
end process;											  

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_tx_interface_buffer_din_type_2 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TX_DATA_2 then								--------		1.发射数据		----------
				ram_tx_interface_buffer_din_type_2 <= "00";	
			elsif ps_addr = ADDR_FREQ_HOPPING_PN_SYNC_ADDR_2 then	--------		2. 跳频参数和sync索引地址		---------
				ram_tx_interface_buffer_din_type_2 <= "01";	
			elsif ps_addr = ADDR_TIME_HOPPING_2 then					--------		3. 跳时参数		--------
				ram_tx_interface_buffer_din_type_2 <= "10";
			elsif ps_addr = ADDR_TX_PULSE_TYPE_2 then					--------		4. 下发发射类型（也作为结束标志）		--------
				ram_tx_interface_buffer_din_type_2 <= "11";
			end if;
		end if;
	end if;
end process;		



----------------------------------------------------------------------------
---------------------------ARM接收数据---------------------------------------
----------------------------------------------------------------------------
process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_rd_arm_onepacket_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RX_DATA then
				flag_rd_arm_onepacket_internal <= ps_dout(0);
			else
				flag_rd_arm_onepacket_internal <= '0';
			end if;
		else
			flag_rd_arm_onepacket_internal <= '0';
		end if;	
	end if;
end process;

U13 : falling_edge_detector PORT MAP ( reset => reset_128M,
												   clk => clk_128M,
												   din => flag_rd_arm_onepacket_internal,
												   dout => flag_rd_arm_onepacket );

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_rd_arm_oneint_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RX_DATA then
				flag_rd_arm_oneint_internal <= ps_dout(1);
			else
				flag_rd_arm_oneint_internal <= '0';
			end if;
		else
			flag_rd_arm_oneint_internal <= '0';
		end if;	
	end if;
end process;

U14 : falling_edge_detector PORT MAP ( reset => reset_128M,
												   clk => clk_128M,
												   din => flag_rd_arm_oneint_internal,
												   dout => flag_rd_arm_oneint );	
									  
									  

----k7 recv
process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_rd_srio_onepacket_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RX_DATA then
				flag_rd_srio_onepacket_internal <= ps_dout(2);
			else
				flag_rd_srio_onepacket_internal <= '0';
			end if;
		else
			flag_rd_srio_onepacket_internal <= '0';
		end if;	
	end if;
end process;

U43 : falling_edge_detector PORT MAP ( reset => reset_128M,
												   clk => clk_128M,
												   din => flag_rd_srio_onepacket_internal,
												   dout => flag_rd_srio_onepacket );

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_rd_srio_oneint_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RX_DATA then
				flag_rd_srio_oneint_internal <= ps_dout(3);
			else
				flag_rd_srio_oneint_internal <= '0';
			end if;
		else
			flag_rd_srio_oneint_internal <= '0';
		end if;	
	end if;
end process;

U44 : falling_edge_detector PORT MAP ( reset => reset_128M,
												   clk => clk_128M,
												   din => flag_rd_srio_oneint_internal,
												   dout => flag_rd_srio_oneint );
												   
												   
												   
process(reset,clk)
begin
	if reset = '0' then
		falg_irq_k_end_internal <= '0';
	elsif clk'event and clk = '1' then
		if ps_cen = '0' and ps_wen = '0' and ps_addr = ADDR_FLAG_IRQ_END then
			falg_irq_k_end_internal <= '1';
		else
			falg_irq_k_end_internal <= '0';
		end if;
	end if;
end process;
												   
												   
U99 : falling_edge_detector PORT MAP ( reset => reset,
												   clk  => clk,
												   din  => falg_irq_k_end_internal,
												   dout => falg_irq_k_end);												   
												   
----空口中断结束信号												   
process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		falg_irq_k_end_k_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_FLAG_IRQ_END then
				falg_irq_k_end_k_internal <= '1';
			else
				falg_irq_k_end_k_internal <= '0';
			end if;
		else
			falg_irq_k_end_k_internal <= '0';
		end if;	
	end if;
end process;

U98 : falling_edge_detector PORT MAP ( reset => reset_128M,
												   clk => clk_128M,
												   din => falg_irq_k_end_k_internal,
												   dout => falg_irq_k_end_k );												   

----------------------------------------------------------------------------
---------------------------接收参数配置-------------------------------------
----------------------------------------------------------------------------

----	sync_bit：头尾各配置15个，对应15个频点

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_wr_sync_bit_pre_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SYNC_BIT_PRE_RX_HIGH then
				flag_wr_sync_bit_pre_internal <= '1';
			else
				flag_wr_sync_bit_pre_internal <= '0';
			end if;
		else
			flag_wr_sync_bit_pre_internal <= '0';
		end if;	
	end if;
end process;

U15 : falling_edge_detector PORT MAP ( reset => reset_128M,
													clk => clk_128M,
													din => flag_wr_sync_bit_pre_internal,
													dout => flag_wr_sync_bit_pre_local );	
flag_wr_sync_bit_pre <= flag_wr_sync_bit_pre_local;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		sync_bit_pre_rx_s <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SYNC_BIT_PRE_RX_LOW then
				sync_bit_pre_rx_s(15 downto 0) <= ps_dout;	
			elsif ps_addr = ADDR_SYNC_BIT_PRE_RX_HIGH then
				sync_bit_pre_rx_s(23 downto 16) <= ps_dout(7 downto 0);		
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		counter_sync_bit_pre <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if flag_wr_sync_bit_pre_local = '1' then
			counter_sync_bit_pre <= counter_sync_bit_pre + 1;
		elsif flag_configuration_rx_complete = '1' then
			counter_sync_bit_pre <= (others => '0');
		end if;
	end if;
end process;

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_wr_sync_bit_post_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SYNC_BIT_POST_RX_HIGH then
				flag_wr_sync_bit_post_internal <= '1';
			else
				flag_wr_sync_bit_post_internal <= '0';
			end if;
		else
			flag_wr_sync_bit_post_internal <= '0';
		end if;	
	end if;
end process;

U16 : falling_edge_detector PORT MAP ( reset => reset_128M,
													clk => clk_128M,
													din => flag_wr_sync_bit_post_internal,
													dout => flag_wr_sync_bit_post_local );	
flag_wr_sync_bit_post <= flag_wr_sync_bit_post_local;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		sync_bit_post_rx_s <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SYNC_BIT_POST_RX_LOW then
				sync_bit_post_rx_s(15 downto 0) <= ps_dout;	
			elsif ps_addr = ADDR_SYNC_BIT_POST_RX_HIGH then
				sync_bit_post_rx_s(23 downto 16) <= ps_dout(7 downto 0);		
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		counter_sync_bit_post <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if flag_wr_sync_bit_post_local = '1' then
			counter_sync_bit_post <= counter_sync_bit_post + 1;
		elsif flag_configuration_rx_complete = '1' then
			counter_sync_bit_post <= (others => '0');
		end if;
	end if;
end process;

	
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		sync_bit_pre_rx <= ((others => '0'),(others => '0'),(others => '0'),
								  (others => '0'),(others => '0'),(others => '0'),
								  (others => '0'),(others => '0'),(others => '0'),
								  (others => '0'),(others => '0'),(others => '0'),
								  (others => '0'),(others => '0'),(others => '0'));
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SYNC_BIT_PRE_RX_LOW then
				case counter_sync_bit_pre is
					when "0000" => sync_bit_pre_rx(0)(15 downto 0) <= ps_dout;
					when "0001" => sync_bit_pre_rx(1)(15 downto 0) <= ps_dout;
					when "0010" => sync_bit_pre_rx(2)(15 downto 0) <= ps_dout;
					when "0011" => sync_bit_pre_rx(3)(15 downto 0) <= ps_dout;
					when "0100" => sync_bit_pre_rx(4)(15 downto 0) <= ps_dout;
					when "0101" => sync_bit_pre_rx(5)(15 downto 0) <= ps_dout;
					when "0110" => sync_bit_pre_rx(6)(15 downto 0) <= ps_dout;
					when "0111" => sync_bit_pre_rx(7)(15 downto 0) <= ps_dout;
					when "1000" => sync_bit_pre_rx(8)(15 downto 0) <= ps_dout;
					when "1001" => sync_bit_pre_rx(9)(15 downto 0) <= ps_dout;
					when "1010" => sync_bit_pre_rx(10)(15 downto 0) <= ps_dout;
					when "1011" => sync_bit_pre_rx(11)(15 downto 0) <= ps_dout;
					when "1100" => sync_bit_pre_rx(12)(15 downto 0) <= ps_dout;
					when "1101" => sync_bit_pre_rx(13)(15 downto 0) <= ps_dout;
					when "1110" => sync_bit_pre_rx(14)(15 downto 0) <= ps_dout;
					when others => null;
				end case;	
			elsif ps_addr = ADDR_SYNC_BIT_PRE_RX_HIGH then
				case counter_sync_bit_pre is
					when "0000" => sync_bit_pre_rx(0)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0001" => sync_bit_pre_rx(1)(23 downto 16) <= ps_dout(7 downto 0);
					when "0010" => sync_bit_pre_rx(2)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0011" => sync_bit_pre_rx(3)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0100" => sync_bit_pre_rx(4)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0101" => sync_bit_pre_rx(5)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0110" => sync_bit_pre_rx(6)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0111" => sync_bit_pre_rx(7)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1000" => sync_bit_pre_rx(8)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1001" => sync_bit_pre_rx(9)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1010" => sync_bit_pre_rx(10)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1011" => sync_bit_pre_rx(11)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1100" => sync_bit_pre_rx(12)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1101" => sync_bit_pre_rx(13)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1110" => sync_bit_pre_rx(14)(23 downto 16) <= ps_dout(7 downto 0);	
					when others => null;
				end case;	
			end if;
		end if;
	end if;
end process;
			
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		sync_bit_post_rx <= ((others => '0'),(others => '0'),(others => '0'),
								   (others => '0'),(others => '0'),(others => '0'),
								   (others => '0'),(others => '0'),(others => '0'),
								   (others => '0'),(others => '0'),(others => '0'),
								   (others => '0'),(others => '0'),(others => '0'));
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SYNC_BIT_POST_RX_LOW then
				case counter_sync_bit_post is
					when "0000" => sync_bit_post_rx(0)(15 downto 0) <= ps_dout;
					when "0001" => sync_bit_post_rx(1)(15 downto 0) <= ps_dout;
					when "0010" => sync_bit_post_rx(2)(15 downto 0) <= ps_dout;
					when "0011" => sync_bit_post_rx(3)(15 downto 0) <= ps_dout;
					when "0100" => sync_bit_post_rx(4)(15 downto 0) <= ps_dout;
					when "0101" => sync_bit_post_rx(5)(15 downto 0) <= ps_dout;
					when "0110" => sync_bit_post_rx(6)(15 downto 0) <= ps_dout;
					when "0111" => sync_bit_post_rx(7)(15 downto 0) <= ps_dout;
					when "1000" => sync_bit_post_rx(8)(15 downto 0) <= ps_dout;
					when "1001" => sync_bit_post_rx(9)(15 downto 0) <= ps_dout;
					when "1010" => sync_bit_post_rx(10)(15 downto 0) <= ps_dout;
					when "1011" => sync_bit_post_rx(11)(15 downto 0) <= ps_dout;
					when "1100" => sync_bit_post_rx(12)(15 downto 0) <= ps_dout;
					when "1101" => sync_bit_post_rx(13)(15 downto 0) <= ps_dout;
					when "1110" => sync_bit_post_rx(14)(15 downto 0) <= ps_dout;
					when others => null;
				end case;
			elsif ps_addr = ADDR_SYNC_BIT_POST_RX_HIGH then
				case counter_sync_bit_post is
					when "0000" => sync_bit_post_rx(0)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0001" => sync_bit_post_rx(1)(23 downto 16) <= ps_dout(7 downto 0);
					when "0010" => sync_bit_post_rx(2)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0011" => sync_bit_post_rx(3)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0100" => sync_bit_post_rx(4)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0101" => sync_bit_post_rx(5)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0110" => sync_bit_post_rx(6)(23 downto 16) <= ps_dout(7 downto 0);	
					when "0111" => sync_bit_post_rx(7)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1000" => sync_bit_post_rx(8)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1001" => sync_bit_post_rx(9)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1010" => sync_bit_post_rx(10)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1011" => sync_bit_post_rx(11)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1100" => sync_bit_post_rx(12)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1101" => sync_bit_post_rx(13)(23 downto 16) <= ps_dout(7 downto 0);	
					when "1110" => sync_bit_post_rx(14)(23 downto 16) <= ps_dout(7 downto 0);	
					when others => null;
				end case;			
			end if;
		end if;
	end if;
end process;
----	跳频图案

----	X1
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		pattern_freq_rx_x1 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PATTERN_FREQ_RX_X1_LOW then
				pattern_freq_rx_x1(15 downto 0) <= ps_dout;
			elsif ps_addr = ADDR_PATTERN_FREQ_RX_X1_MIDDLE then
				pattern_freq_rx_x1(31 downto 16) <= ps_dout;
			elsif ps_addr = ADDR_PATTERN_FREQ_RX_X1_HIGH then
				pattern_freq_rx_x1(47 downto 32) <= ps_dout;
			end if;
		end if;
	end if;
end process;																						  

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_pattern_freq_rx_x1_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PATTERN_FREQ_RX_X1_HIGH then
				flag_pattern_freq_rx_x1_internal <= '1';
			else
				flag_pattern_freq_rx_x1_internal <= '0';
			end if;
		else
			flag_pattern_freq_rx_x1_internal <= '0';
		end if;	
	end if;
end process;

U39 : falling_edge_detector PORT MAP ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_pattern_freq_rx_x1_internal,
									   dout => flag_pattern_freq_rx_x1 );	

----	X2
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		pattern_freq_rx_x2 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PATTERN_FREQ_RX_X2_LOW then
				pattern_freq_rx_x2(15 downto 0) <= ps_dout;
			elsif ps_addr = ADDR_PATTERN_FREQ_RX_X2_MIDDLE then
				pattern_freq_rx_x2(31 downto 16) <= ps_dout;
			elsif ps_addr = ADDR_PATTERN_FREQ_RX_X2_HIGH then
				pattern_freq_rx_x2(47 downto 32) <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_pattern_freq_rx_x2_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PATTERN_FREQ_RX_X2_HIGH then
				flag_pattern_freq_rx_x2_internal <= '1';
			else
				flag_pattern_freq_rx_x2_internal <= '0';
			end if;
		else
			flag_pattern_freq_rx_x2_internal <= '0';
		end if;	
	end if;
end process;

U40 : falling_edge_detector PORT MAP ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_pattern_freq_rx_x2_internal,
									   dout => flag_pattern_freq_rx_x2 );

----	X3
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		pattern_freq_rx_x3 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PATTERN_FREQ_RX_X3_LOW then
				pattern_freq_rx_x3(15 downto 0) <= ps_dout;
			elsif ps_addr = ADDR_PATTERN_FREQ_RX_X3_MIDDLE then
				pattern_freq_rx_x3(31 downto 16) <= ps_dout;
			elsif ps_addr = ADDR_PATTERN_FREQ_RX_X3_HIGH then
				pattern_freq_rx_x3(47 downto 32) <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_pattern_freq_rx_x3_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PATTERN_FREQ_RX_X3_HIGH then
				flag_pattern_freq_rx_x3_internal <= '1';
			else
				flag_pattern_freq_rx_x3_internal <= '0';
			end if;
		else
			flag_pattern_freq_rx_x3_internal <= '0';
		end if;	
	end if;
end process;

U41 : falling_edge_detector PORT MAP ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_pattern_freq_rx_x3_internal,
									   dout => flag_pattern_freq_rx_x3 );

----	X4
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		pattern_freq_rx_x4 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PATTERN_FREQ_RX_X4_LOW then
				pattern_freq_rx_x4(15 downto 0) <= ps_dout;
			elsif ps_addr = ADDR_PATTERN_FREQ_RX_X4_MIDDLE then
				pattern_freq_rx_x4(31 downto 16) <= ps_dout;
			elsif ps_addr = ADDR_PATTERN_FREQ_RX_X4_HIGH then
				pattern_freq_rx_x4(47 downto 32) <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_pattern_freq_rx_x4_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PATTERN_FREQ_RX_X4_HIGH then
				flag_pattern_freq_rx_x4_internal <= '1';
			else
				flag_pattern_freq_rx_x4_internal <= '0';
			end if;
		else
			flag_pattern_freq_rx_x4_internal <= '0';
		end if;	
	end if;
end process;

U42 : falling_edge_detector PORT MAP ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_pattern_freq_rx_x4_internal,
									   dout => flag_pattern_freq_rx_x4 );

----	跳时参数
process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_wr_time_hopping_x1_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X1 then
				flag_wr_time_hopping_x1_internal <= '1';
			else
				flag_wr_time_hopping_x1_internal <= '0';
			end if;
		else
			flag_wr_time_hopping_x1_internal <= '0';
		end if;	
	end if;
end process;

U17 : falling_edge_detector PORT MAP ( reset => reset_128M,
													clk => clk_128M,
													din => flag_wr_time_hopping_x1_internal,
													dout => flag_wr_time_hopping_x1 );	

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		counter_time_hopping_x1 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if flag_wr_time_hopping_x1 = '1' then
			counter_time_hopping_x1 <= counter_time_hopping_x1 + 1;
		elsif flag_configuration_rx_complete = '1' then
			counter_time_hopping_x1 <= (others => '0');
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		time_hopping_rx_x1_s <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X1 then
				time_hopping_rx_x1_s <= ps_dout(13 downto 0);
			end if;
		end if;
	end if;
end process;
flag_time_hoppong_rx_x1 <= flag_wr_time_hopping_x1;

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_wr_time_hopping_x2_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X2 then
				flag_wr_time_hopping_x2_internal <= '1';
			else
				flag_wr_time_hopping_x2_internal <= '0';
			end if;
		else
			flag_wr_time_hopping_x2_internal <= '0';
		end if;	
	end if;
end process;

U18 : falling_edge_detector PORT MAP ( reset => reset_128M,
													clk => clk_128M,
													din => flag_wr_time_hopping_x2_internal,
													dout => flag_wr_time_hopping_x2 );	

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		counter_time_hopping_x2 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if flag_wr_time_hopping_x2 = '1' then
			counter_time_hopping_x2 <= counter_time_hopping_x2 + 1;
		elsif flag_configuration_rx_complete = '1' then
			counter_time_hopping_x2 <= (others => '0');
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		time_hopping_rx_x2_s <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X2 then
				time_hopping_rx_x2_s <= ps_dout(13 downto 0);
			end if;
		end if;
	end if;
end process;
flag_time_hoppong_rx_x2 <= flag_wr_time_hopping_x2;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		time_hopping_rx_x1 <= ((others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'));
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X1 then
				case counter_time_hopping_x1 is
					when "0000" => time_hopping_rx_x1(0) <= ps_dout(13 downto 0);		
					when "0001" => time_hopping_rx_x1(1) <= ps_dout(13 downto 0);	
					when "0010" => time_hopping_rx_x1(2) <= ps_dout(13 downto 0);	
					when "0011" => time_hopping_rx_x1(3) <= ps_dout(13 downto 0);	
					when "0100" => time_hopping_rx_x1(4) <= ps_dout(13 downto 0);	
					when "0101" => time_hopping_rx_x1(5) <= ps_dout(13 downto 0);	
					when "0110" => time_hopping_rx_x1(6) <= ps_dout(13 downto 0);	
					when "0111" => time_hopping_rx_x1(7) <= ps_dout(13 downto 0);	
					when "1000" => time_hopping_rx_x1(8) <= ps_dout(13 downto 0);	
					when "1001" => time_hopping_rx_x1(9) <= ps_dout(13 downto 0);	
					when "1010" => time_hopping_rx_x1(10) <= ps_dout(13 downto 0);	
					when "1011" => time_hopping_rx_x1(11) <= ps_dout(13 downto 0);	
					when "1100" => time_hopping_rx_x1(12) <= ps_dout(13 downto 0);	
					when "1101" => time_hopping_rx_x1(13) <= ps_dout(13 downto 0);	
					when "1110" => time_hopping_rx_x1(14) <= ps_dout(13 downto 0);	
					when others => null;
				end case;	
			end if;
		end if;
	end if;
end process;
		
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		time_hopping_rx_x2 <= ((others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'));
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X2 then
				case counter_time_hopping_x2 is
					when "0000" => time_hopping_rx_x2(0) <= ps_dout(13 downto 0);		
					when "0001" => time_hopping_rx_x2(1) <= ps_dout(13 downto 0);	
					when "0010" => time_hopping_rx_x2(2) <= ps_dout(13 downto 0);	
					when "0011" => time_hopping_rx_x2(3) <= ps_dout(13 downto 0);	
					when "0100" => time_hopping_rx_x2(4) <= ps_dout(13 downto 0);	
					when "0101" => time_hopping_rx_x2(5) <= ps_dout(13 downto 0);	
					when "0110" => time_hopping_rx_x2(6) <= ps_dout(13 downto 0);	
					when "0111" => time_hopping_rx_x2(7) <= ps_dout(13 downto 0);	
					when "1000" => time_hopping_rx_x2(8) <= ps_dout(13 downto 0);	
					when "1001" => time_hopping_rx_x2(9) <= ps_dout(13 downto 0);	
					when "1010" => time_hopping_rx_x2(10) <= ps_dout(13 downto 0);	
					when "1011" => time_hopping_rx_x2(11) <= ps_dout(13 downto 0);	
					when "1100" => time_hopping_rx_x2(12) <= ps_dout(13 downto 0);	
					when "1101" => time_hopping_rx_x2(13) <= ps_dout(13 downto 0);	
					when "1110" => time_hopping_rx_x2(14) <= ps_dout(13 downto 0);	
					when others => null;
				end case;	
			end if;
		end if;
	end if;
end process;
	
process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_wr_time_hopping_x3_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X3 then
				flag_wr_time_hopping_x3_internal <= '1';
			else
				flag_wr_time_hopping_x3_internal <= '0';
			end if;
		else
			flag_wr_time_hopping_x3_internal <= '0';
		end if;	
	end if;
end process;

U19 : falling_edge_detector PORT MAP ( reset => reset_128M,
													clk => clk_128M,
													din => flag_wr_time_hopping_x3_internal,
													dout => flag_wr_time_hopping_x3 );	

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		counter_time_hopping_x3 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if flag_wr_time_hopping_x3 = '1' then
			counter_time_hopping_x3 <= counter_time_hopping_x3 + 1;
		elsif flag_configuration_rx_complete = '1' then
			counter_time_hopping_x3 <= (others => '0');
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		time_hopping_rx_x3_s <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X3 then
				time_hopping_rx_x3_s <= ps_dout(13 downto 0);
			end if;
		end if;
	end if;
end process;
flag_time_hoppong_rx_x3 <= flag_wr_time_hopping_x3;

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_wr_time_hopping_x4_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X4 then
				flag_wr_time_hopping_x4_internal <= '1';
			else
				flag_wr_time_hopping_x4_internal <= '0';
			end if;
		else
			flag_wr_time_hopping_x4_internal <= '0';
		end if;	
	end if;
end process;

U20 : falling_edge_detector PORT MAP ( reset => reset_128M,
													clk => clk_128M,
													din => flag_wr_time_hopping_x4_internal,
													dout => flag_wr_time_hopping_x4 );	

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		counter_time_hopping_x4 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if flag_wr_time_hopping_x4= '1' then
			counter_time_hopping_x4 <= counter_time_hopping_x4 + 1;
		elsif flag_configuration_rx_complete = '1' then
			counter_time_hopping_x4 <= (others => '0');
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		time_hopping_rx_x4_s <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X4 then
				time_hopping_rx_x4_s <= ps_dout(13 downto 0);
			end if;
		end if;
	end if;
end process;
flag_time_hoppong_rx_x4 <= flag_wr_time_hopping_x4;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		time_hopping_rx_x3 <= ((others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'));
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X3 then
				case counter_time_hopping_x3 is
					when "0000" => time_hopping_rx_x3(0) <= ps_dout(13 downto 0);		
					when "0001" => time_hopping_rx_x3(1) <= ps_dout(13 downto 0);	
					when "0010" => time_hopping_rx_x3(2) <= ps_dout(13 downto 0);	
					when "0011" => time_hopping_rx_x3(3) <= ps_dout(13 downto 0);	
					when "0100" => time_hopping_rx_x3(4) <= ps_dout(13 downto 0);	
					when "0101" => time_hopping_rx_x3(5) <= ps_dout(13 downto 0);	
					when "0110" => time_hopping_rx_x3(6) <= ps_dout(13 downto 0);	
					when "0111" => time_hopping_rx_x3(7) <= ps_dout(13 downto 0);	
					when "1000" => time_hopping_rx_x3(8) <= ps_dout(13 downto 0);	
					when "1001" => time_hopping_rx_x3(9) <= ps_dout(13 downto 0);	
					when "1010" => time_hopping_rx_x3(10) <= ps_dout(13 downto 0);	
					when "1011" => time_hopping_rx_x3(11) <= ps_dout(13 downto 0);	
					when "1100" => time_hopping_rx_x3(12) <= ps_dout(13 downto 0);	
					when "1101" => time_hopping_rx_x3(13) <= ps_dout(13 downto 0);	
					when "1110" => time_hopping_rx_x3(14) <= ps_dout(13 downto 0);	
					when others => null;
				end case;	
			end if;
		end if;
	end if;
end process;
		
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		time_hopping_rx_x4 <= ((others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'),
									 (others => '0'),(others => '0'),(others => '0'));
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TIME_HOPPING_X4 then
				case counter_time_hopping_x4 is
					when "0000" => time_hopping_rx_x4(0) <= ps_dout(13 downto 0);		
					when "0001" => time_hopping_rx_x4(1) <= ps_dout(13 downto 0);	
					when "0010" => time_hopping_rx_x4(2) <= ps_dout(13 downto 0);	
					when "0011" => time_hopping_rx_x4(3) <= ps_dout(13 downto 0);	
					when "0100" => time_hopping_rx_x4(4) <= ps_dout(13 downto 0);	
					when "0101" => time_hopping_rx_x4(5) <= ps_dout(13 downto 0);	
					when "0110" => time_hopping_rx_x4(6) <= ps_dout(13 downto 0);	
					when "0111" => time_hopping_rx_x4(7) <= ps_dout(13 downto 0);	
					when "1000" => time_hopping_rx_x4(8) <= ps_dout(13 downto 0);	
					when "1001" => time_hopping_rx_x4(9) <= ps_dout(13 downto 0);	
					when "1010" => time_hopping_rx_x4(10) <= ps_dout(13 downto 0);	
					when "1011" => time_hopping_rx_x4(11) <= ps_dout(13 downto 0);	
					when "1100" => time_hopping_rx_x4(12) <= ps_dout(13 downto 0);	
					when "1101" => time_hopping_rx_x4(13) <= ps_dout(13 downto 0);	
					when "1110" => time_hopping_rx_x4(14) <= ps_dout(13 downto 0);	
					when others => null;
				end case;	
			end if;
		end if;
	end if;
end process;

----	交织参数
process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_wr_PN_deinterleave_internal <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PN_DEINTERLEAVE then
				flag_wr_PN_deinterleave_internal <= '1';
			else
				flag_wr_PN_deinterleave_internal <= '0';
			end if;
		else
			flag_wr_PN_deinterleave_internal <= '0';
		end if;	
	end if;
end process;

U21 : falling_edge_detector PORT MAP ( reset => reset_128M,
													clk => clk_128M,
													din => flag_wr_PN_deinterleave_internal,
													dout => flag_wr_PN_deinterleave );	

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		counter_PN_deinterleave <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if flag_wr_PN_deinterleave = '1' then
			counter_PN_deinterleave <= counter_PN_deinterleave + 1;
		elsif flag_configuration_rx_complete = '1' then
			counter_PN_deinterleave <= (others => '0');
		end if;
	end if;
end process;
flag_PN_deinterleave <= flag_wr_PN_deinterleave;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		PN_deinterleave_s <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PN_DEINTERLEAVE then
				PN_deinterleave_s <= ps_dout;
			end if;
		end if;
	end if;
end process;	

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		PN_deinterleave <= ((others => '0'),(others => '0'),(others => '0'),
								  (others => '0'),(others => '0'),(others => '0'),
								  (others => '0'),(others => '0'),(others => '0'),
								  (others => '0'),(others => '0'),(others => '0'));
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PN_DEINTERLEAVE then
				case counter_PN_deinterleave is
					when "0000" => PN_deinterleave(0) <= ps_dout;	
					when "0001" => PN_deinterleave(1) <= ps_dout;
				    when "0010" => PN_deinterleave(2) <= ps_dout;	
					when "0011" => PN_deinterleave(3) <= ps_dout;	
					when "0100" => PN_deinterleave(4) <= ps_dout;	
					when "0101" => PN_deinterleave(5) <= ps_dout;	
					when "0110" => PN_deinterleave(6) <= ps_dout;	
					when "0111" => PN_deinterleave(7) <= ps_dout;	
					when "1000" => PN_deinterleave(8) <= ps_dout;	
					when "1001" => PN_deinterleave(9) <= ps_dout;	
					when "1010" => PN_deinterleave(10) <= ps_dout;	
					when "1011" => PN_deinterleave(11) <= ps_dout;	
					when others => null;
				end case;	
			end if;
		end if;
	end if;
end process;

----	解扰参数

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_PN_descramble_din <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RX_PN_DESCRAMBLE then
				ram_PN_descramble_din <= ps_dout;	
			end if;
		end if;
	end if;
end process;


process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ram_PN_descramble_we_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RX_PN_DESCRAMBLE then
				ram_PN_descramble_we_internal <= '1';
			else
				ram_PN_descramble_we_internal <= '0';
			end if;
		else
			ram_PN_descramble_we_internal <= '0';
		end if;
	end if;
end process;

U22 : falling_edge_detector Port map ( reset => reset_128M,
													clk => clk_128M,
													din => ram_PN_descramble_we_internal,
													dout => ram_PN_descramble_we_local );	
flag_ram_PN_descramble_din <= ram_PN_descramble_we_local;
ram_PN_descramble_we <= ram_PN_descramble_we_local;

----	接收参数配置完成标志

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_configuration_rx_complete <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RX_CONFIG_COMPLETE then
				flag_configuration_rx_complete <= '1';
			else
				flag_configuration_rx_complete <= '0';
			end if;
		else
			flag_configuration_rx_complete <= '0';
		end if;
	end if;
end process;

U23 : falling_edge_detector Port map ( reset => reset_128M,
													clk => clk_128M,
													din => flag_configuration_rx_complete,
													dout => flag_start_rx_local );

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		rdy_rx <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RX_CONFIG_COMPLETE then
				rdy_rx <= '1';
			end if;	
		end if;
	end if;
end process;
flag_rdy_rx <= flag_start_rx_local;
flag_start_rx <= flag_start_rx_local;


process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		point_test_rx <= "00001001100000";
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_POINT_TEST_RX then
				point_test_rx <= ps_dout(13 downto 0);
			end if;	
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_point_test_rx_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_POINT_TEST_RX then
				flag_point_test_rx_internal <= '1';
			else
				flag_point_test_rx_internal <= '0';
			end if;
		else
			flag_point_test_rx_internal <= '0';
		end if;
	end if;
end process;

U45 : falling_edge_detector Port map ( reset => reset_128M,
													clk => clk_128M,
													din => flag_point_test_rx_internal,
													dout => flag_point_test_rx );
								   
----------------------------------------------------------------------------
----------------				 TX 					-------------------
----------------------------------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		arm_config_switch <= "100";
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PA_SWITCH then								
				arm_config_switch <= ps_dout(2 downto 0);	---2-LNAQ(默认不用) 1-LNA,0-PA
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		arm_config_power_control <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_POWER_CONTROL then								
				arm_config_power_control <= ps_dout(5 downto 2);	
			end if;
		end if;
	end if;
end process;

process(reset_128M, clk_128M)
	begin
		if reset_128M = '0' then
			TX_pwrctrl_internal <= '0';
		elsif clk_128M' event and clk_128M = '1' then
			if ps_cen = '0' and ps_wen = '0' then
				if ps_addr = ADDR_POWER_CONTROL then
					TX_pwrctrl_internal <= '1';
				else
					TX_pwrctrl_internal <= '0';
				end if;
			else
				TX_pwrctrl_internal <= '0';
			end if;
		end if;
	end process;

U24 : falling_edge_detector Port map ( reset => reset_128M,
												   clk => clk_128M,
												   din => TX_pwrctrl_internal,
												   dout => TX_pwrctrl_internal_en );

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		TX_pwrctrl_internal_cnt <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if TX_pwrctrl_internal_en = '1' then
			TX_pwrctrl_internal_cnt <= "0001";
		elsif TX_pwrctrl_internal_cnt /= 0 then
			TX_pwrctrl_internal_cnt <= TX_pwrctrl_internal_cnt + 1;
		end if;
	end if;
end process;

--process(reset_128M, clk_128M)
--	begin
--		if reset_128M = '0' then
--			TX_LE <= '0';
--		elsif clk_128M' event and clk_128M = '1' then
--			if TX_pwrctrl_internal_cnt /= 0 then
--				TX_LE <= '1';
--			else
--				TX_LE <= '0';
--			end if;
--		end if;
--end process;
----------------------------------------------------
--------				"000":CIC+2M			-------------
--------				"001":CIC+250k			-------------
--------				"100":FIR+2M			-------------
--------				"101":FIR+250k			-------------
----------------------------------------------------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		arm_config_rx_rate_mode <= (others => '0');
		arm_config_rx_filter_sel <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RX_RATE_MODE then								
				arm_config_rx_rate_mode <= ps_dout(1 downto 0);	
				arm_config_rx_filter_sel <= ps_dout(2);
			end if;
		end if;
	end if;
end process;

process(reset_128M, clk_128M)
	begin
		if reset_128M = '0' then
			flag_arm_config_rx_rate_mode_sel_internal <= '0';
		elsif clk_128M' event and clk_128M = '1' then
			if ps_cen = '0' and ps_wen = '0' then
				if ps_addr = ADDR_RX_RATE_MODE then
					flag_arm_config_rx_rate_mode_sel_internal <= '1';
				else
					flag_arm_config_rx_rate_mode_sel_internal <= '0';
				end if;
			else
				flag_arm_config_rx_rate_mode_sel_internal <= '0';
			end if;
		end if;
	end process;

U51 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_arm_config_rx_rate_mode_sel_internal,
									   dout => flag_arm_config_rx_rate_mode_sel );

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------                频点择优模式                  ----------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
----	freq_mode
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		dds_clr <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RX_CONFIG_COMPLETE then
				dds_clr <= '1';
			elsif ps_addr = ADDR_FREQ_MODE then
				dds_clr <= '0';
			elsif ps_addr = ADDR_FREQ_CONFIG_COMPLETE then
				dds_clr <= '1';
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		freq_mode <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_FREQ_MODE then
				freq_mode <= ps_dout(0);
			end if;
		end if;
	end if;
end process;
----------------------------mode
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		freq_config_complete_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_FREQ_CONFIG_COMPLETE then
				freq_config_complete_internal <= '1';
			else
				freq_config_complete_internal <= '0';
			end if;
		else
			freq_config_complete_internal <= '0';
		end if;
	end if;
end process;

U25 : falling_edge_detector Port map ( reset => reset_128M,
												   clk => clk_128M,
												   din => freq_config_complete_internal,
												   dout => freq_config_complete);
																									
----------------------------compete
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		dds_next_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_FREQ_DDS_NEXT then
				dds_next_internal <= '1';
			else
				dds_next_internal <= '0';
			end if;
		else
			dds_next_internal <= '0';
		end if;
	end if;
end process;

U26 : falling_edge_detector Port map ( reset => reset_128M,
												   clk => clk_128M,
												   din => dds_next_internal,
												   dout => dds_next);
----------------------------next													
process(reset_128M, clk_128M)
	begin
		if reset_128M = '0' then
			dds_num <= (others => '0');
		elsif clk_128M' event and clk_128M = '1' then
			if dds_next = '1' then
				dds_num <= dds_num + 1;
			elsif freq_config_complete = '1' then
				dds_num <= (others => '0');
			end if;
		end if;
	end process;
----------------------------num
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		dds_freq_para_index <= ((others => '0'),(others => '0'),(others => '0'),
										(others => '0'),(others => '0'),(others => '0'),
										(others => '0'),(others => '0'),(others => '0'),
										(others => '0'),(others => '0'),(others => '0'),
										(others => '0'),(others => '0'),(others => '0'));
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_FREQ_DDS_PARA then
				case dds_num is
					when "0000" => dds_freq_para_index(0) <= ps_dout(3 downto 0);
					when "0001" => dds_freq_para_index(1) <= ps_dout(3 downto 0);
					when "0010" => dds_freq_para_index(2) <= ps_dout(3 downto 0);
					when "0011" => dds_freq_para_index(3) <= ps_dout(3 downto 0);
					when "0100" => dds_freq_para_index(4) <= ps_dout(3 downto 0);
					when "0101" => dds_freq_para_index(5) <= ps_dout(3 downto 0);
					when "0110" => dds_freq_para_index(6) <= ps_dout(3 downto 0);
					when "0111" => dds_freq_para_index(7) <= ps_dout(3 downto 0);
					when "1000" => dds_freq_para_index(8) <= ps_dout(3 downto 0);
					when "1001" => dds_freq_para_index(9) <= ps_dout(3 downto 0);
					when "1010" => dds_freq_para_index(10) <= ps_dout(3 downto 0);
					when "1011" => dds_freq_para_index(11) <= ps_dout(3 downto 0);
					when "1100" => dds_freq_para_index(12) <= ps_dout(3 downto 0);
					when "1101" => dds_freq_para_index(13) <= ps_dout(3 downto 0);
					when "1110" => dds_freq_para_index(14) <= ps_dout(3 downto 0);
					when others => null;
				end case;
			end if;
		end if;
	end if;
end process;

REPRAT_FREQ:
for i in 0 to 14 generate
	process(reset_128M,clk_128M)
	begin
		if reset_128M = '0' then
            dds_freq_para_local(i) <= ( (others => '0'),(others => '0'),(others => '0'),(others => '0'),
                                        (others => '0'),(others => '0'),(others => '0'),(others => '0'),
                                        (others => '0')
                                       );
		elsif clk_128M'event and clk_128M = '1' then
			if freq_mode = '1' then
				dds_freq_para_local(i) <= dds_freq_para(conv_integer(dds_freq_para_index(i)));
			else
				dds_freq_para_local(i) <= dds_freq_para(i);
			end if;
		end if;
	end process;
	


end generate;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		counter_switch <='0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_counter_switch then
		      counter_switch<=ps_dout(0);
			end if;
		end if;
	end if;
end process;

----    time offset reg    ----
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		offset_time_2 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_offset_2 then
		      offset_time_2 <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		offset_time_1 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_offset_1 then
		      offset_time_1 <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		offset_time_0 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_offset_0 then
		      offset_time_0 <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_offset_time_adjust_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_offset_0 then
				flag_offset_time_adjust_internal <= '1';
			else
				flag_offset_time_adjust_internal <= '0';
			end if;
		else
			flag_offset_time_adjust_internal <= '0';
		end if;
	end if;
end process;

U28 : falling_edge_detector Port map ( reset => reset_128M,
												   clk => clk_128M,
												   din => flag_offset_time_adjust_internal,
												   dout => flag_offset_time_adjust);


----    time offset reg k7   ----
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		offset_time_2_k7 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_offset_2_k7 then
		      offset_time_2_k7 <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		offset_time_1_k7 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_offset_1_k7 then
		      offset_time_1_k7 <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		offset_time_0_k7 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_offset_0_k7 then
		      offset_time_0_k7 <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_offset_time_adjust_internal_k7 <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_offset_0_k7 then
				flag_offset_time_adjust_internal_k7 <= '1';
			else
				flag_offset_time_adjust_internal_k7 <= '0';
			end if;
		else
			flag_offset_time_adjust_internal_k7 <= '0';
		end if;
	end if;
end process;

U56 : falling_edge_detector Port map ( reset => reset_128M,
												   clk => clk_128M,
												   din => flag_offset_time_adjust_internal_k7,
												   dout => flag_offset_time_adjust_k7);

----jesd配置
----ILA
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		jesd_ila <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_ILA then
		      jesd_ila <= ps_dout(7 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_jesd_ila_local <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_ILA then
				flag_jesd_ila_local <= '1';
			else
				flag_jesd_ila_local <= '0';
			end if;
		else
			flag_jesd_ila_local <= '0';
		end if;
	end if;
end process;

U29 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_jesd_ila_local,
									   dout => flag_jesd_ila);

----SRC
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		jesd_src <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_SRC then
		      jesd_src <= ps_dout(7 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_jesd_src_local <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SRC then
				flag_jesd_src_local <= '1';
			else
				flag_jesd_src_local <= '0';
			end if;
		else
			flag_jesd_src_local <= '0';
		end if;
	end if;
end process;

U30 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_jesd_src_local,
									   dout => flag_jesd_src);
			
----MOD
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		jesd_mod <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_MOD then
		      jesd_mod <= ps_dout(7 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_jesd_mod_local <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_MOD then
				flag_jesd_mod_local <= '1';
			else
				flag_jesd_mod_local <= '0';
			end if;
		else
			flag_jesd_mod_local <= '0';
		end if;
	end if;
end process;

U31 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_jesd_mod_local,
									   dout => flag_jesd_mod);
									  
----F
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		jesd_f <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_F then
		      jesd_f <= ps_dout(7 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_jesd_f_local <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_F then
				flag_jesd_f_local <= '1';
			else
				flag_jesd_f_local <= '0';
			end if;
		else
			flag_jesd_f_local <= '0';
		end if;
	end if;
end process;

U32 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_jesd_f_local,
									   dout => flag_jesd_f);
									   
----K
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		jesd_k <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_K then
		      jesd_k <= ps_dout(7 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_jesd_k_local <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_K then
				flag_jesd_k_local <= '1';
			else
				flag_jesd_k_local <= '0';
			end if;
		else
			flag_jesd_k_local <= '0';
		end if;
	end if;
end process;

U33 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_jesd_k_local,
									   dout => flag_jesd_k);

----LANES
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		jesd_lanes <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_LANES then
		      jesd_lanes <= ps_dout(7 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_jesd_lanes_local <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_LANES then
				flag_jesd_lanes_local <= '1';
			else
				flag_jesd_lanes_local <= '0';
			end if;
		else
			flag_jesd_lanes_local <= '0';
		end if;
	end if;
end process;

U34 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_jesd_lanes_local,
									   dout => flag_jesd_lanes);	

----SUBCLASS
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		jesd_subclass <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_SUBCLASS then
		      jesd_subclass <= ps_dout(7 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_jesd_subclass_local <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SUBCLASS then
				flag_jesd_subclass_local <= '1';
			else
				flag_jesd_subclass_local <= '0';
			end if;
		else
			flag_jesd_subclass_local <= '0';
		end if;
	end if;
end process;

U35 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_jesd_subclass_local,
									   dout => flag_jesd_subclass);		

----DELAY
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		jesd_delay <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_DELAY then
		      jesd_delay <= ps_dout(7 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_jesd_delay_local <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_DELAY then
				flag_jesd_delay_local <= '1';
			else
				flag_jesd_delay_local <= '0';
			end if;
		else
			flag_jesd_delay_local <= '0';
		end if;
	end if;
end process;

U36 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_jesd_delay_local,
									   dout => flag_jesd_delay);

----ERRO
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		jesd_erro <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_ERRO then
		      jesd_erro <= ps_dout(7 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_jesd_erro_local <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_ERRO then
				flag_jesd_erro_local <= '1';
			else
				flag_jesd_erro_local <= '0';
			end if;
		else
			flag_jesd_erro_local <= '0';
		end if;
	end if;
end process;

U37 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_jesd_erro_local,
									   dout => flag_jesd_erro);	

----ERROO
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		jesd_erroo <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_ERROO then
		      jesd_erroo <= ps_dout(15 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_jesd_erroo_local <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_ERROO then
				flag_jesd_erroo_local <= '1';
			else
				flag_jesd_erroo_local <= '0';
			end if;
		else
			flag_jesd_erroo_local <= '0';
		end if;
	end if;
end process;

U38 : falling_edge_detector Port map ( reset => reset_128M,
									   clk => clk_128M,
									   din => flag_jesd_erroo_local,
									   dout => flag_jesd_erroo);	







process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_tx_nread_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TX_NREAD then
				flag_tx_nread_internal <= '1';
			else
				flag_tx_nread_internal <= '0';
			end if;
		else
			flag_tx_nread_internal <= '0';
		end if;
	end if;
end process;

U60 : falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => flag_tx_nread_internal,
									   dout  => flag_tx_nread);	

----------------------------------------------------------------------------
--------------------------RF_PLL_TxRx初始化----------------------------------
----------------------------------------------------------------------------
process(reset,clk)
begin
    if reset = '0' then
        flag_RF_PLL_TxRx_internal <= '0';
    elsif clk'event and clk = '1' then
        if ps_cen = '0' and ps_wen = '0' then
            if ps_addr = ADDR_RF_PLL_TxRx_HIGH or ps_addr = ADDR_RF_PLL_BOTH_HIGH then
                flag_RF_PLL_TxRx_internal <= '1';
            else
                flag_RF_PLL_TxRx_internal <= '0';
            end if;
        else
            flag_RF_PLL_TxRx_internal <= '0';
        end if;
    end if;
end process;
                                                  
U61 : falling_edge_detector Port map ( reset => reset,
                                       clk => clk,
                                       din => flag_RF_PLL_TxRx_internal,
                                       dout => flag_RF_PLL_TxRx_configuration );
----------------------------------------------------------------------------
--------------------------RF_PLL_CLK初始化-----------------------------------
----------------------------------------------------------------------------
process(reset,clk)
begin
    if reset = '0' then
        flag_RF_PLL_CLK_internal <= '0';
    elsif clk'event and clk = '1' then
        if ps_cen = '0' and ps_wen = '0' then
            if ps_addr = ADDR_RF_PLL_CLK_HIGH or ps_addr = ADDR_RF_PLL_BOTH_HIGH then
                flag_RF_PLL_CLK_internal <= '1';
            else
                flag_RF_PLL_CLK_internal <= '0';
            end if;
        else
            flag_RF_PLL_CLK_internal <= '0';
        end if;
    end if;
end process;

U62 : falling_edge_detector Port map ( reset => reset,
                                      clk => clk,
                                      din => flag_RF_PLL_CLK_internal,
                                      dout => flag_RF_PLL_CLK_configuration );


process(reset,clk)
begin
    if reset = '0' then
        data_RF_PLL_configuration <= (others => '0');
    elsif clk'event and clk = '1' then
        if ps_cen = '0' and ps_wen = '0' then
            if ps_addr = ADDR_RF_PLL_TxRx_LOW or ps_addr = ADDR_RF_PLL_CLK_LOW then
                data_RF_PLL_configuration(15 downto 0) <= ps_dout;
            elsif ps_addr = ADDR_RF_PLL_TxRx_HIGH or ps_addr = ADDR_RF_PLL_CLK_HIGH then
                data_RF_PLL_configuration(31 downto 16) <= ps_dout;
            elsif ps_addr = ADDR_RF_PLL_BOTH_HIGH then
                data_RF_PLL_configuration(31 downto 16) <= ps_dout;
            end if;
        end if;
    end if;
end process;  
----------------------------------------------------------------------------
---------------------------RF_PLL_CEN初始化----------------------------------
----------------------------------------------------------------------------
--process(reset, clk)
--begin
--    if reset = '0' then
--        RF_PLL_CEN1 <= '0';
--        RF_PLL_CEN2 <= '0';
--    elsif clk' event and clk = '1' then
--        if ps_cen_100M1 = '0' and ps_wen_100M1 = '0' then
--            if ps_addr_100M1 = ADDR_RF_PLL_CEN then
--                RF_PLL_CEN1 <= ps_dout_100M1(0);
--                RF_PLL_CEN2 <= ps_dout_100M1(1);
--            end if;
--        end if;
--    end if;
--end process;
-----------------------------------------------------------------------
---------------------------   功放   ----------------------------------
-----------------------------------------------------------------------


process(reset,clk)
begin
	if reset = '0' then
		LNA_switch_hand_1 <=  '1';
	elsif clk'event and clk = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_LNA_switch_hand_1 then
				LNA_switch_hand_1 <= ps_dout(0);
			end if;
		end if;
	end if;
end process;

process(reset,clk)
begin
	if reset = '0' then
		LNA_switch_hand_2 <=  '1';
	elsif clk'event and clk = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_LNA_switch_hand_2 then
				LNA_switch_hand_2 <= ps_dout(0);
			end if;
		end if;
	end if;
end process;

process(reset,clk)
begin
	if reset = '0' then
		PA_switch_hand <=  '0';
	elsif clk'event and clk = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PA_switch_hand then
				PA_switch_hand <= ps_dout(0);
			end if;
		end if;
	end if;
end process;


process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		EN_timestamp_cor <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_EN_timestamp_cor then
				EN_timestamp_cor <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_timestamp_cor_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_flag_timestamp_cor then
				flag_timestamp_cor_internal <= '1';
			else
				flag_timestamp_cor_internal <= '0';
			end if;
		else
			flag_timestamp_cor_internal <= '0';
		end if;
	end if;
end process;

U100 : falling_edge_detector port map ( 
    reset => reset_128M,
	clk => clk_128M,
	din => flag_timestamp_cor_internal,
	dout => flag_timestamp_cor
	 );

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		value_timestamp_cor <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_value_timestamp_cor_0 then
				value_timestamp_cor(47 downto 32) <= ps_dout;
		    elsif ps_addr = ADDR_value_timestamp_cor_1 then
		        value_timestamp_cor(31 downto 16) <= ps_dout;
		    elsif ps_addr = ADDR_value_timestamp_cor_2 then
		        value_timestamp_cor(15 downto 0) <= ps_dout;
--		    elsif ps_addr = ADDR_value_timestamp_cor_3 then
--		        value_timestamp_cor(15 downto 0) <= ps_dout;
			end if;
		end if;
	end if;
end process;	

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		polarity_cor <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_polarity_cor then
				polarity_cor <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;




-----------------------------------------------------------------------
---------------------------   模拟多普勒频偏  -------------------------
-----------------------------------------------------------------------


process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		doppler_freq <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_DOPPLER_FREQ then
				doppler_freq <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		doppler_freq_init0 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_DOPPLER_FREQ_init_0 then
				doppler_freq_init0 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		doppler_freq_init1 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_DOPPLER_FREQ_init_1 then
				doppler_freq_init1 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		doppler_freq_init2 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_DOPPLER_FREQ_init_2 then
				doppler_freq_init2 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		doppler_freq_init3 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_DOPPLER_FREQ_init_3 then
				doppler_freq_init3 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		doppler_freq_init4 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_DOPPLER_FREQ_init_4 then
				doppler_freq_init4 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		doppler_freq_init5 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_DOPPLER_FREQ_init_5 then
				doppler_freq_init5 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		doppler_freq_init6 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_DOPPLER_FREQ_init_6 then
				doppler_freq_init6 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		doppler_freq_init7 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_DOPPLER_FREQ_init_7 then
				doppler_freq_init7 <= ps_dout;	
			end if;
		end if;
	end if;
end process;


process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		pl_mod <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_pl_mod then
				pl_mod <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		board_mod <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_board_mod then
				board_mod <= ps_dout(1 downto 0);	
			end if;
		end if;
	end if;
end process;

-------  射频  -------
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		PA_switch_ps <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_PA_switch_ps then
				PA_switch_ps <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		LNA_switch_ps <= '1';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_LNA_switch_ps then
				LNA_switch_ps <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		T_R_TTL_ps <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_T_R_TTL then
				T_R_TTL_ps <= ps_dout(0);		
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		SW_R0_in_ps <= '1';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SW_R0_in_ps then
				SW_R0_in_ps <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		SW_R1_in_ps <= '1';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SW_R1_in_ps then
				SW_R1_in_ps <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		SW_R2_in_ps <= '1';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SW_R2_in_ps then
				SW_R2_in_ps <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		SW_T_in_ps <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SW_T_in_ps then
				SW_T_in_ps <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		SEL0_TX_in_ps <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SEL0_TX_in_ps then
				SEL0_TX_in_ps <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		SEL1_TX_in_ps <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_SEL1_TX_in_ps then
				SEL1_TX_in_ps <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		R0_C0_ps   <= '0';
        R0_C1_ps   <= '0';
        R0_C2_ps   <= '0';
        R0_C3_ps   <= '0';
        R0_C4_ps   <= '0';
        R0_C5_ps   <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_R0 then
				R0_C0_ps   <= ps_dout(0);
                R0_C1_ps   <= ps_dout(1);
                R0_C2_ps   <= ps_dout(2);
                R0_C3_ps   <= ps_dout(3);
                R0_C4_ps   <= ps_dout(4);
                R0_C5_ps   <= ps_dout(5);	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		R1_C0_ps   <= '0';
        R1_C1_ps   <= '0';
        R1_C2_ps   <= '0';
        R1_C3_ps   <= '0';
        R1_C4_ps   <= '0';
        R1_C5_ps   <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_R1 then
				R1_C0_ps   <= ps_dout(0);
                R1_C1_ps   <= ps_dout(1);
                R1_C2_ps   <= ps_dout(2);
                R1_C3_ps   <= ps_dout(3);
                R1_C4_ps   <= ps_dout(4);
                R1_C5_ps   <= ps_dout(5);	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		R2_C0_ps   <= '0';
        R2_C1_ps   <= '0';
        R2_C2_ps   <= '0';
        R2_C3_ps   <= '0';
        R2_C4_ps   <= '0';
        R2_C5_ps   <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_R2 then
				R2_C0_ps   <= ps_dout(0);
                R2_C1_ps   <= ps_dout(1);
                R2_C2_ps   <= ps_dout(2);
                R2_C3_ps   <= ps_dout(3);
                R2_C4_ps   <= ps_dout(4);
                R2_C5_ps   <= ps_dout(5);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		T_C0_ps    <= '1';
        T_C1_ps    <= '1';
        T_C2_ps    <= '1';
        T_C3_ps    <= '1';       
        T_C4_ps    <= '1'; 
        T_C5_ps    <= '1'; 
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_T then
				T_C0_ps   <= ps_dout(0);
                T_C1_ps   <= ps_dout(1);
                T_C2_ps   <= ps_dout(2);
                T_C3_ps   <= ps_dout(3);            
                T_C4_ps   <= ps_dout(4);
                T_C5_ps   <= ps_dout(5);
			end if;
		end if;
	end if;
end process;        
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        work_mod <= "01";
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_work_mod then
                work_mod <= ps_dout(1 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        wave_mod <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_wave_mod then
                wave_mod <= ps_dout(0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        data_en <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_data_en then
                data_en <= ps_dout(0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        initial_complete_state <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_initial_complete_state then
                initial_complete_state <= ps_dout(0);
			end if;
		end if;
	end if;
end process;

U_ila_ps_write_128M : ila_ps_write_128M
PORT MAP (
	clk => clk_128M,
	probe0(0) => ps_wen, 
	probe1(0) => ps_cen, 
	probe2 => ps_dout,
	probe3 => ps_addr,
	probe4 => flag_lock_reg_PS_read,
	probe5(0) => flag_lock_reg_PS_read_tx_internal,
	probe6(0) => flag_lock_reg_PS_read_tx_internal
);

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        agc_control_mode <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_agc_control_mode then
                agc_control_mode <= ps_dout;
			end if;
		end if;
	end if;
end process; 

--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--        mod_envelope <= (others => '0');
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_mod_envelope then
--                mod_envelope <= ps_dout(2 downto 0);
--			end if;
--		end if;
--	end if;
--end process; 

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        agc_arm_ctrl_mode <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_agc_arm_ctrl_mode then
                agc_arm_ctrl_mode <= ps_dout;
			end if;
		end if;
	end if;
end process; 

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		agc_arm_ctrl_12_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_agc_arm_ctrl_12 then
				agc_arm_ctrl_12_internal <= '1';
			else
				agc_arm_ctrl_12_internal <= '0';
			end if;
		else
			agc_arm_ctrl_12_internal <= '0';
		end if;
	end if;
end process;  

U600 : falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => agc_arm_ctrl_12_internal,
									   dout  => agc_arm_ctrl_12 
									);
									
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        agc_arm_ctrl_DVGA4_delay <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_agc_arm_ctrl_DVGA4 then
                agc_arm_ctrl_DVGA4_delay <= ps_dout(5 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_agc_arm_ctrl_DVGA4_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_agc_arm_ctrl_DVGA4 then
				flag_agc_arm_ctrl_DVGA4_internal <= '1';
			else
				flag_agc_arm_ctrl_DVGA4_internal <= '0';
			end if;
		else
			flag_agc_arm_ctrl_DVGA4_internal <= '0';
		end if;
	end if;
end process;  

U601 : falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => flag_agc_arm_ctrl_DVGA4_internal,
									   dout  => flag_agc_arm_ctrl_DVGA4_internal_out
									);
									
flag_agc_arm_ctrl_DVGA4 <= flag_agc_arm_ctrl_DVGA4_internal_out ;
							
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        agc_arm_ctrl_DVGA4 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if flag_agc_arm_ctrl_DVGA4_internal_out = '1' then
                agc_arm_ctrl_DVGA4 <= agc_arm_ctrl_DVGA4_delay;
		end if;
	end if;
end process;								


process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        THRESHOLD_WIDTH <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_THRESHOLD_WIDTH then
                THRESHOLD_WIDTH <= ps_dout(15 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        THRESHOLD_INSIDE <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_THRESHOLD_INSIDE then
                THRESHOLD_INSIDE <= ps_dout(15 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        THRESHOLD_CENTER <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_THRESHOLD_CENTER then
                THRESHOLD_CENTER <= ps_dout(15 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        RESPONSE_TIME <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_RESPONSE_TIME then
                RESPONSE_TIME <= ps_dout(15 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        shift_config_value <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_shift_config_value then
                shift_config_value <= ps_dout(3 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        shift_din_value <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_shift_din_value then
                shift_din_value <= ps_dout(3 downto 0);
			end if;
		end if;
	end if;
end process;


process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        flag_rdy_wideband <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_flag_rdy_wideband then
                flag_rdy_wideband <= ps_dout(0);
            else
                flag_rdy_wideband <= '0';
			end if;
	    else
	       flag_rdy_wideband <= '0';
		end if;
	end if;
end process;


process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        flag_xdma_test_rdy <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_flag_xdma_test_rdy then
                flag_xdma_test_rdy <= ps_dout(0);
            else
                flag_xdma_test_rdy <= '0';
			end if;
	    else
	       flag_xdma_test_rdy <= '0';
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
        xdma_stop <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_xdma_stop then
                xdma_stop <= ps_dout(0);
			end if;
		end if;
	end if;
end process;
-------------------------------------------------------------------------
-----------------------------    DAC输出测试    -------------------------
-------------------------------------------------------------------------

--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		flag_10M_start <=  '0';
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_flag_10M_start then
--				flag_10M_start <= ps_dout(0);	
--			end if;
--		end if;
--	end if;
--end process;

--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		s_axis_phase_inc <= x"1400";
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_DAC_OUTPUT_FREQ_INC then
--				s_axis_phase_inc <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		s_axis_phase_offset_0 <= (others => '0');
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_DAC_OUTPUT_FREQ_init_0 then
--				s_axis_phase_offset_0 <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		s_axis_phase_offset_1 <= x"0280";
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_DAC_OUTPUT_FREQ_init_1 then
--				s_axis_phase_offset_1 <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		s_axis_phase_offset_2 <= x"0500";
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_DAC_OUTPUT_FREQ_init_2 then
--				s_axis_phase_offset_2 <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		s_axis_phase_offset_3 <= x"0780";
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_DAC_OUTPUT_FREQ_init_3 then
--				s_axis_phase_offset_3 <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		s_axis_phase_offset_4 <= x"0A00";
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_DAC_OUTPUT_FREQ_init_4 then
--				s_axis_phase_offset_4 <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		s_axis_phase_offset_5 <= x"0C80";
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_DAC_OUTPUT_FREQ_init_5 then
--				s_axis_phase_offset_5 <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		s_axis_phase_offset_6 <= x"0F00";
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_DAC_OUTPUT_FREQ_init_6 then
--				s_axis_phase_offset_6 <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;
--process(reset_128M,clk_128M)
--begin
--	if reset_128M = '0' then
--		s_axis_phase_offset_7 <= x"1180";
--	elsif clk_128M'event and clk_128M = '1' then
--		if ps_cen = '0' and ps_wen = '0' then
--			if ps_addr = ADDR_DAC_OUTPUT_FREQ_init_7 then
--				s_axis_phase_offset_7 <= ps_dout;	
--			end if;
--		end if;
--	end if;
--end process;



process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_lock_reg_PS_read <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_flag_lock_reg_PS_read then
				flag_lock_reg_PS_read <= ps_dout(1 downto 0);
			else 
		        flag_lock_reg_PS_read <= (others => '0');
			end if;
		else 
		    flag_lock_reg_PS_read <= (others => '0');
		end if;
	end if;
end process;

U101:falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => flag_lock_reg_PS_read(1),
									   dout  => flag_lock_reg_PS_read_tx_internal );
flag_lock_reg_PS_read_tx <= flag_lock_reg_PS_read_tx_internal;	
								   
U102:falling_edge_detector Port map ( reset => reset_128M,
									   clk   => clk_128M,
									   din   => flag_lock_reg_PS_read(0),
									   dout  => flag_lock_reg_PS_read_rx_internal );
flag_lock_reg_PS_read_rx <= flag_lock_reg_PS_read_rx_internal;	



process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		EN_time_hopping <= (others => '0');  -----从高到低依次控制X1、X2、X3、X4
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_EN_time_hopping then
				EN_time_hopping <= ps_dout(3 DOWNTO 0);	
			end if;
		end if;
	end if;
end process;

----  定频模式切换与选择   ----
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		flag_freq_hopping_control <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_flag_freq_hopping_control then
				flag_freq_hopping_control <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		freq_hopping_select <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_freq_hopping_select then
				freq_hopping_select <= ps_dout(3 downto 0);	
			end if;
		end if;
	end if;
end process;


process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		en_gps <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_en_gps then
				en_gps <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		EN_timebase <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_EN_timebase then
				EN_timebase <= ps_dout(0);	
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		num_frame_timeslot <=(others=>'0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_num_frame_timeslot then
		      num_frame_timeslot <=ps_dout(9 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)  
begin
	if reset_128M = '0' then
		num_preframe_timeslot <=(others=>'0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_num_preframe_timeslot then
		      num_preframe_timeslot <=ps_dout(9 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)  
begin
	if reset_128M = '0' then
		num_payloadframe_timeslot <=(others=>'0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_num_payloadframe_timeslot then
		      num_payloadframe_timeslot <=ps_dout(9 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)  
begin
	if reset_128M = '0' then
		num_timeslot <=(others=>'0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
		  if ps_addr = ADDR_num_timeslot then
		      num_timeslot <=ps_dout(9 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
    if reset_128M = '0' then
        din_RAM_timeslot_confiuration <= (others => '0');
    elsif clk_128M'event and clk_128M = '1' then
        if ps_cen = '0' and ps_wen = '0' then
            if ps_addr = ADDR_din_RAM_timeslot_confiuration then
                din_RAM_timeslot_confiuration <= ps_dout(7 downto 0);
            end if;
        end if;
    end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		we_RAM_timeslot_confiuration_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_din_RAM_timeslot_confiuration then
				we_RAM_timeslot_confiuration_internal <= '1';
			else
				we_RAM_timeslot_confiuration_internal <= '0';
			end if;
		else
			we_RAM_timeslot_confiuration_internal <= '0';
		end if;
	end if;
end process;

U110: falling_edge_detector port map ( 
    reset => reset_128M,
    clk => clk_128M,
    din => we_RAM_timeslot_confiuration_internal,
    dout => we_RAM_timeslot_confiuration 
);

process(reset_128M,clk_128M)
begin
    if reset_128M = '0' then
        value_timeslot_adj <= (others => '0');
    elsif clk_128M'event and clk_128M = '1' then
        if ps_cen = '0' and ps_wen = '0' then
            if ps_addr = ADDR_value_timeslot_adj then
                value_timeslot_adj <= ps_dout(9 downto 0);
            end if;
        end if;
    end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		value_timeslot_adj_internal <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_value_timeslot_adj then
				value_timeslot_adj_internal <= '1';
			else
				value_timeslot_adj_internal <= '0';
			end if;
		else
			value_timeslot_adj_internal <= '0';
		end if;
	end if;
end process;

U112: falling_edge_detector port map ( 
    reset => reset_128M,
    clk => clk_128M,
    din => value_timeslot_adj_internal,
    dout => flag_timeslot_adj 
);

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		speed_control <= "01";
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_speed_control then		
				speed_control <= ps_dout(1 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		master_or_slave <= "01";--默认为主
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_master_or_slave then
				master_or_slave <= ps_dout(1 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		length_mod <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_length_mod then
				length_mod <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		length_mod_offset <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_length_mod_offset then
				length_mod_offset <= ps_dout;
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		TDMA_SPMA_switch <=  '1';--默认是SPMA
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_TDMA_SPMA_switch then
				TDMA_SPMA_switch <= ps_dout(0);
			end if;
		end if;
	end if;
end process;

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		flag_fft_rdy <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_flag_fft_rdy then
				flag_fft_rdy <= '1';
			else
				flag_fft_rdy <= '0';
			end if;
		else
			flag_fft_rdy <= '0';
		end if;	
	end if;
end process;

process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		fft_bram_reset <= '0';
	elsif clk_128M' event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_fft_bram_reset then
				fft_bram_reset <= '1';
			else
				fft_bram_reset <= '0';
			end if;
		else
			fft_bram_reset <= '0';
		end if;	
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		irq1_valid <=  '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_irq1_valid then
				irq1_valid <= ps_dout(0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		reset_DDS_fft <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_reset_DDS_fft then
				reset_DDS_fft <= ps_dout(0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		phase_PINC_fft <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_phase_PINC_fft_HIGH then
				phase_PINC_fft(31 downto 16) <= ps_dout(15 downto 0);
		    elsif ps_addr = ADDR_phase_PINC_fft_low then
				phase_PINC_fft(15 downto 0) <= ps_dout(15 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		phase_POFF_0_fft <= (others => '0');
		phase_POFF_0_fft <= (others => '0');
		phase_POFF_0_fft <= (others => '0');
		phase_POFF_0_fft <= (others => '0');
		phase_POFF_0_fft <= (others => '0');
		phase_POFF_0_fft <= (others => '0');
		phase_POFF_0_fft <= (others => '0');
		phase_POFF_0_fft <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_phase_POFF_0_fft_HIGH then
				phase_POFF_0_fft(31 downto 16) <= ps_dout(15 downto 0);
		    elsif ps_addr = ADDR_phase_POFF_0_fft_LOW then
				phase_POFF_0_fft(15 downto 0) <= ps_dout(15 downto 0);
			elsif ps_addr = ADDR_phase_POFF_1_fft_HIGH then
				phase_POFF_1_fft(31 downto 16) <= ps_dout(15 downto 0);
		    elsif ps_addr = ADDR_phase_POFF_1_fft_LOW then
				phase_POFF_1_fft(15 downto 0) <= ps_dout(15 downto 0);
			elsif ps_addr = ADDR_phase_POFF_2_fft_HIGH then
				phase_POFF_2_fft(31 downto 16) <= ps_dout(15 downto 0);
		    elsif ps_addr = ADDR_phase_POFF_2_fft_LOW then
				phase_POFF_2_fft(15 downto 0) <= ps_dout(15 downto 0);
			elsif ps_addr = ADDR_phase_POFF_3_fft_HIGH then
				phase_POFF_3_fft(31 downto 16) <= ps_dout(15 downto 0);
		    elsif ps_addr = ADDR_phase_POFF_3_fft_LOW then
				phase_POFF_3_fft(15 downto 0) <= ps_dout(15 downto 0);
			elsif ps_addr = ADDR_phase_POFF_4_fft_HIGH then
				phase_POFF_4_fft(31 downto 16) <= ps_dout(15 downto 0);
		    elsif ps_addr = ADDR_phase_POFF_4_fft_LOW then
				phase_POFF_4_fft(15 downto 0) <= ps_dout(15 downto 0);
			elsif ps_addr = ADDR_phase_POFF_5_fft_HIGH then
				phase_POFF_5_fft(31 downto 16) <= ps_dout(15 downto 0);
		    elsif ps_addr = ADDR_phase_POFF_5_fft_LOW then
				phase_POFF_5_fft(15 downto 0) <= ps_dout(15 downto 0);
			elsif ps_addr = ADDR_phase_POFF_6_fft_HIGH then
				phase_POFF_6_fft(31 downto 16) <= ps_dout(15 downto 0);
		    elsif ps_addr = ADDR_phase_POFF_6_fft_LOW then
				phase_POFF_6_fft(15 downto 0) <= ps_dout(15 downto 0);
			elsif ps_addr = ADDR_phase_POFF_7_fft_HIGH then
				phase_POFF_7_fft(31 downto 16) <= ps_dout(15 downto 0);
		    elsif ps_addr = ADDR_phase_POFF_7_fft_LOW then
				phase_POFF_7_fft(15 downto 0) <= ps_dout(15 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		reg_fft_tap_select <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_reg_fft_tap_select then
				reg_fft_tap_select <= ps_dout(2 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		num_valid <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_num_valid then
				num_valid <= ps_dout(13 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		addup_N <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_addup_N then
				addup_N <= ps_dout(15 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		fft_stop <= '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_fft_stop then
				fft_stop <= ps_dout(0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		shift_bits_fft <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_shift_bits_fft then
				shift_bits_fft <= ps_dout(4 downto 0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		gpio_warning_internal <=  '0';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_gpio_warning_internal then
				gpio_warning_internal <= ps_dout(0);
			end if;
		end if;
	end if;
end process;

process(reset_128M,clk)
begin
	if reset_128M = '0' then
		gpio_power_internal <=  '1';
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_gpio_power_internal then
				gpio_power_internal <= ps_dout(0);
			end if;
		end if;
	end if;
end process;



-------------------------------------------------------------------------
-----------------------------    可配置定频频率相位字    ----------------
-------------------------------------------------------------------------

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		configurable_freq_hopping_phase_inc <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_configurable_freq_hopping_phase_inc then
				configurable_freq_hopping_phase_inc <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		configurable_freq_hopping_phase_offset_0 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_configurable_freq_hopping_phase_init_0 then
				configurable_freq_hopping_phase_offset_0 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		configurable_freq_hopping_phase_offset_1 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_configurable_freq_hopping_phase_init_1 then
				configurable_freq_hopping_phase_offset_1 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		configurable_freq_hopping_phase_offset_2 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_configurable_freq_hopping_phase_init_2 then
				configurable_freq_hopping_phase_offset_2 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		configurable_freq_hopping_phase_offset_3 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_configurable_freq_hopping_phase_init_3 then
				configurable_freq_hopping_phase_offset_3 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		configurable_freq_hopping_phase_offset_4 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_configurable_freq_hopping_phase_init_4 then
				configurable_freq_hopping_phase_offset_4 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		configurable_freq_hopping_phase_offset_5 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_configurable_freq_hopping_phase_init_5 then
				configurable_freq_hopping_phase_offset_5 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		configurable_freq_hopping_phase_offset_6 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_configurable_freq_hopping_phase_init_6 then
				configurable_freq_hopping_phase_offset_6 <= ps_dout;	
			end if;
		end if;
	end if;
end process;
process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		configurable_freq_hopping_phase_offset_7 <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_wen = '0' then
			if ps_addr = ADDR_configurable_freq_hopping_phase_init_7 then
				configurable_freq_hopping_phase_offset_7 <= ps_dout;	
			end if;
		end if;
	end if;
end process;

end Behavioral;


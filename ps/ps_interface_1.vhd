----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:45:37 10/17/2013 
-- Design Name: 
-- Module Name:    arm_interface - Behavioral 
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

entity ps_interface_1 is
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
        xdma_stop          : out std_logic;
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
        bpsk_single_shot_ps : out STD_LOGIC;
        bpsk_time_sel_ps    : out STD_LOGIC_VECTOR(9 downto 0);
        bpsk_clock_sel_ps   : out STD_LOGIC_VECTOR(8 downto 0);
        bpsk_tx_busy    : in  STD_LOGIC
	);
end ps_interface_1;

architecture Behavioral of ps_interface_1 is

component arm_interface_write_1
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
        xdma_stop          : out std_logic;
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
        bpsk_single_shot_ps : out STD_LOGIC;
        bpsk_time_sel_ps    : out STD_LOGIC_VECTOR(9 downto 0);
        bpsk_clock_sel_ps   : out STD_LOGIC_VECTOR(8 downto 0)
	);
end component;

component arm_interface_read_1 is
	port (   
		reset 	: in  STD_LOGIC;
		clk 	: in  STD_LOGIC;
        reset_128M 	: in  STD_LOGIC;
		clk_128M   	: in  STD_LOGIC;
		 ----    EMC interface    ----
		 ps_oen_128M  : in    std_logic;
		 ps_cen_128M  : in    std_logic;
		 ps_din_128M  : out   std_logic_vector(15 downto 0);
		 ps_addr_128M : in    std_logic_vector(11 downto 0);
		 
--		 ----    AD9520相关    ----
--		  reg_AD9520_config_rddata 	    : in 	std_logic;
--		 reg_SPI_AD9520_config_state    : in    std_logic_vector(15 downto 0);
		 
--		 ----    AD9680相关    ----
--		 reg_AD9680_config_rddata       : in    std_logic_vector(15 downto 0);
--		 reg_SPI_AD9680_config_state    : in    std_logic_vector(15 downto 0);
--		 data_valid						: in 	std_logic;
--         jesd_ByteIsAligned             : in  STD_LOGIC_VECTOR (7 downto 0);

--		 ----    AD9680_2相关    ----
--        reg_AD9680_2_config_rddata       : in    std_logic_vector(15 downto 0);
--        reg_SPI_AD9680_2_config_state    : in    std_logic_vector(15 downto 0);
----        data_valid_k7                  : in    std_logic;
         
--		 ----    AD9739相关    ----
--		 reg_AD9739_config_rddata       : in    std_logic_vector(15 downto 0);
--		 reg_SPI_AD9739_config_state     : in    std_logic_vector(15 downto 0);
		  
		 reg_tx_interface_buffer_num_0 : in  STD_LOGIC_VECTOR (11 downto 0);
		 reg_tx_interface_buffer_num_1 : in  STD_LOGIC_VECTOR (11 downto 0);
		 reg_tx_interface_buffer_num_2 : in  STD_LOGIC_VECTOR (11 downto 0);
		 flag_monitor_cancel : out  STD_LOGIC;
		 reg_state : in  STD_LOGIC_VECTOR(15 downto 0);
		 reg_monitor : in  STD_LOGIC_VECTOR(15 downto 0);
         
		 ----    FPGA温度    ----
		 MEASURED_TEMP_ZYNQ : in std_logic_vector(11 downto 0);
--	     MEASURED_TEMP_K7 : in std_logic_vector(7 downto 0);
		 
		 ----    K7 版本号    ----
--		 Version_K7  :  in std_logic_vector(2 downto 0);
		 ----    K7 FPGA加载完成标志    ----
--		 DONE_CONFIG_FPGA2  :  in std_logic;
		 --    K7 读取寄存器标志    ----
	     falg_rx_resp  :  in std_logic;
	     rx_resp_data  :  in STD_LOGIC_vector(15 downto 0);
	     falg_rd_respdata_complete  :  out std_logic;
		 
		 ----    时钟锁定标志   ----
--		 clk_lock_state : in std_logic_vector(7 downto 0);
		 ----	RX		----
		 channel_load : in std_logic_vector(15 downto 0);					---- 表征信道负载
		 flag_rd_arm_onetime : out  STD_LOGIC;    
		 counter_2M:in std_logic_vector(15 downto 0);
		 counter_500k:in std_logic_vector(15 downto 0);
		 dout_rx_arm_interface : in  STD_LOGIC_VECTOR (15 downto 0);
		 num_buffer_rx_arm_interface : in  STD_LOGIC_VECTOR (3 downto 0);
		 ----    时间同步    ----
         send_timestamp_2    : in std_logic_vector(15 downto 0);
         send_timestamp_1    : in std_logic_vector(15 downto 0);
         send_timestamp_0    : in std_logic_vector(15 downto 0);
         ----  捕获时标计数器数值----
        send_timestamp_cor_2                     : in std_logic_vector(15 downto 0);
        send_timestamp_cor_1                     : in std_logic_vector(15 downto 0);
        send_timestamp_cor_0                     : in std_logic_vector(15 downto 0);
        -----  捕获时 时标计数器周期新旧值标志-----
        flag_send_timestamp_cor                      : in std_logic;
         ----  发射时间戳更新标志  ----
         flag_tx_time_renew      : in  std_logic;
         ----  发射时间戳读取标志  ----
         flag_tx_timestamp_read  : out std_logic;
		 ----    物理层时间上传    ----
	     reg_phy_time             : in  std_logic_vector(47 downto 0);
		 flag_rd_srio_onetime : out  std_logic;        ----K7 srio读
         num_buffer_rx_srio_interface : in std_logic_vector(3 downto 0);
         dout_rx_srio_interface : in std_logic_vector(15 downto 0) ;
         ---------TDMA----------------
          state_timeslot_adj : in  STD_LOGIC;
         
         ------ 精时间同步  -------
         times_timestamp_cor : in  STD_LOGIC_VECTOR (15 downto 0);
         ------精时间同步校正次数被读走标志 ------
         flag_times_timestamp_cor_read: out std_logic;
         
         fft_data            : in std_logic_vector(15 downto 0);
         flag_fft_bram_addrb : out std_logic;
         bpsk_tx_busy        : in  std_logic
         
   
		   );
end component;


begin
U1 : arm_interface_write_1 Port map ( 
		reset		=> resetn_ps,
		clk   	    => clk_100M,
		reset_128M  => reset,
		clk_128M   	=> clk_128M,
		----    EMC interface    ----
		ps_wen_128M  => ps_wen,
		ps_cen_128M  => ps_cen,
		ps_dout_128M => ps_dout,
		ps_addr_128M => ps_addr,
		
		LNA_switch_hand_1 => LNA_switch_hand_1,
        LNA_switch_hand_2 => LNA_switch_hand_2,
        PA_switch_hand => PA_switch_hand,
        
		PROGRAM_CONFIG_FPGA2  =>  PROGRAM_CONFIG_FPGA2,
		reset_time  =>  reset_time,
--		----    AD9520相关    ----
--		flag_AD9520_config			=> flag_AD9520_config,
--		reg_AD9520_config_wrdata 	=> reg_AD9520_config_wrdata,
--        reset_PLL       => reset_PLL,

--		----    AD9680相关    ----
--		flag_AD9680_config       	=> flag_AD9680_config,
--		reg_AD9680_config_wrdata 	=> reg_AD9680_config_wrdata,		
--		jesd_reset					=> jesd_reset,
--		jesd_reset_n				=> jesd_reset_n,
--		ps_ReSync					=> ps_ReSync,

--        flag_AD9680_2_config        =>  flag_AD9680_2_config,
--        reg_AD9680_2_config_wrdata  =>  reg_AD9680_2_config_wrdata,

--		----    AD9739相关    ----
--		flag_AD9739_config        	=> flag_AD9739_config,
--		reg_AD9739_config_wrdata  	=> reg_AD9739_config_wrdata,
		
--		----    AD5XXX相关    ----  
--		flag_AD5XXX_config 			=>	flag_AD5XXX_config,
--		reg_AD5XXX_wrdata 			=>	reg_AD5XXX_wrdata,
--		reg_AD5XXX_mode 			=>	reg_AD5XXX_mode,
--        reg_LDAC                    => reg_LDAC,
		
		contrl_8506 => contrl_8506,

		reg_initial_reset => reg_initial_reset,
		reg_tx_mode => reg_tx_mode,
		reg_tx_mode_para => reg_tx_mode_para,
		
		 -----  agc_control  ------
        agc_arm_ctrl_mode  => agc_arm_ctrl_mode,
        agc_arm_ctrl_12  => agc_arm_ctrl_12,
        flag_agc_arm_ctrl_DVGA4   =>  flag_agc_arm_ctrl_DVGA4,
        agc_arm_ctrl_DVGA4  => agc_arm_ctrl_DVGA4,
        THRESHOLD_WIDTH     =>       THRESHOLD_WIDTH,         
        THRESHOLD_INSIDE     =>    THRESHOLD_INSIDE,
        THRESHOLD_CENTER      =>   THRESHOLD_CENTER,
        RESPONSE_TIME		  =>      RESPONSE_TIME,  
        -----  功率检测模式  ------
        agc_control_mode=> agc_control_mode,
        ----------------------------数字衰减----------------
        shift_config_value => shift_config_value ,
        shift_din_value  =>  shift_din_value,
		----	初始化		----
--		agc_arm_ctrl_mode => agc_arm_ctrl_mode,
		agc_arm_ctrl_DVGA1_i => agc_arm_ctrl_DVGA1,
		agc_arm_ctrl_DVGA2_i => agc_arm_ctrl_DVGA2,
--		agc_arm_ctrl_i => agc_arm_ctrl_12,
		agc_arm_ctrl_DVGA1_q => agc_arm_ctrl_DVGA3,
--		agc_arm_ctrl_DVGA2_q => agc_arm_ctrl_DVGA4,
		agc_arm_ctrl_q => agc_arm_ctrl_34,
		ram_PN_sync_we => ram_PN_sync_we,
		ram_PN_sync_din => ram_PN_sync_din,
		ram_PN_PAn_we => ram_PN_PAn_we,
		ram_PN_PAn_din => ram_PN_PAn_din,
		ram_PN_scramble_we => ram_PN_scramble_we,
		ram_PN_scramble_din => ram_PN_scramble_din,
		ram_PN_interleave_we => ram_PN_interleave_we,
		ram_PN_interleave_din => ram_PN_interleave_din,
		----	发射数据	----
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
		----	接收数据	----
		flag_rd_arm_onepacket => flag_rd_arm_onepacket,
		flag_rd_arm_oneint => flag_rd_arm_oneint,
		flag_rd_srio_onepacket => flag_rd_srio_onepacket,
        flag_rd_srio_oneint => flag_rd_srio_oneint,
		falg_irq_k_end => falg_irq_k_end,
		falg_irq_k_end_k => falg_irq_k_end_k,
		----   配置接收参数   ---
		sync_bit_pre_rx => arm_config_sync_head_array,
		sync_bit_post_rx => arm_config_sync_tail_array,
		pattern_freq_rx_x1 => arm_config_matrix_pattern_freq_x1,
		pattern_freq_rx_x2 => arm_config_matrix_pattern_freq_x2,
		pattern_freq_rx_x3 => arm_config_matrix_pattern_freq_x3,
		pattern_freq_rx_x4 => arm_config_matrix_pattern_freq_x4,
		time_hopping_rx_x1 => arm_config_addr_offset_x1,
		time_hopping_rx_x2 => arm_config_addr_offset_x2,
		time_hopping_rx_x3 => arm_config_addr_offset_x3,
		time_hopping_rx_x4 => arm_config_addr_offset_x4,
		PN_deinterleave => arm_config_PN_deinterleave_array,
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
		channel_capure_threshold => channel_capure_threshold,
		Antenna_switch_local => Antenna_switch_local,

		----   K7接收参数     ----
		flag_tx_nread                    =>  flag_tx_nread                   ,
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
		jesd_reset_AD2                   =>  jesd_reset_AD2,
		flag_jesd_reset_AD2                  =>  flag_jesd_reset_AD2                 ,
		----   频点择优模式   ----
		dds_clr => dds_clr,
		dds_freq_para_local => dds_freq_para_local,
		counter_switch => counter_switch,
		----	TEST	----
		arm_config_power_control => arm_config_power_control,
		arm_config_switch => arm_config_switch,
--		TX_LE => TX_LE,
		
        offset_time_2              =>    offset_time_2,
        offset_time_1              =>    offset_time_1,
        offset_time_0              =>    offset_time_0,
        flag_offset_time_adjust    =>    flag_offset_time_adjust,
 		----    time offset    ----
        offset_time_2_k7            =>  offset_time_2_k7           ,
        offset_time_1_k7            =>  offset_time_1_k7           ,
        offset_time_0_k7            =>  offset_time_0_k7           ,
        flag_offset_time_adjust_k7  =>  flag_offset_time_adjust_k7 ,
        STATUS_ADHOC  =>  STATUS_ADHOC,
        
        	    ----   PLL   ----
        flag_RF_PLL_TxRx_configuration => flag_RF_PLL_TxRx_configuration,
        flag_RF_PLL_CLK_configuration => flag_RF_PLL_CLK_configuration,
        data_RF_PLL_configuration => data_RF_PLL_configuration,
--        RF_PLL_CEN1 => RF_PLL_CEN1,
--        RF_PLL_CEN2 => RF_PLL_CEN2,
        
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
		jesd_erroo         =>  jesd_erroo         ,
		flag_jesd_erroo    =>  flag_jesd_erroo    ,
		
		EN_timestamp_cor => EN_timestamp_cor,
        flag_timestamp_cor => flag_timestamp_cor,
        value_timestamp_cor => value_timestamp_cor,
        polarity_cor => polarity_cor,
        
        doppler_freq => doppler_freq     ,
        doppler_freq_init0 => doppler_freq_init0,
        doppler_freq_init1 => doppler_freq_init1,
        doppler_freq_init2 => doppler_freq_init2,
        doppler_freq_init3 => doppler_freq_init3,
        doppler_freq_init4 => doppler_freq_init4,
        doppler_freq_init5 => doppler_freq_init5,
        doppler_freq_init6 => doppler_freq_init6,
        doppler_freq_init7 => doppler_freq_init7,
        pl_mod => pl_mod    ,
        board_mod => board_mod    ,
        work_mod => work_mod,
        wave_mod => wave_mod,
        data_en => data_en,
        PA_switch_ps => PA_switch_ps,  
         LNA_switch_ps => LNA_switch_ps,
        T_R_TTL_ps =>         T_R_TTL_ps ,
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
        initial_complete_state  =>   initial_complete_state ,
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
        flag_lock_reg_PS_read_rx  => flag_lock_reg_PS_read_rx,
        EN_time_hopping           => EN_time_hopping,
        ----  定频模式切换与选择   ----
        flag_freq_hopping_control  => flag_freq_hopping_control,           
        freq_hopping_select     => freq_hopping_select ,
        -----------TDMA---------------
        speed_control => speed_control,
        EN_timebase => EN_timebase,
        num_frame_timeslot            =>  num_frame_timeslot ,				
        num_preframe_timeslot         =>  num_preframe_timeslot ,
        num_payloadframe_timeslot     =>  num_payloadframe_timeslot ,
        num_timeslot                  =>  num_timeslot ,		   
        we_RAM_timeslot_confiuration  =>  we_RAM_timeslot_confiuration ,	      
        din_RAM_timeslot_confiuration =>  din_RAM_timeslot_confiuration,
        flag_timeslot_adj  => flag_timeslot_adj,				
        value_timeslot_adj => value_timeslot_adj,
        master_or_slave          =>master_or_slave          ,
        length_mod              => length_mod       ,
        length_mod_offset       => length_mod_offset   ,
        TDMA_SPMA_switch        => TDMA_SPMA_switch    ,
         ---------灯-------------------------            
         gpio_warning_internal      => gpio_warning_internal  ,
         gpio_power_internal        => gpio_power_internal    ,
        
        ----  GPS使能   ----
        en_gps  =>  en_gps,
        
        irq1_valid          =>  irq1_valid          ,
        fft_bram_reset      =>  fft_bram_reset      ,
        flag_fft_rdy        =>  flag_fft_rdy        ,
        fft_data            =>  fft_data            ,
        flag_fft_bram_addrb =>  flag_fft_bram_addrb ,
                                                    
        reset_DDS_fft       =>  reset_DDS_fft       ,
        phase_PINC_fft      =>  phase_PINC_fft      ,
        phase_POFF_0_fft    =>  phase_POFF_0_fft    ,
        phase_POFF_1_fft    =>  phase_POFF_1_fft    ,
        phase_POFF_2_fft    =>  phase_POFF_2_fft    ,
        phase_POFF_3_fft    =>  phase_POFF_3_fft    ,
        phase_POFF_4_fft    =>  phase_POFF_4_fft    ,
        phase_POFF_5_fft    =>  phase_POFF_5_fft    ,
        phase_POFF_6_fft    =>  phase_POFF_6_fft    ,
        phase_POFF_7_fft    =>  phase_POFF_7_fft    ,
        reg_fft_tap_select  =>  reg_fft_tap_select  ,
        num_valid           =>  num_valid           ,
        addup_N             =>  addup_N             ,
        fft_stop            =>  fft_stop            ,
        shift_bits_fft      =>  shift_bits_fft      ,
        --- wideband ---
        flag_rdy_wideband   =>  flag_rdy_wideband   ,
        flag_xdma_test_rdy  =>  flag_xdma_test_rdy  ,
        xdma_stop           =>  xdma_stop           ,
         ---------定频模式任意频率相位字配置---------- 
        configurable_freq_hopping_phase_inc        =>   configurable_freq_hopping_phase_inc      ,
        configurable_freq_hopping_phase_offset_0   =>   configurable_freq_hopping_phase_offset_0 ,
        configurable_freq_hopping_phase_offset_1   =>   configurable_freq_hopping_phase_offset_1 ,
        configurable_freq_hopping_phase_offset_2   =>   configurable_freq_hopping_phase_offset_2 ,
        configurable_freq_hopping_phase_offset_3   =>   configurable_freq_hopping_phase_offset_3 ,
        configurable_freq_hopping_phase_offset_4   =>   configurable_freq_hopping_phase_offset_4 ,
        configurable_freq_hopping_phase_offset_5   =>   configurable_freq_hopping_phase_offset_5 ,
        configurable_freq_hopping_phase_offset_6   =>   configurable_freq_hopping_phase_offset_6 ,
        configurable_freq_hopping_phase_offset_7   =>   configurable_freq_hopping_phase_offset_7 ,
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
        bpsk_single_shot_ps => bpsk_single_shot_ps,
        bpsk_time_sel_ps    => bpsk_time_sel_ps,
        bpsk_clock_sel_ps   => bpsk_clock_sel_ps
);

U2 : arm_interface_read_1 Port map ( 
		reset		=> resetn_ps,
		clk   	    => clk_100M,
		reset_128M  => reset,
		clk_128M   	=> clk_128M,
		----    EMC interface    ----
		ps_oen_128M  => ps_oen,
		ps_cen_128M  => ps_cen,
		ps_din_128M  => ps_din,
		ps_addr_128M => ps_addr,

		----    AD9520相关    ----
--		reg_AD9520_config_rddata       => reg_AD9520_config_rddata,
--		reg_SPI_AD9520_config_state    => reg_SPI_AD9520_config_state,

--		----    AD9680相关    ----
--		reg_AD9680_config_rddata       => reg_AD9680_config_rddata,
--		reg_SPI_AD9680_config_state    => reg_SPI_AD9680_config_state,
--		data_valid						=> data_valid,
--        jesd_ByteIsAligned              => jesd_ByteIsAligned,
----		data_valid_k7                   => data_valid_k7,
--		----    AD9680_2相关    ----
--        reg_AD9680_2_config_rddata      => reg_AD9680_2_config_rddata,
--        reg_SPI_AD9680_2_config_state   => reg_SPI_AD9680_2_config_state,
		
--		----    AD9739相关    ----
--		reg_AD9739_config_rddata       => reg_AD9739_config_rddata,
--		reg_SPI_AD9739_config_state     => reg_SPI_AD9739_config_state,
									  
		reg_tx_interface_buffer_num_0 => reg_tx_interface_buffer_num_0,
		reg_tx_interface_buffer_num_1 => reg_tx_interface_buffer_num_1,
		reg_tx_interface_buffer_num_2 => reg_tx_interface_buffer_num_2,
		flag_monitor_cancel => flag_monitor_cancel,
		reg_state => reg_state,
		reg_monitor => reg_monitor, 
		
		----    FPGA温度    ----
		MEASURED_TEMP_ZYNQ => MEASURED_TEMP_ZYNQ,
--		MEASURED_TEMP_K7   => MEASURED_TEMP_K7  ,
		
        --    K7 FPGA版本号   ----
--		Version_K7  =>  Version_K7,
		--    K7 FPGA版本加载完成标志
--		DONE_CONFIG_FPGA2  =>  DONE_CONFIG_FPGA2,
		
		-----  k7读取寄存器标志   -----
		falg_rx_resp                 =>  falg_rx_resp,
		rx_resp_data                 =>  rx_resp_data,
		falg_rd_respdata_complete    =>  falg_rd_respdata_complete,
		
--		clk_lock_state => clk_lock_state,
		----	RX	----
		channel_load => channel_load,
		flag_rd_arm_onetime => flag_rd_arm_onetime,
		counter_2M => counter_2M,
		counter_500k => counter_500k,
		dout_rx_arm_interface => dout_rx_arm_interface,
		num_buffer_rx_arm_interface => num_buffer_rx_arm_interface,
		
		send_timestamp_2       =>    send_timestamp_2,
        send_timestamp_1       =>    send_timestamp_1,
        send_timestamp_0       =>    send_timestamp_0,
        ----  捕获时标计数器数值----
        send_timestamp_cor_2            =>       send_timestamp_cor_2 ,
        send_timestamp_cor_1            =>       send_timestamp_cor_1 ,
        send_timestamp_cor_0            =>       send_timestamp_cor_0 ,
        -----  捕获时 时标计数器周期新旧值标志-----
        flag_send_timestamp_cor         =>       flag_send_timestamp_cor,
        
        flag_tx_time_renew     =>    flag_tx_time_renew,
        flag_tx_timestamp_read =>    flag_tx_timestamp_read,
		----    物理层时间上传    ----
	    reg_phy_time           =>    reg_phy_time,
		flag_rd_srio_onetime => flag_rd_srio_onetime,
        num_buffer_rx_srio_interface => num_buffer_rx_srio_interface,
        dout_rx_srio_interface => dout_rx_srio_interface,
        ----------TDMA-------------
        state_timeslot_adj => state_timeslot_adj,
        
        times_timestamp_cor => times_timestamp_cor,
        flag_times_timestamp_cor_read => flag_times_timestamp_cor_read,
        
        fft_data                  =>   fft_data,
        flag_fft_bram_addrb       =>   flag_fft_bram_addrb,
        bpsk_tx_busy            =>   bpsk_tx_busy
                      
);												
end Behavioral;


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:16:25 11/30/2012 
-- Design Name: 
-- Module Name:    arm_interface_read_1 - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.rx_data_types.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity arm_interface_read_1 is
	port(	 reset 	: in  STD_LOGIC;
		clk 	: in  STD_LOGIC;
        reset_128M 	: in  STD_LOGIC;
		clk_128M   	: in  STD_LOGIC;
		 ----    EMC interface    ----
		 ps_oen_128M  : in    std_logic;
		 ps_cen_128M  : in    std_logic;
		 ps_din_128M  : out   std_logic_vector(15 downto 0);
		 ps_addr_128M : in    std_logic_vector(11 downto 0);
		 
		 ----    AD9520相关    ----
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
		 clk_lock_state : in std_logic_vector(7 downto 0);
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
         ------TDMA-----------
         state_timeslot_adj : in  STD_LOGIC;
         
         ------ 精时间同步  -------
         times_timestamp_cor : in  STD_LOGIC_VECTOR (15 downto 0);
         ------精时间同步校正次数被读走标志 ------
         flag_times_timestamp_cor_read: out std_logic;
         fft_data            : in std_logic_vector(15 downto 0);
         flag_fft_bram_addrb : out std_logic;
         ----    BPSK 发射状态  ----
         bpsk_tx_busy        : in  std_logic
          
   
		   );
end arm_interface_read_1;

architecture Behavioral of arm_interface_read_1 is

------------------------------地址定义-------------------------------------------
----		common
constant ADDR_VERSION : std_logic_vector(11 downto 0) := x"100";
constant ADDR_REG_STATE : std_logic_vector(11 downto 0) := x"102";
constant ADDR_REG_MONITOR : std_logic_vector(11 downto 0) := x"104";
constant ADDR_num_500k : std_logic_vector(11 downto 0) := x"106";
constant ADDR_num_2M : std_logic_vector(11 downto 0) := x"108";
----		DAC AD9739
constant ADDR_SPI_AD9739_CONFIG_STATE : std_logic_vector(11 downto 0) := x"110";
constant ADDR_REG_AD9739_CONFIG_RDDATA : std_logic_vector(11 downto 0) := x"112";
----  	 ADC  AD9680
constant ADDR_SPI_AD9680_CONFIG_STATE : std_logic_vector(11 downto 0) := x"114";
constant ADDR_REG_AD9680_CONFIG_RDDATA : std_logic_vector(11 downto 0) := x"116";
----  	 ADC  AD9680_2
constant ADDR_SPI_AD9680_2_CONFIG_STATE : std_logic_vector(11 downto 0) := x"120";
constant ADDR_REG_AD9680_2_CONFIG_RDDATA : std_logic_vector(11 downto 0) := x"122";

constant ADDR_REG_data_valid_k7 : std_logic_vector(11 downto 0) := x"188";
constant ADDR_RELEASE : std_logic_vector(11 downto 0) := x"118";

----  	 PLL  AD9520
constant ADDR_SPI_AD9520_CONFIG_STATE : std_logic_vector(11 downto 0) := x"11a";
constant ADDR_REG_AD9520_CONFIG_RDDATA : std_logic_vector(11 downto 0) := x"11c";
----		TX
constant ADDR_TX_BUFFER_NUM_0 : std_logic_vector(11 downto 0) := x"140";
constant ADDR_TX_BUFFER_NUM_1 : std_logic_vector(11 downto 0) := x"150";
constant ADDR_TX_BUFFER_NUM_2 : std_logic_vector(11 downto 0) := x"160";
----		RX
constant ADDR_READ_RX_DATA : std_logic_vector(11 downto 0) := x"180";
constant ADDR_RX_DATA_BUFFER_NUM : std_logic_vector(11 downto 0) := x"182";

constant ADDR_REG_data_valid : std_logic_vector(11 downto 0) := x"184";
constant ADDR_CHANNEL_STATE : std_logic_vector(11 downto 0) := x"186";
constant ADDR_READ_RX_DATA_SRIO : std_logic_vector(11 downto 0) := x"18a";
constant ADDR_RX_DATA_BUFFER_NUM_SRIO : std_logic_vector(11 downto 0) := x"18c";

constant ADDR_MEASURED_TEMP_ZYNQ : std_logic_vector(11 downto 0) := x"142";
constant ADDR_MEASURED_TEMP_K7 : std_logic_vector(11 downto 0) := x"144";
constant ADDR_clk_lock_state : std_logic_vector(11 downto 0) := x"146";

constant ADDR_Version_K7 : std_logic_vector(11 downto 0) := x"14a";
constant ADDR_DONE_CONFIG_FPGA2 : std_logic_vector(11 downto 0) := x"148";

----    时间同步  ----
constant ADDR_send_timestamp_2 : std_logic_vector(11 downto 0) := x"126";
constant ADDR_send_timestamp_1 : std_logic_vector(11 downto 0) := x"128";
constant ADDR_send_timestamp_0 : std_logic_vector(11 downto 0) := x"12a";
constant ADDR_tx_time_renew    : std_logic_vector(11 downto 0) := x"12c";
constant ADDR_reg_phy_time_2   : std_logic_vector(11 downto 0) := x"130";
constant ADDR_reg_phy_time_1   : std_logic_vector(11 downto 0) := x"132";
constant ADDR_reg_phy_time_0   : std_logic_vector(11 downto 0) := x"134";

constant ADDR_send_timestamp_cor_2 : std_logic_vector(11 downto 0) := x"152";
constant ADDR_send_timestamp_cor_1 : std_logic_vector(11 downto 0) := x"154";
constant ADDR_send_timestamp_cor_0 : std_logic_vector(11 downto 0) := x"156";
constant ADDR_flag_send_timestamp_cor  : std_logic_vector(11 downto 0) := x"158";


-----   K7读取寄存器  ---
constant ADDR_falg_rx_resp   : std_logic_vector(11 downto 0) := x"136";
constant ADDR_reg_resp_data   : std_logic_vector(11 downto 0) := x"138";

-----------TDMA----------------
constant ADDR_state_timeslot_adj      : std_logic_vector(11 downto 0) := x"1AA";

-------    精时间同步  --------
constant ADDR_times_timestamp_cor       : std_logic_vector(11 downto 0) := x"1B8";

constant ADDR_fft_data_rd_complete      : std_logic_vector(11 downto 0) := x"170";
constant ADDR_fft_data                  : std_logic_vector(11 downto 0) := x"176";
----    BPSK 发射状态(只读)  ----
constant ADDR_TX_BPSK_BUSY : std_logic_vector(11 downto 0) := x"71A";

COMPONENT ila_ps_read_128M

PORT (
	clk : IN STD_LOGIC;

	probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe2 : IN STD_LOGIC_VECTOR(11 DOWNTO 0)
);
END COMPONENT  ;


component falling_edge_detector_clk is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           din : in  STD_LOGIC;
           dout : out  STD_LOGIC);
end component;

component falling_edge_detector is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           din : in  STD_LOGIC;
           dout : out  STD_LOGIC);
end component;

signal flag_monitor_cancel_internal : std_logic;
signal flag_rd_arm_onetime_internal : std_logic;
signal flag_rd_srio_onetime_internal : std_logic;
----    时间同步相关    ----
signal flag_tx_timestamp_read_internal       : std_logic;
signal flag_times_timestamp_cor_read_internal : std_logic;
----sample data
signal release_FPGA									: STD_LOGIC_VECTOR(15 downto 0);

signal dout_rx_arm_interface_internal1 				: STD_LOGIC_VECTOR(15 downto 0);
signal dout_rx_srio_interface_internal1             : std_logic_vector(15 downto 0);
signal reg_AD9680_config_rddata_internal1       	: std_logic_vector(15 downto 0);
signal reg_SPI_AD9680_config_state_internal1    	: std_logic_vector(15 downto 0);
signal reg_AD9680_2_config_rddata_internal1       	: std_logic_vector(15 downto 0);
signal reg_SPI_AD9680_2_config_state_internal1    	: std_logic_vector(15 downto 0);
signal data_valid_internal1							: std_logic;
signal data_valid_k7_internal1                      : std_logic;
signal jesd_ByteIsAligned_internal1    	            : std_logic_vector(7 downto 0);
signal reg_AD9739_config_rddata_internal1       	: std_logic_vector(15 downto 0);
signal reg_SPI_AD9739_config_state_internal1     	: std_logic_vector(15 downto 0);
signal reg_tx_interface_buffer_num_0_internal1 		: STD_LOGIC_VECTOR(11 downto 0);
signal reg_tx_interface_buffer_num_1_internal1 		: STD_LOGIC_VECTOR(11 downto 0);
signal reg_tx_interface_buffer_num_2_internal1 		: STD_LOGIC_VECTOR(11 downto 0);
signal reg_monitor_internal1 						: STD_LOGIC_VECTOR(15 downto 0);
signal counter_2M_internal1							: std_logic_vector(15 downto 0);
signal counter_500k_internal1						: std_logic_vector(15 downto 0);			
signal num_buffer_rx_arm_interface_internal1 		: STD_LOGIC_VECTOR(3 downto 0);
signal num_buffer_rx_srio_interface_internal1 		: STD_LOGIC_VECTOR(3 downto 0);
signal channel_load_internal1 						: std_logic_vector(15 downto 0);	
signal MEASURED_TEMP_ZYNQ_internal1                 : std_logic_vector(11 downto 0);
signal MEASURED_TEMP_K7_internal1                   : std_logic_vector(11 downto 0);
--signal clk_lock_state_internal1                     : std_logic_vector(7 downto 0);
signal Version_K7_internal1                         : std_logic_vector(2 downto 0);
signal DONE_CONFIG_FPGA2_internal1                  : std_logic;
signal bpsk_tx_busy_internal1                       : std_logic;

signal send_timestamp_2_internal1                   : std_logic_vector(15 downto 0);
signal send_timestamp_1_internal1                   : std_logic_vector(15 downto 0);
signal send_timestamp_0_internal1                   : std_logic_vector(15 downto 0);
signal reg_phy_time_internal1                       : std_logic_vector(47 downto 0);		
signal send_timestamp_cor_2_internal1                 : std_logic_vector(15 downto 0);
signal send_timestamp_cor_1_internal1                 : std_logic_vector(15 downto 0);
signal send_timestamp_cor_0_internal1                 : std_logic_vector(15 downto 0);
signal flag_send_timestamp_cor_internal1                  : std_logic;		

signal falg_rx_resp_internal1                       : std_logic;
signal rx_resp_data_internal1                       : STD_LOGIC_vector(15 downto 0);



signal dout_rx_arm_interface_internal2 				: STD_LOGIC_VECTOR(15 downto 0);
signal dout_rx_srio_interface_internal2 			: STD_LOGIC_VECTOR(15 downto 0);
signal reg_AD9680_config_rddata_internal2       	: std_logic_vector(15 downto 0);
signal reg_SPI_AD9680_config_state_internal2    	: std_logic_vector(15 downto 0);
signal reg_AD9680_2_config_rddata_internal2       	: std_logic_vector(15 downto 0);
signal reg_SPI_AD9680_2_config_state_internal2    	: std_logic_vector(15 downto 0);
signal data_valid_internal2							: std_logic;
signal data_valid_k7_internal2                      : std_logic;
signal jesd_ByteIsAligned_internal2    	            : std_logic_vector(7 downto 0);
signal reg_AD9739_config_rddata_internal2       	: std_logic_vector(15 downto 0);
signal reg_SPI_AD9739_config_state_internal2     	: std_logic_vector(15 downto 0);
signal reg_tx_interface_buffer_num_0_internal2 		: STD_LOGIC_VECTOR(11 downto 0);
signal reg_tx_interface_buffer_num_1_internal2 		: STD_LOGIC_VECTOR(11 downto 0);
signal reg_tx_interface_buffer_num_2_internal2 		: STD_LOGIC_VECTOR(11 downto 0);
signal reg_monitor_internal2 						: STD_LOGIC_VECTOR(15 downto 0);
signal counter_2M_internal2							: std_logic_vector(15 downto 0);
signal counter_500k_internal2						: std_logic_vector(15 downto 0);			
signal num_buffer_rx_arm_interface_internal2 		: STD_LOGIC_VECTOR (3 downto 0);
signal num_buffer_rx_srio_interface_internal2 		: STD_LOGIC_VECTOR(3 downto 0);
signal channel_load_internal2 						: std_logic_vector(15 downto 0);
signal MEASURED_TEMP_ZYNQ_internal2                 : std_logic_vector(11 downto 0);
signal MEASURED_TEMP_K7_internal2                   : std_logic_vector(11 downto 0);
--signal clk_lock_state_internal2                     : std_logic_vector(7 downto 0);
signal Version_K7_internal2                         : std_logic_vector(2 downto 0);
signal DONE_CONFIG_FPGA2_internal2                  : std_logic;
signal bpsk_tx_busy_internal2                       : std_logic;

signal send_timestamp_2_internal2                   : std_logic_vector(15 downto 0);
signal send_timestamp_1_internal2                   : std_logic_vector(15 downto 0);
signal send_timestamp_0_internal2                   : std_logic_vector(15 downto 0);
signal reg_phy_time_internal2                       : std_logic_vector(47 downto 0);
signal send_timestamp_cor_2_internal2                 : std_logic_vector(15 downto 0);
signal send_timestamp_cor_1_internal2                 : std_logic_vector(15 downto 0);
signal send_timestamp_cor_0_internal2                 : std_logic_vector(15 downto 0);
signal flag_send_timestamp_cor_internal2                  : std_logic;


signal falg_rx_resp_internal2                       : std_logic;
signal rx_resp_data_internal2                       : STD_LOGIC_vector(15 downto 0);

signal falg_rd_respdata_complete_internal                    : std_logic;
signal falg_rd_fftdata_complete_internal                    : std_logic;


signal times_timestamp_cor1 :  STD_LOGIC_VECTOR (15 downto 0);
signal times_timestamp_cor2 :  STD_LOGIC_VECTOR (15 downto 0);

signal ps_oen  : std_logic;
signal ps_cen  : std_logic;
signal ps_addr : std_logic_vector(11 downto 0);

----------TDMA-----------
signal state_timeslot_adj1 :  STD_LOGIC;
signal state_timeslot_adj2 :  STD_LOGIC;

----  fft  ----
signal fft_data1 : std_logic_vector(15 downto 0);
signal fft_data2 : std_logic_vector(15 downto 0);

begin

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ps_oen  <= '1';
		ps_cen  <= '1';
		ps_addr <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		ps_oen  <= ps_oen_128M;
		ps_cen  <= ps_cen_128M ;
		ps_addr <= ps_addr_128M;
	end if;
end process;


process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		dout_rx_arm_interface_internal1 		<= (others => '0');
		dout_rx_srio_interface_internal1 		<= (others => '0');
		reg_AD9680_config_rddata_internal1      <= (others => '0');
		reg_SPI_AD9680_config_state_internal1   <= (others => '0');
		reg_AD9680_2_config_rddata_internal1    <= (others => '0');
		reg_SPI_AD9680_2_config_state_internal1 <= (others => '0');        
		data_valid_internal1					<= '0';
        data_valid_k7_internal1                 <= '0';
        jesd_ByteIsAligned_internal1            <= (others => '0');
		reg_AD9739_config_rddata_internal1      <= (others => '0');
		reg_SPI_AD9739_config_state_internal1   <= (others => '0');
		reg_tx_interface_buffer_num_0_internal1 	<= (others => '0');
		reg_tx_interface_buffer_num_1_internal1 	<= (others => '0');
		reg_tx_interface_buffer_num_2_internal1 	<= (others => '0');
		reg_monitor_internal1 					<= (others => '0');
		counter_2M_internal1					<= (others => '0');
		counter_500k_internal1					<= (others => '0');
		num_buffer_rx_arm_interface_internal1 	<= (others => '0');
		num_buffer_rx_srio_interface_internal1 	<= (others => '0');
		channel_load_internal1 					<= (others => '0');
		send_timestamp_2_internal1              <= (others => '0');
        send_timestamp_1_internal1              <= (others => '0');
        send_timestamp_0_internal1              <= (others => '0');
        send_timestamp_cor_2_internal1            <= (others => '0');
        send_timestamp_cor_1_internal1            <= (others => '0');
        send_timestamp_cor_0_internal1            <= (others => '0');
        flag_send_timestamp_cor_internal1             <= '0';
		reg_phy_time_internal1                  <= (others => '0');
		MEASURED_TEMP_ZYNQ_internal1            <= (others => '0');
		MEASURED_TEMP_K7_internal1              <= (others => '0');
--		clk_lock_state_internal1                <= (others => '0');
		Version_K7_internal1                    <= (others => '0');
		DONE_CONFIG_FPGA2_internal1             <= '0';
		bpsk_tx_busy_internal1                  <= '0';
		falg_rx_resp_internal1                  <= '0';
		rx_resp_data_internal1                  <= (others => '0');
		times_timestamp_cor1                    <=  (others => '0');
		state_timeslot_adj1                     <= '0';
		fft_data1                               <= (others => '0');
		
	elsif clk_128M' event and clk_128M = '1' then
		dout_rx_arm_interface_internal1 		<= dout_rx_arm_interface;
		dout_rx_srio_interface_internal1 		<= dout_rx_srio_interface;
--		reg_AD9680_config_rddata_internal1      <= reg_AD9680_config_rddata;
--		reg_SPI_AD9680_config_state_internal1   <= reg_SPI_AD9680_config_state;
--		reg_AD9680_2_config_rddata_internal1    <= reg_AD9680_2_config_rddata;
--		reg_SPI_AD9680_2_config_state_internal1 <= reg_SPI_AD9680_2_config_state;
--		data_valid_internal1					<= data_valid;
--        jesd_ByteIsAligned_internal1            <= jesd_ByteIsAligned;
--        data_valid_k7_internal1					<= data_valid_k7;
--		reg_AD9739_config_rddata_internal1      <= reg_AD9739_config_rddata;
--		reg_SPI_AD9739_config_state_internal1   <= reg_SPI_AD9739_config_state;
		reg_tx_interface_buffer_num_0_internal1 	<= reg_tx_interface_buffer_num_0;
		reg_tx_interface_buffer_num_1_internal1 	<= reg_tx_interface_buffer_num_1;
		reg_tx_interface_buffer_num_2_internal1 	<= reg_tx_interface_buffer_num_2;
		reg_monitor_internal1 					<= reg_monitor;
		counter_2M_internal1					<= counter_2M;
		counter_500k_internal1					<= counter_500k;
		num_buffer_rx_arm_interface_internal1 	<= num_buffer_rx_arm_interface;
		num_buffer_rx_srio_interface_internal1 	<= num_buffer_rx_srio_interface;
		channel_load_internal1 					<= channel_load;
		send_timestamp_2_internal1              <= send_timestamp_2;
        send_timestamp_1_internal1              <= send_timestamp_1;
        send_timestamp_0_internal1              <= send_timestamp_0;
        send_timestamp_cor_2_internal1            <= send_timestamp_cor_2;
        send_timestamp_cor_1_internal1            <= send_timestamp_cor_1;
        send_timestamp_cor_0_internal1            <= send_timestamp_cor_0;
        flag_send_timestamp_cor_internal1             <= flag_send_timestamp_cor;
		reg_phy_time_internal1                  <= reg_phy_time;    
		MEASURED_TEMP_ZYNQ_internal1            <= MEASURED_TEMP_ZYNQ;
--		MEASURED_TEMP_K7_internal1(11 downto 4) <= MEASURED_TEMP_K7;
		MEASURED_TEMP_K7_internal1(3 downto 0)  <= (others => '0');
--		clk_lock_state_internal1                <= clk_lock_state;
--		Version_K7_internal1                    <= Version_K7;
--		DONE_CONFIG_FPGA2_internal1             <= DONE_CONFIG_FPGA2;
		falg_rx_resp_internal1                  <= falg_rx_resp;
		rx_resp_data_internal1                  <= rx_resp_data;
		times_timestamp_cor1                    <= times_timestamp_cor;
		state_timeslot_adj1                     <= state_timeslot_adj;
		fft_data1                               <= fft_data;
		bpsk_tx_busy_internal1                  <= bpsk_tx_busy;
       
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		dout_rx_arm_interface_internal2 		<= (others => '0');
		dout_rx_srio_interface_internal2 		<= (others => '0');
		reg_AD9680_config_rddata_internal2      <= (others => '0');
		reg_SPI_AD9680_config_state_internal2   <= (others => '0');
		data_valid_internal2					<= '0';
        jesd_ByteIsAligned_internal2            <= (others => '0');
		data_valid_k7_internal2                 <= '0';
		reg_AD9680_2_config_rddata_internal2      <= (others => '0');
		reg_SPI_AD9680_2_config_state_internal2   <= (others => '0');
		reg_AD9739_config_rddata_internal2      <= (others => '0');
		reg_SPI_AD9739_config_state_internal2   <= (others => '0');
		reg_tx_interface_buffer_num_0_internal2 	<= (others => '0');
		reg_tx_interface_buffer_num_1_internal2 	<= (others => '0');
		reg_tx_interface_buffer_num_2_internal2 	<= (others => '0');
		reg_monitor_internal2 					<= (others => '0');
		counter_2M_internal2					<= (others => '0');
		counter_500k_internal2					<= (others => '0');
		num_buffer_rx_arm_interface_internal2 	<= (others => '0');
		num_buffer_rx_srio_interface_internal2 	<= (others => '0');
		channel_load_internal2 					<= (others => '0');
		send_timestamp_2_internal2              <= (others => '0');
        send_timestamp_1_internal2              <= (others => '0');
        send_timestamp_0_internal2              <= (others => '0');
        send_timestamp_cor_2_internal2            <= (others => '0');
        send_timestamp_cor_1_internal2            <= (others => '0');
        send_timestamp_cor_0_internal2            <= (others => '0');
        flag_send_timestamp_cor_internal2             <=  '0';
		reg_phy_time_internal2                  <= (others => '0');
		MEASURED_TEMP_ZYNQ_internal2            <= (others => '0');
		MEASURED_TEMP_K7_internal2              <= (others => '0');
--		clk_lock_state_internal2                <= (others => '0');
		Version_K7_internal2                    <= (others => '0');
		DONE_CONFIG_FPGA2_internal2             <= '0';
		bpsk_tx_busy_internal2                  <= '0';
		falg_rx_resp_internal2                  <= '0';
		rx_resp_data_internal2                  <= (others => '0');
		times_timestamp_cor2 <=  (others => '0');
        state_timeslot_adj2                     <= '0';
		fft_data2                               <= (others => '0');
		
	elsif clk_128M' event and clk_128M = '1' then
		dout_rx_arm_interface_internal2 		<= dout_rx_arm_interface_internal1;
		dout_rx_srio_interface_internal2 		<= dout_rx_srio_interface_internal1;
		reg_AD9680_config_rddata_internal2     <= reg_AD9680_config_rddata_internal1;
		reg_SPI_AD9680_config_state_internal2   <= reg_SPI_AD9680_config_state_internal1;
		data_valid_internal2					<= data_valid_internal1;
        jesd_ByteIsAligned_internal2            <= jesd_ByteIsAligned_internal1;
		data_valid_k7_internal2                 <= data_valid_k7_internal1;
		reg_AD9680_2_config_rddata_internal2     <= reg_AD9680_2_config_rddata_internal1;
		reg_SPI_AD9680_2_config_state_internal2   <= reg_SPI_AD9680_2_config_state_internal1;
		reg_AD9739_config_rddata_internal2      <= reg_AD9739_config_rddata_internal1;
		reg_SPI_AD9739_config_state_internal2   <= reg_SPI_AD9739_config_state_internal1;
		reg_tx_interface_buffer_num_0_internal2 	<= reg_tx_interface_buffer_num_0_internal1;
		reg_tx_interface_buffer_num_1_internal2 	<= reg_tx_interface_buffer_num_1_internal1;
		reg_tx_interface_buffer_num_2_internal2 	<= reg_tx_interface_buffer_num_2_internal1;
		reg_monitor_internal2 					<= reg_monitor_internal1;
		counter_2M_internal2					<= counter_2M_internal1;
		counter_500k_internal2					<= counter_500k_internal1;
		num_buffer_rx_arm_interface_internal2 	<= num_buffer_rx_arm_interface_internal1;
		num_buffer_rx_srio_interface_internal2 	<= num_buffer_rx_srio_interface_internal1;
		channel_load_internal2 					<= channel_load_internal1;
		send_timestamp_2_internal2              <= send_timestamp_2_internal1;
        send_timestamp_1_internal2              <= send_timestamp_1_internal1;
        send_timestamp_0_internal2              <= send_timestamp_0_internal1;
        send_timestamp_cor_2_internal2            <= send_timestamp_cor_2_internal1;
        send_timestamp_cor_1_internal2            <= send_timestamp_cor_1_internal1;
        send_timestamp_cor_0_internal2            <= send_timestamp_cor_0_internal1;
        flag_send_timestamp_cor_internal2          <= flag_send_timestamp_cor_internal1 ;
		reg_phy_time_internal2                  <= reg_phy_time_internal1    ;
		MEASURED_TEMP_ZYNQ_internal2            <= MEASURED_TEMP_ZYNQ_internal1;
		MEASURED_TEMP_K7_internal2              <= MEASURED_TEMP_K7_internal1;
--		clk_lock_state_internal2                <= clk_lock_state_internal1;
		Version_K7_internal2                    <= Version_K7_internal1;
		DONE_CONFIG_FPGA2_internal2             <= DONE_CONFIG_FPGA2_internal1;
		falg_rx_resp_internal2                  <= falg_rx_resp_internal1;
		rx_resp_data_internal2                  <= rx_resp_data_internal1;
		times_timestamp_cor2 <=  times_timestamp_cor1;
        state_timeslot_adj2                     <= state_timeslot_adj1;
		fft_data2                               <= fft_data1;
		bpsk_tx_busy_internal2                  <= bpsk_tx_busy_internal1;
		
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset_128M = '0' then
		ps_din_128M <= (others => '0');
	elsif clk_128M'event and clk_128M = '1' then
		if ps_cen = '0' and ps_oen = '0' then
			if ps_addr = ADDR_VERSION then
				ps_din_128M <= x"1101";
            elsif ps_addr = ADDR_RELEASE then
					ps_din_128M <= release_FPGA;
			elsif ps_addr = ADDR_SPI_AD9739_CONFIG_STATE then
					ps_din_128M <= reg_SPI_AD9739_config_state_internal2;
			elsif ps_addr = ADDR_REG_AD9739_CONFIG_RDDATA then
					ps_din_128M <= reg_AD9739_config_rddata_internal2;					
			elsif ps_addr = ADDR_SPI_AD9680_CONFIG_STATE then
					ps_din_128M <= reg_SPI_AD9680_config_state_internal2;
			elsif ps_addr = ADDR_REG_AD9680_CONFIG_RDDATA then
					ps_din_128M <= reg_AD9680_config_rddata_internal2;
			elsif ps_addr = ADDR_REG_data_valid then
					ps_din_128M(8) <=  data_valid_internal2;
                    ps_din_128M(7 downto 0) <=  jesd_ByteIsAligned_internal2;
			elsif ps_addr = ADDR_REG_data_valid_k7 then
					ps_din_128M(8) <=  data_valid_k7_internal2;
                    ps_din_128M(7 downto 0) <=  (others => '0');
			elsif ps_addr = ADDR_SPI_AD9680_2_CONFIG_STATE then
					ps_din_128M <= reg_SPI_AD9680_2_config_state_internal2;
			elsif ps_addr = ADDR_REG_AD9680_2_CONFIG_RDDATA then
					ps_din_128M <= reg_AD9680_2_config_rddata_internal2;
			elsif ps_addr = ADDR_CHANNEL_STATE then
					ps_din_128M <= channel_load_internal2;
--		    elsif ps_addr = ADDR_SPI_AD9520_CONFIG_STATE then
--					ps_din <= reg_SPI_AD9520_config_state;
--			elsif ps_addr = ADDR_REG_AD9520_CONFIG_RDDATA then
--					ps_din(0) <= reg_AD9520_config_rddata;
--                    ps_din(15 downto 1) <= (others => '0');
			elsif ps_addr = ADDR_TX_BUFFER_NUM_0 then			
					ps_din_128M(11 downto 0) <= not reg_tx_interface_buffer_num_0_internal2;
					ps_din_128M(15 downto 12) <= "0000";
			elsif ps_addr = ADDR_TX_BUFFER_NUM_1 then			
					ps_din_128M(11 downto 0) <= not reg_tx_interface_buffer_num_1_internal2;
					ps_din_128M(15 downto 12) <= "0000";
			elsif ps_addr = ADDR_TX_BUFFER_NUM_2 then			
					ps_din_128M(11 downto 0) <= not reg_tx_interface_buffer_num_2_internal2;
					ps_din_128M(15 downto 12) <= "0000";
			elsif ps_addr = ADDR_REG_STATE then
					ps_din_128M <= reg_state;	
			elsif ps_addr = ADDR_REG_MONITOR then
					ps_din_128M <= reg_monitor_internal2;
			elsif ps_addr = ADDR_READ_RX_DATA then
					ps_din_128M <= dout_rx_arm_interface_internal2;
			elsif ps_addr = ADDR_RX_DATA_BUFFER_NUM then
					ps_din_128M(3 downto 0) <= num_buffer_rx_arm_interface_internal2;
			elsif ps_addr = ADDR_READ_RX_DATA_SRIO then
                    ps_din_128M <= dout_rx_srio_interface_internal2;
            elsif ps_addr = ADDR_RX_DATA_BUFFER_NUM_SRIO then
                    ps_din_128M(3 downto 0) <= num_buffer_rx_srio_interface_internal2;
					ps_din_128M(15 downto 4) <= (others => '0');	
            elsif	ps_addr = ADDR_num_500k then
					ps_din_128M <= counter_500k_internal2;			
            elsif	ps_addr = ADDR_num_2M then
					ps_din_128M <= counter_2M_internal2;	
			----  FPGA温度  ----
			elsif ps_addr = ADDR_MEASURED_TEMP_ZYNQ then
					ps_din_128M(11 downto 0) <= MEASURED_TEMP_ZYNQ_internal2;
			elsif ps_addr = ADDR_MEASURED_TEMP_K7 then
					ps_din_128M(11 downto 0) <= MEASURED_TEMP_K7_internal2;
--			elsif ps_addr = ADDR_clk_lock_state then
--					ps_din_128M(7 downto 0) <= clk_lock_state_internal2;
--					ps_din_128M(15 downto 8) <= (others => '0');
			elsif ps_addr = ADDR_Version_K7 then
					ps_din_128M(2 downto 0) <= Version_K7_internal2;
					ps_din_128M(15 downto 3) <= (others => '0');
			----  K7 FPGA加载完成标志  ----
			elsif  ps_addr = ADDR_DONE_CONFIG_FPGA2 then
					ps_din_128M(15 downto 1) <= (others => '0');
					ps_din_128M(0) <= DONE_CONFIG_FPGA2_internal2;
					
            ----  时间同步  ----        
            elsif	ps_addr = ADDR_send_timestamp_2 then
            		ps_din_128M <= send_timestamp_2_internal2;
            elsif	ps_addr = ADDR_send_timestamp_1 then
            		ps_din_128M <= send_timestamp_1_internal2;
            elsif	ps_addr = ADDR_send_timestamp_0 then
            		ps_din_128M <= send_timestamp_0_internal2;
            elsif	ps_addr = ADDR_send_timestamp_cor_2 then
            		ps_din_128M <= send_timestamp_cor_2_internal2;
            elsif	ps_addr = ADDR_send_timestamp_cor_1 then
            		ps_din_128M <= send_timestamp_cor_1_internal2;
            elsif	ps_addr = ADDR_send_timestamp_cor_0 then
            		ps_din_128M <= send_timestamp_cor_0_internal2;
            elsif	ps_addr = ADDR_flag_send_timestamp_cor then
            		ps_din_128M(0) <= flag_send_timestamp_cor_internal2;
            		ps_din_128M(15 downto 1) <= (others => '0');
            elsif	ps_addr = ADDR_tx_time_renew then
                    ps_din_128M(0) <= flag_tx_time_renew;   
                    ps_din_128M(15 downto 1) <= (others => '0');
					
            elsif	ps_addr = ADDR_reg_phy_time_2 then
            		ps_din_128M <= reg_phy_time_internal2(47 downto 32);
            elsif	ps_addr = ADDR_reg_phy_time_1 then
            		ps_din_128M <= reg_phy_time_internal2(31 downto 16);
            elsif	ps_addr = ADDR_reg_phy_time_0 then
            		ps_din_128M <= reg_phy_time_internal2(15 downto 0);
           -----------TDMA------------- 		
            elsif ps_addr = ADDR_state_timeslot_adj then
					ps_din_128M(0) <= state_timeslot_adj2;
					ps_din_128M(15 downto 1) <= (others => '0');
					
            -----   K7读取寄存器  ---					
			elsif	ps_addr = ADDR_falg_rx_resp then
            		ps_din_128M(0) <= falg_rx_resp_internal2;		
			elsif	ps_addr = ADDR_reg_resp_data then
            		ps_din_128M <= rx_resp_data_internal2;		
            elsif ps_addr = ADDR_times_timestamp_cor then
			        ps_din_128M <= times_timestamp_cor2;
			elsif ps_addr = ADDR_fft_data then
			        ps_din_128M <= fft_data2;
			----    BPSK 发射状态(0x71A, 只读, bit0)  ----
			elsif ps_addr = ADDR_TX_BPSK_BUSY then
					ps_din_128M(0) <= bpsk_tx_busy_internal2;
					ps_din_128M(15 downto 1) <= (others => '0');
			else
					ps_din_128M <= x"AA55";
			end if;
		else
			ps_din_128M <= (others => 'Z');
		end if;
	end if;
end process;

process(reset_128M,clk_128M)
begin
	if reset = '0' then
		flag_times_timestamp_cor_read_internal <= '0';
	elsif clk'event and clk = '1' then
		if ps_cen = '0' and ps_oen = '0' then
			if ps_addr = ADDR_times_timestamp_cor then
				flag_times_timestamp_cor_read_internal <= '1';
			else
				flag_times_timestamp_cor_read_internal <= '0';
			end if;
		else
			flag_times_timestamp_cor_read_internal <= '0';
		end if;
	end if;
end process;
U0 : falling_edge_detector Port map ( reset => reset,
												  clk => clk,
												  din => flag_times_timestamp_cor_read_internal,
												  dout => flag_times_timestamp_cor_read );	

process(reset_128M,clk_128M)
begin
	if reset = '0' then
		flag_monitor_cancel_internal <= '0';
	elsif clk'event and clk = '1' then
		if ps_cen = '0' and ps_oen = '0' then
			if ps_addr = ADDR_REG_MONITOR then
				flag_monitor_cancel_internal <= '1';
			else
				flag_monitor_cancel_internal <= '0';
			end if;
		else
			flag_monitor_cancel_internal <= '0';
		end if;
	end if;
end process;

U1 : falling_edge_detector Port map ( reset => reset,
												  clk => clk,
												  din => flag_monitor_cancel_internal,
												  dout => flag_monitor_cancel );	
												  							  
process(reset, clk)
begin
	if reset = '0' then
		flag_rd_arm_onetime_internal <= '0';
	elsif clk' event and clk = '1' then
		if ps_cen = '0' and ps_oen = '0' then
			if ps_addr = ADDR_READ_RX_DATA then
				flag_rd_arm_onetime_internal <= '1';
			else
				flag_rd_arm_onetime_internal <= '0';
			end if;
		else
			flag_rd_arm_onetime_internal <= '0';
		end if;	
	end if;
end process;

U2 : falling_edge_detector_clk PORT MAP ( reset => reset_128M,
									  clk => clk_128M,
									  din => flag_rd_arm_onetime_internal,
									  dout => flag_rd_arm_onetime );

----k7 recv_data
process(reset, clk)
begin
	if reset = '0' then
		flag_rd_srio_onetime_internal <= '0';
	elsif clk' event and clk = '1' then
		if ps_cen = '0' and ps_oen = '0' then
			if ps_addr = ADDR_READ_RX_DATA_SRIO then
				flag_rd_srio_onetime_internal <= '1';
			else
				flag_rd_srio_onetime_internal <= '0';
			end if;
		else
			flag_rd_srio_onetime_internal <= '0';
		end if;	
	end if;
end process;

U3 : falling_edge_detector_clk PORT MAP ( reset => reset_128M,
									  clk => clk_128M,
									  din => flag_rd_srio_onetime_internal,
									  dout => flag_rd_srio_onetime );
									  
process(reset_128M, clk_128M)
begin
	if reset_128M = '0' then
		release_FPGA <= x"0000";
	elsif clk_128M' event and clk_128M = '1' then
		release_FPGA <= x"8888";	
	end if;
end process;

----    时间同步相关    ----
process(reset, clk)
begin
	if reset = '0' then
		flag_tx_timestamp_read_internal <= '0';
	elsif clk' event and clk = '1' then
		if ps_cen = '0' and ps_oen = '0' then
			if ps_addr = ADDR_send_timestamp_0 then
				flag_tx_timestamp_read_internal <= '1';
			else
				flag_tx_timestamp_read_internal <= '0';
			end if;
		else
			flag_tx_timestamp_read_internal <= '0';
		end if;	
	end if;
end process;

U4 : falling_edge_detector_clk PORT MAP ( reset => reset_128M,
									  clk => clk_128M,
									  din => flag_tx_timestamp_read_internal,
									  dout => flag_tx_timestamp_read );
								

----    K7读取寄存器    ----
process(reset, clk)
begin
	if reset = '0' then
		falg_rd_respdata_complete_internal <= '0';
	elsif clk' event and clk = '1' then
		if ps_cen = '0' and ps_oen = '0' then
			if ps_addr = ADDR_reg_resp_data then
				falg_rd_respdata_complete_internal <= '1';
			else
				falg_rd_respdata_complete_internal <= '0';
			end if;
		else
			falg_rd_respdata_complete_internal <= '0';
		end if;	
	end if;
end process;

U5 : falling_edge_detector_clk PORT MAP ( reset => reset_128M,
									  clk => clk_128M,
									  din => falg_rd_respdata_complete_internal,
									  dout => falg_rd_respdata_complete);


----  fft  ----
process(reset, clk)
begin
	if reset = '0' then
		falg_rd_fftdata_complete_internal <= '0';
	elsif clk' event and clk = '1' then
		if ps_cen = '0' and ps_oen = '0' then
			if ps_addr = ADDR_fft_data then
				falg_rd_fftdata_complete_internal <= '1';
			else
				falg_rd_fftdata_complete_internal <= '0';
			end if;
		else
			falg_rd_fftdata_complete_internal <= '0';
		end if;	
	end if;
end process;

U6 : falling_edge_detector_clk PORT MAP ( reset => reset_128M,
									  clk => clk_128M,
									  din => falg_rd_fftdata_complete_internal,
									  dout => flag_fft_bram_addrb);									


U_ila_ps_read_128M : ila_ps_read_128M
PORT MAP (
	clk => clk_128M,
	probe0(0) => ps_oen , 
	probe1(0) => ps_cen ,
	probe2 => ps_addr
);           
								
end Behavioral;


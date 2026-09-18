 ----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2026/01/14 22:02:45
-- Design Name: 
-- Module Name: data_pcie - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_pcie is
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
end data_pcie;

architecture Behavioral of data_pcie is

signal data_out_0_I: std_logic_vector(16 downto 0);
signal data_out_1_I: std_logic_vector(16 downto 0);
signal data_out_2_I: std_logic_vector(16 downto 0);
signal data_out_3_I: std_logic_vector(16 downto 0);
signal data_out_4_I: std_logic_vector(16 downto 0);
signal data_out_5_I: std_logic_vector(16 downto 0);
signal data_out_6_I: std_logic_vector(16 downto 0);
signal data_out_7_I: std_logic_vector(16 downto 0);
signal data_out_0_Q: std_logic_vector(16 downto 0);
signal data_out_1_Q: std_logic_vector(16 downto 0);
signal data_out_2_Q: std_logic_vector(16 downto 0);
signal data_out_3_Q: std_logic_vector(16 downto 0);
signal data_out_4_Q: std_logic_vector(16 downto 0);
signal data_out_5_Q: std_logic_vector(16 downto 0);
signal data_out_6_Q: std_logic_vector(16 downto 0);
signal data_out_7_Q: std_logic_vector(16 downto 0);

signal data_dds_out_0 : std_logic_vector(31 downto 0);
signal data_dds_out_1 : std_logic_vector(31 downto 0);
signal data_dds_out_2 : std_logic_vector(31 downto 0);
signal data_dds_out_3 : std_logic_vector(31 downto 0);
signal data_dds_out_4 : std_logic_vector(31 downto 0);
signal data_dds_out_5 : std_logic_vector(31 downto 0);
signal data_dds_out_6 : std_logic_vector(31 downto 0);
signal data_dds_out_7 : std_logic_vector(31 downto 0);

signal data_in_0_delay : std_logic_vector(31 downto 0);
signal data_in_1_delay : std_logic_vector(31 downto 0);
signal data_in_2_delay : std_logic_vector(31 downto 0);
signal data_in_3_delay : std_logic_vector(31 downto 0);
signal data_in_4_delay : std_logic_vector(31 downto 0);
signal data_in_5_delay : std_logic_vector(31 downto 0);
signal data_in_6_delay : std_logic_vector(31 downto 0);
signal data_in_7_delay : std_logic_vector(31 downto 0);

signal s_axis_phase_tdata_0 : std_logic_vector(63 downto 0);
signal s_axis_phase_tdata_1 : std_logic_vector(63 downto 0);
signal s_axis_phase_tdata_2 : std_logic_vector(63 downto 0);
signal s_axis_phase_tdata_3 : std_logic_vector(63 downto 0);
signal s_axis_phase_tdata_4 : std_logic_vector(63 downto 0);
signal s_axis_phase_tdata_5 : std_logic_vector(63 downto 0);
signal s_axis_phase_tdata_6 : std_logic_vector(63 downto 0);
signal s_axis_phase_tdata_7 : std_logic_vector(63 downto 0);

signal m_axis_data_tdata_0 : std_logic_vector(31 downto 0);
signal m_axis_data_tdata_1 : std_logic_vector(31 downto 0);
signal m_axis_data_tdata_2 : std_logic_vector(31 downto 0);
signal m_axis_data_tdata_3 : std_logic_vector(31 downto 0);
signal m_axis_data_tdata_4 : std_logic_vector(31 downto 0);
signal m_axis_data_tdata_5 : std_logic_vector(31 downto 0);
signal m_axis_data_tdata_6 : std_logic_vector(31 downto 0);
signal m_axis_data_tdata_7 : std_logic_vector(31 downto 0);

COMPONENT carrier_frequency_dds_data
    PORT ( aclk : IN STD_LOGIC;
           aresetn : IN STD_LOGIC;
           s_axis_phase_tvalid : IN STD_LOGIC;
           s_axis_phase_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
           m_axis_data_tvalid : OUT STD_LOGIC;
           m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
END COMPONENT;

COMPONENT carrier_frequency_converter_complex_multiplier_data 
    PORT ( aclk : IN STD_LOGIC;
           s_axis_a_tvalid : IN STD_LOGIC;
           s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           s_axis_b_tvalid : IN STD_LOGIC;
           s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           m_axis_dout_tvalid : OUT STD_LOGIC;
           m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(79 DOWNTO 0) );
END COMPONENT;

signal data_out_0_complex_multiplier : std_logic_vector(79 downto 0);
signal data_out_1_complex_multiplier : std_logic_vector(79 downto 0);
signal data_out_2_complex_multiplier : std_logic_vector(79 downto 0);
signal data_out_3_complex_multiplier : std_logic_vector(79 downto 0);
signal data_out_4_complex_multiplier : std_logic_vector(79 downto 0);
signal data_out_5_complex_multiplier : std_logic_vector(79 downto 0);
signal data_out_6_complex_multiplier : std_logic_vector(79 downto 0);
signal data_out_7_complex_multiplier : std_logic_vector(79 downto 0);

COMPONENT FIR_decimation_D4A
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(39 DOWNTO 0) );   -- 字节对齐: 输出宽度34 -> 端口40, 有效数据(33 downto 0)
END COMPONENT;
signal dout_I_internal_D4A : std_logic_vector(39 downto 0);
signal dout_Q_internal_D4A : std_logic_vector(39 downto 0);
signal dout_I_internal_D4A_delay : std_logic_vector(16 downto 0);
signal dout_Q_internal_D4A_delay : std_logic_vector(16 downto 0);
signal rdy_FIR_decimation_D4A : std_logic;
signal rdy_FIR_decimation_D4A_delay : std_logic;


COMPONENT FIR_decimation_D8
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)       -- 字节对齐: 输出宽度36 -> 端口40, 有效数据(35 downto 0)
  );
END COMPONENT;
signal data_dds_out_I : std_logic_vector(127 downto 0);
signal data_dds_out_Q : std_logic_vector(127 downto 0);
signal data_200M_I    : std_logic_vector(39 downto 0);
signal data_200M_Q    : std_logic_vector(39 downto 0);
signal data_200M_I_delay    : std_logic_vector(16 downto 0);
signal data_200M_Q_delay    : std_logic_vector(16 downto 0);

signal data_out_internal : std_logic_vector(31 downto 0);   -- data_out 是 out 端口，VHDL-93 不能读，用这个中转给 ila

COMPONENT ila_data_dds_downsample
PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC; 
	probe1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe5 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe6 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe7 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe8 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe9 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
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
	probe32 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe33 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe34 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe35 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe36 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe37 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe38 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe39 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe40 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe41 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	probe42 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe43 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe44 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe45 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe46 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe47 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe48 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe49 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe50 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe51 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe52 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe53 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe54 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe55 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe56 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe57 : IN STD_LOGIC_VECTOR(32 DOWNTO 0); 
	probe58 : IN STD_LOGIC_VECTOR(39 DOWNTO 0); 
	probe59 : IN STD_LOGIC_VECTOR(39 DOWNTO 0); 
	probe60 : IN STD_LOGIC_VECTOR(39 DOWNTO 0); 
	probe61 : IN STD_LOGIC_VECTOR(39 DOWNTO 0); 
	probe62 : IN STD_LOGIC;
	probe63 : IN STD_LOGIC
);
END COMPONENT  ;

--COMPONENT ila_data_dds_out
--PORT (
--	clk : IN STD_LOGIC;
--	probe0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
--	probe1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
--);
--END COMPONENT  ;

--- FIR 链路观察 ila：看 D8(36bit) / D4A(34bit) 全精度输出里信号落在哪几位，用来核对截位位置 -----
--- 只做调试用；不需要时把这段 component、下面的 U24 例化和 data_out_internal 一起删掉即可
COMPONENT ila_data_pcie_fir
PORT (
    clk : IN STD_LOGIC;
    probe0  : IN STD_LOGIC_VECTOR(35 DOWNTO 0);   -- data_200M_I(35:0)           D8 I 有效数据 36bit (端口40bit)
    probe1  : IN STD_LOGIC_VECTOR(35 DOWNTO 0);   -- data_200M_Q(35:0)           D8 Q 有效数据 36bit (端口40bit)
    probe2  : IN STD_LOGIC_VECTOR(16 DOWNTO 0);   -- data_200M_I_delay           D8 截位后 (25:9)+1
    probe3  : IN STD_LOGIC_VECTOR(16 DOWNTO 0);   -- data_200M_Q_delay           D8 截位后 (25:9)+1
    probe4  : IN STD_LOGIC_VECTOR(33 DOWNTO 0);   -- dout_I_internal_D4A(33:0)   D4A I 有效数据 34bit (端口40bit)
    probe5  : IN STD_LOGIC_VECTOR(33 DOWNTO 0);   -- dout_Q_internal_D4A(33:0)   D4A Q 有效数据 34bit (端口40bit)
    probe6  : IN STD_LOGIC_VECTOR(16 DOWNTO 0);   -- dout_I_internal_D4A_delay   D4A 截位后 (26:10)+1
    probe7  : IN STD_LOGIC_VECTOR(16 DOWNTO 0);   -- dout_Q_internal_D4A_delay   D4A 截位后 (26:10)+1
    probe8  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);   -- data_out_internal           最终输出 (Q & I)
    probe9  : IN STD_LOGIC;                       -- rdy_FIR_decimation_D4A
    probe10 : IN STD_LOGIC                        -- rdy_FIR_decimation_D4A_delay (= data_out_valid 的前一拍)
);
END COMPONENT;

begin

s_axis_phase_tdata_0 <= phase_POFF_0&phase_PINC;
s_axis_phase_tdata_1 <= phase_POFF_1&phase_PINC;
s_axis_phase_tdata_2 <= phase_POFF_2&phase_PINC;
s_axis_phase_tdata_3 <= phase_POFF_3&phase_PINC;
s_axis_phase_tdata_4 <= phase_POFF_4&phase_PINC;
s_axis_phase_tdata_5 <= phase_POFF_5&phase_PINC;
s_axis_phase_tdata_6 <= phase_POFF_6&phase_PINC;
s_axis_phase_tdata_7 <= phase_POFF_7&phase_PINC;

---- 输入数据锁存一次，延迟一个时钟周期 -----
process(reset,clk)
begin
    if reset = '0' then
        data_in_0_delay <= (others => '0');
        data_in_1_delay <= (others => '0');
        data_in_2_delay <= (others => '0');
        data_in_3_delay <= (others => '0');
        data_in_4_delay <= (others => '0');
        data_in_5_delay <= (others => '0');
        data_in_6_delay <= (others => '0');
        data_in_7_delay <= (others => '0');
    elsif clk'event and clk = '1' then
        data_in_0_delay <=  data_in_0;
        data_in_1_delay <=  data_in_1;
        data_in_2_delay <=  data_in_2;
        data_in_3_delay <=  data_in_3;
        data_in_4_delay <=  data_in_4;
        data_in_5_delay <=  data_in_5;
        data_in_6_delay <=  data_in_6;
        data_in_7_delay <=  data_in_7;
    end if;
end process;

U0 : carrier_frequency_dds_data port map ( aclk => clk,
                                      aresetn => reset_DDS,
                                      s_axis_phase_tvalid => '1',
                                      s_axis_phase_tdata => s_axis_phase_tdata_0,
                                      m_axis_data_tvalid => open,
                                      m_axis_data_tdata => m_axis_data_tdata_0 );
                                      
U1 : carrier_frequency_dds_data port map ( aclk => clk,
                                      aresetn => reset_DDS,
                                      s_axis_phase_tvalid => '1',
                                      s_axis_phase_tdata => s_axis_phase_tdata_1,
                                      m_axis_data_tvalid => open,
                                      m_axis_data_tdata => m_axis_data_tdata_1 );
                                      
U2 : carrier_frequency_dds_data port map ( aclk => clk,
                                      aresetn => reset_DDS,
                                      s_axis_phase_tvalid => '1',
                                      s_axis_phase_tdata => s_axis_phase_tdata_2,
                                      m_axis_data_tvalid => open,
                                      m_axis_data_tdata => m_axis_data_tdata_2 );        
                                      
U3 : carrier_frequency_dds_data port map ( aclk => clk,
                                      aresetn => reset_DDS,
                                      s_axis_phase_tvalid => '1',
                                      s_axis_phase_tdata => s_axis_phase_tdata_3,
                                      m_axis_data_tvalid => open,
                                      m_axis_data_tdata => m_axis_data_tdata_3 );
                                      
U4 : carrier_frequency_dds_data port map ( aclk => clk,
                                      aresetn => reset_DDS,
                                      s_axis_phase_tvalid => '1',
                                      s_axis_phase_tdata => s_axis_phase_tdata_4,
                                      m_axis_data_tvalid => open,
                                      m_axis_data_tdata => m_axis_data_tdata_4 );
                                      
U5 : carrier_frequency_dds_data port map ( aclk => clk,
                                      aresetn => reset_DDS,
                                      s_axis_phase_tvalid => '1',
                                      s_axis_phase_tdata => s_axis_phase_tdata_5,
                                      m_axis_data_tvalid => open,
                                      m_axis_data_tdata => m_axis_data_tdata_5 );
                                      
U6 : carrier_frequency_dds_data port map ( aclk => clk,
                                      aresetn => reset_DDS,
                                      s_axis_phase_tvalid => '1',
                                      s_axis_phase_tdata => s_axis_phase_tdata_6,
                                      m_axis_data_tvalid => open,
                                      m_axis_data_tdata => m_axis_data_tdata_6 );        
                                      
U7 : carrier_frequency_dds_data port map ( aclk => clk,
                                      aresetn => reset_DDS,
                                      s_axis_phase_tvalid => '1',
                                      s_axis_phase_tdata => s_axis_phase_tdata_7,
                                      m_axis_data_tvalid => open,
                                      m_axis_data_tdata => m_axis_data_tdata_7 );    
                                      
U8 : carrier_frequency_converter_complex_multiplier_data port map ( aclk => clk,
                                                                s_axis_a_tvalid => '1',
                                                                s_axis_a_tdata => m_axis_data_tdata_0,
                                                                s_axis_b_tvalid => '1',
                                                                s_axis_b_tdata => data_in_0_delay,
                                                                m_axis_dout_tvalid => open,
                                                                m_axis_dout_tdata => data_out_0_complex_multiplier );    
                                                                
U9 : carrier_frequency_converter_complex_multiplier_data port map ( aclk => clk,
                                                                s_axis_a_tvalid => '1',
                                                                s_axis_a_tdata => m_axis_data_tdata_1,
                                                                s_axis_b_tvalid => '1',
                                                                s_axis_b_tdata => data_in_1_delay,
                                                                m_axis_dout_tvalid => open,
                                                                m_axis_dout_tdata => data_out_1_complex_multiplier );           
                                                                
U10 : carrier_frequency_converter_complex_multiplier_data port map ( aclk => clk,
                                                                s_axis_a_tvalid => '1',
                                                                s_axis_a_tdata => m_axis_data_tdata_2,
                                                                s_axis_b_tvalid => '1',
                                                                s_axis_b_tdata => data_in_2_delay,
                                                                m_axis_dout_tvalid => open,
                                                                m_axis_dout_tdata => data_out_2_complex_multiplier );   
                                                                
U11 : carrier_frequency_converter_complex_multiplier_data port map ( aclk => clk,
                                                                s_axis_a_tvalid => '1',
                                                                s_axis_a_tdata => m_axis_data_tdata_3,
                                                                s_axis_b_tvalid => '1',
                                                                s_axis_b_tdata => data_in_3_delay,
                                                                m_axis_dout_tvalid => open,
                                                                m_axis_dout_tdata => data_out_3_complex_multiplier );          
                                                                
U12 : carrier_frequency_converter_complex_multiplier_data port map ( aclk => clk,
                                                                s_axis_a_tvalid => '1',
                                                                s_axis_a_tdata => m_axis_data_tdata_4,
                                                                s_axis_b_tvalid => '1',
                                                                s_axis_b_tdata => data_in_4_delay,
                                                                m_axis_dout_tvalid => open,
                                                                m_axis_dout_tdata => data_out_4_complex_multiplier );    
                                                                
U13 : carrier_frequency_converter_complex_multiplier_data port map ( aclk => clk,
                                                                s_axis_a_tvalid => '1',
                                                                s_axis_a_tdata => m_axis_data_tdata_5,
                                                                s_axis_b_tvalid => '1',
                                                                s_axis_b_tdata => data_in_5_delay,
                                                                m_axis_dout_tvalid => open,
                                                                m_axis_dout_tdata => data_out_5_complex_multiplier );           
                                                                
U14 : carrier_frequency_converter_complex_multiplier_data port map ( aclk => clk,
                                                                s_axis_a_tvalid => '1',
                                                                s_axis_a_tdata => m_axis_data_tdata_6,
                                                                s_axis_b_tvalid => '1',
                                                                s_axis_b_tdata => data_in_6_delay,
                                                                m_axis_dout_tvalid => open,
                                                                m_axis_dout_tdata => data_out_6_complex_multiplier );   
                                                                
U15 : carrier_frequency_converter_complex_multiplier_data port map ( aclk => clk,
                                                                s_axis_a_tvalid => '1',
                                                                s_axis_a_tdata => m_axis_data_tdata_7,
                                                                s_axis_b_tvalid => '1',
                                                                s_axis_b_tdata => data_in_7_delay,
                                                                m_axis_dout_tvalid => open,
                                                                m_axis_dout_tdata => data_out_7_complex_multiplier );  

U16 : FIR_decimation_D8
  PORT MAP (
    aclk => clk,
    s_axis_data_tvalid => '1',
    s_axis_data_tready => open,
    s_axis_data_tdata => data_dds_out_I,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => data_200M_I
  );
  

  
U17 : FIR_decimation_D8
PORT MAP (
    aclk => clk,
    s_axis_data_tvalid => '1',
    s_axis_data_tready => open,
    s_axis_data_tdata => data_dds_out_Q,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => data_200M_Q
);
process(reset,clk)
begin
    if reset = '0' then
        data_200M_I_delay <= (others => '0');
    elsif clk'event and clk = '1' then
        data_200M_I_delay <= data_200M_I(25 downto 9) + 1;
    end if;
end process;

process(reset,clk)
begin
    if reset = '0' then
        data_200M_Q_delay <= (others => '0');
    elsif clk'event and clk = '1' then
        data_200M_Q_delay <= data_200M_Q(25 downto 9) + 1;
    end if;
end process;

                                                                
U18 : FIR_decimation_D4A port map ( aclk => clk,
                                  s_axis_data_tvalid => '1',
                                  s_axis_data_tready => open,
                                  s_axis_data_tdata => data_200M_I_delay(16 downto 1),
                                  m_axis_data_tvalid => rdy_FIR_decimation_D4A,
                                  m_axis_data_tdata => dout_I_internal_D4A );
                                  
U19 : FIR_decimation_D4A port map ( aclk => clk,
                                  s_axis_data_tvalid => '1',
                                  s_axis_data_tready => open,
                                  s_axis_data_tdata => data_200M_Q_delay(16 downto 1),
                                  m_axis_data_tvalid => open,
                                  m_axis_data_tdata => dout_Q_internal_D4A );   
                                  
process(reset,clk)
begin
    if reset = '0' then
        dout_I_internal_D4A_delay <= (others => '0');
    elsif clk'event and clk = '1' then
        dout_I_internal_D4A_delay <= dout_I_internal_D4A(26 downto 10) + 1;
    end if;
end process;

process(reset,clk)
begin
    if reset = '0' then
        dout_Q_internal_D4A_delay <= (others => '0');
    elsif clk'event and clk = '1' then
        dout_Q_internal_D4A_delay <= dout_Q_internal_D4A(26 downto 10) + 1;
    end if;
end process;  

process(reset,clk)
begin
    if reset = '0' then
        rdy_FIR_decimation_D4A_delay <= '0';
    elsif clk'event and clk = '1' then
        rdy_FIR_decimation_D4A_delay <= rdy_FIR_decimation_D4A;
    end if;
end process;  

--U22 : ila_data_dds_downsample
--port map(
--    clk => clk                                                                      ,
--    probe0      =>      reset_DDS                                                   ,
--    probe1      =>      phase_PINC                                                  ,
--    probe2      =>      phase_POFF_0                                                ,
--    probe3      =>      phase_POFF_1                                                ,
--    probe4      =>      phase_POFF_2                                                ,
--    probe5      =>      phase_POFF_3                                                ,
--    probe6      =>      phase_POFF_4                                                ,
--    probe7      =>      phase_POFF_5                                                ,
--    probe8      =>      phase_POFF_6                                                ,
--    probe9      =>      phase_POFF_7                                                ,
--    probe10     =>      data_in_0(31 downto 16)                                     ,
--    probe11     =>      data_in_1(31 downto 16)                                     ,
--    probe12     =>      data_in_2(31 downto 16)                                     ,
--    probe13     =>      data_in_3(31 downto 16)                                     ,
--    probe14     =>      data_in_4(31 downto 16)                                     ,
--    probe15     =>      data_in_5(31 downto 16)                                     ,
--    probe16     =>      data_in_6(31 downto 16)                                     ,
--    probe17     =>      data_in_7(31 downto 16)                                     ,
--    probe18     =>      data_in_0(15 downto 0)                                      ,
--    probe19     =>      data_in_1(15 downto 0)                                      ,
--    probe20     =>      data_in_2(15 downto 0)                                      ,
--    probe21     =>      data_in_3(15 downto 0)                                      ,
--    probe22     =>      data_in_4(15 downto 0)                                      ,
--    probe23     =>      data_in_5(15 downto 0)                                      ,
--    probe24     =>      data_in_6(15 downto 0)                                      ,
--    probe25     =>      data_in_7(15 downto 0)                                      ,
--    probe26     =>      m_axis_data_tdata_0(31 downto 16)                           ,
--    probe27     =>      m_axis_data_tdata_1(31 downto 16)                           ,
--    probe28     =>      m_axis_data_tdata_2(31 downto 16)                           ,
--    probe29     =>      m_axis_data_tdata_3(31 downto 16)                           ,
--    probe30     =>      m_axis_data_tdata_4(31 downto 16)                           ,
--    probe31     =>      m_axis_data_tdata_5(31 downto 16)                           ,
--    probe32     =>      m_axis_data_tdata_6(31 downto 16)                           ,
--    probe33     =>      m_axis_data_tdata_7(31 downto 16)                           ,
--    probe34     =>      m_axis_data_tdata_0(15 downto 0)                            ,
--    probe35     =>      m_axis_data_tdata_1(15 downto 0)                            ,
--    probe36     =>      m_axis_data_tdata_2(15 downto 0)                            ,
--    probe37     =>      m_axis_data_tdata_3(15 downto 0)                            ,
--    probe38     =>      m_axis_data_tdata_4(15 downto 0)                            ,
--    probe39     =>      m_axis_data_tdata_5(15 downto 0)                            ,
--    probe40     =>      m_axis_data_tdata_6(15 downto 0)                            ,
--    probe41     =>      m_axis_data_tdata_7(15 downto 0)                            ,
--    probe42     =>      data_out_0_complex_multiplier(72 downto 40)                 ,
--    probe43     =>      data_out_1_complex_multiplier(72 downto 40)                 ,
--    probe44     =>      data_out_2_complex_multiplier(72 downto 40)                 ,
--    probe45     =>      data_out_3_complex_multiplier(72 downto 40)                 ,
--    probe46     =>      data_out_4_complex_multiplier(72 downto 40)                 ,
--    probe47     =>      data_out_5_complex_multiplier(72 downto 40)                 ,
--    probe48     =>      data_out_6_complex_multiplier(72 downto 40)                 ,
--    probe49     =>      data_out_7_complex_multiplier(72 downto 40)                 ,
--    probe50     =>      data_out_0_complex_multiplier(32 downto 0)                  ,
--    probe51     =>      data_out_1_complex_multiplier(32 downto 0)                  ,
--    probe52     =>      data_out_2_complex_multiplier(32 downto 0)                  ,
--    probe53     =>      data_out_3_complex_multiplier(32 downto 0)                  ,
--    probe54     =>      data_out_4_complex_multiplier(32 downto 0)                  ,
--    probe55     =>      data_out_5_complex_multiplier(32 downto 0)                  ,
--    probe56     =>      data_200M_I                                                 ,
--    probe57     =>      data_200M_Q                                                 ,
--    probe58     =>      dout_I_internal_delay                                       ,
--    probe59     =>      dout_Q_internal_delay                                       ,
--    probe60     =>      dout_I_internal                                             ,
--    probe61     =>      dout_Q_internal                                             ,
--    probe62     =>      '1'                                                         ,
--    probe63     =>      '1'
--);

--U23 : ila_data_dds_out                              
--PORT MAP(
--    clk => clk,
--    probe0 => m_axis_data_tdata_0(31 downto 16),
--    probe1 => m_axis_data_tdata_0(15 downto 0)
--);                                                  
                                                                
--- DATA0 ---                                                                
process(reset,clk)
begin
    if reset = '0' then
        data_out_0_I <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_0_I(16 downto 0) <= data_out_0_complex_multiplier(29 downto 13) + 1;
    end if;
end process;

process(reset,clk)
begin
    if reset = '0' then
        data_out_0_Q <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_0_Q(16 downto 0) <= data_out_0_complex_multiplier(69 downto 53) + 1;
    end if;
end process;
--- DATA1 ---     
process(reset,clk)
begin
    if reset = '0' then
        data_out_1_I <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_1_I(16 downto 0) <= data_out_1_complex_multiplier(29 downto 13) + 1;
    end if;
end process;

process(reset,clk)
begin
    if reset = '0' then
        data_out_1_Q <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_1_Q(16 downto 0) <= data_out_1_complex_multiplier(69 downto 53) + 1;
    end if;
end process;
--- DATA2 ---     
process(reset,clk)
begin
    if reset = '0' then
        data_out_2_I <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_2_I(16 downto 0) <= data_out_2_complex_multiplier(29 downto 13) + 1;
    end if;
end process;

process(reset,clk)
begin
    if reset = '0' then
        data_out_2_Q <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_2_Q(16 downto 0) <= data_out_2_complex_multiplier(69 downto 53) + 1;
    end if;
end process;
--- DATA3 ---     
process(reset,clk)
begin
    if reset = '0' then
        data_out_3_I <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_3_I(16 downto 0) <= data_out_3_complex_multiplier(29 downto 13) + 1;
    end if;
end process;

process(reset,clk)
begin
    if reset = '0' then
        data_out_3_Q <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_3_Q(16 downto 0) <= data_out_3_complex_multiplier(69 downto 53) + 1;
    end if;
end process;

--- DATA4 ---     
process(reset,clk)
begin
    if reset = '0' then
        data_out_4_I <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_4_I(16 downto 0) <= data_out_4_complex_multiplier(29 downto 13) + 1;
    end if;
end process;

process(reset,clk)
begin
    if reset = '0' then
        data_out_4_Q <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_4_Q(16 downto 0) <= data_out_4_complex_multiplier(69 downto 53) + 1;
    end if;
end process;
--- DATA5 ---     
process(reset,clk)
begin
    if reset = '0' then
        data_out_5_I <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_5_I(16 downto 0) <= data_out_5_complex_multiplier(29 downto 13) + 1;
    end if;
end process;

process(reset,clk)
begin
    if reset = '0' then
        data_out_5_Q <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_5_Q(16 downto 0) <= data_out_5_complex_multiplier(69 downto 53) + 1;
    end if;
end process;
--- DATA6 ---     
process(reset,clk)
begin
    if reset = '0' then
        data_out_6_I <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_6_I(16 downto 0) <= data_out_6_complex_multiplier(29 downto 13) + 1;
    end if;
end process;

process(reset,clk)
begin
    if reset = '0' then
        data_out_6_Q <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_6_Q(16 downto 0) <= data_out_6_complex_multiplier(69 downto 53) + 1;
    end if;
end process;

--- DATA7 ---     
process(reset,clk)
begin
    if reset = '0' then
        data_out_7_I <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_7_I(16 downto 0) <= data_out_7_complex_multiplier(29 downto 13) + 1;
    end if;
end process;

process(reset,clk)
begin
    if reset = '0' then
        data_out_7_Q <= (others => '0');
    elsif clk'event and clk = '1' then
        data_out_7_Q(16 downto 0) <= data_out_7_complex_multiplier(69 downto 53) + 1;
    end if;
end process;
data_dds_out_I <= data_out_7_I(16 downto 1)& data_out_6_I(16 downto 1)& data_out_5_I(16 downto 1) & data_out_4_I(16 downto 1) & data_out_3_I(16 downto 1) & data_out_2_I(16 downto 1) & data_out_1_I(16 downto 1) & data_out_0_I(16 downto 1);
data_dds_out_Q <= data_out_7_Q(16 downto 1) & data_out_6_Q(16 downto 1) & data_out_5_Q(16 downto 1) & data_out_4_Q(16 downto 1) & data_out_3_Q(16 downto 1) & data_out_2_Q(16 downto 1) & data_out_1_Q(16 downto 1) & data_out_0_Q(16 downto 1);

process(reset,clk)
begin
    if reset = '0' then
       data_out_valid <=  '0';
    elsif clk'event and clk = '1' then
       data_out_valid <= rdy_FIR_decimation_D4A_delay;
    end if;
end process;

data_out_internal <= dout_Q_internal_D4A_delay(16 downto 1) & dout_I_internal_D4A_delay(16 downto 1);
data_out <= data_out_internal;
                        
                                                                                                                                                                                     
                                                                                                                                         

--- FIR 链路观察 ila（调试用，可整段删除）-----------------------------------------------------
U24 : ila_data_pcie_fir
port map(
    clk => clk,
    probe0  => data_200M_I(35 downto 0),
    probe1  => data_200M_Q(35 downto 0),
    probe2  => data_200M_I_delay,
    probe3  => data_200M_Q_delay,
    probe4  => dout_I_internal_D4A(33 downto 0),
    probe5  => dout_Q_internal_D4A(33 downto 0),
    probe6  => dout_I_internal_D4A_delay,
    probe7  => dout_Q_internal_D4A_delay,
    probe8  => data_out_internal,
    probe9  => rdy_FIR_decimation_D4A,
    probe10 => rdy_FIR_decimation_D4A_delay
);

end Behavioral;

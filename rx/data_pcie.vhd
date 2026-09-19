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

COMPONENT downsample_45m
PORT (
    clk        : IN  STD_LOGIC;
    rst_n      : IN  STD_LOGIC;
    din_iq     : IN  STD_LOGIC_VECTOR(255 DOWNTO 0);
    din_valid  : IN  STD_LOGIC;
    dout_iq    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    dout_valid : OUT STD_LOGIC
);
END COMPONENT;

signal din_iq         : std_logic_vector(255 downto 0);
signal dds_dout_iq    : std_logic_vector(31 downto 0);
signal dds_dout_valid : std_logic;

COMPONENT ila_data_dds_downsample
PORT (
    clk    : IN STD_LOGIC;
    probe0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);   -- downsample_45m 的 {q,i} 输出
    probe1 : IN STD_LOGIC_VECTOR( 0 DOWNTO 0)    -- downsample_45m 的 dout_valid
);
END COMPONENT;

--COMPONENT ila_data_dds_out
--PORT (
--	clk : IN STD_LOGIC;
--	probe0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
--	probe1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
--);
--END COMPONENT  ;


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

--- 两级抽取（÷8 多相 + ÷4）用自写模块替换原来的 FIR_decimation_D8 / FIR_decimation_D4A -----
--- 输入为 RFDC 风格 256bit：{q7,i7,...,q0,i0}，lane0 最早；输出原生直通，定标上板用 ILA 标定 --
U16 : downsample_45m
port map(
    clk        => clk,
    rst_n      => reset,        -- 本文件 reset 为低有效，即 rst_n
    din_iq     => din_iq,
    din_valid  => '1',          -- 与原来 FIR IP 的 s_axis_data_tvalid => '1' 一致
    dout_iq    => dds_dout_iq,
    dout_valid => dds_dout_valid
);

U22 : ila_data_dds_downsample
port map(
    clk    => clk,
    probe1(0) => dds_dout_valid,
    probe1 => (0 => dds_dout_valid)
);

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

din_iq <= data_out_7_Q(16 downto 1) & data_out_7_I(16 downto 1) &
          data_out_6_Q(16 downto 1) & data_out_6_I(16 downto 1) &
          data_out_5_Q(16 downto 1) & data_out_5_I(16 downto 1) &
          data_out_4_Q(16 downto 1) & data_out_4_I(16 downto 1) &
          data_out_3_Q(16 downto 1) & data_out_3_I(16 downto 1) &
          data_out_2_Q(16 downto 1) & data_out_2_I(16 downto 1) &
          data_out_1_Q(16 downto 1) & data_out_1_I(16 downto 1) &
          data_out_0_Q(16 downto 1) & data_out_0_I(16 downto 1);

--- 输出原生直通：dout_iq 是 downsample_4 的输出寄存器，dout_valid 是 d4_ce_del 的寄存器
--- 输出，两者天然对齐、与旧链一样是 1/4 占空，这里不再额外打拍（ps/top.vhd 还会再寄一拍）-
data_out       <= dds_dout_iq;
data_out_valid <= dds_dout_valid;
                        
                                                                                                                                                                                     
                                                                                                                                         

end Behavioral;

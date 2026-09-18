----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2026/01/25 22:43:14
-- Design Name: 
-- Module Name: pcie_irq_ctrl - Behavioral
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

entity pcie_irq_ctrl is
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
    wea_rising  : out std_logic;
    irq_ack : in std_logic_vector(1 downto 0)
);
end pcie_irq_ctrl;

architecture Behavioral of pcie_irq_ctrl is

component falling_edge_detector is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           din : in  STD_LOGIC;
           dout : out  STD_LOGIC);
end component;

component rising_edge_detector is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           din : in  STD_LOGIC;
           dout : out  STD_LOGIC);
end component;

COMPONENT pcie_irq_ctrl_bram
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(511 DOWNTO 0)
  );
END COMPONENT;

component vio_irq_ctrl
port(
    clk : in std_logic;
    probe_out0 : out std_logic_vector(19 downto 0);
    probe_out1 : out std_logic;
    probe_out2 : out std_logic;
    probe_out3 : out std_logic_vector(1 downto 0)
);
end component;

component wide_pulse
port(
    reset : in std_logic;
    clk : in std_logic;
    num_clk : in std_logic_vector(3 downto 0);
    din : in std_logic;
    dout : out std_logic
);
end component;

COMPONENT ila_pcie_irq_ctrl
PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(19 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(19 DOWNTO 0); 
	probe3 : IN STD_LOGIC; 
	probe4 : IN STD_LOGIC; 
	probe5 : IN STD_LOGIC; 
	probe6 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe7 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
	probe8 : IN STD_LOGIC; 
	probe9 : IN STD_LOGIC; 
	probe10 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); 
	probe11 : IN STD_LOGIC_VECTOR(17 DOWNTO 0); 
	probe12 : IN STD_LOGIC; 
	probe13 : IN STD_LOGIC;
	probe14 : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
	probe15 : IN STD_LOGIC;
	probe16 : IN STD_LOGIC;
	probe17 : IN STD_LOGIC;
	probe18 : IN STD_LOGIC
);
END COMPONENT  ;

signal cnt : std_logic_vector(19 downto 0);
signal times : std_logic_vector(19 downto 0);
signal irq1_falling : std_logic;
signal irq2_falling : std_logic;
signal flag_irq : std_logic;
signal irq1_internal : std_logic;
signal irq2_internal : std_logic;

signal cnt_irq1 : std_logic_vector(31 downto 0);
signal cnt_irq2 : std_logic_vector(31 downto 0);
signal cnt_irq_12 : std_logic_vector(4 downto 0);
signal addra : std_logic_vector(17 downto 0);
signal wea0 : std_logic;
signal wea1 : std_logic;
signal dina : std_logic_vector(511 downto 0);
signal din_analog : std_logic_vector(511 downto 0);
signal flag_rdy : std_logic;
signal write_stop : std_logic;
signal flag_rdy_up : std_logic;
signal flag_rdy_up_short : std_logic;
signal flag_half : std_logic_vector(1 downto 0);

signal clk_24M : std_logic;
signal clk_12M : std_logic;
signal clk_6M : std_logic;
signal cnt_div2 : std_logic_vector(2 downto 0);
signal cnt_flag_rdy : std_logic_vector(3 downto 0);

signal wea0_rising : std_logic;
signal wea1_rising : std_logic;
signal wea01_rising  : std_logic;

begin
write_stop <= xdma_stop;
--process(clk,reset)
--begin
--    if reset = '0' then
--        cnt_flag_rdy <= "0000";
--    elsif clk'event and clk = '1' then
--        if cnt_flag_rdy = "1111" then
--            cnt_flag_rdy <= "0000";
--        elsif flag_xdma_test_rdy = '1' or cnt_flag_rdy /= "0000" then
--            cnt_flag_rdy <= cnt_flag_rdy + 1;
--        end if;
--    end if;
--end process;

--process(clk,reset)
--begin
--    if reset = '0' then
--        flag_rdy <= '0';
--    elsif clk'event and clk = '1' then
--        if cnt_flag_rdy /= "0000" then
--            flag_rdy <= '1';
--        else
--            flag_rdy <= '0';
--        end if;
--    end if;
--end process;


--process(clk,reset)
--begin
--    if reset = '0' then
--        clk_work <= '0';
--    elsif clk'event and clk = '1' then
--        if flag_half = "10" then
--            clk_work <= clk_24M;
--        elsif flag_half = "01" then
--            clk_work <= clk_12M;
--        elsif flag_half = "00" then
--            clk_work <= clk_6M;
--        end if;
--    end if;
--end process;

--process(clk,reset)
--begin
--    if reset = '0' then
--        cnt_div2 <= "000";
--    elsif clk'event and clk = '1' then
--        cnt_div2 <= cnt_div2 + 1;
--    end if;
--end process;

--process(clk,reset)
--begin
--    if reset = '0' then
--        clk_6M <= '0';
--    elsif clk'event and clk = '1' then
--        if cnt_div2 = "100" or cnt_div2 = "101" or cnt_div2 = "110" or cnt_div2 = "111" then
--            clk_6M <= '1';
--        else
--            clk_6M <= '0';
--        end if;
--    end if;
--end process;

--process(clk,reset)
--begin
--    if reset = '0' then
--        clk_12M <= '0';
--    elsif clk'event and clk = '1' then
--        if cnt_div2 = "010" or cnt_div2 = "011" or cnt_div2 = "110" or cnt_div2 = "111" then
--            clk_12M <= '1';
--        else
--            clk_12M <= '0';
--        end if;
--    end if;
--end process;

--process(clk,reset)
--begin
--    if reset = '0' then
--        clk_24M <= '0';
--    elsif clk'event and clk = '1' then
--        clk_24M <= not clk_24M;
--    end if;
--end process;

--process(clk, reset)
--begin
--    if reset = '0' then
--        flag_irq <= '0';
--    elsif clk'event and clk = '1' then
--        if cnt = times and times > x"00000" then
--            flag_irq <= not flag_irq;
--        end if;
--    end if;
--end process;

--process(clk, reset)
--begin
--    if reset = '0' then
--        cnt <= (others => '0');
--    elsif clk'event and clk = '1' then
--        if cnt = times then
--            cnt <= (others => '0');
--        elsif times = x"00000" then
--            cnt <= (others => '0');
--        else
--            cnt <= cnt + 1;
--        end if;
--    end if;
--end process;

--process(clk, reset)
--begin
--    if reset = '0' then
--        irq1_internal <= '0';
--    elsif clk'event and clk = '1' then
--        if irq1_falling = '1' then
--            irq1_internal <= '0';
--        elsif cnt = x"C" then
--            irq1_internal <= '0';
--        elsif cnt = times and times > x"00000" and flag_irq = '0' then
--            irq1_internal <= '1';
--        end if;
--    end if;
--end process;

--process(clk, reset)
--begin
--    if reset = '0' then
--        irq2_internal <= '0';
--    elsif clk'event and clk = '1' then
--        if irq2_falling = '1' then
--            irq2_internal <= '0';
--        elsif cnt = x"C" then
--            irq2_internal <= '0';
--        elsif cnt = times and times > x"00000" and flag_irq = '1' then
--            irq2_internal <= '1';
--        end if;
--    end if;
--end process;

--irq_ctrl(0) <= irq1_internal;
--irq_ctrl(1) <= irq2_internal;

process(clk, reset)
begin
    if reset = '0' then
        cnt_irq1 <= (others => '0');
    elsif clk'event and clk = '1' then
        if flag_rdy_up = '1' then
            cnt_irq1 <= (others => '0');
        elsif wea0 = '1' and addra = x"3FFF" and data_in_valid = '1' then
            cnt_irq1 <= cnt_irq1 + 1;
        end if;
    end if;
end process;

process(clk, reset)
begin
    if reset = '0' then
        cnt_irq2 <= (others => '0');
    elsif clk'event and clk = '1' then
        if flag_rdy_up = '1' then
            cnt_irq2 <= (others => '0');
        elsif wea1 = '1' and addra = x"3FFF" and data_in_valid = '1' then
            cnt_irq2 <= cnt_irq2 + 1;
        end if;
    end if;
end process;

--- data_in_FFT_IQ_delay ---
process(clk,reset)
begin
    if reset = '0' then
        dina <= (others => '0');
    elsif clk'event and clk = '1' then
        if write_stop = '0' then
            dina <= (others => '0');
        elsif data_source_select = '0' then
            dina <= data_in;
        else
            dina <= din_analog;
        end if;
    end if;
end process;

process(clk,reset)
begin
    if reset = '0' then
        din_analog <= (others => '0');
    elsif clk'event and clk = '1' then
        if write_stop = '0' then
            din_analog <= (others => '0');
        elsif data_in_valid = '1' then
            din_analog <= din_analog + 1;
        end if;
    end if;
end process;

--- write_en1 ---
process(clk,reset)
begin
    if reset = '0' then
        wea0 <= '0';
    elsif clk'event and clk = '1' then
        if write_stop = '0' then
            wea0 <= '0';
        elsif addra = x"3FFF" and wea0 = '1' and data_in_valid = '1' then
            wea0 <= '0';
        elsif flag_rdy_up = '1' then
            wea0 <= '1';
        elsif addra = x"3FFF" and wea1 = '1' and data_in_valid = '1' then
            wea0 <= '1';
        end if;
    end if;
end process;

--- write_en2 ---
process(clk,reset)
begin
    if reset = '0' then
        wea1 <= '0';
    elsif clk'event and clk = '1' then
        if write_stop = '0' then
            wea1 <= '0';
        elsif addra = x"3FFF" and wea1 = '1' and data_in_valid = '1' then
            wea1 <= '0';
        elsif addra = x"3FFF" and wea0 = '1' and data_in_valid = '1' then
            wea1 <= '1';
        end if;
    end if;
end process;

--- addra ----
process(clk,reset)
begin
    if reset = '0' then
        addra <= (others => '0');
    elsif clk'event and clk = '1' then
        if write_stop = '0' then
            addra <= (others => '0');
        elsif addra = x"3FFF" and data_in_valid = '1' then
            addra <= (others => '0');
        elsif (wea0 = '1' or wea1 = '1') and data_in_valid = '1'then
            addra <= addra + 1;
        end if;
    end if;
end process;

process(clk,reset)
begin
    if reset = '0' then
        cnt_irq_12 <= (others => '0');
    elsif clk'event and clk = '1' then
        if irq1_internal = '1' or irq2_internal = '1'then
            cnt_irq_12 <= cnt_irq_12 + 1;
        else
            cnt_irq_12 <= (others => '0');
        end if;
    end if;
end process;

----- irq ---
process(clk,reset)
begin
    if reset = '0' then
        irq1_internal <= '0';
    elsif clk'event and clk = '1' then
        if write_stop = '0' then
            irq1_internal <= '0';
        elsif cnt_irq_12 = x"C" then
            irq1_internal <= '0';
        elsif wea0 = '1' and addra = x"3FFF" and data_in_valid = '1' then
            irq1_internal <= '1';
        end if;
    end if;
end process;

process(clk,reset)
begin
    if reset = '0' then
        irq2_internal <= '0';
    elsif clk'event and clk = '1' then 
        if write_stop = '0' then
            irq2_internal <= '0';
        elsif cnt_irq_12 = x"C" then
            irq2_internal <= '0';
        elsif wea1 = '1' and addra = x"3FFF" and data_in_valid = '1' then
            irq2_internal <= '1';
        end if;
    end if;
end process;

irq_ctrl(0) <= irq1_internal;
irq_ctrl(1) <= irq2_internal;

--U0 : falling_edge_detector
--port map(
--    reset => reset,
--    clk => clk_work,
--    din => irq_ack(0),
--    dout => irq1_falling
--);

--U1 : falling_edge_detector
--port map(
--    reset => reset,
--    clk => clk_work,
--    din => irq_ack(1),
--    dout => irq2_falling
--);

U3 : vio_irq_ctrl
port map(
    clk => clk,
    probe_out0 => times,
    probe_out1 => open,
    probe_out2 => open,
    probe_out3 => flag_half
);

U4 : ila_pcie_irq_ctrl
port map(
    clk => clk,
    probe0 => irq_ack,
    probe1 => cnt,
    probe2 => times,
    probe3 => flag_irq,
    probe4 => flag_xdma_test_rdy,
    probe5 => data_source_select,
    probe6 => cnt_irq1,
    probe7 => cnt_irq2,
    probe8 => irq1_internal,
    probe9 => irq2_internal,
    probe10 => cnt_irq_12  ,
    probe11 => addra       ,
    probe12 => wea0        ,
    probe13 => wea1        ,
    probe14 => dina,
    probe15 => data_in_valid,
    probe16 => wea0_rising,
    probe17 => wea1_rising,
    probe18 => wea01_rising
);

U5 : pcie_irq_ctrl_bram
PORT MAP (
    clka => clk,
    wea => wea0,
    ena => data_in_valid,
    addra => addra(13 downto 0),
    dina => dina,
    clkb => clkb0,
    addrb => addrb0(19 downto 6),
    doutb => dout0
  );

U6 : pcie_irq_ctrl_bram
PORT MAP (
    clka => clk,
    wea => wea1,
    ena => data_in_valid,
    addra => addra(13 downto 0),
    dina => dina,
    clkb => clkb1,
    addrb => addrb1(19 downto 6),
    doutb => dout1
  );
  
--   uram1 : entity work.xpm_uram
--Generic map(
--     DATA_WIDTH_A            => 64,  
--     ADDR_WIDTH_A            => 18,  
--     DATA_WIDTH_B            => 256,  
--     ADDR_WIDTH_B            => 16,     
--     READ_LATENCY            => 1  
--  )
--   port map (
--       clka   => clk,
--       clkb   => clkb0,
--       wea(0)   =>  wea0,          -- 注意：必须是单bit信号
--       addra =>     addra(17 downto 0),
--       addrb =>     addrb0(20 downto 5),
--       dina  =>     dina,
--       doutb =>     dout0
--   );

--   uram2 : entity work.xpm_uram
--Generic map(
--     DATA_WIDTH_A            => 64,  
--     ADDR_WIDTH_A            => 18,  
--     DATA_WIDTH_B            => 256,  
--     ADDR_WIDTH_B            => 16,     
--     READ_LATENCY            => 1  
--  )
--   port map (
--       clka   => clk,
--       clkb   => clkb1,
--       wea(0)   =>  wea1,          -- 注意：必须是单bit信号
--       addra =>     addra(17 downto 0),
--       addrb =>     addrb1(20 downto 5),
--       dina  =>     dina,
--       doutb =>     dout1
--   );
  
falling_edge_detect : falling_edge_detector
port map(
    reset => reset,
    clk => clk,
    din => flag_xdma_test_rdy,
    dout => flag_rdy_up
);

rising_edge_detect_0 : rising_edge_detector
port map(
    reset => reset,
    clk => clk,
    din => wea0,
    dout => wea0_rising
);

rising_edge_detect_1 : rising_edge_detector
port map(
    reset => reset,
    clk => clk,
    din => wea1,
    dout => wea1_rising
);

process(clk,reset)
begin
    if reset = '0' then
        wea01_rising <= '0';
    elsif clk'event and clk = '1' then
        if wea0_rising = '1' or wea1_rising = '1' then
            wea01_rising <= '1';
        else
            wea01_rising <= '0';
        end if;
    end if;
end process;

wea_rising <= wea01_rising;

--U8 : wide_pulse
--port map(
--    reset => reset,
--    clk => clk,
--    num_clk => x"F" ,
--    din => flag_rdy_up_short,
--    dout => flag_rdy_up
    
--);

end Behavioral;

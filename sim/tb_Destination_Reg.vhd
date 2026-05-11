
library ieee;
use ieee.std_logic_1164.all;

entity tb_Destination_Reg is
end tb_Destination_Reg;

architecture behavior of tb_Destination_Reg is

  -- componant used in testbench
  component Destination_Reg
    port (
	--Input
        Rx_Data        	: in std_logic_vector(7 downto 0);
        Rx_Clk         	: in std_logic;
        Dst_En   	: in std_logic;
	--Output
        Dst_MAC        	: out std_logic_vector(47 downto 0)
    );
  end component;

  -- Signals
  signal Test_Rx_Data        : std_logic_vector(7 downto 0) := x"00";
  signal Test_Rx_Clk          : std_logic := '0';
  signal Test_Dst_En 		: std_logic := '0'; 
  signal Test_Dst_MAC        : std_logic_vector(47 downto 0) := (others => '0');

  -- Clock Speed
  constant clk_period : time := 1 ns;

  begin

    Comp1 : Destination_Reg port map (
    Rx_Data     => Test_Rx_Data,
    Rx_Clk	=> Test_Rx_Clk,
    Dst_En 	=> Test_Dst_En,
    Dst_MAC   	=> Test_Dst_MAC
    );

  -- Clock generation
  Clk_Generator : process
  begin
    Test_Rx_Clk <= '0';
    wait for clk_period / 2;
    Test_Rx_Clk <= '1';
    wait for clk_period / 2;
  end process;

  -- Data_Simulation
  Data_Sim : process
  begin
    	-- Start by inserting data
    	Test_Dst_En <= '0';
   	wait for clk_period*2;
    	Test_Dst_En <= '1';
	Test_Rx_Data <= X"01";
    	wait for clk_period;
    	Test_Rx_Data <= X"02";
	wait for clk_period;
    	Test_Rx_Data <= X"03";
	wait for clk_period;
    	Test_Rx_Data <= X"04";
	wait for clk_period;
    	Test_Rx_Data <= X"05";
	wait for clk_period;
    	Test_Rx_Data <= X"06";
	wait for clk_period;
	Test_Dst_En <= '0';
    wait;
  end process;

end;













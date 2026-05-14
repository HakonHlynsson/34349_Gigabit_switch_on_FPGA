
library ieee;
use ieee.std_logic_1164.all;

entity tb_Port_Logic is
end tb_Port_Logic;

architecture behavior of tb_Port_Logic is

  -- componant used in testbench
  component Port_Logic
    	port (
	--Input
	Reset			: in std_logic;
	Tx_Clk     		: in std_logic;
	En_Port_in		: in std_logic;
	Dst_Port_in		: in std_logic_vector(2 downto 0);
	--Output
	En_Data_out		: out std_logic;
	Dst_Port_out		: out std_logic_vector(2 downto 0)
	);
  end component;

  -- Signals
	Signal test_Reset	: std_logic;
	Signal test_Tx_Clk	: std_logic;
	Signal test_En_Port_in	: std_logic;
	Signal test_Dst_Port_in	: std_logic_vector(2 downto 0);
	Signal test_En_Port_out	: std_logic;
	Signal test_Dst_Port_out: std_logic_vector(2 downto 0);
 

  -- Clock Speed
  constant clk_period_1 : time := 8 ns;

  begin

    Comp1 : Port_Logic port map (
	Reset		=>test_Reset,
	Tx_Clk		=>test_Tx_Clk,	
	En_Port_in	=>test_En_Port_in,	
	Dst_Port_in	=>test_Dst_Port_in,	
	En_Data_out	=>test_En_Port_out,	
	Dst_Port_out	=>test_Dst_Port_out	
    );

  -- Clock generation 1 
  Clk_Generator1 : process
  begin
    test_Tx_Clk <= '0';
    wait for clk_period_1/2;
    test_Tx_Clk <= '1';
    wait for clk_period_1/2;
  end process;

  -- Data_Simulation
  Data_Sim : process
  begin
    	-- Start by inserting data
	wait for clk_period_1;   	
	test_Reset	<= '1';
	test_En_Port_in	<= '0';
	test_Dst_Port_in<= "000";
	wait for clk_period_1; 
	test_Reset<= '0';
	wait for clk_period_1;
	test_En_Port_in	<= '1';
	test_Dst_Port_in<= "001";
	wait for clk_period_1*5;
	test_En_Port_in	<= '0';
	

    wait;
  end process;

end;


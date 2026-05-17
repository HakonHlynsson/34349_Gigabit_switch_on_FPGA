
library ieee;
use ieee.std_logic_1164.all;

entity tb_Top_Layer is
end tb_Top_Layer;

architecture behavior of tb_Top_Layer is

  -- componant used in testbench
  component FCS
    	port (
	      --Input
        Reset          	: in std_logic;
        Rx_Data_1       : in std_logic_vector(7 downto 0);
        Rx_Clk_1        : in std_logic;
        Rx_Valid_1   	  : in std_logic;
		    Rx_Data_2       : in std_logic_vector(7 downto 0);
        Rx_Clk_2        : in std_logic;
        Rx_Valid_2   	  : in std_logic;
		    Rx_Data_3       : in std_logic_vector(7 downto 0);
        Rx_Clk_3       	: in std_logic;
        Rx_Valid_3   	  : in std_logic;
		    Rx_Data_4       : in std_logic_vector(7 downto 0);
        Rx_Clk_4        : in std_logic;
        Rx_Valid_4   	  : in std_logic;
	
		    --Output
		    Tx_Clk        	: out std_logic;
		    Tx_Data_1       : out std_logic_vector(7 downto 0);
    	  Tx_Valid_1   	  : out std_logic;
		    Tx_Data_2       : out std_logic_vector(7 downto 0);
   	 	  Tx_Valid_2   	  : out std_logic;
		    Tx_Data_3       : out std_logic_vector(7 downto 0);
    	  Tx_Valid_3    	: out std_logic;
		    Tx_Data_4       : out std_logic_vector(7 downto 0);
    	  Tx_Valid_4    	: out std_logic
    );
	    
  end component;

  -- Signals
	Signal test_Reset	    : std_logic;
  Signal test_Rx_Data_1	: std_logic_vector(7 downto 0);
  Signal test_Rx_Clk_1	: std_logic;
  Signal test_Rx_Valid_1: std_logic;
  Signal test_Rx_Data_2	: std_logic_vector(7 downto 0);
  Signal test_Rx_Clk_2	: std_logic;
  Signal test_Rx_Valid_2: std_logic;
  Signal test_Rx_Data_3	: std_logic_vector(7 downto 0);
  Signal test_Rx_Clk_3	: std_logic;
  Signal test_Rx_Valid_3: std_logic;
  Signal test_Rx_Data_4	: std_logic_vector(7 downto 0);
  Signal test_Rx_Clk_4	: std_logic;
  Signal test_Rx_Valid_4: std_logic;
  
  Signal test_Tx_Clk	  : std_logic;
  Signal test_Tx_Data_1	: std_logic_vector(7 downto 0);
  Signal test_Tx_Valid_1: std_logic;
  Signal test_Tx_Data_2	: std_logic_vector(7 downto 0);
  Signal test_Tx_Valid_2: std_logic;
  Signal test_Tx_Data_3	: std_logic_vector(7 downto 0);
  Signal test_Tx_Valid_3: std_logic;
  Signal test_Tx_Data_4	: std_logic_vector(7 downto 0);
  Signal test_Tx_Valid_4: std_logic;

 -- Constants
	constant Preamble 	: std_logic_vector(55 downto 0) := x"AAAAAAAAAAAAAA";
	constant Start_of_Frame : std_logic_vector(7 downto 0)  := x"AB";	
	constant Destination_MAC: std_logic_vector(47 downto 0) := x"000000000002";
	constant Source_MAC	: std_logic_vector(47 downto 0) := x"000000000001";
	constant Ethernetlength : std_logic_vector(15 downto 0) := x"002E";
	constant FCS_1		: std_logic_vector(31 downto 0) := x"A3338135";

  -- Clock Speed
  constant clk_period_1 : time := 8 ns;
  constant clk_period_2 : time := 8 ns;

  begin

    Comp1 : Top_Layer port map (
        --Input
        Reset		=> test_Reset,
        Rx_Data_1   => test_Rx_Data_1,
        Rx_Clk_1    => test_Rx_Clk_1,
        Rx_Valid_1  => test_Rx_Valid_1,
        Rx_Data_2   => test_Rx_Data_2,
        Rx_Clk_2    => test_Rx_Clk_2,
        Rx_Valid_2  => test_Rx_Valid_2, 
        Rx_Data_3   => test_Rx_Data_3,
        Rx_Clk_3    => test_Rx_Clk_3,
        Rx_Valid_3  => test_Rx_Valid_3,
        Rx_Data_4   => test_Rx_Data_4,
        Rx_Clk_4    => test_Rx_Clk_4,
        Rx_Valid_4  => test_Rx_Valid_4,

        --Output
        Tx_Clk      => test_Tx_Clk,
        Tx_Data_1   => test_Tx_Data_1,
        Tx_Valid_1  => test_Tx_Valid_1,
        Tx_Data_2   => test_Tx_Data_2,
        Tx_Valid_2  => test_Tx_Valid_2,
        Tx_Data_3   => test_Tx_Data_3,
        Tx_Valid_3  => test_Tx_Valid_3, 
        Tx_Data_4   => test_Tx_Data_4,
        Tx_Valid_4  => test_Tx_Valid_4
    );

  -- Clock generation 1 
  Clk_Generator1 : process
  begin
    test_Rx_Clk <= '0';
    wait for clk_period_1/2;
    test_Rx_Clk <= '1';
    wait for clk_period_1/2;
  end process;

   Clk_Generator2 : process
  begin
    test_Tx_Clk <= '0';
    wait for clk_period_2/2;
    test_Tx_Clk <= '1';
    wait for clk_period_2/2;
  end process;

  -- Data_Simulation
  Data_Sim : process
  begin

  -- Start by inserting data
	wait for clk_period_1;   	
	test_Reset	<= '1';

	test_Rx_Valid_1	<= '0';
  test_Rx_Valid_2	<= '0';
  test_Rx_Valid_3	<= '0';
  test_Rx_Valid_4	<= '0'; 

	test_Rx_Data_1	<= x"00";
  test_Rx_Data_2	<= x"00";
  test_Rx_Data_3	<= x"00";
  test_Rx_Data_4	<= x"00";

	wait for clk_period_1; 
	test_Reset<= '0';
	wait for clk_period_1;
	
	-- Begin Data Transmission
    test_Rx_Valid_1	<= '0';
    test_Rx_Valid_2	<= '0';
    test_Rx_Valid_3	<= '0';
    test_Rx_Valid_4	<= '0';

    -- 1. Send Preamble (7 Bytes)
    for i in 6 downto 0 loop

        test_Rx_Data_1 <= Preamble((i*8)+7 downto i*8);
        test_Rx_Data_2 <= Preamble((i*8)+7 downto i*8);
        test_Rx_Data_3 <= Preamble((i*8)+7 downto i*8);
        test_Rx_Data_4 <= Preamble((i*8)+7 downto i*8);
        wait for clk_period_1;
    end loop;

    -- 2. Send Start of Frame (1 Byte)
    test_Rx_Data_1 <= Start_of_Frame;
    test_Rx_Data_2 <= Start_of_Frame;
    test_Rx_Data_3 <= Start_of_Frame;
    test_Rx_Data_4 <= Start_of_Frame;
    wait for clk_period_1;

    -- 3. Send Destination MAC (6 Bytes)
    test_Rx_Valid_1 <= '1';
    test_Rx_Valid_2 <= '1';
    test_Rx_Valid_3 <= '1';
    test_Rx_Valid_4 <= '1';
    for i in 5 downto 0 loop
        test_Rx_Data_1 <= Destination_MAC_1((i*8)+7 downto i*8);
        test_Rx_Data_2 <= Destination_MAC_2((i*8)+7 downto i*8);
        test_Rx_Data_3 <= Destination_MAC_3((i*8)+7 downto i*8);
        test_Rx_Data_4 <= Destination_MAC_4((i*8)+7 downto i*8);
        wait for clk_period_1;
    end loop;

    -- 4. Send Source MAC (6 Bytes)
    for i in 5 downto 0 loop
        test_Rx_Data_1 <= Source_MAC_1((i*8)+7 downto i*8);
        test_Rx_Data_2 <= Source_MAC_2((i*8)+7 downto i*8);
        test_Rx_Data_3 <= Source_MAC_3((i*8)+7 downto i*8);
        test_Rx_Data_4 <= Source_MAC_4((i*8)+7 downto i*8);
        wait for clk_period_1;
    end loop;

    -- 5. Send EtherType / Length (2 Bytes)
    for i in 1 downto 0 loop
        test_Rx_Data_1 <= Ethernetlength_1((i*8)+7 downto i*8);
        test_Rx_Data_2 <= Ethernetlength_2((i*8)+7 downto i*8);
        test_Rx_Data_3 <= Ethernetlength_3((i*8)+7 downto i*8);
        test_Rx_Data_4 <= Ethernetlength_4((i*8)+7 downto i*8);
        wait for clk_period_1;
    end loop;

    -- 6. Send Payload (46 Bytes of 0xAA)
    for i in 1 to 46 loop
        test_Rx_Data_1 <= x"AA";
        test_Rx_Data_2 <= x"AA";
        test_Rx_Data_3 <= x"AA";
        test_Rx_Data_4 <= x"AA";
        wait for clk_period_1;
    end loop;

    -- 7. Send FCS (4 Bytes)

    for i in 3 downto 0 loop
        test_Rx_Data_1 <= FCS_1((i*8)+7 downto i*8);
        test_Rx_Data_2 <= FCS_2((i*8)+7 downto i*8);
        test_Rx_Data_3 <= FCS_3((i*8)+7 downto i*8);
        test_Rx_Data_4 <= FCS_4((i*8)+7 downto i*8);
        wait for clk_period_1;
    end loop;

    -- End of Frame Transmission
    test_Rx_Valid_1	<= '0';
    test_Rx_Valid_2	<= '0';
    test_Rx_Valid_3	<= '0';
    test_Rx_Valid_4	<= '0'; 

	  test_Rx_Data_1	<= x"00";
    test_Rx_Data_2	<= x"00";
    test_Rx_Data_3	<= x"00";
    test_Rx_Data_4	<= x"00";

    wait;
  end process;

end;

























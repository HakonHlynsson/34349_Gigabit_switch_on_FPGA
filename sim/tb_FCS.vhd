
library ieee;
use ieee.std_logic_1164.all;

entity tb_FCS is
end tb_FCS;

architecture behavior of tb_FCS is

  -- componant used in testbench
  component FCS
    	port(
        --Input
        Reset			    : in std_logic;
        Tx_Clk     		: in std_logic;
        Rx_Clk     		: in std_logic;
        Rx_Valid		  : in std_logic;
        RX_Data   		: in std_logic_vector(7 downto 0);
        Done_In			  : in std_logic;
        Dst_Port_in		: in std_logic_vector(3 downto 0);
        --Output
        Dst_Port_out	: out std_logic_vector(2 downto 0);
        Data_out		: out std_logic_vector(7 downto 0);
        Dst_Mac 		: out std_logic_vector(47 downto 0);
        Src_Mac 		: out std_logic_vector(47 downto 0)
        );
	    
  end component;

  -- Signals
	Signal test_Reset	: std_logic;
	Signal test_Rx_Clk	: std_logic;
	Signal test_Rx_Valid	: std_logic;
	Signal test_RX_Data	: std_logic_vector(7 downto 0);
  Signal test_Done_In		:  std_logic;
  Signal test_Dst_Port_in		:  std_logic_vector(3 downto 0);
  Signal test_Dst_Port_out	:  std_logic_vector(2 downto 0);
  Signal test_Data_out		:  std_logic_vector(7 downto 0);
  Signal test_Dst_Mac 		:  std_logic_vector(47 downto 0);
  Signal test_Src_Mac 		:  std_logic_vector(47 downto 0)

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

    Comp1 : FCS port map (
        --Input
        Reset		=> test_Reset,
        Tx_Clk		=> test_Tx_Clk,	
        Rx_Clk      => test_Rx_Clk,
        Rx_Valid	=> test_Rx_Valid,
        RX_Data   	=> test_RX_Data,
        Done_In		=> test_Done_In,
        Dst_Port_in	=> test_Dst_Port_in,
        --Output
        Dst_Port_out=> test_Dst_Port_out,
        Data_out	=> test_Data_out,
        Dst_Mac 	=> test_Dst_Mac,
        Src_Mac 	=> test_Src_Mac
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
	test_Rx_Valid	<= '0';
	test_RX_Data	<= x"00";
	wait for clk_period_1; 
	test_Reset<= '0';
	wait for clk_period_1;
	
	-- Begin Data Transmission
    test_Rx_Valid <= '0';

    -- 1. Send Preamble (7 Bytes)
    for i in 6 downto 0 loop
        test_RX_Data <= Preamble((i*8)+7 downto i*8);
        wait for clk_period_1;
    end loop;

    -- 2. Send Start of Frame (1 Byte)
    test_RX_Data <= Start_of_Frame;
    wait for clk_period_1;

    -- 3. Send Destination MAC (6 Bytes)
    test_Rx_Valid <= '1';
    for i in 5 downto 0 loop
        test_RX_Data <= Destination_MAC((i*8)+7 downto i*8);
        wait for clk_period_1;
    end loop;

    -- 4. Send Source MAC (6 Bytes)
    for i in 5 downto 0 loop
        test_RX_Data <= Source_MAC((i*8)+7 downto i*8);
        wait for clk_period_1;
    end loop;

    -- 5. Send EtherType / Length (2 Bytes)
    for i in 1 downto 0 loop
        test_RX_Data <= Ethernetlength((i*8)+7 downto i*8);
        wait for clk_period_1;
    end loop;

    -- 6. Send Payload (46 Bytes of 0xAA)
    for i in 1 to 46 loop
        test_RX_Data <= x"AA";
        wait for clk_period_1;
    end loop;

    -- 7. Send FCS (4 Bytes)
    -- Send the FIRST byte of the FCS and trigger the FCS_Check flag simultaneously
    test_RX_Data   <= FCS_1(31 downto 24); 
    test_FCS_Check <= '1';
    wait for clk_period_1;
    
    -- Turn off the flag for the rest of the FCS transmission
    test_FCS_Check <= '0';

    -- Send the remaining 3 bytes of the FCS
    for i in 2 downto 0 loop
        test_RX_Data <= FCS_1((i*8)+7 downto i*8);
        wait for clk_period_1;
    end loop;

    -- End of Frame Transmission
    test_Rx_Valid <= '0';
    test_RX_Data  <= x"00";

    wait;
  end process;

end;

























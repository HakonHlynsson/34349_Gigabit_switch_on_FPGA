library ieee;
use ieee.std_logic_1164.all;

entity tb_FCS_State_Machine is
end tb_FCS_State_Machine;

architecture behavior of tb_FCS_State_Machine is

  -- componant used in testbench
  component FCS_State_Machine port (
        -- Input 
        Reset           : in    std_logic;  -- reset signal
        Rx_Clk          : in    std_logic;  -- clock signal for receiving data
        Rx_Data         : in    std_logic_vector(7 downto 0);  -- incoming data
        Rx_Valid        : in    std_logic;  -- indicates that the incoming data is valid
        -- Output
        Dst_En          : out   std_logic;  -- enables the destination MAC address register
        Src_En          : out   std_logic;  -- enables the source MAC address register
        FCS_En          : out   std_logic  -- enables the FCS register
    );
  end component;
  
  -- Signals
        -- Input 
      signal  Test_Reset           :    std_logic;  -- Reset signal
      signal  Test_Rx_Clk          :    std_logic;  -- Clock signal for receiving data
      signal  Test_Rx_Data         :    std_logic_vector(7 downto 0);  -- incoming data
      signal  Test_Rx_Valid        :    std_logic;  -- indicates that the incoming data is valid
        -- Output
      signal  Test_Dst_En          :    std_logic;  -- enables the destination MAC address register
      signal  Test_Src_En          :    std_logic;  -- enables the source MAC address register
      signal  Test_FCS_En          :    std_logic;  -- enables the FCS register

  -- Constants
	constant Preamble 	    	: std_logic_vector(55 downto 0) := x"AAAAAAAAAAAAAA";
	constant Start_of_Frame 	: std_logic_vector(7 downto 0)  := x"AB";	
	constant Destination_MAC	: std_logic_vector(47 downto 0) := x"000000000002";
	constant Source_MAC	    	: std_logic_vector(47 downto 0) := x"000000000001";
	constant Ethernetlength 	: std_logic_vector(15 downto 0) := x"002E";
	constant FCS		        : std_logic_vector(31 downto 0) := x"A3338135";

  -- Clock Speed
  constant clk_period : time := 8 ns;

begin

    Comp1 : FCS_State_Machine port map (
      -- Input
      Reset          =>Test_Reset,
      Rx_Clk         =>Test_Rx_Clk,
      Rx_Data        =>Test_Rx_Data,
      Rx_Valid       =>Test_Rx_Valid,
        -- Output 
      Dst_En        =>Test_Dst_En,    
      Src_En        =>Test_Src_En,
      FCS_En        =>Test_FCS_En
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
	wait for clk_period;   	
	test_Reset	<= '1';
	test_Rx_Valid	<= '0';
	test_RX_Data	<= x"00";
	wait for clk_period; 
	test_Reset<= '0';
	wait for clk_period;
	
	-- Begin Data Transmission
    test_Rx_Valid <= '0';

    -- 1. Send Preamble (7 Bytes)
    for i in 6 downto 0 loop
        test_RX_Data <= Preamble((i*8)+7 downto i*8);
        wait for clk_period;
    end loop;

    -- 2. Send Start of Frame (1 Byte)
    test_RX_Data <= Start_of_Frame;
    wait for clk_period;

    -- 3. Send Destination MAC (6 Bytes)
    test_Rx_Valid <= '1';
    for i in 5 downto 0 loop
        test_RX_Data <= Destination_MAC((i*8)+7 downto i*8);
        wait for clk_period;
    end loop;

    -- 4. Send Source MAC (6 Bytes)
    for i in 5 downto 0 loop
        test_RX_Data <= Source_MAC((i*8)+7 downto i*8);
        wait for clk_period;
    end loop;

    -- 5. Send EtherType / Length (2 Bytes)
    for i in 1 downto 0 loop
        test_RX_Data <= Ethernetlength((i*8)+7 downto i*8);
        wait for clk_period;
    end loop;

    -- 6. Send Payload (46 Bytes of 0xAA)
    for i in 1 to 46 loop
        test_RX_Data <= x"AA";
        wait for clk_period;
    end loop;

    -- 7. Send FCS (4 Bytes)
    -- Send the FIRST byte of the FCS and trigger the FCS_Check flag simultaneously
    test_RX_Data   <= FCS(31 downto 24); 
    wait for clk_period;
    
    -- Turn off the flag for the rest of the FCS transmission

    -- Send the remaining 3 bytes of the FCS
    for i in 2 downto 0 loop
        test_RX_Data <= FCS((i*8)+7 downto i*8);
        wait for clk_period;
    end loop;

    -- End of Frame Transmission
    test_Rx_Valid <= '0';
    test_RX_Data  <= x"00";
    wait;
  end process;

end;

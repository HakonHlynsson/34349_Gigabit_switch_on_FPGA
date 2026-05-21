---------------------------------------------------------------------
-- Componant:   FCS
-- Description: its task is read and decode the incomming singnal
--	        as well as chack if the correct FCS value has been achived
-- Made by:    Hakon Hlynsson
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FCS is
    port (
	--Input
	Reset			: in std_logic;
	Tx_Clk     		: in std_logic;
    	Rx_Clk     		: in std_logic;
	Rx_Valid		: in std_logic;
	RX_Data   		: in std_logic_vector(7 downto 0);
	En_Port_in		: in std_logic;				-- From MAC learner
	Dst_Port_in		: in std_logic_vector(2 downto 0);	-- From MAC learner
	--Output
	En_Data_out		: out std_logic; 			-- To crossbar
	Dst_Port_out		: out std_logic_vector(2 downto 0);	-- To crossbar
	Data_out		: out std_logic_vector(7 downto 0);	-- To crossbar
	En_Mac			: out std_logic;			-- To MAC learner
	Dst_Mac 		: out std_logic_vector(47 downto 0);	-- To MAC learner
	Src_Mac 		: out std_logic_vector(47 downto 0)  	-- To MAC learner
	);
end FCS;

architecture behavioral of FCS is
--Component
	component FCS_Reg port (
		--Input
		Reset			: in std_logic;
    		Rx_Clk     		: in std_logic;
		Rx_Valid		: in std_logic;
		RX_Data   		: in std_logic_vector(7 downto 0);
		FCS_Check		: in std_logic;
		--Output
    		En_Mac          : out std_logic;
    		Drop            : out std_logic
	);
  	end component;

	component FCS_State_Machine port (
		-- Input 
		Reset           : in    std_logic;  -- reset signal
		Rx_Clk          : in    std_logic;  -- clock signal for receiving data
		Rx_Data         : in    std_logic_vector(7 downto 0);  -- incoming data
		Rx_Valid        : in    std_logic;  -- indicates that the incoming data is valid
		-- Output
		Package_Length  : out  std_logic_vector(10 downto 0);
		Dst_En          : out   std_logic;  -- enables the destination MAC address register
		Src_En          : out   std_logic;  -- enables the source MAC address register
		FCS_En          : out   std_logic;  -- enables the FCS register
		En_Up		: out	std_logic   -- enables the update of the output Destination and source 
	);
  	end component;

	component Destination_Reg 
	port (
		--Input
		Rx_Data        	: in std_logic_vector(7 downto 0);
		Rx_Clk         	: in std_logic;
		Dst_En   	: in std_logic;
		En_Out		: in std_logic;
		--Output
		Dst_MAC        	: out std_logic_vector(47 downto 0)
		);
	end component;

	component Source_Reg port (
		--Input
		Rx_Data        	: in std_logic_vector(7 downto 0);
		Rx_Clk         	: in std_logic;
		Src_En		: in std_logic;
		En_Out		: in std_logic;
		--Output
		Src_MAC        	: out std_logic_vector(47 downto 0)
	);
	end component;

	component FIFO port (
		--Input
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		--Output
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
	end component;

	component Port_Logic Port(
		--Input
		Reset			: in std_logic;
		Tx_Clk     		: in std_logic;
		Frame_Good		: in std_logic;
		Frame_Bad		: in std_logic;
		Package_Length 		: in  std_logic_vector(10 downto 0);
		En_Port_in		: in std_logic;
		Dst_Port_in		: in std_logic_vector(2 downto 0);
		--Output
		FIFO_Rd			: out std_logic;
		En_Data_out		: out std_logic;
		Dst_Port_out		: out std_logic_vector(2 downto 0)
	);
	end component;
--sigbnal
	Signal Dst_En		: std_logic;
	Signal Src_En		: std_logic;
	Signal FCS_En		: std_logic;
	Signal En_Up		: std_logic;
	Signal En_Data_Out_Int	: std_logic;
	Signal En_Mac_Int	: std_logic;	-- FCS_Reg En_Mac, fanned out to MAC learner and Port_Logic
	Signal Drop_Int		: std_logic;	-- FCS_Reg Drop  (failed-frame pulse) to Port_Logic
	Signal FIFO_Rd_Int	: std_logic;	-- FIFO read enable from Port_Logic (forward AND flush)
	Signal Package_Length  	: std_logic_vector(10 downto 0);
Begin

Comp1 : FCS_State_Machine port map (
	  -- Input
	  Reset          =>Reset,
	  Rx_Clk         =>Rx_Clk,
	  Rx_Data        =>RX_Data,
	  Rx_Valid       =>Rx_Valid,
	 -- Output 
	  Package_Length=>Package_Length,
	  Dst_En        =>Dst_En,    
	  Src_En        =>Src_En,
	  FCS_En        =>FCS_En,
	  En_Up		=>En_Up
	  );

 Comp2 : FCS_Reg port map (
	-- Input
	Reset =>Reset,
	Rx_Clk =>Rx_Clk,
	Rx_Valid =>Rx_Valid,
	RX_Data =>RX_Data,
	FCS_Check =>FCS_En,
	-- Output
	En_Mac =>En_Mac_Int,
	Drop   =>Drop_Int
	);

Comp3 : Destination_Reg port map (
	--Input
	Rx_Data =>RX_Data,
	Rx_Clk =>Rx_Clk,
	Dst_En =>Dst_En,
	En_Out =>En_Up,
	--Output
	Dst_MAC =>Dst_Mac
	);

Comp4 : Source_Reg port map (
	--Input
	Rx_Data =>RX_Data,
	Rx_Clk =>Rx_Clk,
	Src_En =>Src_En,
	En_Out =>En_Up,
	--Output
	Src_MAC =>Src_Mac
	);

Comp5 : FIFO port map (
	--Input
	aclr => Reset,
	data => RX_Data,
	rdclk => Tx_Clk,
	rdreq => FIFO_Rd_Int,
	wrclk => Rx_Clk,
	wrreq => Rx_Valid,
	--Output
	q => Data_out,
	rdempty => open,
	rdusedw => open,
	wrfull => open,
	wrusedw => open
	);

Comp6 :Port_Logic port map (
	--Input
	Reset=>Reset,
	Tx_Clk=>Tx_Clk,
	Frame_Good=>En_Mac_Int,
	Frame_Bad=>Drop_Int,
	Package_Length=>Package_Length,
	En_Port_in=>En_Port_in,
	Dst_Port_in=>Dst_Port_in,
	--Output
	FIFO_Rd=>FIFO_Rd_Int,
	En_Data_out=>En_Data_Out_Int,
	Dst_Port_out=>Dst_Port_out
	);

En_Data_out <= En_Data_Out_Int;	-- crossbar enable (good frames only)
En_Mac      <= En_Mac_Int;	-- pass the pass-pulse on to the MAC learner
end behavioral;
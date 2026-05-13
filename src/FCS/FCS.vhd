---------------------------------------------------------------------
-- Componant:   FCS 
-- Description: its task is read and decode the incomming singnal
--	        as well as chack if the correct FCS value has been achived		   
-- Made by:    Hákon Hlynsson
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
	Done_In			: in std_logic;
	Dst_Port_in		: in std_logic_vector(3 downto 0);
	--Output
	Dst_Port_out	: out std_logic_vector(2 downto 0);
	Data_out		: out std_logic_vector(7 downto 0);
	Dst_Mac 		: out std_logic_vector(47 downto 0);
	Src_Mac 		: out std_logic_vector(47 downto 0)  
	);
end FCS;

architecture behavioral of FCS is
--Component
	component FCS_Reg
		port(
	Reset			: in std_logic;
	Rx_Clk        	: in std_logic;
	Rx_Valid		: in std_logic;
	RX_Data   		: in std_logic_vector(7 downto 0);
	FCS_Check		: in std_logic;
	fcs_error		: out std_logic 

	);
  	end component;

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

	component Destination_Reg port (
		--Input
		Rx_Data        	: in std_logic_vector(7 downto 0);
		Rx_Clk         	: in std_logic;
		Dst_En   		: in std_logic;
		--Output
		Dst_MAC        	: out std_logic_vector(47 downto 0)
	);
	end component;

	component Source_Reg port (
		--Input
		Rx_Data        	: in std_logic_vector(7 downto 0);
		Rx_Clk         	: in std_logic;
		Src_En		   	: in std_logic;
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
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
	end component;




--sigbnal
	Signal Dst_En		: std_logic;	
	Signal Src_En		: std_logic;
	Signal FCS_En		: std_logic;
	Signal fcs_error	: std_logic;
	signal Tx_Valid		: std_logic;



Begin

Comp1 : FCS_State_Machine port map (
	  -- Input
	  Reset          =>Reset,
	  Rx_Clk         =>Rx_Clk,
	  Rx_Data        =>RX_Data,
	  Rx_Valid       =>Rx_Valid,
		-- Output 
	  Dst_En        =>Dst_En,    
	  Src_En        =>Src_En,
	  FCS_En        =>FCS_En
	  );

 Comp2 : FCS_Reg port map (
	-- Input
	Reset =>Reset,
	Rx_Clk =>Rx_Clk,	
	Rx_Valid =>Rx_Valid,
	RX_Data =>RX_Data,
	FCS_Check =>Done_In,
	-- Output
	fcs_error =>fcs_error
	);	

Comp3 : Destination_Reg port map (
	--Input
	Rx_Data =>RX_Data,
	Rx_Clk =>Rx_Clk,
	Dst_En =>Dst_En,
	--Output
	Dst_MAC =>Dst_Mac
	);

Comp4 : Source_Reg port map (
	--Input
	Rx_Data =>RX_Data,
	Rx_Clk =>Rx_Clk,
	Src_En =>Src_En,
	--Output
	Src_MAC =>Src_Mac
	);

comp5 : FIFO port map (
	--Input
	aclr => Reset,
	data => RX_Data,
	rdclk => Tx_Clk,
	rdreq => Tx_Valid,
	wrclk => Rx_Clk,
	wrreq => Rx_Valid,
	--Output
	q => Data_out,
	rdempty => open,	
	rdusedw => open,
	wrfull => open,
	wrusedw => open
	);

end behavioral;
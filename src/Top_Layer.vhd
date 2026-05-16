

---------------------------------------------------------------------
-- Componant:   Top_Layer 
-- Description: This is the toplayer where all the sub-componants   
-- 		 are cornected.
-- Changes	:
--  		Hakon & Mikkel
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top_Layer is
    port (
	--Input
        Reset          	: in std_logic;
        Rx_Data_1       : in std_logic_vector(7 downto 0);
        Rx_Clk_1        : in std_logic;
        Rx_Valid_1   	: in std_logic;
		Rx_Data_2       : in std_logic_vector(7 downto 0);
        Rx_Clk_2        : in std_logic;
        Rx_Valid_2   	: in std_logic;
		Rx_Data_3       : in std_logic_vector(7 downto 0);
        Rx_Clk_3       	: in std_logic;
        Rx_Valid_3   	: in std_logic;
		Rx_Data_4       : in std_logic_vector(7 downto 0);
        Rx_Clk_4        : in std_logic;
        Rx_Valid_4   	: in std_logic;
	
		--Output
		Tx_Clk        	: out std_logic;
		Tx_Data_1       : out std_logic_vector(7 downto 0);
    	Tx_Valid_1   	: out std_logic;
		Tx_Data_2       : out std_logic_vector(7 downto 0);
   	 	Tx_Valid_2   	: out std_logic;
		Tx_Data_3       : out std_logic_vector(7 downto 0);
    	Tx_Valid_3   	: out std_logic;
		Tx_Data_4       : out std_logic_vector(7 downto 0);
    	Tx_Valid_4   	: out std_logic
    );
end Top_Layer;

architecture behavioral of Top_Layer is
-- Signal & Component Declaration


component FCS port (
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
	Dst_Port_out	: out std_logic_vector(2 downto 0);	-- To crossbar
	Data_out		: out std_logic_vector(7 downto 0);	-- To crossbar
	En_Mac			: out std_logic;			-- To MAC learner
	Dst_Mac 		: out std_logic_vector(47 downto 0);	-- To MAC learner
	Src_Mac 		: out std_logic_vector(47 downto 0)  	-- To MAC learner
	);  
end component;

component MAC_TOP port (
    clk      : in  std_logic;
	reset      : in  std_logic;
	
	-- Port 0
	port0_EN      : in  std_logic;
	port0_dstMac  : in  std_logic_vector(47 downto 0);
	port0_srcMac  : in  std_logic_vector(47 downto 0);
	port0_dstPort : out std_logic_vector(2 downto 0);
	port0_done    : out std_logic;

	-- Port 1
	port1_EN      : in  std_logic;
	port1_dstMac  : in  std_logic_vector(47 downto 0);
	port1_srcMac  : in  std_logic_vector(47 downto 0);
	port1_dstPort : out std_logic_vector(2 downto 0);
	port1_done    : out std_logic;

	-- Port 2
	port2_EN      : in  std_logic;
	port2_dstMac  : in  std_logic_vector(47 downto 0);
	port2_srcMac  : in  std_logic_vector(47 downto 0);
	port2_dstPort : out std_logic_vector(2 downto 0);
	port2_done    : out std_logic;

	-- Port 3
	port3_EN      : in  std_logic;
	port3_dstMac  : in  std_logic_vector(47 downto 0);
	port3_srcMac  : in  std_logic_vector(47 downto 0);
	port3_dstPort : out std_logic_vector(2 downto 0);
	port3_done    : out std_logic
);
end component;


Signal TxClk_Int : std_logic;

Signal En_Port_in_1 : std_logic;
Signal En_Port_in_2 : std_logic;
Signal En_Port_in_3 : std_logic;
Signal En_Port_in_4 : std_logic;

Signal Dst_Port_in_1 : std_logic_vector(2 downto 0);
Signal Dst_Port_in_2 : std_logic_vector(2 downto 0);
Signal Dst_Port_in_3 : std_logic_vector(2 downto 0);
Signal Dst_Port_in_4 : std_logic_vector(2 downto 0);

Signal En_Data_out_1 : std_logic;
Signal En_Data_out_2 : std_logic;
Signal En_Data_out_3 : std_logic;
Signal En_Data_out_4 : std_logic;

Signal Dst_Port_out_1 : std_logic_vector(2 downto 0);
Signal Dst_Port_out_2 : std_logic_vector(2 downto 0);
Signal Dst_Port_out_3 : std_logic_vector(2 downto 0);	
Signal Dst_Port_out_4 : std_logic_vector(2 downto 0);

Signal Data_out_1 : std_logic_vector(7 downto 0);
Signal Data_out_2 : std_logic_vector(7 downto 0);
Signal Data_out_3 : std_logic_vector(7 downto 0);
Signal Data_out_4 : std_logic_vector(7 downto 0);

Signal En_Mac_1 : std_logic;
Signal En_Mac_2 : std_logic;
Signal En_Mac_3 : std_logic;
Signal En_Mac_4 : std_logic;

Signal Dst_Mac_1 : std_logic_vector(47 downto 0);
Signal Dst_Mac_2 : std_logic_vector(47 downto 0);
Signal Dst_Mac_3 : std_logic_vector(47 downto 0);
Signal Dst_Mac_4 : std_logic_vector(47 downto 0);

Signal Src_Mac_1 : std_logic_vector(47 downto 0);
Signal Src_Mac_2 : std_logic_vector(47 downto 0);
Signal Src_Mac_3 : std_logic_vector(47 downto 0);
Signal Src_Mac_4 : std_logic_vector(47 downto 0);

-- MAC_Top
--Signal mac_en_in        : t_flag_array;
--Signal mac_dst_mac_in   : t_mac_array;
--Signal mac_src_mac_in   : t_mac_array;
--Signal mac_dst_port_out : t_port_array;
--Signal mac_done_out     : t_flag_array;


Begin



FCS1: FCS port map(
	Reset=>Reset,
	Tx_Clk=>TxClk_Int,
    Rx_Clk=>Rx_Clk_1,
	Rx_Valid=>Rx_Valid_1,
	RX_Data=>Rx_Data_1,
	En_Port_in=>En_Port_in_1,
	Dst_Port_in=>Dst_Port_in_1,
	--Output
	En_Data_out=>En_Data_out_1,
	Dst_Port_out=>Dst_Port_out_1,
	Data_out=>Data_out_1,
	En_Mac=>En_Mac_1,
	Dst_Mac=>Dst_Mac_1,
	Src_Mac=>Src_Mac_1
);

FCS2: FCS port map(
	Reset=>Reset,
	Tx_Clk=>TxClk_Int,
    Rx_Clk=>Rx_Clk_2,
	Rx_Valid=>Rx_Valid_2,
	RX_Data=>Rx_Data_2,
	En_Port_in=>En_Port_in_2,
	Dst_Port_in=>Dst_Port_in_2,
	--Output
	En_Data_out=>En_Data_out_2,
	Dst_Port_out=>Dst_Port_out_2,
	Data_out=>Data_out_2,
	En_Mac=>En_Mac_2,
	Dst_Mac=>Dst_Mac_2,
	Src_Mac=>Src_Mac_2
);

FCS3: FCS port map(
	Reset=>Reset,
	Tx_Clk=>TxClk_Int,
    Rx_Clk=>Rx_Clk_3,
	Rx_Valid=>Rx_Valid_3,
	RX_Data=>Rx_Data_3,
	En_Port_in=>En_Port_in_3,
	Dst_Port_in=>Dst_Port_in_3,
	--Output
	En_Data_out=>En_Data_out_3,
	Dst_Port_out=>Dst_Port_out_3,
	Data_out=>Data_out_3,
	En_Mac=>En_Mac_3,
	Dst_Mac=>Dst_Mac_3,
	Src_Mac=>Src_Mac_3
);

FCS4: FCS port map(
	Reset=>Reset,
	Tx_Clk=>TxClk_Int,
    Rx_Clk=>Rx_Clk_4,
	Rx_Valid=>Rx_Valid_4,
	RX_Data=>Rx_Data_4,
	En_Port_in=>En_Port_in_4,
	Dst_Port_in=>Dst_Port_in_4,
	--Output
	En_Data_out=>En_Data_out_4,
	Dst_Port_out=>Dst_Port_out_4,
	Data_out=>Data_out_4,
	En_Mac=>En_Mac_4,
	Dst_Mac=>Dst_Mac_4,
	Src_Mac=>Src_Mac_4
);

Mac_Top1: MAC_TOP port map(
	clk=>TxClk_Int,-- use TX cllk
	reset=>Reset,

	port0_EN => En_Mac_1,
	port0_dstMac => Dst_Mac_1,
	port0_srcMac => Src_Mac_1,
	port0_dstPort => Dst_Port_in_1,
	port0_done => En_Port_in_1,

	port1_EN => En_Mac_2,
	port1_dstMac => Dst_Mac_2,
	port1_srcMac => Src_Mac_2,
	port1_dstPort => Dst_Port_in_2,
	port1_done => En_Port_in_2,

	port2_EN => En_Mac_3,
	port2_dstMac => Dst_Mac_3,
	port2_srcMac => Src_Mac_3,
	port2_dstPort => Dst_Port_in_3,
	port2_done => En_Port_in_3,

	port3_EN => En_Mac_4,
	port3_dstMac => Dst_Mac_4,
	port3_srcMac => Src_Mac_4,
	port3_dstPort => Dst_Port_in_4,
	port3_done => En_Port_in_4
);

end behavioral;







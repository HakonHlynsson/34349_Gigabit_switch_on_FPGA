

---------------------------------------------------------------------
-- Componant:   Top_Layer 
-- Description: This is the toplayer where all the sub-componants   
-- 		 are cornected.
-- Changes	:
--  		HH 18/3 creation of document and I/O
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

component Mac_Top port (
	
        
    -- Inputs
	clk      		: in  std_logic;
    reset      		: in  std_logic;
    EN 				: in t_flag_array;
    dstMac 			: in t_mac_array;
    srcMac 			: in t_mac_array;
        
    -- Outputs
    dstPort 		: out t_port_array;
    done 			: out t_flag_array
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





Begin



FCS1: FCS_State_Machine port map(
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

FCS2: FCS_State_Machine port map(
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

FCS3: FCS_State_Machine port map(
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

FCS4: FCS_State_Machine port map(
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

Mac_Top: Mac_Top port map(
	clk=>TxClk_Int,-- use TX cllk
	reset=>Reset,
	EN=>(En_Mac_1, En_Mac_2, En_Mac_3, En_Mac_4),
	dstMac=>(Dst_Mac_1, Dst_Mac_2, Dst_Mac_3, Dst_Mac_4),
	srcMac=>(Src_Mac_1, Src_Mac_2, Src_Mac_3, Src_Mac_4),
	dstPort=>(Dst_Port_in_1, Dst_Port_in_2, Dst_Port_in_3, Dst_Port_in_4),
	done=>(En_Port_in_1, En_Port_in_2, En_Port_in_3, En_Port_in_4)
);

end behavioral;







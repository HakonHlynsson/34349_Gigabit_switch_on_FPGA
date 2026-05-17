---------------------------------------------------------------------
-- Componant  : Crossbar
-- Description: this is the top level block for the crossbar.
--  it
--
.
--
-- Made by    : Hakon Hlynsson
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIFO_And_Crossbar is
    port (
        --Input
        Reset       : in  std_logic;
        Tx_Clk      : in  std_logic;
        
        En_FCS_1   : in  std_logic; --write enable signal for FCS1
        En_FCS_2   : in  std_logic; --write enable signal for FCS2
        En_FCS_3   : in  std_logic; --write enable signal for FCS3
        En_FCS_4   : in  std_logic; --write enable signal for FCS4

        Dst_Port_1  : in  std_logic_vector(2 downto 0); --destination port for FCS1
        Dst_Port_2  : in  std_logic_vector(2 downto 0); --destination port for FCS2
        Dst_Port_3  : in  std_logic_vector(2 downto 0); --destination port for FCS3
        Dst_Port_4  : in  std_logic_vector(2 downto 0); --destination port for FCS4

        FCS_1_in    : in  std_logic_vector(7 downto 0);-- data input from FCS1
        FCS_2_in    : in  std_logic_vector(7 downto 0);-- data input from FCS2
        FCS_3_in    : in  std_logic_vector(7 downto 0);-- data input from FCS3
        FCS_4_in    : in  std_logic_vector(7 downto 0);-- data input from FCS4

        -- Output
        Tx_Valid1   : out std_logic;-- enable output data for port 1
        Tx_Valid2   : out std_logic;-- enable output data for port 2
        Tx_Valid3   : out std_logic;-- enable output data for port 3
        Tx_Valid4   : out std_logic;-- enable output data for port 4

        Tx_Data1    : out std_logic_vector(7 downto 0);-- data output for port 1
        Tx_Data2    : out std_logic_vector(7 downto 0);-- data output for port 2
        Tx_Data3    : out std_logic_vector(7 downto 0);-- data output for port 3
        Tx_Data4    : out std_logic_vector(7 downto 0) -- data output for port 4
    );
end FIFO_And_Crossbar;

architecture behavioral of FIFO_And_Crossbar is
    -- Componants
    
    




begin

 















end behavioral;

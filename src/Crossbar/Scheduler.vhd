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

entity Scheduler is
    port (
        --Input
        Reset       : in  std_logic;
        Tx_Clk      : in  std_logic;
        
        En_Port_1   : in  std_logic;
        En_Port_2   : in  std_logic;
        En_Port_3   : in  std_logic;
        En_Port_4   : in  std_logic;

        Port1_in    : in  std_logic_vector(7 downto 0);
        Port2_in    : in  std_logic_vector(7 downto 0);
        Port3_in    : in  std_logic_vector(7 downto 0);
        Port4_in    : in  std_logic_vector(7 downto 0);

        -- Output
        Select_S    : out std_logic_vector(3 downto 0) -- select the port the
    );
end Scheduler;

architecture behavioral of Scheduler is
    -- Internal array so the four muxes can be built with a generate loop.
   




begin

 

end behavioral;

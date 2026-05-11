---------------------------------------------------------------------
-- Componant:   Source_Reg
-- Description: Stores the Source in a register (assume MSB first)
-- 		 
-- Changes	:
--  		HH 5/4 creation of document and testing
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Destination_Reg is
    port (
	--Input
        Rx_Data        	: in std_logic_vector(7 downto 0);
        Rx_Clk         	: in std_logic;
        Scr_En   	: in std_logic;
	--Output
        Scr_MAC        	: out std_logic_vector(47 downto 0)
    );
end Destination_Reg;

architecture behavioral of Destination_Reg is
-- Signal & Component Declaration
Signal Reg	: std_logic_vector(47 downto 0):=(others => '0');
Signal count 	: unsigned(2 downto 0) := "101";

Begin

process(Rx_Clk)
	Begin
		if rising_edge(Rx_Clk) then
			if (Scr_En ='1') then
				Reg( (to_integer(count) * 8) + 7 downto (to_integer(count) * 8)) <= Rx_Data;	
				count 	<= count - 1;
			else 
				count	<= "101";		
			end if;
		end if;
end process;
Scr_MAC <= Reg;

end behavioral;










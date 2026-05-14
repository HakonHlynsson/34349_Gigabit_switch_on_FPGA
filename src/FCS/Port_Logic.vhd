---------------------------------------------------------------------
-- Componant:   Port_Logic 
-- Description:  Should take in the port from the maclearning and,
--		 and set it as an output port as well as setting the output enable signal 
--	        			   
-- Made by:    Hákon Hlynsson
---------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Port_Logic is
    port (
	--Input
	Reset			: in std_logic;
	Tx_Clk     		: in std_logic;
	En_Port_in		: in std_logic;
	Dst_Port_in		: in std_logic_vector(2 downto 0);
	--Output
	En_Data_out		: out std_logic;
	Dst_Port_out		: out std_logic_vector(2 downto 0)
	);
end Port_Logic;

architecture behavioral of Port_Logic is

-- Signals




Begin

process(Reset,Tx_Clk)
Begin
	if rising_edge(Tx_Clk) then
		if Reset = '1' then
			En_Data_out <='0';
			Dst_Port_out<=(others => '0');
		elsif(En_Port_in = '1') then 
			En_Data_out <='1';
			Dst_Port_out<=Dst_Port_in;
		else 
			En_Data_out <='0';
		end if;
	end if;
end process;

end behavioral;








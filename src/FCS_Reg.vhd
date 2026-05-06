---------------------------------------------------------------------
-- Componant:   FCS_Reg 
-- Description: Its task is to preform the FCS calculation and check registor when 
--	        	check signal goes high, and tell the data is the intendet data		   
-- Made by:    Hákon Hlynsson
---------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FCS_Reg is
    port (

	--Input
	Reset			: in std_logic;
    Rx_Clk     		: in std_logic;
	Rx_Valid		: in std_logic;
	RX_Data   		: in std_logic_vector(7 downto 0);
	FCS_Check		: in std_logic; -- goes high when ever the next 32 bits are the FCS value

	--Output
	fcs_error		: out std_logic 

	);
end FCS_Reg;

architecture behavioral of FCS_Reg is

-- Signal & Component Declaration
	Signal Reg           : std_logic_vector(31 downto 0):= (others => '0'); 	-- The 32 registers used to store data
  	Signal Counter       : unsigned(2 downto 0):= (others => '0');		-- Counter that counts number of times 8 bits have been sendt
  	Signal Data_insert   : std_logic_vector(7 downto 0);	-- Data that should be inserted
  	Signal Checksum_Start: std_logic := '0' ;			-- Checksum goes high when the checksum is being inserted 

Begin

-- Invert the first and last 32 bits
Process(Rx_Valid, FCS_Check, RX_Data, Counter)
	Begin
		if( Rx_Valid = '1' AND (Counter < 4 or FCS_Check = '1') ) then 
			Data_insert <= not RX_Data;
		else  
			Data_insert <= RX_Data;
		end if;
End process;

-- Parallel FCS setup
process(Rx_Clk)
Begin
    if rising_edge(Rx_Clk) then
        
        -- 1. Check for Reset or Invalid Data
        if (Reset = '1' or Rx_Valid = '0') then 
            Reg     <= (others => '0');
            Counter <= (others => '0');
            Checksum_Start <= '0';
            
        -- 2. If valid, perform operations
        else
            -- Check for FCS flag
            if (FCS_Check ='1') then  
                Counter <= "001";
                Checksum_Start <= '1';
	    	elsif (Counter < 4) then
				Counter <= Counter + 1;
            end if;

            -- Calculate the next state of the Register ONLY when not resetting
            Reg(0) <= Reg(24) xor Reg(30) xor Data_insert(0);
            Reg(1) <= Reg(24) xor Reg(25) xor Reg(30) xor Reg(31) xor Data_insert(1);
            Reg(2) <= Reg(24) xor Reg(25) xor Reg(26) xor Reg(30) xor Reg(31) xor Data_insert(2);
            Reg(3) <= Reg(25) xor Reg(26) xor Reg(27) xor Reg(31) xor Data_insert(3);
            Reg(4) <= Reg(24) xor Reg(26) xor Reg(27) xor Reg(28) xor Reg(30) xor Data_insert(4);
            Reg(5) <= Reg(24) xor Reg(25) xor Reg(27) xor Reg(28) xor Reg(29) xor Reg(30) xor Reg(31) xor Data_insert(5);
            Reg(6) <= Reg(25) xor Reg(26) xor Reg(28) xor Reg(29) xor Reg(30) xor Reg(31) xor Data_insert(6);
            Reg(7) <= Reg(24) xor Reg(26) xor Reg(27) xor Reg(29) xor Reg(31) xor Data_insert(7);
            Reg(8) <= Reg(0) xor Reg(24) xor Reg(25) xor Reg(27) xor Reg(28);
            Reg(9) <= Reg(1) xor Reg(25) xor Reg(26) xor Reg(28) xor Reg(29);
            Reg(10) <= Reg(2) xor Reg(24) xor Reg(26) xor Reg(27) xor Reg(29);
            Reg(11) <= Reg(3) xor Reg(24) xor Reg(25) xor Reg(27) xor Reg(28);
            Reg(12) <= Reg(4) xor Reg(24) xor Reg(25) xor Reg(26) xor Reg(28) xor Reg(29) xor Reg(30);
            Reg(13) <= Reg(5) xor Reg(25) xor Reg(26) xor Reg(27) xor Reg(29) xor Reg(30) xor Reg(31);
            Reg(14) <= Reg(6) xor Reg(26) xor Reg(27) xor Reg(28) xor Reg(30) xor Reg(31);
            Reg(15) <= Reg(7) xor Reg(27) xor Reg(28) xor Reg(29) xor Reg(31);
            Reg(16) <= Reg(8) xor Reg(24) xor Reg(28) xor Reg(29);
            Reg(17) <= Reg(9) xor Reg(25) xor Reg(29) xor Reg(30);
            Reg(18) <= Reg(10) xor Reg(26) xor Reg(30) xor Reg(31);
            Reg(19) <= Reg(11) xor Reg(27) xor Reg(31);
            Reg(20) <= Reg(12) xor Reg(28);
            Reg(21) <= Reg(13) xor Reg(29);
            Reg(22) <= Reg(14) xor Reg(24);
            Reg(23) <= Reg(15) xor Reg(24) xor Reg(25) xor Reg(30);
            Reg(24) <= Reg(16) xor Reg(25) xor Reg(26) xor Reg(31);
            Reg(25) <= Reg(17) xor Reg(26) xor Reg(27);
            Reg(26) <= Reg(18) xor Reg(24) xor Reg(27) xor Reg(28) xor Reg(30);
            Reg(27) <= Reg(19) xor Reg(25) xor Reg(28) xor Reg(29) xor Reg(31);
            Reg(28) <= Reg(20) xor Reg(26) xor Reg(29) xor Reg(30);
            Reg(29) <= Reg(21) xor Reg(27) xor Reg(30) xor Reg(31);
            Reg(30) <= Reg(22) xor Reg(28) xor Reg(31);
            Reg(31) <= Reg(23) xor Reg(29);
        end if;
        
        --Checking if the FCS value matches the 
        if (Checksum_Start = '1' and Counter = 4) then
            if (Reg = X"00000000") then
                fcs_error <= '0';
            else
                fcs_error <= '1';
            end if;
            Checksum_Start <= '0'; 
        end if;
    end if;
end process;

end behavioral;







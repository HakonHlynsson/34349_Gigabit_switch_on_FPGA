
---------------------------------------------------------------------
-- Componant:   FCS 
-- Description: its task is read and decode the incomming singnal
--	        as well as chack if the correct FCS value has been achived		   
-- Changes	:
--  		HH 19/3: creation of document and I/O and inserted FCS from Execise 1
---------------------------------------------------------------------


---------------------------------------------------------------------
-- Notes on the 

-- Length / Type.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FCS is
    port (
	--Input
	Reset			: in std_logic;
	Tx_Clk        		: in std_logic;
    	Rx_Clk        		: in std_logic;
	Rx_Valid		: in std_logic;
	RX_Data   		: in std_logic_vector(7 downto 0);
	Done_In			: in std_logic;
	Dst_Port_in		: in std_logic_vector(3 downto 0);
	--Output
	Dst_Port_out		: out std_logic_vector(2 downto 0);
	Data_out		: out std_logic_vector(7 downto 0);
	Dst_Mac 		: out std_logic_vector(47 downto 0);
	Src_Mac 		: out std_logic_vector(47 downto 0)  
	);
end FCS;

architecture behavioral of FCS is
-- Signal & Component Declaration
	signal Reg           : std_logic_vector(31 downto 0); 	-- The 32 registers used to store data
  	signal Counter       : unsigned(1 downto 0);		-- Counter that counts number of times 8 bits have been sendt
	signal Count_payload : unsigned(12 downto 0);
  	signal Data_insert   : std_logic_vector(7 downto 0);	-- Data that should be inserted
  	signal Checksum_Start: std_logic;			-- Checksum goes high when the checksum is being inserted
	signal fcs_error     : std_logic;			-- FCS error bit
	signal payload_lenght: std_logic_vector(15 downto 0);	-- Length of the payload that is being sendt			-- 

Begin


-- Data insert process (The first and last 32 bits has due to the way  )
	process(Rx_Valid,RX_Data,Counter)
	Begin
		if(Rx_Valid = '1' or Counter < 3) then
			Data_insert <= not RX_Data;
		else
			Data_insert <= RX_Data;
		end if;
	end process;

-- Parallel FCS setup
	process(clk,reset)
	Begin
		elsif rising_edge(clk) then
			
			--Reset and count control 
			if (Reset = '1') then -- reset the registor and Counter
				Reg     <= (others => '0');
      				Counter <= (others => '0');
				Count_payload <= (others => '0');
			elsif (Rx_Valid = '1') then  
				Counter <= (others => '0');
				Count_payload <= (others => '0');
			elsif(Counter < 21) then 		 
				Counter <= Counter + 1;
			elsif (Count_payload < payload_lenght + 4) then
				Count_payload <= Count_payload + 1;
			else
				Checksum_Start <= '1';
			end if;
			
			--Saveing the values of the 
			
			


			--Register for the FCS Check
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
					
			--Checking if the FCS value matches the 
			if (Checksum_Start = '1' and Counter = 3) then
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




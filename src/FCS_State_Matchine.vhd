---------------------------------------------------------------------
-- Componant:   FCS_State_Machine 
-- Description: This is a statemachine which task is to control the 
--              entire FCS block       
-- Made by :    Hákon Hlynsson
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FCS_State_Machine is
    port (
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
end FCS_State_Machine;

architecture behavioral of FCS_State_Machine is
    type state_type is (IDLE, Preamble,Start_Frame,Destionation_MAC,Source_MAC, Ethernet_Length,Payload,FCS,Dummy);
    signal current_state, next_state : state_type;
    
    -- Changed from std_logic_vector to unsigned for arithmetic operations
    signal Payload_Length : unsigned(10 downto 0);
    signal Counter      : unsigned(11 downto 0);
    
    signal Counter_En   : std_logic;
    signal Done_Reg     : std_logic;
begin

    -- Counter logic (Synchronous)  
    Logic_counter: process(Rx_Clk, Reset)
    begin
        if rising_edge(Rx_Clk) then
            if (Reset = '1' or Done_Reg = '1') then 
                Counter <= (Others => '0');
            elsif (Counter_En = '1') then
                Counter <= Counter + 1; 
            end if;
        end if;
    end process;

    -- State Register (Synchronous)
    SYNC_PROC: process(Rx_Clk, Reset)
    begin
        if Reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(Rx_Clk) then
            current_state <= next_state;
        end if;
    end process;


    -- Next State & Output Logic
    com: process(current_state,Rx_Valid,Rx_Data,Counter,Payload_Length)
    begin

        next_state <= current_state; 
    	Counter_En <= '1'; 
    	Done_Reg   <= '0';
    	Dst_En     <= '0';
    	Src_En     <= '0';
    	FCS_En     <= '0';

        case current_state is

            when IDLE =>
		Counter_En <= '0';
                if  Rx_Data = X"AA" then
                    Counter_En <= '1';
                    next_state <= Preamble;
                end if;

            when Preamble =>
		
                if Rx_Data /= X"AA" then 
                    next_state <= IDLE;  
                elsif Rx_Data = X"AA" and Counter = 6 then
                    next_state <= Start_Frame;
                end if;
            
            when Start_Frame =>

                if Rx_Data = X"AB" and Counter = 7 then 
                    next_state <= Destionation_MAC;
                else 
                    next_state <= IDLE;   
                end if; 
            
            when Destionation_MAC =>
                Dst_En <= '1';
                if Counter = 13 then 
                    Dst_En <= '0'; 
                    next_state <= Source_MAC;
                end if;    
            
            when Source_MAC =>
                Src_En <= '1';
                if Counter = 19 then 
                    Src_En <= '0'; 
                    next_state <= Ethernet_Length;
                end if; 

            when Ethernet_Length =>
                if Counter = 20 then 
                    Payload_Length(10 downto 8) <= unsigned(Rx_Data(2 downto 0)); 
                elsif Counter = 21 then 
                    Payload_Length(7 downto 0) <= unsigned(Rx_Data(7 downto 0));
                    next_state <= Payload;
                end if;

            when Payload =>  
                if Counter = (21 + Payload_Length) then 
                    next_state <= FCS;
                end if;

            when FCS =>
                FCS_En <= '1';  
                if Counter = (25 + Payload_Length) then
                    FCS_En <= '0';
                    next_state <= Dummy;
                end if;

            when Dummy =>
                if Counter = (37 + Payload_Length) then 
                    Done_Reg <= '1'; -- Safely resets the counter for the next frame
                    next_state <= IDLE;
                end if;
                    
            when others =>
                next_state <= IDLE;
        end case;
    end process;
end architecture;

---------------------------------------------------------------------
-- Componant:   FCS_State_Machine 
-- Description: This is a statemachine which task is to control the 
--	        	entire FCS block 	   
-- Changes	:
--  		HH 20/3: creation of document and I/O and inserted basic state machine
--          HH 23/2: change the parameters so that the machine maches our design
---------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FCS_State_Machine is
    port (
        -- Input 
        Reset           : in    std_logic;
        Rx_Clk          : in    std_logic;
        Rx_Data         : in    std_logic_vector(7 downto 0);
        Rx_Valid        : in    std_logic;
        -- Output
        Dst_En          : out   std_logic;
        Src_En          : out   std_logic;
        Eth_En          : out   std_logic;
        Pay_En          : out   std_logic;
        Length_Payload  : out   std_logic_vector(10 downto 0);
        FCS_En          : out   std_logic;
        FCS_check       : out   std_logic
    );
end FCS_State_Machine;

architecture behavioral of FCS_State_Machine is
    type state_type is (IDLE, Praemble,Start_Frame,Destionation_MAC,Source_MAC, Ethernet_Length,Payload,FCS,Dummy);
    signal current_state, next_state : state_type;
    signal Counter      : std_logic_vector(11 downto 0);
    signal Counter_En   : std_logic;
    signal Done_Reg     : std_logic;
begin

    -- Counter logic  
    count: process(Rx_Clk, Reset, Counter_En)
    begin
        if rising_edge(Rx_Clk) then
            if (Reset = '1' or Done_Reg= '1') then --setting the counter in case of a reset or finished messege
                Counter <= (Others => '0');
            elsif (Counter_En = '1') then
                Counter <= Counter + 0x001; --adding to counter 
            end if;
        end if;
    end process;

    -- Makes the next state the current state
    sync: process(Rx_Clk, Reset)
    begin
        if rising_edge(Rx_Clk) then
            if (Reset = '1') then
                current_state <= IDLE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;


    -- This determines the next depending on the inputs as well as setting outputs
    com: process(current_state, Rx_Valid,Rx_Data,Counter)
    begin
        next_state <= current_state; -- Should be default stay in current state

        case current_state is

            when IDLE =>
                Counter_En = '0';
                if Rx_Valid = '1' and Rx_Data = 0xAA then
                    Counter_En = '1';
                    next_state <= Preamble;
                end if;

            when Praemble =>
                if Rx_Data /= 0xAA then 
                    next_state <= IDLE;   
                elsif Rx_Data= 0xAA and Counter > 5 then
                    next_state <= Start_Frame;
                end if;
            
            when Start_Frame =>
                if Rx_Data /= 0xAB then 
                    next_state <= IDLE;   
                else Rx_Data= 0xAB and Counter > 6 then
                    next_state <= Destionation_MAC;
                end if; 
            
            when Destionation_MAC =>
                Dst_En <= '1';
                if count = 13 then
                    Dst_En <= '0'; 
                    next_state <= Source_MAC;
                end if;    
            
            when Source_MAC =>
                Src_En <= '1';
                if count = 19 then
                    Src_En <= '0'; 
                    next_state <= Ethernet_Length;
                end if; 

            when Ethernet_Length =>
                Eth_En <= '1';
                if count = 21
                    Eth_En <= '0';
                    next_state <= Payload;
                end if;

            when Payload =>
                Pay_En <= '1';   
                if count =(21+Length_Payload) then
                    Pay_En <= '0';
                    next_state <= FCS;
                end if;

            when FCS =>
                FCS_En <= '1';  
                if count =(25+Length_Payload) then
                    FCS_En <= '0';
                    FCS_check <= '1'
                    next_state <= Dummy;
                end if;

            when Dummy =>
                if count =(26+Length_Payload) then
                    FCS_check <= '0'
                elsif count =(37+Length_Payload) then 
                    next_state <= IDLE;
                end if;
                   
            when others =>
                next_state <= IDLE;
        end case;
    end process;
end architecture;




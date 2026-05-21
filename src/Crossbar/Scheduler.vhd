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

        Package_Length_1 : in  std_logic_vector(10 downto 0);
        Package_Length_2 : in  std_logic_vector(10 downto 0);
        Package_Length_3 : in  std_logic_vector(10 downto 0);
        Package_Length_4 : in  std_logic_vector(10 downto 0);

        -- Output
        Enable_Out_1 : out std_logic;
        Enable_Out_2 : out std_logic;
        Enable_Out_3 : out std_logic;
        Enable_Out_4 : out std_logic;

        Select_FIFO_1   : out std_logic_vector(1 downto 0);-- select signal for FIFO 1
        Select_FIFO_2   : out std_logic_vector(1 downto 0);-- select signal for FIFO 2
        Select_FIFO_3   : out std_logic_vector(1 downto 0);-- select signal for FIFO 3
        Select_FIFO_4   : out std_logic_vector(1 downto 0);-- select signal for FIFO 4
    );
end Scheduler;

architecture behavioral of Scheduler is
    --Signals



Signal busy_port_1 : std_logic; -- signal to keep track if FIFO 1 is in use
Signal busy_port_2 : std_logic; -- signal to keep track if FIFO 2 is in use
Signal busy_port_3 : std_logic; -- signal to keep track if FIFO 3 is in use
Signal busy_port_4 : std_logic; -- signal to keep track if FIFO 4 is in use

Signal FIFO_FCS1_Port1  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 1
Signal FIFO_FCS1_Port2  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 2
Signal FIFO_FCS1_Port3  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 3
Signal FIFO_FCS1_Port4  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 4
Signal FIFO_FCS2_Port1  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 1
Signal FIFO_FCS2_Port2  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 2
Signal FIFO_FCS2_Port3  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 3
Signal FIFO_FCS2_Port4  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 4
Signal FIFO_FCS3_Port1  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 1
Signal FIFO_FCS3_Port2  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 2
Signal FIFO_FCS3_Port3  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 3
Signal FIFO_FCS3_Port4  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 4
Signal FIFO_FCS4_Port1  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 1
Signal FIFO_FCS4_Port2  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 2
Signal FIFO_FCS4_Port3  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 3
Signal FIFO_FCS4_Port4  : std_logic_vector(11 downto 0); -- signal to keep track of how many packages are in FIFO 4

begin

 
-- Insert into ques to keep track of how much is inside each of the 16 FIFOs
queue_insert process(Tx_Clk, Reset)

    -- prev_enable
    signal Prev_En_Port_1 : std_logic := '0'; -- signal to keep track of previous enable state for port 1
    signal Prev_En_Port_2 : std_logic := '0'; -- signal to keep track of previous enable state for port 2
    signal Prev_En_Port_3 : std_logic := '0'; -- signal to keep track of previous enable state for port 3
    signal Prev_En_Port_4 : std_logic := '0'; -- signal to keep track of previous enable state for port 4

    begin

    if rising_edge(Tx_Clk) then
        if Reset = '1' then
            Prev_En_Port_1 <= '0';
            Prev_En_Port_2 <= '0';
            Prev_En_Port_3 <= '0';
            Prev_En_Port_4 <= '0';
           
        else 
            if (En_Port_1 = '1' and Prev_En_Port_1 = '0') then 
                -- insert into queue 1
            if (En_Port_2 = '1' and Prev_En_Port_2 = '0') then 
                -- insert into queue 2
            if (En_Port_3 = '1' and Prev_En_Port_3 = '0') then 
                -- insert into queue 3
            if (En_Port_4 = '1' and Prev_En_Port_4 = '0') then 
                -- insert into queue 4

        end if;



        -- update previous enable signals
        Prev_En_Port_1 <= En_Port_1;
        Prev_En_Port_2 <= En_Port_2;
        Prev_En_Port_3 <= En_Port_3;
        Prev_En_Port_4 <= En_Port_4;
    end if;





end process;

-- Based on what is inside the queues the scheduler will decide which FIFO to read from and send to the crossbar.
Queue_Read process(Tx_Clk, Reset)
begin
if rising_edge(Tx_Clk) then
    if (busy_port_1 ='1') then 
        --no changes to port 1 
    if (busy_port_2 ='1') then 
        --no changes to port 2
    if (busy_port_3 ='1') then
        --no changes to port 3
    if (busy_port_4 ='1') then
        --no changes to port 4
    else 

    end if;
end if;



end process;





end behavioral;

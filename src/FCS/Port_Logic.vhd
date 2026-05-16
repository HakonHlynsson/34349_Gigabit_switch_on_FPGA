---------------------------------------------------------------------
-- Component:    Port_Logic
-- Description:  Accepts destination-port + packet-length pairs from
--               MAC learning and queues them in an internal FIFO.
--               For each queued entry the output En_Data_out is
--               asserted high and Dst_Port_out is driven with the
--               stored port value for exactly Package_Length clock
--               cycles, after which the next entry is served.
--
--
-- Made by:      Hákon Hlynsson
---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Port_Logic is
    port (
        -- Input
        Reset          : in  std_logic;
        Tx_Clk         : in  std_logic;
        En_Port_in     : in  std_logic;
        Dst_Port_in    : in  std_logic_vector(2 downto 0);
        Package_Length : in  std_logic_vector(10 downto 0);
        -- Output
        En_Data_out    : out std_logic;
        Dst_Port_out   : out std_logic_vector(2 downto 0)
    );
end Port_Logic;

architecture behavioral of Port_Logic is


    constant QUEUE_DEPTH : integer := 24; -- Maximum size given long package followed by many of the smallest one.

    -- Creating a type that includes Port and package length
    type queue_entry_t is record
        dst_port   : std_logic_vector(2 downto 0);
        pkg_length : unsigned(10 downto 0);
    end record;

   -- Creating an array as the queue 
    type queue_array_t is array (0 to QUEUE_DEPTH - 1) of queue_entry_t;

    -- Signals
    signal queue       : queue_array_t;
    signal wr_ptr      : integer range 0 to QUEUE_DEPTH - 1 := 0; -- write pointer
    signal rd_ptr      : integer range 0 to QUEUE_DEPTH - 1 := 0; -- Read pointer 
    signal queue_count : integer range 0 to QUEUE_DEPTH     := 0; -- 

    -- Output control
    signal clk_counter : unsigned(10 downto 0) := (others => '0');-- Counts number of clk cycles inn package
    signal busy        : std_logic             := '0'; 		  -- Goes high if the clk counter is in use  

begin

    -------------------------------------------------------------------
    -- Queue_Insert:
    -- Writes (Dst_Port_in, Package_Length) into the queue when a rising edge of En_Port_in orccurs,
    -- given that the queue is not full
    -------------------------------------------------------------------
    Queue_Insert : process(Tx_Clk)
    begin
        if rising_edge(Tx_Clk) then
            if Reset = '1' then
                wr_ptr <= 0;
            elsif En_Port_in = '1' and queue_count < QUEUE_DEPTH then
                queue(wr_ptr).dst_port   <= Dst_Port_in;
                queue(wr_ptr).pkg_length <= unsigned(Package_Length);
                
		-- write pointer increament (wrap around)
                if wr_ptr = QUEUE_DEPTH - 1 then 
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;
                end if;
            end if;
        end if;
    end process Queue_Insert;

    -------------------------------------------------------------------
    -- Queue_Read: Read the queue and set the outputs

    -- 
    -------------------------------------------------------------------
    Queue_Read : process(Tx_Clk)

        variable Add_To_Queue 		: boolean; -- Add to queue
        variable Remove_From_Queue 	: boolean; -- Remove from the queue

    begin
        if rising_edge(Tx_Clk) then
            if Reset = '1' then -- reset 
                rd_ptr       <= 0; 
                queue_count  <= 0;
                clk_counter  <= (others => '0');
                busy         <= '0';
                En_Data_out  <= '0';
                Dst_Port_out <= (others => '0');
            else

                Add_To_Queue := (En_Port_in = '1') and (queue_count < QUEUE_DEPTH); -- logic for adding to queue
                Remove_From_Queue := false;


                if busy = '1' then -- if currently in transmission(counting remaining cycles)
                    if clk_counter > 0 then
                        clk_counter <= clk_counter - 1;
                    else -- Done counting 
                        busy         <= '0';
                        En_Data_out  <= '0';
                        Dst_Port_out <= (others => '0');
                    end if;

                elsif queue_count > 0 then -- if queue is not empty(haven't startet on next transmision) 
                    En_Data_out  <= '1';
                    Dst_Port_out <= queue(rd_ptr).dst_port;
                    clk_counter  <= queue(rd_ptr).pkg_length - 1;
                    busy         <= '1';

                    -- Read pointer increament (wrap around)
                    if rd_ptr = QUEUE_DEPTH - 1 then
                        rd_ptr <= 0;
                    else
                        rd_ptr <= rd_ptr + 1;
                    end if;
                    Remove_From_Queue := true;
                end if;

                --Trancking number of packages in queue
                if Add_To_Queue and not Remove_From_Queue then
                    queue_count <= queue_count + 1;
                elsif Remove_From_Queue and not Add_To_Queue then
                    queue_count <= queue_count - 1;
                end if;

            end if;
        end if;
    end process Queue_Read;

end behavioral;
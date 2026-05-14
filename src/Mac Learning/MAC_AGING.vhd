library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MAC_PKG.all;

entity MAC_AGING is
    port (
        clk     : in std_logic;
        reset   : in std_logic; -- Active-high synchronous reset
        
        -- Inputs
        rdData  : in STD_LOGIC_VECTOR (211 DOWNTO 0);
        
        -- Outputs
        wren    : out std_logic;
        rden    : out std_logic;
        wrData  : out STD_LOGIC_VECTOR (211 DOWNTO 0);
        rdAddr  : out STD_LOGIC_VECTOR (10 DOWNTO 0);
        wrAddr  : out STD_LOGIC_VECTOR (10 DOWNTO 0)
    );
end entity MAC_AGING;

architecture Behavioral of MAC_AGING is

    -- Internal signal, type, and constant declarations
    signal counter : unsigned(1 downto 0) := (others => '0');

    type t_state is (IDLE, READ, WAIT_READ, UNPACK, EDIT, WRITE);

    signal currentState : t_state := IDLE;

    signal currentAddr : unsigned(10 downto 0) := (others => '0');
    signal newRow : t_bram_row;
    signal oldRow : t_bram_row;

begin

    -- Main synchronous process
    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= (others => '0');
                wren <= '0';
                rden <= '0';
                rdAddr <= (others => '0');
                wrAddr <= (others => '0');
                wrData <= (others => '0');
                currentState <= IDLE;
                currentAddr <= (others => '0');
            else
                wren <= '0';
                rden <= '0';

                counter <= counter + 1;

                case currentState is
                    when IDLE =>
                        -- if counter = "111111111" then
			if counter = "11" then
			    counter <= (others => '0'); 
                            currentState <= READ;
                        end if;

                    when READ =>
                        currentState <= WAIT_READ;

                        -- Set read address and read enable
                        rden <= '1';
                        rdAddr <= std_logic_vector(currentAddr);

                    when WAIT_READ =>
                        currentState <= UNPACK;

                    when UNPACK =>
                        currentState <= EDIT;
                        -- Unpack data
                        -- Put data in new temps (newRow, oldrow)
                        newRow <= unpack_bram_row(rdData);
                        oldRow <= unpack_bram_row(rdData);
                        
                    when EDIT =>
                        currentState <= WRITE;
                        -- Check accessed flags. 
                        -- If they are '1', set accessed = '0'
                        -- Else set valid = '0'
                        l_check_acc : for i in 0 to 3 loop
                            if oldRow(i).accessed = '1' then
                                newRow(i).accessed <= '0';
                            else
                                newRow(i).valid <= '0';
                            end if;                        
                        end loop l_check_acc;

                    when WRITE =>
                        currentState <= IDLE;
                        -- Pack data
                        wrData <= pack_bram_row(newRow);

                        -- Set write address, write data, and write enable
                        wrAddr <= std_logic_vector(currentAddr);
                        wren <= '1';

                        currentAddr <= currentAddr + 1;
                end case;
            end if;
        end if;
    end process;
    -- Concurrent signal assignments or instantiations

end architecture Behavioral;
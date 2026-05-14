library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MAC_PKG.all;

entity MAC_ENGINE is
    port (
        clk      : in  std_logic;
        reset   : in std_logic; -- Active-high synchronous reset
        
        -- Inputs
        -- BRAM Input
        rdData  : in STD_LOGIC_VECTOR (211 DOWNTO 0);
        -- Arbiter Inputs
        dstMac  : in t_mac_addr;
        srcMac  : in t_mac_addr;
        srcPortIn : in t_port_id;
        EN : in std_logic;

        
        -- Outputs
        -- BRAM Outputs
        wren    : out std_logic;
        rden    : out std_logic;
        wrData  : out STD_LOGIC_VECTOR (211 DOWNTO 0);
        rdAddr  : out STD_LOGIC_VECTOR (10 DOWNTO 0);
        wrAddr  : out STD_LOGIC_VECTOR (10 DOWNTO 0);
        -- Arbiter Outputs
        srcPortOut : out t_port_id;
        dstPort : out t_port_id;
        done    : out std_logic

    );
end entity MAC_ENGINE;

architecture Behavioral of MAC_ENGINE is

    -- Internal signal, type, and constant declarations
    type t_state is (IDLE, READ_SRC, WAIT_SRC_1, WAIT_SRC_2, CHECK_SRC, WRITE_SRC, READ_DST, WAIT_DST_1, WAIT_DST_2, CHECK_DST, WRITE_DST);

    signal currentState : t_state := IDLE;

    signal reg_dstMac : t_mac_addr;
    signal reg_srcMac : t_mac_addr;
    signal reg_srcPort : t_port_id;

    signal hash_dstMac : std_logic_vector(10 downto 0) := (others => '0');
    signal hash_srcMac : std_logic_vector(10 downto 0) := (others => '0');

    signal random_counter : unsigned(1 downto 0) := "00";

begin

    -- Main synchronous process
    process(clk)
        variable v_row : t_bram_row;
        variable v_found : boolean;
        variable v_slot_id : integer range 0 to 3;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Reset logic: clear registers
                currentState <= IDLE;

                wren <= '0';
                rden <= '0';
                rdAddr <= (others => '0');
                wrAddr <= (others => '0');
                wrData <= (others => '0');
                done <= '0';
                hash_dstMac <= (others => '0');
                hash_srcMac <= (others => '0');
                random_counter <= "00";
            else
                -- Sequential logic
                done <= '0';
                wren <= '0';
                rden <= '0';

                random_counter <= random_counter + 1;

                case currentState is
                    when IDLE =>
                        if EN = '1' then
                            currentState <= READ_SRC;
                            reg_dstMac <= dstMac;
                            reg_srcMac <= srcMac;
                            reg_srcPort <= srcPortIn;
                            srcPortOut <= srcPortIn;

                            hash_dstMac <= calc_hash(dstMac);
                            hash_srcMac <= calc_hash(srcMac);
                        else
                            currentState <= IDLE;
                        end if;

                    when READ_SRC =>
                        currentState <= WAIT_SRC_1;
                        
                        rden <= '1';
                        rdAddr <= hash_srcMac;

                    when WAIT_SRC_1 =>
                        currentState <= WAIT_SRC_2;

		    when WAIT_SRC_2 =>
			currentState <= CHECK_SRC;

                    when CHECK_SRC =>
                        currentState <= WRITE_SRC;

                        v_row := unpack_bram_row(rdData);
                        v_found := false;
                        -- Check if srcMac exists
                        --  If yes, set .accessed = '1' 
                        --  If not, save mac in hashed index with srcPort
                        --    Check if row is full
                        --      If not, save to available spot
                        --      If full, save to random spot

                        for i in 0 to 3 loop
                            if v_row(i).valid = '1' and v_row(i).mac_addr = reg_srcMac then
                                v_row(i).accessed := '1';
                                v_row(i).port_id := reg_srcPort;
                                v_found := true;
                                exit; -- Exit the loop if the address was found
                            end if;
                        end loop;

                        if not v_found then
                            v_slot_id := to_integer(random_counter); -- Sets a random slot to be overwritten in case no slots are free

                            for i in 0 to 3 loop
                                if v_row(i).valid = '0' then
                                    v_slot_id := i;
                                    exit;
                                end if;
                            end loop;

                            -- Insert the source mac in the row
                            v_row(v_slot_id).valid := '1';
                            v_row(v_slot_id).mac_addr := reg_srcMac;
                            v_row(v_slot_id).port_id := reg_srcPort;
                            v_row(v_slot_id).accessed := '1';
                        end if;

                        wrData <= pack_bram_row(v_row);    

                    when WRITE_SRC =>
                        currentState <= READ_DST;

                        -- Write to BRAM

                        wrAddr <= hash_srcMac;
                        wren <= '1';

                    when READ_DST =>
                        currentState <= WAIT_DST_1;

                        rden <= '1';
                        rdAddr <= hash_dstMac;

                    when WAIT_DST_1 =>
                        currentState <= WAIT_DST_2;

		    when WAIT_DST_2 =>
			currentState <= CHECK_DST;

                    when CHECK_DST =>
                        currentState <= WRITE_DST;

                        v_row := unpack_bram_row(rdData);
                        v_found := false;

                        -- Check if dstMac exists
                        --  If yes, set dstPort = saved port and .accessed = '1'
                        --  If not, set dstPort = '111'
                        for i in 0 to 3 loop
                            if v_row(i).valid = '1' and v_row(i).mac_addr = reg_dstMac then
                                dstPort <= v_row(i).port_id;
                                v_row(i).accessed := '1';
                                v_found := true;
                                exit;
                            end if;
                        end loop;

                        if not v_found then
                            dstPort <= "111";
                        end if;

                        wrData <= pack_bram_row(v_row);

                    when WRITE_DST =>
                        currentState <= IDLE;

                        -- Write to BRAM
                        wrAddr <= hash_dstMac;
                        wren <= '1';

                        -- Return dstPort and srcPort
                        done <= '1';

                end case;
            end if;
        end if;
    end process;

    -- Concurrent signal assignments or instantiations

end architecture Behavioral;
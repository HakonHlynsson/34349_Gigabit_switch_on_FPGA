library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MAC_PKG.all;

entity MAC_ARBITER is
    port (
        clk      : in  std_logic;
        reset      : in  std_logic; -- Active-high synchronous reset
        
        -- Inputs
        port_EN : in t_flag_array;
        port_dstMac : in t_mac_array;
        port_srcMac : in t_mac_array;
        engine_srcPortIn : in t_port_id;
        engine_dstPort : in t_port_id;
        engine_done : in std_logic;
        
        -- Outputs
        port_dstPort : out t_port_array;
        port_done : out t_flag_array;
        engine_dstMac : out t_mac_addr;
        engine_srcMac : out t_mac_addr;
        engine_srcPortOut : out t_port_id;
        engine_EN : out std_logic
    );
end entity MAC_ARBITER;

architecture Behavioral of MAC_ARBITER is

    -- Internal signal, type, and constant declarations
    signal hold_EN : t_flag_array;
    signal hold_dstMac : t_mac_array;
    signal hold_srcMac : t_mac_array;

    signal token : unsigned(1 downto 0) := "00";

    type t_state is (SCANNING, GRANTED, WAITING_FOR_ENGINE);
    signal currentState : t_state := SCANNING;

begin

    -- Main synchronous process
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Reset logic: clear registers
                token <= "00";
                hold_EN <= (others => '0');
                port_done <= (others => '0');
                engine_EN <= '0';
                
            else
                -- Sequential logic
                engine_EN <= '0';
                port_done <= (others => '0');
                -- Check port inputs
                for i in 0 to 3 loop
                    if port_EN(i) = '1' then
                        hold_EN(i) <= '1';
                        hold_dstMac(i) <= port_dstMac(i);
                        hold_srcMac(i) <= port_srcMac(i);
                    end if;
                end loop;

                -- State machine
                case currentState is
                    when SCANNING =>
                        if hold_EN(to_integer(token)) = '1' then
                            currentState <= GRANTED;
                        else
                            token <= token + 1;
                        end if; 
                    when GRANTED =>
                        currentState <= WAITING_FOR_ENGINE;

                        engine_EN <= '1';
                        engine_dstMac <= hold_dstMac(to_integer(token));
                        engine_srcMac <= hold_srcMac(to_integer(token));
                        engine_srcPortOut <= "0" & std_logic_vector(token);
                    when WAITING_FOR_ENGINE =>
                        if engine_done = '1' then
                            currentState <= SCANNING;

                            port_dstPort(to_integer(token)) <= engine_dstPort;
                            port_done(to_integer(token)) <= '1';

                            hold_EN(to_integer(token)) <= '0';
                            token <= token + 1;
                        end if;
                        
                end case;
            end if;
        end if;
    end process;

    -- Concurrent signal assignments or instantiations

end architecture Behavioral;
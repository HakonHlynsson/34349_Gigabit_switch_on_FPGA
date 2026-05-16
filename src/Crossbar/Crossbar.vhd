---------------------------------------------------------------------
-- Componant  : Crossbar
-- Description: 4 x 4 non-blocking crossbar with 8-bit data paths.
--              Each output is a 4-to-1 mux over the four inputs.
--              Pure combinational - no clock.
--
--              Select_S is provided by the Scheduler and is packed
--              as four 2-bit fields, one per output:
--                  Select_S(1 downto 0) -> source for Tx_Data1
--                  Select_S(3 downto 2) -> source for Tx_Data2
--                  Select_S(5 downto 4) -> source for Tx_Data3
--                  Select_S(7 downto 6) -> source for Tx_Data4
--              The 2-bit value picks Port1..Port4 (00 = Port1,
--              01 = Port2, 10 = Port3, 11 = Port4).
--
-- Made by    : Hakon Hlynsson
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Crossbar is
    port (
        -- Data inputs from the four VOQs
        Port1_in : in  std_logic_vector(7 downto 0);
        Port2_in : in  std_logic_vector(7 downto 0);
        Port3_in : in  std_logic_vector(7 downto 0);
        Port4_in : in  std_logic_vector(7 downto 0);

        -- Per-output 2-bit select line from the Scheduler (4 x 2 = 8)
        Select_S : in  std_logic_vector(7 downto 0);

        -- Data outputs to the four Tx ports
        Tx_Data1 : out std_logic_vector(7 downto 0);
        Tx_Data2 : out std_logic_vector(7 downto 0);
        Tx_Data3 : out std_logic_vector(7 downto 0);
        Tx_Data4 : out std_logic_vector(7 downto 0)
    );
end Crossbar;

architecture behavioral of Crossbar is
    -- Internal array so the four muxes can be built with a generate loop.
    type port_array_t is array (0 to 3) of std_logic_vector(7 downto 0);
    signal in_array  : port_array_t;
    signal out_array : port_array_t;
begin

    -- Pack the discrete input ports into an indexable array
    in_array(0) <= Port1_in;
    in_array(1) <= Port2_in;
    in_array(2) <= Port3_in;
    in_array(3) <= Port4_in;

    -- Four 4-to-1 muxes, one per output, controlled by its 2-bit selector
    Mux_Gen : for j in 0 to 3 generate
        out_array(j) <= in_array(
            to_integer( unsigned( Select_S((j*2)+1 downto j*2) ) )
        );
    end generate;

    -- Unpack the array back to discrete output ports
    Tx_Data1 <= out_array(0);
    Tx_Data2 <= out_array(1);
    Tx_Data3 <= out_array(2);
    Tx_Data4 <= out_array(3);

end behavioral;

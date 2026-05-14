library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package MAC_PKG is

    -- Constants
    constant C_MAC_WIDTH : integer := 48;
    constant C_PORT_WIDTH : integer := 3;
    constant C_NUM_PORTS : integer := 4;

    constant C_SLOT_WIDTH : integer := 53;
    constant C_ROW_WIDTH : integer := 212;

    constant C_BROADCAST_PORT : std_logic_vector(C_PORT_WIDTH-1 downto 0) := "111";

    -- Types
    subtype t_mac_addr is std_logic_vector(C_MAC_WIDTH-1 downto 0);
    subtype t_port_id is std_logic_vector(C_PORT_WIDTH-1 downto 0);

    -- Record representing a single slot in a row
    type t_bram_slot is record
        valid : std_logic;
        mac_addr : t_mac_addr;
        port_id : t_port_id;
        accessed : std_logic;
    end record t_bram_slot;

    type t_mac_array is array(0 to C_NUM_PORTS-1) of t_mac_addr;
    type t_port_array is array(0 to C_NUM_PORTS-1) of t_port_id;
    type t_flag_array is array(0 to C_NUM_PORTS-1) of std_logic;

    -- Type representing a full row in BRAM
    type t_bram_row is array (0 to 3) of t_bram_slot;

    -- Functions
    function pack_bram_row(row : t_bram_row) return std_logic_vector;

    function unpack_bram_row(data : std_logic_vector) return t_bram_row;

    function pack_slot(slot : t_bram_slot) return std_logic_vector;

    function calc_hash(mac : t_mac_addr) return std_logic_vector;


end package MAC_PKG;

package body MAC_PKG is

    function pack_slot(slot : t_bram_slot) return std_logic_vector is
        variable data : std_logic_vector(C_SLOT_WIDTH-1 downto 0);
    begin
        data(52) := slot.valid;
        data(51 downto 4) := slot.mac_addr;
        data(3 downto 1) := slot.port_id;
        data(0) := slot.accessed;
        return data;
    end function pack_slot;

    function pack_bram_row(row : t_bram_row) return std_logic_vector is 
        variable row_data : std_logic_vector(C_ROW_WIDTH-1 downto 0);
    begin
        row_data(52 downto 0) := pack_slot(row(0));
        row_data(105 downto 53) := pack_slot(row(1));
        row_data(158 downto 106) := pack_slot(row(2));
        row_data(211 downto 159) := pack_slot(row(3));
        return row_data;
    end function pack_bram_row;

    function unpack_bram_row(data : std_logic_vector) return t_bram_row is
        variable row : t_bram_row;
    begin
        for i in 0 to 3 loop
            row(i).valid := data((i*C_SLOT_WIDTH)+52);
            row(i).mac_addr := data((i*C_SLOT_WIDTH)+51 downto (i*C_SLOT_WIDTH)+4);
            row(i).port_id := data((i*C_SLOT_WIDTH)+3 downto (i*C_SLOT_WIDTH)+1);
            row(i).accessed := data(i*C_SLOT_WIDTH);
        end loop;
        return row;
    end function unpack_bram_row;

    function calc_hash(mac : t_mac_addr) return std_logic_vector is
        variable v_hash : std_logic_vector(10 downto 0);
    begin
        v_hash := mac(10 downto 0) xor
                  mac(21 downto 11) xor
                  mac(32 downto 22) xor
                  mac(43 downto 33) xor
                  ("0000000" & mac(47 downto 44));
        return v_hash;
    end function calc_hash;
end package body MAC_PKG;
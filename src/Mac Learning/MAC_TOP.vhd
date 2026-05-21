---------------------------------------------------------------------
-- Componant:   MAC_TOP
-- Description: The top module for the MAC learning.
-- Made by:    Mikkel Svendsen
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MAC_PKG.all;

entity MAC_TOP is
    generic (
        DATA_WIDTH : integer := 16 -- Adjust default data width as needed
    );
    port (
        clk      : in  std_logic;
        reset      : in  std_logic;
        
        -- Port 0
        port0_EN      : in  std_logic;
        port0_dstMac  : in  std_logic_vector(47 downto 0);
        port0_srcMac  : in  std_logic_vector(47 downto 0);
        port0_dstPort : out std_logic_vector(2 downto 0);
        port0_done    : out std_logic;

        -- Port 1
        port1_EN      : in  std_logic;
        port1_dstMac  : in  std_logic_vector(47 downto 0);
        port1_srcMac  : in  std_logic_vector(47 downto 0);
        port1_dstPort : out std_logic_vector(2 downto 0);
        port1_done    : out std_logic;

        -- Port 2
        port2_EN      : in  std_logic;
        port2_dstMac  : in  std_logic_vector(47 downto 0);
        port2_srcMac  : in  std_logic_vector(47 downto 0);
        port2_dstPort : out std_logic_vector(2 downto 0);
        port2_done    : out std_logic;

        -- Port 3
        port3_EN      : in  std_logic;
        port3_dstMac  : in  std_logic_vector(47 downto 0);
        port3_srcMac  : in  std_logic_vector(47 downto 0);
        port3_dstPort : out std_logic_vector(2 downto 0);
        port3_done    : out std_logic
    );
end entity MAC_TOP;

architecture Behavioral of MAC_TOP is

    -- Internal signal declarations
    signal sig_EN : t_flag_array;
    signal sig_dstMac : t_mac_array;
    signal sig_srcMac : t_mac_array;
    
    -- Outputs
    signal sig_dstPort : t_port_array;
    signal sig_done : t_flag_array;

    
    -- Aribter - Engine signals
    signal sig_engine_EN : std_logic;
    signal sig_engine_dstMac : t_mac_addr;
    signal sig_engine_srcMac : t_mac_addr;
    signal sig_engine_srcPortIn : t_port_id;
    signal sig_engine_srcPortOut : t_port_id;
    signal sig_engine_dstPort : t_port_id;
    signal sig_engine_done : std_logic;

    -- Engine - BRAM signals
    signal sig_rden_A : std_logic;
    signal sig_wren_A : std_logic;
    signal sig_wrAddr_A : std_logic_vector(10 downto 0);
    signal sig_rdAddr_A : std_logic_vector(10 downto 0);
    signal sig_wrData_A : std_logic_vector(211 downto 0);
    signal sig_rdData_A : std_logic_vector(211 downto 0);

    -- Aging - BRAM signals
    signal sig_rden_B : std_logic;
    signal sig_wren_B : std_logic;
    signal sig_wrAddr_B : std_logic_vector(10 downto 0);
    signal sig_rdAddr_B : std_logic_vector(10 downto 0);
    signal sig_wrData_B : std_logic_vector(211 downto 0);
    signal sig_rdData_B : std_logic_vector(211 downto 0);

    -- Shared BRAM signals
    signal sig_bram_addr_A : std_logic_vector(10 downto 0);
    signal sig_bram_addr_B : std_logic_vector(10 downto 0);


begin

    sig_EN(0) <= port0_EN;
    sig_EN(1) <= port1_EN;
    sig_EN(2) <= port2_EN;
    sig_EN(3) <= port3_EN;

    sig_dstMac(0) <= port0_dstMac;
    sig_dstMac(1) <= port1_dstMac;
    sig_dstMac(2) <= port2_dstMac;
    sig_dstMac(3) <= port3_dstMac;

    sig_srcMac(0) <= port0_srcMac;
    sig_srcMac(1) <= port1_srcMac;
    sig_srcMac(2) <= port2_srcMac;
    sig_srcMac(3) <= port3_srcMac;

    port0_dstPort <= sig_dstPort(0);
    port1_dstPort <= sig_dstPort(1);
    port2_dstPort <= sig_dstPort(2);
    port3_dstPort <= sig_dstPort(3);

    port0_done <= sig_done(0);
    port1_done <= sig_done(1);
    port2_done <= sig_done(2);
    port3_done <= sig_done(3);

    -- BRAM Address multiplexers
    sig_bram_addr_A <= sig_wrAddr_A when sig_wren_A = '1' else sig_rdAddr_A;
    sig_bram_addr_B <= sig_wrAddr_B when sig_wren_B = '1' else sig_rdAddr_B;

    U_ARBITER : entity work.MAC_ARBITER
        port map (
            clk             => clk,
            reset           => reset,

            port_EN         => sig_EN,
            port_dstMac     => sig_dstMac,
            port_srcMac     => sig_srcMac,

            engine_srcPortIn => sig_engine_srcPortOut,

            engine_dstPort  => sig_engine_dstPort,
            engine_done     => sig_engine_done,

            port_dstPort    => sig_dstPort,
            port_done       => sig_done,
            engine_dstMac   => sig_engine_dstMac,
            engine_srcMac   => sig_engine_srcMac,

            engine_srcPortOut => sig_engine_srcPortIn,

            engine_EN       => sig_engine_EN
        );
    
    U_ENGINE : entity work.MAC_ENGINE
        port map (
            clk             => clk,
            reset           => reset,

            rdData          => sig_rdData_A,
            
            dstMac          => sig_engine_dstMac,
            srcMac          => sig_engine_srcMac,
            srcPortIn       => sig_engine_srcPortIn,
            EN              => sig_engine_EN,

            wren            => sig_wren_A,
            rden            => sig_rden_A,
            wrData          => sig_wrData_A,
            rdAddr          => sig_rdAddr_A,
            wrAddr          => sig_wrAddr_A,

            srcPortOut      => sig_engine_srcPortOut,
            dstPort         => sig_engine_dstPort,
            done            =>  sig_engine_done
        );
    
    U_AGING : entity work.MAC_AGING
        port map (
            clk             => clk,
            reset           => reset,

            rdData          => sig_rdData_B,
        
            wren            => sig_wren_B,
            rden            => sig_rden_B,
            wrData          => sig_wrData_B,
            rdAddr          => sig_rdAddr_B,
            wrAddr          => sig_wrAddr_B
        );
    
    U_BRAM : entity work.MAC_BRAM
        port map (
            clock           => clk,
            address_a		=> sig_bram_addr_A,
            address_b		=> sig_bram_addr_B,
            data_a		    => sig_wrData_A,
            data_b		    => sig_wrData_B,
            rden_a		    => sig_rden_A,
            rden_b		    => sig_rden_B,
            wren_a		    => sig_wren_A,
            wren_b		    => sig_wren_B,
            q_a		        => sig_rdData_A,
            q_b		        => sig_rdData_B
        );


end architecture Behavioral;
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
        
        -- Inputs
        EN : in t_flag_array;
        dstMac : in t_mac_array;
        srcMac : in t_mac_array;
        
        -- Outputs
        dstPort : out t_port_array;
        done : out t_flag_array
         
    );
end entity MAC_TOP;

architecture Behavioral of MAC_TOP is

    -- Internal signal declarations
    
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

    -- BRAM Address multiplexers
    sig_bram_addr_A <= sig_wrAddr_A when sig_wren_A = '1' else sig_rdAddr_A;
    sig_bram_addr_B <= sig_wrAddr_B when sig_wren_B = '1' else sig_rdAddr_B;

    U_ARBITER : entity work.MAC_ARBITER
        port map (
            clk             => clk,
            reset           => reset,

            port_EN         => EN,
            port_dstMac     => dstMac,
            port_srcMac     => srcMac,

            engine_srcPortIn => sig_engine_srcPortOut,

            engine_dstPort  => sig_engine_dstPort,
            engine_done     => sig_engine_done,

            port_dstPort    => dstPort,
            port_done       => done,
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
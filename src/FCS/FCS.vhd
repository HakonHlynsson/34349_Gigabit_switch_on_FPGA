---------------------------------------------------------------------
-- Componant:   FCS 
-- Description: its task is read and decode the incomming singnal
--	        as well as chack if the correct FCS value has been achived		   
-- Made by:    Hákon Hlynsson
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FCS is
    port (
	--Input
	Reset			: in std_logic;
	Tx_Clk     		: in std_logic;
    Rx_Clk     		: in std_logic;
	Rx_Valid		: in std_logic;
	RX_Data   		: in std_logic_vector(7 downto 0);
	En_Port_in		: in std_logic;
	Dst_Port_in		: in std_logic_vector(3 downto 0);
	--Output
	En_Data_out			: out std_logic;
	Dst_Port_out		: out std_logic_vector(2 downto 0);
	Data_out		: out std_logic_vector(7 downto 0);
	En_Mac			: out std_logic;
	Dst_Mac 		: out std_logic_vector(47 downto 0);
	Src_Mac 		: out std_logic_vector(47 downto 0)  
	);
end FCS;

architecture behavioral of FCS is
--Component
	component FCS_Reg
		port(
	Reset			: in std_logic;
	Rx_Clk        	: in std_logic;
	Rx_Valid		: in std_logic;
	RX_Data   		: in std_logic_vector(7 downto 0);
	FCS_Check		: in std_logic;
	fcs_error		: out std_logic;
	fcs_done		: out std_logic

	);
  	end component;

	component FCS_State_Machine port (
		-- Input 
		Reset           : in    std_logic;  -- reset signal
		Rx_Clk          : in    std_logic;  -- clock signal for receiving data
		Rx_Data         : in    std_logic_vector(7 downto 0);  -- incoming data
		Rx_Valid        : in    std_logic;  -- indicates that the incoming data is valid
		-- Output
		Dst_En          : out   std_logic;  -- enables the destination MAC address register
		Src_En          : out   std_logic;  -- enables the source MAC address register
		FCS_En          : out   std_logic  -- enables the FCS register
	);
  	end component;

	component Destination_Reg 
	port (
		--Input
		Rx_Data        	: in std_logic_vector(7 downto 0);
		Rx_Clk         	: in std_logic;
		Dst_En   	: in std_logic;
		--Output
		Dst_MAC        	: out std_logic_vector(47 downto 0)
		);
	end component;

	component Source_Reg port (
		--Input
		Rx_Data        	: in std_logic_vector(7 downto 0);
		Rx_Clk         	: in std_logic;
		Src_En		: in std_logic;
		--Output
		Src_MAC        	: out std_logic_vector(47 downto 0)
	);
	end component;

	component FIFO port (
		--Input
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		--Output
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
	end component;

--sigbnal
	Signal Dst_En		    : std_logic;
	Signal Src_En		    : std_logic;
	Signal FCS_En		    : std_logic;
	Signal fcs_error	    : std_logic;
	Signal fcs_done		    : std_logic;
	Signal Tx_Valid		    : std_logic;

	-- Internal registers for the routing handshake from the MAC learner
	Signal Dst_Port_out_reg : std_logic_vector(2 downto 0);
	Signal En_Data_out_reg  : std_logic;
	Signal rdempty_int      : std_logic;

Begin

Comp1 : FCS_State_Machine port map (
	  -- Input
	  Reset          =>Reset,
	  Rx_Clk         =>Rx_Clk,
	  Rx_Data        =>RX_Data,
	  Rx_Valid       =>Rx_Valid,
		-- Output 
	  Dst_En        =>Dst_En,    
	  Src_En        =>Src_En,
	  FCS_En        =>FCS_En
	  );

 Comp2 : FCS_Reg port map (
	-- Input
	Reset     => Reset,
	Rx_Clk    => Rx_Clk,
	Rx_Valid  => Rx_Valid,
	RX_Data   => RX_Data,
	FCS_Check => FCS_En,
	-- Output
	fcs_error => fcs_error,
	fcs_done  => fcs_done
	);

Comp3 : Destination_Reg port map (
	--Input
	Rx_Data =>RX_Data,
	Rx_Clk =>Rx_Clk,
	Dst_En =>Dst_En,
	--Output
	Dst_MAC =>Dst_Mac
	);

Comp4 : Source_Reg port map (
	--Input
	Rx_Data =>RX_Data,
	Rx_Clk =>Rx_Clk,
	Src_En =>Src_En,
	--Output
	Src_MAC =>Src_Mac
	);

comp5 : FIFO port map (
	--Input
	aclr    => Reset,
	data    => RX_Data,
	rdclk   => Tx_Clk,
	rdreq   => Tx_Valid,
	wrclk   => Rx_Clk,
	wrreq   => Rx_Valid,
	--Output
	q       => Data_out,
	rdempty => rdempty_int,
	rdusedw => open,
	wrfull  => open,
	wrusedw => open
	);

---------------------------------------------------------------------
-- En_Mac : single-cycle pulse to the MAC learner.
-- Asserted on the cycle when the FCS check completes (fcs_done = '1')
-- and the frame passed (fcs_error = '0'). Tells the learner that
-- Dst_Mac and Src_Mac are valid and ready to be read.
---------------------------------------------------------------------
En_Mac <= fcs_done and (not fcs_error);


---------------------------------------------------------------------
-- Routing handshake from the MAC learner to the VOQ.
--
--   1. The MAC learner finishes its lookup and pulses En_Port_in
--      with the destination port on Dst_Port_in.
--   2. On that edge we latch Dst_Port_in(2 downto 0) into
--      Dst_Port_out (the 4th bit is currently ignored - reserved for
--      a future "broadcast / not-found" flag) and assert En_Data_out.
--   3. En_Data_out also drives Tx_Valid, so the FIFO starts emitting
--      the stored frame on Data_out.
--   4. We hold En_Data_out high until the FIFO is drained
--      (rdempty_int = '1'), then we deassert and wait for the next
--      lookup.
--
-- NOTE: rdempty comes from the Tx_Clk side of the dual-clock FIFO
-- but is sampled here on Rx_Clk. This is fine while Tx_Clk and
-- Rx_Clk are tied together; if they are ever made truly independent,
-- add a 2-FF synchronizer on rdempty_int before this process.
---------------------------------------------------------------------
Routing_Logic : process(Rx_Clk, Reset)
begin
	if Reset = '1' then
		Dst_Port_out_reg <= (others => '0');
		En_Data_out_reg  <= '0';
	elsif rising_edge(Rx_Clk) then
		if En_Port_in = '1' then
			-- Learner has answered: capture the port and start streaming
			Dst_Port_out_reg <= Dst_Port_in(2 downto 0);
			En_Data_out_reg  <= '1';
		elsif En_Data_out_reg = '1' and rdempty_int = '1' then
			-- FIFO drained: release the link
			En_Data_out_reg  <= '0';
		end if;
	end if;
end process;

Dst_Port_out <= Dst_Port_out_reg;
En_Data_out  <= En_Data_out_reg;
Tx_Valid     <= En_Data_out_reg;

end behavioral;
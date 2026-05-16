---------------------------------------------------------------------
-- Componant  : Scheduler
-- Description: 4-port matching scheduler for the gigabit switch.
--              Each Tx_Clk cycle it looks at a 4x4 "Ready" matrix
--              from the four VOQs and decides which input drives
--              which output (the matching), then emits:
--                  - Select_S : 4 x 2-bit field for the Crossbar.
--                  - Tx_Valid : 4-bit, one per output, '1' while
--                               that output is matched.
--
--              Granularity is PER FRAME: once an output is matched
--              to an input, the match holds until that VOQ stops
--              advertising data for the target output (its Ready
--              bit drops). The scheduler then advances the round-
--              robin priority pointer for that output and looks for
--              a new match on the next cycle (or in the same cycle
--              if another VOQ is ready).
--
--              Conflict resolution: outputs are processed in fixed
--              index order 0..3. An input that is already claimed by
--              an active or just-matched higher-priority output
--              cannot be re-claimed in the same cycle.
--
--              Ready encoding (flat 16-bit vector):
--                  Ready(i*4 + j) = '1'
--                  means VOQ i has data destined for output j.
--                  ( i = input index 0..3 ,
--                    j = output index 0..3 )
--
--              Select_S encoding: same packing as Crossbar.vhd:
--                  Select_S((j*2)+1 downto j*2) is the 2-bit input
--                  index driving output j.
--
-- Made by    : Hakon Hlynsson
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Scheduler is
    port (
        --Input
        Reset    : in  std_logic;
        Tx_Clk   : in  std_logic;
        Ready    : in  std_logic_vector(15 downto 0);  -- 4 inputs x 4 outputs

        --Output
        Select_S : out std_logic_vector(7 downto 0);   -- 4 x 2-bit for Crossbar
        Tx_Valid : out std_logic_vector(3 downto 0)    -- per-output valid
    );
end Scheduler;

architecture behavioral of Scheduler is

    -- Per-output state (registered)
    type src_array_t is array (0 to 3) of unsigned(1 downto 0);

    signal active : std_logic_vector(3 downto 0) := (others => '0');
    signal src    : src_array_t                  := (others => "00");
    signal ptr    : src_array_t                  := (others => "00");

    -- Helper: read Ready(input = i, output = j) from the flat vector.
    function ReadyAt(R : std_logic_vector(15 downto 0);
                     i, j : integer) return std_logic is
    begin
        return R(i * 4 + j);
    end function;

begin

    ---------------------------------------------------------------
    -- Sequential state update on Tx_Clk
    ---------------------------------------------------------------
    State_Reg : process(Tx_Clk, Reset)
        variable claimed     : std_logic_vector(3 downto 0);
        variable next_active : std_logic_vector(3 downto 0);
        variable next_src    : src_array_t;
        variable next_ptr    : src_array_t;
        variable cand        : unsigned(1 downto 0);
        variable found       : boolean;
    begin
        if Reset = '1' then
            active <= (others => '0');
            src    <= (others => "00");
            -- Stagger the round-robin pointers so the first frame
            -- bursts spread across different inputs.
            ptr(0) <= to_unsigned(0, 2);
            ptr(1) <= to_unsigned(1, 2);
            ptr(2) <= to_unsigned(2, 2);
            ptr(3) <= to_unsigned(3, 2);

        elsif rising_edge(Tx_Clk) then

            -- Start from current registered state
            next_active := active;
            next_src    := src;
            next_ptr    := ptr;
            claimed     := (others => '0');

            -----------------------------------------------------------
            -- Phase 1 : maintain or release existing matches.
            --
            --   If an output is currently active and its source VOQ
            --   still has data for it, the match holds and the input
            --   stays "claimed" so no other output can grab it.
            --
            --   If the Ready bit has dropped, the frame is over:
            --   release the match and bump the priority pointer past
            --   the input we just used.
            -----------------------------------------------------------
            for j in 0 to 3 loop
                if active(j) = '1' then
                    if ReadyAt(Ready, to_integer(src(j)), j) = '1' then
                        claimed(to_integer(src(j))) := '1';
                    else
                        next_active(j) := '0';
                        next_ptr(j)    := src(j) + 1;
                    end if;
                end if;
            end loop;

            -----------------------------------------------------------
            -- Phase 2 : try to match each idle output to a new input.
            --
            --   We scan inputs in round-robin order starting from
            --   next_ptr(j). The first input that is Ready for this
            --   output AND not already claimed wins. After matching,
            --   we advance ptr to one past the chosen input so the
            --   next frame to this output naturally rotates onward.
            --
            --   Outputs are processed 0..3 so the conflict resolution
            --   is deterministic (output 0 has highest priority).
            -----------------------------------------------------------
            for j in 0 to 3 loop
                if next_active(j) = '0' then
                    found := false;
                    for offset in 0 to 3 loop
                        cand := next_ptr(j) + to_unsigned(offset, 2);
                        if (not found)
                           and (ReadyAt(Ready, to_integer(cand), j) = '1')
                           and (claimed(to_integer(cand)) = '0') then
                            next_active(j)            := '1';
                            next_src(j)               := cand;
                            next_ptr(j)               := cand + 1;
                            claimed(to_integer(cand)) := '1';
                            found                     := true;
                        end if;
                    end loop;
                end if;
            end loop;

            -- Commit
            active <= next_active;
            src    <= next_src;
            ptr    <= next_ptr;
        end if;
    end process;

    ---------------------------------------------------------------
    -- Combinational outputs derived from the registered state
    ---------------------------------------------------------------
    Out_Gen : for j in 0 to 3 generate
        Tx_Valid(j)                       <= active(j);
        Select_S((j*2)+1 downto j*2)      <= std_logic_vector(src(j));
    end generate;

end behavioral;

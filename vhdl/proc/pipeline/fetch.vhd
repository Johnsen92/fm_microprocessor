library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;
use work.program_package.all;

entity fetch is
    port (
        clk         : in std_logic;
        reset       : in std_logic;
        jmp         : in std_logic;
        jmp_pc      : in PC_T;
        instr       : out INSTR_T
    );
end fetch;

architecture fetch_arc of fetch is
    signal pc, pc_next : PC_T;
begin
    pc_logic : process(pc, jmp)
    begin
        -- default:
        if(pc = MAX_PC) then
            pc_next <= pc; -- program completed / bad jump
        else
            pc_next <= pc + 1;
        end if;
        
        if(jmp = '1') then
            pc_next <= jmp_pc;
        end if;
    end process;

    sync : process(reset, clk)
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                pc <= 0;
                instr <= (others => '0');
            else
                pc <= pc_next;
                if(pc > PROGRAM'high) then
                    instr <= (others => '0');
                else
                    instr <= PROGRAM(pc);
                end if;
            end if;
        end if;
    end process;
end architecture;
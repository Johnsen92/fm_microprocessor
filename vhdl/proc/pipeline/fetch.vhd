library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;
use work.program_package.all;

entity fetch is
    port (
        clk         : in std_logic;
        reset       : in std_logic;
		start		: in std_logic;
		done		: out std_logic;
        jmp         : in std_logic;
        jmp_addr    : in JMP_ADDR_T;
        instr       : out INSTR_T
    );
end fetch;

architecture fetch_arc of fetch is

	component imem is
    port (
        pc      : in PC_T;
        instr	: out INSTR_T
    );
	end component;

    signal pc, pc_next, jmp_pc : PC_T;
	signal imem_instr : INSTR_T;
begin
    done <= start;

	imem_inst: imem
		port map(
			pc      => pc_next,
			instr   => imem_instr
		);
    
    jmp_pc_conversion : process(jmp_addr)
    begin
        if(to_integer(unsigned(jmp_addr)) > MAX_PC) then
            jmp_pc <= MAX_PC;
        else
            jmp_pc <= to_integer(unsigned(jmp_addr));
        end if;
    end process;
    
    pc_logic : process(start, pc, jmp)
    begin
        -- default:
        pc_next <= pc;
        if(start = '1') then
            pc_next <= 0;
            if(pc = MAX_PC) then
                pc_next <= pc; -- program completed / bad jump
            else
                pc_next <= pc + 1;
            end if;
            
            if(jmp = '1') then
                pc_next <= jmp_pc;
            end if;
        end if;
    end process;

    output : process(pc, imem_instr)
    begin
        if(pc = MAX_PC) then
            instr <= (others => '0');
        else
            instr <= imem_instr;
        end if;
    end process;
    
    sync : process(reset, clk)
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                pc <= 0;
            elsif(start = '1') then
                pc <= pc_next;
            end if;
        end if;
    end process;
end architecture;
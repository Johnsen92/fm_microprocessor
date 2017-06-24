library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;

entity writeback is
    port (
        clk         : in std_logic;
        reset       : in std_logic;
        -- for top
		start		: in std_logic;
		done		: out std_logic;
        -- for regfile
        writeback   : in std_logic;
        rd          : in REG_ADDR_T;
        data        : in REG_DATA_T;
        wr          : out std_logic;
        wraddr      : out REG_ADDR_T;
        wrdata      : out REG_DATA_T;
        -- for fetch
        jmp_in      : in std_logic;
        jmp_out     : out std_logic;
        jmp_addr    : out JMP_ADDR_T
    );
end writeback;

architecture writeback_arc of writeback is
begin
    
    sync : process(reset, clk)
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                wr <= '0';
                wraddr <= (others => '0');
                wrdata <= (others => '0');
                jmp_addr <= (others => '0');
                jmp_out <= '0';
				done <= '0';
            else
				done <= start;
                wr <= writeback;
                wraddr <= rd;
                wrdata <= data;
                jmp_addr <= std_logic_vector(resize(unsigned(data), JMP_ADDR_T'length));
                jmp_out <= jmp_in;
            end if;
        end if;
    end process;
end architecture;
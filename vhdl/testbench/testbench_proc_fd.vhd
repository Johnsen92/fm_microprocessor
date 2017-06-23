library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.pipeline_package.all;
use work.program_package.all;

entity testbench_proc_fd is
end testbench_proc_fd;

architecture beh of testbench_proc_fd is
    component fetch is
        port (
            clk         : in std_logic;
            reset       : in std_logic;
            jmp         : in std_logic;
            jmp_pc      : in PC_T;
            instr       : out INSTR_T
        );
    end component;
    
    component decode is
        port (
            clk         : in std_logic;
            reset       : in std_logic;
            instr       : in INSTR_T;
            -- for regfile:
            wr          : in std_logic;
            wraddr      : in REG_ADDR_T;
            wrdata      : in REG_DATA_T;
            -- for exec/writeback stage:
            exec_op     : out EXEC_OP_T
        );
    end component;
    
    constant CLK_PERIOD : time := 20 ns;
    
    signal clk, reset : std_logic;
    
    signal instr : INSTR_T;
    signal exec_op : EXEC_OP_T;
begin
    fetch_inst : fetch
        port map(
            clk     => clk,
            reset   => reset,
            jmp     => '0',
            jmp_pc  => 0,
            instr   => instr
        );
    
    decode_inst : decode
        port map(
            clk     => clk,
            reset   => reset,
            instr   => instr,
            wr      => '0',
            wraddr  => (others => '0'),
            wrdata  => (others => '0'),
            exec_op => exec_op
        );
    
    clkgen : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process clkgen;

    -- Generates the reset signal
    resetgen : process
    begin  -- process reset
        reset <= '1';
        wait for 2*CLK_PERIOD;
        reset <= '0';
        wait;
    end process;
    
    input : process
    begin
        wait until falling_edge(reset);
        
        wait;
    end process;
end architecture;
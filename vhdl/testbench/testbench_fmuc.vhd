    library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.pipeline_package.all;
use work.program_package.all;
use work.sine_cordic_constants.all;

entity testbench_fmuc is
	port (
		fixed_converted : out REG_DATA_T := float_to_fixed(0.000143, DATA_WIDTH - 1, DATA_WIDTH)
	);
end testbench_fmuc;

architecture beh of testbench_fmuc is
    component fmuc is
        port (
            clk         	: in std_logic;
            reset       	: in std_logic;
            adc_rddata      : in REG_DATA_T;
            dac_wrdata      : out REG_DATA_T;
            dac_valid      	: out std_logic
        );
    end component;
    
    constant CLK_PERIOD : time := 20 ns;
    
    signal clk, reset : std_logic;
    
begin
    fmuc_inst : fmuc
        port map (
            clk         => clk,
            reset       => reset,
            adc_rddata  => x"BEEF",
            dac_wrdata  => open,
            dac_valid   => open
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
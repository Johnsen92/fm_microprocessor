    library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.pipeline_package.all;
use work.program_package.all;
use work.sine_cordic_constants.all;

entity testbench_fmuc is
	port (
		fixed_converted : out REG_DATA_T := float_to_fixed(-MATH_PI, DATA_WIDTH - 1, DATA_WIDTH)
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
	
	component adc_dac is
		port (
			clk				: in std_logic;
			reset			: in std_logic;
			adc_rddata_in	: in ADC_DATA_T;
			dac_wrdata_in	: in REG_DATA_T;
			dac_valid_in	: in std_logic;
			adc_rddata_out	: out REG_DATA_T;
			dac_wrdata_out	: out DAC_DATA_T;
			dac_valid_out	: out std_logic
		);
	end component;
    
    constant CLK_PERIOD : time := 20 ns;
    
    signal clk, reset : std_logic;
	signal adc_rddata_in_int : std_logic_vector(ADC_WIDTH-1 downto 0);
	signal dac_wrdata_in_int : REG_DATA_T;
	signal dac_valid_in_int : std_logic;
	signal adc_rddata_out_int : REG_DATA_T;
	signal dac_wrdata_out_int : std_logic_vector(DAC_WIDTH-1 downto 0);
	signal dac_valid_out_int : std_logic;
	signal sine : real;
    
begin
    fmuc_inst : fmuc
        port map (
            clk         => clk,
            reset       => reset,
            adc_rddata  => x"BEEF",
            dac_wrdata  => dac_wrdata_in_int,
            dac_valid   => dac_valid_in_int
        );
		
	adc_inst : adc_dac
		port map(
			clk				=> clk,
			reset			=> reset,
			adc_rddata_in 	=> adc_rddata_in_int,
			dac_wrdata_in	=> dac_wrdata_in_int,
			dac_valid_in	=> dac_valid_in_int,
			adc_rddata_out	=> adc_rddata_out_int,
			dac_wrdata_out	=> dac_wrdata_out_int,
			dac_valid_out	=> dac_valid_out_int
		);
    
	sine_output : process(dac_valid_out_int)
	begin
		if(rising_edge(dac_valid_out_int)) then
			sine <= fixed_to_float(dac_wrdata_in_int, DATA_WIDTH - Q_FORMAT_INTEGER_PLACES);
		end if;
	end process sine_output;
	
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
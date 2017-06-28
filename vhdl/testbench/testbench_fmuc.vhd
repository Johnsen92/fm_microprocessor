    library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


use work.program_package.all;
use work.sine_cordic_constants.all;
use work.pipeline_package.all;

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
	
    component timekeeper is
        generic (
            DATA_WIDTH              : integer := 8;
            CLK_FREQ                : real := 50_000_000.0; -- in Hz
            BAUD_RATE               : real := 44_000.0
        );
        port (
            clk         : in std_logic;
            reset       : in std_logic;
            sample      : out std_logic;
            phi         : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
    
	constant CLK_PERIOD             : time := 20 ns;
    constant CLK_FREQ               : real := 50_000_000.0; -- CAUTION: compare with above
    constant TIME_PRECISION         : integer := 16;
    constant INTERNAL_DATA_WIDTH    : integer := 16;
    constant INPUT_DATA_WIDTH       : integer := 14;
    constant OUTPUT_DATA_WIDTH      : integer := 12;
    constant BAUD_RATE              : real := 44_000.0;
    constant CARRIER_FREQ           : real := 1_000.0;
    constant FREQUENCY_DEV_KHZ      : real := 0.5;
	constant INPUT_FREQ 			: real := 1000.0; -- used to drive input sine wave
    constant INCREMENT 				: real := 2.0**(-(INTERNAL_DATA_WIDTH - Q_FORMAT_INTEGER_PLACES));
    constant CLK_PER_INCREMENT 		: integer := integer(round(CLK_FREQ*INCREMENT));
    constant CLK_PER_SAMPLE_INTERVAL : integer := integer(round(CLK_FREQ/BAUD_RATE));
	
	
    signal clk, reset : std_logic;
	signal adc_rddata_in_int : std_logic_vector(ADC_WIDTH-1 downto 0);
	signal dac_wrdata_in_int : REG_DATA_T;
	signal dac_valid_in_int : std_logic;
	signal adc_rddata_out_int : REG_DATA_T;
	signal dac_wrdata_out_int : std_logic_vector(DAC_WIDTH-1 downto 0);
	signal dac_valid_out_int : std_logic;
	signal sine, sine2 : real;
    signal dac_wrdata_stored : std_logic_vector(DAC_WIDTH-1 downto 0);
	
	signal phi : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal phi_r : real;
    signal sig_in : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal in_r, out_r : real;
	signal dac_rddata_uut : ADC_DATA_T;
    
begin

	phi_r <= fixed_to_float(phi, DATA_WIDTH - Q_FORMAT_INTEGER_PLACES);
    in_r <= sin(phi_r);
    --in_r <= 0.0;
    sig_in <= float_to_fixed(in_r, DATA_WIDTH - Q_FORMAT_INTEGER_PLACES, DATA_WIDTH);
    out_r <= fixed_to_float(sig_out, DATA_WIDTH - Q_FORMAT_INTEGER_PLACES);


    fmuc_inst : fmuc
        port map (
            clk         => clk,
            reset       => reset,
            adc_rddata  => sig_in,
            dac_wrdata  => dac_wrdata_in_int,
            dac_valid   => dac_valid_in_int
        );
		
	tk_input_gen : timekeeper
        generic map (
            DATA_WIDTH      => TIME_PRECISION,
            CLK_FREQ        => CLK_FREQ/INPUT_FREQ,
            BAUD_RATE       => BAUD_RATE
        )
        port map (
            reset   	=> reset,
            clk     	=> clk,
            sample      => open,
            phi         => phi
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
    
	sine_output : process(dac_valid_in_int)
	begin
		if(rising_edge(dac_valid_in_int)) then
			sine <= fixed_to_float(dac_wrdata_in_int, DATA_WIDTH - Q_FORMAT_INTEGER_PLACES);
		end if;
	end process sine_output;
    
    sine_output2 : process(dac_valid_out_int)
	begin
		if(rising_edge(dac_valid_out_int)) then
			sine2 <= fixed_to_float('0' & dac_wrdata_out_int, DAC_WIDTH-1);
            dac_wrdata_stored <= dac_wrdata_out_int;
		end if;
	end process sine_output2;
	
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
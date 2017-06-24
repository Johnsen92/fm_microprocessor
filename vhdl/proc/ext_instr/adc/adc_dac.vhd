library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;
use work.sine_cordic_constants.all;

entity adc_dac is
    port (
        clk         	: in std_logic;
        reset       	: in std_logic;
		adc_rddata_in	: in ADC_DATA_T;
		dac_wrdata_in	: in REG_DATA_T;
		dac_valid_in	: in std_logic;
		adc_rddata_out	: out REG_DATA_T;
		dac_wrdata_out	: out DAC_DATA_T;
		dac_valid_out	: out std_logic
    );
end adc_dac;

architecture adc_dac_arc of adc_dac is
	signal dac_wrdata_out_tmp    : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
	output: process(adc_rddata_in)  
	begin
		-- ADC input
		adc_rddata_out <= std_logic_vector(resize(signed(adc_rddata_in),DATA_WIDTH));
		
		-- DAC output
		dac_wrdata_out_tmp <= std_logic_vector(signed(dac_wrdata_in) + signed(float_to_fixed(1.1, DATA_WIDTH - Q_FORMAT_INTEGER_PLACES, DATA_WIDTH)));
		dac_wrdata_out <= dac_wrdata_out_tmp(DATA_WIDTH-(DATA_WIDTH - DAC_WIDTH)-2 downto 0) & "0";
	end process;
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;

entity fmuc is
    port (
        clk         	: in std_logic;
        reset       	: in std_logic;
        adc_rddata      : in REG_DATA_T;
        adc_wrdata      : out REG_DATA_T;
        adc_valid      	: out std_logic;
    );
end fmuc;

architecture fmuc_arc of fmuc is

	-- signals writeback to fetch
	signal start_wf		: std_logic;
	
	-- signals fetch to decode
	signal start_fd		: std_logic;
	signal instr_fd		: std_logic;
	
	-- signals decode to exec
	signal start_de		: std_logic;
	signal exec_op_de	: EXEC_OP_T;	
	
	-- signals exec to writeback
	signal start_ew		: std_logic;
	
begin

	fetch: entity work.fetch
		port map(
			clk		=> clk,
			reset	=> reset,
			start	=> start_wf,
			done	=> start_fd,
			jmp		=>
			jmp_pc	=>
			instr	=> instr_fd
		);
	
	decode: entity work.decode
		port map(
			clk		=> clk,
			reset	=> reset,
			start	=> start_fd,
			done	=> start_de,
			wr		=>
			wraddr	=>
			wrdata	=>
			exec_op => exec_op_de
		);
	
	exec: entity work.exec
		port map(
			clk			=> clk,
			reset		=> reset,
			start		=> start_de,
			done		=> start_ew,
			adc_rddata	=> adc_rddata,
			adc_wrdata	=> adc_wrdata,
			adc_valid	=> adc_valid
		);
	
	writeback: entity work.writeback
		port map(
			clk		=> clk,
			reset	=> reset,
		);
	
	
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;

entity fmuc is
    port (
        clk         	: in std_logic;
        reset       	: in std_logic;
        adc_rddata      : in REG_DATA_T;
        dac_wrdata      : out REG_DATA_T;
        dac_valid      	: out std_logic
    );
end fmuc;

architecture fmuc_arc of fmuc is
    signal reset_hold : std_logic;
    signal start_f, start_d, start_e, start_w : std_logic;
    signal done_f, done_d, done_e, done_w : std_logic;
    
	-- signals writeback to fetch
    signal jmp_wf       : std_logic;
    signal jmp_addr_wf  : JMP_ADDR_T;
    
    -- signals writeback to decode
    signal wr_wd        : std_logic;
    signal wraddr_wd    : REG_ADDR_T;
    signal wrdata_wd    : REG_DATA_T;
	
	-- signals fetch to decode
	signal instr_fd		: INSTR_T;
	
	-- signals decode to exec
	signal exec_op_de	: EXEC_OP_T;	
	
	-- signals exec to writeback
    signal result_ew    : REG_DATA_T;
    signal writeback_ew : std_logic;
    signal rd_ew        : REG_ADDR_T;
    signal jmp_ew       : std_logic;
	
begin

	fetch: entity work.fetch
		port map(
			clk		    => clk,
			reset	    => reset,
			start	    => start_f,
			done	    => done_f,
			jmp		    => jmp_wf,
			jmp_addr    => jmp_addr_wf,
			instr	    => instr_fd
		);
	
	decode: entity work.decode
		port map(
			clk		=> clk,
			reset	=> reset,
			start	=> start_d,
			done	=> done_d,
            instr   => instr_fd,
			wr		=> wr_wd,
			wraddr	=> wraddr_wd,
			wrdata	=> wrdata_wd,
			exec_op => exec_op_de
		);
	
	exec: entity work.exec
		port map(
			clk			=> clk,
			reset		=> reset,
			start		=> start_e,
			done		=> done_e,
            op          => exec_op_de,
            result      => result_ew,
            writeback   => writeback_ew,
            rd          => rd_ew,
            jmp         => jmp_ew,
			adc_rddata	=> adc_rddata,
			dac_wrdata	=> dac_wrdata,
			dac_valid	=> dac_valid
		);
	
	writeback: entity work.writeback
		port map(
			clk		    => clk,
			reset       => reset,
            start       => start_w,
            done        => done_w,
            writeback   => writeback_ew,
            rd          => rd_ew,
            data        => result_ew,
            wr          => wr_wd,
            wraddr      => wraddr_wd,
            wrdata      => wrdata_wd,
            jmp_in      => jmp_ew,
            jmp_out     => jmp_wf,
            jmp_addr    => jmp_addr_wf
		);
    
    sync : process(reset, clk)
    begin
        if(rising_edge(clk)) then
            reset_hold <= reset;
            if(reset = '1') then
                start_f <= '0';
                start_d <= '0';
                start_e <= '0';
                start_w <= '0';
            else
                if(reset_hold = '1') then
                    start_f <= '0';
                    start_d <= '1';
                    start_e <= '0';
                    start_w <= '0';
                else
                    start_f <= done_w;
                    start_d <= done_f;
                    start_e <= done_d;
                    start_w <= done_e;
                end if;
            end if;
        end if;
    end process;
	
end architecture;

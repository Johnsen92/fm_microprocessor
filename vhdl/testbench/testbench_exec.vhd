library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.sine_cordic_constants.all;
use work.pipeline_package.all;

entity testbench_exec is
end testbench_exec;

architecture beh of testbench_exec is

    component exec is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        -- for top
        start           : in  std_logic;
        done            : out std_logic;
        -- for operations
        op              : in  EXEC_OP_T;
        result          : out REG_DATA_T;
        jmp             : out std_logic;
        -- interface with ADC/DAC
        adc_rddata      : in  REG_DATA_T;
        dac_wrdata      : out REG_DATA_T;
        dac_valid       : out std_logic
    );
	end component;

    constant CLK_PERIOD             : time := 20 ns;
    constant CLK_FREQ               : real := 50_000_000.0; -- CAUTION: compare with above
    constant INTERNAL_DATA_WIDTH    : integer := 16;
    constant INPUT_DATA_WIDTH       : integer := 14;
    constant OUTPUT_DATA_WIDTH      : integer := 12;
	
	-- UUT signals IN
	signal clk, reset			: std_logic;
	signal start, done			: std_logic := '0';
	signal op_uut				: exec_op_type := EXEC_NOP;
	signal adc_rddata_uut		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal dac_wrdata_uut		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal dac_valid_uut		: std_logic := '0';

	
	-- UUT signals OUT
	signal jmp_uut				: std_logic_vector(ADDR_WIDTH_BITS-1 downto 0) := (others => '0');
	signal result_uut    		: std_logic := '0';
	
	-- testcases 
	type testcase_exec_op_array is array(1 downto 0) of exec_op_type;
    constant testcases_exec_op : testcase_exec_op_array := (
        (
			alu_op 		=> ALU_ADD,
			jmp_op		=> JMP_NOP,
			special_op 	=> SPECIAL_NOP, 
			dataa		=> std_logic_vector(to_unsigned(15, DATA_WIDTH)), 
			datab		=> std_logic_vector(to_unsigned(20, DATA_WIDTH)),
			rs			=> (others => '0'),
			rd			=> (others => '0'),
			imm			=> '0', 
			addr		=> '0', 
			use_imm		=> '0', 
			writeback	=> '0'
		),
		(
			alu_op 		=> ALU_ADD,
			jmp_op		=> JMP_NOP,
			special_op 	=> SPECIAL_NOP, 
			dataa		=> std_logic_vector(to_unsigned(15, DATA_WIDTH)), 
			datab		=> std_logic_vector(to_unsigned(20, DATA_WIDTH)),
			rs			=> (others => '0'),
			rd			=> (others => '0'),
			imm			=> '0', 
			addr		=> '0', 
			use_imm		=> '0', 
			writeback	=> '0'
		)
    );
	
begin    

	-- UUT
	exec_inst : exec
		port map(
			clk				=> clk,
			reset       	=> reset,
			start			=> start,
			done			=> done,
			op				=> op_uut,
			result			=> result_uut,
			jmp				=> jmp_uut,
			adc_rddata		=> adc_rddata_uut,
			dac_wrdata		=> dac_wrdata_uut,
			dac_valid		=> dac_valid_uut
		);
 
    -- Generates the clock signal
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

    -- Generates the input
    input : process
    begin  -- process input
        report "initiating test sequence!" severity note;
        wait until rising_edge(clk);
		wait until falling_edge(reset);
		
		adc_rddata_uut <= std_logic_vector(to_unsigned(265, DATA_WIDTH));
		
		wait for CLK_PERIOD*5;

		for i in testcases_exec_op'high downto testcases_exec_op'low loop
			op_uut <= testcases_exec_op(i);
			start  <= '1';
			wait until rising_edge(clk);
			start  <= '0';
			wait until done = '1';
			op_uut <= EXEC_NOP;
			wait for 5 * CLK_PERIOD;
		end loop;
		
		
		
        wait;
    end process;

end beh;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.sine_cordic_constants.all;
use work.core_pack.all;
use work.op_pack.all;

entity testbench_fm is
end testbench_fm;

architecture beh of testbench_fm is

    component exec is
	port (
		clk, reset       : in  std_logic;
		stall      		 : in  std_logic;
		flush            : in  std_logic;
		start			 : in  std_logic;
		done			 : out std_logic;
		pc_in            : in  std_logic_vector(ADDR_WIDTH_BITS-1 downto 0);
		op	   	         : in  exec_op_type;
		pc_out           : out std_logic_vector(ADDR_WIDTH_BITS-1 downto 0) := (others => '0');
		rd, rs			 : out std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
		aluresult	     : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		wrdata           : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		zero, neg        : out std_logic := '0';
		new_pc           : out std_logic_vector(ADDR_WIDTH_BITS-1 downto 0) := (others => '0');		
		jmpop_in         : in  jmp_op_type;
		jmpop_out        : out jmp_op_type := JMP_NOP;
		wbop_in          : in  wb_op_type;
		wbop_out         : out wb_op_type := WB_NOP;
		adc_rddata       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		adc_wrdata		 : out std_logic_vector(DATA_WIDTH-1 downto 0);
		adc_valid		 : out std_logic;
		mem_aluresult    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		wb_result        : in  std_logic_vector(DATA_WIDTH-1 downto 0)
	);
	end component;

    constant CLK_PERIOD             : time := 20 ns;
    constant CLK_FREQ               : real := 50_000_000.0; -- CAUTION: compare with above
    constant INTERNAL_DATA_WIDTH    : integer := 16;
    constant INPUT_DATA_WIDTH       : integer := 14;
    constant OUTPUT_DATA_WIDTH      : integer := 12;
	
	-- UUT signals IN
	signal clk, reset			: std_logic;
	signal stall, flush			: std_logic := '0';
	signal start, done			: std_logic := '0';
	signal pc_in_uut 			: std_logic_vector(ADDR_WIDTH_BITS-1 downto 0) := (others => '0');
	signal op_uut				: exec_op_type := EXEC_NOP;
	signal jmpop_in_uut			: jmp_op_type := JMP_NOP;
	signal wbop_in_uut			: wb_op_type := WB_NOP;
	signal adc_rddata_uut		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal adc_wrdata_uut		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal adc_valid_uut		: std_logic := '0';
	signal mem_aluresult_uut	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal wb_result_uut		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
	-- UUT signals OUT
	signal pc_out_uut			: std_logic_vector(ADDR_WIDTH_BITS-1 downto 0) := (others => '0');
	signal rd_uut, rs_uut		: std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	signal aluresult_uut    	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal wrdata_uut          	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal zero_uut, neg_uut    : std_logic := '0';
	signal new_pc_uut          	: std_logic_vector(ADDR_WIDTH_BITS-1 downto 0) := (others => '0');
	signal jmpop_out_uut        : jmp_op_type := JMP_NOP;
	signal wbop_out_uut        	: wb_op_type := WB_NOP;
	
	
	-- testcases 
	type testcase_exec_op_array is array(4 downto 0) of exec_op_type;
	type testcase_jmp_op_array is array(4 downto 0) of jmp_op_type;
    constant testcases_exec_op : testcase_exec_op_array := (
        (
			aluop 		=> ALU_NOP,
			adcop		=> ADC_NOP,
			readdata1 	=> "0010000000000000", 
			readdata2	=> (others => '0'), 
			imm			=> (others => '0'),
			addr		=> (others => '0'),
			rs			=> (others => '0'), 
			rd			=> (others => '0'),
			useimm		=> '0', 
			useamt		=> '0', 
			link		=> '0', 
			branch		=> '0', 
			regdst		=> '0', 
			adc			=> '0', 
			sine		=> '1', 
			mult		=> '0'
		),
		(
			aluop 		=> ALU_SUB,
			adcop		=> ADC_NOP,
			readdata1 	=> std_logic_vector(to_unsigned(20, DATA_WIDTH)), 
			readdata2	=> std_logic_vector(to_unsigned(20, DATA_WIDTH)), 
			imm			=> (others => '0'),
			addr		=> std_logic_vector(to_unsigned(3, ADDR_WIDTH_BITS)),
			rs			=> (others => '0'), 
			rd			=> (others => '0'),
			useimm		=> '0', 
			useamt		=> '0', 
			link		=> '0', 
			branch		=> '0', 
			regdst		=> '0', 
			adc			=> '0', 
			sine		=> '0', 
			mult		=> '0'
		),
        (
			aluop 		=> ALU_NOP,
			adcop		=> ('1', '0'),
			readdata1 	=> std_logic_vector(to_unsigned(20, DATA_WIDTH)), 
			readdata2	=> (others => '0'),
			imm			=> (others => '0'),
			addr		=> (others => '0'),
			rs			=> (others => '0'), 
			rd			=> (others => '0'),
			useimm		=> '0', 
			useamt		=> '0', 
			link		=> '0', 
			branch		=> '0', 
			regdst		=> '0', 
			adc			=> '1', 
			sine		=> '0', 
			mult		=> '0'
		),
        (
			aluop 		=> ALU_NOP,
			adcop		=> ('0', '1'),
			readdata1 	=> (others => '0'), 
			readdata2	=> (others => '0'),
			imm			=> (others => '0'),
			addr		=> (others => '0'),
			rs			=> (others => '0'), 
			rd			=> (others => '0'),
			useimm		=> '0', 
			useamt		=> '0', 
			link		=> '0', 
			branch		=> '0', 
			regdst		=> '0', 
			adc			=> '1', 
			sine		=> '0', 
			mult		=> '0'
		),
		(
			aluop 		=> ALU_NOP,
			adcop		=> ADC_NOP,
			readdata1 	=> (others => '0'),
			readdata2	=> (others => '0'),
			imm			=> (others => '0'),
			addr		=> std_logic_vector(to_unsigned(25, DATA_WIDTH)), 
			rs			=> (others => '0'), 
			rd			=> (others => '0'),
			useimm		=> '0', 
			useamt		=> '0', 
			link		=> '0', 
			branch		=> '0', 
			regdst		=> '0', 
			adc			=> '0', 
			sine		=> '0', 
			mult		=> '0'
		)
    );
	
	constant testcases_jmp_op : testcase_jmp_op_array := (
		JMP_NOP,
		JMP_NOP,
		JMP_NOP,
		JMP_NOP,
		JMP_JNZ
	);
	
begin    


	-- UUT
	exec_inst : exec
		port map(
			clk				 => clk,
			reset       	 => reset,
			stall      		 => stall,
			flush            => flush,
			start			 => start,
			done			 => done,
			pc_in            => pc_in_uut,
			op	   	         => op_uut,
			pc_out           => pc_out_uut,
			rd 				 => rd_uut,
			rs			 	 => rs_uut,
			aluresult	     => aluresult_uut,
			wrdata           => wrdata_uut,
			zero			 => zero_uut,
			neg        		 => neg_uut,
			new_pc           => new_pc_uut,
			jmpop_in         => jmpop_in_uut,
			jmpop_out        => jmpop_out_uut,
			wbop_in          => wbop_in_uut,
			wbop_out         => wbop_out_uut,
			adc_rddata       => adc_rddata_uut,
			adc_wrdata       => adc_wrdata_uut,
			adc_valid        => adc_valid_uut,
			mem_aluresult    => mem_aluresult_uut,
			wb_result        => wb_result_uut
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
			jmpop_in_uut <= testcases_jmp_op(i);
			start  <= '1';
			wait until rising_edge(clk);
			start  <= '0';
			wait until done = '1';
			op_uut <= EXEC_NOP;
			jmpop_in_uut <= JMP_NOP;
			wait for 5 * CLK_PERIOD;
		end loop;
		
		
		
        wait;
    end process;

end beh;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;
use work.sine_cordic_constants.all;

entity exec is
	port (
		clk, reset       : in  std_logic;
		stall      		 : in  std_logic := '0';
		flush            : in  std_logic := '0';
		start			 : in  std_logic := '0';
		done			 : out std_logic := '0';
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
		adc_rddata       : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		adc_wrdata		 : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		adc_valid		 : out std_logic := '0';
		mem_aluresult    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		wb_result        : in  std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end exec;

architecture rtl of exec is
	signal pc_next				: std_logic_vector(ADDR_WIDTH_BITS-1 downto 0);
	signal op_next				: exec_op_type := EXEC_NOP;
	signal op_alu    			: alu_op_type := ALU_NOP;
	signal alu_A    			: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal alu_B    			: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal alu_R   		 		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal alu_Z    			: std_logic := '0';
	signal alu_V    			: std_logic := '0';
	signal jmpop_next 			: jmp_op_type := JMP_NOP ;
	signal wbop_next 			: wb_op_type := WB_NOP;
	signal mem_aluresult_next 	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal wb_result_next 		: std_logic_vector(DATA_WIDTH-1 downto 0);

	-- internal signals
	signal start_int			: std_logic := '0';
	signal done_next			: std_logic := '0';
	signal zero_reg, over_reg	: std_logic := '0';
	signal zero_reg_next		: std_logic := '0';
	signal over_reg_next		: std_logic := '0';
	
	-- sine signals
	signal sine_done			: std_logic := '0';
	signal sine_result			: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal sine_start			: std_logic := '0';
	
	-- adc signals
	signal adc_rddata_next		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal adc_wrdata_next		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal adc_valid_next		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
	-- mult signals
	signal mult_result			: std_logic_vector(DATA_WIDTH-1 downto 0);
	
begin  -- rtl


	-- instances
	alu: entity work.alu
		port map (
			op => op_alu,
			A => alu_A,
			B => alu_B,
			R => alu_R,
			Z => alu_Z,
			V => alu_V
		);	

	sine: entity work.sine_cordic
		generic map(
			INPUT_DATA_WIDTH 	=> DATA_WIDTH, 
			OUTPUT_DATA_WIDTH	=> DATA_WIDTH,
			INTERNAL_DATA_WIDTH	=> DATA_WIDTH,
			ITERATION_COUNT		=> CORDIC_ITERATIONS
		)
		port map (
			reset	=> reset,
			clk		=> clk,
			beta	=> alu_A,
			start	=> sine_start,
			done	=> sine_done,
			result 	=> sine_result
		);
		
	mult: entity work.mult2
		generic map(
			DATA_WIDTH => DATA_WIDTH
		)
		port map(
			dataa	=> alu_A,
			datab	=> alu_B,
			result	=> mult_result
		);
	
	-- output process
	exec_output: process (
		op_next, 
		alu_R, 
		alu_V, 
		alu_Z, 
		pc_next, 
		jmpop_next, 
		mem_aluresult, 
		wb_result, 
		sine_result, 
		mult_result, 
		adc_rddata, 
		sine_done,
		start_int,
		over_reg,
		zero_reg
	)
	begin
		
		
		if stall /= '1' then		
			if op_next.useimm = '1' then
				alu_B <= std_logic_vector(resize(signed(op_next.imm),DATA_WIDTH));
			else
				alu_B <= op_next.readdata2;
			end if;
			alu_A <= op_next.readdata1;
		end if;
		
		-- status flags
		zero <= alu_Z;
		neg	<= alu_R(DATA_WIDTH - 1);
		
		-- aluresult multiplexer
		if op_next.adc = '1' and op_next.adcop.rd = '1' then
			aluresult <= adc_rddata;
		elsif op_next.sine = '1' then
			aluresult <= sine_result;
		elsif op_next.mult = '1' then
			aluresult <= mult_result;
		elsif op_next.useimm = '1' and op_next.aluop = ALU_NOP then
			aluresult <= std_logic_vector(resize(signed(op_next.imm),DATA_WIDTH));
		else
			aluresult <= alu_R;
		end if;

		-- done flag multiplexer
		if op_next.sine = '1' then
			done_next <= sine_done;
		else
			done_next <= start_int;
		end if;
		
		-- register data
		rs <= op_next.rs;
        rd <= op_next.rd;
		
		
		-- adc operation
		if op_next.adc = '1' and op_next.adcop.wr = '1' then
			adc_wrdata <= op_next.readdata1;
		end if;
		
		
		-- jump unit
		case jmpop_next is
			when  JMP_JC =>
				if over_reg = '1' then
					new_pc <= op_next.addr; 
				else
					new_pc <= pc_next;
				end if;
			when  JMP_JNC =>
				if over_reg = '0' then
					new_pc <= op_next.addr;
				else 
					new_pc <= pc_next;
				end if;
			when  JMP_JMP =>
				new_pc <= op_next.addr; 
			when  JMP_JZ => 
				if zero_reg = '1' then
					new_pc <= op_next.addr;
				else
					new_pc <= pc_next;
				end if;
			when  JMP_JNZ =>
				if zero_reg = '0' then 
					new_pc <= op_next.addr;
				else 
					new_pc <= pc_next;
				end if;
			when others =>
				new_pc <= pc_next;
		end case;
	end process exec_output;

	-- synch process
	exec_sync: process (clk, reset)
	begin	
		if reset = '1' then
			jmpop_next		<= JMP_NOP;
			jmpop_out		<= JMP_NOP;
			wbop_next		<= WB_NOP;
			wbop_out		<= WB_NOP;
			pc_next			<= (others => '0');
			pc_out      	<= (others => '0');
			op_next			<= EXEC_NOP;
			adc_rddata_next	<= (others => '0');
      		op_alu 			<= ALU_NOP;
			start_int		<= '0';
			sine_start		<= '0';
   		 elsif rising_edge(clk) then
			if flush = '1' then
				jmpop_next	<= JMP_NOP;
				jmpop_out	<= JMP_NOP;
				wbop_next	<= WB_NOP;
				wbop_out	<= WB_NOP;
				op_next		<= op;	
				start_int	<= '0';
				sine_start  <= '0';
				adc_rddata_next	<= (others => '0');
			elsif stall = '0' and start = '1' then
				start_int 	<= start;
				jmpop_next	<= jmpop_in;
				wbop_next	<= wbop_in;
				pc_next		<= pc_in;
				op_next		<= op;	
				op_alu 		<= op.aluop;
				adc_rddata_next	<= adc_rddata;
				mem_aluresult_next <= mem_aluresult;
				wb_result_next <= wb_result;
			elsif stall = '0' then
				sine_start  <= start_int;
				start_int 	<= '0';
				done 		<= done_next;
				zero_reg		<= zero_reg_next;
				over_reg		<= over_reg_next;
				if op_next.adcop.wr = '1' then
					adc_valid <= done_next;
				else
					adc_valid <= '0';
				end if;
			end if;	
			
			if done_next = '1' then
				jmpop_out		<= jmpop_next;
				wbop_out		<= wbop_next;
				pc_out			<= pc_next;
				zero_reg_next 	<= alu_Z;
				over_reg_next	<= alu_V;
			end if;
		end if;
	
	end process exec_sync;

end rtl;

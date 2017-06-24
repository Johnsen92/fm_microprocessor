LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.core_pack.all;
USE work.op_pack.all;

ENTITY decode IS
	PORT (
		clk, reset : IN  std_logic;
		stall      : IN  std_logic;
		flush      : IN  std_logic;
		pc_in      : IN  std_logic_vector(PC_WIDTH-1 DOWNTO 0);
		instr	   : IN  std_logic_vector(INSTR_WIDTH-1 DOWNTO 0);
		wraddr     : IN  std_logic_vector(REG_BITS-1 DOWNTO 0);
		wrdata     : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
		regwrite   : IN  std_logic;
		pc_out     : OUT std_logic_vector(PC_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
		exec_op    : OUT exec_op_type := EXEC_NOP;
		cop0_op    : OUT cop0_op_type := COP0_NOP;
		jmp_op     : OUT jmp_op_type := JMP_NOP;
		mem_op     : OUT mem_op_type := MEM_NOP;
		wb_op      : OUT wb_op_type := WB_NOP;
		exc_dec    : OUT std_logic := '0';
		cop0_wrdata : OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0)
	);
END decode;

ARCHITECTURE rtl OF decode IS
	SIGNAL regwrite_int, flush_int : std_logic  := '0';
	SIGNAL wraddr_int : std_logic_vector(REG_BITS - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL wrdata_int : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL pc_in_int : std_logic_vector(PC_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL instr_int : std_logic_vector(INSTR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL rddata1_int, rddata2_int : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	COMPONENT regfile IS
	PORT (
		clk, reset       : IN  std_logic;
		stall            : IN  std_logic;
		rdaddr1, rdaddr2 : IN  std_logic_vector(REG_BITS-1 DOWNTO 0);
		rddata1, rddata2 : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
		wraddr		 	 : IN  std_logic_vector(REG_BITS-1 DOWNTO 0);
		wrdata		 	 : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
		regwrite         : IN  std_logic
	);
	END COMPONENT regfile;
BEGIN  -- rtl
	reg_inst : regfile
	PORT MAP(
		clk => clk,
		reset => reset,
		stall => stall,
		-- rs_addr
		rdaddr1 => instr(25 DOWNTO 21),
		-- rt_addr
		rdaddr2 => instr(20 DOWNTO 16),
		wraddr => wraddr,
		wrdata => wrdata,
		regwrite => regwrite,
		-- rs
		rddata1 => rddata1_int,
		-- rt
		rddata2 => rddata2_int
	);
	
	output_transition : PROCESS(pc_in_int, instr_int, regwrite_int, flush, rddata1_int, rddata2_int)
	VARIABLE tmp : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
	VARIABLE imm_signed, imm_unsigned : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
	VARIABLE shamt : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
	BEGIN
		imm_signed(15 DOWNTO 0) := instr_int(15 DOWNTO 0);
		imm_signed(DATA_WIDTH - 1 DOWNTO 16) := (OTHERS => instr_int(15)); 
		imm_unsigned(15 DOWNTO 0) := instr_int(15 DOWNTO 0);
		imm_unsigned(DATA_WIDTH - 1 DOWNTO 16) := (OTHERS => '0');
		shamt(4 DOWNTO 0) := instr_int(10 DOWNTO 6);
		shamt(DATA_WIDTH - 1 DOWNTO 5) := (OTHERS => '0');
		IF instr_int(DATA_WIDTH - 1 DOWNTO 21) = "01000000100" THEN
			cop0_wrdata <= rddata2_int;
		ELSE
			cop0_wrdata <= (OTHERS => '0');
		END IF;
		IF flush /= '1' AND unsigned(instr_int) /= 0 THEN
			CASE instr_int(INSTR_WIDTH - 1 DOWNTO INSTR_WIDTH - 6) IS
				-- R format operations
				WHEN "000000" => 
					CASE instr_int(5 DOWNTO 0) IS
						-- SLL rd, rt, shamt
						WHEN "000000" => 
							exec_op <= (
								aluop => ALU_SLL,
								readdata1 => shamt,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '1',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.memtoreg <= '0';
							wb_op.regwrite <= '1';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- SRL rd, rt, shamt
						WHEN "000010" =>
							exec_op <= (
								aluop => ALU_SRL,
								readdata1 => shamt,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '1',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.memtoreg <= '0';
							wb_op.regwrite <= '1';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- SRA rd, rt, shamt					
						WHEN "000011" =>
							exec_op <= (
								aluop => ALU_SRA,
								readdata1 => shamt,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '1',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.memtoreg <= '0';
							wb_op.regwrite <= '1';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- SLLV rd, rt, rs					
						WHEN "000100" =>
							tmp(4 DOWNTO 0) := rddata1_int(4 DOWNTO 0);
							tmp(DATA_WIDTH - 1 DOWNTO 5) := (OTHERS => '0');
							exec_op <= (
								aluop => ALU_SLL,
								readdata1 => tmp,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.memtoreg <= '0';
							wb_op.regwrite <= '1';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- SRLV rd, rt, rs
						WHEN "000110" =>
							tmp(4 DOWNTO 0) := rddata1_int(4 DOWNTO 0);
							tmp(DATA_WIDTH - 1 DOWNTO 5) := (OTHERS => '0');
							exec_op <= (
								aluop => ALU_SRL,
								readdata1 => tmp,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.memtoreg <= '0';
							wb_op.regwrite <= '1';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- SRAV rd, rs, rt
						WHEN "000111" =>
							tmp(4 DOWNTO 0) := rddata1_int(4 DOWNTO 0);
							tmp(DATA_WIDTH - 1 DOWNTO 5) := (OTHERS => '0');
							exec_op <= (
								aluop => ALU_SRA,
								readdata1 => tmp,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.memtoreg <= '0';
							wb_op.regwrite <= '1';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- JR rs
						WHEN "001000" =>
							exec_op <= (
								aluop => ALU_NOP,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op <= WB_NOP;
							jmp_op <= JMP_JMP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- JALR rd, rs
						WHEN "001001" =>
							exec_op <= (
								aluop => ALU_NOP,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '1',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							jmp_op <= JMP_JMP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- ADD rd, rs, rt
						WHEN "100000" =>
							exec_op <= (
								aluop => ALU_ADD,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '1'
							);
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- ADDU rd, rs, rt
						WHEN "100001" =>
							exec_op <= (
								aluop => ALU_ADD,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- SUB rd, rs, rt
						WHEN "100010" =>
							exec_op <= (
								aluop => ALU_SUB,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '1'
							);
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- SUBU rd, rs, rt
						WHEN "100011" =>
							exec_op <= (
								aluop => ALU_SUB,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- AND rd, rs, rt
						WHEN "100100" =>
							exec_op <= (
								aluop => ALU_AND,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- OR rd, rs, rt
						WHEN "100101" =>
							exec_op <= (
								aluop => ALU_OR,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- XOR rd, rs, rt
						WHEN "100110" =>
							exec_op <= (
								aluop => ALU_XOR,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- NOR rd, rs, rt
						WHEN "100111" =>
							exec_op <= (
								aluop => ALU_NOR,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- SLT, rd, rs, rt
						WHEN "101010" =>
							exec_op <= (
								aluop => ALU_SLT,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- SLTU rd, rs, rt
						WHEN "101011" =>
							exec_op <= (
								aluop => ALU_SLTU,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '0',
								ovf => '0'
							);
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						WHEN OTHERS =>
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							wb_op <= WB_NOP;
							exec_op <= EXEC_NOP;
							exc_dec <= '1';
					END CASE;
				-- I format operations
				WHEN "000001" =>
					CASE instr_int(20 DOWNTO 16) IS
						-- BLTZ rs, imm18
						WHEN "00000" =>
							exec_op <= (
								aluop => ALU_NOP,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => imm_signed,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '1',
								regdst => '1',
								cop0 => '0',
								ovf => '0'
							);
							jmp_op <= JMP_BLTZ;
							wb_op <= WB_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- BGEZ rs, imm18
						WHEN "00001" =>
							exec_op <= (
								aluop => ALU_NOP,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => imm_signed,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '1',
								regdst => '1',
								cop0 => '0',
								ovf => '0'
							);
							jmp_op <= JMP_BGEZ;
							wb_op <= WB_NOP;
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- BLTZAL rs, imm18
						WHEN "10000" =>	
							exec_op <= (
								aluop => ALU_ADD,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => imm_signed,
								rs => instr_int(25 DOWNTO 21),
								rt => "11111",
								rd => "11111",
								useimm => '0',
								useamt => '0',
								link => '1',
								branch => '1',
								regdst => '1',
								cop0 => '0',
								ovf => '0'
							);
							jmp_op <= JMP_BLTZ;
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						-- BGEZAL rs, imm18
						WHEN "10001" =>	
							exec_op <= (
								aluop => ALU_ADD,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => imm_signed,
								rs => instr_int(25 DOWNTO 21),
								rt => "11111",
								rd => "11111",
								useimm => '0',
								useamt => '0',
								link => '1',
								branch => '1',
								regdst => '1',
								cop0 => '0',
								ovf => '0'
							);
							jmp_op <= JMP_BGEZ;
							wb_op.regwrite <= '1';
							wb_op.memtoreg <= '0';
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							exc_dec <= '0';
						WHEN OTHERS =>
							mem_op <= MEM_NOP;	
							cop0_op <= COP0_NOP;
							wb_op <= WB_NOP;
							jmp_op <= JMP_NOP;
							exec_op <= EXEC_NOP;
							exc_dec <= '1';
					END CASE;
				-- J address
				WHEN "000010" =>
					exec_op <= (
						aluop => ALU_NOP,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => instr_int,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '0',
						cop0 => '0',
						ovf => '0'
					);
					jmp_op <= JMP_JMP;
					wb_op <= WB_NOP;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- JAL address
				WHEN "000011" =>
					exec_op <= (
						aluop => ALU_NOP,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => instr_int,
						rs => instr_int(25 DOWNTO 21),
						rt => "11111",
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '1',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					jmp_op <= JMP_JMP;
					wb_op.regwrite <= '1';
					wb_op.memtoreg <= '0';
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- BEQ rd, rs, imm18
				WHEN "000100" =>
					exec_op <= (
						aluop => ALU_SUB,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '0',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					jmp_op <= JMP_BEQ;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					wb_op <= WB_NOP;
					exc_dec <= '0';
				-- BNE rd, rs, imm18
				WHEN "000101" =>
					exec_op <= (
						aluop => ALU_SUB,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '0',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					jmp_op <= JMP_BNE;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					wb_op <= WB_NOP;
					exc_dec <= '0';
				-- BLEZ rs, imm18
				WHEN "000110" =>
					exec_op <= (
						aluop => ALU_NOP,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '0',
						useamt => '0',
						link => '0',
						branch => '1',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					jmp_op <= JMP_BLEZ;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					wb_op <= WB_NOP;
					exc_dec <= '0';
				-- BGTZ rs, imm18
				WHEN "000111" =>
					exec_op <= (
						aluop => ALU_NOP,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '0',
						useamt => '0',
						link => '0',
						branch => '1',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					jmp_op <= JMP_BGTZ;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					wb_op <= WB_NOP;
					exc_dec <= '0';
				-- ADDI rd, rs, imm16
				WHEN "001000" =>
					exec_op <= (
						aluop => ALU_ADD,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '1'
					);
					wb_op.memtoreg <= '0';
					wb_op.regwrite <= '1';
					jmp_op <= JMP_NOP;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- ADDIU rd, rs, imm16
				WHEN "001001" =>
					exec_op <= (
						aluop => ALU_ADD,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => "00000",
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.memtoreg <= '0';
					wb_op.regwrite <= '1';
					jmp_op <= JMP_NOP;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- SLTI rd, rs, imm16
				WHEN "001010" =>
					exec_op <= (
						aluop => ALU_SLT,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.memtoreg <= '0';
					wb_op.regwrite <= '1';
					jmp_op <= JMP_NOP;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- SLTIU rd, rs, imm16
				WHEN "001011" =>
					exec_op <= (
						aluop => ALU_SLTU,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_unsigned,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.memtoreg <= '0';
					wb_op.regwrite <= '1';
					jmp_op <= JMP_NOP;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- ANDI rd, rs, imm16
				WHEN "001100" =>
					exec_op <= (
						aluop => ALU_AND,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_unsigned,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.memtoreg <= '0';
					wb_op.regwrite <= '1';
					jmp_op <= JMP_NOP;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- ORI rd, rs, imm16
				WHEN "001101" =>
					exec_op <= (
						aluop => ALU_OR,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_unsigned,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.memtoreg <= '0';
					wb_op.regwrite <= '1';
					jmp_op <= JMP_NOP;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- XORI rd, rs, imm16
				WHEN "001110" =>
					exec_op <= (
						aluop => ALU_XOR,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_unsigned,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.memtoreg <= '0';
					wb_op.regwrite <= '1';
					jmp_op <= JMP_NOP;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- LUI rd, imm16
				WHEN "001111" =>
					exec_op <= (
						aluop => ALU_LUI,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_unsigned,
						rs => "00000",
						rt => instr_int(20 DOWNTO 16),
						rd => "00000",
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.memtoreg <= '0';
					wb_op.regwrite <= '1';
					jmp_op <= JMP_NOP;
					mem_op <= MEM_NOP;	
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- Coprocessor operations
				WHEN "010000" =>
					CASE instr_int(25 DOWNTO 21) IS
						-- MFC0 rt, rd
						WHEN "00000" =>
							exec_op <= (
								aluop => ALU_ADD,
								readdata1 => rddata1_int,
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '1',
								cop0 => '1',
								ovf => '0'
							);
							wb_op.memtoreg <= '0';
							wb_op.regwrite <= '1';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op.wr <= '0';
							cop0_op.addr <= instr_int(15 DOWNTO 11);
							exc_dec <= '0';
						-- MTC0 rt, rd
						WHEN "00100" =>
							exec_op <= (
								aluop => ALU_ADD,
								readdata1 => (OTHERS => '0'),
								readdata2 => rddata2_int,
								imm => instr_int,
								rs => instr_int(25 DOWNTO 21),
								rt => instr_int(20 DOWNTO 16),
								rd => instr_int(15 DOWNTO 11),
								useimm => '0',
								useamt => '0',
								link => '0',
								branch => '0',
								regdst => '0',
								cop0 => '1',
								ovf => '0'
							);
							wb_op.memtoreg <= '0';
							wb_op.regwrite <= '0';
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;	
							cop0_op.wr <= '1';
							cop0_op.addr <= instr_int(15 DOWNTO 11);
							exc_dec <= '0';
						WHEN OTHERS =>
							exec_op <= EXEC_NOP;
							cop0_op <= COP0_NOP;
							jmp_op <= JMP_NOP;
							mem_op <= MEM_NOP;
							wb_op <= WB_NOP;
							exc_dec <= '0';
					END CASE;
				-- LB rd, imm16(rs)
				WHEN "100000" =>
					exec_op <= (
						aluop => ALU_ADD,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.regwrite <= '1';
					wb_op.memtoreg <= '1';
					mem_op.memtype <= MEM_B;
					mem_op.memread <= '1';
					mem_op.memwrite <= '0';
					jmp_op <= JMP_NOP;
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- LH rd, imm16(rs)
				WHEN "100001" =>
					exec_op <= (
						aluop => ALU_ADD,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.regwrite <= '1';
					wb_op.memtoreg <= '1';
					mem_op.memtype <= MEM_H;
					mem_op.memread <= '1';
					mem_op.memwrite <= '0';
					jmp_op <= JMP_NOP;
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- LW rd, imm16(rs)
				WHEN "100011" =>
					exec_op <= (
						aluop => ALU_ADD,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.regwrite <= '1';
					wb_op.memtoreg <= '1';
					mem_op.memtype <= MEM_W;
					mem_op.memread <= '1';
					mem_op.memwrite <= '0';
					jmp_op <= JMP_NOP;
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- LBU rd, imm16(rs)
				WHEN "100100" =>
					exec_op <= (
						aluop => ALU_ADD,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.regwrite <= '1';
					wb_op.memtoreg <= '1';
					mem_op.memtype <= MEM_BU;
					mem_op.memread <= '1';
					mem_op.memwrite <= '0';
					jmp_op <= JMP_NOP;
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- LHU rd, imm16(rs)
				WHEN "100101" =>
					exec_op <= (
						aluop => ALU_ADD,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					wb_op.regwrite <= '1';
					wb_op.memtoreg <= '1';
					mem_op.memtype <= MEM_HU;
					mem_op.memread <= '1';
					mem_op.memwrite <= '0';
					jmp_op <= JMP_NOP;
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- SB rd, imm16(rs)
				WHEN "101000" =>
					exec_op <= (
						aluop => ALU_ADD,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					mem_op.memtype <= MEM_B;
					mem_op.memwrite <= '1';
					mem_op.memread <= '0';
					wb_op <= WB_NOP;
					jmp_op <= JMP_NOP;
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- SH rd, imm16(rs)
				WHEN "101001" =>
					exec_op <= (
						aluop => ALU_ADD,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					mem_op.memtype <= MEM_H;
					mem_op.memwrite <= '1';
					mem_op.memread <= '0';
					wb_op <= WB_NOP;
					jmp_op <= JMP_NOP;
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				-- SW rd, imm16(rs)
				WHEN "101011" =>
					exec_op <= (
						aluop => ALU_ADD,
						readdata1 => rddata1_int,
						readdata2 => rddata2_int,
						imm => imm_signed,
						rs => instr_int(25 DOWNTO 21),
						rt => instr_int(20 DOWNTO 16),
						rd => instr_int(15 DOWNTO 11),
						useimm => '1',
						useamt => '0',
						link => '0',
						branch => '0',
						regdst => '1',
						cop0 => '0',
						ovf => '0'
					);
					mem_op.memtype <= MEM_W;
					mem_op.memwrite <= '1';
					mem_op.memread <= '0';
					wb_op <= WB_NOP;
					jmp_op <= JMP_NOP;
					cop0_op <= COP0_NOP;
					exc_dec <= '0';
				WHEN OTHERS => 
					exec_op <= EXEC_NOP;
					cop0_op <= COP0_NOP;
					jmp_op <= JMP_NOP;
					mem_op <= MEM_NOP;
					wb_op <= WB_NOP;
					exc_dec <= '1';
			END CASE;
		ELSE
			exec_op <= EXEC_NOP;
			cop0_op <= COP0_NOP;
			jmp_op <= JMP_NOP;
			mem_op <= MEM_NOP;
			wb_op <= WB_NOP;
			exc_dec <= '0';
		END IF;
		pc_out <= pc_in_int;
	END PROCESS output_transition;
		
	sync : PROCESS(clk, reset, flush)
	BEGIN
		IF reset = '0' THEN
			instr_int <= (OTHERS => '0');
			pc_in_int <= (OTHERS => '0');
			regwrite_int <= '0';
			wraddr_int <= (OTHERS => '0');
			wrdata_int <= (OTHERS => '0');
			flush_int <= '1';
		ELSE
			IF rising_edge(clk) AND stall /= '1' THEN
				IF flush = '1' THEN
					instr_int <= (OTHERS => '0');
				ELSE
					instr_int <= instr;
				END IF;
				pc_in_int <= pc_in;
				regwrite_int <= regwrite;
				wraddr_int <= wraddr;
				wrdata_int <= wrdata;
				flush_int <= flush;
			END IF;
		END IF;
	END PROCESS sync;
END rtl;

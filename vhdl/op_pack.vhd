library ieee;
use ieee.std_logic_1164.all;

use work.core_pack.all;

package op_pack is

	type adc_op_type is
	record
		wr   : std_logic;
		rd	 : std_logic;
	end record;

	constant ADC_NOP : adc_op_type :=
		('0', '0');

	type alu_op_type is (
		ALU_NOP,
		ALU_SLT,
		ALU_SLTU,
		ALU_SLL,
		ALU_SRL,
		ALU_SRA,
		ALU_ADD,
		ALU_SUB,
		ALU_AND,
		ALU_OR,
		ALU_XOR,
		ALU_NOR,
		ALU_LUI
		);

	type exec_op_type is
	record
		aluop	   	: alu_op_type;
		adcop		: adc_op_type;
		readdata1  	: std_logic_vector(DATA_WIDTH-1 downto 0);
		readdata2  	: std_logic_vector(DATA_WIDTH-1 downto 0);
		imm        	: std_logic_vector(IMM_WIDTH_BITS-1 downto 0);
		addr        : std_logic_vector(ADDR_WIDTH_BITS-1 downto 0);
		rs, rd		: std_logic_vector(REG_BITS-1 downto 0);
		useimm     	: std_logic;
		useamt     	: std_logic;
		link       	: std_logic;
		branch     	: std_logic;
		regdst     	: std_logic;
		adc       	: std_logic;
		sine		: std_logic;
		mult		: std_logic;
	end record;

	constant EXEC_NOP : exec_op_type :=
		(ALU_NOP, ADC_NOP,
		 (others => '0'), (others => '0'), (others => '0'),
		 (others => '0'), (others => '0'), (others => '0'),
		 '0', '0', '0', '0', '0', '0', '0', '0');

	type jmp_op_type is (
		JMP_NOP,
		JMP_JMP,
		JMP_JC,
		JMP_JNC,
		JMP_JZ,
		JMP_JNZ
	);
	
	type wb_op_type is
	record
		memtoreg : std_logic;
		regwrite : std_logic;
	end record;

	constant WB_NOP : wb_op_type := ('0', '0');

end op_pack;

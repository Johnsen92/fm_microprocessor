package pipeline_package is
    
    -------------------------------
    -- General Constants         --
    -------------------------------
    constant DATA_WIDTH     : integer := 16;
    constant NUM_REGS       : integer := 20;
    constant NUM_HL_REGS    : integer := 2;
    constant PC_WIDTH       : integer := 16;
    
    -------------------------------
    -- Instruction Set Fields    --
    -------------------------------
    constant INSTR_WIDTH    : integer := 22;
    constant OP_WIDTH       : integer := 6;
    constant REG_ADDR_WIDTH : integer := 5;
    constant IMM_WIDTH      : integer := 11;
    constant JMP_ADDR_WIDTH : integer := 16;
    -- used for reading fields from instr
    type INSTR_FIELD_OP     is range 21 downto 16;
    type INSTR_FIELD_RD     is range 15 downto 11;
    type INSTR_FIELD_RS     is range 10 downto 6;
    type INSTR_FIELD_RT     is range 5  downto 1; --TODO only need 21 bits; need RT field? c=a+b or b=a+b?
    type INSTR_FIELD_IMM    is range 10 downto 0;
    type INSTR_FIELD_ADDR   is range 15 downto 0;
    
    -------------------------------
    -- Pipeline-Relevant Types   --
    -------------------------------
    type INSTR_T is std_logic_vector(INSTR_WIDTH-1 downto 0);
    type OP_T is std_logic_vector(OP_WIDTH-1 downto 0);
    type REG_ADDR_T is std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
    type REG_DATA_T is std_logic_vector(DATA_WIDTH-1 downto 0);
    type IMM_DATA_T is std_logic_vector(IMM_WIDTH-1 downto 0);
    type JMP_ADDR_T is std_logic_vector(JMP_ADDR_WIDTH-1 downto 0);
    type ALU_OP_T is (
        ALU_NOP,
        ALU_ADD,
        ALU_SUB,
        ALU_AND,
        ALU_OR,
        ALU_XOR
    );
    type JMP_OP_T is (
        JMP_NOP,
        JMP_JMP,
        JMP_JC,
        JMP_JNC,
        JMP_JZ,
        JMP_JNZ
    );
    type SPECIAL_OP_T is (
        SPECIAL_NOP,
        SPECIAL_ADC_IN,
        SPECIAL_SIN,
        SPECIAL_DAC_OUT,
        SPECIAL_WAIT
    );
    
    type EXEC_OP_T is
	record
		alu_op	    : ALU_OP_T;
        jmp_op      : JMP_OP_T;
        special_op  : SPECIAL_OP_T;
		dataa       : REG_DATA_T;
		datab       : REG_DATA_T;
		rs          : REG_ADDR_T;
        rt          : REG_ADDR_T;
        rd          : REG_ADDR_T;
        imm         : IMM_DATA_T;
        addr        : JMP_ADDR_T;
		use_imm     : std_logic;
        writeback   : std_logic;
	end record;
    
    -------------------------------
    -- Instruction Set Op-Codes  --
    -------------------------------
    constant OP_NOP     : OP_T := "000000"; --TODO can NOP be 0?
    constant OP_ADC_IN  : OP_T := "000001";
    constant OP_MUL     : OP_T := "000010";
    constant OP_SIN     : OP_T := "000011";
    constant OP_MOV     : OP_T := "000100";
    constant OP_ADD     : OP_T := "000101";
    constant OP_SUB     : OP_T := "000110";
    constant OP_INC     : OP_T := "000111";
    constant OP_CP      : OP_T := "001000";
    constant OP_DAC_OUT : OP_T := "001001";
    constant OP_AND     : OP_T := "001010";
    constant OP_OR      : OP_T := "001011";
    constant OP_XOR     : OP_T := "001100";
    constant OP_MOVI    : OP_T := "010100";
    constant OP_ADDI    : OP_T := "010101";
    constant OP_ANDI    : OP_T := "011010";
    constant OP_ORI     : OP_T := "011011";
    constant OP_XORI    : OP_T := "011100";
    constant OP_JMP     : OP_T := "100000";
    constant OP_JC      : OP_T := "100001";
    constant OP_JNC     : OP_T := "100010";
    constant OP_JZ      : OP_T := "100011";
    constant OP_JNZ     : OP_T := "100100";
    constant OP_WAIT    : OP_T := "111111";
    
end pipeline_package;
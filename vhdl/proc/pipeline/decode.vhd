library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;

entity decode is
    port (
        clk         : in std_logic;
        reset       : in std_logic;
		start		: in std_logic;
		done		: out std_logic;
        instr       : in INSTR_T;
        -- for regfile:
        wr          : in std_logic;
        wraddr      : in REG_ADDR_T;
        wrdata      : in REG_DATA_T;
        -- for exec/writeback stage:
        exec_op     : out EXEC_OP_T
    );
end decode;

architecture decode_arc of decode is
    component regfile is
        port (
            clk         : in std_logic;
            reset       : in std_logic;
            rdaddr_a    : in REG_ADDR_T;
            rdaddr_b    : in REG_ADDR_T;
            wr          : in std_logic;
            wraddr      : in REG_ADDR_T;
            wrdata      : in REG_DATA_T;
            rddata_a    : out REG_DATA_T;
            rddata_b    : out REG_DATA_T
        );
    end component;
    
    signal instr_int : INSTR_T;
        alias op : OP_T is instr_int(INSTR_FIELD_OP'high downto INSTR_FIELD_OP'low);
        alias rd : REG_ADDR_T is instr_int(INSTR_FIELD_RD'high downto INSTR_FIELD_RD'low);
        alias rs : REG_ADDR_T is instr_int(INSTR_FIELD_RS'high downto INSTR_FIELD_RS'low);
        alias imm : IMM_DATA_T is instr_int(INSTR_FIELD_IMM'high downto INSTR_FIELD_IMM'low);
        alias addr : JMP_ADDR_T is instr_int(INSTR_FIELD_ADDR'high downto INSTR_FIELD_ADDR'low);
        
    alias rdaddr_a is instr(INSTR_FIELD_RD'high downto INSTR_FIELD_RD'low);
    alias rdaddr_b is instr(INSTR_FIELD_RS'high downto INSTR_FIELD_RS'low);
    
    signal regfile_dataa, regfile_datab : REG_DATA_T;
    signal stored_dataa, stored_datab : REG_DATA_T;
    signal dataa, datab : REG_DATA_T;
begin
    done <= start;
    
    regfile_inst : regfile
        port map (
            clk => clk,
            reset => reset,
            rdaddr_a => rdaddr_a,
            rdaddr_b => rdaddr_b,
            wr => wr,
            wraddr => wraddr,
            wrdata => wrdata,
            rddata_a => regfile_dataa,
            rddata_b => regfile_datab
        );
    
    data_mux : process(start, regfile_dataa, regfile_datab, stored_dataa, stored_datab)
    begin
        if(start = '1') then
            dataa <= regfile_dataa;
            datab <= regfile_datab;
        else
            dataa <= stored_dataa;
            datab <= stored_datab;
        end if;
    end process;
    
    do_decode : process(instr_int, dataa, datab)
    begin
        --default:
        exec_op <= (
            alu_op      => ALU_NOP,
            jmp_op      => JMP_NOP,
            special_op  => SPECIAL_NOP,
            dataa       => dataa,
            datab       => datab,
            rd          => rd,
            rs          => rs,
            imm         => imm,
            addr        => addr,
            use_imm     => '0',
            writeback   => '0'
        );
        
        case op is
            when OP_ADC_IN =>
                exec_op.special_op <= SPECIAL_ADC_IN;
                exec_op.writeback <= '1';
            when OP_MUL =>
                exec_op.special_op <= SPECIAL_MUL;
                exec_op.writeback <= '1';
            when OP_SIN =>
                exec_op.special_op <= SPECIAL_SIN;
                exec_op.writeback <= '1';
            when OP_MOV =>
                exec_op.writeback <= '1';
            when OP_ADD =>
                exec_op.alu_op <= ALU_ADD;
                exec_op.writeback <= '1';
            when OP_SUB =>
                exec_op.alu_op <= ALU_SUB;
                exec_op.writeback <= '1';
            when OP_INC =>
                exec_op.alu_op <= ALU_ADD;
                exec_op.imm <= std_logic_vector(to_signed(1, exec_op.imm'length));
                exec_op.use_imm <= '1';
                exec_op.writeback <= '1';
            when OP_CP =>
                exec_op.alu_op <= ALU_SUB;
            when OP_DAC_OUT =>
                exec_op.special_op <= SPECIAL_DAC_OUT;
            when OP_AND =>
                exec_op.alu_op <= ALU_AND;
                exec_op.writeback <= '1';
            when OP_OR =>
                exec_op.alu_op <= ALU_OR;
                exec_op.writeback <= '1';
            when OP_XOR =>
                exec_op.alu_op <= ALU_XOR;
                exec_op.writeback <= '1';
			when OP_SLL =>
                exec_op.alu_op <= ALU_SLL;
                exec_op.writeback <= '1';
			when OP_SRL =>
                exec_op.alu_op <= ALU_SRL;
                exec_op.writeback <= '1';
			when OP_SRA =>
                exec_op.alu_op <= ALU_SRA;
                exec_op.writeback <= '1';
            when OP_MOVI =>
                exec_op.use_imm <= '1';
                exec_op.writeback <= '1';
            when OP_ADDI =>
                exec_op.alu_op <= ALU_ADD;
                exec_op.use_imm <= '1';
                exec_op.writeback <= '1';
            when OP_ANDI =>
                exec_op.alu_op <= ALU_AND;
                exec_op.use_imm <= '1';
                exec_op.writeback <= '1';
            when OP_ORI =>
                exec_op.alu_op <= ALU_OR;
                exec_op.use_imm <= '1';
                exec_op.writeback <= '1';
            when OP_XORI =>
                exec_op.alu_op <= ALU_XOR;
                exec_op.use_imm <= '1';
                exec_op.writeback <= '1';
			when OP_SLLI =>
                exec_op.alu_op <= ALU_SLL;
                exec_op.use_imm <= '1';
                exec_op.writeback <= '1';
			when OP_SRLI =>
                exec_op.alu_op <= ALU_SRL;
                exec_op.use_imm <= '1';
                exec_op.writeback <= '1';
			when OP_SRAI =>
                exec_op.alu_op <= ALU_SRA;
                exec_op.use_imm <= '1';
                exec_op.writeback <= '1';
            when OP_JMP =>
                exec_op.jmp_op <= JMP_JMP;
            when OP_JC =>
                exec_op.jmp_op <= JMP_JC;
            when OP_JNC =>
                exec_op.jmp_op <= JMP_JNC;
            when OP_JZ =>
                exec_op.jmp_op <= JMP_JZ;
            when OP_JNZ =>
                exec_op.jmp_op <= JMP_JNZ;
			when OP_JN =>
                exec_op.jmp_op <= JMP_JN;
			when OP_JNN =>
                exec_op.jmp_op <= JMP_JNN;
            when OP_WAIT =>
                exec_op.special_op <= SPECIAL_WAIT;
            when others =>
                -- do nothing
        end case;
    end process;
    
    sync : process(reset, clk)
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                instr_int <= (others => '0');
                stored_dataa <= (others => '0');
                stored_datab <= (others => '0');
            else
                instr_int <= instr;
                if(start = '1') then
                    stored_dataa <= regfile_dataa;
                    stored_datab <= regfile_datab;
                end if;
            end if;
        end if;
    end process;
end architecture;
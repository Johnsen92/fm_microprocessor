library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;

entity decode is
    port (
        clk         : in std_logic;
        reset       : in std_logic;
        instr       : in INSTR_T;
        rdaddr_a    : in REG_ADDR_T; --address A for register file read
        rdaddr_b    : in REG_ADDR_T; --address B for register file read
        exec_op     : out EXEC_OP_T; --decoded operation for exec stage
    );
end decode;

architecture decode_arc of decode is
    signal instr_int : INSTR_T;
        alias op is instr_int(INSTR_FIELD_OP'high downto INSTR_FIELD_OP'low);
        alias rd is instr_int(INSTR_FIELD_RD'high downto INSTR_FIELD_RD'low);
        alias rs is instr_int(INSTR_FIELD_RS'high downto INSTR_FIELD_RS'low);
        alias rt is instr_int(INSTR_FIELD_RT'high downto INSTR_FIELD_RT'low);
        alias imm is instr_int(INSTR_FIELD_IMM'high downto INSTR_FIELD_IMM'low);
        alias addr is instr_int(INSTR_FIELD_ADDR'high downto INSTR_FIELD_ADDR'low);
    
    signal regfile_dataa, regfile_datab : REG_DATA_T;
begin
    do_decode : process(instr_int)
    begin
        --default:
        exec_op <= (
            alu_op      <= ALU_NOP,
            jmp_op      <= JMP_NOP,
            special_op  <= SPECIAL_NOP,
            dataa       <= regfile_dataa,
            datab       <= regfile_datab,
            rd          <= rd,
            rs          <= rs,
            rt          <= rt,
            imm         <= imm,
            addr        <= addr,
            use_imm     <= '0',
            writeback   <= '0'
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
                exec_op.imm <= std_logic_vector(to_signed(1, IMM_WIDTH));
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
            when OP_WAIT =>
                exec_op.special_op <= SPECIAL_WAIT;
        end case;
    end process;
    
    sync : process(reset, clk)
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                instr_int <= (others => '0');
            else
                instr_int <= instr;
            end if;
        end if;
    end process;
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;

entity alu is
    port (
        op  : in  ALU_OP_T;
        A   : in  REG_DATA_T;
        B   : in  REG_DATA_T;
        R   : out REG_DATA_T;
        V   : out std_logic
    );
end alu;

architecture rtl of alu is

signal R_int : REG_DATA_T;


begin
    alu_result : process(A, B, op)
    begin
        case op is
            when ALU_NOP =>
                R_int <= A;
            when ALU_ADD =>
                R_int <= std_logic_vector(signed(A) + signed(B));
            when ALU_SUB =>
                R_int <= std_logic_vector(signed(A) - signed(B));
            when ALU_AND =>
                R_int <= A AND B ;
            when ALU_OR =>
                R_int <= A OR B ;
            when ALU_XOR =>
                R_int <= A XOR B ;
			when ALU_SLL =>
				R_int <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B))));
			when ALU_SRL =>
				R_int <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B))));
			when ALU_SRA =>
				R_int <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B))));
        end case;
    end process alu_result;
    
    alu_overflow : process (A, B, op, R_int)
    begin
        case op is
            when ALU_ADD =>
                if signed(A) >= 0 and signed(B) >= 0 and signed(R_int) < 0 then
                    V <= '1';
                elsif signed(A) < 0 and signed(B) < 0 and signed(R_int)  >= 0 then
                    V <= '1';
                else
                    V <= '0';
                end if;
            when ALU_SUB =>
                if signed(A) >= 0 and signed(B) < 0 and signed(R_int) < 0 then
                    V <= '1';
                elsif signed(A) < 0 and signed(B) >= 0 and signed(R_int) >= 0 then
                    V <= '1';
                else
                    V <= '0';
                end if;
            when others =>
                V <= '0';
        end case;
    end process alu_overflow;
    
    
    R <= R_int;
    
end rtl;
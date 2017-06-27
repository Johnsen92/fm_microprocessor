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
        Z   : out std_logic;
        N   : out std_logic;
        V   : out std_logic
    );
end alu;

architecture rtl of alu is

signal R_int : REG_DATA_T;
signal V_int : std_logic;

begin
    V <= V_int;
    R <= R_int;
    
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
    
    alu_zero : process (R_int)
    begin
        if(R_int = std_logic_vector(to_unsigned(0, DATA_WIDTH))) then
            Z <= '1';
        else
            Z <= '0';
        end if;
    end process alu_zero;
    
    alu_negative : process (R_int, V_int)
    begin
        if(R_int(DATA_WIDTH-1) = '1' and V_int = '0') then
            N <= '1';
        else
            N <= '0';
        end if;
    end process alu_negative;
    
    alu_overflow : process (op, A, B, R_int)
    begin
        case op is
            when ALU_ADD =>
                if signed(A) >= 0 and signed(B) >= 0 and signed(R_int) < 0 then
                    V_int <= '1';
                elsif signed(A) < 0 and signed(B) < 0 and signed(R_int)  >= 0 then
                    V_int <= '1';
                else
                    V_int <= '0';
                end if;
            when ALU_SUB =>
                if signed(A) >= 0 and signed(B) < 0 and signed(R_int) < 0 then
                    V_int <= '1';
                elsif signed(A) < 0 and signed(B) >= 0 and signed(R_int) >= 0 then
                    V_int <= '1';
                else
                    V_int <= '0';
                end if;
            when others =>
                V_int <= '0';
        end case;
    end process alu_overflow;
    
end rtl;
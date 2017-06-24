library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity alu is
	port (
		op   : in  alu_op_type;
		A, B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		Z    : out std_logic;
		V    : out std_logic);

end alu;

architecture rtl of alu is

signal R_sign : std_logic_vector(DATA_WIDTH-1 downto 0);


begin  -- rtl



	alu_result : process(A,B,op)
	begin
		case op is
			when ALU_NOP =>
				R_sign <= A;
			when ALU_LUI =>
				R_sign <= std_logic_vector (shift_left( unsigned(B) , 16)); 
			when ALU_SLT =>
				if signed(A) < signed(B) then 
					R_sign <= (0 => '1', others => '0');
				else 
					R_sign <= (others => '0'); 
				end if;
			when ALU_SLTU =>
				if unsigned(A) < unsigned(B) then 
					R_sign <= (0 => '1', others => '0');
				else 
					R_sign <= (others => '0'); 
				end if;
			when ALU_SLL =>
				R_sign <= std_logic_vector (shift_left( unsigned(B), to_integer(unsigned(A(DATA_WIDTH_BITS-1 downto 0)))));
			when ALU_SRL =>
				R_sign <= std_logic_vector (shift_right( unsigned(B), to_integer( unsigned(A(DATA_WIDTH_BITS-1 downto 0)))));
			when ALU_SRA =>
				R_sign <= std_logic_vector (shift_right( signed(B), to_integer( unsigned(A(DATA_WIDTH_BITS-1 downto 0)))));
			when ALU_ADD =>
				R_sign <= std_logic_vector(signed(A)+ signed(B));
			when ALU_SUB =>
				R_sign <= std_logic_vector(signed(A)- signed(B)); 
			when ALU_AND =>
				R_sign <= A AND B ;
			when ALU_OR =>
				R_sign <= A OR B ;
			when ALU_XOR =>
				R_sign <= A XOR B ;
			when ALU_NOR =>
				R_sign <= NOT (A OR B);
		end case;
	end process alu_result;
	
	alu_zero_flag: process (A,B,op)
	begin 
		case op is
			when ALU_SUB =>
				if A = B then 
					Z <= '1';
				else 
					Z <= '0';
				end if;
			when others =>
				if signed(A) = 0 then 
					Z <= '1';
				else
					Z <= '0';
				end if;
		end case;
	end process alu_zero_flag;
	
	alu_overflow: process (A,B,R_sign,op)
	begin 
		case op is 
			when ALU_ADD =>
				if signed(A) >= 0 AND signed(B) >= 0 AND signed(R_sign) < 0 then -- signed unsigned??? 
					V <= '1';
				elsif signed(A) < 0 AND signed(B) < 0 AND signed(R_sign)  >= 0 then
					V <= '1';
				else
					V <= '0';
				end if;
			when ALU_SUB =>
				if signed(A) >= 0 AND signed(B) < 0 AND signed(R_sign) < 0 then 
					V <= '1';
				elsif signed(A) < 0 AND signed(B) >= 0 AND signed(R_sign) >= 0 then 
					V <= '1';
				else
					V <= '0';
				end if;
			when others =>
				V <= '0';
		end case;
	end process alu_overflow;
	
	
		R <= R_sign;
		
end rtl;

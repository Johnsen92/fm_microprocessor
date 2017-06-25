library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;

package program_package is
    
    --constant MAX_PC : integer := 16; -- TODO: incl or excl, what is at last pc if anything
    constant MAX_PC : integer := 5;
    
    subtype PC_T is integer range 0 to MAX_PC;
    type INSTR_ARRAY_T is array(0 to MAX_PC) of INSTR_T;
    constant PROGRAM : INSTR_ARRAY_T := (
		"0101000001000000000001",
		"0001000001100010000000",
		"0001010001100010000000",
		"0111010001100000001100",
		"0000110001100000000000",
		"0111100001100000000001"
    );
    
    --constant PROGRAM : INSTR_ARRAY_T := (
        --OP_MOVI & "00001" & "01001001001",              -- 1: 0000001001001001
        --OP_XORI & "00001" & "00110110110",              -- 1: 0000001111111111
        --OP_INC  & "00001" & "00000000000",              -- 1: 0000010000000000
        --OP_MOVI & "00010" & "01000000000",              -- 2: 0000001000000000
        --OP_SUB  & "00010" & "00001" & "00000" & '0',    -- 2: 1111111000000000
		--OP_MOV	& "00011" & "00010" & "00000" & '0',	-- 3: 1111111000000000
		--OP_SLLI & "00011" & "00000000110",    			-- 3: 1000000000000000
		--OP_SRLI & "00011" & "00000000010",    			-- 3: 0010000000000000
		--OP_SIN  & "00011" & "00000000000",    			-- 3: sin(1)
		--OP_MOV  & "00100" & "00011" & "00000" & '0',    -- 4: sin(1)
		--OP_MOVI	& "00100" & "00000001010",				-- 4: 0000000000001010
		--OP_WAIT	& "00100" & "00000" & "00000" & '0',	-- 4: 0000000000001010
		--OP_INC	& "00100" & "00000000000",				-- 4: 0000000000001010
		--OP_ADC_IN	& "00101" & "00000000000",			-- 5: 0xBEEF
        --(others => '0')
    --);

end program_package;
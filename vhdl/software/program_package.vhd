library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;

package program_package is
    
    --constant MAX_PC : integer := 16; -- TODO: incl or excl, what is at last pc if anything
    constant MAX_PC : integer := 5;
    
    subtype PC_T is integer range 0 to MAX_PC;
    type INSTR_ARRAY_T is array(0 to MAX_PC) of INSTR_T;
    -- constant PROGRAM : INSTR_ARRAY_T := (
        -- "0000010001000000000000",
        -- "0000100001000011000000",
        -- "0000110001100100000000",
        -- "0001000001100000000000",
        -- "0001010010000101000000",
        -- "0001100010000101000000",
        -- "0001110010000000000000",
        -- "0010000010000101000000",
        -- "0010010010000000000000",
        -- "0001000010000011111111",
        -- "0101011000000000000001",
        -- "1000000001111111111111",
        -- "1000010000000000000001",
        -- "1000100000000000011001",
        -- "1000110000111111111111",
        -- "1001000000000000000001",
        -- "0000000000000000000000"
    -- );
    
    constant PROGRAM : INSTR_ARRAY_T := (
        OP_MOVI & "00001" & "01001001001",              -- 1: 0000001001001001
        OP_XORI & "00001" & "00110110110",              -- 1: 0000001111111111
        OP_INC  & "00001" & "00000000000",              -- 1: 0000010000000000
        OP_MOVI & "00010" & "01000000000",              -- 2: 0000001000000000
        OP_SUB  & "00010" & "00001" & "00000" & '0',    -- 2: 1111111000000000
        (others => '0')
    );

end program_package;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;

package program_package is
    
    constant MAX_PC : integer := 5; -- TODO: incl or excl, what is at last pc if anything
    
    subtype PC_T is integer range 0 to MAX_PC;
    type PROGRAM_T is array(0 to MAX_PC) of INSTR_T;
    
    constant PROGRAM : PROGRAM_T := (
        OP_MOVI & "00001" & "00001001001",
        OP_XORI & "00001" & "00110110110",
        OP_INC  & "00001" & "00000000000",
        OP_MOVI & "00010" & "01000000001",
        OP_SUB  & "00001" & "00010" & "00000" & '0',
        (others => '0')
    );

end program_package;
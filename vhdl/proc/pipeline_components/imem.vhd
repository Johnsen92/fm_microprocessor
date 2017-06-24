library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;
use work.program_package.all;

entity imem is
    port (
        pc      : in PC_T;
        instr	: out INSTR_T
    );
end imem;

architecture imem_arc of imem is
	constant instruction_array : INSTR_ARRAY_T := PROGRAM;
begin
    instr <= instruction_array(pc);
end imem_arc;
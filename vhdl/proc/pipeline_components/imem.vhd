library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;

entity imem is
    port (
        addr 	: in JMP_ADDR_T;
        instr	: out INSTR_T;
    );
end imem;

architecture imem_arc of imem is
	type instruction_array_type is array(15 downto 0) of INSTR_T;
	constant instruction_array : instruction_array_type := (
		"0000010001000000000000",
		"0000100001000011000000",
		"0000110001100100000000",
		"0001000001100000000000",
		"0001010010000101000000",
		"0001100010000101000000",
		"0001110010000000000000",
		"0010000010000101000000",
		"0010010010000000000000",
		"0001000010000011111111",
		"0101011000000000000001",
		"1000000001111111111111",
		"1000010000000000000001",
		"1000100000000000011001",
		"1000110000111111111111",
		"1001000000000000000001"

	);
begin
    instr <= instruction_array(unsigned(addr));
end imem_arc;
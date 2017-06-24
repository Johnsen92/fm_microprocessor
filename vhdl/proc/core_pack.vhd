library ieee;
use ieee.std_logic_1164.all;

use work.sine_cordic_constants.all;

package core_pack is

	-- width of a dataword
	-- constant DATA_WIDTH_BITS  : integer := 16;
	-- constant DATA_WIDTH       : integer := 2**DATA_WIDTH_BITS;
	constant DATA_WIDTH_BITS  : integer := 16;
	constant DATA_WIDTH		  : integer := 16;

	constant BYTE_WIDTH       : integer := 8;
	constant BYTES_PER_WORD   : integer := (DATA_WIDTH+BYTE_WIDTH-1)/BYTE_WIDTH;
		
	-- width of an instruction word
	constant INSTR_WIDTH_BITS : integer := 22;
	constant INSTR_WIDTH      : integer := 2**INSTR_WIDTH_BITS;

	-- size of instruction memory
	-- constant PC_WIDTH         : integer := 11;
	-- the exception handling routine is at address 0x80
	constant EXCEPTION_PC 	  : std_logic_vector := "00000010000000";
	
	-- regfile properties
	constant REG_BITS         : integer := 5;
	constant REG_COUNT        : integer := 2**REG_BITS;
	
	-- bits to address memory
	constant ADDR_WIDTH_BITS       : integer := 16;

	-- number of external interrupts
	constant INTR_COUNT       : integer := 3;
	
	-- size of immediates used
	constant IMM_WIDTH_BITS	  : integer := 11;
	constant IMM_WIDTH		  : integer := 2**IMM_WIDTH_BITS;
	
end core_pack;

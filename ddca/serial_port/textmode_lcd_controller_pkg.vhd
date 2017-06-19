LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

PACKAGE textmode_lcd_controller_pkg IS
	constant INSTR_NOP : std_logic_vector(7 downto 0) := (others=>'0');
	constant INSTR_SET_CHAR : std_logic_vector(7 downto 0) := x"01";
	constant INSTR_CLEAR_SCREEN : std_logic_vector(7 downto 0) := x"02";
	constant INSTR_SET_CURSOR_POSITION : std_logic_vector(7 downto 0) := x"03";
	constant INSTR_CFG : std_logic_vector(7 downto 0) := x"04";
	constant INSTR_DELETE : std_logic_vector(7 downto 0) := x"05";
	constant INSTR_MOVE_CURSOR_NEXT : std_logic_vector(7 downto 0) := x"06";
	constant INSTR_NEW_LINE : std_logic_vector(7 downto 0) := x"07";	
	constant BACKSPACE : std_logic_vector(7 downto 0) := x"08";
	constant CARRIAGE_RETURN : std_logic_vector(7 downto 0) := x"0D";
	constant LINE_FEED : std_logic_vector(7 downto 0) := x"0A";
	COMPONENT textmode_lcd_controller_fsm IS
		GENERIC(
			CLK_FREQ : integer;
			-- given in ns
			CLK_CYCLE_TIME : integer
		);
		PORT(
			SIGNAL res_n, clk, wr : IN std_logic;	
			SIGNAL instr_out : OUT std_logic_vector(7 DOWNTO 0);
			SIGNAL rs, rw, busy, lcd_blon, lcd_on, en : OUT std_logic;
			SIGNAL instr_in : IN std_logic_vector(7 DOWNTO 0);
			SIGNAL instr_data : IN std_logic_vector(15 DOWNTO 0)
		);
	END COMPONENT textmode_lcd_controller_fsm;
END PACKAGE;
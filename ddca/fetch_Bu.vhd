LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.core_pack.all;

ENTITY fetch IS
	
	PORT (
		clk, reset : IN	 std_logic;
		stall      : IN  std_logic;
		pcsrc	   : IN	 std_logic;
		pc_in	   : IN	 std_logic_vector(PC_WIDTH-1 DOWNTO 0);
		pc_out	   : OUT std_logic_vector(PC_WIDTH-1 DOWNTO 0);
		instr	   : OUT std_logic_vector(INSTR_WIDTH-1 DOWNTO 0));

END fetch;

ARCHITECTURE rtl OF fetch IS
	SIGNAL pc_in_int : std_logic_vector(PC_WIDTH - 1 DOWNTO 0);
	SIGNAL pcsrc_int : std_logic;
	COMPONENT imem_altera IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	END COMPONENT imem_altera;
BEGIN  -- rtl
	imem_instr : imem_altera
	PORT MAP(
		address => pc_in_int
	); 
	
	sync : PROCESS(clk, reset)
	BEGIN
		IF rising_edge(clk) AND stall /= '1' THEN
			IF pcsrc = '1' THEN
				pc_in_int <= pc_in;
			ELSE
				pc_in_int <= 
			END IF;
			 
	END PROCESS;
END rtl;

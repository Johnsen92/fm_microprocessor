LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.core_pack.all;
USE work.op_pack.all;

ENTITY wb IS
	PORT (
		clk, reset : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;
		op	   	   : in  wb_op_type;
		rd_in      : in  std_logic_vector(REG_BITS-1 downto 0);
		aluresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		memresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_out     : out std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
		result     : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		regwrite   : out std_logic := '0'
	);
END wb;

ARCHITECTURE rtl OF wb IS
	SIGNAL rd_in_int : std_logic_vector(REG_BITS - 1 DOWNTO 0) := (others => '0');
	SIGNAL op_int : wb_op_type := WB_NOP;
BEGIN  -- rtl	
	sync : PROCESS(clk, reset, flush)
	BEGIN
		IF reset = '0' THEN
			regwrite <= '0';
			rd_out <= (OTHERS => '0');
			result <= (OTHERS => '0');
		ELSIF flush = '1' THEN
			regwrite <= '0';
			rd_out <= (OTHERS => '0');
			result <= (OTHERS => '0');
		ELSIF rising_edge(clk) AND stall /= '1' THEN		
			IF op.memtoreg = '1' THEN
				result <= memresult;
			ELSE
				result <= aluresult;
			END IF;
			regwrite <= op.regwrite;
			rd_out <= rd_in;
		END IF;
	END PROCESS sync;
END rtl;

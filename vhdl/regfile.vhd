LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.core_pack.all;

ENTITY regfile IS
	PORT (
		clk, reset       : IN  std_logic;
		stall            : IN  std_logic;
		rdaddr1, rdaddr2 : IN  std_logic_vector(REG_BITS-1 DOWNTO 0);
		rddata1, rddata2 : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
		wraddr		 	 : IN  std_logic_vector(REG_BITS-1 DOWNTO 0);
		wrdata		 	 : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
		regwrite         : IN  std_logic
	);
END ENTITY regfile;

ARCHITECTURE rtl OF regfile IS
	TYPE reg_type IS ARRAY(2**REG_BITS - 1 DOWNTO 0) OF std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL wraddr_int : std_logic_vector(REG_BITS-1 DOWNTO 0);
	SIGNAL wrdata_int : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL rdaddr1_int, rdaddr2_int : std_logic_vector(REG_BITS-1 DOWNTO 0);
	SIGNAL regwrite_int : std_logic;
	-- regfile as array
	SIGNAL regfile : reg_type := (OTHERS=>(OTHERS => '0'));  
	--SIGNAL regfile : reg_type;
BEGIN  -- rtl	

	output : PROCESS(wraddr_int, rdaddr1_int, rdaddr2_int, wrdata, wrdata_int, wraddr, regwrite_int, regwrite)
	BEGIN

	
		-- read from rdaddr1
		IF wraddr = rdaddr1_int AND regwrite = '1' AND rdaddr1_int /= "00000" AND stall /= '1' THEN
			rddata1 <= wrdata;
		ELSE
			IF rdaddr1_int = "00000" THEN
				rddata1 <= (OTHERS => '0');
			ELSE
				rddata1 <= regfile(to_integer(unsigned(rdaddr1_int)));
			END IF;
		END IF;

		-- read from rdaddr2
		IF wraddr = rdaddr2_int AND regwrite = '1' AND rdaddr2_int /= "00000" AND stall /= '1' THEN
			rddata2 <= wrdata;
		ELSE
			IF rdaddr2_int = "00000" THEN
				rddata2 <= (OTHERS => '0');
			ELSE
				rddata2 <= regfile(to_integer(unsigned(rdaddr2_int)));
			END IF;
		END IF;	
	END PROCESS output;

	sync : PROCESS(clk, reset)
	BEGIN
		IF reset = '0' THEN
			rdaddr1_int <= (OTHERS => '0');
			rdaddr2_int <= (OTHERS => '0');
			wraddr_int <= (OTHERS => '0');
			regwrite_int <= '0';
			wrdata_int <= (OTHERS => '0');
		ELSE	
			IF rising_edge(clk) AND stall /= '1' THEN
				rdaddr1_int <= rdaddr1;
				rdaddr2_int <= rdaddr2;
				wraddr_int <= wraddr;
				wrdata_int <= wrdata;
				regwrite_int <= regwrite;
				-- write to wraddr
				IF regwrite = '1' THEN 
					IF to_integer(unsigned(wraddr)) /= 0 THEN
						regfile(to_integer(unsigned(wraddr))) <= wrdata;
					END IF;
				END IF;
			END IF;	
		END IF;
	END PROCESS;
END rtl;

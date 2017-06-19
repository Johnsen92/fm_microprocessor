LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.core_pack.all;
USE work.op_pack.all;

ENTITY memu IS
	PORT (
		op   : IN  mem_op_type;
		A    : IN  std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
		W    : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
		D    : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
		M    : OUT mem_out_type;
		R    : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
		XL   : OUT std_logic;
		XS   : OUT std_logic
	);
END memu;

ARCHITECTURE rtl of memu is
	SIGNAL XL_int, XS_int		: std_logic;
BEGIN  -- rtl

	output: PROCESS (op, A, W, D)
	BEGIN
		M.byteena	<= "0000";
		M.wrdata	<= (OTHERS => '0');
		IF (op.memtype = MEM_B) or (op.memtype = MEM_BU) THEN
			CASE A(1 DOWNTO 0) is
				WHEN "00" =>
					M.byteena <= "1000";
					M.wrdata(31 DOWNTO 24) <= W(7 DOWNTO 0);
				WHEN "01" =>
					M.byteena <= "0100";
					M.wrdata(23 DOWNTO 16) <= W(7 DOWNTO 0);
				WHEN "10" =>
					M.byteena <= "0010";
					M.wrdata(15 DOWNTO 8) <= W(7 DOWNTO 0);
				WHEN "11" =>
					M.byteena <= "0001";
					M.wrdata(7 DOWNTO 0) <= W(7 DOWNTO 0);
				WHEN OTHERS =>
					NULL;
			END CASE;

		ELSIF (op.memtype = MEM_H) or (op.memtype = MEM_HU) THEN
			CASE A(1) is
				WHEN '0' =>
					M.byteena <= "1100";
					M.wrdata(31 DOWNTO 16) <= W(15 DOWNTO 0);
				WHEN '1' =>
					M.byteena <= "0011";
					M.wrdata(15 DOWNTO 0) <= W(15 DOWNTO 0);
				WHEN OTHERS =>
					NULL;
			END CASE;
		ELSE	-- MEM_W
			M.byteena <= "1111";
			M.wrdata <= W;

		END IF;
	END PROCESS output;

	M.address	<= A;
	M.wr		<= op.memwrite AND NOT XS_int;
	M.rd		<= op.memread AND NOT XL_int;
	XS		<= XS_int;
	XL		<= XL_int;

	input : PROCESS (op, A, W, D)
	BEGIN
		CASE op.memtype is
			WHEN MEM_B =>
				CASE A(1 DOWNTO 0) is
					WHEN "00" =>
						R(DATA_WIDTH - 1 DOWNTO 8)	<= (OTHERS => D(31));
						R( 7 DOWNTO 0)	<= D(31 DOWNTO 24);
					WHEN "01" =>
						R(DATA_WIDTH - 1 DOWNTO 8)	<= (OTHERS => D(23));
						R( 7 DOWNTO 0)	<= D(23 DOWNTO 16);
					WHEN "10" =>
						R(DATA_WIDTH - 1 DOWNTO 8)	<= (OTHERS => D(15));
						R( 7 DOWNTO 0)	<= D(15 DOWNTO 8);
					WHEN "11" =>
						R(DATA_WIDTH - 1 DOWNTO 8)	<= (OTHERS => D( 7));
						R( 7 DOWNTO 0)	<= D( 7 DOWNTO 0);
					WHEN OTHERS =>
						NULL;
				END CASE;
			WHEN MEM_BU =>
				R(31 DOWNTO 8)	<= (OTHERS => '0');
				CASE A(1 DOWNTO 0) is
					WHEN "00" =>
						R( 7 DOWNTO 0)	<= D(31 DOWNTO 24);
					WHEN "01" =>
						R( 7 DOWNTO 0)	<= D(23 DOWNTO 16);
					WHEN "10" =>
						R( 7 DOWNTO 0)	<= D(15 DOWNTO 8);
					WHEN "11" =>
						R( 7 DOWNTO 0)	<= D( 7 DOWNTO 0);
					WHEN OTHERS =>
						NULL;
				END CASE;
			WHEN MEM_H =>
				CASE A(1) is
					WHEN '0' =>
						R(DATA_WIDTH - 1 DOWNTO 16)	<= (OTHERS => D(DATA_WIDTH - 1));
						R(15 DOWNTO  0)	<= D(31 DOWNTO 16);

					WHEN '1' =>
						R(DATA_WIDTH - 1 DOWNTO 16)	<= (OTHERS => D(15));
						R(15 DOWNTO  0)	<= D(15 DOWNTO 0);

					WHEN OTHERS =>
						NULL;
				END CASE;
			WHEN MEM_HU =>
				R(DATA_WIDTH - 1 DOWNTO 16)	<= (OTHERS => '0');
				CASE A(1) is
					WHEN '0' =>
						R(15 DOWNTO 0)	<= D(DATA_WIDTH - 1 DOWNTO 16);
					WHEN '1' =>
						R(15 DOWNTO 0)	<= D(15 DOWNTO 0);
					WHEN OTHERS =>
						NULL;
				END CASE;
			WHEN MEM_W =>
				R <= D;
		END CASE;
	END PROCESS input;

	exc : PROCESS (op, A, W, D)
	BEGIN
		XL_int <= '0';
		XS_int <= '0';
		IF A = "000000000000000000000" THEN
			IF op.memread = '1' THEN
				XL_int <= '1';
			END IF;

			IF op.memwrite = '1' THEN
				XS_int <= '1';
			END IF;
		END IF;
		CASE op.memtype is
			WHEN MEM_H =>
				IF A(0) /= '0' THEN
					IF op.memread = '1' THEN
						XL_int <= '1';
					END IF;

					IF op.memwrite = '1' THEN
						XS_int <= '1';
					END IF;
				END IF;
			WHEN MEM_HU =>
				IF A(0) /= '0' THEN
					IF op.memread = '1' THEN
						XL_int <= '1';
					END IF;

					IF op.memwrite = '1' THEN
						XS_int <= '1';
					END IF;
				END IF;
			WHEN MEM_W =>
				IF A(1 DOWNTO 0) /= "00" THEN
					IF op.memread = '1' THEN
						XL_int <= '1';
					END IF;

					IF op.memwrite = '1' THEN
						XS_int <= '1';
					END IF;
				END IF;
			WHEN OTHERS =>
				NULL;
		END CASE;
	END PROCESS exc;
END rtl;

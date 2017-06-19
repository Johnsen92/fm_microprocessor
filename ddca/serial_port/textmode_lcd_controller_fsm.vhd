LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.NUMERIC_STD.all;
USE work.textmode_lcd_controller_pkg.all;


ENTITY textmode_lcd_controller_fsm IS
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
END ENTITY textmode_lcd_controller_fsm;

ARCHITECTURE textmode_lcd_controller_fsm_a OF textmode_lcd_controller_fsm IS
	TYPE CONTROLLER_STATE_TYPE IS (
		CONTROLLER_STATE_IDLE, 
		CONTROLLER_STATE_INITIALIZE_STEP_1, 
		CONTROLLER_STATE_WAIT_INITIALIZE_STEP_1, 
		CONTROLLER_STATE_INITIALIZE_STEP_2, 
		CONTROLLER_STATE_WAIT_INITIALIZE_STEP_2, 
		CONTROLLER_STATE_INITIALIZE_STEP_3,
		CONTROLLER_STATE_WAIT_INITIALIZE_STEP_3, 
		CONTROLLER_STATE_INITIALIZE_STEP_4,	
		CONTROLLER_STATE_WAIT_INITIALIZE_STEP_4, 
		CONTROLLER_STATE_INITIALIZE_STEP_5,	
		CONTROLLER_STATE_WAIT_INITIALIZE_STEP_5, 
		CONTROLLER_STATE_INITIALIZE_STEP_6,	
		CONTROLLER_STATE_WAIT_INITIALIZE_STEP_6, 
		CONTROLLER_STATE_INITIALIZE_STEP_7,
		CONTROLLER_STATE_WAIT_INITIALIZE_STEP_7, 	
		CONTROLLER_STATE_WAIT_INSTRUCTION,
		CONTROLLER_STATE_DO_INSTR_NOP,
		CONTROLLER_STATE_DO_INSTR_DELETE,
		CONTROLLER_STATE_WAIT_INSTR_DELETE,
		CONTROLLER_STATE_DO_INSTR_CLEAR_POSITION,
		CONTROLLER_STATE_WAIT_INSTR_CLEAR_POSITION,
		CONTROLLER_STATE_DO_INSTR_CLEAR_SCREEN,
		CONTROLLER_STATE_DO_INSTR_MOVE_CURSOR_NEXT,
		CONTROLLER_STATE_DO_INSTR_NEW_LINE,
		CONTROLLER_STATE_WAIT_INSTR_NEW_LINE,
		CONTROLLER_STATE_DO_INSTR_CFG,
		CONTROLLER_STATE_DO_INSTR_SET_CURSOR_POSITION,
		CONTROLLER_STATE_DO_INSTR_SET_CHAR,
		CONTROLLER_STATE_WAIT_INSTR_SET_CHAR,
		CONTROLLER_STATE_WAIT_END_INSTRUCTION,
		CONTROLLER_STATE_DO_INSTR_DELETE_LINE,
		CONTROLLER_STATE_WAIT_INSTR_DELETE_LINE,
		CONTROLLER_STATE_DO_INSTR_MOVE_CURSOR_DELETE_LINE,
		CONTROLLER_STATE_WAIT_INSTR_MOVE_CURSOR_DELETE_LINE
	);	
	SIGNAL controller_state : CONTROLLER_STATE_TYPE;
	SIGNAL controller_state_next : CONTROLLER_STATE_TYPE;
	SIGNAL rs_int, rw_int, rs_next, rw_next, current_line, current_line_next, en_int, en_next : std_logic;
	SIGNAL clk_cnt, clk_cnt_next : integer RANGE 0 TO 38501;
	SIGNAL wait_time, wait_time_next : integer RANGE 0 TO 1540001;
	SIGNAL instr_cnt, instr_cnt_next, cursor_col, cursor_col_next : integer RANGE 0 TO 16;
	SIGNAL en_cnt, en_cnt_next : integer RANGE 0 TO 4;
	SIGNAL instr_out_next, instr_out_int: std_logic_vector(7 DOWNTO 0);
	SIGNAL instr_data_buffer, instr_data_buffer_next: std_logic_vector(15 DOWNTO 0);
	BEGIN
		lcd_blon <= '1';
		lcd_on <= '1';
		state_transmission : PROCESS(controller_state, clk_cnt, instr_cnt, wait_time, cursor_col, instr_in, en_cnt, wr, instr_data)
		BEGIN
			controller_state_next <= controller_state;
			CASE controller_state IS 
				WHEN CONTROLLER_STATE_IDLE =>
					controller_state_next <= CONTROLLER_STATE_INITIALIZE_STEP_1;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_1 =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_INITIALIZE_STEP_1;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_1 =>
					IF clk_cnt * CLK_CYCLE_TIME > 40000 THEN
						controller_state_next <= CONTROLLER_STATE_INITIALIZE_STEP_2;
					END IF;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_2 =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_INITIALIZE_STEP_2;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_2 =>
					IF clk_cnt * CLK_CYCLE_TIME > 40000 THEN
						controller_state_next <= CONTROLLER_STATE_INITIALIZE_STEP_3;
					END IF;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_3 =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_INITIALIZE_STEP_3;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_3 =>
					IF clk_cnt * CLK_CYCLE_TIME > 40000 THEN
						controller_state_next <= CONTROLLER_STATE_INITIALIZE_STEP_4;
					END IF;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_4 =>
					IF en_cnt = 3 THEN					
						controller_state_next <= CONTROLLER_STATE_WAIT_INITIALIZE_STEP_4;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_4 =>
					IF clk_cnt * CLK_CYCLE_TIME > 40000 THEN
						controller_state_next <= CONTROLLER_STATE_INITIALIZE_STEP_5;
					END IF;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_5 =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_INITIALIZE_STEP_5;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_5 =>
					IF clk_cnt * CLK_CYCLE_TIME > 40000 THEN
						controller_state_next <= CONTROLLER_STATE_INITIALIZE_STEP_6;
					END IF;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_6 =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_INITIALIZE_STEP_6;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_6 =>
					IF clk_cnt * CLK_CYCLE_TIME > 1540000 THEN
						controller_state_next <= CONTROLLER_STATE_INITIALIZE_STEP_7;
					END IF;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_7 =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_INITIALIZE_STEP_7;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_7 =>
					IF clk_cnt * CLK_CYCLE_TIME > 40000 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_INSTRUCTION;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INSTRUCTION =>
					IF wr = '1' THEN
						CASE instr_in IS 
							WHEN INSTR_NOP =>
								controller_state_next <= CONTROLLER_STATE_DO_INSTR_NOP;
							WHEN INSTR_CFG =>
								controller_state_next <= CONTROLLER_STATE_DO_INSTR_CFG;
							WHEN INSTR_SET_CHAR =>
								IF instr_data(7 DOWNTO 0) = BACKSPACE THEN
									controller_state_next <= CONTROLLER_STATE_DO_INSTR_DELETE;
								ELSE
									IF instr_data(7 DOWNTO 0) = CARRIAGE_RETURN OR instr_data(7 DOWNTO 0) = LINE_FEED THEN
										controller_state_next <= CONTROLLER_STATE_DO_INSTR_NEW_LINE;
									ELSE
										controller_state_next <= CONTROLLER_STATE_DO_INSTR_SET_CHAR;
									END IF;
								END IF;
							WHEN INSTR_DELETE =>
								controller_state_next <= CONTROLLER_STATE_DO_INSTR_DELETE;
							WHEN INSTR_MOVE_CURSOR_NEXT =>
								controller_state_next <= CONTROLLER_STATE_DO_INSTR_MOVE_CURSOR_NEXT;
							WHEN INSTR_NEW_LINE =>
								controller_state_next <= CONTROLLER_STATE_DO_INSTR_NEW_LINE;
							WHEN INSTR_SET_CURSOR_POSITION =>
								controller_state_next <= CONTROLLER_STATE_DO_INSTR_SET_CURSOR_POSITION;
							WHEN OTHERS =>
								controller_state_next <= CONTROLLER_STATE_WAIT_INSTRUCTION;
						END CASE;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_END_INSTRUCTION =>
					IF clk_cnt * CLK_CYCLE_TIME > wait_time THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_INSTRUCTION;
					END IF;
				WHEN CONTROLLER_STATE_DO_INSTR_CLEAR_SCREEN =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_END_INSTRUCTION;
					END IF;
				WHEN CONTROLLER_STATE_DO_INSTR_CFG =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_END_INSTRUCTION;
					END IF;
				WHEN CONTROLLER_STATE_DO_INSTR_NOP =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_END_INSTRUCTION;
					END IF;
				WHEN CONTROLLER_STATE_DO_INSTR_NEW_LINE =>
					IF en_cnt = 3 THEN
						IF instr_cnt < 16 THEN
							controller_state_next <= CONTROLLER_STATE_WAIT_INSTR_NEW_LINE;
						ELSE
							controller_state_next <= CONTROLLER_STATE_WAIT_END_INSTRUCTION;
						END IF;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INSTR_NEW_LINE => 
					IF clk_cnt * CLK_CYCLE_TIME > 40000 THEN
						controller_state_next <= CONTROLLER_STATE_DO_INSTR_DELETE_LINE;
					END IF;
				WHEN CONTROLLER_STATE_DO_INSTR_DELETE_LINE =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_INSTR_DELETE_LINE;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INSTR_DELETE_LINE =>
					IF clk_cnt * CLK_CYCLE_TIME > 44000 THEN
						IF instr_cnt < 16 THEN
							controller_state_next <= CONTROLLER_STATE_DO_INSTR_DELETE_LINE;
						ELSE	
							controller_state_next <= CONTROLLER_STATE_DO_INSTR_NEW_LINE;
						END IF;
					END IF;
				WHEN CONTROLLER_STATE_DO_INSTR_SET_CHAR =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_INSTR_SET_CHAR;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INSTR_SET_CHAR =>				
					IF clk_cnt * CLK_CYCLE_TIME > 44000 THEN
						IF cursor_col = 16 THEN 
							controller_state_next <= CONTROLLER_STATE_DO_INSTR_NEW_LINE;
						ELSE			
							controller_state_next <= CONTROLLER_STATE_WAIT_INSTRUCTION;
						END IF;
					END IF;
				WHEN CONTROLLER_STATE_DO_INSTR_SET_CURSOR_POSITION =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_END_INSTRUCTION;
					END IF;
				WHEN CONTROLLER_STATE_DO_INSTR_DELETE =>
					IF en_cnt = 3 THEN
						IF instr_cnt = 0 THEN
							controller_state_next <= CONTROLLER_STATE_WAIT_INSTR_DELETE;
						ELSE	
							controller_state_next <= CONTROLLER_STATE_WAIT_END_INSTRUCTION;
						END IF;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INSTR_DELETE =>
					IF clk_cnt * CLK_CYCLE_TIME > 40000 THEN
						controller_state_next <= CONTROLLER_STATE_DO_INSTR_CLEAR_POSITION;
					END IF;
				WHEN CONTROLLER_STATE_DO_INSTR_CLEAR_POSITION =>
					IF en_cnt = 3 THEN
						controller_state_next <= CONTROLLER_STATE_WAIT_INSTR_CLEAR_POSITION;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_INSTR_CLEAR_POSITION =>
					IF clk_cnt * CLK_CYCLE_TIME > 44000 THEN
						controller_state_next <= CONTROLLER_STATE_DO_INSTR_DELETE;
					END IF;
				WHEN CONTROLLER_STATE_DO_INSTR_MOVE_CURSOR_NEXT =>
					IF en_cnt = 3 THEN
						IF cursor_col + 1 = 16 THEN
							controller_state_next <= CONTROLLER_STATE_DO_INSTR_NEW_LINE;		
						ELSE
							controller_state_next <= CONTROLLER_STATE_WAIT_END_INSTRUCTION;
						END IF;
					END IF;
				WHEN OTHERS =>
					NULL;
			END CASE;
		END PROCESS state_transmission;
		
		state_output : PROCESS(controller_state, instr_out_int, rs_int, rw_int, clk_cnt, wait_time, instr_cnt, current_line, cursor_col, instr_data, en_cnt, en_int, instr_data_buffer, wr)
		BEGIN
			instr_out_next <= instr_out_int;
			rs_next <= rs_int;
			rw_next <= rw_int;
			clk_cnt_next <= clk_cnt;
			wait_time_next <= wait_time;
			instr_cnt_next <= instr_cnt;
			current_line_next <= current_line;
			cursor_col_next <= cursor_col;
			en_cnt_next <= en_cnt;
			en_next <= en_int;
			instr_data_buffer_next <= instr_data_buffer;
			CASE controller_state IS
				WHEN CONTROLLER_STATE_IDLE =>
					busy <= '1';
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_1 =>
					busy <= '1';
					IF en_cnt = 0 THEN
						en_next <= '1';
						instr_out_next <= "00110000";
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_1 =>
					en_cnt_next <= 0;
					busy <= '1';
					instr_out_next <= "00000000";
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_2 =>
					clk_cnt_next <= 0;
					busy <= '1';
					IF en_cnt = 0 THEN
						en_next <= '1';
						instr_out_next <= "00110000";
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_2 =>
					en_cnt_next <= 0;
					busy <= '1';
					instr_out_next <= "00000000";
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_3 =>
					clk_cnt_next <= 0;
					busy <= '1';
					IF en_cnt = 0 THEN
						en_next <= '1';
						instr_out_next <= "00110000";
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_3 =>
					en_cnt_next <= 0;
					busy <= '1';
					instr_out_next <= "00000000";
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_4 =>
					clk_cnt_next <= 0;
					busy <= '1';
					IF en_cnt = 0 THEN
						en_next <= '1';
						instr_out_next <= "00111100";
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_4 =>
					en_cnt_next <= 0;
					busy <= '1';
					instr_out_next <= "00000000";
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_5 =>
					clk_cnt_next <= 0;
					busy <= '1';
					IF en_cnt = 0 THEN
						en_next <= '1';
						instr_out_next <= "00001111";
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_5 =>
					en_cnt_next <= 0;
					busy <= '1';
					instr_out_next <= "00000000";
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_6 =>
					clk_cnt_next <= 0;
					busy <= '1';
					IF en_cnt = 0 THEN
						en_next <= '1';
						instr_out_next <= "00000001";
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_6 =>
					en_cnt_next <= 0;
					busy <= '1';
					instr_out_next <= "00000000";
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_INITIALIZE_STEP_7 =>
					clk_cnt_next <= 0;
					busy <= '1';
					IF en_cnt = 0 THEN
						en_next <= '1';
						instr_out_next <= "00000110";
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INITIALIZE_STEP_7 =>
					en_cnt_next <= 0;
					busy <= '1';
					instr_out_next <= "00000000";
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INSTRUCTION =>
					en_cnt_next <= 0;
					rs_next <= '0';
					rw_next <= '0';
					instr_out_next <= "00000000";
					instr_cnt_next <= 0;
					clk_cnt_next <= 0;
					busy <= '0';
					IF wr = '1' THEN
						instr_data_buffer_next <= instr_data;
					END IF;
				WHEN CONTROLLER_STATE_WAIT_END_INSTRUCTION =>
					en_cnt_next <= 0;
					en_next <= '0';
					busy <= '1';
					rs_next <= '0';
					rw_next <= '0';
					clk_cnt_next <= clk_cnt + 1;
					instr_out_next <= "00000000";
				WHEN CONTROLLER_STATE_DO_INSTR_CLEAR_SCREEN =>
					busy <= '1';
					wait_time_next <= 1540000;
					rs_next <= '0';
					rw_next <= '0';
					instr_out_next <= "00000001";
				WHEN CONTROLLER_STATE_DO_INSTR_CFG =>
					busy <= '1';					
					IF en_cnt = 0 THEN
						wait_time_next <= 40000;
						rs_next <= '0';
						rw_next <= '0';
						instr_out_next <= "00000000";
						en_next <= '1';
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_DO_INSTR_NOP =>
					busy <= '1';					
					IF en_cnt = 0 THEN
						wait_time_next <= 40000;
						rs_next <= '0';
						rw_next <= '0';
						instr_out_next <= "00000000";
						en_next <= '1';
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_DO_INSTR_NEW_LINE =>
					clk_cnt_next <= 0;
					busy <= '1';
					IF en_cnt = 0 THEN
						en_next <= '1';
						wait_time_next <= 40000;
						rs_next <= '0';
						rw_next <= '0';
						IF current_line = '0' THEN
							instr_out_next <= "11000000";
						ELSE
							instr_out_next <= "10000000";
						END IF;
						IF instr_cnt >= 16 THEN
							current_line_next <= NOT current_line;
							cursor_col_next <= 0;
						END IF;
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INSTR_NEW_LINE =>
					en_cnt_next <= 0;
					rs_next <= '0';
					rw_next <= '0';
					busy <= '1';
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_DO_INSTR_DELETE_LINE =>
					busy <= '1';	
				   clk_cnt_next <= 0;				
					IF en_cnt = 0 THEN					
						en_next <= '1';						
						rs_next <= '1';
						rw_next <= '0';
						instr_out_next <= "00100000";
						instr_cnt_next <= instr_cnt + 1;
					ELSE
						IF en_cnt = 2 THEN 
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INSTR_DELETE_LINE =>
					en_cnt_next <= 0;
					busy <= '1';
					rs_next <= '0';
					rw_next <= '0';
					instr_out_next <= "00000000";
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_DO_INSTR_SET_CHAR =>
					busy <= '1';
					IF en_cnt = 0 THEN 
						en_next <= '1';
						wait_time_next <= 40000;
						cursor_col_next <= cursor_col + 1;
						rs_next <= '1';
						rw_next <= '0';
						instr_out_next <= instr_data_buffer(7 DOWNTO 0);
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INSTR_SET_CHAR =>
					busy <= '1';
					en_cnt_next <= 0;
					rs_next <= '0';
					rw_next <= '0';
					instr_out_next <= "00000000";
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_DO_INSTR_SET_CURSOR_POSITION =>
					busy <= '1';
					IF en_cnt = 0 THEN 
						wait_time_next <= 44000;
						rs_next <= '0';
						rw_next <= '0';
						en_next <= '1';
						cursor_col_next <= to_integer(ieee.NUMERIC_STD.unsigned(instr_data_buffer(11 DOWNTO 8)));
						current_line_next <= instr_data_buffer(0);
						instr_out_next(6) <= instr_data_buffer(0);
						instr_out_next(3 DOWNTO 0) <= instr_data_buffer(11 DOWNTO 8);
					ELSE
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_DO_INSTR_DELETE =>
					busy <= '1';
					clk_cnt_next <= 0;
					IF en_cnt = 0 THEN					
						en_next <= '1';						
						rs_next <= '0';
						rw_next <= '0';
						wait_time_next <= 40000; 
						instr_out_next(7) <= '1';
						instr_out_next(5 DOWNTO 4) <= "00";
						IF cursor_col > 0 THEN
							instr_out_next(6) <= current_line;
							instr_out_next(3 DOWNTO 0) <= std_logic_vector(to_unsigned(cursor_col - 1, 4));
						ELSE
							instr_out_next(6) <= NOT current_line;
							instr_out_next(3 DOWNTO 0) <= std_logic_vector(to_unsigned(15, 4));
						END IF;
						IF instr_cnt > 0 THEN
							IF cursor_col > 0 THEN
								cursor_col_next <= cursor_col - 1;
							ELSE
								cursor_col_next <= 15;
								current_line_next <= NOT current_line;
						END IF;
					END IF;
					ELSE 
						IF en_cnt = 2 THEN 
							en_next <= '0';
						END IF;
					END IF;
					
					en_cnt_next <= en_cnt + 1;
				WHEN CONTROLLER_STATE_WAIT_INSTR_DELETE =>
					en_cnt_next <= 0;
					rs_next <= '0';
					rw_next <= '0';
					busy <= '1';
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_DO_INSTR_CLEAR_POSITION =>
					busy <= '1';
					clk_cnt_next <= 0;
					IF en_cnt = 0 THEN					
						en_next <= '1';
						rs_next <= '1';
						rw_next <= '0';
						instr_out_next <= "00100000";
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					instr_cnt_next <= instr_cnt + 1;
					en_cnt_next <= en_cnt + 1;					
				WHEN CONTROLLER_STATE_WAIT_INSTR_CLEAR_POSITION =>
					rs_next <= '0';
					rw_next <= '0';
					en_cnt_next <= 0;
					busy <= '1';
					clk_cnt_next <= clk_cnt + 1;
				WHEN CONTROLLER_STATE_DO_INSTR_MOVE_CURSOR_NEXT =>
					busy <= '1';
					IF en_cnt = 0 THEN 
						en_next <= '1';
						wait_time_next <= 44000;
						IF cursor_col + 1 < 16 THEN
							rs_next <= '1';
							rw_next <= '0';
							instr_out_next <= "00100000";		
						END IF;
						cursor_col_next <= cursor_col + 1;
					ELSE 
						IF en_cnt = 2 THEN
							en_next <= '0';
						END IF;
					END IF;
					en_cnt_next <= en_cnt + 1;
				WHEN OTHERS =>
					busy <= '0';
			END CASE;
		END PROCESS state_output; 	

		sync : PROCESS(clk, res_n)
		BEGIN
			IF res_n = '0' THEN
				controller_state <= CONTROLLER_STATE_IDLE;
				instr_out <= "00000000";
				rs <= '0';
				rs_int <= '0';
				rw <= '0';
				rw_int <= '0';
				wait_time <= 0;
				instr_cnt <= 0;
				current_line <= '0';
				cursor_col <= 0;
				en_cnt <= 0;
				en <= '0';
				instr_data_buffer <= "0000000000000000";
			ELSE 
				IF rising_edge(clk) THEN
					controller_state <= controller_state_next;
					instr_out_int <= instr_out_next;
					instr_out <= instr_out_next;
					wait_time <= wait_time_next;
					clk_cnt <= clk_cnt_next;
					instr_cnt <= instr_cnt_next;
					current_line <= current_line_next;
					cursor_col <= cursor_col_next;
					rs_int <= rs_next;
					rs <= rs_next;
					rw_int <= rw_next;
					rw <= rw_next;
					en_cnt <= en_cnt_next;
					en_int <= en_next;
					en <= en_next;
					instr_data_buffer <= instr_data_buffer_next;
				END IF;
			END IF;
		END PROCESS sync;
END ARCHITECTURE textmode_lcd_controller_fsm_a;
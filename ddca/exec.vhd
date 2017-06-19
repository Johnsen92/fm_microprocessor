library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;





entity exec is
	
	port (
		clk, reset       : in  std_logic;
		stall      		 : in  std_logic;
		flush            : in  std_logic;
		pc_in            : in  std_logic_vector(PC_WIDTH-1 downto 0);
		op	   	         : in  exec_op_type;
		pc_out           : out std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');
		rd, rs, rt       : out std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
		aluresult	    : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		wrdata           : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		zero, neg         : out std_logic := '0';
		new_pc           : out std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');		
		memop_in         : in  mem_op_type;
		memop_out        : out mem_op_type := MEM_NOP;
		jmpop_in         : in  jmp_op_type;
		jmpop_out        : out jmp_op_type := JMP_NOP;
		wbop_in          : in  wb_op_type;
		wbop_out         : out wb_op_type := WB_NOP;
		forwardA         : in  fwd_type;
		forwardB         : in  fwd_type;
		cop0_rddata      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		mem_aluresult    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		wb_result        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		exc_ovf          : out std_logic := '0'
	);

end exec;

architecture rtl of exec is
	signal pc_next		: std_logic_vector(PC_WIDTH-1 downto 0);
	
	signal op_next		: exec_op_type := EXEC_NOP;
	signal op_alu    :  alu_op_type := ALU_NOP;
	signal alu_A    :  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal alu_B    :  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal alu_R    :  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal alu_Z    :  std_logic := '0';
	signal alu_V    :  std_logic := '0';
	signal cop0_rddata_next	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal memop_next : mem_op_type := MEM_NOP;
	signal jmpop_next : jmp_op_type := JMP_NOP ;
	signal wbop_next : wb_op_type := WB_NOP;

	signal mem_aluresult_next : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal wb_result_next : std_logic_vector(DATA_WIDTH-1 downto 0);
	
begin  -- rtl
	alu: entity work.alu
		port map (
			op => op_alu,
			A => alu_A,
			B => alu_B,
			R => alu_R,
			Z => alu_Z,
			V => alu_V
		);	

	
	exec_sync: process (clk, reset)
	begin	
		if reset = '0' then
		
			memop_next	<= MEM_NOP;
			memop_out	<= MEM_NOP;
			jmpop_next	<= JMP_NOP;
			jmpop_out	<= JMP_NOP;

			wbop_next	<= WB_NOP;
			wbop_out	<= WB_NOP;
			pc_next		<= (others => '0');
			pc_out      <= (others => '0');
			op_next		<= EXEC_NOP;

			cop0_rddata_next	<= (others => '0');

      			op_alu <= ALU_NOP;
		
   		 elsif rising_edge(clk) then
			if flush = '1' then
				memop_next	<= MEM_NOP;
				memop_out	<= MEM_NOP;
				jmpop_next	<= JMP_NOP;
				jmpop_out	<= JMP_NOP;
				wbop_next	<= WB_NOP;
				wbop_out	<= WB_NOP;
				op_next		<= op;	
				cop0_rddata_next	<= (others => '0');
			elsif stall = '0' then
				memop_next	<= memop_in;
				memop_out   <= memop_in;
				jmpop_next	<= jmpop_in;
				jmpop_out	<= jmpop_in;
				wbop_next	<= wbop_in;
				wbop_out	<= wbop_in;
				pc_next		<= pc_in;
				pc_out		<= pc_in;
				op_next		<= op;	
				op_alu <= op.aluop;
				cop0_rddata_next	<= cop0_rddata;

				mem_aluresult_next <= mem_aluresult;
				wb_result_next <= wb_result;

			end if;
		end if;
	
	end process exec_sync;
	
	exec_output: process (op_next, alu_R, alu_V, alu_Z, pc_next, jmpop_next, memop_next, forwardA, forwardB, mem_aluresult, wb_result)
	begin
		
		if stall /= '1' then		
			case forwardA is
				when FWD_ALU =>
					alu_A <= mem_aluresult;
				when FWD_WB =>
					alu_A <= wb_result;
				when others =>
					alu_A <= op_next.readdata1;
			end case;

			if op_next.useimm = '1' then
				alu_B <= op_next.imm;
			else
				case forwardB is
					when FWD_ALU =>
						alu_B <= mem_aluresult;
					when FWD_WB =>
						alu_B <= wb_result;
					when others =>
						alu_B <= op_next.readdata2;
				end case;
			end if;
		end if;

		if op_next.ovf = '1' then		
			exc_ovf <= alu_V;
		else
			exc_ovf <= '0';
		end if;
		
		
		zero <= alu_Z;
		
		neg	<= alu_R(DATA_WIDTH - 1);
		
		if op_next.cop0 = '1' then
			aluresult <= cop0_rddata;
		elsif op_next.link = '1' then
        	aluresult(DATA_WIDTH - 1 DOWNTO PC_WIDTH) <= (OTHERS => '0');
			aluresult(PC_WIDTH - 1 DOWNTO 0) <= std_logic_vector(signed(pc_next)+4);
		else
			aluresult <= alu_R;
		end if;

		rs <= op_next.rs;
		rt <= op_next.rt;
        if op_next.regdst = '1' then
        	rd <= op_next.rt;
        else
        	rd <= op_next.rd;
        end if;
		

		case jmpop_next is
			when  JMP_BLTZ =>
				if op_next.readdata1(DATA_WIDTH - 1) = '1' then
					new_pc <=  std_logic_vector(signed(pc_next)+shift_left(signed(op_next.imm(15 downto 0)),2)(PC_WIDTH-1 downto 0));   --14 PC_WIDTH == 14, korigiert
				else
					new_pc <= pc_next;
				end if;

			when  JMP_BGEZ =>
				if op_next.readdata1(DATA_WIDTH - 1) = '0' then
						
					new_pc <= std_logic_vector(signed(pc_next)+shift_left(signed(op_next.imm(15 downto 0)),2)(PC_WIDTH-1 downto 0)); --14 , korigiert
				else 
					new_pc <= pc_next;
				end if;
			
			when  JMP_JMP =>
				if op_next.useimm = '0' then 
					new_pc <= op_next.readdata1(PC_WIDTH-1 downto 0);		-- korigiert 14
				else
					new_pc <= std_logic_vector(shift_left(signed(op_next.imm(15 downto 0)),2)(PC_WIDTH-1 downto 0));		--14, korigiert55
				end if;

			when  JMP_BEQ => 
				if alu_Z = '1' then
					new_pc <= std_logic_vector(signed(pc_next)+shift_left(signed(op_next.imm(15 downto 0)),2)(PC_WIDTH-1 downto 0)); --14, korigiert
				else
					new_pc <= pc_next;
				end if;
			when  JMP_BNE =>
				if alu_Z = '0' then 
					new_pc <= std_logic_vector(signed(pc_next)+shift_left(signed(op_next.imm(15 downto 0)),2)(PC_WIDTH-1 downto 0)); --14, korigiert
				else 
					new_pc <= pc_next;
				end if;
			when  JMP_BLEZ =>
				if op_next.readdata1(DATA_WIDTH - 1) = '1' OR op_next.readdata1 = x"00000000" then
					new_pc <= std_logic_vector(signed(pc_next)+shift_left(signed(op_next.imm(15 downto 0)),2)(PC_WIDTH-1 downto 0)); --14, korigiert
				else
					new_pc <= pc_next;
				end if;
			when  JMP_BGTZ =>
				if op_next.readdata1(DATA_WIDTH - 1) = '0' AND op_next.readdata1 /= x"00000000" then
					new_pc <=std_logic_vector(signed(pc_next)+shift_left(signed(op_next.imm(15 downto 0)),2)(PC_WIDTH-1 downto 0)); --14, korigiert
				else
					new_pc <= pc_next;
				end if;
			when others =>
					new_pc <= pc_next;
			end case;
			case memop_next.memtype is
				when MEM_B =>
					case forwardB is
						when FWD_NONE => wrdata(7 downto 0) <= op_next.readdata2(7 downto 0);
						when FWD_ALU => wrdata(7 downto 0) <= mem_aluresult(7 downto 0);
						when FWD_WB => wrdata(7 downto 0) <= wb_result(7 downto 0);
					end case;
					wrdata(DATA_WIDTH - 1 downto 8) <= (others => '0');
				when MEM_H =>
					case forwardB is
						when FWD_NONE => wrdata(15 downto 0) <= op_next.readdata2(15 downto 0);
						when FWD_ALU => wrdata(15 downto 0) <= mem_aluresult(15 downto 0);
						when FWD_WB => wrdata(15 downto 0) <= wb_result(15 downto 0);
					end case;	
					wrdata(DATA_WIDTH - 1 downto 16) <= (others => '0');
				when others => 
					case forwardB is
						when FWD_NONE => wrdata <= op_next.readdata2;
						when FWD_ALU => wrdata <= mem_aluresult;
						when FWD_WB => wrdata <= wb_result;
					end case;
			end case;
	end process exec_output;

end rtl;

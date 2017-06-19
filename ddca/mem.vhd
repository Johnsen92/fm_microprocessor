library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity mem is
	
	port (
		clk, reset    : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;
		mem_op        : in  mem_op_type;
		jmp_op        : in  jmp_op_type;
		pc_in         : in  std_logic_vector(PC_WIDTH-1 downto 0);
		rd_in         : in  std_logic_vector(REG_BITS-1 downto 0);
		aluresult_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		wrdata        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		zero, neg     : in  std_logic;
		new_pc_in     : in  std_logic_vector(PC_WIDTH-1 downto 0);
		pc_out        : out std_logic_vector(PC_WIDTH-1 downto 0);
		pcsrc         : out std_logic;
		rd_out        : out std_logic_vector(REG_BITS-1 downto 0);
		aluresult_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
		memresult     : out std_logic_vector(DATA_WIDTH-1 downto 0);
		new_pc_out    : out std_logic_vector(PC_WIDTH-1 downto 0);
		wbop_in       : in  wb_op_type;
		wbop_out      : out wb_op_type;
		mem_out       : out mem_out_type;
		mem_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		exc_load      : out std_logic;
		exc_store     : out std_logic;
		branch_bit : out std_logic);

end mem;

architecture rtl of mem is

COMPONENT memu IS
PORT (
  op   : in  mem_op_type;
  A    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
  W    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  D    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  M    : out mem_out_type := ((others => '0'), '0', '0', (others => '0'), (others => '0'));
  R    : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  XL   : out std_logic := '0';
  XS   : out std_logic := '0'
);

END COMPONENT memu;

COMPONENT jmpu IS
PORT (
  op   : in  jmp_op_type;
  N, Z : in  std_logic;
  J    : out std_logic);
END COMPONENT jmpu;

  --For memu
  signal op_prev : mem_op_type := MEM_NOP;
  signal wrdata_prev : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal aluresult_prev : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  
  --For jmpu
  signal jmp_op_prev : jmp_op_type := JMP_NOP;
  signal neg_prev : std_logic := '0';
  signal zero_prev : std_logic := '0';

begin  -- rtl
  memu_inst : memu PORT MAP(
  op => op_prev,
  A => aluresult_prev(ADDR_WIDTH-1 downto 0), -- no signal with ADDR-WIDTH
  W => wrdata_prev,
  D => mem_data,
  M => mem_out,
  R => memresult,
  XL => exc_load,
  XS => exc_store
  );

  jmpu_inst : jmpu PORT MAP(
    op => jmp_op_prev,
    N => neg_prev,
    Z => zero_prev,
    J => pcsrc
  );

  sync : process (clk, reset, flush)
  begin
  if reset = '0' then

  	wbop_out <= WB_NOP;
	zero_prev <= '0';
	neg_prev <= '0';
	rd_out <= (others => '0');
	new_pc_out <= (others => '0');
	jmp_op_prev <= JMP_NOP;
	op_prev <= MEM_NOP;
	pc_out <= (others => '0');
	wrdata_prev <= (others => '0');
	aluresult_prev <= (others => '0');
  	
	elsif rising_edge(clk) then

		if flush = '1' then

			wbop_out <= WB_NOP;
			zero_prev <= '0';
			neg_prev <= '0';
			rd_out <= (others => '0');
			new_pc_out <= (others => '0');
			jmp_op_prev <= JMP_NOP;
			op_prev <= MEM_NOP;
			wrdata_prev <= (others => '0');
			aluresult_prev <= (others => '0');

		else

			op_prev.memread	<= '0';
			op_prev.memwrite	<= '0';
	    		if stall = '0' then
      				--memu inputs
    				op_prev <= mem_op;
      				wrdata_prev <= wrdata;
      				aluresult_prev <= aluresult_in;
      				--jmpu inputs
      				jmp_op_prev <= jmp_op;
      				neg_prev <= neg;
      				zero_prev <= zero;
      				--clk-shift outputs
      				pc_out <= pc_in;
      				rd_out <= rd_in;
      				new_pc_out <= new_pc_in;
      				wbop_out <= wbop_in;
    			end if;
		end if;
 	end if;
  end process;

  set_bit_computation : process(jmp_op_prev)
  begin
    if jmp_op_prev = JMP_NOP then
      branch_bit <= '0';
    else
      branch_bit <= '1';
    end if;
  
  end process;
  
  aluresult_out <= aluresult_prev;

end rtl;

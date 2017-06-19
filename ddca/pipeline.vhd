library ieee;
use ieee.std_logic_1164.all;

use work.core_pack.all;
use work.op_pack.all;

entity pipeline is
	
	port (
		clk, reset : in	 std_logic;
		mem_in     : in  mem_in_type;
		mem_out    : out mem_out_type;
		intr       : in  std_logic_vector(INTR_COUNT-1 downto 0);
		clk_count  : out integer
	);

end pipeline;

architecture rtl of pipeline is

  signal pcsrc_mf : std_logic;
  signal pc_mf : std_logic_vector(PC_WIDTH-1 downto 0);
  signal pc_fd : std_logic_vector(PC_WIDTH-1 downto 0);
  signal instr_fd : std_logic_vector(INSTR_WIDTH-1 downto 0);
  signal pc_de : std_logic_vector(PC_WIDTH-1 downto 0);
  signal exec_op_de : exec_op_type;
  signal jmpop_de : JMP_OP_TYPE;
  signal memop_de : MEM_OP_TYPE;
  signal wbop_de : WB_OP_TYPE;
  signal exc_dec : std_logic;
  signal exc_ovf : std_logic;
  signal exc_store : std_logic;
  signal exc_load : std_logic;
  signal pc_em : std_logic_vector(PC_WIDTH-1 downto 0);
  signal rd_em : std_logic_vector(REG_BITS-1 downto 0);
  signal rs_e : std_logic_vector(REG_BITS-1 downto 0);
  signal rt_e : std_logic_vector(REG_BITS-1 downto 0);
  signal aluresult_em : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal wrdata_em : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal zero_em : std_logic;
  signal neg_em : std_logic;
  signal new_pc_em : std_logic_vector(PC_WIDTH-1 downto 0);
  signal memop_em : MEM_OP_TYPE;
  signal jmpop_em : JMP_OP_TYPE;
  signal wbop_em : WB_OP_TYPE;
  signal aluresult_m : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal wb_res_we : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pc_mw : std_logic_vector(PC_WIDTH-1 downto 0);
  signal rd_mw : std_logic_vector(REG_BITS-1 downto 0);
  signal memresult_mw : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal wbop_mw : WB_OP_TYPE;
  signal rd_wd : std_logic_vector(REG_BITS-1 downto 0);
  signal result_wd : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal regwrite_wd : std_logic;
  signal flush_d : std_logic;
  signal flush_e : std_logic;
  signal flush_m : std_logic;
  signal flush_w : std_logic;
  signal forwardA_e : fwd_type;
  signal forwardB_e : fwd_type;
  signal cop0_wrdata_e : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal cop0_rddata_e : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal cop0_op_e : COP0_OP_TYPE;
  signal clk_count_int : integer := -1;
  signal branch_bit_ctr : std_logic;
  --signal cop0_rddata_ctrl : std_logic_vector(DATA_WIDTH-1 downto 0);


--Components
COMPONENT fetch is
	
	port (
		clk, reset : in	 std_logic;
		stall      : in  std_logic;
		pcsrc	   : in	 std_logic;
		pc_in	   : in	 std_logic_vector(PC_WIDTH-1 downto 0);
		pc_out	   : out std_logic_vector(PC_WIDTH-1 downto 0);
		instr	   : out std_logic_vector(INSTR_WIDTH-1 downto 0));

end COMPONENT fetch;
COMPONENT decode is
	port (
		clk, reset : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;
		pc_in      : in  std_logic_vector(PC_WIDTH-1 downto 0);
		instr	   : in  std_logic_vector(INSTR_WIDTH-1 downto 0);
		wraddr     : in  std_logic_vector(REG_BITS-1 downto 0);
		wrdata     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite   : in  std_logic;
		pc_out     : out std_logic_vector(PC_WIDTH-1 downto 0);
		exec_op    : out exec_op_type;
		cop0_op    : out cop0_op_type;
		jmp_op     : out jmp_op_type;
		mem_op     : out mem_op_type;
		wb_op      : out wb_op_type;
		exc_dec    : out std_logic;
		cop0_wrdata: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end COMPONENT decode;
COMPONENT exec is
	port (
		clk, reset       : in  std_logic;
		stall      		 : in  std_logic;
		flush            : in  std_logic;
		pc_in            : in  std_logic_vector(PC_WIDTH-1 downto 0);
		op	   	         : in  exec_op_type;
		pc_out           : out std_logic_vector(PC_WIDTH-1 downto 0);
		rd, rs, rt       : out std_logic_vector(REG_BITS-1 downto 0);
		aluresult	     : out std_logic_vector(DATA_WIDTH-1 downto 0);
		wrdata           : out std_logic_vector(DATA_WIDTH-1 downto 0);
		zero, neg         : out std_logic;
		new_pc           : out std_logic_vector(PC_WIDTH-1 downto 0);		
		memop_in         : in  mem_op_type;
		memop_out        : out mem_op_type;
		jmpop_in         : in  jmp_op_type;
		jmpop_out        : out jmp_op_type;
		wbop_in          : in  wb_op_type;
		wbop_out         : out wb_op_type;
		forwardA         : in  fwd_type;
		forwardB         : in  fwd_type;
		cop0_rddata      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		mem_aluresult    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		wb_result        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		exc_ovf          : out std_logic);
end COMPONENT exec;
COMPONENT mem is
	
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

END COMPONENT mem;
COMPONENT wb is
	port (
		clk, reset : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;
		op	   	   : in  wb_op_type;
		rd_in      : in  std_logic_vector(REG_BITS-1 downto 0);
		aluresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		memresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_out     : out std_logic_vector(REG_BITS-1 downto 0);
		result     : out std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite   : out std_logic);
end COMPONENT wb;

COMPONENT ctrl is
	port(
		clk	   : IN std_logic;
		reset	   : IN std_logic;
		stall 	   : IN std_logic;
		jump       : IN std_logic;
		pc_src_in  : IN std_logic;
		cop0_op	   : IN COP0_OP_TYPE;
		cop0_wrdata	 : IN std_logic_vector(DATA_WIDTH - 1 downto 0);
		--exc_dec	 	 : IN std_logic;
		--exc_ovf		 : IN std_logic;
		exc_load	 : IN std_logic;
	        exc_store	 : IN std_logic;
		pc_exec		 : IN std_logic_vector(PC_WIDTH - 1 downto 0);
	        pc_mem	 : IN std_logic_vector(PC_WIDTH - 1 downto 0);
		flush_d      : OUT std_logic;
		flush_e      : OUT std_logic;
		flush_m      : OUT std_logic;
		flush_w      : OUT std_logic;
		branch_bit : in std_logic;
		cop0_rddata	 : OUT std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
end COMPONENT ctrl;

COMPONENT fwd is
	port (
		-- define input and output ports as needed
		rs_e	: in std_logic_vector(REG_BITS -1 downto 0);
		rt_e	: in std_logic_vector(REG_BITS -1 downto 0);
		rd_mem	: in std_logic_vector(REG_BITS -1 downto 0);
		rd_wb	: in std_logic_vector(REG_BITS -1 downto 0);
		fwdA	: out fwd_type;
		fwdB	: out fwd_type;
		regwrite_mem	: in std_logic;
		regwrite_wb	: in std_logic);
end COMPONENT fwd;

--/Components

begin  -- rtl

clk_count <= clk_count_int;


count : process(clk, reset, mem_in.busy)
begin
	if reset = '0' then
		clk_count_int <= -1;
	elsif rising_edge(clk) and mem_in.busy = '0' then
		clk_count_int <= clk_count_int + 1;
	end if;
end process;

ctrl_inst : ctrl PORT MAP (
  clk => clk,
  reset => reset,
  stall => mem_in.busy,
  jump => pcsrc_mf,
  pc_src_in => pcsrc_mf,
  cop0_op => cop0_op_e,
  cop0_wrdata => cop0_wrdata_e,
  --exc_dec => open,
 --exc_ovf => open,
  exc_load => exc_load,
  exc_store	=> exc_store,
  pc_exec => pc_de,
  pc_mem => pc_mw,
  flush_d => flush_d,
  flush_e => flush_e,
  flush_m => flush_m,
  flush_w => flush_w,
  branch_bit => branch_bit_ctr,

  cop0_rddata => cop0_rddata_e
);


fwd_inst : fwd PORT MAP (
  rs_e => rs_e,
  rt_e => rt_e,
  rd_mem => rd_mw,
  rd_wb => rd_wd,
  fwdA => forwardA_e,
  fwdB => forwardB_e,
  regwrite_mem => wbop_mw.regwrite,
  regwrite_wb => regwrite_wd
);

fetch_inst : fetch PORT MAP (
  clk => clk,
  reset => reset,
  stall => mem_in.busy,
  pcsrc => pcsrc_mf,
  pc_in => pc_mf,
  pc_out => pc_fd,
  instr => instr_fd
);

decode_inst : decode PORT MAP (
  clk => clk,
  reset => reset,
  flush => flush_d,
  stall => mem_in.busy,
  pc_in => pc_fd,
  instr => instr_fd,
  wraddr => rd_wd,
  wrdata => result_wd,
  regwrite => regwrite_wd,
  pc_out => pc_de,
  exec_op => exec_op_de,
  cop0_op => cop0_op_e,
  jmp_op => jmpop_de,
  mem_op => memop_de,
  wb_op => wbop_de,
  exc_dec => exc_dec,
  cop0_wrdata => cop0_wrdata_e
);

exec_inst : exec PORT MAP (
  clk => clk,
  reset => reset,
  flush => flush_e,
  stall => mem_in.busy,
  pc_in => pc_de,
  op => exec_op_de,
  pc_out => pc_em,
  rd => rd_em,
  rs => rs_e,
  rt => rt_e,
  aluresult => aluresult_em,
  wrdata => wrdata_em,
  zero => zero_em,
  neg => neg_em,
  new_pc => new_pc_em,
  memop_in => memop_de,
  memop_out => memop_em,
  jmpop_in => jmpop_de,
  jmpop_out => jmpop_em,
  wbop_in => wbop_de,
  wbop_out => wbop_em,
  forwardA => forwardA_e,
  forwardB => forwardB_e,
  cop0_rddata => cop0_rddata_e,
  mem_aluresult => aluresult_m,
  --wb_result => aluresult_m,
  wb_result => result_wd,
  exc_ovf => exc_ovf
);

mem_inst : mem PORT MAP (
  clk => clk,
  reset => reset,
  stall => mem_in.busy,
  flush => flush_m,
  mem_op => memop_em,
  jmp_op => jmpop_em,
  pc_in => pc_em,
  rd_in => rd_em,
  aluresult_in => aluresult_em,
  wrdata => wrdata_em,
  zero => zero_em,
  neg => neg_em,
  new_pc_in => new_pc_em,
  pc_out => pc_mw,
  pcsrc => pcsrc_mf,
  rd_out => rd_mw,
  aluresult_out => aluresult_m,
  memresult => memresult_mw,
  new_pc_out => pc_mf,
  wbop_in => wbop_em,
  wbop_out =>wbop_mw,
  mem_out => mem_out,
  mem_data => mem_in.rddata,
  exc_load => exc_load,
  exc_store => exc_store,
  branch_bit => branch_bit_ctr
);

wb_inst : wb PORT MAP(
  clk => clk,
  reset => reset,
  stall => mem_in.busy,
  flush => flush_w,
  op => wbop_mw,
  rd_in => rd_mw,
  aluresult => aluresult_m,
  memresult => memresult_mw,
  rd_out => rd_wd,
  result => result_wd,
  regwrite => regwrite_wd
);
	
end rtl;

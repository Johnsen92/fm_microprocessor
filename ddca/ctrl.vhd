--coprocessor 0
----------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;


entity cop0 is
	
	port (
		clk, reset : in  std_logic;
		stall      : in  std_logic;
		pc_exec : in  std_logic_vector(PC_WIDTH-1 downto 0);
		pc_mem : in  std_logic_vector(PC_WIDTH-1 downto 0);
		branch_bit: in std_logic; --new David 
		exc_load :  in std_logic;
		exc_store : in std_logic;
		pc_src : in std_logic;
		cop0_op : in cop0_op_type;
		cop0_wrdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
		cop0_rddata : out std_logic_vector(DATA_WIDTH-1 downto 0);
		flush_to_ctrl : out std_logic
	);
end cop0;



architecture rtl of cop0 is

type REGISTER_TYPE is array (3 downto 0) of std_logic_vector(31 downto 0);
signal cop0_reg : REGISTER_TYPE := ((others => '0'), (others => '0'), (others => '0'), (others => '0'));

signal cop0_rddata_sig : std_logic_vector(DATA_WIDTH-1 downto 0);
signal cop0_rddata_last : std_logic_vector(DATA_WIDTH-1 downto 0);

signal pc_src_buffer2 : std_logic := '0';
signal pc_src_buffer : std_logic :=  '0';

signal exc_load_buffer : std_logic :=  '0';
signal exc_store_buffer : std_logic :=  '0';
signal branch_bit_buffer : std_logic :=  '0';

begin
		sync : process(clk,reset)
		begin
				if reset = '0' then

					exc_load_buffer <= '0';
					exc_store_buffer <=  '0';

					pc_src_buffer2 <= '0';
					pc_src_buffer <= '0';
					
					cop0_rddata_last <= (others => '0');
					
				elsif rising_edge(clk) then 
					
					exc_load_buffer <= exc_load;
					exc_store_buffer <= exc_store;
					pc_src_buffer2 <= pc_src_buffer;
					pc_src_buffer <= pc_src;
					branch_bit_buffer <= branch_bit;
					

				  if stall = '0' then

					cop0_rddata_last <= cop0_rddata_sig;

					if cop0_op.wr = '1' then
			   			cop0_reg(to_integer(unsigned(cop0_op.addr(1 downto 0)))) <= cop0_wrdata; 
		  			end if;
											
					if (exc_load = '1') then
						cop0_reg(1) <= (others => '0');
						cop0_reg(1)(5 downto 2) <= "0100";
						cop0_reg(1)(DATA_WIDTH-1) <= branch_bit_buffer; --pc_src;
						cop0_reg(2) <= (others => '0');
						cop0_reg(3) <= (others => '0');
						cop0_reg(2)(PC_WIDTH-1 downto 0) <= std_logic_vector(to_unsigned(to_integer(unsigned(pc_mem)) - 4,PC_WIDTH));
						if pc_src_buffer ='0' then
					  		cop0_reg(3)(PC_WIDTH-1 downto 0) <= pc_mem;
						else
					  		cop0_reg(3)(PC_WIDTH-1 downto 0) <= pc_exec;
						end if;

					elsif (exc_store = '1') then
						cop0_reg(1) <= (others => '0');
						cop0_reg(1)(5 downto 2) <= "0101";
						cop0_reg(1)(DATA_WIDTH-1) <= branch_bit_buffer; --pc_src;
						cop0_reg(2) <= (others => '0');
						cop0_reg(3) <= (others => '0');
						cop0_reg(2)(PC_WIDTH-1 downto 0) <= std_logic_vector(to_unsigned(to_integer(unsigned(pc_mem)) - 4,PC_WIDTH));
						if pc_src_buffer ='0' then
					  		cop0_reg(3)(PC_WIDTH-1 downto 0) <= pc_mem;
						else
					  		cop0_reg(3)(PC_WIDTH-1 downto 0) <= pc_exec;
						end if;
					end if;
				  end if;		
				end if;
		end process;

	read_registers : process(cop0_reg, cop0_op.addr, cop0_rddata_last, cop0_wrdata, stall)
			variable cop0_rddata_next :  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	begin
		cop0_rddata_next := cop0_reg(to_integer(unsigned(cop0_op.addr(1 downto 0))));
		
		 if cop0_op.wr = '1' then
        		cop0_rddata_next := cop0_wrdata; 
     		 end if;	


		if stall = '0' then
				cop0_rddata <= cop0_rddata_next;
				cop0_rddata_sig <= cop0_rddata_next;
			else
				cop0_rddata <= cop0_rddata_last;
				cop0_rddata_sig <= cop0_rddata_last;
		end if;
--
			
	end process;

	compute_flush : process(exc_load_buffer, exc_store_buffer)
	begin
			flush_to_ctrl <= exc_load_buffer or exc_store_buffer;
	end process;


end rtl;


--ctrl unit
----------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity ctrl is
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
end ctrl;

architecture rtl of ctrl is
	signal status : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal cause : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal epc : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal npc : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal cop0_op_next : COP0_OP_TYPE;
	signal flush_from_cop0 : std_logic := '0';

begin  -- rtl

		cop0_inst : entity work.cop0
		port map(
			clk => clk,
			reset => reset,
			stall => stall,
			pc_exec => pc_exec,
			pc_mem => pc_mem,			
			branch_bit => branch_bit,
			exc_load => exc_load,
			exc_store => exc_store,
			pc_src => pc_src_in, 
			cop0_op => cop0_op,
			cop0_wrdata =>  cop0_wrdata,
			cop0_rddata => cop0_rddata,
			flush_to_ctrl => flush_from_cop0
		);

output : process (jump)
begin
  flush_d <= jump or flush_from_cop0;
  flush_e <= jump or flush_from_cop0;
  flush_m <= flush_from_cop0;
  flush_w <= flush_from_cop0;
end process;



end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pack.all;

entity fetch is

	port (
		clk, reset : in	 std_logic;
		stall      : in  std_logic;
		pcsrc	   : in	 std_logic;
		pc_in	   : in	 std_logic_vector(PC_WIDTH-1 downto 0);
		pc_out	   : out std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');
		instr	   : out std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0')
	);
end fetch;



architecture rtl of fetch is
	signal pc_out_next 	:std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');
	signal pc_counter 	:std_logic_vector(PC_WIDTH-1 downto 0);

begin  -- rtl

	imem_altera_inst : entity work.imem_altera

		port map(
			address => pc_out_next(PC_WIDTH-1 downto 2),
			clock => clk,
			q => instr
		);

	pc_out <= pc_out_next;

	fetch_output: process (pcsrc,stall, pc_in,pc_counter)
	begin
		if stall /= '1' then
			if pcsrc = '1' then
				pc_out_next <= pc_in;
			else
				pc_out_next<= std_logic_vector(unsigned(pc_counter)+4);
			end if;
		else
			pc_out_next <= pc_counter;
		end if;
	end process fetch_output;

	fetch_sync: process(clk, reset)
	begin 
		if reset = '0'then
			pc_counter <= std_logic_vector(to_signed(-4, 14));
		elsif rising_edge(clk)then
			if stall = '0' then 
				pc_counter <= pc_out_next;
			end if;
		end if;
	end process fetch_sync;
end  architecture rtl;

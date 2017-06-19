library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity ctrl is
	port(
		--reset	   : IN std_logic;
		--clk	   : IN std_logic;
		jump       : IN std_logic;
		cop0_op	   : IN COP0_OP_TYPE;
		cop0_wrdata	 : IN std_logic_vector(DATA_WIDTH - 1 downto 0);
		exc_dec	 	 : IN std_logic;
		--npc_dec		 : IN std_logic_vector(PC_WIDTH - 1 downto 0);
	    --epc_dec		 : IN std_logic_vector(PC_WIDTH - 1 downto 0);
		exc_ovf		 : IN std_logic;
		--npc_exc		 : IN std_logic_vector(PC_WIDTH - 1 downto 0);
	    --epc_exc		 : IN std_logic_vector(PC_WIDTH - 1 downto 0);
		exc_load	 : IN std_logic;
	    exc_store	 : IN std_logic;
		--npc_mem		 : IN std_logic_vector(PC_WIDTH - 1 downto 0);
	    --epc_mem		 : IN std_logic_vector(PC_WIDTH - 1 downto 0);
		flush_d      : OUT std_logic;
		flush_e      : OUT std_logic;
		flush_m      : OUT std_logic;
		flush_w      : OUT std_logic;
		cop0_rddata	 : OUT std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
end ctrl;

architecture rtl of ctrl is
	signal status : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal cause : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal epc : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal npc : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal cop0_op_next : COP0_OP_TYPE;
begin  -- rtl



output : process (jump)
begin
  flush_d <= jump;
  flush_e <= jump;
  flush_m <= '0';
  flush_w <= '0';
end process;

--sync : process(clk, reset)
sync : process(exc_dec)
begin
	if exc_dec = '1' then
		cause(5 downto 2) <= "1010";
		--epc(PC_WIDTH - 1 downto 0) <= epc_dec;
		--npc(PC_WIDTH - 1 downto 0) <= epc_dec;
	elsif exc_ovf = '1' then
		cause(5 downto 2) <= "1100";
		--epc(PC_WIDTH - 1 downto 0) <= epc_exc;
		--npc(PC_WIDTH - 1 downto 0) <= epc_exc;
	elsif exc_load = '1' then
		cause(5 downto 2) <= "0100";
		--epc(PC_WIDTH - 1 downto 0) <= epc_mem;
		--npc(PC_WIDTH - 1 downto 0) <= epc_mem;
	elsif exc_store = '1' then
		cause(5 downto 2) <= "0101";
		--epc(PC_WIDTH - 1 downto 0) <= epc_mem;
		--npc(PC_WIDTH - 1 downto 0) <= epc_mem;
	else
		cause(5 downto 2) <= "0000";
		--epc <= (others => '0');
		--npc <= (others => '0');
	end if;
end process;

coprocessor0 : process(cop0_op, cop0_wrdata)
begin
	if cop0_op_next.wr = '1' then
		case cop0_op_next.addr is
			when "01100" =>
				status <= cop0_wrdata;
			when "01101" =>
				cause <= cop0_wrdata;
			when "01110" =>
				epc <= cop0_wrdata;
			when "01111" =>
				npc <= cop0_wrdata;
			when others =>
				null;
		end case;
	else
		case cop0_op_next.addr is
			when "01100" =>
				cop0_rddata <= status;
			when "01101" =>
				cop0_rddata <= cause;
			when "01110" =>
				cop0_rddata <= epc;
			when "01111" =>
				cop0_rddata <= npc;
			when others =>
				cop0_rddata <= (others => '0');
		end case;
	end if;
end process;

end rtl;

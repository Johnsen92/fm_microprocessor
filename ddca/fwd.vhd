library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity fwd is
	port (
		rs_e	: in std_logic_vector(REG_BITS -1 downto 0);
		rt_e	: in std_logic_vector(REG_BITS -1 downto 0);
		rd_mem	: in std_logic_vector(REG_BITS -1 downto 0);
		rd_wb	: in std_logic_vector(REG_BITS -1 downto 0);
		fwdA	: out fwd_type;
		fwdB	: out fwd_type;
		regwrite_mem	: in std_logic;
		regwrite_wb	: in std_logic
);
	
end fwd;

architecture rtl of fwd is

begin  -- rtl

fwd_output : process (rs_e, rt_e, rd_mem, rd_wb, regwrite_mem, regwrite_wb)
	begin
		if rs_e /= "00000" then
			if rs_e = rd_mem AND regwrite_mem = '1' then
				fwdA <= FWD_ALU;
			elsif rs_e = rd_wb AND regwrite_wb = '1' then
				fwdA <= FWD_WB;
			else
				fwdA <= FWD_NONE;
			end if;
		else
			fwdA <= FWD_NONE;
		end if;

		if rt_e /= "00000" then
			if rt_e = rd_mem AND regwrite_mem = '1' then
				fwdB <= FWD_ALU;
			elsif rt_e = rd_wb AND regwrite_wb = '1' then
				fwdB <= FWD_WB;
			else
				fwdB <= FWD_NONE;
			end if;
		else
			fwdB <= FWD_NONE;
		end if;
	end process fwd_output;
end rtl;

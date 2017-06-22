library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_pack.all;

entity regfile is
    port (
        clk         : in std_logic;
        reset       : in std_logic;
        rdaddr_a    : in REG_ADDR_T;
        rdaddr_b    : in REG_ADDR_T;
        wr          : in std_logic;
        wraddr      : in REG_ADDR_T;
        wrdata      : in REG_DATA_T;
        rddata_a    : out REG_DATA_T;
        rddata_b    : out REG_DATA_T
    );
end entity regfile;

architecture regfile_arc of regfile is
    type REG_T is array(2**REG_ADDR_WIDTH-1 downto 0) of REG_DATA_T;
    
    signal rdaddr_a_int, rdaddr_b_int : integer range 0 to 2**REG_ADDR_WIDTH-1;
    signal wraddr_int : integer range 0 to 2**REG_ADDR_WIDTH-1; -- async
	signal regfile : REG_T := (others => (others => '0'));
begin
    wraddr_int <= to_integer((unsigned(wraddr));

    output : process(rdaddr_a_int, rdaddr_b_int, wraddr_int, wr, wrdata, regfile)
    begin
		-- read from rdaddr_a
		if rdaddr_a_int = wraddr_int and wr = '1' and rdaddr_a_int /= 0 then
			rddata_a <= wrdata;
		else
			if rdaddr_a_int = 0 then
				rddata_a <= (others => '0');
			else
				rddata_a <= regfile(rdaddr_a_int);
			end if;
		end if;
        
        -- read from rdaddr_b
		if rdaddr_b_int = wraddr_int and wr = '1' and rdaddr_b_int /= 0 then
			rddata_b <= wrdata;
		else
			if rdaddr_b_int = 0 then
				rddata_b <= (others => '0');
			else
				rddata_b <= regfile(rdaddr_b_int);
			end if;
		end if;	
	end process output;

    sync : process(clk, reset)
    begin
        if(rising_edge(clk)) then
            if reset = '1' then
                rdaddr_a_int <= 0;
                rdaddr_b_int <= 0;
                regfile <= (others => (others => '0'));
            else
                rdaddr_a_int <= to_integer(unsigned(rdaddr_a));
                rdaddr_b_int <= to_integer(unsigned(rdaddr_b));

                -- write to wraddr
                if wr = '1' then
                    if wraddr /= 0 then
                        regfile(to_integer(unsigned(wraddr))) <= wrdata;
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture;

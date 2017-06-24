library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wait_unit is
    generic (
        DATA_WIDTH  : integer := 11
    );
	port (
        clk         : in std_logic;
        reset       : in std_logic;
        wait_cycles : in std_logic_vector(DATA_WIDTH-1 downto 0);
        start       : in std_logic;
        done        : out std_logic
	);
end wait_unit;

architecture wait_unit_arc of wait_unit is
    signal countdown        : integer range 0 to 2**DATA_WIDTH-1;
    signal wait_cycles_int  : integer range 0 to 2**DATA_WIDTH-1;
	signal start_hold		: std_logic;
begin
    wait_cycles_int <= to_integer(unsigned(wait_cycles));
    
    next_logic : process(start_hold, countdown)
    begin
        if(countdown = 0 and start_hold = '1') then
            done <= '1';
		else
			done <= '0';
        end if;
    end process;
    
    sync : process(reset, clk)
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                start_hold  <= '0';
                countdown   <= 0;
            else
				if((start = '1' and countdown = 0) or countdown /= 0) then
					start_hold <= '1';
				else
					start_hold <= '0';
				end if;
                
                if(start = '1') then
                    countdown <= wait_cycles_int;
                elsif(countdown /= 0) then
                    countdown <= countdown - 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wait_unit is
    generic (
        DATA_WIDTH  : integer := 11;
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
    signal start_hold       : std_logic;
    signal start_hold_next  : std_logic;
    signal countdown        : integer range 0 to 2**DATA_WIDTH-1;
begin
    done <= (countdown = 0 and (start = '1' or start_hold = '1'));
    wait_cycles_int <= to_integer(unsigned(wait_cycles));
    
    next_logic : process(start, start_hold, countdown)
    begin
        --default:
        start_hold_next <= start_hold;
        
        if(countdown = 0) then
            start_hold_next <= '0';
        else if(start = '1') then
            start_hold_next <= '1';
        end if;
    end process;
    
    sync : process(reset, clk)
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                start_hold  <= '0';
                countdown   <= 0;
            else
                start_hold  <= start_hold_next;
                
                if(start = '1') then
                    countdown <= wait_cycles_int;
                else if(countdown /= 0) then
                    countdown <= countdown - 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
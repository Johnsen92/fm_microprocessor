library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sine_cordic_constants.all;

entity mult_fix is
    generic (
        DATA_WIDTH  : integer := 8;
    );
	port (
        dataa               : in std_logic_vector(DATA_WIDTH-1 downto 0);
        datab               : in std_logic_vector(DATA_WIDTH-1 downto 0);
        integer_places_a    : in integer range 0 to DATA_WIDTH;
        integer_places_b    : in integer range 0 to DATA_WIDTH;
        integer_places_out  : in integer range 0 to DATA_WIDTH;
        result              : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end mult_fix;

architecture mult_fix_arc of mult_fix is
	signal initial_product      : signed(DATA_WIDTH*2-1 downto 0);
    signal shifted_product      : signed(DATA_WIDTH*2-1 downto 0);
    signal rounded_product      : unsigned(DATA_WIDTH*2-1 downto 0);
    signal shifted_round_bit    : unsigned(DATA_WIDTH*2-1 downto 0);
    signal samt             : integer range -2*DATA_WIDTH to 2*DATA_WIDTH;
begin
    -- shifted output in output in MSBs
    samt <= (integer_places_a + integer_places_b) - integer_places_out;
    initial_product     <= signed(dataa) * signed(datab);
    shifted_product     <= initial_product sll samt;
    shifted_round_bit   <= to_unsigned(1, DATA_WIDTH*2-1) sll (samt-1);
    rounded_product     <= unsigned(shifted_product) + shifted_round_bit;
    result              <= rounded_product(DATA_WIDTH*2-1 downto DATA_WIDTH);
	
end architecture;
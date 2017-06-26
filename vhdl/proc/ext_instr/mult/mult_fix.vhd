library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;

entity mult_fix is
    generic (
        DATA_WIDTH  : integer := 8
    );
	port (
        dataa               : in std_logic_vector(DATA_WIDTH-1 downto 0);
        datab               : in std_logic_vector(DATA_WIDTH-1 downto 0);
        samt                : in OP_AUX_T;
        result              : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end mult_fix;

architecture mult_fix_arc of mult_fix is
    -- samt_int is the number of fraction bits to take into account;
    -- samt_int_norm is to normalize the input so that "00..0" represents pure integer multiplication
    -- (output always in MSBs)
    --calculate samt in instruction as follows:
    --DATA_WIDTH - ( ([# of fraction bits of dataa] + [# of fraction bits of datab]) - [desired # of fraction bits at output] );
    signal samt_int             : integer range -(2**(OP_AUX_T'length-1)) to (2**(OP_AUX_T'length-1))-1;
    signal samt_int_norm        : integer range -(2**(OP_AUX_T'length-1))-1+DATA_WIDTH to (2**(OP_AUX_T'length-1))+DATA_WIDTH;
	signal initial_product      : signed(DATA_WIDTH*2-1 downto 0);
    signal rounded_product      : signed(DATA_WIDTH*2-1 downto 0);
    signal shifted_product      : signed(DATA_WIDTH*2-1 downto 0);
    signal shifted_round_bit    : unsigned(DATA_WIDTH*2-1 downto 0);
begin
    samt_int        <= to_integer(signed(samt));
    samt_int_norm   <= DATA_WIDTH - to_integer(signed(samt));
    initial_product <= signed(dataa) * signed(datab);
    rounded_product <= signed(unsigned(initial_product) + shifted_round_bit);
    result          <= std_logic_vector(shifted_product(DATA_WIDTH*2-1 downto DATA_WIDTH));
    
    shifter : process(rounded_product, samt_int)
    begin
        if(samt_int_norm > 0) then
            shifted_product     <= shift_left(rounded_product, samt_int_norm);
        else
            shifted_product     <= shift_right(rounded_product, -samt_int_norm); --sra
        end if;
        
        if(samt_int > 1) then
            shifted_round_bit   <= shift_left(to_unsigned(1, DATA_WIDTH*2), samt_int-1);
        else
            shifted_round_bit   <= to_unsigned(0, DATA_WIDTH*2);
        end if;
    end process;
	
end architecture;
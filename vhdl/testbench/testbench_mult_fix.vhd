    library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.pipeline_package.all;
use work.program_package.all;
use work.sine_cordic_constants.all;

entity testbench_mult_fix is
	port (
		fixed_converted : out REG_DATA_T := float_to_fixed(-MATH_PI, DATA_WIDTH - 1, DATA_WIDTH)
	);
end testbench_mult_fix;

architecture beh of testbench_mult_fix is
    component mult_fix is
        generic (
            DATA_WIDTH  : integer := 8
        );
        port (
            dataa               : in std_logic_vector(DATA_WIDTH-1 downto 0);
            datab               : in std_logic_vector(DATA_WIDTH-1 downto 0);
            samt                : in OP_AUX_T;
            result              : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
    
    constant CLK_PERIOD : time := 20 ns;
    
    constant DATA_WIDTH : integer := 16;
    
    signal clk, reset : std_logic;
    signal dataa, datab : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal samt : OP_AUX_T;
    
    type TESTCASE_T is record
        dataa   : std_logic_vector(DATA_WIDTH-1 downto 0);
        datab   : std_logic_vector(DATA_WIDTH-1 downto 0);
        samt    : OP_AUX_T;
    end record;
    
    constant NUM_TESTCASES : integer := 4;
    type TESTCASE_ARRAY_T is array(0 to NUM_TESTCASES-1) of TESTCASE_T;
    constant TESTCASES : TESTCASE_ARRAY_T := (
        (
            dataa   => x"0002", -- 2
            datab   => x"000F", -- 15
            samt    => "000000" -- 16 - ((16+16)-16)=0
        ),                      -- should be: x"1E"
        
        (
            dataa   => "010" & "0000000000000", -- 2    (Q3.13)
            datab   => "000" & "1000000000000", -- 0.5  (Q3.13)
            samt    => "001101"                 -- 16 - ((3 + 3)-3)=13
        ),                                      -- should be: x"2000"
        
        (
            dataa   => "000" & "0100000000000", -- 0.25 (Q3.13)
            datab   => "0100000000000000",      -- X    (Q16.0)
            samt    => "001101"                 -- 16 - ((16+3)-16)=13
        ),                                      -- should be: x"1000"
        
        (
            dataa   => "001" & "0000000000001", -- 1.0001.. (Q3.13)
            datab   => "000" & "1000000000000", -- 0.5      (Q16.0)
            samt    => "001101"                 -- 16 - ((3+3)-3)=13
        )                                       -- should be: x"1001"
    );
    
begin
    mult_fix_inst : mult_fix
        generic map (
            DATA_WIDTH  => DATA_WIDTH
        )
        port map (
            dataa   => dataa,
            datab   => datab,
            samt    => samt,
            result  => open
        );
    
    clkgen : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process clkgen;

    -- Generates the reset signal
    resetgen : process
    begin  -- process reset
        reset <= '1';
        wait for 2*CLK_PERIOD;
        reset <= '0';
        wait;
    end process;
    
    input : process
    begin
        wait until falling_edge(reset);
        wait until rising_edge(clk);
        
        for i in testcases'low to testcases'high loop
            dataa <= testcases(i).dataa;
            datab <= testcases(i).datab;
            samt  <= testcases(i).samt;
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;
        
        wait;
    end process;
end architecture;
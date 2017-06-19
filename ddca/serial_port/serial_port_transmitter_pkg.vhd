
----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                                 PACKAGE                                      --
----------------------------------------------------------------------------------

package serial_port_transmitter_pkg is

  --------------------------------------------------------------------
  --                          COMPONENT                             --
  --------------------------------------------------------------------
  
  -- serial connection of flip-flops to avoid latching of metastable inputs at
  -- the analog/digital interface
  component serial_port_transmitter is
    generic
    (
      CLK_DIVISOR : integer
    );
    port
    (
      clk, res_n         : in  std_logic;

      data               : in  std_logic_vector(7 downto 0);
      empty              : in  std_logic;
      rd                 : out std_logic;
    
      tx                 : out std_logic
    );
  end component serial_port_transmitter;
end package serial_port_transmitter_pkg;
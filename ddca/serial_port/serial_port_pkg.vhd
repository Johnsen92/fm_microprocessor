----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                                 PACKAGE                                      --
----------------------------------------------------------------------------------

package serial_port_pkg is

  --------------------------------------------------------------------
  --                          COMPONENT                             --
  --------------------------------------------------------------------
  
  -- serial connection of flip-flops to avoid latching of metastable inputs at
  -- the analog/digital interface
  component serial_port is
    generic
    (
      CLK_FREQ, BAUD_RATE, SYNC_STAGES, TX_FIFO_DEPTH, RX_FIFO_DEPTH : integer
    );
    port
    (
      clk, res_n, rx, tx_wr, rx_rd : in  std_logic;
      tx_data  : in  std_logic_vector(7 downto 0);
      rx_data : out std_logic_vector(7 downto 0);
      tx_free, tx, rx_data_empty, rx_data_full : out std_logic
    );
  end component serial_port;
end package serial_port_pkg;

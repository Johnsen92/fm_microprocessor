library ieee;
use ieee.std_logic_1164.all;
use work.sync_pkg.all;
use work.ram_pkg.all;
use work.serial_port_receiver_fsm_pkg.all;
use work.serial_port_transmitter_pkg.all;

----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

-- serial port transmitter
entity serial_port is
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
end entity serial_port;

architecture serial_port_a of serial_port is
  signal rx_sync, tx_empty, tx_full, rd, rx_data_new : std_logic;
  signal tx_data1, rx_data_unsynced : std_logic_vector(7 downto 0);
  
begin
  tx_free <= NOT tx_full;
  rx_sync_inst : sync GENERIC MAP (SYNC_STAGES => SYNC_STAGES, RESET_VALUE => '1') PORT MAP (clk => clk, res_n => res_n, data_in => rx, data_out => rx_sync);
  receiver_inst : serial_port_receiver_fsm GENERIC MAP (CLK_DIVISOR => (CLK_FREQ/BAUD_RATE)) PORT MAP (clk => clk, res_n => res_n, rx => rx_sync, data => rx_data_unsynced, data_new => rx_data_new);
  rx_fifo_inst : fifo_1c1r1w GENERIC MAP (MIN_DEPTH => RX_FIFO_DEPTH, DATA_WIDTH => 8) PORT MAP (clk => clk, res_n => res_n, data_in2 => rx_data_unsynced, wr2 => rx_data_new, rd1 => rx_rd, data_out1 => rx_data, empty => rx_data_empty, full => rx_data_full);
  tx_fifo_inst : fifo_1c1r1w GENERIC MAP (MIN_DEPTH => TX_FIFO_DEPTH, DATA_WIDTH => 8) PORT MAP (clk => clk, res_n => res_n, data_in2 => tx_data, wr2 => tx_wr, rd1 => rd, data_out1 => tx_data1, empty => tx_empty, full => tx_full);
  transmitter_inst : serial_port_transmitter GENERIC MAP (CLK_DIVISOR => (CLK_FREQ/BAUD_RATE)) PORT MAP (clk => clk, res_n => res_n, data => tx_data1, empty => tx_empty, tx => tx, rd => rd);
end serial_port_a;
--- EOF ---

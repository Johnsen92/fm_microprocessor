library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

-- serial port transmitter
entity serial_port_receiver_fsm is
  generic
  (
    CLK_DIVISOR : integer
  );
  port
  (
    clk, res_n, rx : in  std_logic;
    data_new : out std_logic;
    data                     : out  std_logic_vector(7 downto 0)
  );
end entity serial_port_receiver_fsm;

--- EOF ---
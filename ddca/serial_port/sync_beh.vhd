----------------------------------------------------------------------------------
-- Company:      TU Wien - ECS Group                                            --
-- Engineer:     Thomas Polzer                                                  --
--                                                                              --
-- Create Date:  21.09.2010                                                     --
-- Design Name:  DIDELU                                                         --
-- Module Name:  sync_beh                                                       --
-- Project Name: DIDELU                                                         --
-- Description:  Synchronizer - Architecture                                    --
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture beh of sync is
  -- synchronizer stages
  signal sync : std_logic_vector(1 to SYNC_STAGES);
begin

  --------------------------------------------------------------------
  --                    PROCESS : SYNC                              --
  --------------------------------------------------------------------
  
  sync_proc : process(clk, res_n)
  begin
    if res_n = '0' then
      sync <= (others => RESET_VALUE);
    elsif rising_edge(clk) then
      -- get new data
      sync(1) <= data_in;
      -- forward data to next synchronizer stage
      for i in 2 to SYNC_STAGES loop
        sync(i) <= sync(i - 1);
      end loop;
    end if;
  end process sync_proc;
  
  -- output synchronized data
  data_out <= sync(SYNC_STAGES);
  
end architecture beh;

--- EOF ---
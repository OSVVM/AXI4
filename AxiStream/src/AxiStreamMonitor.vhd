--
--  File Name:         AxiStreamMonitor.vhd
--  Design Unit Name:  AxiStreamMonitor
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      AXI Stream Receiver Verification Component
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    06/2025   2025.06    Initial Release
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2025 by SynthWorks Design Inc.
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      https://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--
library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

entity AxiStreamMonitor is
  generic (
    MODEL_ID_NAME  : string :="" ;
    USES_TLAST     : boolean := FALSE 
  ) ;
  port (
    -- Globals
    Clk       : in  std_logic ;
    nReset    : in  std_logic ;

    -- AXI Stream Interface
    TValid    : in  std_logic ;
    TReady    : in  std_logic ;
    TID       : in  std_logic_vector ;
    TDest     : in  std_logic_vector ;
    TUser     : in  std_logic_vector ;
    TData     : in  std_logic_vector ;
    TStrb     : in  std_logic_vector ;
    TKeep     : in  std_logic_vector ;
    TLast     : in  std_logic 
  ) ;

  -- Use MODEL_ID_NAME Generic if set, otherwise,
  -- use model instance label (preferred if set as entityname_1)
  constant MODEL_INSTANCE_NAME : string :=
    ifelse(MODEL_ID_NAME'length > 0, MODEL_ID_NAME,
      to_lower(PathTail(AxiStreamMonitor'PATH_NAME))) ;

end entity AxiStreamMonitor ;
architecture MonitorVC of AxiStreamMonitor is
  signal ModelID : AlertLogIDType ;
  signal TIdPrev   : TID'subtype ; 
  signal TDestPrev : TDest'subtype ; 
  signal TLastPrev : std_logic ; 

begin

  ------------------------------------------------------------
  --  Initialize alerts
  ------------------------------------------------------------
  Initialize : process
    variable ID : AlertLogIDType ;
  begin
    -- Alerts
    ID            := NewID(MODEL_INSTANCE_NAME) ;
    ModelID       <= ID ;
    wait ;
  end process Initialize ;

  MonitorIdDestGen : if USES_TLAST Generate
  begin
    ------------------------------------------------------------
    --  MonitorIdDest
    --    Checks that TID and TDest only change at the start of a transfer
    ------------------------------------------------------------
    MonitorIdDestProc : process
    begin
      TLastPrev <= '1' ; -- indicates next TValid is the start of a cycle.
      wait for 0 ns ;  -- Allow ModelID to initialize
      wait for 0 ns ;  -- Allow TransRec.BurstFifo to update.

      MonitorLoop : loop
        wait until Rising_Edge(Clk) and TValid = '1' ;

        -- If not at start of cycle, check that ID and Dest do not change
        If TLastPrev /= '1' then 
          AlertIf(ModelID, TID /= TIdPrev,      "TID: "   & to_string(TID) &   " /= Previous TID: "   & to_string(TIdPrev) ) ;
          AlertIf(ModelID, TDest /= TDestPrev,  "TDest: " & to_string(TDest) & " /= Previous TDest: " & to_string(TDestPrev) ) ;
        end if  ; 

        -- Log values from this cycle
        TIdPrev   <= TID ; 
        TDestPrev <= TDest ;
        TLastPrev <= TLast ; 
      end loop MonitorLoop ; 
    end process MonitorIdDestProc ; 
  end Generate MonitorIdDestGen ;

end architecture MonitorVC ;

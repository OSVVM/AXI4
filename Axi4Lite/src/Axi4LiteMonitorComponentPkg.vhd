--
--  File Name:         Axi4LiteMonitorComponentPkg.vhd
--  Design Unit Name:  Axi4LiteMonitorComponentPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Simple AXI Lite Master Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date       Version    Description
--    03/2019:   2019       Initial revision
--
--
-- Copyright 2019 SynthWorks Design Inc
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
    context osvvm.OsvvmContext ;

  use work.Axi4LiteInterfacePkg.all ; 
  use work.Axi4CommonPkg.all ; 

package Axi4LiteMonitorComponentPkg is
  component Axi4LiteMonitor is
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- AXI Master Functional Interface
      AxiLiteBus  : in    Axi4LiteRecType 
    ) ;
  end component Axi4LiteMonitor ;
end package Axi4LiteMonitorComponentPkg ;


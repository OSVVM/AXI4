--
--  File Name:         TestCtrl_e.vhd
--  Design Unit Name:  TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Test transaction source
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date       Version    Description
--    09/2017:   2017.09    Initial revision
--    05/2019    2019.05    Added context reference
--
--
-- Copyright 2017-2019 SynthWorks Design Inc
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
--
library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  
library OSVVM ; 
  context OSVVM.OsvvmContext ; 

library OSVVM_AXI4 ;
  context OSVVM_AXI4.Axi4LiteContext ; 

entity TestCtrl is
  generic (
    constant AXI_ADDR_WIDTH : integer := 32 ; 
    constant AXI_DATA_WIDTH : integer := 32  
  ) ;
  port (
    -- Global Signal Interface
    Clk                 : In    std_logic ;
    nReset              : In    std_logic ;

    -- Transaction Interfaces
    AxiMasterTransRec   : inout Axi4LiteMasterTransactionRecType ;
    AxiSlaveTransRec    : inout Axi4LiteSlaveTransactionRecType 

  ) ;
end entity TestCtrl ;

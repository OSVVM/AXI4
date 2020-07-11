--
--  File Name:         Axi4SlaveComponentPkg.vhd
--  Design Unit Name:  Axi4SlaveComponentPkg
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
--    Date      Version    Description
--    03/2019   2019       Initial revision
--    01/2020   2020.01    Updated license notice
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2019 - 2020 by SynthWorks Design Inc.  
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

library osvvm_common ;  
  context osvvm_common.OsvvmCommonContext ;

  use work.Axi4InterfacePkg.all ; 

package Axi4SlaveComponentPkg is

  component Axi4Slave is
    generic (
      tperiod_Clk     : time := 10 ns ;
      
      tpd_Clk_AWReady : time := 2 ns ; 

      tpd_Clk_WReady  : time := 2 ns ; 

      tpd_Clk_BValid  : time := 2 ns ; 
      tpd_Clk_BResp   : time := 2 ns ; 

      tpd_Clk_ARReady : time := 2 ns ; 

      tpd_Clk_RValid  : time := 2 ns ; 
      tpd_Clk_RData   : time := 2 ns ; 
      tpd_Clk_RResp   : time := 2 ns 
    ) ;
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- Testbench Transaction Interface
      TransRec    : inout AddressBusTransactionRecType ;

      -- AXI Master Functional Interface
      AxiBus      : inout Axi4RecType 
    ) ;
        
  end component Axi4Slave ;
end package Axi4SlaveComponentPkg ;

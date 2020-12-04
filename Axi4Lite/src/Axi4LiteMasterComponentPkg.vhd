--
--  File Name:         Axi4LiteMasterComponentPkg.vhd
--  Design Unit Name:  Axi4LiteMasterComponentPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Package for AXI Lite Master Component
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

  use work.Axi4LiteInterfacePkg.all ; 

package Axi4LiteMasterComponentPkg is
  component Axi4LiteMaster is
    generic (
      MODEL_ID_NAME    : string :="" ;
      tperiod_Clk      : time   := 10 ns ;

      tpd_Clk_AWAddr   : time   := 2 ns ;
      tpd_Clk_AWProt   : time   := 2 ns ;
      tpd_Clk_AWValid  : time   := 2 ns ;
      -- AXI4 Full
      tpd_clk_AWLen    : time   := 2 ns ;
      tpd_clk_AWID     : time   := 2 ns ;
      tpd_clk_AWSize   : time   := 2 ns ;
      tpd_clk_AWBurst  : time   := 2 ns ;
      tpd_clk_AWLock   : time   := 2 ns ;
      tpd_clk_AWCache  : time   := 2 ns ;
      tpd_clk_AWQOS    : time   := 2 ns ;
      tpd_clk_AWRegion : time   := 2 ns ;
      tpd_clk_AWUser   : time   := 2 ns ;

      tpd_Clk_WValid   : time   := 2 ns ;
      tpd_Clk_WData    : time   := 2 ns ;
      tpd_Clk_WStrb    : time   := 2 ns ;
      -- AXI4 Full
      tpd_Clk_WLast    : time   := 2 ns ;
      tpd_Clk_WUser    : time   := 2 ns ;
      -- AXI3
      tpd_Clk_WID      : time   := 2 ns ;

      tpd_Clk_BReady   : time   := 2 ns ;

      tpd_Clk_ARValid  : time   := 2 ns ;
      tpd_Clk_ARProt   : time   := 2 ns ;
      tpd_Clk_ARAddr   : time   := 2 ns ;
      -- AXI4 Full
      tpd_clk_ARLen    : time   := 2 ns ;
      tpd_clk_ARID     : time   := 2 ns ;
      tpd_clk_ARSize   : time   := 2 ns ;
      tpd_clk_ARBurst  : time   := 2 ns ;
      tpd_clk_ARLock   : time   := 2 ns ;
      tpd_clk_ARCache  : time   := 2 ns ;
      tpd_clk_ARQOS    : time   := 2 ns ;
      tpd_clk_ARRegion : time   := 2 ns ;
      tpd_clk_ARUser   : time   := 2 ns ;

      tpd_Clk_RReady   : time   := 2 ns 
    ) ;
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- Testbench Transaction Interface
      TransRec    : inout AddressBusRecType ;

      -- AXI Master Functional Interface
      AxiBus  : inout Axi4LiteRecType
    ) ;
  end component Axi4LiteMaster ;
end package Axi4LiteMasterComponentPkg ;


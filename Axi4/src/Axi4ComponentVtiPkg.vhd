--
--  File Name:         Axi4ComponentPkg.vhd
--  Design Unit Name:  Axi4ComponentPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Package for AXI4 Components
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    06/2021   2021.06    Added new generics to Axi4Memory[Vti].vhd
--    02/2021   2021.02    Merged separate component packages into 1
--    01/2020   2020.01    Updated license notice
--    03/2019   2019       Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2019 - 2021 by SynthWorks Design Inc.
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

  use work.Axi4InterfaceCommonPkg.all ;
  use work.Axi4InterfacePkg.all ;

package Axi4ComponentVtiPkg is

  ------------------------------------------------------------
  component Axi4ManagerVti is
  ------------------------------------------------------------
    generic (
      MODEL_ID_NAME    : string := "" ;
      tperiod_Clk      : time   := 10 ns ;

      DEFAULT_DELAY    : time   := 1 ns ; 

      tpd_Clk_AWAddr   : time   := DEFAULT_DELAY ;
      tpd_Clk_AWProt   : time   := DEFAULT_DELAY ;
      tpd_Clk_AWValid  : time   := DEFAULT_DELAY ;
      -- AXI4 Full
      tpd_clk_AWLen    : time   := DEFAULT_DELAY ;
      tpd_clk_AWID     : time   := DEFAULT_DELAY ;
      tpd_clk_AWSize   : time   := DEFAULT_DELAY ;
      tpd_clk_AWBurst  : time   := DEFAULT_DELAY ;
      tpd_clk_AWLock   : time   := DEFAULT_DELAY ;
      tpd_clk_AWCache  : time   := DEFAULT_DELAY ;
      tpd_clk_AWQOS    : time   := DEFAULT_DELAY ;
      tpd_clk_AWRegion : time   := DEFAULT_DELAY ;
      tpd_clk_AWUser   : time   := DEFAULT_DELAY ;

      tpd_Clk_WValid   : time   := DEFAULT_DELAY ;
      tpd_Clk_WData    : time   := DEFAULT_DELAY ;
      tpd_Clk_WStrb    : time   := DEFAULT_DELAY ;
      -- AXI4 Full
      tpd_Clk_WLast    : time   := DEFAULT_DELAY ;
      tpd_Clk_WUser    : time   := DEFAULT_DELAY ;
      -- AXI3
      tpd_Clk_WID      : time   := DEFAULT_DELAY ;

      tpd_Clk_BReady   : time   := DEFAULT_DELAY ;

      tpd_Clk_ARValid  : time   := DEFAULT_DELAY ;
      tpd_Clk_ARProt   : time   := DEFAULT_DELAY ;
      tpd_Clk_ARAddr   : time   := DEFAULT_DELAY ;
      -- AXI4 Full
      tpd_clk_ARLen    : time   := DEFAULT_DELAY ;
      tpd_clk_ARID     : time   := DEFAULT_DELAY ;
      tpd_clk_ARSize   : time   := DEFAULT_DELAY ;
      tpd_clk_ARBurst  : time   := DEFAULT_DELAY ;
      tpd_clk_ARLock   : time   := DEFAULT_DELAY ;
      tpd_clk_ARCache  : time   := DEFAULT_DELAY ;
      tpd_clk_ARQOS    : time   := DEFAULT_DELAY ;
      tpd_clk_ARRegion : time   := DEFAULT_DELAY ;
      tpd_clk_ARUser   : time   := DEFAULT_DELAY ;

      tpd_Clk_RReady   : time   := DEFAULT_DELAY
    ) ;
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- AXI Manager Functional Interface
      AxiBus  : inout Axi4RecType
    ) ;
  end component Axi4ManagerVti ;


  ------------------------------------------------------------
  component Axi4SubordinateVti is
  ------------------------------------------------------------
    generic (
      MODEL_ID_NAME   : string := "" ;
      tperiod_Clk     : time   := 10 ns ;

      DEFAULT_DELAY   : time   := 1 ns ; 

      tpd_Clk_AWReady : time   := DEFAULT_DELAY ;

      tpd_Clk_WReady  : time   := DEFAULT_DELAY ;

      tpd_Clk_BValid  : time   := DEFAULT_DELAY ;
      tpd_Clk_BResp   : time   := DEFAULT_DELAY ;
      tpd_Clk_BID     : time   := DEFAULT_DELAY ;
      tpd_Clk_BUser   : time   := DEFAULT_DELAY ;

      tpd_Clk_ARReady : time   := DEFAULT_DELAY ;

      tpd_Clk_RValid  : time   := DEFAULT_DELAY ;
      tpd_Clk_RData   : time   := DEFAULT_DELAY ;
      tpd_Clk_RResp   : time   := DEFAULT_DELAY ;
      tpd_Clk_RID     : time   := DEFAULT_DELAY ;
      tpd_Clk_RUser   : time   := DEFAULT_DELAY 
    ) ;
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- AXI Manager Functional Interface
      AxiBus      : inout Axi4RecType
    ) ;
  end component Axi4SubordinateVti ;


  ------------------------------------------------------------
  component Axi4MemoryVti is
  ------------------------------------------------------------
    generic (
      MODEL_ID_NAME   : string := "" ;
      MEMORY_NAME      : string := "" ;
      tperiod_Clk     : time   := 10 ns ;

      DEFAULT_DELAY   : time   := 1 ns ; 

      tpd_Clk_AWReady : time   := DEFAULT_DELAY ;

      tpd_Clk_WReady  : time   := DEFAULT_DELAY ;

      tpd_Clk_BValid  : time   := DEFAULT_DELAY ;
      tpd_Clk_BResp   : time   := DEFAULT_DELAY ;
      tpd_Clk_BID     : time   := DEFAULT_DELAY ;
      tpd_Clk_BUser   : time   := DEFAULT_DELAY ;

      tpd_Clk_ARReady : time   := DEFAULT_DELAY ;

      tpd_Clk_RValid  : time   := DEFAULT_DELAY ;
      tpd_Clk_RData   : time   := DEFAULT_DELAY ;
      tpd_Clk_RResp   : time   := DEFAULT_DELAY ;
      tpd_Clk_RID     : time   := DEFAULT_DELAY ;
      tpd_Clk_RUser   : time   := DEFAULT_DELAY ;
      tpd_Clk_RLast   : time   := DEFAULT_DELAY
    ) ;
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- AXI Slave Interface
      AxiBus      : inout Axi4RecType
    ) ;
  end component Axi4MemoryVti ;


end package Axi4ComponentVtiPkg ;


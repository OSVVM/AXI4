--
--  File Name:         Axi4LiteComponentPkg.vhd
--  Design Unit Name:  Axi4LiteComponentPkg
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

  use work.Axi4InterfaceCommonPkg.all ;
  use work.Axi4LiteInterfacePkg.all ; 

package Axi4LiteComponentPkg is
  component Axi4LiteManager is
    generic (
      MODEL_ID_NAME    : string := "" ;
      tperiod_Clk      : time   := 10 ns ;
      
      DEFAULT_DELAY    : time   := 1 ns ; 

      tpd_Clk_AWAddr   : time   := DEFAULT_DELAY ;
      tpd_Clk_AWProt   : time   := DEFAULT_DELAY ;
      tpd_Clk_AWValid  : time   := DEFAULT_DELAY ;

      tpd_Clk_WValid   : time   := DEFAULT_DELAY ;
      tpd_Clk_WData    : time   := DEFAULT_DELAY ;
      tpd_Clk_WStrb    : time   := DEFAULT_DELAY ;

      tpd_Clk_BReady   : time   := DEFAULT_DELAY ;

      tpd_Clk_ARValid  : time   := DEFAULT_DELAY ;
      tpd_Clk_ARProt   : time   := DEFAULT_DELAY ;
      tpd_Clk_ARAddr   : time   := DEFAULT_DELAY ;

      tpd_Clk_RReady   : time   := DEFAULT_DELAY
    ) ;
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- AXI Manager Functional Interface
      AxiBus      : inout Axi4LiteRecType ;

      -- Testbench Transaction Interface
      TransRec    : inout AddressBusRecType 
    ) ;
  end component Axi4LiteManager ;
  
  
  component Axi4LiteMemory is
    generic (
    MODEL_ID_NAME   : string := "" ;
    MEMORY_NAME     : string := "" ;
    tperiod_Clk     : time   := 10 ns ;

    DEFAULT_DELAY   : time   := 1 ns ; 

    tpd_Clk_AWReady : time   := DEFAULT_DELAY ;

    tpd_Clk_WReady  : time   := DEFAULT_DELAY ;

    tpd_Clk_BValid  : time   := DEFAULT_DELAY ;
    tpd_Clk_BResp   : time   := DEFAULT_DELAY ;

    tpd_Clk_ARReady : time   := DEFAULT_DELAY ;

    tpd_Clk_RValid  : time   := DEFAULT_DELAY ;
    tpd_Clk_RData   : time   := DEFAULT_DELAY ;
    tpd_Clk_RResp   : time   := DEFAULT_DELAY 
    ) ;
    port (
    -- Globals
    Clk         : in   std_logic ;
    nReset      : in   std_logic ;

    -- AXI Subordinate Interface
    AxiBus      : inout Axi4LiteRecType ;

    -- Testbench Transaction Interface
    TransRec    : inout AddressBusRecType
    ) ;
  end component Axi4LiteMemory ;


  component Axi4LiteSubordinate is
    generic (
      MODEL_ID_NAME   : string := "" ;
      tperiod_Clk     : time   := 10 ns ;

      DEFAULT_DELAY   : time   := 1 ns ; 

      tpd_Clk_AWReady : time   := DEFAULT_DELAY ;

      tpd_Clk_WReady  : time   := DEFAULT_DELAY ;

      tpd_Clk_BValid  : time   := DEFAULT_DELAY ;
      tpd_Clk_BResp   : time   := DEFAULT_DELAY ;

      tpd_Clk_ARReady : time   := DEFAULT_DELAY ;

      tpd_Clk_RValid  : time   := DEFAULT_DELAY ;
      tpd_Clk_RData   : time   := DEFAULT_DELAY ;
      tpd_Clk_RResp   : time   := DEFAULT_DELAY 
    ) ;
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- AXI Manager Functional Interface
      AxiBus      : inout Axi4LiteRecType ;

      -- Testbench Transaction Interface
      TransRec    : inout AddressBusRecType
    ) ;
  end component Axi4LiteSubordinate ;  
  
  component Axi4LiteMonitor is
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- AXI Master Functional Interface
      AxiBus      : in    Axi4LiteRecType 
    ) ;
  end component Axi4LiteMonitor ;
  
  component Axi4LitePassThru is
    port (
    -- AXI Manager Interface 
      -- AXI Write Address Channel
      mAwAddr       : out   std_logic_vector ; 
      mAwProt       : out   Axi4ProtType ;
      mAwValid      : out   std_logic ; 
      mAwReady      : in    std_logic ; 

      -- AXI Write Data Channel
      mWData        : out   std_logic_vector ; 
      mWStrb        : out   std_logic_vector ; 
      mWValid       : out   std_logic ; 
      mWReady       : in    std_logic ; 

      -- AXI Write Response Channel
      mBValid       : in    std_logic ; 
      mBReady       : out   std_logic ; 
      mBResp        : in    Axi4RespType ; 
    
      -- AXI Read Address Channel
      mArAddr       : out   std_logic_vector ; 
      mArProt       : out   Axi4ProtType ;
      mArValid      : out   std_logic ; 
      mArReady      : in    std_logic ; 

      -- AXI Read Data Channel
      mRData        : in    std_logic_vector ; 
      mRResp        : in    Axi4RespType ;
      mRValid       : in    std_logic ; 
      mRReady       : out   std_logic ; 


    -- AXI Subordinate Interface 
      -- AXI Write Address Channel
      sAwAddr       : in    std_logic_vector ; 
      sAwProt       : in    Axi4ProtType ;
      sAwValid      : in    std_logic ; 
      sAwReady      : out   std_logic ; 

      -- AXI Write Data Channel
      sWData        : in    std_logic_vector ; 
      sWStrb        : in    std_logic_vector ; 
      sWValid       : in    std_logic ; 
      sWReady       : out   std_logic ; 

      -- AXI Write Response Channel
      sBValid       : out   std_logic ; 
      sBReady       : in    std_logic ; 
      sBResp        : out   Axi4RespType ; 
    
    
      -- AXI Read Address Channel
      sArAddr       : in    std_logic_vector ; 
      sArProt       : in    Axi4ProtType ;
      sArValid      : in    std_logic ; 
      sArReady      : out   std_logic ; 

      -- AXI Read Data Channel
      sRData        : out   std_logic_vector ; 
      sRResp        : out   Axi4RespType ;
      sRValid       : out   std_logic ; 
      sRReady       : in    std_logic  
    ) ;
  end component Axi4LitePassThru ;

end package Axi4LiteComponentPkg ;


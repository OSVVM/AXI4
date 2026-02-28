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
  use work.Axi4InterfaceModeViewPkg.all ;

package Axi4ComponentPkg is

  ------------------------------------------------------------
  component Axi4Manager is
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
      AxiBus      : view Axi4ManagerView of Axi4RecType ;

      -- Testbench Transaction Interface
      TransRec    : view AddressBusVerificationComponentView of AddressBusRecType  
    ) ;
  end component Axi4Manager ;


  ------------------------------------------------------------
  component Axi4Subordinate is
  ------------------------------------------------------------
    generic (
      MODEL_ID_NAME   : string := "" ;
      tperiod_Clk     : time   := 10 ns ;

      DEFAULT_DELAY    : time   := 1 ns ; 

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

      -- AXI Manager Functional Interface
      AxiBus      : view Axi4SubordinateView of Axi4RecType ;

      -- Testbench Transaction Interface
      TransRec    : view AddressBusVerificationComponentView of AddressBusRecType  
    ) ;
  end component Axi4Subordinate ;


  ------------------------------------------------------------
  component Axi4Memory is
  ------------------------------------------------------------
    generic (
      MODEL_ID_NAME   : string := "" ;
      MEMORY_NAME     : string := "" ;
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

      -- AXI Subordinate Interface
      AxiBus      : view Axi4SubordinateView of Axi4RecType ;

      -- Testbench Transaction Interface
      TransRec    : view AddressBusVerificationComponentView of AddressBusRecType  
    ) ;
  end component Axi4Memory ;


  ------------------------------------------------------------
  component Axi4Monitor is
  ------------------------------------------------------------
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- AXI Manager Functional Interface
      AxiBus      : in    Axi4RecType
    ) ;
  end component Axi4Monitor ;


  ------------------------------------------------------------
  component Axi4PassThru is
  ------------------------------------------------------------
    port (
    -- AXI Manager Interface 
      -- AXI Write Address Channel
      -- AXI4 Lite
      mAwAddr       : out   std_logic_vector ; 
      mAwProt       : out   Axi4ProtType ;
      mAwValid      : out   std_logic ; 
      mAwReady      : in    std_logic ; 
      -- AXI4 Full
      -- User Config - AXI recommended 3:0 for master, 7:0 at slave
      mAwID         : out   std_logic_vector ; 
      -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
      mAwLen        : out   std_logic_vector(7 downto 0) ; 
      -- #Bytes in transfer = 2**AxSize
      mAwSize       : out   std_logic_vector(2 downto 0) ; 
      -- AxBurst Binary Encoded (Fixed, Incr, Wrap, NotDefined)
      mAwBurst      : out   std_logic_vector(1 downto 0) ; 
      mAwLock       : out   std_logic ;
      -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
      mAwCache      : out   std_logic_vector(3 downto 0) ;
      mAwQOS        : out   std_logic_vector(3 downto 0) ;
      mAwRegion     : out   std_logic_vector(3 downto 0) ;
      mAwUser       : out   std_logic_vector ; -- User Config

      -- AXI Write Data Channel
      -- AXI4 Lite
      mWData        : out   std_logic_vector ; 
      mWStrb        : out   std_logic_vector ; 
      mWValid       : out   std_logic ; 
      mWReady       : in    std_logic ; 
      -- AXI 4 Full 
      mWLast        : out   std_logic ;
      mWUser        : out   std_logic_vector ;
      -- AXI3       
      mWID          : out   std_logic_vector ;

      -- AXI Write Response Channel
      -- AXI4 Lite
      mBValid       : in    std_logic ; 
      mBReady       : out   std_logic ; 
      mBResp        : in    Axi4RespType ; 
      -- AXI 4 Full 
      mBID          : in    std_logic_vector ;
      mBUser        : in    std_logic_vector ;
    
      -- AXI Read Address Channel
      -- AXI4 Lite
      mArAddr       : out   std_logic_vector ; 
      mArProt       : out   Axi4ProtType ;
      mArValid      : out   std_logic ; 
      mArReady      : in    std_logic ; 
      -- AXI4 Full
      -- User Config - AXI recommended 3:0 for master, 7:0 at slave
      mArID         : out   std_logic_vector ; 
      -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
      mArLen        : out   std_logic_vector(7 downto 0) ; 
      -- #Bytes in transfer = 2**AxSize
      mArSize       : out   std_logic_vector(2 downto 0) ; 
      -- AxBurst Binary Encoded (Fixed, Incr, Wrap, NotDefined)
      mArBurst      : out   std_logic_vector(1 downto 0) ; 
      mArLock       : out   std_logic ;
      -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
      mArCache      : out   std_logic_vector(3 downto 0) ;
      mArQOS        : out   std_logic_vector(3 downto 0) ;
      mArRegion     : out   std_logic_vector(3 downto 0) ;
      mArUser       : out   std_logic_vector ; -- User Config

      -- AXI Read Data Channel
      -- AXI4 Lite
      mRData        : in    std_logic_vector ; 
      mRResp        : in    Axi4RespType ;
      mRValid       : in    std_logic ; 
      mRReady       : out   std_logic ; 
      -- AXI 4 Full 
      mRLast        : in    std_logic ;
      mRUser        : in    std_logic_vector ;
      mRID          : in    std_logic_vector ;


    -- AXI Subordinate Interface 
      -- AXI Write Address Channel
      -- AXI4 Lite
      sAwAddr       : in    std_logic_vector ; 
      sAwProt       : in    Axi4ProtType ;
      sAwValid      : in    std_logic ; 
      sAwReady      : out   std_logic ; 
      -- AXI4 Full
      -- User Config - AXI recommended 3:0 for master, 7:0 at slave
      sAwID         : in    std_logic_vector ; 
      -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
      sAwLen        : in    std_logic_vector(7 downto 0) ; 
      -- #Bytes in transfer = 2**AxSize
      sAwSize       : in    std_logic_vector(2 downto 0) ; 
      -- AxBurst Binary Encoded (Fixed, Incr, Wrap, NotDefined)
      sAwBurst      : in    std_logic_vector(1 downto 0) ; 
      sAwLock       : in    std_logic ;
      -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
      sAwCache      : in    std_logic_vector(3 downto 0) ;
      sAwQOS        : in    std_logic_vector(3 downto 0) ;
      sAwRegion     : in    std_logic_vector(3 downto 0) ;
      sAwUser       : in    std_logic_vector ; -- User Config

      -- AXI Write Data Channel
      -- AXI4 Lite
      sWData        : in    std_logic_vector ; 
      sWStrb        : in    std_logic_vector ; 
      sWValid       : in    std_logic ; 
      sWReady       : out   std_logic ; 
      -- AXI 4 Full 
      sWLast        : in    std_logic ;
      sWUser        : in    std_logic_vector ;
      -- AXI3       
      sWID          : in    std_logic_vector ;

      -- AXI Write Response Channel
      -- AXI4 Lite
      sBValid       : out   std_logic ; 
      sBReady       : in    std_logic ; 
      sBResp        : out   Axi4RespType ; 
      -- AXI 4 Full 
      sBID          : out   std_logic_vector ;
      sBUser        : out   std_logic_vector ;
    
    
      -- AXI Read Address Channel
      -- AXI4 Lite
      sArAddr       : in    std_logic_vector ; 
      sArProt       : in    Axi4ProtType ;
      sArValid      : in    std_logic ; 
      sArReady      : out   std_logic ; 
      -- AXI4 Full
      -- User Config - AXI recommended 3:0 for master, 7:0 at slave
      sArID         : in    std_logic_vector ; 
      -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
      sArLen        : in    std_logic_vector(7 downto 0) ; 
      -- #Bytes in transfer = 2**AxSize
      sArSize       : in    std_logic_vector(2 downto 0) ; 
      -- AxBurst Binary Encoded (Fixed, Incr, Wrap, NotDefined)
      sArBurst      : in    std_logic_vector(1 downto 0) ; 
      sArLock       : in    std_logic ;
      -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
      sArCache      : in    std_logic_vector(3 downto 0) ;
      sArQOS        : in    std_logic_vector(3 downto 0) ;
      sArRegion     : in    std_logic_vector(3 downto 0) ;
      sArUser       : in    std_logic_vector ; -- User Config

      -- AXI Read Data Channel
      -- AXI4 Lite
      sRData        : out   std_logic_vector ; 
      sRResp        : out   Axi4RespType ;
      sRValid       : out   std_logic ; 
      sRReady       : in    std_logic ; 
      -- AXI 4 Full 
      sRLast        : out   std_logic ;
      sRUser        : out   std_logic_vector ;    
      sRID          : out   std_logic_vector 
    ) ;
  end component Axi4PassThru ;
  
end package Axi4ComponentPkg ;


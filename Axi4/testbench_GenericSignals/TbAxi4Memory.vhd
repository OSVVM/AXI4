--
--  File Name:         TbAxi4Memory.vhd
--  Design Unit Name:  TbAxi4Memory
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Simple AXI Lite Manager Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    12/2020   2020.12    Updated signal and port names
--    01/2020   2020.01    Updated license notice
--    04/2018   2018       Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2018 - 2024 by SynthWorks Design Inc.
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

library osvvm ;
  context osvvm.OsvvmContext ;

library OSVVM_AXI4 ;
  context OSVVM_AXI4.Axi4Context ;

entity TbAxi4Memory is
end entity TbAxi4Memory ;
architecture TestHarness of TbAxi4Memory is
  constant tperiod_Clk : time := 10 ns ;
  constant tpd         : time := 2 ns ;

  signal Clk         : std_logic ;
  signal nReset      : std_logic ;

  package Manager is new OSVVM_AXI4.Axi4GenericSignalsPkg
    generic map (
      AXI_ADDR_WIDTH   => 32, 
      AXI_DATA_WIDTH   => 32, 
      AXI_ID_WIDTH     => 8,
      AXI_USER_WIDTH   => 8
    ) ;

  package Subordinate is new OSVVM_AXI4.Axi4GenericSignalsPkg
    generic map (
      AXI_ADDR_WIDTH   => 32, 
      AXI_DATA_WIDTH   => 32, 
      AXI_ID_WIDTH     => 8,
      AXI_USER_WIDTH   => 8
    ) ;


  component TestCtrl is
    port (
      -- Global Signal Interface
      nReset         : In    std_logic ;

      -- Transaction Interfaces
      ManagerRec      : inout AddressBusRecType ;
      SubordinateRec   : inout AddressBusRecType
    ) ;
  end component TestCtrl ;


begin

  ------------------------------------------------------------
  -- create Clock
  Osvvm.ClockResetPkg.CreateClock (
  ------------------------------------------------------------
    Clk        => Clk,
    Period     => Tperiod_Clk
  )  ;

  ------------------------------------------------------------
  -- create nReset
  Osvvm.ClockResetPkg.CreateReset (
  ------------------------------------------------------------
    Reset       => nReset,
    ResetActive => '0',
    Clk         => Clk,
    Period      => 7 * tperiod_Clk,
    tpd         => tpd
  ) ;

  ------------------------------------------------------------
  Axi4PassThru_1 : Axi4PassThru 
  ------------------------------------------------------------
  port map (
  -- AXI Manager Interface - Driven By PassThru
    -- AXI Write Address Channel
    mAwAddr       => Subordinate.AwAddr,
    mAwProt       => Subordinate.AwProt,
    mAwValid      => Subordinate.AwValid,
    mAwReady      => Subordinate.AwReady,
    mAwID         => Subordinate.AwID,
    mAwLen        => Subordinate.AwLen,
    mAwSize       => Subordinate.AwSize,
    mAwBurst      => Subordinate.AwBurst,
    mAwLock       => Subordinate.AwLock,
    mAwCache      => Subordinate.AwCache,
    mAwQOS        => Subordinate.AwQOS,
    mAwRegion     => Subordinate.AwRegion,
    mAwUser       => Subordinate.AwUser,

    -- AXI Write Data Channel
    mWData        => Subordinate.WData, 
    mWStrb        => Subordinate.WStrb, 
    mWValid       => Subordinate.WValid, 
    mWReady       => Subordinate.WReady, 
    mWLast        => Subordinate.WLast,
    mWUser        => Subordinate.WUser,
    mWID          => Subordinate.WID,

    -- AXI Write Response Channel
    mBValid       => Subordinate.BValid, 
    mBReady       => Subordinate.BReady, 
    mBResp        => Subordinate.BResp, 
    mBID          => Subordinate.BID,
    mBUser        => Subordinate.BUser,
  
    -- AXI Read Address Channel
    mArAddr       => Subordinate.ArAddr,
    mArProt       => Subordinate.ArProt,
    mArValid      => Subordinate.ArValid,
    mArReady      => Subordinate.ArReady,
    mArID         => Subordinate.ArID,
    mArLen        => Subordinate.ArLen,
    mArSize       => Subordinate.ArSize,
    mArBurst      => Subordinate.ArBurst,
    mArLock       => Subordinate.ArLock,
    mArCache      => Subordinate.ArCache,
    mArQOS        => Subordinate.ArQOS,
    mArRegion     => Subordinate.ArRegion,
    mArUser       => Subordinate.ArUser,

    -- AXI Read Data Channel
    mRData        => Subordinate.RData, 
    mRResp        => Subordinate.RResp,
    mRValid       => Subordinate.RValid, 
    mRReady       => Subordinate.RReady, 
    mRLast        => Subordinate.RLast,
    mRUser        => Subordinate.RUser,
    mRID          => Subordinate.RID,


  -- AXI Subordinate Interface - Driven by DUT
    -- AXI Write Address Channel
    sAwAddr       => Manager.AwAddr,
    sAwProt       => Manager.AwProt,
    sAwValid      => Manager.AwValid,
    sAwReady      => Manager.AwReady,
    sAwID         => Manager.AwID,
    sAwLen        => Manager.AwLen,
    sAwSize       => Manager.AwSize,
    sAwBurst      => Manager.AwBurst,
    sAwLock       => Manager.AwLock,
    sAwCache      => Manager.AwCache,
    sAwQOS        => Manager.AwQOS,
    sAwRegion     => Manager.AwRegion,
    sAwUser       => Manager.AwUser,

    -- AXI Write Data Channel
    sWData        => Manager.WData,  
    sWStrb        => Manager.WStrb,  
    sWValid       => Manager.WValid, 
    sWReady       => Manager.WReady, 
    sWLast        => Manager.WLast,
    sWUser        => Manager.WUser,
    sWID          => Manager.WID,

    -- AXI Write Response Channel
    sBValid       => Manager.BValid, 
    sBReady       => Manager.BReady, 
    sBResp        => Manager.BResp,  
    sBID          => Manager.BID,
    sBUser        => Manager.BUser,
  
  
    -- AXI Read Address Channel
    sArAddr       => Manager.ArAddr,
    sArProt       => Manager.ArProt,
    sArValid      => Manager.ArValid,
    sArReady      => Manager.ArReady,
    sArID         => Manager.ArID,
    sArLen        => Manager.ArLen,
    sArSize       => Manager.ArSize,
    sArBurst      => Manager.ArBurst,
    sArLock       => Manager.ArLock,
    sArCache      => Manager.ArCache,
    sArQOS        => Manager.ArQOS,
    sArRegion     => Manager.ArRegion,
    sArUser       => Manager.ArUser,

    -- AXI Read Data Channel
    sRData        => Manager.RData,  
    sRResp        => Manager.RResp,
    sRValid       => Manager.RValid, 
    sRReady       => Manager.RReady, 
    sRLast        => Manager.RLast,
    sRUser        => Manager.RUser,   
    sRID          => Manager.RID
  ) ;
  
  ------------------------------------------------------------
  -- Behavioral model.  Replaces DUT for labs
  Memory_1 : Axi4Memory
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus      => Subordinate.AxiBus,
    
    -- Testbench Transaction Interface
    TransRec    => Subordinate.TransRec
  ) ;

  ------------------------------------------------------------
  Manager_1 : Axi4Manager
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus      => Manager.AxiBus,

    -- Testbench Transaction Interface
    TransRec    => Manager.TransRec
  ) ;


  ------------------------------------------------------------
  Monitor_1 : Axi4Monitor
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus      => Manager.AxiBus
  ) ;


  ------------------------------------------------------------
  TestCtrl_1 : TestCtrl
  ------------------------------------------------------------
  port map (
    -- Global Signal Interface
    nReset          => nReset,

    -- Transaction Interfaces
    ManagerRec      => Manager.TransRec,
    SubordinateRec  => Subordinate.TransRec
  ) ;

end architecture TestHarness ;
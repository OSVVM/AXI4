--
--  File Name:         TbAxi4.vhd
--  Design Unit Name:  TbAxi4
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
--    04/2018   2018       Initial revision
--    01/2020   2020.01    Updated license notice
--    12/2020   2020.12    Updated signal and port names
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.
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

entity TbAxi4 is
end entity TbAxi4 ;
architecture TestHarness of TbAxi4 is

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
    mAwAddr       => Subordinate.AxiBus.WriteAddress.Addr,
    mAwProt       => Subordinate.AxiBus.WriteAddress.Prot,
    mAwValid      => Subordinate.AxiBus.WriteAddress.Valid,
    mAwReady      => Subordinate.AxiBus.WriteAddress.Ready,
    mAwID         => Subordinate.AxiBus.WriteAddress.ID,
    mAwLen        => Subordinate.AxiBus.WriteAddress.Len,
    mAwSize       => Subordinate.AxiBus.WriteAddress.Size,
    mAwBurst      => Subordinate.AxiBus.WriteAddress.Burst,
    mAwLock       => Subordinate.AxiBus.WriteAddress.Lock,
    mAwCache      => Subordinate.AxiBus.WriteAddress.Cache,
    mAwQOS        => Subordinate.AxiBus.WriteAddress.QOS,
    mAwRegion     => Subordinate.AxiBus.WriteAddress.Region,
    mAwUser       => Subordinate.AxiBus.WriteAddress.User,

    -- AXI Write Data Channel
    mWData        => Subordinate.AxiBus.WriteData.Data, 
    mWStrb        => Subordinate.AxiBus.WriteData.Strb, 
    mWValid       => Subordinate.AxiBus.WriteData.Valid, 
    mWReady       => Subordinate.AxiBus.WriteData.Ready, 
    mWLast        => Subordinate.AxiBus.WriteData.Last,
    mWUser        => Subordinate.AxiBus.WriteData.User,
    mWID          => Subordinate.AxiBus.WriteData.ID,

    -- AXI Write Response Channel
    mBValid       => Subordinate.AxiBus.WriteResponse.Valid, 
    mBReady       => Subordinate.AxiBus.WriteResponse.Ready, 
    mBResp        => Subordinate.AxiBus.WriteResponse.Resp, 
    mBID          => Subordinate.AxiBus.WriteResponse.ID,
    mBUser        => Subordinate.AxiBus.WriteResponse.User,
  
    -- AXI Read Address Channel
    mArAddr       => Subordinate.AxiBus.ReadAddress.Addr,
    mArProt       => Subordinate.AxiBus.ReadAddress.Prot,
    mArValid      => Subordinate.AxiBus.ReadAddress.Valid,
    mArReady      => Subordinate.AxiBus.ReadAddress.Ready,
    mArID         => Subordinate.AxiBus.ReadAddress.ID,
    mArLen        => Subordinate.AxiBus.ReadAddress.Len,
    mArSize       => Subordinate.AxiBus.ReadAddress.Size,
    mArBurst      => Subordinate.AxiBus.ReadAddress.Burst,
    mArLock       => Subordinate.AxiBus.ReadAddress.Lock,
    mArCache      => Subordinate.AxiBus.ReadAddress.Cache,
    mArQOS        => Subordinate.AxiBus.ReadAddress.QOS,
    mArRegion     => Subordinate.AxiBus.ReadAddress.Region,
    mArUser       => Subordinate.AxiBus.ReadAddress.User,

    -- AXI Read Data Channel
    mRData        => Subordinate.AxiBus.ReadData.Data, 
    mRResp        => Subordinate.AxiBus.ReadData.Resp,
    mRValid       => Subordinate.AxiBus.ReadData.Valid, 
    mRReady       => Subordinate.AxiBus.ReadData.Ready, 
    mRLast        => Subordinate.AxiBus.ReadData.Last,
    mRUser        => Subordinate.AxiBus.ReadData.User,
    mRID          => Subordinate.AxiBus.ReadData.ID,


  -- DUT Subordinate Interface - Connects to  
    -- AXI Write Address Channel
    sAwAddr       => Manager.AxiBus.WriteAddress.Addr,
    sAwProt       => Manager.AxiBus.WriteAddress.Prot,
    sAwValid      => Manager.AxiBus.WriteAddress.Valid,
    sAwReady      => Manager.AxiBus.WriteAddress.Ready,
    sAwID         => Manager.AxiBus.WriteAddress.ID,
    sAwLen        => Manager.AxiBus.WriteAddress.Len,
    sAwSize       => Manager.AxiBus.WriteAddress.Size,
    sAwBurst      => Manager.AxiBus.WriteAddress.Burst,
    sAwLock       => Manager.AxiBus.WriteAddress.Lock,
    sAwCache      => Manager.AxiBus.WriteAddress.Cache,
    sAwQOS        => Manager.AxiBus.WriteAddress.QOS,
    sAwRegion     => Manager.AxiBus.WriteAddress.Region,
    sAwUser       => Manager.AxiBus.WriteAddress.User,

    -- AXI Write Data Channel
    sWData        => Manager.AxiBus.WriteData.Data,  
    sWStrb        => Manager.AxiBus.WriteData.Strb,  
    sWValid       => Manager.AxiBus.WriteData.Valid, 
    sWReady       => Manager.AxiBus.WriteData.Ready, 
    sWLast        => Manager.AxiBus.WriteData.Last,
    sWUser        => Manager.AxiBus.WriteData.User,
    sWID          => Manager.AxiBus.WriteData.ID,

    -- AXI Write Response Channel
    sBValid       => Manager.AxiBus.WriteResponse.Valid, 
    sBReady       => Manager.AxiBus.WriteResponse.Ready, 
    sBResp        => Manager.AxiBus.WriteResponse.Resp,  
    sBID          => Manager.AxiBus.WriteResponse.ID,
    sBUser        => Manager.AxiBus.WriteResponse.User,
  
    -- AXI Read Address Channel
    sArAddr       => Manager.AxiBus.ReadAddress.Addr,
    sArProt       => Manager.AxiBus.ReadAddress.Prot,
    sArValid      => Manager.AxiBus.ReadAddress.Valid,
    sArReady      => Manager.AxiBus.ReadAddress.Ready,
    sArID         => Manager.AxiBus.ReadAddress.ID,
    sArLen        => Manager.AxiBus.ReadAddress.Len,
    sArSize       => Manager.AxiBus.ReadAddress.Size,
    sArBurst      => Manager.AxiBus.ReadAddress.Burst,
    sArLock       => Manager.AxiBus.ReadAddress.Lock,
    sArCache      => Manager.AxiBus.ReadAddress.Cache,
    sArQOS        => Manager.AxiBus.ReadAddress.QOS,
    sArRegion     => Manager.AxiBus.ReadAddress.Region,
    sArUser       => Manager.AxiBus.ReadAddress.User,

    -- AXI Read Data Channel
    sRData        => Manager.AxiBus.ReadData.Data,  
    sRResp        => Manager.AxiBus.ReadData.Resp,
    sRValid       => Manager.AxiBus.ReadData.Valid, 
    sRReady       => Manager.AxiBus.ReadData.Ready, 
    sRLast        => Manager.AxiBus.ReadData.Last,
    sRUser        => Manager.AxiBus.ReadData.User,   
    sRID          => Manager.AxiBus.ReadData.ID
  ) ;
  
  ------------------------------------------------------------
  -- Behavioral model.  Replaces DUT for labs
  Subordinate_1 : Axi4Subordinate
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Bus Functional Interface
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

    -- AXI Bus Functional Interface
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
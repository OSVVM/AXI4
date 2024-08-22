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
  constant AXI_ADDR_WIDTH : integer := 32 ;
  constant AXI_DATA_WIDTH : integer := 32 ;
  constant AXI_STRB_WIDTH : integer := AXI_DATA_WIDTH/8 ;

  constant tperiod_Clk : time := 10 ns ;
  constant tpd         : time := 2 ns ;

  signal Clk         : std_logic ;
  signal nReset      : std_logic ;

  -- Testbench Transaction Interface
  signal ManagerRec, SubordinateRec  : AddressBusRecType (
          Address(AXI_ADDR_WIDTH-1 downto 0),
          DataToModel(AXI_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI_DATA_WIDTH-1 downto 0)
        ) ;

  --  AXI Interface
  signal   ManagerAxiBus, SubordinateAxiBus : Axi4RecType(
    WriteAddress(
      Addr(AXI_ADDR_WIDTH-1 downto 0),
      ID(7 downto 0),
      User(7 downto 0)
    ),
    WriteData   (
      Data(AXI_DATA_WIDTH-1 downto 0),
      Strb(AXI_STRB_WIDTH-1 downto 0),
      User(7 downto 0),
      ID(7 downto 0)
    ),
    WriteResponse(
      ID(7 downto 0),
      User(7 downto 0)
    ),
    ReadAddress (
      Addr(AXI_ADDR_WIDTH-1 downto 0),
      ID(7 downto 0),
      User(7 downto 0)
    ),
    ReadData    (
      Data(AXI_DATA_WIDTH-1 downto 0),
      ID(7 downto 0),
      User(7 downto 0)
    )
  ) ;


  component TestCtrl is
    port (
      -- Global Signal Interface
      nReset           : In    std_logic ;

      -- Transaction Interfaces
      ManagerRec       : inout AddressBusRecType ;
      SubordinateRec   : inout AddressBusRecType
    ) ;
  end component TestCtrl ;


begin

  ------------------------------------------------------------
  -- create Clock - From ClockResetPkg
 CreateClock (
  ------------------------------------------------------------
    Clk        => Clk,
    Period     => Tperiod_Clk
  )  ;

  ------------------------------------------------------------
  -- create nReset - From ClockResetPkg
  CreateReset (
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
    mAwAddr       => SubordinateAxiBus.WriteAddress.Addr,
    mAwProt       => SubordinateAxiBus.WriteAddress.Prot,
    mAwValid      => SubordinateAxiBus.WriteAddress.Valid,
    mAwReady      => SubordinateAxiBus.WriteAddress.Ready,
    mAwID         => SubordinateAxiBus.WriteAddress.ID,
    mAwLen        => SubordinateAxiBus.WriteAddress.Len,
    mAwSize       => SubordinateAxiBus.WriteAddress.Size,
    mAwBurst      => SubordinateAxiBus.WriteAddress.Burst,
    mAwLock       => SubordinateAxiBus.WriteAddress.Lock,
    mAwCache      => SubordinateAxiBus.WriteAddress.Cache,
    mAwQOS        => SubordinateAxiBus.WriteAddress.QOS,
    mAwRegion     => SubordinateAxiBus.WriteAddress.Region,
    mAwUser       => SubordinateAxiBus.WriteAddress.User,

    -- AXI Write Data Channel
    mWData        => SubordinateAxiBus.WriteData.Data, 
    mWStrb        => SubordinateAxiBus.WriteData.Strb, 
    mWValid       => SubordinateAxiBus.WriteData.Valid, 
    mWReady       => SubordinateAxiBus.WriteData.Ready, 
    mWLast        => SubordinateAxiBus.WriteData.Last,
    mWUser        => SubordinateAxiBus.WriteData.User,
    mWID          => SubordinateAxiBus.WriteData.ID,

    -- AXI Write Response Channel
    mBValid       => SubordinateAxiBus.WriteResponse.Valid, 
    mBReady       => SubordinateAxiBus.WriteResponse.Ready, 
    mBResp        => SubordinateAxiBus.WriteResponse.Resp, 
    mBID          => SubordinateAxiBus.WriteResponse.ID,
    mBUser        => SubordinateAxiBus.WriteResponse.User,
  
    -- AXI Read Address Channel
    mArAddr       => SubordinateAxiBus.ReadAddress.Addr,
    mArProt       => SubordinateAxiBus.ReadAddress.Prot,
    mArValid      => SubordinateAxiBus.ReadAddress.Valid,
    mArReady      => SubordinateAxiBus.ReadAddress.Ready,
    mArID         => SubordinateAxiBus.ReadAddress.ID,
    mArLen        => SubordinateAxiBus.ReadAddress.Len,
    mArSize       => SubordinateAxiBus.ReadAddress.Size,
    mArBurst      => SubordinateAxiBus.ReadAddress.Burst,
    mArLock       => SubordinateAxiBus.ReadAddress.Lock,
    mArCache      => SubordinateAxiBus.ReadAddress.Cache,
    mArQOS        => SubordinateAxiBus.ReadAddress.QOS,
    mArRegion     => SubordinateAxiBus.ReadAddress.Region,
    mArUser       => SubordinateAxiBus.ReadAddress.User,

    -- AXI Read Data Channel
    mRData        => SubordinateAxiBus.ReadData.Data, 
    mRResp        => SubordinateAxiBus.ReadData.Resp,
    mRValid       => SubordinateAxiBus.ReadData.Valid, 
    mRReady       => SubordinateAxiBus.ReadData.Ready, 
    mRLast        => SubordinateAxiBus.ReadData.Last,
    mRUser        => SubordinateAxiBus.ReadData.User,
    mRID          => SubordinateAxiBus.ReadData.ID,


  -- AXI Subordinate Interface - Driven by DUT
    -- AXI Write Address Channel
    sAwAddr       => ManagerAxiBus.WriteAddress.Addr,
    sAwProt       => ManagerAxiBus.WriteAddress.Prot,
    sAwValid      => ManagerAxiBus.WriteAddress.Valid,
    sAwReady      => ManagerAxiBus.WriteAddress.Ready,
    sAwID         => ManagerAxiBus.WriteAddress.ID,
    sAwLen        => ManagerAxiBus.WriteAddress.Len,
    sAwSize       => ManagerAxiBus.WriteAddress.Size,
    sAwBurst      => ManagerAxiBus.WriteAddress.Burst,
    sAwLock       => ManagerAxiBus.WriteAddress.Lock,
    sAwCache      => ManagerAxiBus.WriteAddress.Cache,
    sAwQOS        => ManagerAxiBus.WriteAddress.QOS,
    sAwRegion     => ManagerAxiBus.WriteAddress.Region,
    sAwUser       => ManagerAxiBus.WriteAddress.User,

    -- AXI Write Data Channel
    sWData        => ManagerAxiBus.WriteData.Data,  
    sWStrb        => ManagerAxiBus.WriteData.Strb,  
    sWValid       => ManagerAxiBus.WriteData.Valid, 
    sWReady       => ManagerAxiBus.WriteData.Ready, 
    sWLast        => ManagerAxiBus.WriteData.Last,
    sWUser        => ManagerAxiBus.WriteData.User,
    sWID          => ManagerAxiBus.WriteData.ID,

    -- AXI Write Response Channel
    sBValid       => ManagerAxiBus.WriteResponse.Valid, 
    sBReady       => ManagerAxiBus.WriteResponse.Ready, 
    sBResp        => ManagerAxiBus.WriteResponse.Resp,  
    sBID          => ManagerAxiBus.WriteResponse.ID,
    sBUser        => ManagerAxiBus.WriteResponse.User,
  
  
    -- AXI Read Address Channel
    sArAddr       => ManagerAxiBus.ReadAddress.Addr,
    sArProt       => ManagerAxiBus.ReadAddress.Prot,
    sArValid      => ManagerAxiBus.ReadAddress.Valid,
    sArReady      => ManagerAxiBus.ReadAddress.Ready,
    sArID         => ManagerAxiBus.ReadAddress.ID,
    sArLen        => ManagerAxiBus.ReadAddress.Len,
    sArSize       => ManagerAxiBus.ReadAddress.Size,
    sArBurst      => ManagerAxiBus.ReadAddress.Burst,
    sArLock       => ManagerAxiBus.ReadAddress.Lock,
    sArCache      => ManagerAxiBus.ReadAddress.Cache,
    sArQOS        => ManagerAxiBus.ReadAddress.QOS,
    sArRegion     => ManagerAxiBus.ReadAddress.Region,
    sArUser       => ManagerAxiBus.ReadAddress.User,

    -- AXI Read Data Channel
    sRData        => ManagerAxiBus.ReadData.Data,  
    sRResp        => ManagerAxiBus.ReadData.Resp,
    sRValid       => ManagerAxiBus.ReadData.Valid, 
    sRReady       => ManagerAxiBus.ReadData.Ready, 
    sRLast        => ManagerAxiBus.ReadData.Last,
    sRUser        => ManagerAxiBus.ReadData.User,   
    sRID          => ManagerAxiBus.ReadData.ID
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
    AxiBus  => SubordinateAxiBus,
    
    -- Testbench Transaction Interface
    TransRec    => SubordinateRec
  ) ;

  ------------------------------------------------------------
  Manager_1 : Axi4Manager
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus      => ManagerAxiBus,

    -- Testbench Transaction Interface
    TransRec    => ManagerRec
  ) ;


  ------------------------------------------------------------
  Monitor_1 : Axi4Monitor
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus      => ManagerAxiBus
  ) ;


  ------------------------------------------------------------
  TestCtrl_1 : TestCtrl
  ------------------------------------------------------------
  port map (
    -- Global Signal Interface
    nReset          => nReset,

    -- Transaction Interfaces
    ManagerRec      => ManagerRec,
    SubordinateRec  => SubordinateRec
  ) ;

end architecture TestHarness ;
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
  constant AXI_ADDR_WIDTH : integer := 32 ;
  constant AXI_DATA_WIDTH : integer := 32 ;
  constant AXI_STRB_WIDTH : integer := AXI_DATA_WIDTH/8 ;


  constant tperiod_Clk : time := 10 ns ;
  constant tpd         : time := 2 ns ;

  signal Clk         : std_logic ;
  signal nReset      : std_logic ;

--  -- Testbench Transaction Interface
--  subtype LocalTransactionRecType is AddressBusRecType(
--    Address(AXI_ADDR_WIDTH-1 downto 0),
--    DataToModel(AXI_DATA_WIDTH-1 downto 0),
--    DataFromModel(AXI_DATA_WIDTH-1 downto 0)
--  ) ;
--  signal ManagerRec   : LocalTransactionRecType ;
--  signal SubordinateRec  : LocalTransactionRecType ;
  signal ManagerRec, SubordinateRec  : AddressBusRecType (
          Address(AXI_ADDR_WIDTH-1 downto 0),
          DataToModel(AXI_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI_DATA_WIDTH-1 downto 0)
        ) ;

--  -- AXI Manager Functional Interface
--  signal   AxiBus : Axi4RecType(
--    WriteAddress( AWAddr(AXI_ADDR_WIDTH-1 downto 0) ),
--    WriteData   ( WData (AXI_DATA_WIDTH-1 downto 0),   WStrb(AXI_STRB_WIDTH-1 downto 0) ),
--    ReadAddress ( ARAddr(AXI_ADDR_WIDTH-1 downto 0) ),
--    ReadData    ( RData (AXI_DATA_WIDTH-1 downto 0) )
--  ) ;

  signal   AxiBus1, AxiBus2 : Axi4RecType(
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
      nReset         : In    std_logic ;

      -- Transaction Interfaces
      ManagerRec      : inout AddressBusRecType ;
      SubordinateRec   : inout AddressBusRecType
    ) ;
  end component TestCtrl ;


begin

  ------------------------------------------------------------
  -- create Clock
  Osvvm.TbUtilPkg.CreateClock (
  ------------------------------------------------------------
    Clk        => Clk,
    Period     => Tperiod_Clk
  )  ;

  ------------------------------------------------------------
  -- create nReset
  Osvvm.TbUtilPkg.CreateReset (
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
    mAwAddr       => AxiBus2.WriteAddress.Addr,
    mAwProt       => AxiBus2.WriteAddress.Prot,
    mAwValid      => AxiBus2.WriteAddress.Valid,
    mAwReady      => AxiBus2.WriteAddress.Ready,
    mAwID         => AxiBus2.WriteAddress.ID,
    mAwLen        => AxiBus2.WriteAddress.Len,
    mAwSize       => AxiBus2.WriteAddress.Size,
    mAwBurst      => AxiBus2.WriteAddress.Burst,
    mAwLock       => AxiBus2.WriteAddress.Lock,
    mAwCache      => AxiBus2.WriteAddress.Cache,
    mAwQOS        => AxiBus2.WriteAddress.QOS,
    mAwRegion     => AxiBus2.WriteAddress.Region,
    mAwUser       => AxiBus2.WriteAddress.User,

    -- AXI Write Data Channel
    mWData        => AxiBus2.WriteData.Data, 
    mWStrb        => AxiBus2.WriteData.Strb, 
    mWValid       => AxiBus2.WriteData.Valid, 
    mWReady       => AxiBus2.WriteData.Ready, 
    mWLast        => AxiBus2.WriteData.Last,
    mWUser        => AxiBus2.WriteData.User,
    mWID          => AxiBus2.WriteData.ID,

    -- AXI Write Response Channel
    mBValid       => AxiBus2.WriteResponse.Valid, 
    mBReady       => AxiBus2.WriteResponse.Ready, 
    mBResp        => AxiBus2.WriteResponse.Resp, 
    mBID          => AxiBus2.WriteResponse.ID,
    mBUser        => AxiBus2.WriteResponse.User,
  
    -- AXI Read Address Channel
    mArAddr       => AxiBus2.ReadAddress.Addr,
    mArProt       => AxiBus2.ReadAddress.Prot,
    mArValid      => AxiBus2.ReadAddress.Valid,
    mArReady      => AxiBus2.ReadAddress.Ready,
    mArID         => AxiBus2.ReadAddress.ID,
    mArLen        => AxiBus2.ReadAddress.Len,
    mArSize       => AxiBus2.ReadAddress.Size,
    mArBurst      => AxiBus2.ReadAddress.Burst,
    mArLock       => AxiBus2.ReadAddress.Lock,
    mArCache      => AxiBus2.ReadAddress.Cache,
    mArQOS        => AxiBus2.ReadAddress.QOS,
    mArRegion     => AxiBus2.ReadAddress.Region,
    mArUser       => AxiBus2.ReadAddress.User,

    -- AXI Read Data Channel
    mRData        => AxiBus2.ReadData.Data, 
    mRResp        => AxiBus2.ReadData.Resp,
    mRValid       => AxiBus2.ReadData.Valid, 
    mRReady       => AxiBus2.ReadData.Ready, 
    mRLast        => AxiBus2.ReadData.Last,
    mRUser        => AxiBus2.ReadData.User,
    mRID          => AxiBus2.ReadData.ID,


  -- AXI Subordinate Interface - Driven by DUT
    -- AXI Write Address Channel
    sAwAddr       => AxiBus1.WriteAddress.Addr,
    sAwProt       => AxiBus1.WriteAddress.Prot,
    sAwValid      => AxiBus1.WriteAddress.Valid,
    sAwReady      => AxiBus1.WriteAddress.Ready,
    sAwID         => AxiBus1.WriteAddress.ID,
    sAwLen        => AxiBus1.WriteAddress.Len,
    sAwSize       => AxiBus1.WriteAddress.Size,
    sAwBurst      => AxiBus1.WriteAddress.Burst,
    sAwLock       => AxiBus1.WriteAddress.Lock,
    sAwCache      => AxiBus1.WriteAddress.Cache,
    sAwQOS        => AxiBus1.WriteAddress.QOS,
    sAwRegion     => AxiBus1.WriteAddress.Region,
    sAwUser       => AxiBus1.WriteAddress.User,

    -- AXI Write Data Channel
    sWData        => AxiBus1.WriteData.Data,  
    sWStrb        => AxiBus1.WriteData.Strb,  
    sWValid       => AxiBus1.WriteData.Valid, 
    sWReady       => AxiBus1.WriteData.Ready, 
    sWLast        => AxiBus1.WriteData.Last,
    sWUser        => AxiBus1.WriteData.User,
    sWID          => AxiBus1.WriteData.ID,

    -- AXI Write Response Channel
    sBValid       => AxiBus1.WriteResponse.Valid, 
    sBReady       => AxiBus1.WriteResponse.Ready, 
    sBResp        => AxiBus1.WriteResponse.Resp,  
    sBID          => AxiBus1.WriteResponse.ID,
    sBUser        => AxiBus1.WriteResponse.User,
  
  
    -- AXI Read Address Channel
    sArAddr       => AxiBus1.ReadAddress.Addr,
    sArProt       => AxiBus1.ReadAddress.Prot,
    sArValid      => AxiBus1.ReadAddress.Valid,
    sArReady      => AxiBus1.ReadAddress.Ready,
    sArID         => AxiBus1.ReadAddress.ID,
    sArLen        => AxiBus1.ReadAddress.Len,
    sArSize       => AxiBus1.ReadAddress.Size,
    sArBurst      => AxiBus1.ReadAddress.Burst,
    sArLock       => AxiBus1.ReadAddress.Lock,
    sArCache      => AxiBus1.ReadAddress.Cache,
    sArQOS        => AxiBus1.ReadAddress.QOS,
    sArRegion     => AxiBus1.ReadAddress.Region,
    sArUser       => AxiBus1.ReadAddress.User,

    -- AXI Read Data Channel
    sRData        => AxiBus1.ReadData.Data,  
    sRResp        => AxiBus1.ReadData.Resp,
    sRValid       => AxiBus1.ReadData.Valid, 
    sRReady       => AxiBus1.ReadData.Ready, 
    sRLast        => AxiBus1.ReadData.Last,
    sRUser        => AxiBus1.ReadData.User,   
    sRID          => AxiBus1.ReadData.ID
  ) ;
  
  ------------------------------------------------------------
  -- Behavioral model.  Replaces DUT for labs
  Subordinate_1 : Axi4Subordinate
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus  => AxiBus2,

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
    AxiBus      => AxiBus1,

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
    AxiBus      => AxiBus1
  ) ;


  ------------------------------------------------------------
  TestCtrl_1 : TestCtrl
  ------------------------------------------------------------
  port map (
    -- Global Signal Interface
    nReset        => nReset,

    -- Transaction Interfaces
    ManagerRec     => ManagerRec,
    SubordinateRec  => SubordinateRec
  ) ;

end architecture TestHarness ;
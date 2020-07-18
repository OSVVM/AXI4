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
--    04/2018   2018       Initial revision
--    01/2020   2020.01    Updated license notice
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
--  subtype LocalTransactionRecType is AddressBusTransactionRecType(
--    Address(AXI_ADDR_WIDTH-1 downto 0),
--    DataToModel(AXI_DATA_WIDTH-1 downto 0),
--    DataFromModel(AXI_DATA_WIDTH-1 downto 0)
--  ) ;
--  signal AxiSuperTransRec   : LocalTransactionRecType ;
--  signal AxiMinionTransRec  : LocalTransactionRecType ;
  signal AxiSuperTransRec, AxiMinionTransRec  : AddressBusTransactionRecType(
          Address(AXI_ADDR_WIDTH-1 downto 0),
          DataToModel(AXI_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI_DATA_WIDTH-1 downto 0)
        ) ;

--  -- AXI Master Functional Interface
--  signal   AxiBus : Axi4RecType(
--    WriteAddress( AWAddr(AXI_ADDR_WIDTH-1 downto 0) ),
--    WriteData   ( WData (AXI_DATA_WIDTH-1 downto 0),   WStrb(AXI_STRB_WIDTH-1 downto 0) ),
--    ReadAddress ( ARAddr(AXI_ADDR_WIDTH-1 downto 0) ),
--    ReadData    ( RData (AXI_DATA_WIDTH-1 downto 0) )
--  ) ;

  signal   AxiBus : Axi4RecType(
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
--   WriteAddress (  ),
--   WriteData    (  ),  -- WID only AXI3
--   WriteResponse( BID(7 downto 0), BUser(7 downto 0) ),
--   ReadAddress  ( ARAddr(open), ARID(7 downto 0), ARUser(7 downto 0) ),
--   ReadData     ( RData(open), RID(7 downto 0), RUser(7 downto 0) )


  -- Aliases to make access to record elements convenient
  -- This is only needed for model use them
  -- Write Address
  alias  AWAddr    : std_logic_vector is AxiBus.WriteAddress.Addr ;
  alias  AWProt    : Axi4ProtType     is AxiBus.WriteAddress.Prot ;
  alias  AWValid   : std_logic        is AxiBus.WriteAddress.Valid ;
  alias  AWReady   : std_logic        is AxiBus.WriteAddress.Ready ;
  -- Axi4 Full
  alias  AWID      : std_logic_vector is AxiBus.WriteAddress.ID ;
  alias  AWLen     : std_logic_vector is AxiBus.WriteAddress.Len ;
  alias  AWSize    : std_logic_vector is AxiBus.WriteAddress.Size ;
  alias  AWBurst   : std_logic_vector is AxiBus.WriteAddress.Burst ;
  alias  AWLock    : std_logic        is AxiBus.WriteAddress.Lock ;
  alias  AWCache   : std_logic_vector is AxiBus.WriteAddress.Cache ;
  alias  AWQOS     : std_logic_vector is AxiBus.WriteAddress.QOS ;
  alias  AWRegion  : std_logic_vector is AxiBus.WriteAddress.Region ;
  alias  AWUser    : std_logic_vector is AxiBus.WriteAddress.User ;

  -- Write Data
  alias  WData     : std_logic_vector is AxiBus.WriteData.Data ;
  alias  WStrb     : std_logic_vector is AxiBus.WriteData.Strb ;
  alias  WValid    : std_logic        is AxiBus.WriteData.Valid ;
  alias  WReady    : std_logic        is AxiBus.WriteData.Ready ;
  -- AXI4 Full
  alias  WLast     : std_logic        is AxiBus.WriteData.Last ;
  alias  WUser     : std_logic_vector is AxiBus.WriteData.User ;
  -- AXI3
  alias  WID       : std_logic_vector is AxiBus.WriteData.ID ;

  -- Write Response
  alias  BResp     : Axi4RespType     is AxiBus.WriteResponse.Resp ;
  alias  BValid    : std_logic        is AxiBus.WriteResponse.Valid ;
  alias  BReady    : std_logic        is AxiBus.WriteResponse.Ready ;
  -- AXI4 Full
  alias  BID       : std_logic_vector is AxiBus.WriteResponse.ID ;
  alias  BUser     : std_logic_vector is AxiBus.WriteResponse.User ;

  -- Read Address
  alias  ARAddr    : std_logic_vector is AxiBus.ReadAddress.Addr ;
  alias  ARProt    : Axi4ProtType     is AxiBus.ReadAddress.Prot ;
  alias  ARValid   : std_logic        is AxiBus.ReadAddress.Valid ;
  alias  ARReady   : std_logic        is AxiBus.ReadAddress.Ready ;
  -- Axi4 Full
  alias  ARID      : std_logic_vector is AxiBus.ReadAddress.ID ;
  -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
  alias  ARLen     : std_logic_vector is AxiBus.ReadAddress.Len ;
  -- #Bytes in transfer = 2**AxSize
  alias  ARSize    : std_logic_vector is AxiBus.ReadAddress.Size ;
  -- AxBurst = (Fixed, Incr, Wrap, NotDefined)
  alias  ARBurst   : std_logic_vector is AxiBus.ReadAddress.Burst ;
  alias  ARLock    : std_logic        is AxiBus.ReadAddress.Lock ;
  -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
  alias  ARCache   : std_logic_vector is AxiBus.ReadAddress.Cache  ;
  alias  ARQOS     : std_logic_vector is AxiBus.ReadAddress.QOS    ;
  alias  ARRegion  : std_logic_vector is AxiBus.ReadAddress.Region ;
  alias  ARUser    : std_logic_vector is AxiBus.ReadAddress.User   ;

  -- Read Data
  alias  RData     : std_logic_vector is AxiBus.ReadData.Data ;
  alias  RResp     : Axi4RespType     is AxiBus.ReadData.Resp ;
  alias  RValid    : std_logic        is AxiBus.ReadData.Valid ;
  alias  RReady    : std_logic        is AxiBus.ReadData.Ready ;
  -- AXI4 Full
  alias  RID       : std_logic_vector is AxiBus.ReadData.ID   ;
  alias  RLast     : std_logic        is AxiBus.ReadData.Last ;
  alias  RUser     : std_logic_vector is AxiBus.ReadData.User ;

  component TestCtrl is
    port (
      -- Global Signal Interface
      Clk                 : In    std_logic ;
      nReset              : In    std_logic ;

      -- Transaction Interfaces
      AxiSuperTransRec    : inout AddressBusTransactionRecType ;
      AxiMinionTransRec   : inout AddressBusTransactionRecType

    ) ;
  end component TestCtrl ;


begin

  -- create Clock
  Osvvm.TbUtilPkg.CreateClock (
    Clk        => Clk,
    Period     => Tperiod_Clk
  )  ;

  -- create nReset
  Osvvm.TbUtilPkg.CreateReset (
    Reset       => nReset,
    ResetActive => '0',
    Clk         => Clk,
    Period      => 7 * tperiod_Clk,
    tpd         => tpd
  ) ;

  -- Behavioral model.  Replaces DUT for labs
  Axi4Minion_1 : Axi4Responder
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Testbench Transaction Interface
    TransRec    => AxiMinionTransRec,

    -- AXI Master Functional Interface
--    AxiBus  => AxiBus
    -- Mapping aliases on Left Hand Side (most similar to basic design)
    AxiBus.WriteAddress.Addr       => AWAddr  ,
    AxiBus.WriteAddress.Prot       => AWProt  ,
    AxiBus.WriteAddress.Valid      => AWValid ,
    AxiBus.WriteAddress.Ready      => AWReady ,
    AxiBus.WriteAddress.ID         => AWID    ,
    AxiBus.WriteAddress.Len        => AWLen   ,
    AxiBus.WriteAddress.Size       => AWSize  ,
    AxiBus.WriteAddress.Burst      => AWBurst ,
    AxiBus.WriteAddress.Lock       => AWLock  ,
    AxiBus.WriteAddress.Cache      => AWCache ,
    AxiBus.WriteAddress.QOS        => AWQOS   ,
    AxiBus.WriteAddress.Region     => AWRegion,
    AxiBus.WriteAddress.User       => AWUser  ,

    -- Mapping record elements on Left Hand Side (easiest way to connect Master to Responder DUT)
    AxiBus.WriteData.Data          => AxiBus.WriteData.Data   ,
    AxiBus.WriteData.Strb          => AxiBus.WriteData.Strb   ,
    AxiBus.WriteData.Valid         => AxiBus.WriteData.Valid  ,
    AxiBus.WriteData.Ready         => AxiBus.WriteData.Ready  ,
    AxiBus.WriteData.Last          => AxiBus.WriteData.Last  ,
    AxiBus.WriteData.User          => AxiBus.WriteData.User  ,
    AxiBus.WriteData.ID            => AxiBus.WriteData.ID  ,

    -- Mapping bus subrecords on left hand side (because it is easy)
    AxiBus.WriteResponse           => AxiBus.WriteResponse ,
    AxiBus.ReadAddress             => AxiBus.ReadAddress ,
    AxiBus.ReadData                => AxiBus.ReadData
  ) ;

  Axi4Super_1 : Axi4Master
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Testbench Transaction Interface
    TransRec    => AxiSuperTransRec,

    -- AXI Master Functional Interface
    AxiBus      => AxiBus
  ) ;


  Axi4Monitor_1 : Axi4Monitor
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Master Functional Interface
    AxiBus     => AxiBus
  ) ;


  TestCtrl_1 : TestCtrl
  port map (
    -- Globals
    Clk                => Clk,
    nReset             => nReset,

    -- Testbench Transaction Interfaces
    AxiSuperTransRec   => AxiSuperTransRec,
    AxiMinionTransRec  => AxiMinionTransRec
  ) ;

end architecture TestHarness ;
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

library osvvm_Axi4 ;
  context osvvm_Axi4.Axi4LiteContext ;

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
--  signal MasterRec   : LocalTransactionRecType ;
--  signal ResponderRec  : LocalTransactionRecType ;
  signal MasterRec, ResponderRec  : AddressBusRecType(
          Address(AXI_ADDR_WIDTH-1 downto 0),
          DataToModel(AXI_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI_DATA_WIDTH-1 downto 0)
        ) ;

--  -- AXI Master Functional Interface
  signal   AxiBus : Axi4LiteRecType(
    WriteAddress( Addr(AXI_ADDR_WIDTH-1 downto 0) ),
    WriteData   ( Data (AXI_DATA_WIDTH-1 downto 0),   Strb(AXI_STRB_WIDTH-1 downto 0) ),
    ReadAddress ( Addr(AXI_ADDR_WIDTH-1 downto 0) ),
    ReadData    ( Data (AXI_DATA_WIDTH-1 downto 0) )
  ) ;

  -- Aliases to make access to record elements convenient
  -- This is only needed for model use them
  -- Write Address
  alias  AWAddr    : std_logic_vector is AxiBus.WriteAddress.Addr ;
  alias  AWProt    : Axi4ProtType     is AxiBus.WriteAddress.Prot ;
  alias  AWValid   : std_logic        is AxiBus.WriteAddress.Valid ;
  alias  AWReady   : std_logic        is AxiBus.WriteAddress.Ready ;

  -- Write Data
  alias  WData     : std_logic_vector is AxiBus.WriteData.Data ;
  alias  WStrb     : std_logic_vector is AxiBus.WriteData.Strb ;
  alias  WValid    : std_logic        is AxiBus.WriteData.Valid ;
  alias  WReady    : std_logic        is AxiBus.WriteData.Ready ;

  -- Write Response
  alias  BResp     : Axi4RespType     is AxiBus.WriteResponse.Resp ;
  alias  BValid    : std_logic        is AxiBus.WriteResponse.Valid ;
  alias  BReady    : std_logic        is AxiBus.WriteResponse.Ready ;

  -- Read Address
  alias  ARAddr    : std_logic_vector is AxiBus.ReadAddress.Addr ;
  alias  ARProt    : Axi4ProtType     is AxiBus.ReadAddress.Prot ;
  alias  ARValid   : std_logic        is AxiBus.ReadAddress.Valid ;
  alias  ARReady   : std_logic        is AxiBus.ReadAddress.Ready ;

  -- Read Data
  alias  RData     : std_logic_vector is AxiBus.ReadData.Data ;
  alias  RResp     : Axi4RespType     is AxiBus.ReadData.Resp ;
  alias  RValid    : std_logic        is AxiBus.ReadData.Valid ;
  alias  RReady    : std_logic        is AxiBus.ReadData.Ready ;

  component TestCtrl is
    port (
      -- Global Signal Interface
      Clk                 : In    std_logic ;
      nReset              : In    std_logic ;

      -- Transaction Interfaces
      MasterRec           : inout AddressBusRecType ;
      ResponderRec        : inout AddressBusRecType
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
  Responder_1 : Axi4LiteResponder
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Master Functional Interface
    AxiBus  => AxiBus,
    -- Mapping aliases on Left Hand Side (most similar to basic design)
--      AxiBus.WriteAddress.Addr       => AWAddr  ,
--      AxiBus.WriteAddress.Prot       => AWProt  ,
--      AxiBus.WriteAddress.Valid      => AWValid ,
--      AxiBus.WriteAddress.Ready      => AWReady ,
--  
--      -- Mapping record elements on Left Hand Side (easiest way to connect Master to Responder DUT)
--      AxiBus.WriteData.Data          => AxiBus.WriteData.Data   ,
--      AxiBus.WriteData.Strb          => AxiBus.WriteData.Strb   ,
--      AxiBus.WriteData.Valid         => AxiBus.WriteData.Valid  ,
--      AxiBus.WriteData.Ready         => AxiBus.WriteData.Ready  ,
--  
--      -- Mapping bus subrecords on left hand side (because it is easy)
--      AxiBus.WriteResponse           => AxiBus.WriteResponse ,
--      AxiBus.ReadAddress             => AxiBus.ReadAddress ,
--      AxiBus.ReadData                => AxiBus.ReadData ,

    -- Testbench Transaction Interface
    TransRec    => ResponderRec
  ) ;

  Master_1 : Axi4LiteMaster
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Testbench Transaction Interface
    TransRec    => MasterRec,

    -- AXI Master Functional Interface
    AxiBus      => AxiBus
  ) ;


  Monitor_1 : Axi4LiteMonitor
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Master Functional Interface
    AxiBus      => AxiBus
  ) ;


  TestCtrl_1 : TestCtrl
  port map (
    -- Globals
    Clk           => Clk,
    nReset        => nReset,

    -- Testbench Transaction Interfaces
    MasterRec     => MasterRec,
    ResponderRec  => ResponderRec
  ) ;

end architecture TestHarness ;
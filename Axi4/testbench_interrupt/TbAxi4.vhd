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
--      Simple AXI + Interrupt Handler
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    04/2021   2021.04    Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2021 by SynthWorks Design Inc.
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
  signal ManagerRec, InterruptRec, VCRec, SubordinateRec  : AddressBusRecType (
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

  component TestCtrl is
    port (
      -- Global Signal Interface
      nReset         : In    std_logic ;

      -- Transaction Interfaces
      ManagerRec      : inout AddressBusRecType ;
      InterruptRec   : inout AddressBusRecType ;
      SubordinateRec   : inout AddressBusRecType
    ) ;
  end component TestCtrl ;

  signal IntReq : std_logic ; 
  
begin

  -- create Clock
  ------------------------------------------------------------
  Osvvm.TbUtilPkg.CreateClock (
  ------------------------------------------------------------
    Clk        => Clk,
    Period     => Tperiod_Clk
  )  ;

  -- create nReset
  ------------------------------------------------------------
  Osvvm.TbUtilPkg.CreateReset (
  ------------------------------------------------------------
    Reset       => nReset,
    ResetActive => '0',
    Clk         => Clk,
    Period      => 7 * tperiod_Clk,
    tpd         => tpd
  ) ;

  -- Behavioral model.  Replaces DUT for testing Axi4Manager
  ------------------------------------------------------------
  Subordinate_1 : Axi4Subordinate
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus      => AxiBus,

    -- Testbench Transaction Interface
    TransRec    => SubordinateRec
  ) ;
  
  ------------------------------------------------------------
  InterruptHandler_1 : InterruptHandler 
  ------------------------------------------------------------
  port map (
    -- Interrupt Input
    IntReq       => IntReq,

    -- From TestCtrl
    TransRec     => ManagerRec,
    InterruptRec => InterruptRec,
    
    -- To Verification Component
    VCRec        => VCRec
  ) ;


  ------------------------------------------------------------
  Manager_1 : Axi4Manager
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus      => AxiBus,

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
    AxiBus      => AxiBus
  ) ;


  ------------------------------------------------------------
  TestCtrl_1 : TestCtrl
  ------------------------------------------------------------
  port map (
    -- Global Signal Interface
    nReset        => nReset,

    -- Transaction Interfaces
    ManagerRec     => ManagerRec,
    InterruptRec  => InterruptRec,
    SubordinateRec  => SubordinateRec
  ) ;

end architecture TestHarness ;
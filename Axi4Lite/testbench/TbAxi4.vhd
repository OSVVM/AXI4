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

  signal ManagerRec, SubordinateRec  : AddressBusRecType(
          Address(AXI_ADDR_WIDTH-1 downto 0),
          DataToModel(AXI_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI_DATA_WIDTH-1 downto 0)
        ) ;

--  -- AXI Master Functional Interface
  signal   AxiBus : Axi4LiteRecType(
    WriteAddress( Addr (AXI_ADDR_WIDTH-1 downto 0) ),
    WriteData   ( Data (AXI_DATA_WIDTH-1 downto 0),   Strb(AXI_STRB_WIDTH-1 downto 0) ),
    ReadAddress ( Addr (AXI_ADDR_WIDTH-1 downto 0) ),
    ReadData    ( Data (AXI_DATA_WIDTH-1 downto 0) )
  ) ;


  component TestCtrl is
    port (
      -- Global Signal Interface
      Clk                 : In    std_logic ;
      nReset              : In    std_logic ;

      -- Transaction Interfaces
      ManagerRec          : inout AddressBusRecType ;
      SubordinateRec      : inout AddressBusRecType
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
  Subordinate_1 : Axi4LiteSubordinate
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Master Functional Interface
    AxiBus  => AxiBus,

    -- Testbench Transaction Interface
    TransRec    => SubordinateRec
  ) ;

  Manager_1 : Axi4LiteManager
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Master Functional Interface
    AxiBus      => AxiBus,

    -- Testbench Transaction Interface
    TransRec    => ManagerRec
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
    Clk            => Clk,
    nReset         => nReset,

    -- Testbench Transaction Interfaces
    ManagerRec     => ManagerRec,
    SubordinateRec => SubordinateRec
  ) ;

end architecture TestHarness ;
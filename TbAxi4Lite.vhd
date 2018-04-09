--
--  File Name:         TbAxi4Lite.vhd
--  Design Unit Name:  TbAxi4Lite
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
--    Date       Version    Description
--    09/2017:   2017       Initial revision
--
--
-- Copyright 2017 SynthWorks Design Inc
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
    context osvvm.OsvvmContext ;
    
  use work.Axi4TransactionPkg.all ; 
  use work.Axi4LiteInterfacePkg.all ; 

entity TbAxi4Lite is
end entity TbAxi4Lite ; 
architecture TestHarness of TbAxi4Lite is
  constant AXI_ADDR_WIDTH : integer := 32 ; 
  constant AXI_DATA_WIDTH : integer := 32 ; 
  constant AXI_STRB_WIDTH : integer := AXI_DATA_WIDTH/8 ; 


  constant tperiod_Clk : time := 10 ns ; 
  constant tpd         : time := 2 ns ; 

  signal Clk         : std_logic ;
  signal nReset      : std_logic ;

  -- Testbench Transaction Interface
  subtype TransactionRecType is Axi4TransactionRecType(
    Address(SizeOf_TransactionType(AXI_ADDR_WIDTH)-1 downto 0), 
    DataToModel(SizeOf_TransactionType(AXI_DATA_WIDTH)-1 downto 0),
    DataFromModel(SizeOf_TransactionType(AXI_DATA_WIDTH)-1 downto 0)
  ) ;  
  signal AxiMasterTransRec   : TransactionRecType ;
  signal AxiSlaveTransRec    : TransactionRecType ;
  

  -- AXI Master Functional Interface
  signal   AxiLiteBus : Axi4LiteRecType( 
    WriteAddress( AWAddr(AXI_ADDR_WIDTH-1 downto 0) ),
    WriteData( WData(AXI_DATA_WIDTH-1 downto 0), WStrb(AXI_STRB_WIDTH-1 downto 0) ),
    ReadAddress( ARAddr(AXI_ADDR_WIDTH-1 downto 0) ),
    ReadData( RData(AXI_DATA_WIDTH-1 downto 0) )
  ) ;

  component Axi4LiteMaster is
  port (
    -- Globals
    Clk         : in   std_logic ;
    nReset      : in   std_logic ;

    -- Testbench Transaction Interface
    TransRec    : inout Axi4TransactionRecType ;

    -- AXI Master Functional Interface
    AxiLiteBus  : inout Axi4LiteRecType 
  ) ;
  end component Axi4LiteMaster ;

  component Axi4LiteSlave is
  port (
    -- Globals
    Clk         : in   std_logic ;
    nReset      : in   std_logic ;

    -- Testbench Transaction Interface
    TransRec    : inout Axi4TransactionRecType ;

    -- AXI Master Functional Interface
    AxiLiteBus  : inout Axi4LiteRecType 
  ) ;
  end component Axi4LiteSlave ;

  component Axi4LiteMonitor is
  port (
    -- Globals
    Clk         : in   std_logic ;
    nReset      : in   std_logic ;

    -- AXI Master Functional Interface
    AxiLiteBus  : in    Axi4LiteRecType 
  ) ;
  end component Axi4LiteMonitor ;

  component TestCtrl is
    port (
      -- Global Signal Interface
      Clk                 : In    std_logic ;
      nReset              : In    std_logic ;

      -- Transaction Interfaces
      AxiMasterTransRec   : inout Axi4TransactionRecType ;
      AxiSlaveTransRec    : inout Axi4TransactionRecType 

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

  Axi4LiteMaster_1 : Axi4LiteMaster 
  port map ( 
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Testbench Transaction Interface
    TransRec    => AxiMasterTransRec,

    -- AXI Master Functional Interface
    AxiLiteBus  => AxiLiteBus 
  ) ;

  
  Axi4LiteSlave_1 : Axi4LiteSlave 
  port map ( 
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Testbench Transaction Interface
    TransRec    => AxiSlaveTransRec,

    -- AXI Master Functional Interface
    AxiLiteBus  => AxiLiteBus 
  ) ;

  Axi4LiteMonitor_1 : Axi4LiteMonitor 
  port map ( 
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Master Functional Interface
    AxiLiteBus  => AxiLiteBus 
  ) ;
  
  
  TestCtrl_1 : TestCtrl
  port map ( 
    -- Globals
    Clk                => Clk,
    nReset             => nReset,
    
    -- Testbench Transaction Interfaces
    AxiMasterTransRec  => AxiMasterTransRec, 
    AxiSlaveTransRec   => AxiSlaveTransRec  
  ) ; 

end architecture TestHarness ;
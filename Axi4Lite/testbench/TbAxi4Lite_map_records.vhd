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
--    04/2018:   2018       Initial revision
--
--
-- Copyright 2018 SynthWorks Design Inc
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
    
library OSVVM_AXI4 ;
  context OSVVM_AXI4.Axi4LiteContext ; 

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
  subtype MasterTransactionRecType is Axi4LiteMasterTransactionRecType(
    Address(AXI_ADDR_WIDTH-1 downto 0), 
    DataToModel(AXI_DATA_WIDTH-1 downto 0),
    DataFromModel(AXI_DATA_WIDTH-1 downto 0)
  ) ;  
  signal AxiMasterTransRec   : MasterTransactionRecType ;
  
  subtype SlaveTransactionRecType is Axi4LiteSlaveTransactionRecType(
    Address(AXI_ADDR_WIDTH-1 downto 0), 
    DataToModel(AXI_DATA_WIDTH-1 downto 0),
    DataFromModel(AXI_DATA_WIDTH-1 downto 0)
  ) ;  
  signal AxiSlaveTransRec    : SlaveTransactionRecType ;
  

  -- AXI Master Functional Interface
  signal   AxiLiteBus : Axi4LiteRecType( 
    WriteAddress( AWAddr(AXI_ADDR_WIDTH-1 downto 0) ),
    WriteData( WData(AXI_DATA_WIDTH-1 downto 0), WStrb(AXI_STRB_WIDTH-1 downto 0) ),
    ReadAddress( ARAddr(AXI_ADDR_WIDTH-1 downto 0) ),
    ReadData( RData(AXI_DATA_WIDTH-1 downto 0) )
  ) ;

  -- Aliases to make access to record elements convenient 
  -- This is only needed for model use them
  alias AWValid : std_logic        is AxiLiteBus.WriteAddress.AWValid ;
  alias AWReady : std_logic        is AxiLiteBus.WriteAddress.AWReady ;
  alias AWProt  : Axi4ProtType     is AxiLiteBus.WriteAddress.AWProt ;
  alias AWAddr  : std_logic_vector is AxiLiteBus.WriteAddress.AWAddr ;

  alias WValid  : std_logic        is AxiLiteBus.WriteData.WValid ;
  alias WReady  : std_logic        is AxiLiteBus.WriteData.WReady ;
  alias WData   : std_logic_vector is AxiLiteBus.WriteData.WData ;
  alias WStrb   : std_logic_vector is AxiLiteBus.WriteData.WStrb ;

  alias BValid  : std_logic        is AxiLiteBus.WriteResponse.BValid ;
  alias BReady  : std_logic        is AxiLiteBus.WriteResponse.BReady ;
  alias BResp   : Axi4RespType     is AxiLiteBus.WriteResponse.BResp ;

  alias ARValid : std_logic        is AxiLiteBus.ReadAddress.ARValid ;
  alias ARReady : std_logic        is AxiLiteBus.ReadAddress.ARReady ;
  alias ARProt  : Axi4ProtType     is AxiLiteBus.ReadAddress.ARProt ;
  alias ARAddr  : std_logic_vector is AxiLiteBus.ReadAddress.ARAddr ;

  alias RValid  : std_logic        is AxiLiteBus.ReadData.RValid ;
  alias RReady  : std_logic        is AxiLiteBus.ReadData.RReady ;
  alias RData   : std_logic_vector is AxiLiteBus.ReadData.RData ;
  alias RResp   : Axi4RespType     is AxiLiteBus.ReadData.RResp ;

  component TestCtrl is
    generic (
      constant AXI_ADDR_WIDTH : integer ; 
      constant AXI_DATA_WIDTH : integer  
    ) ;
    port (
      -- Global Signal Interface
      Clk                 : In    std_logic ;
      nReset              : In    std_logic ;

      -- Transaction Interfaces
      AxiMasterTransRec   : inout Axi4LiteMasterTransactionRecType ;
      AxiSlaveTransRec    : inout Axi4LiteSlaveTransactionRecType 

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
  Axi4LiteSlave_1 : Axi4LiteSlave 
  port map ( 
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Testbench Transaction Interface
    TransRec    => AxiSlaveTransRec,

    -- AXI Master Functional Interface
--    AxiLiteBus  => AxiLiteBus 
      AxiLiteBus.WriteAddress.AWValid      => AWValid ;
      AxiLiteBus.WriteAddress.AWReady      => AWReady ;
      AxiLiteBus.WriteAddress.AWProt       => AWProt  ;
      AxiLiteBus.WriteAddress.AWAddr       => AWAddr  ;

      AxiLiteBus.WriteData.WValid          => WValid  ;
      AxiLiteBus.WriteData.WReady          => WReady  ;
      AxiLiteBus.WriteData.WData           => WData   ;
      AxiLiteBus.WriteData.WStrb           => WStrb   ;

      AxiLiteBus.WriteResponse.BValid      => BValid  ;
      AxiLiteBus.WriteResponse.BReady      => BReady  ;
      AxiLiteBus.WriteResponse.BResp       => BResp   ;

      AxiLiteBus.ReadAddress.ARValid       => ARValid ;
      AxiLiteBus.ReadAddress.ARReady       => ARReady ;
      AxiLiteBus.ReadAddress.ARProt        => ARProt  ;
      AxiLiteBus.ReadAddress.ARAddr        => ARAddr  ;

      AxiLiteBus.ReadData.RValid           => RValid  ;
      AxiLiteBus.ReadData.RReady           => RReady  ;
      AxiLiteBus.ReadData.RData            => RData   ;
      AxiLiteBus.ReadData.RResp            => RResp   
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

  
  Axi4LiteMonitor_1 : Axi4LiteMonitor 
  port map ( 
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Master Functional Interface
    AxiLiteBus  => AxiLiteBus 
  ) ;
  
  
  TestCtrl_1 : TestCtrl
  generic map (
    AXI_ADDR_WIDTH => AXI_ADDR_WIDTH, 
    AXI_DATA_WIDTH => AXI_DATA_WIDTH
  ) 
  port map ( 
    -- Globals
    Clk                => Clk,
    nReset             => nReset,
    
    -- Testbench Transaction Interfaces
    AxiMasterTransRec  => AxiMasterTransRec, 
    AxiSlaveTransRec   => AxiSlaveTransRec  
  ) ; 

end architecture TestHarness ;
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
  subtype LocalMasterTransactionRecType is AddressBusMasterTransactionRecType(
    Address(AXI_ADDR_WIDTH-1 downto 0), 
    DataToModel(AXI_DATA_WIDTH-1 downto 0),
    DataFromModel(AXI_DATA_WIDTH-1 downto 0)
  ) ;  
  signal AxiMasterTransRec   : LocalMasterTransactionRecType ;
  
  subtype LocalSlaveTransactionRecType is AddressBusSlaveTransactionRecType(
    Address(AXI_ADDR_WIDTH-1 downto 0), 
    DataToModel(AXI_DATA_WIDTH-1 downto 0),
    DataFromModel(AXI_DATA_WIDTH-1 downto 0)
  ) ;  
  signal AxiSlaveTransRec    : LocalSlaveTransactionRecType ;
  

  -- AXI Master Functional Interface
  signal   AxiLiteBus : Axi4LiteRecType( 
    WriteAddress( AWAddr(AXI_ADDR_WIDTH-1 downto 0) ),
    WriteData( WData(AXI_DATA_WIDTH-1 downto 0), WStrb(AXI_STRB_WIDTH-1 downto 0) ),
    ReadAddress( ARAddr(AXI_ADDR_WIDTH-1 downto 0) ),
    ReadData( RData(AXI_DATA_WIDTH-1 downto 0) )
  ) ;

  -- Aliases to make access to record elements convenient 
  -- This is only needed for model use them
  -- Write Address
  alias  AWAddr    : std_logic_vector is AxiLiteBus.WriteAddress.AWAddr ;
  alias  AWProt    : Axi4ProtType     is AxiLiteBus.WriteAddress.AWProt ;
  alias  AWValid   : std_logic        is AxiLiteBus.WriteAddress.AWValid ;
  alias  AWReady   : std_logic        is AxiLiteBus.WriteAddress.AWReady ;
  -- Axi4 Full
  alias  AWID      : std_logic_vector is AxiLiteBus.WriteAddress.AWID ;
  alias  AWLen     : std_logic_vector is AxiLiteBus.WriteAddress.AWLen ; 
  alias  AWSize    : std_logic_vector is AxiLiteBus.WriteAddress.AWSize ;
  alias  AWBurst   : std_logic_vector is AxiLiteBus.WriteAddress.AWBurst ;
  alias  AWLock    : std_logic        is AxiLiteBus.WriteAddress.AWLock ;
  alias  AWCache   : std_logic_vector is AxiLiteBus.WriteAddress.AWCache ;
  alias  AWQOS     : std_logic_vector is AxiLiteBus.WriteAddress.AWQOS ;
  alias  AWRegion  : std_logic_vector is AxiLiteBus.WriteAddress.AWRegion ;
  alias  AWUser    : std_logic_vector is AxiLiteBus.WriteAddress.AWUser ;

  -- Write Data
  alias  WData     : std_logic_vector is AxiLiteBus.WriteData.WData ;
  alias  WStrb     : std_logic_vector is AxiLiteBus.WriteData.WStrb ;
  alias  WValid    : std_logic        is AxiLiteBus.WriteData.WValid ;
  alias  WReady    : std_logic        is AxiLiteBus.WriteData.WReady ;
  -- AXI4 Full
  alias  WLast     : std_logic        is AxiLiteBus.WriteData.WLast ;
  alias  WUser     : std_logic_vector is AxiLiteBus.WriteData.WUser ;
  -- AXI3
  alias  WID       : std_logic_vector is AxiLiteBus.WriteData.WID ;

  -- Write Response
  alias  BResp     : Axi4RespType     is AxiLiteBus.WriteResponse.BResp ;
  alias  BValid    : std_logic        is AxiLiteBus.WriteResponse.BValid ;
  alias  BReady    : std_logic        is AxiLiteBus.WriteResponse.BReady ;
  -- AXI4 Full
  alias  BID       : std_logic_vector is AxiLiteBus.WriteResponse.BID ;
  alias  BUser     : std_logic_vector is AxiLiteBus.WriteResponse.BUser ;

  -- Read Address
  alias  ARAddr    : std_logic_vector is AxiLiteBus.ReadAddress.ARAddr ;
  alias  ARProt    : Axi4ProtType     is AxiLiteBus.ReadAddress.ARProt ;
  alias  ARValid   : std_logic        is AxiLiteBus.ReadAddress.ARValid ;
  alias  ARReady   : std_logic        is AxiLiteBus.ReadAddress.ARReady ;
  -- Axi4 Full
  alias  ARID      : std_logic_vector is AxiLiteBus.ReadAddress.ARID ;
  -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
  alias  ARLen     : std_logic_vector is AxiLiteBus.ReadAddress.ARLen ;
  -- #Bytes in transfer = 2**AxSize
  alias  ARSize    : std_logic_vector is AxiLiteBus.ReadAddress.ARSize ;
  -- AxBurst = (Fixed, Incr, Wrap, NotDefined)
  alias  ARBurst   : std_logic_vector is AxiLiteBus.ReadAddress.ARBurst ;
  alias  ARLock    : std_logic is AxiLiteBus.ReadAddress.ARLock ;
  -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
  alias  ARCache   : std_logic_vector is AxiLiteBus.ReadAddress.ARCache  ;
  alias  ARQOS     : std_logic_vector is AxiLiteBus.ReadAddress.ARQOS    ;
  alias  ARRegion  : std_logic_vector is AxiLiteBus.ReadAddress.ARRegion ;
  alias  ARUser    : std_logic_vector is AxiLiteBus.ReadAddress.ARUser   ;

  -- Read Data
  alias  RData     : std_logic_vector is AxiLiteBus.ReadData.RData ;
  alias  RResp     : Axi4RespType     is AxiLiteBus.ReadData.RResp ;
  alias  RValid    : std_logic        is AxiLiteBus.ReadData.RValid ;
  alias  RReady    : std_logic        is AxiLiteBus.ReadData.RReady ;
  -- AXI4 Full
  alias  RID       : std_logic_vector is AxiLiteBus.ReadData.RID   ;
  alias  RLast     : std_logic        is AxiLiteBus.ReadData.RLast ;
  alias  RUser     : std_logic_vector is AxiLiteBus.ReadData.RUser ;

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
      AxiMasterTransRec   : inout AddressBusMasterTransactionRecType ;
      AxiSlaveTransRec    : inout AddressBusSlaveTransactionRecType 

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
    -- Mapping aliases on Left Hand Side (most similar to basic design)
    AxiLiteBus.WriteAddress.AWAddr       => AWAddr  ,
    AxiLiteBus.WriteAddress.AWProt       => AWProt  ,
    AxiLiteBus.WriteAddress.AWValid      => AWValid ,
    AxiLiteBus.WriteAddress.AWReady      => AWReady ,
    AxiLiteBus.WriteAddress.AWID         => AWID    ,
    AxiLiteBus.WriteAddress.AWLen        => AWLen   ,
    AxiLiteBus.WriteAddress.AWSize       => AWSize  ,
    AxiLiteBus.WriteAddress.AWBurst      => AWBurst ,
    AxiLiteBus.WriteAddress.AWLock       => AWLock  ,
    AxiLiteBus.WriteAddress.AWCache      => AWCache ,
    AxiLiteBus.WriteAddress.AWQOS        => AWQOS   ,
    AxiLiteBus.WriteAddress.AWRegion     => AWRegion,
    AxiLiteBus.WriteAddress.AWUser       => AWUser  ,

    -- Mapping record elements on Left Hand Side (easiest way to connect Master to Slave DUT)
    AxiLiteBus.WriteData.WData           => AxiLiteBus.WriteData.WData   ,
    AxiLiteBus.WriteData.WStrb           => AxiLiteBus.WriteData.WStrb   ,
    AxiLiteBus.WriteData.WValid          => AxiLiteBus.WriteData.WValid  ,
    AxiLiteBus.WriteData.WReady          => AxiLiteBus.WriteData.WReady  ,
    AxiLiteBus.WriteData.WLast           => AxiLiteBus.WriteData.WLast  ,
    AxiLiteBus.WriteData.WUser           => AxiLiteBus.WriteData.WUser  ,
    AxiLiteBus.WriteData.WID             => AxiLiteBus.WriteData.WID  ,

    -- Mapping bus subrecords on left hand side (because it is easy)
    AxiLiteBus.WriteResponse             => AxiLiteBus.WriteResponse ,
    AxiLiteBus.ReadAddress               => AxiLiteBus.ReadAddress ,
    AxiLiteBus.ReadData                  => AxiLiteBus.ReadData 
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
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

  -- Testbench Transaction Interface
  subtype LocalTransactionRecType is AddressBusTransactionRecType(
    Address(AXI_ADDR_WIDTH-1 downto 0), 
    DataToModel(AXI_DATA_WIDTH-1 downto 0),
    DataFromModel(AXI_DATA_WIDTH-1 downto 0)
  ) ;  
  signal AxiSuperTransRec   : LocalTransactionRecType ;
  signal AxiMinionTransRec  : LocalTransactionRecType ;


--  -- AXI Master Functional Interface
--  signal   AxiBus : Axi4RecType( 
--    WriteAddress( AWAddr(AXI_ADDR_WIDTH-1 downto 0) ),
--    WriteData   ( WData (AXI_DATA_WIDTH-1 downto 0),   WStrb(AXI_STRB_WIDTH-1 downto 0) ),
--    ReadAddress ( ARAddr(AXI_ADDR_WIDTH-1 downto 0) ),
--    ReadData    ( RData (AXI_DATA_WIDTH-1 downto 0) )
--  ) ;

  signal   AxiBus : Axi4RecType( 
    WriteAddress( 
      AWAddr(AXI_ADDR_WIDTH-1 downto 0),
      AWID(7 downto 0), 
      AWUser(7 downto 0)
    ),
    WriteData   ( 
      WData(AXI_DATA_WIDTH-1 downto 0), 
      WStrb(AXI_STRB_WIDTH-1 downto 0),
      WUser(7 downto 0), 
      WID(7 downto 0)    
    ),
    WriteResponse( 
      BID(7 downto 0), 
      BUser(7 downto 0) 
    ),
    ReadAddress ( 
      ARAddr(AXI_ADDR_WIDTH-1 downto 0),
      ARID(7 downto 0), 
      ARUser(7 downto 0)
    ),
    ReadData    ( 
      RData(AXI_DATA_WIDTH-1 downto 0),
      RID(7 downto 0), 
      RUser(7 downto 0)
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
  alias  AWAddr    : std_logic_vector is AxiBus.WriteAddress.AWAddr ;
  alias  AWProt    : Axi4ProtType     is AxiBus.WriteAddress.AWProt ;
  alias  AWValid   : std_logic        is AxiBus.WriteAddress.AWValid ;
  alias  AWReady   : std_logic        is AxiBus.WriteAddress.AWReady ;
  -- Axi4 Full
  alias  AWID      : std_logic_vector is AxiBus.WriteAddress.AWID ;
  alias  AWLen     : std_logic_vector is AxiBus.WriteAddress.AWLen ; 
  alias  AWSize    : std_logic_vector is AxiBus.WriteAddress.AWSize ;
  alias  AWBurst   : std_logic_vector is AxiBus.WriteAddress.AWBurst ;
  alias  AWLock    : std_logic        is AxiBus.WriteAddress.AWLock ;
  alias  AWCache   : std_logic_vector is AxiBus.WriteAddress.AWCache ;
  alias  AWQOS     : std_logic_vector is AxiBus.WriteAddress.AWQOS ;
  alias  AWRegion  : std_logic_vector is AxiBus.WriteAddress.AWRegion ;
  alias  AWUser    : std_logic_vector is AxiBus.WriteAddress.AWUser ;

  -- Write Data
  alias  WData     : std_logic_vector is AxiBus.WriteData.WData ;
  alias  WStrb     : std_logic_vector is AxiBus.WriteData.WStrb ;
  alias  WValid    : std_logic        is AxiBus.WriteData.WValid ;
  alias  WReady    : std_logic        is AxiBus.WriteData.WReady ;
  -- AXI4 Full
  alias  WLast     : std_logic        is AxiBus.WriteData.WLast ;
  alias  WUser     : std_logic_vector is AxiBus.WriteData.WUser ;
  -- AXI3
  alias  WID       : std_logic_vector is AxiBus.WriteData.WID ;

  -- Write Response
  alias  BResp     : Axi4RespType     is AxiBus.WriteResponse.BResp ;
  alias  BValid    : std_logic        is AxiBus.WriteResponse.BValid ;
  alias  BReady    : std_logic        is AxiBus.WriteResponse.BReady ;
  -- AXI4 Full
  alias  BID       : std_logic_vector is AxiBus.WriteResponse.BID ;
  alias  BUser     : std_logic_vector is AxiBus.WriteResponse.BUser ;

  -- Read Address
  alias  ARAddr    : std_logic_vector is AxiBus.ReadAddress.ARAddr ;
  alias  ARProt    : Axi4ProtType     is AxiBus.ReadAddress.ARProt ;
  alias  ARValid   : std_logic        is AxiBus.ReadAddress.ARValid ;
  alias  ARReady   : std_logic        is AxiBus.ReadAddress.ARReady ;
  -- Axi4 Full
  alias  ARID      : std_logic_vector is AxiBus.ReadAddress.ARID ;
  -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
  alias  ARLen     : std_logic_vector is AxiBus.ReadAddress.ARLen ;
  -- #Bytes in transfer = 2**AxSize
  alias  ARSize    : std_logic_vector is AxiBus.ReadAddress.ARSize ;
  -- AxBurst = (Fixed, Incr, Wrap, NotDefined)
  alias  ARBurst   : std_logic_vector is AxiBus.ReadAddress.ARBurst ;
  alias  ARLock    : std_logic is AxiBus.ReadAddress.ARLock ;
  -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
  alias  ARCache   : std_logic_vector is AxiBus.ReadAddress.ARCache  ;
  alias  ARQOS     : std_logic_vector is AxiBus.ReadAddress.ARQOS    ;
  alias  ARRegion  : std_logic_vector is AxiBus.ReadAddress.ARRegion ;
  alias  ARUser    : std_logic_vector is AxiBus.ReadAddress.ARUser   ;

  -- Read Data
  alias  RData     : std_logic_vector is AxiBus.ReadData.RData ;
  alias  RResp     : Axi4RespType     is AxiBus.ReadData.RResp ;
  alias  RValid    : std_logic        is AxiBus.ReadData.RValid ;
  alias  RReady    : std_logic        is AxiBus.ReadData.RReady ;
  -- AXI4 Full
  alias  RID       : std_logic_vector is AxiBus.ReadData.RID   ;
  alias  RLast     : std_logic        is AxiBus.ReadData.RLast ;
  alias  RUser     : std_logic_vector is AxiBus.ReadData.RUser ;

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
  Axi4Minion_1 : Axi4Slave 
  port map ( 
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Testbench Transaction Interface
    TransRec    => AxiMinionTransRec,

    -- AXI Master Functional Interface
--    AxiBus  => AxiBus 
    -- Mapping aliases on Left Hand Side (most similar to basic design)
    AxiBus.WriteAddress.AWAddr       => AWAddr  ,
    AxiBus.WriteAddress.AWProt       => AWProt  ,
    AxiBus.WriteAddress.AWValid      => AWValid ,
    AxiBus.WriteAddress.AWReady      => AWReady ,
    AxiBus.WriteAddress.AWID         => AWID    ,
    AxiBus.WriteAddress.AWLen        => AWLen   ,
    AxiBus.WriteAddress.AWSize       => AWSize  ,
    AxiBus.WriteAddress.AWBurst      => AWBurst ,
    AxiBus.WriteAddress.AWLock       => AWLock  ,
    AxiBus.WriteAddress.AWCache      => AWCache ,
    AxiBus.WriteAddress.AWQOS        => AWQOS   ,
    AxiBus.WriteAddress.AWRegion     => AWRegion,
    AxiBus.WriteAddress.AWUser       => AWUser  ,

    -- Mapping record elements on Left Hand Side (easiest way to connect Master to Slave DUT)
    AxiBus.WriteData.WData           => AxiBus.WriteData.WData   ,
    AxiBus.WriteData.WStrb           => AxiBus.WriteData.WStrb   ,
    AxiBus.WriteData.WValid          => AxiBus.WriteData.WValid  ,
    AxiBus.WriteData.WReady          => AxiBus.WriteData.WReady  ,
    AxiBus.WriteData.WLast           => AxiBus.WriteData.WLast  ,
    AxiBus.WriteData.WUser           => AxiBus.WriteData.WUser  ,
    AxiBus.WriteData.WID             => AxiBus.WriteData.WID  ,

    -- Mapping bus subrecords on left hand side (because it is easy)
    AxiBus.WriteResponse             => AxiBus.WriteResponse ,
    AxiBus.ReadAddress               => AxiBus.ReadAddress ,
    AxiBus.ReadData                  => AxiBus.ReadData 
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
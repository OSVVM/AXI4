--
--  File Name:         TbAxi4_AxiIfOptionsMasterMemory.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--    For Master and Memory: 
--        AWPROT, AWID, AWLOCK, AWCACHE, AWQOS, AWREGION, AWUSER, AWBURST
--        WID, WUSER
--        BRESP, BID, BUSER – BID and BUSER are set by AWID and AWUSER
--        ARPROT, ARID, ARSIZE, ARLOCK, ARCACHE, ARQOS, ARREGION, ARUSER, ARBURST
--        RRESP, RID, RUSER
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    12/2020   2020.12    Initial revision
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

architecture AxiIfOptionsMasterMemory of TestCtrl is

  signal TestDone, SetParams, RunTest, Sync : integer_barrier := 1 ;

  signal TbMasterID : AlertLogIDType ; 
  signal TbResponderID  : AlertLogIDType ; 
  signal TransactionCount : integer := 0 ; 
  constant BURST_MODE : AddressBusFifoBurstModeType := ADDRESS_BUS_BURST_WORD_MODE ;   
--  constant BURST_MODE : AddressBusFifoBurstModeType := ADDRESS_BUS_BURST_BYTE_MODE ;   
  constant DATA_WIDTH : integer := IfElse(BURST_MODE = ADDRESS_BUS_BURST_BYTE_MODE, 8, AXI_DATA_WIDTH)  ;  

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_AxiIfOptionsMasterMemory") ;
    TbMasterID <= GetAlertLogID("TB Master Proc") ;
    TbResponderID <= GetAlertLogID("TB Responder Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_AxiIfOptionsMasterMemory.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    -- SetAlertLogJustify ;
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4_AxiIfOptionsMasterMemory.txt", "../sim_shared/validated_results/TbAxi4_AxiIfOptionsMasterMemory.txt", "") ; 
    
    print("") ;
    ReportAlerts ; 
    print("") ;
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- MasterProc
  --   Generate transactions for AxiResponder
  ------------------------------------------------------------
  MasterProc : process
    variable Addr, ExpAddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data, ExpData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;  
    variable ValidDelayCycleOption : Axi4OptionsType ; 
    variable IntOption  : integer ; 
  begin
    -- Must set Master options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 
   
------------------------------------------------------  Check Defaults
    --------------------------------  Get and Check Defaults - Write
    log(TbMasterID, "Checking IF Parameters for Write Address") ;
    GetAxi4Options(MasterRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbMasterID, IntOption,  2, "AWSIZE") ; 
    GetAxi4Options(MasterRec, AWBURST,  IntOption) ;      -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbMasterID, IntOption,  1, "AWBURST") ;   -- INCR
    GetAxi4Options(MasterRec, AWLOCK,   IntOption) ;      -- std_logic
    AffirmIfEqual(TbMasterID, IntOption,  0, "AWLOCK") ;
    --------
    GetAxi4Options(MasterRec, AWPROT,   IntOption) ;      -- 3 bits
    AffirmIfEqual(TbMasterID, IntOption,   0, "AWPROT") ;
    GetAxi4Options(MasterRec, AWID,     IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,     0, "AWID") ;  
    GetAxi4Options(MasterRec, AWCACHE,  IntOption) ;      -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,  0, "AWCACHE") ;
    GetAxi4Options(MasterRec, AWQOS,    IntOption) ;      -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,    0, "AWQOS") ;
    GetAxi4Options(MasterRec, AWREGION, IntOption) ;      -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption, 0, "AWREGION") ;
    GetAxi4Options(MasterRec, AWUSER,   IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,   0, "AWUSER") ;  

    log(TbMasterID, "Checking IF Parameters for Write Data") ;
    GetAxi4Options(MasterRec, WID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,      0, "WID") ;  
    GetAxi4Options(MasterRec, WUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,    0, "WUSER") ;  

    log(TbMasterID, "Checking IF Parameters for Master Write Response") ;
    GetAxi4Options(MasterRec, BRESP,    IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbMasterID, IntOption,    0, "BRESP") ;     -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(MasterRec, BID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,      0, "BID") ;  
    GetAxi4Options(MasterRec, BUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,    0, "BUSER") ;  


    WaitForClock(MasterRec, 4) ; 
    
------------------------------------------------------  Write Test 1.  Defaults
    --------------------------------  Set #1, None - Using Defaults
    --------------------------------  Get and Check #1, None - Already Done Above 
    --------------------------------  Do Writes #1
    log(TbMasterID, "Write with parameters setting #1, Defaults") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    Write(MasterRec, Addr,    Data) ;
    Write(MasterRec, Addr+4,  Data+1) ;
    PushBurstIncrement(WriteBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
    WriteBurst(MasterRec, Addr + 16, 8) ;
    
    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Write Test 2.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #2
    log(TbMasterID, "Set Write parameters #2") ;
    log(TbMasterID, "Setting IF Parameters for Write Address") ;
    SetAxi4Options(MasterRec, AWBURST,   2) ;      -- 2 bits (fixed, incr, wrap, none)
    SetAxi4Options(MasterRec, AWLOCK,    1) ;      -- std_logic
    --------
    SetAxi4Options(MasterRec, AWPROT,    3) ;      -- 3 bits
    SetAxi4Options(MasterRec, AWID,      4) ;      -- config:  8 bits
    SetAxi4Options(MasterRec, AWCACHE,   5) ;      -- 4 bits
    SetAxi4Options(MasterRec, AWQOS,     6) ;      -- 4 bits
    SetAxi4Options(MasterRec, AWREGION,  7) ;      -- 4 bits
    SetAxi4Options(MasterRec, AWUSER,    8) ;      -- config: 8 bits

    log(TbMasterID, "Setting IF Parameters for Write Data") ;
    SetAxi4Options(MasterRec, WID,       9) ;      -- config:  8 bits
    SetAxi4Options(MasterRec, WUSER,    10) ;      -- config: 8 bits

    log(TbMasterID, "Setting IF Parameters for Master Write Response") ;
    SetAxi4Options(MasterRec, BRESP,     1) ;      -- config:  2 bits
    SetAxi4Options(MasterRec, BID,      11) ;      -- config:  8 bits
    SetAxi4Options(MasterRec, BUSER,    12) ;      -- config: 8 bits
    
    --------------------------------  Get and Check #2
    log(TbMasterID, "Verify Write parameters #2 were set by doing get") ;
    log(TbMasterID, "Checking IF Parameters for Write Address") ;
    GetAxi4Options(MasterRec, AWBURST,  IntOption) ;      -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbMasterID, IntOption,   2, "AWBURST") ;  -- INCR
    GetAxi4Options(MasterRec, AWLOCK,   IntOption) ;      -- std_logic
    AffirmIfEqual(TbMasterID, IntOption,    1, "AWLOCK") ;
    --------
    GetAxi4Options(MasterRec, AWPROT,   IntOption) ;      -- 3 bits
    AffirmIfEqual(TbMasterID, IntOption,    3, "AWPROT") ;
    GetAxi4Options(MasterRec, AWID,     IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,      4, "AWID") ;  
    GetAxi4Options(MasterRec, AWCACHE,  IntOption) ;      -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,   5, "AWCACHE") ;
    GetAxi4Options(MasterRec, AWQOS,    IntOption) ;      -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,     6, "AWQOS") ;
    GetAxi4Options(MasterRec, AWREGION, IntOption) ;      -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,  7, "AWREGION") ;
    GetAxi4Options(MasterRec, AWUSER,   IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,    8, "AWUSER") ;  

    log(TbMasterID, "Checking IF Parameters for Write Data") ;
    GetAxi4Options(MasterRec, WID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,       9, "WID") ;  
    GetAxi4Options(MasterRec, WUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,    10, "WUSER") ;  

    log(TbMasterID, "Checking IF Parameters for Master Write Response") ;
    GetAxi4Options(MasterRec, BRESP,    IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbMasterID, IntOption,     1, "BRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(MasterRec, BID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,      11, "BID") ;  
    GetAxi4Options(MasterRec, BUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,    12, "BUSER") ;  

    --------------------------------  Do Writes #2
    WaitForBarrier(RunTest) ;
    log(TbMasterID, "Write with parameters setting #2") ;
    Addr := Addr + 256 ; 
    Data := Data + 256 ; 
    Write(MasterRec, Addr,    Data) ;
    Write(MasterRec, Addr+4,  Data+1) ;
    PushBurstIncrement(WriteBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
    WriteBurst(MasterRec, Addr + 16, 8) ;

    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Write Test 3.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #3
    log(TbMasterID, "Set Write parameters #3") ;
    log(TbMasterID, "Setting IF Parameters for Write Address") ;
    SetAxi4Options(MasterRec, AWBURST,   1) ;      -- 2 bits (fixed, incr, wrap, none)
    SetAxi4Options(MasterRec, AWLOCK,    0) ;      -- std_logic
    --------
    SetAxi4Options(MasterRec, AWPROT,    2) ;      -- 3 bits
    SetAxi4Options(MasterRec, AWID,     10) ;      -- config:  8 bits
    SetAxi4Options(MasterRec, AWCACHE,  11) ;      -- 4 bits
    SetAxi4Options(MasterRec, AWQOS,    12) ;      -- 4 bits
    SetAxi4Options(MasterRec, AWREGION, 13) ;      -- 4 bits
    SetAxi4Options(MasterRec, AWUSER,   14) ;      -- config: 8 bits

    log(TbMasterID, "Checking IF Parameters for Write Data") ;
    SetAxi4Options(MasterRec, WID,      15) ;      -- config:  8 bits
    SetAxi4Options(MasterRec, WUSER,    16) ;      -- config: 8 bits

    log(TbMasterID, "Checking IF Parameters for Master Write Response") ;
    SetAxi4Options(MasterRec, BRESP,     2) ;      -- config:  2 bits
    SetAxi4Options(MasterRec, BID,      17) ;      -- config:  8 bits
    SetAxi4Options(MasterRec, BUSER,    18) ;      -- config: 8 bits

    --------------------------------  Get and Check #3
    log(TbMasterID, "Verify Write parameters #3 were set by doing get") ;
    log(TbMasterID, "Checking IF Parameters for Write Address") ;
    GetAxi4Options(MasterRec, AWBURST,  IntOption) ;      -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbMasterID, IntOption,   1, "AWBURST") ;   -- INCR
    GetAxi4Options(MasterRec, AWLOCK,   IntOption) ;      -- std_logic
    AffirmIfEqual(TbMasterID, IntOption,    0, "AWLOCK") ;
    --------
    GetAxi4Options(MasterRec, AWPROT,   IntOption) ;      -- 3 bits
    AffirmIfEqual(TbMasterID, IntOption,    2, "AWPROT") ;
    GetAxi4Options(MasterRec, AWID,     IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,     10, "AWID") ;  
    GetAxi4Options(MasterRec, AWCACHE,  IntOption) ;      -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,  11, "AWCACHE") ;
    GetAxi4Options(MasterRec, AWQOS,    IntOption) ;      -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,    12, "AWQOS") ;
    GetAxi4Options(MasterRec, AWREGION, IntOption) ;      -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption, 13, "AWREGION") ;
    GetAxi4Options(MasterRec, AWUSER,   IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,   14, "AWUSER") ;  

    log(TbMasterID, "Checking IF Parameters for Write Data") ;
    GetAxi4Options(MasterRec, WID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,      15, "WID") ;  
    GetAxi4Options(MasterRec, WUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,    16, "WUSER") ;  

    log(TbMasterID, "Checking IF Parameters for Master Write Response") ;
    GetAxi4Options(MasterRec, BRESP,    IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbMasterID, IntOption,     2, "BRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(MasterRec, BID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,      17, "BID") ;  
    GetAxi4Options(MasterRec, BUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,    18, "BUSER") ;  

    --------------------------------  Do Writes #3
    WaitForBarrier(RunTest) ;
    log(TbMasterID, "Write with parameters setting #3") ;
    Addr := Addr + 256 ; 
    Data := Data + 256 ; 
    Write(MasterRec, Addr,    Data) ;
    Write(MasterRec, Addr+4,  Data+1) ;
    PushBurstIncrement(WriteBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
    WriteBurst(MasterRec, Addr + 16, 8) ;
    
    
    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;


--  ==================================================  Read Tests
    WaitForBarrier(Sync) ;

------------------------------------------------------  Check Defaults
    --------------------------------  Get and Check Defaults - Read
    log(TbMasterID, "Checking IF Parameters for Read Address") ;
    GetAxi4Options(MasterRec, ARSIZE,   IntOption) ;        -- 3 bits 2**N bytes
    AffirmIfEqual(TbMasterID, IntOption,   2, "ARSIZE") ; 
    GetAxi4Options(MasterRec, ARBURST,  IntOption) ;        -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbMasterID, IntOption,   1, "ARBURST") ;  -- INCR
    GetAxi4Options(MasterRec, ARLOCK,   IntOption) ;        -- std_logic
    AffirmIfEqual(TbMasterID, IntOption,   0, "ARLOCK") ;
    ------ 
    GetAxi4Options(MasterRec, ARPROT,   IntOption) ;        -- 3 bits
    AffirmIfEqual(TbMasterID, IntOption,   0, "ARPROT") ;
    GetAxi4Options(MasterRec, ARID,     IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,   0, "ARID") ;  
    GetAxi4Options(MasterRec, ARCACHE,  IntOption) ;        -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,   0, "ARCACHE") ;
    GetAxi4Options(MasterRec, ARQOS,    IntOption) ;        -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,   0, "ARQOS") ;
    GetAxi4Options(MasterRec, ARREGION, IntOption) ;        -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,   0, "ARREGION") ;
    GetAxi4Options(MasterRec, ARUSER,   IntOption) ;        -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,   0, "ARUSER") ;  

    log(TbMasterID, "Checking IF Parameters for Master READ DATA") ;
    GetAxi4Options(MasterRec, RRESP,    IntOption) ;        -- config:  2 bits
    AffirmIfEqual(TbMasterID, IntOption,   0, "RRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(MasterRec, RID,      IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,   0, "RID") ;  
    GetAxi4Options(MasterRec, RUSER,    IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,   0, "RUSER") ;  
    
------------------------------------------------------  Read Test 1.  Defaults
    --------------------------------  Set #1, None - Using Defaults
    --------------------------------  Get and Check #1, None - Already Done Above 
    --------------------------------  Do Reads #1
    log(TbMasterID, "Read with parameters setting #1, Defaults") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    ReadCheck(MasterRec, Addr,    Data) ;
    ReadCheck(MasterRec, Addr+4,  Data+1) ;
    ReadBurst(MasterRec, Addr + 16, 8) ;
    CheckBurstIncrement(ReadBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
    
    
    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Read Test 2.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #2
    log(TbMasterID, "Set Read parameters #2") ;
    SetAxi4Options(MasterRec, ARBURST,  2) ;        -- 2 bits (fixed, incr, wrap, none)
    SetAxi4Options(MasterRec, ARLOCK,   1) ;        -- std_logic
    ------ 
    SetAxi4Options(MasterRec, ARPROT,   3) ;        -- 3 bits
    SetAxi4Options(MasterRec, ARID,     4) ;        -- config:  8 bits
    SetAxi4Options(MasterRec, ARCACHE,  5) ;        -- 4 bits
    SetAxi4Options(MasterRec, ARQOS,    6) ;        -- 4 bits
    SetAxi4Options(MasterRec, ARREGION, 7) ;        -- 4 bits
    SetAxi4Options(MasterRec, ARUSER,   8) ;        -- config: 8 bits

    log(TbMasterID, "Checking IF Parameters for Master READ DATA") ;
    SetAxi4Options(MasterRec, RRESP,    1) ;        -- config:  2 bits
    SetAxi4Options(MasterRec, RID,      9) ;        -- config:  8 bits
    SetAxi4Options(MasterRec, RUSER,    10) ;        -- config:  8 bits
    
    --------------------------------  Get and Check #2
    log(TbMasterID, "Checking IF Parameters for Read Address") ;
    GetAxi4Options(MasterRec, ARBURST,  IntOption) ;        -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbMasterID, IntOption,   2, "ARBURST") ;  -- INCR
    GetAxi4Options(MasterRec, ARLOCK,   IntOption) ;        -- std_logic
    AffirmIfEqual(TbMasterID, IntOption,   1, "ARLOCK") ;
    ------ 
    GetAxi4Options(MasterRec, ARPROT,   IntOption) ;        -- 3 bits
    AffirmIfEqual(TbMasterID, IntOption,   3, "ARPROT") ;
    GetAxi4Options(MasterRec, ARID,     IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,   4, "ARID") ;  
    GetAxi4Options(MasterRec, ARCACHE,  IntOption) ;        -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,   5, "ARCACHE") ;
    GetAxi4Options(MasterRec, ARQOS,    IntOption) ;        -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,   6, "ARQOS") ;
    GetAxi4Options(MasterRec, ARREGION, IntOption) ;        -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,   7, "ARREGION") ;
    GetAxi4Options(MasterRec, ARUSER,   IntOption) ;        -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,   8, "ARUSER") ;  

    log(TbMasterID, "Checking IF Parameters for Master READ DATA") ;
    GetAxi4Options(MasterRec, RRESP,    IntOption) ;        -- config:  2 bits
    AffirmIfEqual(TbMasterID, IntOption,   1, "RRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(MasterRec, RID,      IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,   9, "RID") ;  
    GetAxi4Options(MasterRec, RUSER,    IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,  10, "RUSER") ;  

    --------------------------------  Do Reads #2
    WaitForBarrier(RunTest) ;
    log(TbMasterID, "Read with parameters setting #2") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" + 256 ; 
    Data := X"0000_0000" + 256 ; 
    ReadCheck(MasterRec, Addr,    Data) ;
    ReadCheck(MasterRec, Addr+4,  Data+1) ;
    ReadBurst(MasterRec, Addr + 16, 8) ;
    CheckBurstIncrement(ReadBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
    
    
    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Read Test 3.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #3
    log(TbMasterID, "Set Read parameters #3") ;
    SetAxi4Options(MasterRec, ARBURST,   1) ;        -- 2 bits (fixed, incr, wrap, none)
    SetAxi4Options(MasterRec, ARLOCK,    0) ;        -- std_logic
    ------ 
    SetAxi4Options(MasterRec, ARPROT,    2) ;        -- 3 bits
    SetAxi4Options(MasterRec, ARID,     10) ;        -- config:  8 bits
    SetAxi4Options(MasterRec, ARCACHE,  11) ;        -- 4 bits
    SetAxi4Options(MasterRec, ARQOS,    12) ;        -- 4 bits
    SetAxi4Options(MasterRec, ARREGION, 13) ;        -- 4 bits
    SetAxi4Options(MasterRec, ARUSER,   14) ;        -- config: 8 bits

    log(TbMasterID, "Checking IF Parameters for Master READ DATA") ;
    SetAxi4Options(MasterRec, RRESP,     2) ;        -- config:  2 bits
    SetAxi4Options(MasterRec, RID,      15) ;        -- config:  8 bits
    SetAxi4Options(MasterRec, RUSER,    16) ;        -- config:  8 bits
    
    --------------------------------  Get and Check #3
    log(TbMasterID, "Checking IF Parameters for Read Address") ;
    GetAxi4Options(MasterRec, ARBURST,  IntOption) ;        -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbMasterID, IntOption,   1, "ARBURST") ;  -- INCR
    GetAxi4Options(MasterRec, ARLOCK,   IntOption) ;        -- std_logic
    AffirmIfEqual(TbMasterID, IntOption,   0, "ARLOCK") ;
    ------ 
    GetAxi4Options(MasterRec, ARPROT,   IntOption) ;        -- 3 bits
    AffirmIfEqual(TbMasterID, IntOption,   2, "ARPROT") ;
    GetAxi4Options(MasterRec, ARID,     IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,  10, "ARID") ;  
    GetAxi4Options(MasterRec, ARCACHE,  IntOption) ;        -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,  11, "ARCACHE") ;
    GetAxi4Options(MasterRec, ARQOS,    IntOption) ;        -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,  12, "ARQOS") ;
    GetAxi4Options(MasterRec, ARREGION, IntOption) ;        -- 4 bits
    AffirmIfEqual(TbMasterID, IntOption,  13, "ARREGION") ;
    GetAxi4Options(MasterRec, ARUSER,   IntOption) ;        -- config: 8 bits
    AffirmIfEqual(TbMasterID, IntOption,  14, "ARUSER") ;  

    log(TbMasterID, "Checking IF Parameters for Master READ DATA") ;
    GetAxi4Options(MasterRec, RRESP,    IntOption) ;        -- config:  2 bits
    AffirmIfEqual(TbMasterID, IntOption,   2, "RRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(MasterRec, RID,      IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,  15, "RID") ;  
    GetAxi4Options(MasterRec, RUSER,    IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbMasterID, IntOption,  16, "RUSER") ; 
    
    --------------------------------  Do Reads #3
    WaitForBarrier(RunTest) ;
    log(TbMasterID, "Read with parameters setting #3") ;
    increment(TransactionCount) ;
    Addr := Addr + 256 ; 
    Data := Data + 256 ; 
    ReadCheck(MasterRec, Addr,    Data) ;
    ReadCheck(MasterRec, Addr+4,  Data+1) ;
    ReadBurst(MasterRec, Addr + 16, 8) ;
    CheckBurstIncrement(ReadBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
    
    
    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(MasterRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MasterProc ;
  
  
  ------------------------------------------------------------
  -- ResponderProc
  --   Generate transactions for AxiResponder
  ------------------------------------------------------------
  ResponderProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
    variable IntOption : integer ; 
  begin
    wait for 0 ns ; 
    wait for 1 ns ; -- Allow default checks in Master to happen first
    
------------------------------------------------------  Check Defaults
    --------------------------------  Get and Check Defaults - Write
    log(TbResponderID, "Checking IF Parameters for Responder Write Response") ;
    GetAxi4Options(ResponderRec, BRESP, IntOption) ;       -- config:  2 bits
    AffirmIfEqual(TbResponderID, IntOption, 0, "BRESP") ;      -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ResponderRec, BID, IntOption) ;         -- config:  8 bits
    AffirmIfEqual(TbResponderID, IntOption,   0, "BID") ;  
    GetAxi4Options(ResponderRec, BUSER, IntOption) ;       -- config: 8 bits
    AffirmIfEqual(TbResponderID, IntOption, 0, "BUSER") ;  


------------------------------------------------------  Write Test 2.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    wait for 1 ns ; 
    --------------------------------  Set #2
    SetAxi4Options(ResponderRec, BRESP,  1) ;      -- config:  2 bits
    SetAxi4Options(ResponderRec, BID,   21) ;      -- config:  8 bits
    SetAxi4Options(ResponderRec, BUSER, 22) ;      -- config:  8 bits
    
    --------------------------------  Get and Check #2
    GetAxi4Options(ResponderRec, BRESP, IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbResponderID, IntOption,  1, "BRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ResponderRec, BID, IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbResponderID, IntOption,   21, "BID") ;  
    GetAxi4Options(ResponderRec, BUSER, IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbResponderID, IntOption, 22, "BUSER") ;  
    
    WaitForBarrier(RunTest) ;

------------------------------------------------------  Write Test 3.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    wait for 1 ns ; 
    --------------------------------  Set #3
    SetAxi4Options(ResponderRec, BRESP,  2) ;      -- config:  2 bits
    SetAxi4Options(ResponderRec, BID,   27) ;      -- config:  8 bits
    SetAxi4Options(ResponderRec, BUSER, 28) ;      -- config:  8 bits
    
    --------------------------------  Get and Check #3
    GetAxi4Options(ResponderRec, BRESP, IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbResponderID, IntOption,  2, "BRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ResponderRec, BID, IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbResponderID, IntOption,   27, "BID") ;  
    GetAxi4Options(ResponderRec, BUSER, IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbResponderID, IntOption, 28, "BUSER") ;  
    
    WaitForBarrier(RunTest) ;


--  ==================================================  Read Tests
    WaitForBarrier(Sync) ;
    wait for 1 ns ; -- Allow default checks in Master to happen first
    
------------------------------------------------------  Check Defaults
    --------------------------------  Get and Check Defaults - Read
    log(TbResponderID, "Checking IF Parameters for Responder Read Data") ;
    GetAxi4Options(ResponderRec, RRESP, IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbResponderID, IntOption, 0, "RRESP") ;     -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ResponderRec, RID, IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbResponderID, IntOption, 0, "RID") ;  
    GetAxi4Options(ResponderRec, RUSER, IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbResponderID, IntOption, 0, "RUSER") ;  

------------------------------------------------------  Read Test 2.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    wait for 1 ns ; 
    --------------------------------  Set #2
    SetAxi4Options(ResponderRec, RRESP,  1) ;        -- config:  2 bits
    SetAxi4Options(ResponderRec, RID,    9) ;        -- config:  8 bits
    SetAxi4Options(ResponderRec, RUSER, 10) ;        -- config:  8 bits

    --------------------------------  Get and Check #2
    GetAxi4Options(ResponderRec, RRESP, IntOption) ;        -- config:  2 bits
    AffirmIfEqual(TbResponderID, IntOption,  1, "RRESP") ;  -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ResponderRec, RID, IntOption) ;          -- config:  8 bits
    AffirmIfEqual(TbResponderID, IntOption,  9, "RID") ;  
    GetAxi4Options(ResponderRec, RUSER, IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbResponderID, IntOption, 10, "RUSER") ;  
    
    WaitForBarrier(RunTest) ;

------------------------------------------------------  Read Test 3.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    wait for 1 ns ; 
    --------------------------------  Set #3
    SetAxi4Options(ResponderRec, RRESP,  2) ;        -- config:  2 bits
    SetAxi4Options(ResponderRec, RID,   15) ;        -- config:  8 bits
    SetAxi4Options(ResponderRec, RUSER, 16) ;        -- config:  8 bits

    --------------------------------  Get and Check #3
    GetAxi4Options(ResponderRec, RRESP, IntOption) ;        -- config:  2 bits
    AffirmIfEqual(TbResponderID, IntOption,  2, "RRESP") ;  -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ResponderRec, RID, IntOption) ;          -- config:  8 bits
    AffirmIfEqual(TbResponderID, IntOption, 15, "RID") ;  
    GetAxi4Options(ResponderRec, RUSER, IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbResponderID, IntOption, 16, "RUSER") ;  

    WaitForBarrier(RunTest) ;


    WaitForBarrier(TestDone) ;
    wait ;
  end process ResponderProc ;

end AxiIfOptionsMasterMemory ;

Configuration TbAxi4_AxiIfOptionsMasterMemory of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiIfOptionsMasterMemory) ; 
    end for ; 
--!!    for Responder_1 : Axi4Responder 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_AxiIfOptionsMasterMemory ; 
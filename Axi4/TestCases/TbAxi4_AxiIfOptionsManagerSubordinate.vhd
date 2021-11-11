--
--  File Name:         TbAxi4_AxiIfOptionsManagerSubordinate.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--    For Manager and Subordinate: 
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
--  Copyright (c) 2018 - 2021 by SynthWorks Design Inc.  
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

architecture AxiIfOptionsManagerSubordinate of TestCtrl is

  signal TestDone, SetParams, RunTest, Sync : integer_barrier := 1 ;

  signal TbManagerID : AlertLogIDType ; 
  signal TbSubordinateID  : AlertLogIDType ; 
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
    SetAlertLogName("TbAxi4_AxiIfOptionsManagerSubordinate") ;
    TbManagerID <= GetAlertLogID("TB Manager Proc") ;
    TbSubordinateID <= GetAlertLogID("TB Subordinate Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_AxiIfOptionsManagerSubordinate.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_AxiIfOptionsManagerSubordinate.txt", "../sim_shared/validated_results/TbAxi4_AxiIfOptionsManagerSubordinate.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- ManagerProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  ManagerProc : process
    variable Addr, ExpAddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data, ExpData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;  
    variable ValidDelayCycleOption : Axi4OptionsType ; 
    variable IntOption  : integer ; 
  begin
    -- Must set Manager options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 
   
------------------------------------------------------  Check Defaults
    --------------------------------  Get and Check Defaults - Write
    log(TbManagerID, "Checking IF Parameters for Write Address") ;
    GetAxi4Options(ManagerRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbManagerID, IntOption,  2, "AWSIZE") ; 
    GetAxi4Options(ManagerRec, AWBURST,  IntOption) ;      -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbManagerID, IntOption,  1, "AWBURST") ;   -- INCR
    GetAxi4Options(ManagerRec, AWLOCK,   IntOption) ;      -- std_logic
    AffirmIfEqual(TbManagerID, IntOption,  0, "AWLOCK") ;
    --------
    GetAxi4Options(ManagerRec, AWPROT,   IntOption) ;      -- 3 bits
    AffirmIfEqual(TbManagerID, IntOption,   0, "AWPROT") ;
    GetAxi4Options(ManagerRec, AWID,     IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,     0, "AWID") ;  
    GetAxi4Options(ManagerRec, AWCACHE,  IntOption) ;      -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,  0, "AWCACHE") ;
    GetAxi4Options(ManagerRec, AWQOS,    IntOption) ;      -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,    0, "AWQOS") ;
    GetAxi4Options(ManagerRec, AWREGION, IntOption) ;      -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption, 0, "AWREGION") ;
    GetAxi4Options(ManagerRec, AWUSER,   IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,   0, "AWUSER") ;  

    log(TbManagerID, "Checking IF Parameters for Write Data") ;
    GetAxi4Options(ManagerRec, WID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,      0, "WID") ;  
    GetAxi4Options(ManagerRec, WUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,    0, "WUSER") ;  

    log(TbManagerID, "Checking IF Parameters for Manager Write Response") ;
    GetAxi4Options(ManagerRec, BRESP,    IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbManagerID, IntOption,    0, "BRESP") ;     -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ManagerRec, BID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,      0, "BID") ;  
    GetAxi4Options(ManagerRec, BUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,    0, "BUSER") ;  


    WaitForClock(ManagerRec, 4) ; 
    
------------------------------------------------------  Write Test 1.  Defaults
    --------------------------------  Set #1, None - Using Defaults
    --------------------------------  Get and Check #1, None - Already Done Above 
    --------------------------------  Do Writes #1
    WaitForBarrier(RunTest) ;
    log(TbManagerID, "Write with parameters setting #1, Defaults") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    Write(ManagerRec, Addr,    Data) ;
    Write(ManagerRec, Addr+4,  Data+1) ;
--!!    PushBurstIncrement(WriteBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
--!!    WriteBurst(ManagerRec, Addr + 16, 8) ;
    
    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Write Test 2.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #2
    log(TbManagerID, "Set Write parameters #2") ;
    log(TbManagerID, "Setting IF Parameters for Write Address") ;
    SetAxi4Options(ManagerRec, AWBURST,   2) ;      -- 2 bits (fixed, incr, wrap, none)
    SetAxi4Options(ManagerRec, AWLOCK,    1) ;      -- std_logic
    --------
    SetAxi4Options(ManagerRec, AWPROT,    3) ;      -- 3 bits
    SetAxi4Options(ManagerRec, AWID,      4) ;      -- config:  8 bits
    SetAxi4Options(ManagerRec, AWCACHE,   5) ;      -- 4 bits
    SetAxi4Options(ManagerRec, AWQOS,     6) ;      -- 4 bits
    SetAxi4Options(ManagerRec, AWREGION,  7) ;      -- 4 bits
    SetAxi4Options(ManagerRec, AWUSER,    8) ;      -- config: 8 bits

    log(TbManagerID, "Setting IF Parameters for Write Data") ;
    SetAxi4Options(ManagerRec, WID,       9) ;      -- config:  8 bits
    SetAxi4Options(ManagerRec, WUSER,    10) ;      -- config: 8 bits

    log(TbManagerID, "Setting IF Parameters for Manager Write Response") ;
    SetAxi4Options(ManagerRec, BRESP,     1) ;      -- config:  2 bits
    SetAxi4Options(ManagerRec, BID,      11) ;      -- config:  8 bits
    SetAxi4Options(ManagerRec, BUSER,    12) ;      -- config: 8 bits
    
    --------------------------------  Get and Check #2
    log(TbManagerID, "Verify Write parameters #2 were set by doing get") ;
    log(TbManagerID, "Checking IF Parameters for Write Address") ;
    GetAxi4Options(ManagerRec, AWBURST,  IntOption) ;      -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbManagerID, IntOption,   2, "AWBURST") ;  -- INCR
    GetAxi4Options(ManagerRec, AWLOCK,   IntOption) ;      -- std_logic
    AffirmIfEqual(TbManagerID, IntOption,    1, "AWLOCK") ;
    --------
    GetAxi4Options(ManagerRec, AWPROT,   IntOption) ;      -- 3 bits
    AffirmIfEqual(TbManagerID, IntOption,    3, "AWPROT") ;
    GetAxi4Options(ManagerRec, AWID,     IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,      4, "AWID") ;  
    GetAxi4Options(ManagerRec, AWCACHE,  IntOption) ;      -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,   5, "AWCACHE") ;
    GetAxi4Options(ManagerRec, AWQOS,    IntOption) ;      -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,     6, "AWQOS") ;
    GetAxi4Options(ManagerRec, AWREGION, IntOption) ;      -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,  7, "AWREGION") ;
    GetAxi4Options(ManagerRec, AWUSER,   IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,    8, "AWUSER") ;  

    log(TbManagerID, "Checking IF Parameters for Write Data") ;
    GetAxi4Options(ManagerRec, WID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,       9, "WID") ;  
    GetAxi4Options(ManagerRec, WUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,    10, "WUSER") ;  

    log(TbManagerID, "Checking IF Parameters for Manager Write Response") ;
    GetAxi4Options(ManagerRec, BRESP,    IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbManagerID, IntOption,     1, "BRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ManagerRec, BID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,      11, "BID") ;  
    GetAxi4Options(ManagerRec, BUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,    12, "BUSER") ;  

    --------------------------------  Do Writes #2
    WaitForBarrier(RunTest) ;
    log(TbManagerID, "Write with parameters setting #2") ;
    Addr := Addr + 256 ; 
    Data := Data + 256 ; 
    Write(ManagerRec, Addr,    Data) ;
    Write(ManagerRec, Addr+4,  Data+1) ;
--!!    PushBurstIncrement(WriteBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
--!!    WriteBurst(ManagerRec, Addr + 16, 8) ;

    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Write Test 3.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #3
    log(TbManagerID, "Set Write parameters #3") ;
    log(TbManagerID, "Setting IF Parameters for Write Address") ;
    SetAxi4Options(ManagerRec, AWBURST,   1) ;      -- 2 bits (fixed, incr, wrap, none)
    SetAxi4Options(ManagerRec, AWLOCK,    0) ;      -- std_logic
    --------
    SetAxi4Options(ManagerRec, AWPROT,    2) ;      -- 3 bits
    SetAxi4Options(ManagerRec, AWID,     10) ;      -- config:  8 bits
    SetAxi4Options(ManagerRec, AWCACHE,  11) ;      -- 4 bits
    SetAxi4Options(ManagerRec, AWQOS,    12) ;      -- 4 bits
    SetAxi4Options(ManagerRec, AWREGION, 13) ;      -- 4 bits
    SetAxi4Options(ManagerRec, AWUSER,   14) ;      -- config: 8 bits

    log(TbManagerID, "Checking IF Parameters for Write Data") ;
    SetAxi4Options(ManagerRec, WID,      15) ;      -- config:  8 bits
    SetAxi4Options(ManagerRec, WUSER,    16) ;      -- config: 8 bits

    log(TbManagerID, "Checking IF Parameters for Manager Write Response") ;
    SetAxi4Options(ManagerRec, BRESP,     2) ;      -- config:  2 bits
    SetAxi4Options(ManagerRec, BID,      17) ;      -- config:  8 bits
    SetAxi4Options(ManagerRec, BUSER,    18) ;      -- config: 8 bits

    --------------------------------  Get and Check #3
    log(TbManagerID, "Verify Write parameters #3 were set by doing get") ;
    log(TbManagerID, "Checking IF Parameters for Write Address") ;
    GetAxi4Options(ManagerRec, AWBURST,  IntOption) ;      -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbManagerID, IntOption,   1, "AWBURST") ;   -- INCR
    GetAxi4Options(ManagerRec, AWLOCK,   IntOption) ;      -- std_logic
    AffirmIfEqual(TbManagerID, IntOption,    0, "AWLOCK") ;
    --------
    GetAxi4Options(ManagerRec, AWPROT,   IntOption) ;      -- 3 bits
    AffirmIfEqual(TbManagerID, IntOption,    2, "AWPROT") ;
    GetAxi4Options(ManagerRec, AWID,     IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,     10, "AWID") ;  
    GetAxi4Options(ManagerRec, AWCACHE,  IntOption) ;      -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,  11, "AWCACHE") ;
    GetAxi4Options(ManagerRec, AWQOS,    IntOption) ;      -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,    12, "AWQOS") ;
    GetAxi4Options(ManagerRec, AWREGION, IntOption) ;      -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption, 13, "AWREGION") ;
    GetAxi4Options(ManagerRec, AWUSER,   IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,   14, "AWUSER") ;  

    log(TbManagerID, "Checking IF Parameters for Write Data") ;
    GetAxi4Options(ManagerRec, WID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,      15, "WID") ;  
    GetAxi4Options(ManagerRec, WUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,    16, "WUSER") ;  

    log(TbManagerID, "Checking IF Parameters for Manager Write Response") ;
    GetAxi4Options(ManagerRec, BRESP,    IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbManagerID, IntOption,     2, "BRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ManagerRec, BID,      IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,      17, "BID") ;  
    GetAxi4Options(ManagerRec, BUSER,    IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,    18, "BUSER") ;  

    --------------------------------  Do Writes #3
    WaitForBarrier(RunTest) ;
    log(TbManagerID, "Write with parameters setting #3") ;
    Addr := Addr + 256 ; 
    Data := Data + 256 ; 
    Write(ManagerRec, Addr,    Data) ;
    Write(ManagerRec, Addr+4,  Data+1) ;
--!!    PushBurstIncrement(WriteBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
--!!    WriteBurst(ManagerRec, Addr + 16, 8) ;
    
    
    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;


--  ==================================================  Read Tests
    WaitForBarrier(Sync) ;

------------------------------------------------------  Check Defaults
    --------------------------------  Get and Check Defaults - Read
    log(TbManagerID, "Checking IF Parameters for Read Address") ;
    GetAxi4Options(ManagerRec, ARSIZE,   IntOption) ;        -- 3 bits 2**N bytes
    AffirmIfEqual(TbManagerID, IntOption,   2, "ARSIZE") ; 
    GetAxi4Options(ManagerRec, ARBURST,  IntOption) ;        -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbManagerID, IntOption,   1, "ARBURST") ;  -- INCR
    GetAxi4Options(ManagerRec, ARLOCK,   IntOption) ;        -- std_logic
    AffirmIfEqual(TbManagerID, IntOption,   0, "ARLOCK") ;
    ------ 
    GetAxi4Options(ManagerRec, ARPROT,   IntOption) ;        -- 3 bits
    AffirmIfEqual(TbManagerID, IntOption,   0, "ARPROT") ;
    GetAxi4Options(ManagerRec, ARID,     IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,   0, "ARID") ;  
    GetAxi4Options(ManagerRec, ARCACHE,  IntOption) ;        -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,   0, "ARCACHE") ;
    GetAxi4Options(ManagerRec, ARQOS,    IntOption) ;        -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,   0, "ARQOS") ;
    GetAxi4Options(ManagerRec, ARREGION, IntOption) ;        -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,   0, "ARREGION") ;
    GetAxi4Options(ManagerRec, ARUSER,   IntOption) ;        -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,   0, "ARUSER") ;  

    log(TbManagerID, "Checking IF Parameters for Manager READ DATA") ;
    GetAxi4Options(ManagerRec, RRESP,    IntOption) ;        -- config:  2 bits
    AffirmIfEqual(TbManagerID, IntOption,   0, "RRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ManagerRec, RID,      IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,   0, "RID") ;  
    GetAxi4Options(ManagerRec, RUSER,    IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,   0, "RUSER") ;  
    
------------------------------------------------------  Read Test 1.  Defaults
    --------------------------------  Set #1, None - Using Defaults
    --------------------------------  Get and Check #1, None - Already Done Above 
    --------------------------------  Do Reads #1
    WaitForBarrier(RunTest) ;
    log(TbManagerID, "Read with parameters setting #1, Defaults") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    ReadCheck(ManagerRec, Addr,    Data) ;
    ReadCheck(ManagerRec, Addr+4,  Data+1) ;
--!!    ReadBurst(ManagerRec, Addr + 16, 8) ;
--!!    CheckBurstIncrement(ReadBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
    
    
    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Read Test 2.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #2
    log(TbManagerID, "Set Read parameters #2") ;
    SetAxi4Options(ManagerRec, ARBURST,  2) ;        -- 2 bits (fixed, incr, wrap, none)
    SetAxi4Options(ManagerRec, ARLOCK,   1) ;        -- std_logic
    ------ 
    SetAxi4Options(ManagerRec, ARPROT,   3) ;        -- 3 bits
    SetAxi4Options(ManagerRec, ARID,     4) ;        -- config:  8 bits
    SetAxi4Options(ManagerRec, ARCACHE,  5) ;        -- 4 bits
    SetAxi4Options(ManagerRec, ARQOS,    6) ;        -- 4 bits
    SetAxi4Options(ManagerRec, ARREGION, 7) ;        -- 4 bits
    SetAxi4Options(ManagerRec, ARUSER,   8) ;        -- config: 8 bits

    log(TbManagerID, "Checking IF Parameters for Manager READ DATA") ;
    SetAxi4Options(ManagerRec, RRESP,    1) ;        -- config:  2 bits
    SetAxi4Options(ManagerRec, RID,      9) ;        -- config:  8 bits
    SetAxi4Options(ManagerRec, RUSER,    10) ;        -- config:  8 bits
    
    --------------------------------  Get and Check #2
    log(TbManagerID, "Checking IF Parameters for Read Address") ;
    GetAxi4Options(ManagerRec, ARBURST,  IntOption) ;        -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbManagerID, IntOption,   2, "ARBURST") ;  -- INCR
    GetAxi4Options(ManagerRec, ARLOCK,   IntOption) ;        -- std_logic
    AffirmIfEqual(TbManagerID, IntOption,   1, "ARLOCK") ;
    ------ 
    GetAxi4Options(ManagerRec, ARPROT,   IntOption) ;        -- 3 bits
    AffirmIfEqual(TbManagerID, IntOption,   3, "ARPROT") ;
    GetAxi4Options(ManagerRec, ARID,     IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,   4, "ARID") ;  
    GetAxi4Options(ManagerRec, ARCACHE,  IntOption) ;        -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,   5, "ARCACHE") ;
    GetAxi4Options(ManagerRec, ARQOS,    IntOption) ;        -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,   6, "ARQOS") ;
    GetAxi4Options(ManagerRec, ARREGION, IntOption) ;        -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,   7, "ARREGION") ;
    GetAxi4Options(ManagerRec, ARUSER,   IntOption) ;        -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,   8, "ARUSER") ;  

    log(TbManagerID, "Checking IF Parameters for Manager READ DATA") ;
    GetAxi4Options(ManagerRec, RRESP,    IntOption) ;        -- config:  2 bits
    AffirmIfEqual(TbManagerID, IntOption,   1, "RRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ManagerRec, RID,      IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,   9, "RID") ;  
    GetAxi4Options(ManagerRec, RUSER,    IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,  10, "RUSER") ;  

    --------------------------------  Do Reads #2
    WaitForBarrier(RunTest) ;
    log(TbManagerID, "Read with parameters setting #2") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" + 256 ; 
    Data := X"0000_0000" + 256 ; 
    ReadCheck(ManagerRec, Addr,    Data) ;
    ReadCheck(ManagerRec, Addr+4,  Data+1) ;
--!!    ReadBurst(ManagerRec, Addr + 16, 8) ;
--!!    CheckBurstIncrement(ReadBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
    
    
    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Read Test 3.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #3
    log(TbManagerID, "Set Read parameters #3") ;
    SetAxi4Options(ManagerRec, ARBURST,   1) ;        -- 2 bits (fixed, incr, wrap, none)
    SetAxi4Options(ManagerRec, ARLOCK,    0) ;        -- std_logic
    ------ 
    SetAxi4Options(ManagerRec, ARPROT,    2) ;        -- 3 bits
    SetAxi4Options(ManagerRec, ARID,     10) ;        -- config:  8 bits
    SetAxi4Options(ManagerRec, ARCACHE,  11) ;        -- 4 bits
    SetAxi4Options(ManagerRec, ARQOS,    12) ;        -- 4 bits
    SetAxi4Options(ManagerRec, ARREGION, 13) ;        -- 4 bits
    SetAxi4Options(ManagerRec, ARUSER,   14) ;        -- config: 8 bits

    log(TbManagerID, "Checking IF Parameters for Manager READ DATA") ;
    SetAxi4Options(ManagerRec, RRESP,     2) ;        -- config:  2 bits
    SetAxi4Options(ManagerRec, RID,      15) ;        -- config:  8 bits
    SetAxi4Options(ManagerRec, RUSER,    16) ;        -- config:  8 bits
    
    --------------------------------  Get and Check #3
    log(TbManagerID, "Checking IF Parameters for Read Address") ;
    GetAxi4Options(ManagerRec, ARBURST,  IntOption) ;        -- 2 bits (fixed, incr, wrap, none)
    AffirmIfEqual(TbManagerID, IntOption,   1, "ARBURST") ;  -- INCR
    GetAxi4Options(ManagerRec, ARLOCK,   IntOption) ;        -- std_logic
    AffirmIfEqual(TbManagerID, IntOption,   0, "ARLOCK") ;
    ------ 
    GetAxi4Options(ManagerRec, ARPROT,   IntOption) ;        -- 3 bits
    AffirmIfEqual(TbManagerID, IntOption,   2, "ARPROT") ;
    GetAxi4Options(ManagerRec, ARID,     IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,  10, "ARID") ;  
    GetAxi4Options(ManagerRec, ARCACHE,  IntOption) ;        -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,  11, "ARCACHE") ;
    GetAxi4Options(ManagerRec, ARQOS,    IntOption) ;        -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,  12, "ARQOS") ;
    GetAxi4Options(ManagerRec, ARREGION, IntOption) ;        -- 4 bits
    AffirmIfEqual(TbManagerID, IntOption,  13, "ARREGION") ;
    GetAxi4Options(ManagerRec, ARUSER,   IntOption) ;        -- config: 8 bits
    AffirmIfEqual(TbManagerID, IntOption,  14, "ARUSER") ;  

    log(TbManagerID, "Checking IF Parameters for Manager READ DATA") ;
    GetAxi4Options(ManagerRec, RRESP,    IntOption) ;        -- config:  2 bits
    AffirmIfEqual(TbManagerID, IntOption,   2, "RRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(ManagerRec, RID,      IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,  15, "RID") ;  
    GetAxi4Options(ManagerRec, RUSER,    IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbManagerID, IntOption,  16, "RUSER") ; 
    
    --------------------------------  Do Reads #3
    WaitForBarrier(RunTest) ;
    log(TbManagerID, "Read with parameters setting #3") ;
    increment(TransactionCount) ;
    Addr := Addr + 256 ; 
    Data := Data + 256 ; 
    ReadCheck(ManagerRec, Addr,    Data) ;
    ReadCheck(ManagerRec, Addr+4,  Data+1) ;
--!!    ReadBurst(ManagerRec, Addr + 16, 8) ;
--!!    CheckBurstIncrement(ReadBurstFifo, to_integer(DATA)+16, 8, DATA_WIDTH) ;
    
    
    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc ;
  
  
  ------------------------------------------------------------
  -- SubordinateProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  SubordinateProc : process
    variable Addr, RxAddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data, RxData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
    variable IntOption : integer ; 
  begin
    wait for 0 ns ; 
    wait for 1 ns ; -- Allow default checks in Manager to happen first
    
------------------------------------------------------  Check Defaults
    --------------------------------  Get and Check Defaults - Write
    log(TbSubordinateID, "Checking IF Parameters for Subordinate Write Response") ;
    GetAxi4Options(SubordinateRec, BRESP, IntOption) ;       -- config:  2 bits
    AffirmIfEqual(TbSubordinateID, IntOption, 0, "BRESP") ;      -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(SubordinateRec, BID, IntOption) ;         -- config:  8 bits
    AffirmIfEqual(TbSubordinateID, IntOption,   0, "BID") ;  
    GetAxi4Options(SubordinateRec, BUSER, IntOption) ;       -- config: 8 bits
    AffirmIfEqual(TbSubordinateID, IntOption, 0, "BUSER") ;  

    --------------------------------  Do Writes #1
    WaitForBarrier(RunTest) ;
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    GetWrite(SubordinateRec, RxAddr, RxData) ;
    AffirmIfEqual(RxAddr, Addr, "Subordinate Write Addr: ") ;
    AffirmIfEqual(RxData, Data, "Subordinate Write Data: ") ;
    GetWrite(SubordinateRec, RxAddr, RxData) ;
    AffirmIfEqual(RxAddr, Addr+4, "Subordinate Write Addr: ") ;
    AffirmIfEqual(RxData, Data+1, "Subordinate Write Data: ") ;
    

------------------------------------------------------  Write Test 2.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    wait for 1 ns ; 
    --------------------------------  Set #2
    SetAxi4Options(SubordinateRec, BRESP,  1) ;      -- config:  2 bits
    SetAxi4Options(SubordinateRec, BID,   21) ;      -- config:  8 bits
    SetAxi4Options(SubordinateRec, BUSER, 22) ;      -- config:  8 bits
    
    --------------------------------  Get and Check #2
    GetAxi4Options(SubordinateRec, BRESP, IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbSubordinateID, IntOption,  1, "BRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(SubordinateRec, BID, IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbSubordinateID, IntOption,   21, "BID") ;  
    GetAxi4Options(SubordinateRec, BUSER, IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbSubordinateID, IntOption, 22, "BUSER") ;  
    
    --------------------------------  Do Writes #2
    WaitForBarrier(RunTest) ;
    Addr := Addr + 256 ; 
    Data := Data + 256 ; 
    GetWrite(SubordinateRec, RxAddr, RxData) ;
    AffirmIfEqual(RxAddr, Addr, "Subordinate Write Addr: ") ;
    AffirmIfEqual(RxData, Data, "Subordinate Write Data: ") ;
    GetWrite(SubordinateRec, RxAddr, RxData) ;
    AffirmIfEqual(RxAddr, Addr+4, "Subordinate Write Addr: ") ;
    AffirmIfEqual(RxData, Data+1, "Subordinate Write Data: ") ;

------------------------------------------------------  Write Test 3.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    wait for 1 ns ; 
    --------------------------------  Set #3
    SetAxi4Options(SubordinateRec, BRESP,  2) ;      -- config:  2 bits
    SetAxi4Options(SubordinateRec, BID,   27) ;      -- config:  8 bits
    SetAxi4Options(SubordinateRec, BUSER, 28) ;      -- config:  8 bits
    
    --------------------------------  Get and Check #3
    GetAxi4Options(SubordinateRec, BRESP, IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbSubordinateID, IntOption,  2, "BRESP") ;    -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(SubordinateRec, BID, IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbSubordinateID, IntOption,   27, "BID") ;  
    GetAxi4Options(SubordinateRec, BUSER, IntOption) ;      -- config:  8 bits
    AffirmIfEqual(TbSubordinateID, IntOption, 28, "BUSER") ;  
    
    --------------------------------  Do Writes #3
    WaitForBarrier(RunTest) ;
    Addr := Addr + 256 ; 
    Data := Data + 256 ; 
    GetWrite(SubordinateRec, RxAddr, RxData) ;
    AffirmIfEqual(RxAddr, Addr, "Subordinate Write Addr: ") ;
    AffirmIfEqual(RxData, Data, "Subordinate Write Data: ") ;
    GetWrite(SubordinateRec, RxAddr, RxData) ;
    AffirmIfEqual(RxAddr, Addr+4, "Subordinate Write Addr: ") ;
    AffirmIfEqual(RxData, Data+1, "Subordinate Write Data: ") ;


--  ==================================================  Read Tests
    WaitForBarrier(Sync) ;
    wait for 1 ns ; -- Allow default checks in Manager to happen first
    
------------------------------------------------------  Check Defaults
    --------------------------------  Get and Check Defaults - Read
    log(TbSubordinateID, "Checking IF Parameters for Subordinate Read Data") ;
    GetAxi4Options(SubordinateRec, RRESP, IntOption) ;      -- config:  2 bits
    AffirmIfEqual(TbSubordinateID, IntOption, 0, "RRESP") ;     -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(SubordinateRec, RID, IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbSubordinateID, IntOption, 0, "RID") ;  
    GetAxi4Options(SubordinateRec, RUSER, IntOption) ;      -- config: 8 bits
    AffirmIfEqual(TbSubordinateID, IntOption, 0, "RUSER") ;  
    
    --------------------------------  Do Reads #1
    WaitForBarrier(RunTest) ;
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ;
    SendRead(SubordinateRec, RxAddr, Data) ; 
    AffirmIfEqual(RxAddr, Addr, "Subordinate Read Addr: ") ;
    SendRead(SubordinateRec, RxAddr, Data+1) ; 
    AffirmIfEqual(RxAddr, Addr+4, "Subordinate Read Addr: ") ;

------------------------------------------------------  Read Test 2.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    wait for 1 ns ; 
    --------------------------------  Set #2
    SetAxi4Options(SubordinateRec, RRESP,  1) ;        -- config:  2 bits
    SetAxi4Options(SubordinateRec, RID,    9) ;        -- config:  8 bits
    SetAxi4Options(SubordinateRec, RUSER, 10) ;        -- config:  8 bits

    --------------------------------  Get and Check #2
    GetAxi4Options(SubordinateRec, RRESP, IntOption) ;        -- config:  2 bits
    AffirmIfEqual(TbSubordinateID, IntOption,  1, "RRESP") ;  -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(SubordinateRec, RID, IntOption) ;          -- config:  8 bits
    AffirmIfEqual(TbSubordinateID, IntOption,  9, "RID") ;  
    GetAxi4Options(SubordinateRec, RUSER, IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbSubordinateID, IntOption, 10, "RUSER") ;  
    
    --------------------------------  Do Reads #2
    WaitForBarrier(RunTest) ;
    Addr := Addr + 256 ; 
    Data := Data + 256 ; 
    SendRead(SubordinateRec, RxAddr, Data) ; 
    AffirmIfEqual(RxAddr, Addr, "Subordinate Read Addr: ") ;
    SendRead(SubordinateRec, RxAddr, Data+1) ; 
    AffirmIfEqual(RxAddr, Addr+4, "Subordinate Read Addr: ") ;

------------------------------------------------------  Read Test 3.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    wait for 1 ns ; 
    --------------------------------  Set #3
    SetAxi4Options(SubordinateRec, RRESP,  2) ;        -- config:  2 bits
    SetAxi4Options(SubordinateRec, RID,   15) ;        -- config:  8 bits
    SetAxi4Options(SubordinateRec, RUSER, 16) ;        -- config:  8 bits

    --------------------------------  Get and Check #3
    GetAxi4Options(SubordinateRec, RRESP, IntOption) ;        -- config:  2 bits
    AffirmIfEqual(TbSubordinateID, IntOption,  2, "RRESP") ;  -- (OK, EXOK, SLVERR, DECERR)
    GetAxi4Options(SubordinateRec, RID, IntOption) ;          -- config:  8 bits
    AffirmIfEqual(TbSubordinateID, IntOption, 15, "RID") ;  
    GetAxi4Options(SubordinateRec, RUSER, IntOption) ;        -- config:  8 bits
    AffirmIfEqual(TbSubordinateID, IntOption, 16, "RUSER") ;  

    --------------------------------  Do Reads #3
    WaitForBarrier(RunTest) ;
    Addr := Addr + 256 ; 
    Data := Data + 256 ; 
    SendRead(SubordinateRec, RxAddr, Data) ; 
    AffirmIfEqual(RxAddr, Addr, "Subordinate Read Addr: ") ;
    SendRead(SubordinateRec, RxAddr, Data+1) ; 
    AffirmIfEqual(RxAddr, Addr+4, "Subordinate Read Addr: ") ;


    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;

end AxiIfOptionsManagerSubordinate ;

Configuration TbAxi4_AxiIfOptionsManagerSubordinate of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiIfOptionsManagerSubordinate) ; 
    end for ; 
  end for ; 
end TbAxi4_AxiIfOptionsManagerSubordinate ; 
--
--  File Name:         TbAxi4_TimeOut.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Test transaction source
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    05/2018   2018       Initial revision
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

architecture TimeOut of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
  signal TestPhaseStart : integer_barrier := 1 ;
  signal TbSuperID : AlertLogIDType ; 
  signal TbMinionID  : AlertLogIDType ; 
  
  signal ExpectedErrors : AlertCountType ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_TimeOut") ;
    TbSuperID <= GetAlertLogID("TB Super Proc") ;
    TbMinionID  <= GetAlertLogID("TB Minion Proc") ;
    SetLogEnable(PASSED, TRUE) ;      -- Enable PASSED logs
    SetLogEnable(INFO,   TRUE) ;      -- Enable INFO logs
    SetLogEnable(DEBUG,  TRUE) ;      -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    SetAlertLogJustify ;
    TranscriptOpen("./results/TbAxi4_TimeOut.txt") ;
--    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;
    SetAlertStopCount(FAILURE, integer'right) ;  -- Allow up to 2 FAILURES

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4_TimeOut.txt", "../sim_shared/validated_results/TbAxi4_TimeOut.txt", "") ; 
    
    print("") ;
    ReportAlerts(ExternalErrors => -ExpectedErrors) ; 
    print("") ;
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- AxiSuperProc
  --   Generate transactions for AxiSuper
  ------------------------------------------------------------
  AxiSuperProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable ReadData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
    variable ErrorsInjected : AlertCountType ; 
    variable PreviousErrorCount : AlertCountType ; 
  begin
    wait until nReset = '1' ;  
    WaitForClock(AxiSuperTransRec, 2) ; 
    
    PreviousErrorCount := GetAlertCount ; 

WaitForBarrier(TestPhaseStart) ;
log(TbSuperID, "Write Address Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    WaitForClock(AxiSuperTransRec, 2) ;  -- Allow Model Options to Set.
    Write(AxiSuperTransRec, X"0001_0010",  X"0001_0010") ;  -- Pass
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, WRITE_ADDRESS_READY_TIME_OUT, 5) ;
    Write(AxiSuperTransRec, X"BAD0_0010",  X"BAD0_0010") ;  -- Write Address Fail
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, WRITE_ADDRESS_READY_TIME_OUT, 10) ;
    Write(AxiSuperTransRec, X"0002_0020",  X"0002_0020") ;  -- Pass
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, WRITE_ADDRESS_READY_TIME_OUT, 5) ;
    Write(AxiSuperTransRec, X"BAD0_0020",  X"BAD0_0020") ;  -- Write Address Fail
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, WRITE_ADDRESS_READY_TIME_OUT, 25) ;
    Write(AxiSuperTransRec, X"0003_0030",  X"0003_0030") ;  -- Pass
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    ErrorsInjected    := (FAILURE => 4, ERROR => 0, WARNING => 0) ;
    ExpectedErrors    <= ErrorsInjected ; 

    ReportNonZeroAlerts ;
    print("") ; 
    log(TbSuperID, "Removed Expected Errors from This Stage.") ;
    ReportAlerts(ExternalErrors => - (PreviousErrorCount + ErrorsInjected)) ; 
    print("") ;  print("") ;  
    
    PreviousErrorCount := GetAlertCount ; 
    
WaitForBarrier(TestPhaseStart) ;
log(TbSuperID, "Write DATA Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    WaitForClock(AxiSuperTransRec, 2) ;  -- Allow model options to set.
    Write(AxiSuperTransRec, X"0001_0110",  X"0001_0110") ;  -- Pass
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  

    SetModelOptions(AxiSuperTransRec, WRITE_DATA_READY_TIME_OUT, 5) ;
    Write(AxiSuperTransRec, X"BAD0_0110",  X"BAD0_0110") ;  -- Write Data Fail
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, WRITE_DATA_READY_TIME_OUT, 10) ;
    Write(AxiSuperTransRec, X"0002_0120",  X"0002_0120") ;  -- Pass
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, WRITE_DATA_READY_TIME_OUT, 5) ;
    Write(AxiSuperTransRec, X"BAD0_0120",  X"BAD0_0120") ;  -- Write DATA Fail
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, WRITE_DATA_READY_TIME_OUT, 25) ;
    Write(AxiSuperTransRec, X"0003_0130",  X"0003_0130") ;  -- Pass
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  

    ErrorsInjected    := (FAILURE => 4, ERROR => 0, WARNING => 0) ;
    ExpectedErrors    <= ExpectedErrors + ErrorsInjected ; 

    ReportNonZeroAlerts ;
    print("") ; 
    log(TbSuperID, "Removed Expected Errors from This Stage.") ;
    ReportAlerts(ExternalErrors => - (PreviousErrorCount + ErrorsInjected)) ; 
    print("") ;  print("") ;  
    
    PreviousErrorCount := GetAlertCount ; 
    
WaitForBarrier(TestPhaseStart) ;
log(TbSuperID, "Write Response Ready TimeOut test.  Trigger Ready TimeOut twice.") ;

    SetModelOptions(AxiSuperTransRec, WRITE_RESPONSE_READY_DELAY_CYCLES, 7) ;
    SetModelOptions(AxiSuperTransRec, WRITE_RESPONSE_READY_BEFORE_VALID, FALSE) ;

    WaitForClock(AxiSuperTransRec, 2) ;  -- Allow model options to set.
    Write(AxiSuperTransRec, X"0001_0210",  X"0001_0210") ;  -- Pass
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  

    Write(AxiSuperTransRec, X"BAD0_0210",  X"BAD0_0210") ;  -- Write Data Fail
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    Write(AxiSuperTransRec, X"0002_0220",  X"0002_0220") ;  -- Pass
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    Write(AxiSuperTransRec, X"BAD0_0220",  X"BAD0_0220") ;  -- Write DATA Fail
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, WRITE_RESPONSE_READY_DELAY_CYCLES, 0) ;
    SetModelOptions(AxiSuperTransRec, WRITE_RESPONSE_READY_BEFORE_VALID, FALSE) ;

    SetModelOptions(AxiSuperTransRec, WRITE_DATA_READY_TIME_OUT, 25) ;
    Write(AxiSuperTransRec, X"0003_0230",  X"0003_0230") ;  -- Pass
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  

    ErrorsInjected    := (FAILURE => 4, ERROR => 2, WARNING => 0) ;
    ExpectedErrors    <= ExpectedErrors + ErrorsInjected ; 

    ReportNonZeroAlerts ;
    print("") ; 
    log(TbSuperID, "Removed Expected Errors from This Stage.") ;
    ReportAlerts(ExternalErrors => - (PreviousErrorCount + ErrorsInjected)) ; 
    print("") ;  print("") ;  
    
    PreviousErrorCount := GetAlertCount ; 
    
WaitForBarrier(TestPhaseStart) ;
log(TbSuperID, "Read Address Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    WaitForClock(AxiSuperTransRec, 2) ;  -- Allow Model Options to Set.
    Read(AxiSuperTransRec, X"0001_0010",  ReadData) ;  -- Pass
    AffirmIfEqual(TbSuperID, ReadData, X"0001_0010", "AXI Super Read Data: ") ;
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, READ_ADDRESS_READY_TIME_OUT, 5) ;
    Read(AxiSuperTransRec, X"BAD0_0010",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbSuperID, ReadData, X"BAD0_0010", "AXI Super Read Data: ") ;
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, READ_ADDRESS_READY_TIME_OUT, 10) ;
    Read(AxiSuperTransRec, X"0002_0020",  ReadData) ;  -- Pass
    AffirmIfEqual(TbSuperID, ReadData, X"0002_0020", "AXI Super Read Data: ") ;
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, READ_ADDRESS_READY_TIME_OUT, 5) ;
    Read(AxiSuperTransRec, X"BAD0_0020",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbSuperID, ReadData, X"BAD0_0020", "AXI Super Read Data: ") ;
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, READ_ADDRESS_READY_TIME_OUT, 25) ;
    Read(AxiSuperTransRec, X"0003_0030",  ReadData) ;  -- Pass
    AffirmIfEqual(TbSuperID, ReadData, X"0003_0030", "AXI Super Read Data: ") ;
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    ErrorsInjected    := (FAILURE => 4, ERROR => 0, WARNING => 0) ;
    ExpectedErrors    <= ExpectedErrors + ErrorsInjected ; 

    ReportNonZeroAlerts ;
    print("") ; 
    log(TbSuperID, "Removed Expected Errors from This Stage.") ;
    ReportAlerts(ExternalErrors => - (PreviousErrorCount + ErrorsInjected)) ; 
    print("") ;  print("") ;  
    
    PreviousErrorCount := GetAlertCount ; 
    
WaitForBarrier(TestPhaseStart) ;
log(TbSuperID, "Read Data Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiSuperTransRec, READ_DATA_READY_DELAY_CYCLES, 7) ;
    SetModelOptions(AxiSuperTransRec, READ_DATA_READY_BEFORE_VALID, FALSE) ;

    WaitForClock(AxiSuperTransRec, 2) ;  -- Allow Model Options to Set.
    Read(AxiSuperTransRec, X"0001_0010",  ReadData) ;  -- Pass
    AffirmIfEqual(TbSuperID, ReadData, X"0001_0010", "AXI Super Read Data: ") ;
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    Read(AxiSuperTransRec, X"BAD0_0010",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbSuperID, ReadData, not(X"BAD0_0010"), "AXI Super Read Data: ") ;
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    Read(AxiSuperTransRec, X"0002_0020",  ReadData) ;  -- Pass
    AffirmIfEqual(TbSuperID, ReadData, X"0002_0020", "AXI Super Read Data: ") ;
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    Read(AxiSuperTransRec, X"BAD0_0020",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbSuperID, ReadData, not(X"BAD0_0020"), "AXI Super Read Data: ") ;
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiSuperTransRec, READ_DATA_READY_DELAY_CYCLES, 0) ;
    SetModelOptions(AxiSuperTransRec, READ_DATA_READY_BEFORE_VALID, TRUE) ;

    Read(AxiSuperTransRec, X"0003_0030",  ReadData) ;  -- Pass
    AffirmIfEqual(TbSuperID, ReadData, X"0003_0030", "AXI Super Read Data: ") ;
    WaitForClock(AxiSuperTransRec, 10) ; 
    print("") ;  print("") ;  
    
    ErrorsInjected    := (FAILURE => 4, ERROR => 2, WARNING => 0) ;
    ExpectedErrors    <= ExpectedErrors + ErrorsInjected ; 

    ReportNonZeroAlerts ;
    print("") ; 
    log(TbSuperID, "Removed Expected Errors from This Stage.") ;
    ReportAlerts(ExternalErrors => - (PreviousErrorCount + ErrorsInjected)) ; 
    print("") ;  print("") ;  
    
    PreviousErrorCount := GetAlertCount ; 
    
--  WaitForBarrier(TestPhaseStart) ;
    log(TbSuperID, "Removed Expected Errors for Whole Test.") ;
    

--! TODO move these to the appropriate test.
--!      Must prove that each of these settings impacts the intended item
--       Setting all at the beginning can hide issues.
--       There is a delay of one cycle before these are effective, so it requires
--       One "practice cycle" before doing the test cycles  
--    SetModelOptions(AxiSuperTransRec, READ_DATA_READY_DELAY_CYCLES, 7) ;
--    SetModelOptions(AxiSuperTransRec, READ_DATA_READY_BEFORE_VALID, FALSE) ;

    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(AxiSuperTransRec, 20) ;  
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiSuperProc ;


  ------------------------------------------------------------
  -- AxiMinionProc
  --   Generate transactions for AxiMinion
  ------------------------------------------------------------
  AxiMinionProc : process
    variable Addr, ExpAddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data, ExpData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    -- Must set Minion options before start otherwise, ready will be active on first cycle.
    
    -- test preparation
    
-- Start test phase 1:  Write Address
WaitForBarrier(TestPhaseStart) ;
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiMinionTransRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 7) ;
    SetModelOptions(AxiMinionTransRec, WRITE_ADDRESS_READY_BEFORE_VALID, FALSE) ;

    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Pass.  Ready Delay still = 0.
    AffirmIfEqual(TbMinionID, Addr, X"0001_0010", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0001_0010", "Minion Write Data: ") ;

    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbMinionID, Addr, X"BAD0_0011", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"BAD0_0010", "Minion Write Data: ") ;
    
    GetWrite(AxiMinionTransRec, Addr, Data) ; -- Pass
    AffirmIfEqual(TbMinionID, Addr, X"0002_0020", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0002_0020", "Minion Write Data: ") ;
    
    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbMinionID, Addr, X"BAD0_0021", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"BAD0_0020", "Minion Write Data: ") ;
    
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiMinionTransRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 0) ;
    SetModelOptions(AxiMinionTransRec, WRITE_ADDRESS_READY_BEFORE_VALID, TRUE) ;

    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Pass
    AffirmIfEqual(TbMinionID, Addr, X"0003_0030", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0003_0030", "Minion Write Data: ") ;
    

-- Start test phase 2:  Write Data
WaitForBarrier(TestPhaseStart) ;

    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiMinionTransRec, WRITE_DATA_READY_DELAY_CYCLES, 7) ;
    SetModelOptions(AxiMinionTransRec, WRITE_DATA_READY_BEFORE_VALID, FALSE) ;

    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Pass.  Ready Delay still = 0.
    AffirmIfEqual(TbMinionID, Addr, X"0001_0110", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0001_0110", "Minion Write Data: ") ;

    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbMinionID, Addr, X"BAD0_0110", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, not(X"BAD0_0110"), "Minion Write Data: ") ;
    
    GetWrite(AxiMinionTransRec, Addr, Data) ; -- Pass
    AffirmIfEqual(TbMinionID, Addr, X"0002_0120", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0002_0120", "Minion Write Data: ") ;
    
    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbMinionID, Addr, X"BAD0_0120", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, not(X"BAD0_0120"), "Minion Write Data: ") ;
    
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiMinionTransRec, WRITE_DATA_READY_DELAY_CYCLES, 0) ;
    SetModelOptions(AxiMinionTransRec, WRITE_DATA_READY_BEFORE_VALID, TRUE) ;

    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Pass
    AffirmIfEqual(TbMinionID, Addr, X"0003_0130", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0003_0130", "Minion Write Data: ") ;
    

-- Start test phase 3:  Write Response
WaitForBarrier(TestPhaseStart) ;
    
    -- Warning:  it takes one operation before these take impact
    -- SetModelOptions(AxiSuperTransRec, WRITE_RESPONSE_READY_DELAY_CYCLES, 7) ;
    -- SetModelOptions(AxiSuperTransRec, WRITE_RESPONSE_READY_BEFORE_VALID, FALSE) ;

    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Pass.  Ready Delay still = 0.
    AffirmIfEqual(TbMinionID, Addr, X"0001_0210", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0001_0210", "Minion Write Data: ") ;

    SetModelOptions(AxiMinionTransRec, WRITE_RESPONSE_READY_TIME_OUT, 5) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbMinionID, Addr, X"BAD0_0210", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"BAD0_0210", "Minion Write Data: ") ;
    
    SetModelOptions(AxiMinionTransRec, WRITE_RESPONSE_READY_TIME_OUT, 10) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ; -- Pass
    AffirmIfEqual(TbMinionID, Addr, X"0002_0220", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0002_0220", "Minion Write Data: ") ;
    
    SetModelOptions(AxiMinionTransRec, WRITE_RESPONSE_READY_TIME_OUT, 5) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbMinionID, Addr, X"BAD0_0220", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"BAD0_0220", "Minion Write Data: ") ;
    
    SetModelOptions(AxiMinionTransRec, WRITE_RESPONSE_READY_TIME_OUT, 10) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;  -- Pass
    AffirmIfEqual(TbMinionID, Addr, X"0003_0230", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0003_0230", "Minion Write Data: ") ;
    
    
-- Start test phase 4: Read Address
WaitForBarrier(TestPhaseStart) ;
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiMinionTransRec, READ_ADDRESS_READY_DELAY_CYCLES, 7) ;
    SetModelOptions(AxiMinionTransRec, READ_ADDRESS_READY_BEFORE_VALID, FALSE) ;

    SendRead(AxiMinionTransRec, Addr, X"0001_0010") ; 
    AffirmIfEqual(TbMinionID, Addr, X"0001_0010", "Minion Read Addr: ") ;

    SendRead(AxiMinionTransRec, Addr, X"BAD0_0010") ; -- Fail
    AffirmIfEqual(TbMinionID, Addr, X"BAD0_0011", "Minion Read Addr: ") ;
    
    SendRead(AxiMinionTransRec, Addr, X"0002_0020") ; -- Pass
    AffirmIfEqual(TbMinionID, Addr, X"0002_0020", "Minion Read Addr: ") ;

    SendRead(AxiMinionTransRec, Addr, X"BAD0_0020") ; -- Fail
    AffirmIfEqual(TbMinionID, Addr, X"BAD0_0021", "Minion Read Addr: ") ;
    
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiMinionTransRec, READ_ADDRESS_READY_DELAY_CYCLES, 0) ;
    SetModelOptions(AxiMinionTransRec, READ_ADDRESS_READY_BEFORE_VALID, TRUE) ;

    SendRead(AxiMinionTransRec, Addr, X"0003_0030") ; -- Pass
    AffirmIfEqual(TbMinionID, Addr, X"0003_0030", "Minion Read Addr: ") ;

-- Start test phase 5: Read Data
WaitForBarrier(TestPhaseStart) ;

    SendRead(AxiMinionTransRec, Addr, X"0001_0010") ; 
    AffirmIfEqual(TbMinionID, Addr, X"0001_0010", "Minion Read Addr: ") ;

    SetModelOptions(AxiMinionTransRec, READ_DATA_READY_TIME_OUT, 5) ;
    SendRead(AxiMinionTransRec, Addr, X"BAD0_0010") ; -- Fail
    AffirmIfEqual(TbMinionID, Addr, X"BAD0_0010", "Minion Read Addr: ") ;
    
    SetModelOptions(AxiMinionTransRec, READ_DATA_READY_TIME_OUT, 10) ;
    SendRead(AxiMinionTransRec, Addr, X"0002_0020") ; -- Pass
    AffirmIfEqual(TbMinionID, Addr, X"0002_0020", "Minion Read Addr: ") ;

    SetModelOptions(AxiMinionTransRec, READ_DATA_READY_TIME_OUT, 5) ;
    SendRead(AxiMinionTransRec, Addr, X"BAD0_0020") ; -- Fail
    AffirmIfEqual(TbMinionID, Addr, X"BAD0_0020", "Minion Read Addr: ") ;
    
    SetModelOptions(AxiMinionTransRec, READ_DATA_READY_TIME_OUT, 25) ;
    SendRead(AxiMinionTransRec, Addr, X"0003_0030") ; -- Pass
    AffirmIfEqual(Addr, X"0003_0030", "Minion Read Addr: ") ;

    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(AxiMinionTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiMinionProc ;


end TimeOut ;

Configuration TbAxi4_TimeOut of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(TimeOut) ; 
    end for ; 
  end for ; 
end TbAxi4_TimeOut ; 
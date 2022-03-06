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

architecture TimeOut of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
  signal TestPhaseStart : integer_barrier := 1 ;
  signal TbMasterID : AlertLogIDType ; 
  signal TbResponderID  : AlertLogIDType ; 
  
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
    TbMasterID <= GetAlertLogID("TB Master Proc") ;
    TbResponderID  <= GetAlertLogID("TB Responder Proc") ;
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

    EndOfTestReports(ExternalErrors => -ExpectedErrors) ; 
    std.env.stop(SumAlertCount(GetAlertCount - ExpectedErrors)) ;
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- MasterProc
  --   Generate transactions for AxiMaster
  ------------------------------------------------------------
  MasterProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable ReadData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
    variable ErrorsInjected : AlertCountType ; 
    variable PreviousErrorCount : AlertCountType ; 
  begin
    wait until nReset = '1' ;  
    WaitForClock(ManagerRec, 2) ; 
    
    PreviousErrorCount := GetAlertCount ; 

WaitForBarrier(TestPhaseStart) ;
log(TbMasterID, "Write Address Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    WaitForClock(ManagerRec, 2) ;  -- Allow Model Options to Set.
    Write(ManagerRec, X"0001_0010",  X"0001_0010") ;  -- Pass
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, WRITE_ADDRESS_READY_TIME_OUT, 5) ;
    Write(ManagerRec, X"BAD0_0010",  X"BAD0_0010") ;  -- Write Address Fail
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, WRITE_ADDRESS_READY_TIME_OUT, 10) ;
    Write(ManagerRec, X"0002_0020",  X"0002_0020") ;  -- Pass
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, WRITE_ADDRESS_READY_TIME_OUT, 5) ;
    Write(ManagerRec, X"BAD0_0020",  X"BAD0_0020") ;  -- Write Address Fail
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, WRITE_ADDRESS_READY_TIME_OUT, 25) ;
    Write(ManagerRec, X"0003_0030",  X"0003_0030") ;  -- Pass
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    ErrorsInjected    := (FAILURE => 4, ERROR => 0, WARNING => 0) ;
    ExpectedErrors    <= ErrorsInjected ; 

    ReportNonZeroAlerts ;
    print("") ; 
    log(TbMasterID, "Removed Expected Errors from This Stage.") ;
    ReportAlerts(ExternalErrors => - (PreviousErrorCount + ErrorsInjected)) ; 
    print("") ;  print("") ;  
    
    PreviousErrorCount := GetAlertCount ; 
    
WaitForBarrier(TestPhaseStart) ;
log(TbMasterID, "Write DATA Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    WaitForClock(ManagerRec, 2) ;  -- Allow model options to set.
    Write(ManagerRec, X"0001_0110",  X"0001_0110") ;  -- Pass
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  

    SetAxi4Options(ManagerRec, WRITE_DATA_READY_TIME_OUT, 5) ;
    Write(ManagerRec, X"BAD0_0110",  X"BAD0_0110") ;  -- Write Data Fail
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, WRITE_DATA_READY_TIME_OUT, 10) ;
    Write(ManagerRec, X"0002_0120",  X"0002_0120") ;  -- Pass
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, WRITE_DATA_READY_TIME_OUT, 5) ;
    Write(ManagerRec, X"BAD0_0120",  X"BAD0_0120") ;  -- Write DATA Fail
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, WRITE_DATA_READY_TIME_OUT, 25) ;
    Write(ManagerRec, X"0003_0130",  X"0003_0130") ;  -- Pass
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  

    ErrorsInjected    := (FAILURE => 4, ERROR => 0, WARNING => 0) ;
    ExpectedErrors    <= ExpectedErrors + ErrorsInjected ; 

    ReportNonZeroAlerts ;
    print("") ; 
    log(TbMasterID, "Removed Expected Errors from This Stage.") ;
    ReportAlerts(ExternalErrors => - (PreviousErrorCount + ErrorsInjected)) ; 
    print("") ;  print("") ;  
    
    PreviousErrorCount := GetAlertCount ; 
    
WaitForBarrier(TestPhaseStart) ;
log(TbMasterID, "Write Response Ready TimeOut test.  Trigger Ready TimeOut twice.") ;

    SetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_DELAY_CYCLES, 7) ;
    SetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_BEFORE_VALID, FALSE) ;

    WaitForClock(ManagerRec, 2) ;  -- Allow model options to set.
    Write(ManagerRec, X"0001_0210",  X"0001_0210") ;  -- Pass
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  

    Write(ManagerRec, X"BAD0_0210",  X"BAD0_0210") ;  -- Write Data Fail
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    Write(ManagerRec, X"0002_0220",  X"0002_0220") ;  -- Pass
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    Write(ManagerRec, X"BAD0_0220",  X"BAD0_0220") ;  -- Write DATA Fail
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_DELAY_CYCLES, 0) ;
    SetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_BEFORE_VALID, FALSE) ;

    SetAxi4Options(ManagerRec, WRITE_DATA_READY_TIME_OUT, 25) ;
    Write(ManagerRec, X"0003_0230",  X"0003_0230") ;  -- Pass
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  

    ErrorsInjected    := (FAILURE => 4, ERROR => 2, WARNING => 0) ;
    ExpectedErrors    <= ExpectedErrors + ErrorsInjected ; 

    ReportNonZeroAlerts ;
    print("") ; 
    log(TbMasterID, "Removed Expected Errors from This Stage.") ;
    ReportAlerts(ExternalErrors => - (PreviousErrorCount + ErrorsInjected)) ; 
    print("") ;  print("") ;  
    
    PreviousErrorCount := GetAlertCount ; 
    
WaitForBarrier(TestPhaseStart) ;
log(TbMasterID, "Read Address Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    WaitForClock(ManagerRec, 2) ;  -- Allow Model Options to Set.
    Read(ManagerRec, X"0001_0010",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0001_0010", "AXI Master Read Data: ") ;
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, READ_ADDRESS_READY_TIME_OUT, 5) ;
    Read(ManagerRec, X"BAD0_0010",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbMasterID, ReadData, X"BAD0_0010", "AXI Master Read Data: ") ;
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, READ_ADDRESS_READY_TIME_OUT, 10) ;
    Read(ManagerRec, X"0002_0020",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0002_0020", "AXI Master Read Data: ") ;
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, READ_ADDRESS_READY_TIME_OUT, 5) ;
    Read(ManagerRec, X"BAD0_0020",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbMasterID, ReadData, X"BAD0_0020", "AXI Master Read Data: ") ;
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, READ_ADDRESS_READY_TIME_OUT, 25) ;
    Read(ManagerRec, X"0003_0030",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0003_0030", "AXI Master Read Data: ") ;
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    ErrorsInjected    := (FAILURE => 4, ERROR => 0, WARNING => 0) ;
    ExpectedErrors    <= ExpectedErrors + ErrorsInjected ; 

    ReportNonZeroAlerts ;
    print("") ; 
    log(TbMasterID, "Removed Expected Errors from This Stage.") ;
    ReportAlerts(ExternalErrors => - (PreviousErrorCount + ErrorsInjected)) ; 
    print("") ;  print("") ;  
    
    PreviousErrorCount := GetAlertCount ; 
    
WaitForBarrier(TestPhaseStart) ;
log(TbMasterID, "Read Data Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    -- Warning:  it takes one operation before these take impact
    SetAxi4Options(ManagerRec, READ_DATA_READY_DELAY_CYCLES, 7) ;
    SetAxi4Options(ManagerRec, READ_DATA_READY_BEFORE_VALID, FALSE) ;

    WaitForClock(ManagerRec, 2) ;  -- Allow Model Options to Set.
    Read(ManagerRec, X"0001_0010",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0001_0010", "AXI Master Read Data: ") ;
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    Read(ManagerRec, X"BAD0_0010",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbMasterID, ReadData, not(X"BAD0_0010"), "AXI Master Read Data: ") ;
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    Read(ManagerRec, X"0002_0020",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0002_0020", "AXI Master Read Data: ") ;
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    Read(ManagerRec, X"BAD0_0020",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbMasterID, ReadData, not(X"BAD0_0020"), "AXI Master Read Data: ") ;
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    SetAxi4Options(ManagerRec, READ_DATA_READY_DELAY_CYCLES, 0) ;
    SetAxi4Options(ManagerRec, READ_DATA_READY_BEFORE_VALID, TRUE) ;

    Read(ManagerRec, X"0003_0030",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0003_0030", "AXI Master Read Data: ") ;
    WaitForClock(ManagerRec, 10) ; 
    print("") ;  print("") ;  
    
    ErrorsInjected    := (FAILURE => 4, ERROR => 2, WARNING => 0) ;
    ExpectedErrors    <= ExpectedErrors + ErrorsInjected ; 

    ReportNonZeroAlerts ;
    print("") ; 
    log(TbMasterID, "Removed Expected Errors from This Stage.") ;
    ReportAlerts(ExternalErrors => - (PreviousErrorCount + ErrorsInjected)) ; 
    print("") ;  print("") ;  
    
    PreviousErrorCount := GetAlertCount ; 
    
--  WaitForBarrier(TestPhaseStart) ;
    log(TbMasterID, "Removed Expected Errors for Whole Test.") ;
    

--! TODO move these to the appropriate test.
--!      Must prove that each of these settings impacts the intended item
--       Setting all at the beginning can hide issues.
--       There is a delay of one cycle before these are effective, so it requires
--       One "practice cycle" before doing the test cycles  
--    SetAxi4Options(ManagerRec, READ_DATA_READY_DELAY_CYCLES, 7) ;
--    SetAxi4Options(ManagerRec, READ_DATA_READY_BEFORE_VALID, FALSE) ;

    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 20) ;  
    WaitForBarrier(TestDone) ;
    wait ;
  end process MasterProc ;


  ------------------------------------------------------------
  -- ResponderProc
  --   Generate transactions for AxiResponder
  ------------------------------------------------------------
  ResponderProc : process
    variable Addr, ExpAddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data, ExpData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    -- Must set Responder options before start otherwise, ready will be active on first cycle.
    
    -- test preparation
    
-- Start test phase 1:  Write Address
WaitForBarrier(TestPhaseStart) ;
    -- Warning:  it takes one operation before these take impact
    SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 7) ;
    SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, FALSE) ;

    GetWrite(SubordinateRec, Addr, Data) ;  -- Pass.  Ready Delay still = 0.
    AffirmIfEqual(TbResponderID, Addr, X"0001_0010", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0001_0010", "Responder Write Data: ") ;

    GetWrite(SubordinateRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbResponderID, Addr, X"BAD0_0014", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"BAD0_0010", "Responder Write Data: ") ;
    
    GetWrite(SubordinateRec, Addr, Data) ; -- Pass
    AffirmIfEqual(TbResponderID, Addr, X"0002_0020", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0002_0020", "Responder Write Data: ") ;
    
    GetWrite(SubordinateRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbResponderID, Addr, X"BAD0_0024", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"BAD0_0020", "Responder Write Data: ") ;
    
    -- Warning:  it takes one operation before these take impact
    SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 0) ;
    SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, TRUE) ;

    GetWrite(SubordinateRec, Addr, Data) ;  -- Pass
    AffirmIfEqual(TbResponderID, Addr, X"0003_0030", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0003_0030", "Responder Write Data: ") ;
    

-- Start test phase 2:  Write Data
WaitForBarrier(TestPhaseStart) ;

    -- Warning:  it takes one operation before these take impact
    SetAxi4Options(SubordinateRec, WRITE_DATA_READY_DELAY_CYCLES, 7) ;
    SetAxi4Options(SubordinateRec, WRITE_DATA_READY_BEFORE_VALID, FALSE) ;

    GetWrite(SubordinateRec, Addr, Data) ;  -- Pass.  Ready Delay still = 0.
    AffirmIfEqual(TbResponderID, Addr, X"0001_0110", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0001_0110", "Responder Write Data: ") ;

    GetWrite(SubordinateRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbResponderID, Addr, X"BAD0_0110", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, not(X"BAD0_0110"), "Responder Write Data: ") ;
    
    GetWrite(SubordinateRec, Addr, Data) ; -- Pass
    AffirmIfEqual(TbResponderID, Addr, X"0002_0120", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0002_0120", "Responder Write Data: ") ;
    
    GetWrite(SubordinateRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbResponderID, Addr, X"BAD0_0120", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, not(X"BAD0_0120"), "Responder Write Data: ") ;
    
    -- Warning:  it takes one operation before these take impact
    SetAxi4Options(SubordinateRec, WRITE_DATA_READY_DELAY_CYCLES, 0) ;
    SetAxi4Options(SubordinateRec, WRITE_DATA_READY_BEFORE_VALID, TRUE) ;

    GetWrite(SubordinateRec, Addr, Data) ;  -- Pass
    AffirmIfEqual(TbResponderID, Addr, X"0003_0130", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0003_0130", "Responder Write Data: ") ;
    

-- Start test phase 3:  Write Response
WaitForBarrier(TestPhaseStart) ;
    
    -- Warning:  it takes one operation before these take impact
    -- SetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_DELAY_CYCLES, 7) ;
    -- SetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_BEFORE_VALID, FALSE) ;

    GetWrite(SubordinateRec, Addr, Data) ;  -- Pass.  Ready Delay still = 0.
    AffirmIfEqual(TbResponderID, Addr, X"0001_0210", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0001_0210", "Responder Write Data: ") ;

    SetAxi4Options(SubordinateRec, WRITE_RESPONSE_READY_TIME_OUT, 5) ;
    GetWrite(SubordinateRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbResponderID, Addr, X"BAD0_0210", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"BAD0_0210", "Responder Write Data: ") ;
    
    SetAxi4Options(SubordinateRec, WRITE_RESPONSE_READY_TIME_OUT, 10) ;
    GetWrite(SubordinateRec, Addr, Data) ; -- Pass
    AffirmIfEqual(TbResponderID, Addr, X"0002_0220", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0002_0220", "Responder Write Data: ") ;
    
    SetAxi4Options(SubordinateRec, WRITE_RESPONSE_READY_TIME_OUT, 5) ;
    GetWrite(SubordinateRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbResponderID, Addr, X"BAD0_0220", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"BAD0_0220", "Responder Write Data: ") ;
    
    SetAxi4Options(SubordinateRec, WRITE_RESPONSE_READY_TIME_OUT, 10) ;
    GetWrite(SubordinateRec, Addr, Data) ;  -- Pass
    AffirmIfEqual(TbResponderID, Addr, X"0003_0230", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0003_0230", "Responder Write Data: ") ;
    
    
-- Start test phase 4: Read Address
WaitForBarrier(TestPhaseStart) ;
    -- Warning:  it takes one operation before these take impact
    SetAxi4Options(SubordinateRec, READ_ADDRESS_READY_DELAY_CYCLES, 7) ;
    SetAxi4Options(SubordinateRec, READ_ADDRESS_READY_BEFORE_VALID, FALSE) ;

    SendRead(SubordinateRec, Addr, X"0001_0010") ; 
    AffirmIfEqual(TbResponderID, Addr, X"0001_0010", "Responder Read Addr: ") ;

    SendRead(SubordinateRec, Addr, X"BAD0_0010") ; -- Fail
    AffirmIfEqual(TbResponderID, Addr, X"BAD0_0014", "Responder Read Addr: ") ;
    
    SendRead(SubordinateRec, Addr, X"0002_0020") ; -- Pass
    AffirmIfEqual(TbResponderID, Addr, X"0002_0020", "Responder Read Addr: ") ;

    SendRead(SubordinateRec, Addr, X"BAD0_0020") ; -- Fail
    AffirmIfEqual(TbResponderID, Addr, X"BAD0_0024", "Responder Read Addr: ") ;
    
    -- Warning:  it takes one operation before these take impact
    SetAxi4Options(SubordinateRec, READ_ADDRESS_READY_DELAY_CYCLES, 0) ;
    SetAxi4Options(SubordinateRec, READ_ADDRESS_READY_BEFORE_VALID, TRUE) ;

    SendRead(SubordinateRec, Addr, X"0003_0030") ; -- Pass
    AffirmIfEqual(TbResponderID, Addr, X"0003_0030", "Responder Read Addr: ") ;

-- Start test phase 5: Read Data
WaitForBarrier(TestPhaseStart) ;

    SendRead(SubordinateRec, Addr, X"0001_0010") ; 
    AffirmIfEqual(TbResponderID, Addr, X"0001_0010", "Responder Read Addr: ") ;

    SetAxi4Options(SubordinateRec, READ_DATA_READY_TIME_OUT, 5) ;
    SendRead(SubordinateRec, Addr, X"BAD0_0010") ; -- Fail
    AffirmIfEqual(TbResponderID, Addr, X"BAD0_0010", "Responder Read Addr: ") ;
    
    SetAxi4Options(SubordinateRec, READ_DATA_READY_TIME_OUT, 10) ;
    SendRead(SubordinateRec, Addr, X"0002_0020") ; -- Pass
    AffirmIfEqual(TbResponderID, Addr, X"0002_0020", "Responder Read Addr: ") ;

    SetAxi4Options(SubordinateRec, READ_DATA_READY_TIME_OUT, 5) ;
    SendRead(SubordinateRec, Addr, X"BAD0_0020") ; -- Fail
    AffirmIfEqual(TbResponderID, Addr, X"BAD0_0020", "Responder Read Addr: ") ;
    
    SetAxi4Options(SubordinateRec, READ_DATA_READY_TIME_OUT, 25) ;
    SendRead(SubordinateRec, Addr, X"0003_0030") ; -- Pass
    AffirmIfEqual(Addr, X"0003_0030", "Responder Read Addr: ") ;

    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ResponderProc ;


end TimeOut ;

Configuration TbAxi4_TimeOut of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(TimeOut) ; 
    end for ; 
  end for ; 
end TbAxi4_TimeOut ; 
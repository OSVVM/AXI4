--
--  File Name:         TbAxi4_ReleaseAcquireManager1.vhd
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
--    02/2021   2021.02    Initial revision
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

architecture ReleaseAcquireManager1 of TestCtrl is

  signal Sync1, TestDone : integer_barrier := 1 ;
  signal TbID : AlertLogIDType ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_ReleaseAcquireManager1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    TbID <= GetAlertLogID("Testbench") ;

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_ReleaseAcquireManager1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4_ReleaseAcquireManager1.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_ReleaseAcquireManager1.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- ManagerProc1
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc1 : process
    variable StartTime : time ; 
    variable IntOption  : integer ; 
    variable BoolOption : boolean ; 
  begin
    wait until nReset = '1' ;  
    -- First Alignment to clock
    WaitForClock(ManagerRec, 1) ; 
    StartTime := now ; 
    WaitForClock(ManagerRec, 2) ; 
    AffirmIfEqual(NOW, StartTime + 20 ns, "Expected Completion Time") ;

    -- Setting and checking values set 
    SetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_DELAY_CYCLES, 2) ;
    GetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbID, IntOption, 2, "WRITE_RESPONSE_READY_DELAY_CYCLES") ;
    SetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_BEFORE_VALID, TRUE) ;
    GetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_BEFORE_VALID, BoolOption) ;
    AffirmIfEqual(TbID, BoolOption, TRUE, "WRITE_RESPONSE_READY_BEFORE_VALID") ;

    SetAxi4Options(ManagerRec, READ_DATA_READY_DELAY_CYCLES, 2) ;
    GetAxi4Options(ManagerRec, READ_DATA_READY_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbID, IntOption, 2, "READ_DATA_READY_DELAY_CYCLES") ;
    SetAxi4Options(ManagerRec, READ_DATA_READY_BEFORE_VALID, TRUE) ;
    GetAxi4Options(ManagerRec, READ_DATA_READY_BEFORE_VALID, BoolOption) ;
    AffirmIfEqual(TbID, BoolOption, TRUE, "READ_DATA_READY_BEFORE_VALID") ;

    Write(ManagerRec, X"1000_1000", X"5555_5555" ) ;
    ReadCheck(ManagerRec, X"1000_1000", X"5555_5555" ) ;
    PushBurstIncrement(WriteBurstFifo, 3, 6, AXI_DATA_WIDTH) ;
    WriteBurst(ManagerRec, X"0000_0008", 6) ;
    ReadBurst (ManagerRec, X"0000_0008", 6) ;
    CheckBurstIncrement(ReadBurstFifo, 3, 6, AXI_DATA_WIDTH) ;

    WaitForBarrier(Sync1) ;
    ReleaseTransactionRecord(ManagerRec) ; 
    
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc1 ;
  
  ------------------------------------------------------------
  -- ManagerProc2
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc2 : process
    variable StartTime : time ; 
    variable IntOption  : integer ; 
    variable BoolOption : boolean ; 
  begin
    WaitForBarrier(Sync1) ;
    AcquireTransactionRecord(ManagerRec) ;

    StartTime := now ; 
    WaitForClock(ManagerRec, 1) ; 
    AffirmIfEqual(NOW, StartTime + 10 ns, "Expected Completion Time") ;
    
    -- Setting and checking values set 
    SetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_DELAY_CYCLES, 1) ;
    GetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbID, IntOption, 1, "WRITE_RESPONSE_READY_DELAY_CYCLES") ;
    SetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_BEFORE_VALID, FALSE) ;
    GetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_BEFORE_VALID, BoolOption) ;
    AffirmIfEqual(TbID, BoolOption, FALSE, "WRITE_RESPONSE_READY_BEFORE_VALID") ;

    SetAxi4Options(ManagerRec, READ_DATA_READY_DELAY_CYCLES, 1) ;
    GetAxi4Options(ManagerRec, READ_DATA_READY_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbID, IntOption, 1, "READ_DATA_READY_DELAY_CYCLES") ;
    SetAxi4Options(ManagerRec, READ_DATA_READY_BEFORE_VALID, FALSE) ;
    GetAxi4Options(ManagerRec, READ_DATA_READY_BEFORE_VALID, BoolOption) ;
    AffirmIfEqual(TbID, BoolOption, FALSE, "READ_DATA_READY_BEFORE_VALID") ;
    

    Write(ManagerRec, X"1000_2000", X"AAAA_AAAA" ) ;
    ReadCheck(ManagerRec, X"1000_2000", X"AAAA_AAAA" ) ;
    PushBurstIncrement(WriteBurstFifo, 10, 4, AXI_DATA_WIDTH) ;
    WriteBurst(ManagerRec, X"0000_1008", 4) ;
    ReadBurst (ManagerRec, X"0000_1008", 4) ;
    CheckBurstIncrement(ReadBurstFifo, 10, 4, AXI_DATA_WIDTH) ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc2 ;

  ------------------------------------------------------------
  -- SubordinateProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  SubordinateProc : process
  begin
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;


end ReleaseAcquireManager1 ;

Configuration TbAxi4_ReleaseAcquireManager1 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ReleaseAcquireManager1) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_ReleaseAcquireManager1 ; 
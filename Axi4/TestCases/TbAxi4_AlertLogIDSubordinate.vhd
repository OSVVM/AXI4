--
--  File Name:         TbAxi4_AlertLogIDSubordinate.vhd
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
--    12/2020   2020.12    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2017 - 2021 by SynthWorks Design Inc.  
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

architecture AlertLogIDSubordinate of TestCtrl is

  signal TestDone, Sync : integer_barrier := 1 ;
  signal TbManagerID, TbSubordinateID : AlertLogIDType ; 
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_AlertLogIDSubordinate") ;
    TbManagerID     <= GetAlertLogID("Manager") ;
    TbSubordinateID  <= GetAlertLogID("Subordinate") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    SetAlertStopCount(FAILURE, 2) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_AlertLogIDSubordinate.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
--    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4_AlertLogIDSubordinate.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_AlertLogIDSubordinate.txt", "") ; 

    EndOfTestReports(ExternalErrors => (FAILURE => -1, ERROR => -1, WARNING => -1)) ; 
    std.env.stop(SumAlertCount(GetAlertCount + (FAILURE => -1, ERROR => -1, WARNING => -1))) ;
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- ManagerProc
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc : process
  begin
    wait until nReset = '1' ;  
    WaitForClock(ManagerRec, 2) ; 
    
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc ;


  ------------------------------------------------------------
  -- SubordinateProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  SubordinateProc : process
    variable AlertLogID : AlertLogIDType ; 
    variable Count1, Count2 : integer ; 
  begin
    wait until nReset = '1' ;  
    WaitForClock(SubordinateRec, 2) ; 
    
    GetAlertLogID(SubordinateRec, AlertLogID) ;
    GetErrorCount(SubordinateRec, Count1) ;
    AffirmIfEqual(TbSubordinateID, Count1, 0, "GetErrorCount") ;
    Count2 := GetAlertCount(AlertLogID) ;
    AffirmIfEqual(TbSubordinateID, Count2, 0, "GetAlertCount") ;
    
    Alert(AlertLogID, "Injected Error 1", ERROR) ;
    GetErrorCount(SubordinateRec, Count1) ;
    AffirmIfEqual(TbSubordinateID, Count1, 1, "GetErrorCount") ;
    Count2 := GetAlertCount(AlertLogID) ;
    AffirmIfEqual(TbSubordinateID, Count2, 1, "GetAlertCount") ;

    SetAlertStopCount(AlertLogID, FAILURE, 10) ;
    Alert(AlertLogID, "Injected FAILURE 1", FAILURE) ;
    GetErrorCount(SubordinateRec, Count1) ;
    AffirmIfEqual(TbSubordinateID, Count1, 2, "GetErrorCount") ;
    Count2 := GetAlertCount(AlertLogID) ;
    AffirmIfEqual(TbSubordinateID, Count2, 2, "GetAlertCount") ;

    Alert(AlertLogID, "Injected WARNING 1", WARNING) ;
    GetErrorCount(SubordinateRec, Count1) ;
    AffirmIfEqual(TbSubordinateID, Count1, 3, "GetErrorCount") ;
    Count2 := GetAlertCount(AlertLogID) ;
    AffirmIfEqual(TbSubordinateID, Count2, 3, "GetAlertCount") ;

    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;


end AlertLogIDSubordinate ;

Configuration TbAxi4_AlertLogIDSubordinate of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AlertLogIDSubordinate) ; 
    end for ; 
  end for ; 
end TbAxi4_AlertLogIDSubordinate ; 
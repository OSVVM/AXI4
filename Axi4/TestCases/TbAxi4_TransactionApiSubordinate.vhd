--
--  File Name:         TbAxi4_TransactionApiSubordinate.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--    WaitForTransaction, GetTransactionCount, ...
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
--  Copyright (c) 2020 by SynthWorks Design Inc.  
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

architecture TransactionApiSubordinate of TestCtrl is

  signal TestDone, Sync, RunTest : integer_barrier := 1 ;
  signal TbManagerID : AlertLogIDType ; 
  signal TbSubordinateID  : AlertLogIDType ; 
  signal WaitForTransactionCount : integer := 0 ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_TransactionApiSubordinate") ;
    TbManagerID <= GetAlertLogID("TB Manager Proc") ;
    TbSubordinateID <= GetAlertLogID("TB Subordinate Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_TransactionApiSubordinate.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_TransactionApiSubordinate.txt", "../../sim_results/Axi4/TbAxi4_TransactionApiSubordinate.txt", "") ; 

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
  begin
    wait until nReset = '1' ;  
    -- Must set Manager options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 

-------------------------------------------------- Test 1:  Write & Subordinate WFT
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    
    -- Write Tests
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    log(TbManagerID, "Read, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    Write(ManagerRec, Addr,    Data) ;
    Write(ManagerRec, Addr+4,  Data+1) ;
    
-------------------------------------------------- Test 2:  Write & Subordinate WFWT
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    
    -- Write Tests
    Addr := Addr + 128 ; 
    Data := Data + 128 ; 
    log(TbManagerID, "Read, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    Write(ManagerRec, Addr,    Data) ;
    Write(ManagerRec, Addr+4,  Data+1) ;
    
-------------------------------------------------- Test 3:  Read & Subordinate WFT
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    
    -- Read Tests
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    log(TbManagerID, "Read, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    ReadCheck(ManagerRec, Addr,    Data) ;
    ReadCheck(ManagerRec, Addr+4,  Data+1) ;
    
-------------------------------------------------- Test 4:  Read & Subordinate WFWT
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    
    -- Read Tests
    Addr := Addr + 128 ; 
    Data := Data + 128 ; 
    log(TbManagerID, "Read, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    ReadCheck(ManagerRec, Addr,    Data) ;
    ReadCheck(ManagerRec, Addr+4,  Data+1) ;


-------------------------------------------------- End of Test

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
    variable Count        : integer ; 
    variable WFTStartTime : time ; 
  begin
    wait until nReset = '1' ;  
    wait for 0 ns ; 
    -- Verify Initial values of Transaction Counts
    GetTransactionCount(SubordinateRec, Count) ;  -- Expect 1
    AffirmIfEqual(TbSubordinateID, Count, 1, "GetTransactionCount") ;
    GetWriteTransactionCount(SubordinateRec, Count) ; -- Expect 0
    AffirmIfEqual(TbSubordinateID, Count, 0, "GetTransactionWriteCount") ;
    GetReadTransactionCount(SubordinateRec, Count) ; -- Expect 0
    AffirmIfEqual(TbSubordinateID, Count, 0, "GetTransactionReadCount") ;
    
    WaitForClock(SubordinateRec, 4) ; 
    
-------------------------------------------------- Test 1:  Write & Subordinate WFT
    -- Check #1 validate WFT before transaction received
    WaitForBarrier(Sync) ;
    WFTStartTime := now ; 
    WaitForTransaction(SubordinateRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFT
    AffirmIf(TbSubordinateID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(SubordinateRec, Count) ;  -- Expect 6
    AffirmIfEqual(TbSubordinateID, Count, 6, "GetTransactionCount") ;
    GetWriteTransactionCount(SubordinateRec, Count) ; -- Expect 1
    AffirmIfEqual(TbSubordinateID, Count, 1, "GetTransactionWriteCount") ;
    
    -- Get Write 1
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    log(TbManagerID, "Read, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    GetWrite(SubordinateRec, RxAddr, RxData) ;
    AffirmIfEqual(RxAddr, Addr, "Subordinate Write Addr: ") ;
    AffirmIfEqual(RxData, Data, "Subordinate Write Data: ") ;

    -- Check #2 validate WFT after transaction received
    WaitForClock(SubordinateRec, 4) ;
    WFTStartTime := now ; 
    WaitForTransaction(SubordinateRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time did not pass in WFT
    AffirmIfEqual(TbSubordinateID, WFTStartTime, now, "WaitForTransaction after TryReadCheckData takes 0 time") ;
    -- Check Transaction Counts
    GetTransactionCount(SubordinateRec, Count) ;  -- Expect 11
    AffirmIfEqual(TbSubordinateID, Count, 11, "GetTransactionCount") ;
    GetWriteTransactionCount(SubordinateRec, Count) ; -- Expect 2
    AffirmIfEqual(TbSubordinateID, Count, 2, "GetTransactionWriteCount") ;
    
    -- Get Write 2
    GetWrite(SubordinateRec, RxAddr, RxData) ;
    AffirmIfEqual(RxAddr, Addr+4, "Subordinate Write Addr: ") ;
    AffirmIfEqual(RxData, Data+1, "Subordinate Write Data: ") ;


-------------------------------------------------- Test 2:  Write & Subordinate WFWT
    -- Check #1 validate WFT before transaction received
    WaitForBarrier(Sync) ;
    WFTStartTime := now ; 
    WaitForWriteTransaction(SubordinateRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFWT
    AffirmIf(TbSubordinateID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(SubordinateRec, Count) ;  -- Expect 15
    AffirmIfEqual(TbSubordinateID, Count, 15, "GetTransactionCount") ;
    GetWriteTransactionCount(SubordinateRec, Count) ; -- Expect 3
    AffirmIfEqual(TbSubordinateID, Count, 3, "GetTransactionWriteCount") ;
    
    -- Get Write 1
    Addr := Addr + 128 ; 
    Data := Data + 128 ; 
    log(TbManagerID, "Read, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    GetWrite(SubordinateRec, RxAddr, RxData) ;
    AffirmIfEqual(RxAddr, Addr, "Subordinate Write Addr: ") ;
    AffirmIfEqual(RxData, Data, "Subordinate Write Data: ") ;

    -- Check #2 validate WFT after transaction received
    WaitForClock(SubordinateRec, 4) ;
    WFTStartTime := now ; 
    WaitForWriteTransaction(SubordinateRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time did not pass in WFWT
    AffirmIfEqual(TbSubordinateID, WFTStartTime, now, "WaitForTransaction after TryReadCheckData takes 0 time") ;
    -- Check Transaction Counts
    GetTransactionCount(SubordinateRec, Count) ;  -- Expect 20
    AffirmIfEqual(TbSubordinateID, Count, 20, "GetTransactionCount") ;
    GetWriteTransactionCount(SubordinateRec, Count) ; -- Expect 4
    AffirmIfEqual(TbSubordinateID, Count, 4, "GetTransactionWriteCount") ;

    -- Get Write 2
    GetWrite(SubordinateRec, RxAddr, RxData) ;
    AffirmIfEqual(RxAddr, Addr+4, "Subordinate Write Addr: ") ;
    AffirmIfEqual(RxData, Data+1, "Subordinate Write Data: ") ;

-------------------------------------------------- Test 3:  Read & Subordinate WFT
    -- Check #1 validate WFT before transaction received
    WaitForBarrier(Sync) ;
    WFTStartTime := now ; 
    WaitForTransaction(SubordinateRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFT
    AffirmIf(TbSubordinateID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(SubordinateRec, Count) ;  -- Expect 24
    AffirmIfEqual(TbSubordinateID, Count, 24, "GetTransactionCount") ;
    GetReadTransactionCount(SubordinateRec, Count) ; -- Expect 1
    AffirmIfEqual(TbSubordinateID, Count, 1, "GetReadTransactionCount") ;
    
    -- Check Read 1
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ;
    SendRead(SubordinateRec, RxAddr, Data) ; 
    AffirmIfEqual(RxAddr, Addr, "Subordinate Read Addr: ") ;

    -- Check #2 validate WFT after transaction received
    WaitForClock(SubordinateRec, 4) ;
    WFTStartTime := now ; 
    WaitForTransaction(SubordinateRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time did not pass in WFT
    AffirmIfEqual(TbSubordinateID, WFTStartTime, now, "WaitForTransaction after TryReadCheckData takes 0 time") ;
    -- Check Transaction Counts
    GetTransactionCount(SubordinateRec, Count) ;  -- Expect 29
    AffirmIfEqual(TbSubordinateID, Count, 29, "GetTransactionCount") ;
    GetReadTransactionCount(SubordinateRec, Count) ; -- Expect 2
    AffirmIfEqual(TbSubordinateID, Count, 2, "GetReadTransactionCount") ;

    -- Check Read 2
    SendRead(SubordinateRec, RxAddr, Data+1) ; 
    AffirmIfEqual(RxAddr, Addr+4, "Subordinate Read Addr: ") ;


-------------------------------------------------- Test 4:  Read & Subordinate WFWT
    -- Check #1 validate WFT before transaction received
    WaitForBarrier(Sync) ;
    WFTStartTime := now ; 
    WaitForReadTransaction(SubordinateRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFWT
    AffirmIf(TbSubordinateID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(SubordinateRec, Count) ;  -- Expect 33
    AffirmIfEqual(TbSubordinateID, Count, 33, "GetTransactionCount") ;
    GetReadTransactionCount(SubordinateRec, Count) ; -- Expect 3
    AffirmIfEqual(TbSubordinateID, Count, 3, "GetReadTransactionCount") ;
    
    -- Check Read #1
    Addr := Addr + 128 ; 
    Data := Data + 128 ; 
    SendRead(SubordinateRec, RxAddr, Data) ; 
    AffirmIfEqual(RxAddr, Addr, "Subordinate Read Addr: ") ;

    -- Check #2 validate WFT after transaction received
    WaitForClock(SubordinateRec, 4) ;
    WFTStartTime := now ; 
    WaitForReadTransaction(SubordinateRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time did not pass in WFWT
    AffirmIfEqual(TbSubordinateID, WFTStartTime, now, "WaitForTransaction after TryReadCheckData takes 0 time") ;
    -- Check Transaction Counts
    GetTransactionCount(SubordinateRec, Count) ;     -- Expect 38
    AffirmIfEqual(TbSubordinateID, Count, 38, "GetTransactionCount") ;
    GetReadTransactionCount(SubordinateRec, Count) ; -- Expect 4
    AffirmIfEqual(TbSubordinateID, Count, 4, "GetReadTransactionCount") ;

    -- Check Read #2
    SendRead(SubordinateRec, RxAddr, Data+1) ; 
    AffirmIfEqual(RxAddr, Addr+4, "Subordinate Read Addr: ") ;


-------------------------------------------------- End of Test
    WaitForClock(SubordinateRec, 4) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;

end TransactionApiSubordinate ;

Configuration TbAxi4_TransactionApiSubordinate of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(TransactionApiSubordinate) ; 
    end for ; 
  end for ; 
end TbAxi4_TransactionApiSubordinate ; 
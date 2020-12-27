--
--  File Name:         TbAxi4_TransactionApiMemory.vhd
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

architecture TransactionApiMemory of TestCtrl is

  signal TestDone, Sync, RunTest : integer_barrier := 1 ;
  signal TbMasterID : AlertLogIDType ; 
  signal TbResponderID  : AlertLogIDType ; 
  signal WaitForTransactionCount : integer := 0 ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_TransactionApiMemory") ;
    TbMasterID <= GetAlertLogID("TB Master Proc") ;
    TbResponderID <= GetAlertLogID("TB Responder Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_TransactionApiMemory.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_TransactionApiMemory.txt", "../../sim_results/Axi4/TbAxi4_TransactionApiMemory.txt", "") ; 
    
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
  begin
    wait until nReset = '1' ;  
    -- Must set Master options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 

-------------------------------------------------- Test 1:  Write & Responder WFT
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    
    -- Write Tests
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    log(TbMasterID, "Read, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    Write(MasterRec, Addr,    Data) ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, Addr+4,  Data+1) ;
    
-------------------------------------------------- Test 2:  Write & Responder WFWT
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    
    -- Write Tests
    Addr := Addr + 128 ; 
    Data := Data + 128 ; 
    log(TbMasterID, "Read, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    Write(MasterRec, Addr,    Data) ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, Addr+4,  Data+1) ;
    
-------------------------------------------------- Test 3:  Read & Responder WFT
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    
    -- Write Tests
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    log(TbMasterID, "Read, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    ReadCheck(MasterRec, Addr,    Data) ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    ReadCheck(MasterRec, Addr+4,  Data+1) ;
    
-------------------------------------------------- Test 4:  Read & Responder WFWT
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    
    -- Write Tests
    Addr := Addr + 128 ; 
    Data := Data + 128 ; 
    log(TbMasterID, "Read, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    ReadCheck(MasterRec, Addr,    Data) ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    ReadCheck(MasterRec, Addr+4,  Data+1) ;


-------------------------------------------------- End of Test

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
    variable Count        : integer ; 
    variable WFTStartTime : time ; 
  begin
    wait until nReset = '1' ;  
    wait for 0 ns ; 
    -- Verify Initial values of Transaction Counts
    GetTransactionCount(ResponderRec, Count) ;  -- Expect 0
    AffirmIfEqual(TbResponderID, Count, 0, "GetTransactionCount") ;
    GetWriteTransactionCount(ResponderRec, Count) ; -- Expect 0
    AffirmIfEqual(TbResponderID, Count, 0, "GetTransactionWriteCount") ;
    GetReadTransactionCount(ResponderRec, Count) ; -- Expect 0
    AffirmIfEqual(TbResponderID, Count, 0, "GetTransactionReadCount") ;
    
    WaitForClock(ResponderRec, 4) ; 
    
-------------------------------------------------- Test 1:  Write & Responder WFT
    -- Check #1 validate WFT before transaction received
    WaitForBarrier(Sync) ;
    WFTStartTime := now ; 
    WaitForTransaction(ResponderRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFT
    AffirmIf(TbResponderID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(ResponderRec, Count) ;  -- Expect 1
    AffirmIfEqual(TbResponderID, Count, 1, "GetTransactionCount") ;
    GetWriteTransactionCount(ResponderRec, Count) ; -- Expect 1
    AffirmIfEqual(TbResponderID, Count, 1, "GetTransactionWriteCount") ;
    
    -- Check #2 validate WFT before transaction received
    WaitForBarrier(Sync) ;
--!!    WaitForClock(ResponderRec, 4) ;
    WFTStartTime := now ; 
    WaitForTransaction(ResponderRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFT
    AffirmIf(TbResponderID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(ResponderRec, Count) ;  -- Expect 2
    AffirmIfEqual(TbResponderID, Count, 2, "GetTransactionCount") ;
    GetWriteTransactionCount(ResponderRec, Count) ; -- Expect 2
    AffirmIfEqual(TbResponderID, Count, 2, "GetTransactionWriteCount") ;


-------------------------------------------------- Test 2:  Write & Responder WFWT
    -- Check #1 validate WFT before transaction received
    WaitForBarrier(Sync) ;
    WFTStartTime := now ; 
    WaitForWriteTransaction(ResponderRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFWT
    AffirmIf(TbResponderID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(ResponderRec, Count) ;  -- Expect 3
    AffirmIfEqual(TbResponderID, Count, 3, "GetTransactionCount") ;
    GetWriteTransactionCount(ResponderRec, Count) ; -- Expect 3
    AffirmIfEqual(TbResponderID, Count, 3, "GetTransactionWriteCount") ;
    
    -- Check #2 validate WFT after transaction received
    WaitForBarrier(Sync) ;
--!!    WaitForClock(ResponderRec, 4) ;
    WFTStartTime := now ; 
    WaitForWriteTransaction(ResponderRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFWT
    AffirmIf(TbResponderID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(ResponderRec, Count) ;  -- Expect 4
    AffirmIfEqual(TbResponderID, Count, 4, "GetTransactionCount") ;
    GetWriteTransactionCount(ResponderRec, Count) ; -- Expect 4
    AffirmIfEqual(TbResponderID, Count, 4, "GetTransactionWriteCount") ;

-------------------------------------------------- Test 3:  Read & Responder WFT
    -- Check #1 validate WFT before transaction received
    WaitForBarrier(Sync) ;
    WFTStartTime := now ; 
    WaitForTransaction(ResponderRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFT
    AffirmIf(TbResponderID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(ResponderRec, Count) ;  -- Expect 5
    AffirmIfEqual(TbResponderID, Count, 5, "GetTransactionCount") ;
    GetReadTransactionCount(ResponderRec, Count) ; -- Expect 1
    AffirmIfEqual(TbResponderID, Count, 1, "GetReadTransactionCount") ;
    
    -- Check #2 validate WFT after transaction received
    WaitForBarrier(Sync) ;
--!!    WaitForClock(ResponderRec, 4) ;
    WFTStartTime := now ; 
    WaitForTransaction(ResponderRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFT
    AffirmIf(TbResponderID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(ResponderRec, Count) ;  -- Expect 6
    AffirmIfEqual(TbResponderID, Count, 6, "GetTransactionCount") ;
    GetReadTransactionCount(ResponderRec, Count) ; -- Expect 2
    AffirmIfEqual(TbResponderID, Count, 2, "GetReadTransactionCount") ;


-------------------------------------------------- Test 4:  Read & Responder WFWT
    -- Check #1 validate WFT before transaction received
    WaitForBarrier(Sync) ;
    WFTStartTime := now ; 
    WaitForReadTransaction(ResponderRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFRT
    AffirmIf(TbResponderID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(ResponderRec, Count) ;  -- Expect 7
    AffirmIfEqual(TbResponderID, Count, 7, "GetTransactionCount") ;
    GetReadTransactionCount(ResponderRec, Count) ; -- Expect 3
    AffirmIfEqual(TbResponderID, Count, 3, "GetReadTransactionCount") ;
    
    -- Check #2 validate WFT after transaction received
    WaitForBarrier(Sync) ;
--!!    WaitForClock(ResponderRec, 4) ;
    WFTStartTime := now ; 
    WaitForReadTransaction(ResponderRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    -- Check that time passed in WFRT
    AffirmIf(TbResponderID, now > WFTStartTime, 
      "WaitForTransaction before StartTime: " & to_string(WFTStartTime)) ;
    -- Check Transaction Counts
    GetTransactionCount(ResponderRec, Count) ;  -- Expect 8
    AffirmIfEqual(TbResponderID, Count, 8, "GetTransactionCount") ;
    GetReadTransactionCount(ResponderRec, Count) ; -- Expect 4
    AffirmIfEqual(TbResponderID, Count, 4, "GetReadTransactionCount") ;

-------------------------------------------------- End of Test
    GetWriteTransactionCount(ResponderRec, Count) ; -- Expect 4
    AffirmIfEqual(TbResponderID, Count, 4, "GetTransactionWriteCount") ;
    GetReadTransactionCount(ResponderRec, Count) ; -- Expect 4
    AffirmIfEqual(TbResponderID, Count, 4, "GetReadTransactionCount") ;


    WaitForClock(ResponderRec, 4) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ResponderProc ;

end TransactionApiMemory ;

Configuration TbAxi4_TransactionApiMemory of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(TransactionApiMemory) ; 
    end for ; 
    for Responder_1 : Axi4Responder 
      use entity OSVVM_AXI4.Axi4Memory ; 
    end for ; 
  end for ; 
end TbAxi4_TransactionApiMemory ; 
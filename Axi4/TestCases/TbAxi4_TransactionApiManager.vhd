--
--  File Name:         TbAxi4_TransactionApiManager.vhd
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

architecture TransactionApiManager of TestCtrl is

  signal TestDone, MemorySync : integer_barrier := 1 ;
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
    SetAlertLogName("TbAxi4_TransactionApiManager") ;
    TbManagerID <= GetAlertLogID("TB Manager Proc") ;
    TbSubordinateID <= GetAlertLogID("TB Subordinate Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_TransactionApiManager.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_TransactionApiManager.txt", "../../sim_results/Axi4/TbAxi4_TransactionApiManager.txt", "") ; 

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
    variable Count : integer ; 
    variable WFTStartTime : time ; 
    variable Available : boolean ; 
  begin
    wait until nReset = '1' ;  
    -- Must set Manager options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 
    -- Verify Initial values of Transaction Counts
    GetTransactionCount(ManagerRec, Count) ;  -- Expect 1
    AffirmIfEqual(TbManagerID, Count, 1, "GetTransactionCount") ;
    GetWriteTransactionCount(ManagerRec, Count) ; -- Expect 0
    AffirmIfEqual(TbManagerID, Count, 0, "GetTransactionWriteCount") ;
    GetReadTransactionCount(ManagerRec, Count) ; -- Expect 0
    AffirmIfEqual(TbManagerID, Count, 0, "GetTransactionReadCount") ;
    
    WaitForClock(ManagerRec, 4) ; 
    
    -- Write Tests
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    log(TbManagerID, "WriteAsync, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    WriteAsync(ManagerRec, Addr,    Data) ;
    WriteAsync(ManagerRec, Addr+4,  Data+1) ;
    WaitForTransaction(ManagerRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetTransactionCount(ManagerRec, Count) ;  -- Expect 8
    AffirmIfEqual(TbManagerID, Count, 8, "GetTransactionCount") ;
    GetWriteTransactionCount(ManagerRec, Count) ; -- Expect 2
    AffirmIfEqual(TbManagerID, Count, 2, "GetTransactionWriteCount") ;
    
    WaitForClock(ManagerRec, 4) ;
    
    WriteAsync(ManagerRec, Addr+8,  Data+2) ;
    WriteAsync(ManagerRec, Addr+12, Data+3) ;
    WaitForWriteTransaction(ManagerRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetTransactionCount(ManagerRec, Count) ;  -- Expect 14
    AffirmIfEqual(TbManagerID, Count, 14, "GetTransactionCount") ;
    GetWriteTransactionCount(ManagerRec, Count) ; -- Expect 4
    AffirmIfEqual(TbManagerID, Count, 4, "GetTransactionWriteCount") ;
    
    WaitForClock(ManagerRec, 4) ;
    
    Addr := X"0000_0000" + 16 ; 
    Data := X"0000_0000" + 4 ; 
    log(TbManagerID, "WriteAddressAsync, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    WriteAddressAsync(ManagerRec, Addr) ;
    WriteAddressAsync(ManagerRec, Addr+4) ;
    WaitForTransaction(ManagerRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetWriteTransactionCount(ManagerRec, Count) ; -- Expect 6
    AffirmIfEqual(TbManagerID, Count, 6, "GetTransactionWriteCount") ;
    
    WaitForClock(ManagerRec, 4) ;
    
    log(TbManagerID, "WriteDataAsync, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    WriteDataAsync(ManagerRec, Addr,    Data) ;
    WriteDataAsync(ManagerRec, Addr+4,  Data+1) ;
    WaitForTransaction(ManagerRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetWriteTransactionCount(ManagerRec, Count) ; -- Expect 6 
    AffirmIfEqual(TbManagerID, Count, 6, "GetTransactionWriteCount") ;

    WaitForClock(ManagerRec, 4) ;
    
    WriteAddressAsync(ManagerRec, Addr+8) ;
    WriteAddressAsync(ManagerRec, Addr+12) ;
    WaitForWriteTransaction(ManagerRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetWriteTransactionCount(ManagerRec, Count) ; -- Expect 8
    AffirmIfEqual(TbManagerID, Count, 8, "GetTransactionWriteCount") ;
    
    WaitForClock(ManagerRec, 4) ;

    WriteDataAsync(ManagerRec, Addr+8,   Data+2) ;
    WriteDataAsync(ManagerRec, Addr+12,  Data+3) ;
    WaitForWriteTransaction(ManagerRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetWriteTransactionCount(ManagerRec, Count) ; -- Expect 8 
    AffirmIfEqual(TbManagerID, Count, 8, "GetTransactionWriteCount") ;

    WaitForClock(ManagerRec, 4) ;

    GetReadTransactionCount(ManagerRec, Count) ; -- Expect 0
    AffirmIfEqual(TbManagerID, Count, 0, "GetTransactionReadCount") ;
    
    -- Read Tests
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 

    log(TbManagerID, "ReadAddressAsync, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    ReadAddressAsync(ManagerRec, Addr) ;
    ReadAddressAsync(ManagerRec, Addr+4) ;
    WaitForTransaction(ManagerRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetReadTransactionCount(ManagerRec, Count) ; -- Expect 2
    AffirmIfEqual(TbManagerID, Count, 2, "GetTransactionReadCount") ;   
    GetWriteTransactionCount(ManagerRec, Count) ; -- Expect 8 
    AffirmIfEqual(TbManagerID, Count, 8, "GetTransactionWriteCount") ;
    
    WaitForClock(ManagerRec, 4) ;
    
    log(TbManagerID, "TryReadCheckData, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    TryReadCheckData(ManagerRec, Data  , Available) ;
    AffirmIfEqual(TbManagerID, Available, TRUE, "TryReadCheckData Available: ") ;
    TryReadCheckData(ManagerRec, Data+1, Available) ;
    AffirmIfEqual(TbManagerID, Available, TRUE, "TryReadCheckData Available: ") ;
    WFTStartTime := now ; 
    WaitForTransaction(ManagerRec) ;
    AffirmIfEqual(TbManagerID, WFTStartTime, now, "WaitForTransaction after TryReadCheckData takes 0 time") ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetReadTransactionCount(ManagerRec, Count) ; -- Expect 2
    AffirmIfEqual(TbManagerID, Count, 2, "GetTransactionReadCount") ;   

    WaitForClock(ManagerRec, 4) ;
    
    ReadAddressAsync(ManagerRec, Addr+8) ;
    ReadAddressAsync(ManagerRec, Addr+12) ;
    WaitForReadTransaction(ManagerRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetReadTransactionCount(ManagerRec, Count) ; -- Expect 4
    AffirmIfEqual(TbManagerID, Count, 4, "GetTransactionReadCount") ;   
    
    WaitForClock(ManagerRec, 4) ;
    
    TryReadCheckData(ManagerRec, Data+2, Available) ;
    AffirmIfEqual(TbManagerID, Available, TRUE, "TryReadCheckData Available: ") ;
    TryReadCheckData(ManagerRec, Data+3, Available) ;
    AffirmIfEqual(TbManagerID, Available, TRUE, "TryReadCheckData Available: ") ;
    WFTStartTime := now ; 
    WaitForReadTransaction(ManagerRec) ;
    AffirmIfEqual(TbManagerID, WFTStartTime, now, "WaitForTransaction after TryReadCheckData takes 0 time") ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetReadTransactionCount(ManagerRec, Count) ; -- Expect 4
    AffirmIfEqual(TbManagerID, Count, 4, "GetTransactionReadCount") ;   

    WaitForClock(ManagerRec, 4) ;

    GetReadTransactionCount(ManagerRec, Count) ; -- Expect 4
    AffirmIfEqual(TbManagerID, Count, 4, "GetTransactionReadCount") ;   
    GetWriteTransactionCount(ManagerRec, Count) ; -- Expect 8 
    AffirmIfEqual(TbManagerID, Count, 8, "GetTransactionWriteCount") ;


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
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
    variable IntOption  : integer ; 
    variable ValidDelayCycleOption : Axi4OptionsType ; 
  begin
  

    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;

end TransactionApiManager ;

Configuration TbAxi4_TransactionApiManager of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(TransactionApiManager) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_TransactionApiManager ; 
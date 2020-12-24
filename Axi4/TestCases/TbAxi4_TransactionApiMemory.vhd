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

  signal TestDone, MemorySync : integer_barrier := 1 ;
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
    variable Count : integer ; 
    variable WFTStartTime : time ; 
    variable Available : boolean ; 
  begin
    wait until nReset = '1' ;  
    -- Must set Master options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 
    -- Verify Initial values of Transaction Counts
    GetTransactionCount(MasterRec, Count) ;  -- Expect 1
    AffirmIfEqual(TbMasterID, Count, 1, "GetTransactionCount") ;
    GetWriteTransactionCount(MasterRec, Count) ; -- Expect 0
    AffirmIfEqual(TbMasterID, Count, 0, "GetTransactionWriteCount") ;
    GetReadTransactionCount(MasterRec, Count) ; -- Expect 0
    AffirmIfEqual(TbMasterID, Count, 0, "GetTransactionReadCount") ;
    
    WaitForClock(MasterRec, 4) ; 
    
    -- Write Tests
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 
    log(TbMasterID, "WriteAsync, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    WriteAsync(MasterRec, Addr,    Data) ;
    WriteAsync(MasterRec, Addr+4,  Data+1) ;
    WaitForTransaction(MasterRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetTransactionCount(MasterRec, Count) ;  -- Expect 8
    AffirmIfEqual(TbMasterID, Count, 8, "GetTransactionCount") ;
    GetWriteTransactionCount(MasterRec, Count) ; -- Expect 2
    AffirmIfEqual(TbMasterID, Count, 2, "GetTransactionWriteCount") ;
    
    WaitForClock(MasterRec, 4) ;
    
    WriteAsync(MasterRec, Addr+8,  Data+2) ;
    WriteAsync(MasterRec, Addr+12, Data+3) ;
    WaitForWriteTransaction(MasterRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetTransactionCount(MasterRec, Count) ;  -- Expect 14
    AffirmIfEqual(TbMasterID, Count, 14, "GetTransactionCount") ;
    GetWriteTransactionCount(MasterRec, Count) ; -- Expect 4
    AffirmIfEqual(TbMasterID, Count, 4, "GetTransactionWriteCount") ;
    
    WaitForClock(MasterRec, 4) ;
    
    Addr := X"0000_0000" + 16 ; 
    Data := X"0000_0000" + 4 ; 
    log(TbMasterID, "WriteAddressAsync, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    WriteAddressAsync(MasterRec, Addr) ;
    WriteAddressAsync(MasterRec, Addr+4) ;
    WaitForTransaction(MasterRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetWriteTransactionCount(MasterRec, Count) ; -- Expect 6
    AffirmIfEqual(TbMasterID, Count, 6, "GetTransactionWriteCount") ;
    
    WaitForClock(MasterRec, 4) ;
    
    log(TbMasterID, "WriteDataAsync, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    WriteDataAsync(MasterRec, Addr,    Data) ;
    WriteDataAsync(MasterRec, Addr+4,  Data+1) ;
    WaitForTransaction(MasterRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetWriteTransactionCount(MasterRec, Count) ; -- Expect 6 
    AffirmIfEqual(TbMasterID, Count, 6, "GetTransactionWriteCount") ;

    WaitForClock(MasterRec, 4) ;
    
    WriteAddressAsync(MasterRec, Addr+8) ;
    WriteAddressAsync(MasterRec, Addr+12) ;
    WaitForWriteTransaction(MasterRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetWriteTransactionCount(MasterRec, Count) ; -- Expect 8
    AffirmIfEqual(TbMasterID, Count, 8, "GetTransactionWriteCount") ;
    
    WaitForClock(MasterRec, 4) ;

    WriteDataAsync(MasterRec, Addr+8,   Data+2) ;
    WriteDataAsync(MasterRec, Addr+12,  Data+3) ;
    WaitForWriteTransaction(MasterRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetWriteTransactionCount(MasterRec, Count) ; -- Expect 8 
    AffirmIfEqual(TbMasterID, Count, 8, "GetTransactionWriteCount") ;

    WaitForClock(MasterRec, 4) ;

    GetReadTransactionCount(MasterRec, Count) ; -- Expect 0
    AffirmIfEqual(TbMasterID, Count, 0, "GetTransactionReadCount") ;
    
    -- Read Tests
    Addr := X"0000_0000" ; 
    Data := X"0000_0000" ; 

    log(TbMasterID, "ReadAddressAsync, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    ReadAddressAsync(MasterRec, Addr) ;
    ReadAddressAsync(MasterRec, Addr+4) ;
    WaitForTransaction(MasterRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetReadTransactionCount(MasterRec, Count) ; -- Expect 2
    AffirmIfEqual(TbMasterID, Count, 2, "GetTransactionReadCount") ;   
    GetWriteTransactionCount(MasterRec, Count) ; -- Expect 8 
    AffirmIfEqual(TbMasterID, Count, 8, "GetTransactionWriteCount") ;
    
    WaitForClock(MasterRec, 4) ;
    
    log(TbMasterID, "TryReadCheckData, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
    TryReadCheckData(MasterRec, Data  , Available) ;
    AffirmIfEqual(TbMasterID, Available, TRUE, "TryReadCheckData Available: ") ;
    TryReadCheckData(MasterRec, Data+1, Available) ;
    AffirmIfEqual(TbMasterID, Available, TRUE, "TryReadCheckData Available: ") ;
    WFTStartTime := now ; 
    WaitForTransaction(MasterRec) ;
    AffirmIfEqual(TbMasterID, WFTStartTime, now, "WaitForTransaction after TryReadCheckData takes 0 time") ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetReadTransactionCount(MasterRec, Count) ; -- Expect 2
    AffirmIfEqual(TbMasterID, Count, 2, "GetTransactionReadCount") ;   

    WaitForClock(MasterRec, 4) ;
    
    ReadAddressAsync(MasterRec, Addr+8) ;
    ReadAddressAsync(MasterRec, Addr+12) ;
    WaitForReadTransaction(MasterRec) ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetReadTransactionCount(MasterRec, Count) ; -- Expect 4
    AffirmIfEqual(TbMasterID, Count, 4, "GetTransactionReadCount") ;   
    
    WaitForClock(MasterRec, 4) ;
    
    TryReadCheckData(MasterRec, Data+2, Available) ;
    AffirmIfEqual(TbMasterID, Available, TRUE, "TryReadCheckData Available: ") ;
    TryReadCheckData(MasterRec, Data+3, Available) ;
    AffirmIfEqual(TbMasterID, Available, TRUE, "TryReadCheckData Available: ") ;
    WFTStartTime := now ; 
    WaitForReadTransaction(MasterRec) ;
    AffirmIfEqual(TbMasterID, WFTStartTime, now, "WaitForTransaction after TryReadCheckData takes 0 time") ;
    WaitForTransactionCount <= WaitForTransactionCount + 1 ; 
    GetReadTransactionCount(MasterRec, Count) ; -- Expect 4
    AffirmIfEqual(TbMasterID, Count, 4, "GetTransactionReadCount") ;   

    WaitForClock(MasterRec, 4) ;

    GetReadTransactionCount(MasterRec, Count) ; -- Expect 4
    AffirmIfEqual(TbMasterID, Count, 4, "GetTransactionReadCount") ;   
    GetWriteTransactionCount(MasterRec, Count) ; -- Expect 8 
    AffirmIfEqual(TbMasterID, Count, 8, "GetTransactionWriteCount") ;


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
    variable IntOption  : integer ; 
    variable ValidDelayCycleOption : Axi4OptionsType ; 
  begin
  

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
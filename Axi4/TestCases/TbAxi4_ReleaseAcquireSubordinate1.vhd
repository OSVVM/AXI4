--
--  File Name:         TbAxi4_ReleaseAcquireSubordinate1.vhd
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

architecture ReleaseAcquireSubordinate1 of TestCtrl is

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
    SetAlertLogName("TbAxi4_ReleaseAcquireSubordinate1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    TbID <= GetAlertLogID("Testbench") ;

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_ReleaseAcquireSubordinate1.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_ReleaseAcquireSubordinate1.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_ReleaseAcquireSubordinate1.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 
  
  ------------------------------------------------------------
  -- ManagerProc
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc : process
    variable StartTime : time ; 
  begin
    wait until nReset = '1' ;  
    -- Align to the first clock
    WaitForClock(ManagerRec, 2) ; 
    StartTime := now ; 
    WaitForClock(ManagerRec, 2) ; 
    AffirmIfEqual(NOW, StartTime + 20 ns, "Expected Completion Time") ;

    Write(ManagerRec, X"1000_0000", X"5555_5555" ) ;
    ReadCheck(ManagerRec,  X"2000_0000", X"2222_2222") ;
    
    WaitForBarrier(Sync1) ;
    
    Write(ManagerRec, X"1000_1000", X"AAAA_AAAA" ) ;
    ReadCheck(ManagerRec,  X"2000_1000", X"4444_4444") ;
    
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc ;

  ------------------------------------------------------------
  -- SubordinateProc1
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  SubordinateProc1 : process
    variable StartTime : time ; 
    variable IntOption  : integer ; 
    variable BoolOption : boolean ; 
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    wait until nReset = '1' ;  
    -- Align to the first clock
    WaitForClock(SubordinateRec, 1) ; 
    StartTime := now ; 
    WaitForClock(SubordinateRec, 2) ; 
    AffirmIfEqual(NOW, StartTime + 20 ns, "Expected Completion Time") ;

    -- Setting and checking values set 
    SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 2) ;
    GetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbID, IntOption, 2, "WRITE_ADDRESS_READY_DELAY_CYCLES") ;
    SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, TRUE) ;
    GetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, BoolOption) ;
    AffirmIfEqual(TbID, BoolOption, TRUE, "WRITE_ADDRESS_READY_BEFORE_VALID") ;


    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"1000_0000", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"5555_5555", "Subordinate Write Data: ") ;
    
    SendRead(SubordinateRec, Addr, X"2222_2222") ; 
    AffirmIfEqual(Addr, X"2000_0000", "Subordinate Read Addr: ") ;


    WaitForBarrier(Sync1) ;
    ReleaseTransactionRecord(SubordinateRec) ; 
    
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc1 ;
  
  ------------------------------------------------------------
  -- SubordinateProc2
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  SubordinateProc2 : process
    variable StartTime : time ; 
    variable IntOption  : integer ; 
    variable BoolOption : boolean ; 
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    WaitForBarrier(Sync1) ;
    AcquireTransactionRecord(SubordinateRec) ;
    WaitForClock(SubordinateRec, 1) ; 

    StartTime := now ; 
    WaitForClock(SubordinateRec, 1) ; 
    AffirmIfEqual(NOW, StartTime + 10 ns, "Expected Completion Time") ;
    
    -- Setting and checking values set 
    SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 1) ;
    GetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbID, IntOption, 1, "WRITE_ADDRESS_READY_DELAY_CYCLES") ;
    SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, FALSE) ;
    GetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, BoolOption) ;
    AffirmIfEqual(TbID, BoolOption, FALSE, "WRITE_ADDRESS_READY_BEFORE_VALID") ;

    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"1000_1000", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"AAAA_AAAA", "Subordinate Write Data: ") ;
    
    SendRead(SubordinateRec, Addr, X"4444_4444") ; 
    AffirmIfEqual(Addr, X"2000_1000", "Subordinate Read Addr: ") ;

    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc2 ;


end ReleaseAcquireSubordinate1 ;

Configuration TbAxi4_ReleaseAcquireSubordinate1 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ReleaseAcquireSubordinate1) ; 
    end for ; 
  end for ; 
end TbAxi4_ReleaseAcquireSubordinate1 ; 
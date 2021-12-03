--
--  File Name:         TbAxi4_Separate1.vhd
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

architecture Separate1 of TestCtrl is

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
    SetAlertLogName("TbAxi4_Separate1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    TbID <= GetAlertLogID("Testbench") ;

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_Separate1.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_Separate1.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_Separate1.txt", "") ; 

    EndOfTestReports(ExternalErrors => (0, -12, 0)) ; 
    std.env.stop(GetAlertCount - 12) ; 
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
    WaitForClock(Manager1Rec, 1) ; 

    Write(Manager1Rec, X"1000_1000", X"5555_5555" ) ;
    ReadCheck(Manager1Rec, X"1000_1000", X"5555_5555" ) ;
    
    PushBurstIncrement(WriteBurstFifo1, 3, 6, AXI_DATA_WIDTH) ;
    WriteBurst(Manager1Rec, X"0000_0008", 6) ;
    
    ReadBurst (Manager1Rec, X"0000_0008", 6) ;
    CheckBurstIncrement(ReadBurstFifo1, 3, 6, AXI_DATA_WIDTH) ;

    WaitForBarrier(Sync1) ;
    WaitForBarrier(Sync1) ;

    -- Check values written by Manager2 side
    ReadCheck(Manager1Rec, X"1000_2000", X"AAAA_AAAA" ) ;

    ReadBurst (Manager1Rec, X"0000_1008", 4) ;
    CheckBurstIncrement(ReadBurstFifo1, 10, 4, AXI_DATA_WIDTH) ;

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

    WaitForClock(Manager2Rec, 1) ; 
    
    -- Check values written by other side
    ReadCheck(Manager2Rec, X"1000_1000", X"5555_5555" ) ;
    
    ReadBurst (Manager2Rec, X"0000_0008", 6) ;
    CheckBurstIncrement(ReadBurstFifo2, 3, 6, AXI_DATA_WIDTH) ;


    Write(Manager2Rec, X"1000_2000", X"AAAA_AAAA" ) ;
    ReadCheck(Manager2Rec, X"1000_2000", X"AAAA_AAAA" ) ;
    PushBurstIncrement(WriteBurstFifo2, 10, 4, AXI_DATA_WIDTH) ;
    WriteBurst(Manager2Rec, X"0000_1008", 4) ;
    ReadBurst (Manager2Rec, X"0000_1008", 4) ;
    CheckBurstIncrement(ReadBurstFifo2, 10, 4, AXI_DATA_WIDTH) ;
    
    WaitForBarrier(Sync1) ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(Manager2Rec, 2) ;
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


end Separate1 ;

library OSVVM_AXI4 ;

Configuration TbAxi4_Separate1 of TbAxi4_MultipleMemory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(Separate1) ; 
    end for ; 
    
-- ##    for all : Axi4Memory
-- ##      use entity OSVVM_AXI4.Axi4Memory(MemorySubordinate) 
-- ##          generic map (MEMORY_NAME => "SharedMemory");
-- ##    end for ; 

  end for ; 
end TbAxi4_Separate1 ; 
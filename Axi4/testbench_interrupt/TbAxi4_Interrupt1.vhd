--
--  File Name:         TbAxi4_Interrupt1.vhd
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
--    04/202`   202`.04    Initial revision
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

architecture Interrupt1 of TestCtrl is

  signal ManagerSync1, MemorySync1, TestDone : integer_barrier := 1 ;
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_Interrupt1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    SetLogEnable(GetAlertLogID("Memory_1"), INFO, FALSE) ;   

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_Interrupt1.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_Interrupt1.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_Interrupt1.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- ManagerProc
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0') ;    
  begin
    wait until nReset = '1' ;  
    WaitForClock(ManagerRec, 2) ; 
    
    for i in 0 to 3 loop 
      blankline(2) ; 
      log("Main Starting Writes.  Loop #" & to_string(i)) ;
      Write(ManagerRec, X"1000_0000", Data ) ;
      Write(ManagerRec, X"1000_0004", Data + 1 ) ;
      Write(ManagerRec, X"1000_0008", Data + 2 ) ;
      Write(ManagerRec, X"1000_000C", Data + 3 ) ;
      
      IntReq <= '1' after i * 10 ns + 5 ns, '0' after i * 10 ns + 50 ns ;  
      wait for 9 ns ; 
      WaitForClock(ManagerRec, 1) ; 
      log("WaitForClock #1 finished") ;
      WaitForClock(ManagerRec, 1) ; 
      log("WaitForClock #2 finished") ;
      WaitForClock(ManagerRec, 1) ; 
      log("WaitForClock #3 finished") ;
      WaitForClock(ManagerRec, 1) ; 
      log("WaitForClock #4 finished") ;

      blankline(2) ; 
      log("Main Starting Reads.  Loop #" & to_string(i)) ;
      ReadCheck(ManagerRec, X"A000_2000", Data ) ;
      ReadCheck(ManagerRec, X"A000_2004", Data + 1 ) ;
      ReadCheck(ManagerRec, X"A000_2008", Data + 2 ) ;
      ReadCheck(ManagerRec, X"A000_200C", Data + 3 ) ;

      Data := Data + X"10" ;
    end loop ; 

    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc ;


  ------------------------------------------------------------
  -- InterruptProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  InterruptProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0') ;    
  begin
    WaitForClock(InterruptRec, 1) ; 
    blankline(2) ; 
    log("Interrupt Handler Started") ; 
    ReadCheck(InterruptRec, X"1000_0000", Data ) ;
    ReadCheck(InterruptRec, X"1000_0004", Data + 1 ) ;
    ReadCheck(InterruptRec, X"1000_0008", Data + 2 ) ;
    ReadCheck(InterruptRec, X"1000_000C", Data + 3 ) ;
    
    Write(InterruptRec, X"A000_2000", Data ) ;
    Write(InterruptRec, X"A000_2004", Data + 1 ) ;
    Write(InterruptRec, X"A000_2008", Data + 2 ) ;
    Write(InterruptRec, X"A000_200C", Data + 3 ) ;
    
    Data := Data + X"10" ;

    log("Interrupt Handler Done") ; 
    blankline(2) ; 
    InterruptReturn(InterruptRec) ;
  end process InterruptProc ;

  ------------------------------------------------------------
  -- SubordinateProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  SubordinateProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;


end Interrupt1 ;

Configuration TbAxi4_Interrupt1 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(Interrupt1) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_Interrupt1 ; 
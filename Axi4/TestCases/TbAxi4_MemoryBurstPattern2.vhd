--
--  File Name:         TbAxi4_MemoryBurstPattern2.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Testing of Burst Features in AXI Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    01/2022   2022.01    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2022 by SynthWorks Design Inc.  
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

architecture MemoryBurstPattern2 of TestCtrl is

  signal TestDone, WriteDone : integer_barrier := 1 ;
  constant BURST_MODE : AddressBusFifoBurstModeType := ADDRESS_BUS_BURST_WORD_MODE ;   
--  constant BURST_MODE : AddressBusFifoBurstModeType := ADDRESS_BUS_BURST_BYTE_MODE ;   
  constant DATA_WIDTH : integer := IfElse(BURST_MODE = ADDRESS_BUS_BURST_BYTE_MODE, 8, AXI_DATA_WIDTH)  ;  
  constant DATA_ZERO  : std_logic_vector := (DATA_WIDTH - 1 downto 0 => '0') ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_MemoryBurstPattern2") ;
    SetLogEnable(PASSED, TRUE) ;   -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;     -- Enable INFO logs
    SetLogEnable(DEBUG, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_MemoryBurstPattern2.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 1 ms) ;
    AlertIf(now >= 1 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4_MemoryBurstPattern2.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_MemoryBurstPattern2.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- ManagerProc
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc : process
    variable ByteData : std_logic_vector(7 downto 0) ;
    variable BurstVal : AddressBusFifoBurstModeType ; 
    variable CoverID1, CoverID2 : CoverageIdType ; 
  begin
    CoverID1 := NewID("Cov1") ; 
    InitSeed(CoverID1, 5) ; -- Get a common seed in both processes
    AddBins (CoverID1, 1, GenBin(0,7) & GenBin(32,39) & GenBin(64,71) & GenBin(96,103)) ; 
    CoverID2 := NewID("Cov2") ; 
    InitSeed(CoverID2, 5) ; -- Get a common seed in both processes
    AddBins (CoverID2, 1, GenBin(0,7) & GenBin(32,39) & GenBin(64,71) & GenBin(96,103)) ; 
    wait until nReset = '1' ;  
    WaitForClock(ManagerRec, 2) ; 
    
    GetBurstMode(ManagerRec, BurstVal) ;
    AffirmIf(BurstVal = ADDRESS_BUS_BURST_WORD_MODE, "Default BurstMode is ADDRESS_BUS_BURST_WORD_MODE " & to_string(BurstVal)) ; 
    SetBurstMode(ManagerRec, BURST_MODE) ;
    GetBurstMode(ManagerRec, BurstVal) ;
    AffirmIfEqual(BurstVal, BURST_MODE, "BurstMode") ; 
    
    log("Write with Addr = 0008, 12 Words -- word aligned") ;
    WriteBurstRandom(    ManagerRec, X"0000_0008", CoverID1, 12, DATA_WIDTH) ;
    ReadCheckBurstRandom(ManagerRec, X"0000_0008", CoverID2, 12, DATA_WIDTH) ;
    
    log("Write with Addr = 1008, 9 Words -- word aligned") ;
    WriteBurstRandomAsync(ManagerRec, X"0000_1008", CoverID1, 9, DATA_WIDTH) ;
    WaitForTransaction(ManagerRec) ;
    ReadCheckBurstRandom( ManagerRec, X"0000_1008", CoverID2, 9, DATA_WIDTH) ;

    log("Write with Addr = 2008, 11 Words -- word aligned") ;
    WriteBurstRandom(    ManagerRec, X"0000_2008", CoverID1, 11, DATA_WIDTH) ;
    ReadCheckBurstRandom(ManagerRec, X"0000_2008", CoverID2, 11, DATA_WIDTH) ;
    
    log("Write with Addr = 3008, 13 Words -- word aligned") ;
    WriteBurstRandomAsync(ManagerRec, X"0000_3008", CoverID1, 13, DATA_WIDTH) ;
    WaitForTransaction(ManagerRec) ;
    ReadCheckBurstRandom( ManagerRec, X"0000_3008", CoverID2, 13, DATA_WIDTH) ;

    WaitForBarrier(WriteDone) ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc ;


  ------------------------------------------------------------
  -- MemoryProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  MemoryProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ; 
  begin
    WaitForClock(SubordinateRec, 2) ; 
    
    
    WaitForBarrier(WriteDone) ;

/*
    -- Check that write burst was received correctly
    ReadCheck(SubordinateRec, X"0000_0008", X"0000_0003") ;
    ReadCheck(SubordinateRec, X"0000_000C", X"0000_0004") ;
    ReadCheck(SubordinateRec, X"0000_0010", X"0000_0005") ;
    ReadCheck(SubordinateRec, X"0000_0014", X"0000_0006") ;
    ReadCheck(SubordinateRec, X"0000_0018", X"0000_0007") ;
    ReadCheck(SubordinateRec, X"0000_001C", X"0000_0008") ;
*/
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MemoryProc ;


end MemoryBurstPattern2 ;

Configuration TbAxi4_MemoryBurstPattern2 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MemoryBurstPattern2) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_MemoryBurstPattern2 ; 
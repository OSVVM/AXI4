--
--  File Name:         TbAxi4_MemoryBurst1.vhd
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
--    04/2020   2020.04    Initial revision
--    12/2020   2020.12    Updated signal and port names
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

architecture MemoryBurst1 of TestCtrl is

  signal TestDone, WriteDone : integer_barrier := 1 ;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_MemoryBurst1") ;
    SetLogEnable(PASSED, TRUE) ;   -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;     -- Enable INFO logs
    SetLogEnable(DEBUG, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_MemoryBurst1.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_MemoryBurst1.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_MemoryBurst1.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- MasterProc
  --   Generate transactions for AxiMaster
  ------------------------------------------------------------
  MasterProc : process
    variable ByteData : std_logic_vector(7 downto 0) ;
  begin
    wait until nReset = '1' ;  
    WaitForClock(ManagerRec, 2) ; 
    
    log("Write with ByteAddr = 8, 12 Bytes -- word aligned") ;
    PushBurstIncrement(WriteBurstFifo, 3, 12) ;
    WriteBurst(ManagerRec, X"0000_0008", 12) ;

    ReadBurst (ManagerRec, X"0000_0008", 12) ;
    CheckBurstIncrement(ReadBurstFifo, 3, 12) ;
    
    log("Write with ByteAddr = x1A, 13 Bytes -- unaligned") ;
    PushBurst(WriteBurstFifo, (1,3,5,7,9,11,13,15,17,19,21,23,25)) ;
    WriteBurst(ManagerRec, X"0000_001A", 13) ;

    ReadBurst (ManagerRec, X"0000_001A", 13) ;
    CheckBurst(ReadBurstFifo, (1,3,5,7,9,11,13,15,17,19,21,23,25)) ;

    log("Write with ByteAddr = 31, 12 Bytes -- unaligned") ;
    PushBurstRandom(WriteBurstFifo, 7, 12) ;
    WriteBurst(ManagerRec, X"0000_0031", 12) ;

    ReadBurst (ManagerRec, X"0000_0031", 12) ;
    CheckBurstRandom(ReadBurstFifo, 7, 12) ;

    log("Write with ByteAddr = 8, 12 Bytes -- word aligned") ;
    PushBurstIncrement(WriteBurstFifo, 1, 16) ;
    WriteBurst(ManagerRec, X"0000_0050", 1) ;
    WriteBurst(ManagerRec, X"0000_0051", 1) ;
    WriteBurst(ManagerRec, X"0000_0052", 1) ;
    WriteBurst(ManagerRec, X"0000_0053", 1) ;
    
    WriteBurst(ManagerRec, X"0000_0060", 2) ;
    WriteBurst(ManagerRec, X"0000_0062", 2) ;
    WriteBurst(ManagerRec, X"0000_0065", 2) ;
    
    WriteBurst(ManagerRec, X"0000_0070", 3) ;
    WriteBurst(ManagerRec, X"0000_0075", 3) ;


    ReadBurst (ManagerRec, X"0000_0050", 1) ;
    CheckBurst(ReadBurstFifo, (1 => 1)) ;
    ReadBurst (ManagerRec, X"0000_0051", 1) ;
    CheckBurst(ReadBurstFifo, (1 => 2)) ;
    ReadBurst (ManagerRec, X"0000_0052", 1) ;
    CheckBurst(ReadBurstFifo, (1 => 3)) ;
    ReadBurst (ManagerRec, X"0000_0053", 1) ;
    CheckBurst(ReadBurstFifo, (1 => 4)) ;
    
    ReadBurst (ManagerRec, X"0000_0060", 2) ;
    CheckBurst(ReadBurstFifo, (5, 6)) ;
    ReadBurst (ManagerRec, X"0000_0062", 2) ;
    CheckBurst(ReadBurstFifo, (7, 8)) ;
    ReadBurst (ManagerRec, X"0000_0065", 2) ;
    CheckBurst(ReadBurstFifo, (9, 10)) ;

    ReadBurst (ManagerRec, X"0000_0070", 3) ;
    CheckBurst(ReadBurstFifo, (11, 12, 13)) ;
    ReadBurst (ManagerRec, X"0000_0075", 3) ;
    CheckBurst(ReadBurstFifo, (14, 15, 16)) ;

    WaitForBarrier(WriteDone) ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MasterProc ;


  ------------------------------------------------------------
  -- AxiMemoryProc
  --   Generate transactions for AxiResponder
  ------------------------------------------------------------
  AxiMemoryProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ; 
    alias AxiMemoryTransRec is SubordinateRec ;        
  begin
    WaitForClock(AxiMemoryTransRec, 2) ; 
    
    
    WaitForBarrier(WriteDone) ;

    -- Check that write burst was received correctly
    ReadCheck(AxiMemoryTransRec, X"0000_0008", X"0605_0403") ;
    ReadCheck(AxiMemoryTransRec, X"0000_000C", X"0A09_0807") ;
    ReadCheck(AxiMemoryTransRec, X"0000_0010", X"0E0D_0C0B") ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(AxiMemoryTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiMemoryProc ;


end MemoryBurst1 ;

library osvvm_Axi4 ;

Configuration TbAxi4_MemoryBurst1 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MemoryBurst1) ; 
    end for ; 
  for Subordinate_1 : Axi4LiteSubordinate
      use entity osvvm_Axi4.Axi4LiteMemory ; 
    end for ; 
  end for ; 
end TbAxi4_MemoryBurst1 ; 
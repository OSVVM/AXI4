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
  constant BURST_MODE : AddressBusFifoBurstModeType := ADDRESS_BUS_BURST_WORD_MODE ;   
--  constant BURST_MODE : AddressBusFifoBurstModeType := ADDRESS_BUS_BURST_BYTE_MODE ;   
  constant DATA_WIDTH : integer := IfElse(BURST_MODE = ADDRESS_BUS_BURST_BYTE_MODE, 8, AXI_DATA_WIDTH)  ;  

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
  -- ManagerProc
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc : process
    variable ByteData : std_logic_vector(7 downto 0) ;
    variable BurstVal : AddressBusFifoBurstModeType ; 
  begin
    wait until nReset = '1' ;  
    WaitForClock(ManagerRec, 2) ; 
    
    GetBurstMode(ManagerRec, BurstVal) ;
    AffirmIf(BurstVal = ADDRESS_BUS_BURST_WORD_MODE, "Default BurstMode is ADDRESS_BUS_BURST_WORD_MODE " & to_string(BurstVal)) ; 
    SetBurstMode(ManagerRec, BURST_MODE) ;
    GetBurstMode(ManagerRec, BurstVal) ;
    AffirmIfEqual(BurstVal, BURST_MODE, "BurstMode") ; 
    
    log("Write with ByteAddr = 8, 12 Bytes -- word aligned") ;
    PushBurstIncrement(WriteBurstFifo, 3, 12, DATA_WIDTH) ;
    WriteBurst(ManagerRec, X"0000_0008", 12) ;

    ReadBurst (ManagerRec, X"0000_0008", 12) ;
    CheckBurstIncrement(ReadBurstFifo, 3, 12, DATA_WIDTH) ;
    
    log("Write with ByteAddr = x1A, 13 Bytes -- unaligned") ;
    Push(WriteBurstFifo, X"0001_UUUU") ;
    PushBurst(WriteBurstFifo, (3,5,7,9,11,13,15,17,19,21,23,25), DATA_WIDTH) ;
    WriteBurst(ManagerRec, X"0000_100A", 13) ;

    ReadBurst (ManagerRec, X"0000_100A", 13) ;
    CheckExpected(ReadBurstFifo, X"0001_----") ; -- First Byte not aligned
    CheckBurst(ReadBurstFifo, (3,5,7,9,11,13,15,17,19,21,23,25), DATA_WIDTH) ;

    log("Write with ByteAddr = 31, 12 Bytes -- unaligned") ;
    Push(WriteBurstFifo, X"A015_28UU") ; 
    PushBurstRandom(WriteBurstFifo, 7, 12, DATA_WIDTH) ;

    WriteBurst(ManagerRec, X"0000_3001", 13) ;

    ReadBurst (ManagerRec, X"0000_3001", 13) ;
    CheckExpected(ReadBurstFifo, X"A015_28--") ; -- First Byte not aligned
    CheckBurstRandom(ReadBurstFifo, 7, 12, DATA_WIDTH) ;

    log("Write with ByteAddr = 8, 12 Bytes -- word aligned") ;
    Push(WriteBurstFifo, X"UUUU_UU01") ;
    Push(WriteBurstFifo, X"UUUU_02UU") ;
    Push(WriteBurstFifo, X"UU03_UUUU") ;
    Push(WriteBurstFifo, X"04UU_UUUU") ;
    
    Push(WriteBurstFifo, X"UUUU_0605") ;
    Push(WriteBurstFifo, X"UU08_07UU") ;
    Push(WriteBurstFifo, X"0A09_UUUU") ;

    Push(WriteBurstFifo, X"UU0D_0C0B") ;
    Push(WriteBurstFifo, X"100F_0EUU") ;
    
    WriteBurst(ManagerRec, X"0000_5050", 1) ;
    WriteBurst(ManagerRec, X"0000_5051", 1) ;
    WriteBurst(ManagerRec, X"0000_5052", 1) ;
    WriteBurst(ManagerRec, X"0000_5053", 1) ;
    
    WriteBurst(ManagerRec, X"0000_5060", 1) ;
    WriteBurst(ManagerRec, X"0000_5071", 1) ;
    WriteBurst(ManagerRec, X"0000_5082", 1) ;
    
    WriteBurst(ManagerRec, X"0000_5090", 1) ;
    WriteBurst(ManagerRec, X"0000_50A1", 1) ;


    ReadBurst (ManagerRec, X"0000_5050", 1) ;
    ReadBurst (ManagerRec, X"0000_5051", 1) ;
    ReadBurst (ManagerRec, X"0000_5052", 1) ;
    ReadBurst (ManagerRec, X"0000_5053", 1) ;
    
    ReadBurst (ManagerRec, X"0000_5060", 1) ;
    ReadBurst (ManagerRec, X"0000_5071", 1) ;
    ReadBurst (ManagerRec, X"0000_5082", 1) ;

    ReadBurst (ManagerRec, X"0000_5090", 1) ;
    ReadBurst (ManagerRec, X"0000_50A1", 1) ;
    
    CheckExpected(ReadBurstFifo, X"----_--01") ;
    CheckExpected(ReadBurstFifo, X"----_02--") ;
    CheckExpected(ReadBurstFifo, X"--03_----") ;
    CheckExpected(ReadBurstFifo, X"04--_----") ;

    CheckExpected(ReadBurstFifo, X"----_0605") ;
    CheckExpected(ReadBurstFifo, X"--08_07--") ;
    CheckExpected(ReadBurstFifo, X"0A09_----") ;

    CheckExpected(ReadBurstFifo, X"--0D_0C0B") ;
    CheckExpected(ReadBurstFifo, X"100F_0E--") ;

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

    -- Check that write burst was received correctly
    ReadCheck(SubordinateRec, X"0000_0008", X"0000_0003") ;
    ReadCheck(SubordinateRec, X"0000_000C", X"0000_0004") ;
    ReadCheck(SubordinateRec, X"0000_0010", X"0000_0005") ;
    ReadCheck(SubordinateRec, X"0000_0014", X"0000_0006") ;
    ReadCheck(SubordinateRec, X"0000_0018", X"0000_0007") ;
    ReadCheck(SubordinateRec, X"0000_001C", X"0000_0008") ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MemoryProc ;


end MemoryBurst1 ;

Configuration TbAxi4_MemoryBurst1 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MemoryBurst1) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_MemoryBurst1 ; 
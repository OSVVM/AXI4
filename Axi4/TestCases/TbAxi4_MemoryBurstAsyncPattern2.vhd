--
--  File Name:         TbAxi4_MemoryBurstAsyncPattern2.vhd
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

architecture MemoryBurstAsyncPattern1 of TestCtrl is

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
    SetAlertLogName("TbAxi4_MemoryBurstAsyncPattern2") ;
    SetLogEnable(PASSED, TRUE) ;   -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;     -- Enable INFO logs
    SetLogEnable(DEBUG, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_MemoryBurstAsyncPattern2.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_MemoryBurstAsyncPattern2.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_MemoryBurstAsyncPattern2.txt", "") ; 

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
    
    log("Write with ByteAddr = 8, 256 Words -- word aligned") ;
    WriteBurstIncrementAsync(ManagerRec, X"0000_0008", DATA_ZERO+1, 256) ;
    -- Allow Numerous Writes to complete
    WaitForClock(ManagerRec, 240) ; 
    ReadCheckBurstIncrement(ManagerRec, X"0000_0008", DATA_ZERO+1, 256) ;
    

--    log("Write with ByteAddr = x1A, 13 Words -- unaligned") ;
--    WriteBurstVectorAsync(ManagerRec, X"0000_100A", 
--        (X"0001_UUUU", DATA_ZERO+3,  DATA_ZERO+5,  DATA_ZERO+7,  DATA_ZERO+9,
--        DATA_ZERO+11,  DATA_ZERO+13, DATA_ZERO+15, DATA_ZERO+17, DATA_ZERO+19,
--        DATA_ZERO+21,  DATA_ZERO+23, DATA_ZERO+25) ) ;
--
--    log("Write with ByteAddr = 31, 12 Bytes -- unaligned") ;
--    WriteBurstRandomAsync(ManagerRec, X"0000_3001", X"A015_2800", 13) ;
--    
--    WaitForTransaction(ManagerRec) ;
--
--    ReadCheckBurstIncrement(ManagerRec, X"0000_0008", DATA_ZERO+3, 12) ;
--    
--    ReadCheckBurstVector(ManagerRec, X"0000_100A", 
--        (X"0001_----", DATA_ZERO+3,  DATA_ZERO+5,  DATA_ZERO+7,  DATA_ZERO+9,
--        DATA_ZERO+11,  DATA_ZERO+13, DATA_ZERO+15, DATA_ZERO+17, DATA_ZERO+19,
--        DATA_ZERO+21,  DATA_ZERO+23, DATA_ZERO+25) ) ;
--
--    ReadCheckBurstRandom(ManagerRec, X"0000_3001", X"A015_28UU", 13) ;
--
--    log("Write with ByteAddr = 8, 12 Bytes -- word aligned") ;
--    WriteBurstVectorAsync(ManagerRec, X"0000_5050", (1 => X"UUUU_UU01")) ;
--    WriteBurstVectorAsync(ManagerRec, X"0000_5051", (1 => X"UUUU_02UU")) ;
--    WriteBurstVectorAsync(ManagerRec, X"0000_5052", (1 => X"UU03_UUUU")) ;
--    WriteBurstVectorAsync(ManagerRec, X"0000_5053", (1 => X"04UU_UUUU")) ;
--
--    WriteBurstVectorAsync(ManagerRec, X"0000_5060", (1 => X"UUUU_0605")) ;
--    WriteBurstVectorAsync(ManagerRec, X"0000_5071", (1 => X"UU08_07UU")) ;
--    WriteBurstVectorAsync(ManagerRec, X"0000_5082", (1 => X"0A09_UUUU")) ;
--
--    WriteBurstVectorAsync(ManagerRec, X"0000_5090", (1 => X"UU0D_0C0B")) ;
--    WriteBurstVectorAsync(ManagerRec, X"0000_50A1", (1 => X"100F_0EUU")) ;
--
--    WaitForWriteTransaction(ManagerRec) ;
--
--    ReadCheckBurstVector (ManagerRec, X"0000_5050", (1 => X"----_--01")) ;
--    ReadCheckBurstVector (ManagerRec, X"0000_5051", (1 => X"----_02--")) ;
--    ReadCheckBurstVector (ManagerRec, X"0000_5052", (1 => X"--03_----")) ;
--    ReadCheckBurstVector (ManagerRec, X"0000_5053", (1 => X"04--_----")) ;
--
--    ReadCheckBurstVector (ManagerRec, X"0000_5060", (1 => X"----_0605")) ;
--    ReadCheckBurstVector (ManagerRec, X"0000_5071", (1 => X"--08_07--")) ;
--    ReadCheckBurstVector (ManagerRec, X"0000_5082", (1 => X"0A09_----")) ;
--
--    ReadCheckBurstVector (ManagerRec, X"0000_5090", (1 => X"--0D_0C0B")) ;
--    ReadCheckBurstVector (ManagerRec, X"0000_50A1", (1 => X"100F_0E--")) ;
--
--    WaitForBarrier(WriteDone) ;
    
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
    
    
--    WaitForBarrier(WriteDone) ;
--
--    -- Check that write burst was received correctly
--    ReadCheck(SubordinateRec, X"0000_0008", X"0000_0003") ;
--    ReadCheck(SubordinateRec, X"0000_000C", X"0000_0004") ;
--    ReadCheck(SubordinateRec, X"0000_0010", X"0000_0005") ;
--    ReadCheck(SubordinateRec, X"0000_0014", X"0000_0006") ;
--    ReadCheck(SubordinateRec, X"0000_0018", X"0000_0007") ;
--    ReadCheck(SubordinateRec, X"0000_001C", X"0000_0008") ;
--
--    -- Wait for outputs to propagate and signal TestDone
--    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MemoryProc ;


end MemoryBurstAsyncPattern1 ;

Configuration TbAxi4_MemoryBurstAsyncPattern2 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MemoryBurstAsyncPattern1) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_MemoryBurstAsyncPattern2 ; 
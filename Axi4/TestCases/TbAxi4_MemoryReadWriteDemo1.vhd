--
--  File Name:         TbAxi4_MemoryReadWriteDemo1.vhd
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

architecture MemoryReadWriteDemo1 of TestCtrl is

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
    SetAlertLogName("TbAxi4_MemoryReadWriteDemo1") ;
    SetLogEnable(PASSED, TRUE) ;   -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;     -- Enable INFO logs
    SetLogEnable(DEBUG, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_MemoryReadWriteDemo1.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_MemoryReadWriteDemo1.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_MemoryReadWriteDemo1.txt", "") ;

    EndOfTestReports ;
    std.env.stop(GetAlertCount) ;
    wait ;
  end process ControlProc ;

  ------------------------------------------------------------
  -- ManagerProc
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc : process
    variable BurstVal  : AddressBusFifoBurstModeType ;
    variable RxData    : std_logic_vector(31 downto 0) ;
    constant DATA_ZERO : std_logic_vector := (DATA_WIDTH - 1 downto 0 => '0') ;
    variable CoverID1, CoverID2 : CoverageIdType ;
    variable slvBurstVector : slv_vector(1 to 5)(31 downto 0) ;
    variable intBurstVector : integer_vector(1 to 5) ;
  begin
    wait until nReset = '1' ;
    WaitForClock(ManagerRec, 2) ;

    GetBurstMode(ManagerRec, BurstVal) ;
    AffirmIf(BurstVal = ADDRESS_BUS_BURST_WORD_MODE, "Default BurstMode is ADDRESS_BUS_BURST_WORD_MODE " & to_string(BurstVal)) ;
    SetBurstMode(ManagerRec, BURST_MODE) ;
    GetBurstMode(ManagerRec, BurstVal) ;
    AffirmIfEqual(BurstVal, BURST_MODE, "BurstMode") ;

-- Write and Read
    log("Write and Read. Addr = 0000.  16 words") ;
    for I in 1 to 16 loop
      Write( ManagerRec, X"0000_0000" + 16*I, X"0000_0000" + I ) ;
    end loop ;

    for I in 1 to 16 loop
      Read ( ManagerRec, X"0000_0000" + 16*I, RxData) ;
      AffirmIfEqual(RxData, X"0000_0000" + I, "Read Data " ) ;
    end loop ;

-- Write and ReadCheck
    log("Write and ReadCheck. Addr = 1000.  16 words") ;
    for I in 1 to 16 loop
      Write( ManagerRec, X"0000_1000" + 16*I, X"0000_1000" + I ) ;
    end loop ;

    for I in 1 to 16 loop
      ReadCheck ( ManagerRec, X"0000_1000" + 16*I, X"0000_1000" + I ) ;
    end loop ;

-- WriteBurst and ReadBurst
    log("WriteBurst and ReadBurst.  Addr = 2000.  16 words") ;
    for I in 1 to 16 loop
      Push( ManagerRec.WriteBurstFifo, X"0000_2000" + I  ) ;
    end loop ;
    WriteBurst(ManagerRec, X"0000_2000", 16) ;

    ReadBurst(ManagerRec, X"0000_2000", 16) ;
    for I in 1 to 16 loop
      CheckExpected( ManagerRec.ReadBurstFifo, X"0000_2000" + I  ) ;
    end loop ;

-- Burst Vector
    log("Burst Vector.  Addr = 3000, 13 Words -- unaligned") ;
    WriteBurstVector(ManagerRec, X"0000_3000",
        (X"0001_UUUU", DATA_ZERO+3,  DATA_ZERO+5,  DATA_ZERO+7,  DATA_ZERO+9,
        DATA_ZERO+11,  DATA_ZERO+13, DATA_ZERO+15, DATA_ZERO+17, DATA_ZERO+19,
        DATA_ZERO+21,  DATA_ZERO+23, DATA_ZERO+25) ) ;

    ReadCheckBurstVector(ManagerRec, X"0000_3000",
        (X"0001_----", DATA_ZERO+3,  DATA_ZERO+5,  DATA_ZERO+7,  DATA_ZERO+9,
        DATA_ZERO+11,  DATA_ZERO+13, DATA_ZERO+15, DATA_ZERO+17, DATA_ZERO+19,
        DATA_ZERO+21,  DATA_ZERO+23, DATA_ZERO+25) ) ;

-- Burst Increment
    log("Burst Increment.  Addr = 4000, 12 Words -- word aligned") ;
    WriteBurstIncrement    (ManagerRec, X"0000_4000", X"0000_4000"+3, 12) ;

    ReadCheckBurstIncrement(ManagerRec, X"0000_4000", X"0000_4000"+3, 12) ;

-- Burst Random
    log("Burst Random. Addr = 5001, 13 Words -- unaligned") ;
    WriteBurstRandom    (ManagerRec, X"0000_5001", X"A015_2800", 13) ;

    ReadCheckBurstRandom(ManagerRec, X"0000_5001", X"A015_28UU", 13) ;

-- Burst Coverage Driven Random
    log("Burst Coverage Driven Random. Addr = 6000, 12 Words") ;
    CoverID1 := NewID("Cov1") ;
    InitSeed(CoverID1, 5) ; -- Start Write and Read with the same seed value
    AddBins (CoverID1, 1, GenBin(0,7) & GenBin(32,39) & GenBin(64,71) & GenBin(96,103)) ;
    WriteBurstRandom(    ManagerRec, X"0000_6000", CoverID1, 12, DATA_WIDTH) ;
    
    CoverID2 := NewID("Cov2") ;
    InitSeed(CoverID2, 5) ; -- Start Write and Read with the same seed value
    AddBins (CoverID2, 1, GenBin(0,7) & GenBin(32,39) & GenBin(64,71) & GenBin(96,103)) ;
    ReadCheckBurstRandom(ManagerRec, X"0000_6000", CoverID2, 12, DATA_WIDTH) ;

-- Burst Combining Patterns
    log("Combining Patterns:  Vector, Increment, Random, Intelligent Coverage") ;
    PushBurstVector(ManagerRec.WriteBurstFifo,
        (X"0000_B001", X"0000_B003", X"0000_B005", X"0000_B007", X"0000_B009",
         X"0000_B011", X"0000_B013", X"0000_B015", X"0000_B017", X"0000_B019") ) ;
    PushBurstIncrement(ManagerRec.WriteBurstFifo, X"0000_B100", 10) ;
    PushBurstRandom(ManagerRec.WriteBurstFifo, X"0000_B200", 6) ;
    CoverID1 := NewID("Cov1b") ;
    InitSeed(CoverID1, 5) ; -- Start Write and Read with the same seed value
    AddBins(CoverID1, 1,
        GenBin(16#B300#, 16#B307#) & GenBin(16#B310#, 16#B317#) &
        GenBin(16#B320#, 16#B327#) & GenBin(16#B330#, 16#B337#)) ;
    PushBurstRandom(ManagerRec.WriteBurstFifo, CoverID1, 16, 32) ;
    WriteBurst(ManagerRec, X"0000_B000", 42) ;

    ReadBurst (ManagerRec, X"0000_B000", 42) ;
    CheckBurstVector(ManagerRec.ReadBurstFifo,
        (X"0000_B001", X"0000_B003", X"0000_B005", X"0000_B007", X"0000_B009",
         X"0000_B011", X"0000_B013", X"0000_B015", X"0000_B017", X"0000_B019") ) ;
    CheckBurstIncrement(ManagerRec.ReadBurstFifo, X"0000_B100", 10) ;
    CheckBurstRandom(ManagerRec.ReadBurstFifo, X"0000_B200", 6) ;
    CoverID2 := NewID("Cov2b") ;
    InitSeed(CoverID2, 5) ; -- Start Write and Read with the same seed value
    AddBins(CoverID2, 1,
        GenBin(16#B300#, 16#B307#) & GenBin(16#B310#, 16#B317#) &
        GenBin(16#B320#, 16#B327#) & GenBin(16#B330#, 16#B337#)) ;
    CheckBurstRandom(ManagerRec.ReadBurstFifo, CoverID2, 16, 32) ;

-- WriteBurstVector - PopBurstVector slv_vector
    log("WriteBurstVector 5 word burst") ;
    WriteBurstVector(ManagerRec, X"0000_C000",
        (X"0000_C001", X"0000_C003", X"0000_C005", X"0000_C007", X"0000_C009") ) ;

    ReadBurst(ManagerRec, X"0000_C000", 5) ;
    PopBurstVector(ManagerRec.ReadBurstFifo, slvBurstVector) ;
    AffirmIf(slvBurstVector =
        (X"0000_C001", X"0000_C003", X"0000_C005", X"0000_C007", X"0000_C009"),
        "slvBurstVector = C001, C003, C005, C007, C009") ; --  & to_string(slvBurstVector)) ; -- to_string in 2019

-- SendBurstVector - PopBurstVector integer_vector
    log("SendBurstVector 5 word burst") ;
    PushBurstVector(ManagerRec.WriteBurstFifo,
        (16#D001#, 16#D003#, 16#D005#, 16#D007#, 16#D009#), 32 ) ;
    WriteBurst(ManagerRec, X"0000_D000", 5) ;

    ReadBurst(ManagerRec, X"0000_D000", 5) ;
    PopBurstVector(ManagerRec.ReadBurstFifo, intBurstVector) ;
    AffirmIf(intBurstVector =
        (16#D001#, 16#D003#, 16#D005#, 16#D007#, 16#D009#),
        "slvBurstVector = D001, D003, D005, D007, D009") ; -- & to_string(slvBurstVector)) ; -- to_string in 2019

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


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MemoryProc ;


end MemoryReadWriteDemo1 ;

Configuration TbAxi4_MemoryReadWriteDemo1 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MemoryReadWriteDemo1) ;
    end for ;
--!!    for Subordinate_1 : Axi4Subordinate
--!!      use entity OSVVM_AXI4.Axi4Memory ;
--!!    end for ;
  end for ;
end TbAxi4_MemoryReadWriteDemo1 ;
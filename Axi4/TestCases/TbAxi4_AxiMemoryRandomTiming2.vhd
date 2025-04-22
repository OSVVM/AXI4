--
--  File Name:         TbAxi4_AxiMemoryRandomTiming2.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Testing of Burst Features in AxiMemory Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    04/2025   2025.04    Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2025 by SynthWorks Design Inc.
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

architecture AxiMemoryRandomTiming2 of TestCtrl is

  signal SyncPoint, TestDone, WriteDone : integer_barrier := 1 ;
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
    SetTestName("TbAxi4_AxiMemoryRandomTiming2") ;
    SetLogEnable(PASSED, TRUE) ;   -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;     -- Enable INFO logs
    -- SetLogEnable(DEBUG, TRUE) ;    -- Enable DEBUG logs

    -- Wait for testbench initialization
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen ;
    SetTranscriptMirror(TRUE) ;

    -- Wait for Design Reset
    wait until nReset = '1' ;
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 10 ms) ;

    TranscriptClose ;
    -- Printing differs in different simulators due to differences in process order execution
    -- AffirmIfTranscriptsMatch("../AXI4/Axi4/testbench/validated_results") ;

    EndOfTestReports(TimeOut => (now >= 10 ms)) ;
    std.env.stop ;
    wait ;
  end process ControlProc ;

  ------------------------------------------------------------
  -- ManagerProc
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc : process
  begin
    wait until nReset = '1' ;
    WaitForClock(ManagerRec, 2) ;

    -- Use Coverage based delays
--    SetUseRandomDelays(ManagerRec) ; 

    BlankLine ; 
    Print("-----------------------------------------------------------------") ;
    log("Write and Read 32 words. Addr = 0000_0000 + 16*i.") ;
    BlankLine ; 
    for I in 1 to 32 loop
      WriteAsync  ( ManagerRec, X"0000_0000" + 16*I, X"0000_0000" + 16*I ) ;
    end loop ;

    WaitForTransaction(ManagerRec) ; 

    for I in 1 to 32 loop
      ReadAddressAsync ( ManagerRec, X"0000_0000" + 16*I) ;
    end loop ;
    for I in 1 to 32 loop
      ReadCheckData    ( ManagerRec, X"0000_0000" + 16*I ) ;
    end loop ;

    BlankLine ; 
    Print("-----------------------------------------------------------------") ;
    log("Write and Read 3 bursts of 16 words. Addr = 0000_1000 + 256*i.") ;
    BlankLine ; 
    for i in 1 to 3 loop 
      WriteBurstIncrementAsync    (ManagerRec, X"0000_1000" + 256*I, X"0000_1000" + 16*I, 16) ;
    end loop ;

    WaitForTransaction(ManagerRec) ; 

    for I in 1 to 3 loop
      ReadCheckBurstIncrement(ManagerRec, X"0000_1000" + 256*I, X"0000_1000" + 16*I, 16) ;
    end loop ;

    WaitForClock(ManagerRec, 2) ;

    WaitForBarrier(TestDone) ;
    wait ;

  end process ManagerProc ;


  ------------------------------------------------------------
  -- MemoryProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  MemoryProc : process
    variable DelayCovID, NewDelayCovID       : AxiDelayCoverageIdArrayType ; 
    variable TbID : AlertLogIDType ;
  begin
    -- Use Coverage based delays
    SetUseRandomDelays(SubordinateRec) ; 

    -- Testing AXI Specific Random Delay Capability
    GetDelayCoverageID(SubordinateRec, DelayCovID) ; 

    TbID := NewID("TbID") ;

    NewDelayCovID(WRITE_ADDRESS_ID)    := NewID("WriteAddrDelayCov",   TbID, ReportMode => DISABLED, Search => PRIVATE_NAME) ; 
    NewDelayCovID(WRITE_DATA_ID)       := NewID("WriteDataDelayCov",   TbID, ReportMode => DISABLED, Search => PRIVATE_NAME) ; 
    NewDelayCovID(WRITE_RESPONSE_ID)   := NewID("WriteRespDelayCov",   TbID, ReportMode => DISABLED, Search => PRIVATE_NAME) ; 
    NewDelayCovID(READ_ADDRESS_ID)     := NewID("ReadAddrDelayCov",    TbID, ReportMode => DISABLED, Search => PRIVATE_NAME) ; 
    NewDelayCovID(READ_DATA_ID)        := NewID("ReadDataDelayCov",    TbID, ReportMode => DISABLED, Search => PRIVATE_NAME) ; 

    -- Change all of the Coverage Bins
    AddBins (NewDelayCovID(WRITE_ADDRESS_ID).BurstLengthCov,    GenBin(7)) ; 
    AddCross(NewDelayCovID(WRITE_ADDRESS_ID).BurstDelayCov,     GenBin(0), GenBin(1)) ;
    AddCross(NewDelayCovID(WRITE_ADDRESS_ID).BeatDelayCov,      GenBin(0), GenBin(0)) ;

    AddBins (NewDelayCovID(WRITE_DATA_ID).BurstLengthCov,       GenBin(6)) ; 
    AddCross(NewDelayCovID(WRITE_DATA_ID).BurstDelayCov,        GenBin(1), GenBin(4)) ;
    AddCross(NewDelayCovID(WRITE_DATA_ID).BeatDelayCov,         GenBin(0), GenBin(0)) ;

    AddBins (NewDelayCovID(WRITE_RESPONSE_ID).BurstLengthCov,  GenBin(4)) ;
    AddBins (NewDelayCovID(WRITE_RESPONSE_ID).BurstDelayCov,   GenBin(3)) ;
    AddBins (NewDelayCovID(WRITE_RESPONSE_ID).BeatDelayCov,    GenBin(0)) ;

    AddBins (NewDelayCovID(READ_ADDRESS_ID).BurstLengthCov,     GenBin(8)) ; 
    AddCross(NewDelayCovID(READ_ADDRESS_ID).BurstDelayCov,      GenBin(1), GenBin(3)) ;
    AddCross(NewDelayCovID(READ_ADDRESS_ID).BeatDelayCov,       GenBin(0), GenBin(0)) ;

    AddBins (NewDelayCovID(READ_DATA_ID).BurstLengthCov,       GenBin(6)) ;
    AddBins (NewDelayCovID(READ_DATA_ID).BurstDelayCov,        GenBin(5)) ;
    AddBins (NewDelayCovID(READ_DATA_ID).BeatDelayCov,         GenBin(0)) ;

    SetDelayCoverageID(SubordinateRec, NewDelayCovID) ; 

    --
    -- At this point, the Axi4Memory responds to the transactions from the 
    -- Axi4Manager using the updated DelayCoverage models above
    --

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MemoryProc ;
end AxiMemoryRandomTiming2 ;

Configuration TbAxi4_AxiMemoryRandomTiming2 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiMemoryRandomTiming2) ;
    end for ;
  end for ;
end TbAxi4_AxiMemoryRandomTiming2 ;
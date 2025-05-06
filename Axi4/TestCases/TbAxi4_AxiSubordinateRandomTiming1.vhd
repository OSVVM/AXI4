--
--  File Name:         TbAxi4_AxiSubordinateRandomTiming1.vhd
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
--    04/2025   2024.05    Initial revision
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

architecture AxiSubordinateRandomTiming1 of TestCtrl is

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
    SetTestName("TbAxi4_AxiSubordinateRandomTiming1") ;
    SetLogEnable(PASSED, TRUE) ;   -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;     -- Enable INFO logs
    -- SetLogEnable(DEBUG, TRUE) ;    -- Enable INFO logs

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

    EndOfTestReports (TimeOut => (now >= 10 ms)) ;
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

    for I in 1 to 64 loop
      WriteAsync  ( ManagerRec, X"0000_0000" + 16*I, X"0000_0000" + I ) ;
    end loop ;

    WaitForTransaction(ManagerRec) ; 

    for I in 1 to 64 loop
      ReadAddressAsync ( ManagerRec, X"0000_0000" + 16*I) ;
    end loop ;
    for I in 1 to 64 loop
      ReadCheckData    ( ManagerRec, X"0000_0000" + I ) ;
    end loop ;
    WaitForTransaction(ManagerRec) ; 
    WaitForClock(ManagerRec, 2) ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc ;

  ------------------------------------------------------------
  -- SubordinateProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  SubordinateProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
    variable DelayCovID       : AxiDelayCoverageIdArrayType ; 
  begin
    WaitForClock(SubordinateRec, 1) ;

    SetUseRandomDelays(SubordinateRec) ; 
    GetDelayCoverageID(SubordinateRec, DelayCovID) ; 

    -- Change all of the Coverage Bins
    DeallocateBins(DelayCovID(WRITE_ADDRESS_ID)) ;  -- Remove old coverage model
    AddBins (DelayCovID(WRITE_ADDRESS_ID).BurstLengthCov,    GenBin(7)) ; 
    AddCross(DelayCovID(WRITE_ADDRESS_ID).BurstDelayCov,     GenBin(1), GenBin(2)) ;
    AddCross(DelayCovID(WRITE_ADDRESS_ID).BeatDelayCov,      GenBin(0), GenBin(0)) ;

    DeallocateBins(DelayCovID(WRITE_DATA_ID)) ;  -- Remove old coverage model
    AddBins (DelayCovID(WRITE_DATA_ID).BurstLengthCov,       GenBin(6)) ; 
    AddCross(DelayCovID(WRITE_DATA_ID).BurstDelayCov,        GenBin(1), GenBin(4)) ;
    AddCross(DelayCovID(WRITE_DATA_ID).BeatDelayCov,         GenBin(0), GenBin(0)) ;

    DeallocateBins(DelayCovID(WRITE_RESPONSE_ID)) ;  -- Remove old coverage model
    AddBins (DelayCovID(WRITE_RESPONSE_ID).BurstLengthCov,  GenBin(4)) ;
    AddBins (DelayCovID(WRITE_RESPONSE_ID).BurstDelayCov,   GenBin(3)) ;
    AddBins (DelayCovID(WRITE_RESPONSE_ID).BeatDelayCov,    GenBin(0)) ;
    -- Write Response timing is influenced by both WriteAddress and WriteData timing

    DeallocateBins(DelayCovID(READ_ADDRESS_ID)) ;  -- Remove old coverage model
    AddBins (DelayCovID(READ_ADDRESS_ID).BurstLengthCov,     GenBin(8)) ; 
    AddCross(DelayCovID(READ_ADDRESS_ID).BurstDelayCov,      GenBin(1), GenBin(3)) ;
    AddCross(DelayCovID(READ_ADDRESS_ID).BeatDelayCov,       GenBin(0), GenBin(0)) ;

    DeallocateBins(DelayCovID(READ_DATA_ID)) ;  -- Remove old coverage model
    AddBins (DelayCovID(READ_DATA_ID).BurstLengthCov,       GenBin(6)) ;
    AddBins (DelayCovID(READ_DATA_ID).BurstDelayCov,        GenBin(5)) ;
    AddBins (DelayCovID(READ_DATA_ID).BeatDelayCov,         GenBin(0)) ;

    WaitForClock(SubordinateRec, 2) ;
    
    -- Check Single transactions
    for I in 1 to 64 loop
--      Write     ( ManagerRec, X"0000_0000" + 16*I, X"0000_0000" + I ) ;
      GetWrite(SubordinateRec, Addr, Data) ;
      AffirmIfEqual(Addr, X"0000_0000" + 16*I, "Subordinate Write Addr: ") ;
      AffirmIfEqual(Data, X"0000_0000" + I, "Subordinate Write Data: ") ;
    end loop ;
    
    for I in 1 to 64 loop
--      ReadCheck ( ManagerRec, X"0000_0000" + 16*I, X"0000_0000" + I ) ;
      SendRead(SubordinateRec, Addr, X"0000_0000" + I) ; 
      AffirmIfEqual(Addr, X"0000_0000" + 16*I, "Subordinate Read Addr: ") ;
    end loop ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;


end AxiSubordinateRandomTiming1 ;

Configuration TbAxi4_AxiSubordinateRandomTiming1 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiSubordinateRandomTiming1) ;
    end for ;
  end for ;
end TbAxi4_AxiSubordinateRandomTiming1 ;

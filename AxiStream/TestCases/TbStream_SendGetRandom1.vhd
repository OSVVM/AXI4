--
--  File Name:         TbStream_SendGetRandom1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--    Validates AxiStream usage of delay randomization for TReady and TValid
--    Demonstrates how to:
--      1) Activate the VC's internal randomization capability
--      2) Change the randomization values by overwriting the existing ones
--      3) Swap between two different settings quickly
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    04/2023   2023.04    Initial.   Tests delay randomization
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2023 by SynthWorks Design Inc.
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
architecture SendGetRandom1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
  signal   TbID : AlertLogIDType ;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbStream_SendGetRandom1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    TbID <= NewID("Testbench") ;

    -- Wait for simulation elaboration/initialization
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen ;
    SetTranscriptMirror(TRUE) ;

    -- Wait for Design Reset
    wait until nReset = '1' ;
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");

    TranscriptClose ;
    -- AffirmIfNotDiff(GetTranscriptName, OSVVM_VALIDATED_RESULTS_DIR & GetTranscriptName, "") ;

    -- Expecting two check errors at 128 and 256
    EndOfTestReports(ExternalErrors => (0, 0, 0)) ;
    std.env.stop ;
    wait ;
  end process ControlProc ;


  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  TransmitterProc : process
    variable DelayCoverageID, DelayCoverageID_random : DelayCoverageIDType ;
    variable BaseWord, BurstWord : std_logic_vector(31 downto 0) := X"0000_0000" ;
  begin

    wait until nReset = '1' ;
    WaitForClock(StreamTxRec, 2) ;
    SetUseDelayCoverage(StreamTxRec) ;

    -- Send
    log("Transmit 256 words") ;
    BaseWord := BaseWord + X"0001_0000" ;
    for I in 1 to 256 loop
      Send( StreamTxRec, BaseWord + I ) ;
    end loop ;
    
    BurstWord := BaseWord ; 
    log("SendBurstIncrement 8 bursts of size 8") ;
    for i in 1 to 32 loop
      BurstWord := BurstWord + X"0000_1000" ;
      SendBurstIncrement(StreamTxRec, BurstWord, 8) ;
    end loop ;

    WaitForClock(StreamTxRec, 4) ;

    -- Get the DelayCoverageID and CoverageIDs in use by the VC
    -- Note that DelayCoverageID has a copy of the CoverageIDs that are in the DelayCoveragePkg singleton
    GetDelayCoverageID(StreamTxRec, DelayCoverageID) ;

    -- Remove Delay Coverage Bins that are referenced by CoverageIDs referenced in DelayCoverageID
    DeallocateBins(DelayCoverageID) ;

    -- Create New Coverage Models that are not random
    -- Use BurstDelay once every 4 transfers, Use BeatDelay otherwise (the other three)
    -- This is using the coverage IDs that were previously retrieved
    AddBins(DelayCoverageID.BurstLengthCov, GenBin(4)) ;
    -- Burst delay will be exactly 4
    AddBins(DelayCoverageID.BurstDelayCov, GenBin(4)) ;
    -- Burst delay will be exactly 1
    AddBins(DelayCoverageID.BeatDelayCov,  GenBin(1)) ;

    -- Send
    log("Transmit 32 words") ;
    BaseWord := BaseWord + X"0001_0000" ;
    for i in 1 to 32 loop
      Send( StreamTxRec, BaseWord + I ) ;
    end loop ;

    log("SendBurstIncrement 8 bursts of size 8") ;
    BurstWord := BaseWord ; 
    for i in 1 to 8 loop
      BurstWord := BurstWord + X"0000_1000" ;
      SendBurstIncrement(StreamTxRec, BurstWord, 8) ;
    end loop ;

    WaitForClock(StreamTxRec, 4) ;

    -- Create another coverage model with the same ID (reference to DelayCoveragePkg singleton) as DelayCoverageID.ID
    -- References to the coverage models are in the variable DelayCoverageID_Random
    DelayCoverageID_Random  := NewDelayCoverage(DelayCoverageID.ID, "TxRandom", TbID) ;

    -- BurstLength - once per BurstLength, use BurstDelay, otherwise use BeatDelay
    AddBins (DelayCoverageID_Random.BurstLengthCov,  80, GenBin(3,11,1)) ;     -- 80% Small Burst Length
    AddBins (DelayCoverageID_Random.BurstLengthCov,  20, GenBin(109,131,1)) ;  -- 20% Large Burst Length
    -- BurstDelay - happens at BurstLength boundaries
    AddBins (DelayCoverageID_Random.BurstDelayCov,   80, GenBin(2,8,1)) ;      -- 80% Small delay
    AddBins (DelayCoverageID_Random.BurstDelayCov,   20, GenBin(108,156,1)) ;  -- 20% Large delay
    -- BeatDelay - happens between each transfer it not at a BurstLength boundary
    AddBins (DelayCoverageID_Random.BeatDelayCov,    85, GenBin(0)) ;          -- 85% Ready Before Valid, no delay
    AddBins (DelayCoverageID_Random.BeatDelayCov,    10, GenBin(1)) ;          -- 10% Ready Before Valid, 1 cycle delay
    AddBins (DelayCoverageID_Random.BeatDelayCov,     5, GenBin(2)) ;          --  5% Ready Before Valid, 1 cycle delay

    -- Copy the CoverageIDs in DelayCoverageID_random to the DelayCoveragePkg singleton
    -- This uses DelayCoverageID_random.ID to update the coverage model used by the VC
    -- Note when DelayCoverageID_Random was created, this ID was copied from DelayCoverageID.ID so they match.
    SetDelayCoverage(DelayCoverageID_Random) ;

    -- Send
    log("Transmit 256 words") ;
    BaseWord := BaseWord + X"0001_0000" ;
    for I in 1 to 256 loop
      Send( StreamTxRec, BaseWord + I ) ;
    end loop ;
    
    BurstWord := BaseWord ; 
    log("SendBurstIncrement 8 bursts of size 8") ;
    for i in 1 to 32 loop
      BurstWord := BurstWord + X"0000_1000" ;
      SendBurstIncrement(StreamTxRec, BurstWord, 8) ;
    end loop ;

    WaitForClock(StreamTxRec, 4) ;

    -- Copy the CoverageIDs in DelayCoverageID to the DelayCoveragePkg singleton
    -- This uses DelayCoverageID.ID to update the coverage model used by the VC
    SetDelayCoverage(DelayCoverageID) ;

    -- Send
    log("Transmit 32 words") ;
    BaseWord := BaseWord + X"0001_0000" ;
    for i in 1 to 32 loop
      Send( StreamTxRec, BaseWord + I ) ;
    end loop ;

    log("SendBurstIncrement 8 bursts of size 8") ;
    BurstWord := BaseWord ; 
    for i in 1 to 8 loop
      BurstWord := BurstWord + X"0000_1000" ;
      SendBurstIncrement(StreamTxRec, BurstWord, 8) ;
    end loop ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamTxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process TransmitterProc ;


  ------------------------------------------------------------
  -- AxiReceiverProc
  --   Generate transactions for AxiReceiver
  ------------------------------------------------------------
  ReceiverProc : process
    variable DelayCoverageID, DelayCoverageID_random : DelayCoverageIDType ;
    variable BaseWord, BurstWord : std_logic_vector(31 downto 0) := X"0000_0000" ;
  begin
    WaitForClock(StreamRxRec, 1) ;
    SetUseDelayCoverage(StreamRxRec) ;
    
-- An experiment with seed to change the large random delays at the start
--    GetDelayCoverageID(StreamRxRec, DelayCoverageID) ;
--    InitSeed(DelayCoverageID.BurstDelayCov, "MaryHadALittleLamb189!") ; -- set the seed to see if what is happening is a seed pecularity
    
    -- Check
    BaseWord := BaseWord + X"0001_0000" ;
    for I in 1 to 256 loop
      Check(StreamRxRec, BaseWord + I ) ;
    end loop ;

    BurstWord := BaseWord ; 
    for i in 1 to 32 loop
      BurstWord := BurstWord + X"0000_1000" ;
      CheckBurstIncrement(StreamRxRec, BurstWord, 8) ;
    end loop ;

    WaitForClock(StreamRxRec, 3) ;

    -- Get the DelayCoverageID and CoverageIDs in use by the VC
    -- Note that DelayCoverageID has a copy of the CoverageIDs that are in the DelayCoveragePkg singleton
    GetDelayCoverageID(StreamRxRec, DelayCoverageID) ;

    -- Remove Delay Coverage Bins that are referenced by CoverageIDs referenced in DelayCoverageID
    DeallocateBins(DelayCoverageID) ;

    -- Create New Coverage Models that are not random
    -- Use BurstDelay once every 5 transfers, Use BeatDelay otherwise (the other 4)
    -- This is using the coverage IDs that were previously retrieved
    AddBins(DelayCoverageID.BurstLengthCov, GenBin(5)) ;
    -- Burst delay will be exactly 4, Signal Ready before Valid (done by GenBin(0)
    AddCross(DelayCoverageID.BurstDelayCov, GenBin(0), GenBin(4)) ;
    -- Burst delay will be exactly 1, Signal Ready before Valid (done by GenBin(0)
    AddCross(DelayCoverageID.BeatDelayCov,  GenBin(0), GenBin(1)) ;

    -- Check
    BaseWord := BaseWord + X"0001_0000" ;
    for i in 1 to 32 loop
      Check(StreamRxRec, BaseWord + I ) ;
    end loop ;

    BurstWord := BaseWord ; 
    for i in 1 to 8 loop
      BurstWord := BurstWord + X"0000_1000" ;
      CheckBurstIncrement(StreamRxRec, BurstWord, 8) ;
    end loop ;

    WaitForClock(StreamRxRec, 3) ;
    
    -- Create another coverage model with the same ID (reference to DelayCoveragePkg singleton) as DelayCoverageID.ID
    -- References to the coverage models are in the variable DelayCoverageID_Random
    DelayCoverageID_Random  := NewDelayCoverage(DelayCoverageID.ID, "RxRandom", TbID) ;

    -- BurstLength - once per BurstLength, use BurstDelay, otherwise use BeatDelay
    AddBins (DelayCoverageID_Random.BurstLengthCov,  80, GenBin(3,11,1)) ;      -- 80% Small Burst Length
    AddBins (DelayCoverageID_Random.BurstLengthCov,  20, GenBin(109,131,1)) ;   -- 20% Large Burst Length
    -- BurstDelay - happens at BurstLength boundaries
    AddCross(DelayCoverageID_Random.BurstDelayCov,   65, GenBin(0), GenBin(2,8,1)) ;     -- 65% Ready Before Valid, small delay
    AddCross(DelayCoverageID_Random.BurstDelayCov,   10, GenBin(0), GenBin(108,156,1)) ; -- 10% Ready Before Valid, large delay
    AddCross(DelayCoverageID_Random.BurstDelayCov,   15, GenBin(1), GenBin(2,8,1)) ;     -- 15% Ready After Valid, small delay
    AddCross(DelayCoverageID_Random.BurstDelayCov,   10, GenBin(1), GenBin(108,156,1)) ; -- 10% Ready After Valid, large delay
    -- BeatDelay - happens between each transfer it not at a BurstLength boundary
    AddCross(DelayCoverageID_Random.BeatDelayCov,    85, GenBin(0), GenBin(0)) ;       -- 85% Ready Before Valid, no delay
    AddCross(DelayCoverageID_Random.BeatDelayCov,     5, GenBin(0), GenBin(1)) ;       --  5% Ready Before Valid, 1 cycle delay
    AddCross(DelayCoverageID_Random.BeatDelayCov,     5, GenBin(1), GenBin(0)) ;       --  5% Ready After Valid, no delay
    AddCross(DelayCoverageID_Random.BeatDelayCov,     5, GenBin(1), GenBin(1)) ;       --  5% Ready After Valid, 1 cycle delay

    -- Copy the CoverageIDs in DelayCoverageID_random to the DelayCoveragePkg singleton
    -- This uses DelayCoverageID_random.ID to update the coverage model used by the VC
    -- Note when DelayCoverageID_Random was created, this ID was copied from DelayCoverageID.ID so they match.
    SetDelayCoverage(DelayCoverageID_Random) ;

    -- Check
    BaseWord := BaseWord + X"0001_0000" ;
    for I in 1 to 256 loop
      Check(StreamRxRec, BaseWord + I ) ;
    end loop ;

    BurstWord := BaseWord ; 
    for i in 1 to 32 loop
      BurstWord := BurstWord + X"0000_1000" ;
      CheckBurstIncrement(StreamRxRec, BurstWord, 8) ;
    end loop ;

    WaitForClock(StreamRxRec, 3) ;
    
    -- Copy the CoverageIDs in DelayCoverageID to the DelayCoveragePkg singleton
    -- This uses DelayCoverageID.ID to update the coverage model used by the VC
    SetDelayCoverage(DelayCoverageID) ;

    -- Check
    BaseWord := BaseWord + X"0001_0000" ;
    for i in 1 to 32 loop
      Check(StreamRxRec, BaseWord + I ) ;
    end loop ;

    BurstWord := BaseWord ; 
    for i in 1 to 8 loop
      BurstWord := BurstWord + X"0000_1000" ;
      CheckBurstIncrement(StreamRxRec, BurstWord, 8) ;
    end loop ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ReceiverProc ;

end SendGetRandom1 ;

Configuration TbStream_SendGetRandom1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SendGetRandom1) ;
    end for ;
  end for ;
end TbStream_SendGetRandom1 ;
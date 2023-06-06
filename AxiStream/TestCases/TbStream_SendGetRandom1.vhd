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
--      Validates AxiStream usage of delay randomization for TReady and TValid
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
    variable BurstCovID : BurstCoverageIdType ; 
    variable BurstLengthCovID, BurstDelayCovID, BeatDelayCovID : CoverageIdType ; 
    variable BaseWord : std_logic_vector(31 downto 0) := X"0000_0000" ;
  begin

    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
--    GetAxiStreamOptions(StreamTxRec, BURST_COV, BurstCovID) ; 
    GetDelayCoverageID(StreamTxRec, BurstCovID) ;
    BurstLengthCovID := BurstCovID.BurstLengthCov ; 
    BurstDelayCovID  := BurstCovID.BurstDelayCov ; 
    BeatDelayCovID   := BurstCovID.BeatDelayCov ; 
    
    DeallocateBins(BurstLengthCovID) ;  -- Remove old coverage model
    AddBins(BurstLengthCovID, 90000, GenBin(16,32,1)) ; 
    DeallocateBins(BurstDelayCovID) ;  -- Remove old coverage model
    AddBins(BurstDelayCovID, 90000, GenBin(8,12,1)) ; 
    DeallocateBins(BeatDelayCovID) ;  -- Remove old coverage model
    AddBins(BeatDelayCovID, 90000, GenBin(0)) ; 
    AddBins(BeatDelayCovID, 10000, GenBin(1)) ; 

    for i in 1 to 2 loop 
      -- Send and Check    
      log("Transmit 1024 words") ;
      BaseWord := BaseWord + X"0000_1000" ;
      for I in 0 to 1023 loop 
        Send( StreamTxRec, BaseWord + I ) ; 
      end loop ; 

      for i in 1 to 4 loop
        log("SendBurstIncrement 256 word burst") ;
        BaseWord := BaseWord + X"0000_1000" ;
        SendBurstIncrement(StreamTxRec, BaseWord, 256) ; 
      end loop ; 
      
      -- Additional bins for second iteration
      ClearCov(BurstDelayCovID) ; 
      AddBins(BurstDelayCovID, 10000, GenBin(20)) ; 
    end loop ; 
    
    
    WaitForClock(StreamTxRec, 2) ; 
--    SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_DELAY_CYCLES, 1) ; 
--    SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_BURST_DELAY_CYCLES, 0) ; 
    -- Quiet
    DeallocateBins(BurstLengthCovID) ;  -- Remove old coverage model
    AddBins(BurstLengthCovID, GenBin(0)) ; 
    DeallocateBins(BurstDelayCovID) ;  -- Remove old coverage model
    AddBins(BurstDelayCovID, GenBin(1)) ; 
    DeallocateBins(BeatDelayCovID) ;  -- Remove old coverage model
    AddBins(BeatDelayCovID, GenBin(1)) ; 
    
    for i in 1 to 2 loop 
      log("Transmit 1024 words") ;
      BaseWord := BaseWord + X"0000_1000" ;
      for I in 0 to 1023 loop 
        Send( StreamTxRec, BaseWord + I ) ; 
      end loop ; 

      for i in 1 to 4 loop
        log("SendBurstIncrement 256 word burst") ;
        BaseWord := BaseWord + X"0000_1000" ;
        SendBurstIncrement(StreamTxRec, BaseWord, 256) ; 
      end loop ; 
      
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
    variable BurstCovID : BurstCoverageIdType ; 
    variable BurstLengthCovID, BurstDelayCovID, BeatDelayCovID : CoverageIdType ; 
    variable BaseWord : std_logic_vector(31 downto 0) := X"0000_0000" ;
  begin
    WaitForClock(StreamRxRec, 1) ; 
--    GetAxiStreamOptions(StreamRxRec, BURST_COV, BurstCovID) ; 
    GetDelayCoverageID(StreamTxRec, BurstCovID) ;
    BurstLengthCovID := BurstCovID.BurstLengthCov ; 
    BurstDelayCovID  := BurstCovID.BurstDelayCov ; 
    BeatDelayCovID   := BurstCovID.BeatDelayCov ; 
    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_WAIT_FOR_GET, TRUE) ;
    
    -- Quiet
    DeallocateBins(BurstLengthCovID) ;  -- Remove old coverage model
    AddBins(BurstLengthCovID, GenBin(0)) ; 
    DeallocateBins(BurstDelayCovID) ;  -- Remove old coverage model
    AddCross(BurstDelayCovID, GenBin(0,1,1), GenBin(0,1,1)) ; 
    DeallocateBins(BeatDelayCovID) ;  -- Remove old coverage model
    AddCross(BeatDelayCovID, GenBin(0,1), GenBin(10)) ; 

    
    for i in 1 to 2 loop 
      -- Check    
      BaseWord := BaseWord + X"0000_1000" ;
      for I in 0 to 1023 loop 
        Check(StreamRxRec, BaseWord + I ) ; 
      end loop ; 

      for i in 1 to 4 loop
        BaseWord := BaseWord + X"0000_1000" ;
        CheckBurstIncrement(StreamRxRec, BaseWord, 256) ; 
      end loop ; 
    end loop ; 
    

    WaitForClock(StreamRxRec, 2) ; 

    DeallocateBins(BurstLengthCovID) ;  -- Remove old coverage model
    AddBins(BurstLengthCovID, 90000, GenBin(16,32,1)) ; 
    DeallocateBins(BurstDelayCovID) ;  -- Remove old coverage model
    AddCross(BurstDelayCovID, 90000, GenBin(0,1,1), GenBin(8,12,1)) ; 
    DeallocateBins(BeatDelayCovID) ;  -- Remove old coverage model
    AddCross(BeatDelayCovID, 90000, GenBin(0,1,1), GenBin(0)) ; 
    AddCross(BeatDelayCovID, 10000, GenBin(0,1,1), GenBin(1)) ; 
    for i in 1 to 2 loop 
      -- Check    
      BaseWord := BaseWord + X"0000_1000" ;
      for I in 0 to 1023 loop 
        Check(StreamRxRec, BaseWord + I ) ; 
      end loop ; 

      for i in 1 to 4 loop
        BaseWord := BaseWord + X"0000_1000" ;
        CheckBurstIncrement(StreamRxRec, BaseWord, 256) ; 
      end loop ; 

      -- Additional bins for second iteration
      ClearCov(BurstDelayCovID) ; 
      AddCross(BurstDelayCovID, 10000, GenBin(0,1), GenBin(20)) ; 
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
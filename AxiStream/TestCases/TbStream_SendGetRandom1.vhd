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
--    Uses only basic feature of SetUseRandomDelays
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

  signal   SequenceNumber : integer := 0 ; 
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
    if CHECK_TRANSCRIPT then 
    --  AffirmIfTranscriptsMatch(PATH_TO_VALIDATED_RESULTS) ; 
    end if ;   
   


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
    variable DelayCoverageID, DelayCovID_Random : DelayCoverageIDType ;
    variable BaseWord, BurstWord : std_logic_vector(31 downto 0) := X"0000_0000" ;
  begin

    wait until nReset = '1' ;
    WaitForClock(StreamTxRec, 2) ;
    
    --
    -- Part 1: Randomize using existing VC delay coverage
    --
    -- Turn on Delay Coverage randomization by calling SetUseRandomDelays.  
    -- Note that whether randomization is on initially or not 
    -- is up to a particular VC.   AxiStreamTransmitter currently 
    -- has it off to support historical modes of operation.   
    SetUseRandomDelays(StreamTxRec) ;
    SequenceNumber <= SequenceNumber + 1 ;  -- To locate this sequence (part 1) on the waveform

    -- Using the Delay Coverage settings from the VC, 
    -- transfer 256 words individually and 256 words in 32 bursts of 8.  
    -- Note that the burst length of SendBurst (here 8) is independent 
    -- from the delays set in the Delay Coverage. 
    -- The burst length of SendBurst says I want to transfer 8 words on the interface.   
    -- The burst length of Delay Coverage models what happens when a sequence of words 
    -- is put on the interface – independent of whether the API thinks of it as a single word or burst transfer.
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
    variable DelayCoverageID, DelayCovID_Random : DelayCoverageIDType ;
    variable BaseWord, BurstWord : std_logic_vector(31 downto 0) := X"0000_0000" ;
  begin
    WaitForClock(StreamRxRec, 1) ;
    SetUseRandomDelays(StreamRxRec) ;
    
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
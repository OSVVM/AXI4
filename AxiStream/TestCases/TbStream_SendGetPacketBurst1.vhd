--
--  File Name:         TbStream_SendGetPacketBurst1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Packet burst test 
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
architecture SendGetPacketBurst1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_SendGetPacketBurst1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for simulation elaboration/initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_SendGetPacketBurst1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_SendGetPacketBurst1.txt", "../sim_shared/validated_results/TbStream_SendGetPacketBurst1.txt", "") ; 
    
    -- Expecting two check errors at 128 and 256
    EndOfTestReports(ExternalErrors => (0, 0, 0)) ; 
    std.env.stop(SumAlertCount(GetAlertCount + (0, 0, 0))) ;
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  TransmitterProc : process
    variable CoverID : CoverageIdType ; 
  begin

    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 

-- Simple Incrementing Pattern - Using Bytes - Counts are number of Bytes
    SetBurstMode(StreamTxRec, STREAM_BURST_BYTE_MODE) ;
    Print("Simple Pattern:  80 bytes, each one increments") ;
    PushBurstIncrement(StreamTxRec.BurstFifo, X"01", 80) ; -- 80 bytes = 20 32 bit words
    
    -- Emulate Packetization of Bursts
    SendBurst(StreamTxRec, 20, "0") ; -- Send first 5 Words
    WaitForClock(StreamTxRec, 4) ;
    SendBurst(StreamTxRec, 20, "0") ; -- Send 5 Words
    WaitForClock(StreamTxRec, 4);
    SendBurst(StreamTxRec, 20, "0") ; -- Send 5 Words
    WaitForClock(StreamTxRec, 4);
    SendBurst(StreamTxRec, 20, "1") ; -- Send last 5 Words
    WaitForClock(StreamTxRec, 20) ;

    
-- Burst Combining Patterns - Using Words
    SetBurstMode(StreamTxRec, STREAM_BURST_WORD_MODE) ;
    Print("Combining Patterns:  Vector, Increment, Random, Intelligent Coverage") ;
    PushBurstVector(StreamTxRec.BurstFifo, 
        (X"0000_A001", X"0000_A003", X"0000_A005", X"0000_A007", X"0000_A009",
         X"0000_A011", X"0000_A013", X"0000_A015", X"0000_A017", X"0000_A019") ) ;
    PushBurstIncrement(StreamTxRec.BurstFifo, X"0000_A100", 10) ; 
    PushBurstRandom(StreamTxRec.BurstFifo, X"0000_A200", 6) ; 
    CoverID := NewID("Cov1a") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, 
        GenBin(16#A000#, 16#A007#) & GenBin(16#A010#, 16#A017#) & 
        GenBin(16#A020#, 16#A027#) & GenBin(16#A030#, 16#A037#)) ; 
    PushBurstRandom(StreamTxRec.BurstFifo, CoverID, Count => 16, FifoWidth => 32) ; 
    
    -- Emulate Packetization of Bursts
    SendBurst(StreamTxRec, 10, "0");
    WaitForClock(StreamTxRec, 5);
    SendBurst(StreamTxRec, 10, "0");
    WaitForClock(StreamTxRec, 5);
    SendBurst(StreamTxRec, 10, "0");
    WaitForClock(StreamTxRec, 5);
    SendBurst(StreamTxRec, 12, "1") ; 
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamTxRec, 4) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process TransmitterProc ;


  ------------------------------------------------------------
  -- AxiReceiverProc
  --   Generate transactions for AxiReceiver
  ------------------------------------------------------------
  ReceiverProc : process
    variable ExpData, RxData : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable NumBytes : integer ; 
    variable CoverID : CoverageIdType ; 
    variable slvBurstVector : slv_vector(1 to 5)(31 downto 0) ; 
    variable intBurstVector : integer_vector(1 to 5) ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    
    SetBurstMode(StreamRxRec, STREAM_BURST_BYTE_MODE) ;
    CheckBurstIncrement(StreamRxRec, X"01", 80) ; 

    
--    log("Combining Patterns:  Vector, Increment, Random, Intelligent Coverage") ;
    SetBurstMode(StreamRxRec, STREAM_BURST_WORD_MODE) ;
    PushBurstVector(StreamRxRec.BurstFifo, 
        (X"0000_A001", X"0000_A003", X"0000_A005", X"0000_A007", X"0000_A009",
         X"0000_A011", X"0000_A013", X"0000_A015", X"0000_A017", X"0000_A019") ) ;
    PushBurstIncrement(StreamRxRec.BurstFifo, X"0000_A100", 10) ; 
    PushBurstRandom(StreamRxRec.BurstFifo, X"0000_A200", 6) ; 
    CoverID := NewID("Cov2a") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, 
        GenBin(16#A000#, 16#A007#) & GenBin(16#A010#, 16#A017#) & 
        GenBin(16#A020#, 16#A027#) & GenBin(16#A030#, 16#A037#)) ; 
    PushBurstRandom(StreamRxRec.BurstFifo, CoverID, 16, 32) ; 
    CheckBurst(StreamRxRec, 42) ; 

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ReceiverProc ;

end SendGetPacketBurst1 ;

Configuration TbStream_SendGetPacketBurst1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SendGetPacketBurst1) ; 
    end for ; 
  end for ; 
end TbStream_SendGetPacketBurst1 ; 
--
--  File Name:         TbStream_SendGetDemo1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Validates Stream Model Independent Transactions
--      Send, Get, Check, 
--      WaitForTransaction, GetTransactionCount
--      GetAlertLogID, GetErrorCount, 
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
architecture SendGetDemo1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_SendGetDemo1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for simulation elaboration/initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_SendGetDemo1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_SendGetDemo1.txt", "../sim_shared/validated_results/TbStream_SendGetDemo1.txt", "") ; 
    
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
    
-- Send and Get    
    log("Transmit 32 words") ;
    for I in 1 to 32 loop 
      Send( StreamTxRec, X"0000_0000" + I ) ; 
    end loop ; 

-- Send and Check    
    log("Transmit 32 words") ;
    for I in 1 to 32 loop 
      Send( StreamTxRec, X"0000_1000" + I ) ; 
    end loop ; 

-- SendBurst and GetBurst    
    log("Send 32 word burst") ;
    for I in 1 to 32 loop 
      Push( StreamTxRec.BurstFifo, X"0000_2000" + I  ) ; 
    end loop ; 
    SendBurst(StreamTxRec, 32) ;

-- SendBurst and CheckBurst    
    log("Send 32 word burst") ;
    for I in 1 to 32 loop 
      Push( StreamTxRec.BurstFifo, X"0000_3000" + I ) ; 
    end loop ; 
    SendBurst(StreamTxRec, 32) ;

-- SendBurst and CheckBurst    
    log("SendBurstVector 13 word burst") ;
    SendBurstVector(StreamTxRec, 
        (X"0000_4001", X"0000_4003", X"0000_4005", X"0000_4007", X"0000_4009",
         X"0000_4011", X"0000_4013", X"0000_4015", X"0000_4017", X"0000_4019",
         X"0000_4021", X"0000_4023", X"0000_4025") ) ;
   

-- SendBurstIncrement and CheckBurstIncrement    
    log("SendBurstIncrement 16 word burst") ;
    SendBurstIncrement(StreamTxRec, X"0000_5000", 16) ; 

-- SendBurstRandom and CheckBurstRandom    
    log("SendBurstRandom 24 word burst") ;
    SendBurstRandom   (StreamTxRec, X"0000_6000", 24) ; 
    
-- Coverage:  SendBurstRandom and CheckBurstRandom    
    CoverID := NewID("Cov1") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, GenBin(16#7000#, 16#7007#) & GenBin(16#7010#, 16#7017#) & GenBin(16#7020#, 16#7027#) & GenBin(16#7030#, 16#7037#)) ; 

    log("SendBurstRandom 42 word burst") ;
    SendBurstRandom   (StreamTxRec, CoverID, 42, 32) ; 
    
-- Burst Combining Patterns - Send Get
    log("Combining Patterns:  Vector, Increment, Random, Intelligent Coverage") ;
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
    PushBurstRandom(StreamTxRec.BurstFifo, CoverID, 16, 32) ; 
    SendBurst(StreamTxRec, 42) ; 
         
-- Burst Combining Patterns
    log("Combining Patterns:  Vector, Increment, Random, Intelligent Coverage") ;
    PushBurstVector(StreamTxRec.BurstFifo, 
        (X"0000_B001", X"0000_B003", X"0000_B005", X"0000_B007", X"0000_B009",
         X"0000_B011", X"0000_B013", X"0000_B015", X"0000_B017", X"0000_B019") ) ;
    PushBurstIncrement(StreamTxRec.BurstFifo, X"0000_A100", 10) ; 
    PushBurstRandom(StreamTxRec.BurstFifo, X"0000_A200", 6) ; 
    CoverID := NewID("Cov1b") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, 
        GenBin(16#B000#, 16#B007#) & GenBin(16#B010#, 16#B017#) & 
        GenBin(16#B020#, 16#B027#) & GenBin(16#B030#, 16#B037#)) ; 
    PushBurstRandom(StreamTxRec.BurstFifo, CoverID, Count => 16, FifoWidth => 32) ; 
    SendBurst(StreamTxRec, 42) ; 

-- SendBurstVector - PopBurstVector slv_vector
    log("SendBurstVector 5 word burst") ;
    SendBurstVector(StreamTxRec, 
        (X"0000_C001", X"0000_C003", X"0000_C005", X"0000_C007", X"0000_C009") ) ;
   
-- SendBurstVector - PopBurstVector integer_vector
    log("SendBurstVector 5 word burst") ;
    PushBurstVector(StreamTxRec.BurstFifo, 
        (16#D001#, 16#D003#, 16#D005#, 16#D007#, 16#D009#), 32 ) ;
    SendBurst(StreamTxRec, 5) ; 
   

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
    variable ExpData, RxData : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable NumBytes : integer ; 
    variable CoverID : CoverageIdType ; 
    variable slvBurstVector : slv_vector(1 to 5)(31 downto 0) ; 
    variable intBurstVector : integer_vector(1 to 5) ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    
--    log("Transmit 32 words") ;
    for I in 1 to 32 loop 
      Get(StreamRxRec, RxData) ;      
      AffirmIfEqual(RxData, X"0000_0000" + I, "RxData") ;
    end loop ; 

--    log("Transmit 32 words") ;
    for I in 1 to 32 loop 
      Check(StreamRxRec, X"0000_1000" + I ) ;      
    end loop ; 

--    log("Send 32 word burst") ;
    GetBurst(StreamRxRec, NumBytes) ;
    AffirmIfEqual(NumBytes, 32, "Receiver: 32 Received") ;
    for I in 1 to 32 loop 
      RxData := Pop( StreamRxRec.BurstFifo ) ;      
      AffirmIfEqual(RxData, X"0000_2000" + I , "RxData") ;
    end loop ; 

--    log("Send 32 word burst") ;
    for I in 1 to 32 loop 
      Push( StreamRxRec.BurstFifo, X"0000_3000" + I  ) ; 
    end loop ; 
    CheckBurst(StreamRxRec, 32) ;

    CheckBurstVector(StreamRxRec, 
        (X"0000_4001", X"0000_4003", X"0000_4005", X"0000_4007", X"0000_4009",
         X"0000_4011", X"0000_4013", X"0000_4015", X"0000_4017", X"0000_4019",
         X"0000_4021", X"0000_4023", X"0000_4025") ) ;
   
    CheckBurstIncrement(StreamRxRec, X"0000_5000", 16) ; 

    CheckBurstRandom   (StreamRxRec, X"0000_6000", 24) ; 

    CoverID := NewID("Cov2") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, 
        GenBin(16#7000#, 16#7007#) & GenBin(16#7010#, 16#7017#) & 
        GenBin(16#7020#, 16#7027#) & GenBin(16#7030#, 16#7037#)) ; 

    CheckBurstRandom   (StreamRxRec, CoverID, 42, 32) ; 
    
--    log("Combining Patterns:  Vector, Increment, Random, Intelligent Coverage") ;
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

--    log("Combining Patterns:  Vector, Increment, Random, Intelligent Coverage") ;
    GetBurst(StreamRxRec, NumBytes) ; 
    CheckBurstVector(StreamRxRec.BurstFifo, 
        (X"0000_B001", X"0000_B003", X"0000_B005", X"0000_B007", X"0000_B009",
         X"0000_B011", X"0000_B013", X"0000_B015", X"0000_B017", X"0000_B019") ) ;
    CheckBurstIncrement(StreamRxRec.BurstFifo, X"0000_A100", 10) ; 
    CheckBurstRandom(StreamRxRec.BurstFifo, X"0000_A200", 6) ; 
    CoverID := NewID("Cov2b") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, 
        GenBin(16#B000#, 16#B007#) & GenBin(16#B010#, 16#B017#) & 
        GenBin(16#B020#, 16#B027#) & GenBin(16#B030#, 16#B037#)) ; 
    CheckBurstRandom(StreamRxRec.BurstFifo, CoverID, 16, 32) ; 

--    log("SendBurstVector 5 word burst") ;
    GetBurst(StreamRxRec, NumBytes) ;
    PopBurstVector(StreamRxRec.BurstFifo, slvBurstVector) ; 
    AffirmIf(slvBurstVector = 
        (X"0000_C001", X"0000_C003", X"0000_C005", X"0000_C007", X"0000_C009"),
        "slvBurstVector = C001, C003, C005, C007, C009") ; --  & to_string(slvBurstVector)) ; -- to_string in 2019
   
--    log("SendBurstVector 5 word burst") ;
    GetBurst(StreamRxRec, NumBytes) ;
    PopBurstVector(StreamRxRec.BurstFifo, intBurstVector) ; 
    AffirmIf(intBurstVector = 
        (16#D001#, 16#D003#, 16#D005#, 16#D007#, 16#D009#), 
        "slvBurstVector = D001, D003, D005, D007, D009") ; -- & to_string(slvBurstVector)) ; -- to_string in 2019

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ReceiverProc ;

end SendGetDemo1 ;

Configuration TbStream_SendGetDemo1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SendGetDemo1) ; 
    end for ; 
  end for ; 
end TbStream_SendGetDemo1 ; 
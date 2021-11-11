--
--  File Name:         TbStream_SendGetBurstByte1.vhd
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
--      SendBurst, GetBurst
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    10/2020   2020.10    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.  
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
architecture SendGetBurstByte1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
  
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_SendGetBurstByte1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_SendGetBurstByte1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms) ;
    AlertIf(now >= 5 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_SendGetBurstByte1.txt", "../sim_shared/validated_results/TbStream_SendGetBurstByte1.txt", "") ; 
    
    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc : process
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    SetBurstMode(StreamTxRec, STREAM_BURST_BYTE_MODE) ;

    log("Transmit 32 Bytes -- word aligned") ;
    PushBurstIncrement(TxBurstFifo, 3, 32) ;
    SendBurst(StreamTxRec, 32) ;

    WaitForClock(StreamTxRec, 4) ; 

    log("Transmit 30 Bytes -- unaligned") ;
    PushBurst(TxBurstFifo, (1,3,5,7,9,11,13,15,17,19,21,23,25,27,29)) ;
    PushBurst(TxBurstFifo, (31,33,35,37,39,41,43,45,47,49,51,53,55,57,59)) ;
    SendBurst(StreamTxRec, 30) ;

    WaitForClock(StreamTxRec, 4) ; 

    log("Transmit 34 Bytes -- unaligned") ;
    PushBurstRandom(TxBurstFifo, 7, 34) ;
    SendBurst(StreamTxRec, 34) ;
    
    for i in 0 to 6 loop 
      log("Transmit " & to_string(32+5*i) & " Bytes. Starting with " & to_string(i*32)) ;
      PushBurstIncrement(TxBurstFifo, i*32, 32 + 5*i) ;
      SendBurst(StreamTxRec, 32 + 5*i) ;
    end loop ; 


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamTxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiTransmitterProc ;


  ------------------------------------------------------------
  -- AxiReceiverProc
  --   Generate transactions for AxiReceiver
  ------------------------------------------------------------
  AxiReceiverProc : process
    variable NumBytes : integer ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    SetBurstMode(StreamRxRec, STREAM_BURST_BYTE_MODE) ;
    
--    log("Transmit 32 Bytes -- word aligned") ;
    GetBurst (StreamRxRec, NumBytes) ;
    AffirmIfEqual(NumBytes, 32, "Receiver: NumBytes Received") ;
    CheckBurstIncrement(RxBurstFifo, 3, NumBytes) ;
    
--    log("Transmit 30 Bytes -- unaligned") ;
    GetBurst (StreamRxRec, NumBytes) ;
    AffirmIfEqual(NumBytes, 30, "Receiver: NumBytes Received") ;
    CheckBurst(RxBurstFifo, (1,3,5,7,9,11,13,15,17,19,21,23,25,27,29)) ;
    CheckBurst(RxBurstFifo, (31,33,35,37,39,41,43,45,47,49,51,53,55,57,59)) ;

--    log("Transmit 34 Bytes -- unaligned") ;
    GetBurst (StreamRxRec, NumBytes) ;
    AffirmIfEqual(NumBytes, 34, "Receiver: NumBytes Received") ;
    CheckBurstRandom(RxBurstFifo, 7, NumBytes) ;
    
    for i in 0 to 6 loop 
--      log("Transmit " & to_string(32+5*i) & " Bytes. Starting with " & to_string(i*32)) ;
      GetBurst (StreamRxRec, NumBytes) ;
      AffirmIfEqual(NumBytes, 32 + 5*i, "Receiver: NumBytes Received") ;
      CheckBurstIncrement(RxBurstFifo, i*32, NumBytes) ;
    end loop ; 
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end SendGetBurstByte1 ;

Configuration TbStream_SendGetBurstByte1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SendGetBurstByte1) ; 
    end for ; 
  end for ; 
end TbStream_SendGetBurstByte1 ; 
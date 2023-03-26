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
    AffirmIfNotDiff(GetTranscriptName, OSVVM_VALIDATED_RESULTS_DIR & GetTranscriptName, "") ;   
    
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
    variable ValidDelayCovID, ValidBurstDelayCovID : CoverageIdType ; 
  begin

    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    GetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_DELAY_COV, ValidDelayCovID) ; 
    GetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_BURST_DELAY_COV, ValidBurstDelayCovID) ; 
    
    DeallocateBins(ValidDelayCovID) ; 
    AddBins(ValidDelayCovID,      5, GenBin(1,3)) ; 
    DeallocateBins(ValidBurstDelayCovID) ;
    AddBins(ValidBurstDelayCovID, 5, GenBin(0,1)) ; 

    for i in 1 to 2 loop 
      -- Send and Check    
      log("Transmit 16 words") ;
      for I in 0 to 31 loop 
        Send( StreamTxRec, X"0000_1000" + I ) ; 
      end loop ; 

      -- SendBurstIncrement and CheckBurstIncrement    
      log("SendBurstIncrement 16 word burst") ;
      SendBurstIncrement(StreamTxRec, X"0000_2000", 32) ; 
      
      -- Additional bins for second iteration
      ClearCov(ValidDelayCovID) ; 
      AddBins(ValidDelayCovID,      GenBin(6)) ; 
      ClearCov(ValidBurstDelayCovID) ; 
      AddBins(ValidBurstDelayCovID, GenBin(5)) ; 
    end loop ; 
    
    
    WaitForClock(StreamTxRec, 2) ; 
    SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_DELAY_CYCLES, 1) ; 
    SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_BURST_DELAY_CYCLES, 0) ; 
    for i in 1 to 2 loop 
      -- Send and Check    
      log("Transmit 16 words") ;
      for I in 0 to 31 loop 
        Send( StreamTxRec, X"0000_1000" + I ) ; 
      end loop ; 

      -- SendBurstIncrement and CheckBurstIncrement    
      log("SendBurstIncrement 16 word burst") ;
      SendBurstIncrement(StreamTxRec, X"0000_2000", 32) ; 
      
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
    variable ReadyCovID : CoverageIdType ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    GetAxiStreamOptions(StreamRxRec, RECEIVE_READY_COV, ReadyCovID) ; 
    
    for i in 1 to 2 loop 
  --    log("Transmit 32 words") ;
      for I in 0 to 31 loop 
        Check(StreamRxRec, X"0000_1000" + I ) ;      
      end loop ; 

      CheckBurstIncrement(StreamRxRec, X"0000_2000", 32) ; 
    end loop ; 
    
    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_WAIT_FOR_GET, TRUE) ;
    WaitForClock(StreamRxRec, 2) ; 

    DeallocateBins(ReadyCovID) ; 
    AddCross(ReadyCovID, 5, GenBin(0,1), GenBin(1,3)) ; 
    for i in 1 to 2 loop 
  --    log("Transmit 32 words") ;
      for I in 0 to 31 loop 
        Check(StreamRxRec, X"0000_1000" + I ) ;      
      end loop ; 

      CheckBurstIncrement(StreamRxRec, X"0000_2000", 32) ; 

      -- Additional bins for second iteration
      ClearCov(ReadyCovID) ; 
      AddCross(ReadyCovID, GenBin(0,1), GenBin(6)) ; 
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
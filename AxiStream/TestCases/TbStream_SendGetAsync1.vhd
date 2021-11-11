--
--  File Name:         TbStream_SendGetAsync1.vhd
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
architecture SendGetAsync1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_SendGetAsync1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_SendGetAsync1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 1 ms) ;
    AlertIf(now >= 1 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_SendGetAsync1.txt", "../sim_shared/validated_results/TbStream_SendGetAsync1.txt", "") ; 
    
    -- Expecting two check errors at 128 and 256
    EndOfTestReports(ExternalErrors => (0, -2, 0)) ; 
    std.env.stop(SumAlertCount(GetAlertCount + (0, -2, 0))) ;
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc : process
    variable Data : std_logic_vector(DATA_WIDTH-1 downto 0) ;
    variable OffSet : integer ; 
    variable TransactionCount : integer; 
    variable ErrorCount : integer; 
    variable CurTime : time ; 
    variable TxAlertLogID : AlertLogIDType ; 
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    
    log("Send 256 words with each byte incrementing") ;
    for i in 1 to 256 loop 
      -- Create words one byte at a time
      OffSet := i * DATA_BYTES ;
      for j in 0 to DATA_BYTES-1 loop 
        Data := to_slv((OffSet + j) mod 256, 8) & Data(Data'left downto 8) ;
      end loop ; 
      SendAsync(StreamTxRec, Data) ;
      GetTransactionCount(StreamTxRec, TransactionCount) ;
      log("Transmitter Queued Transactions: " & to_string(i) & " Completed Transactions: " & to_string(TransactionCount)) ;
--      AffirmIfEqual(TransactionCount, i, "Transmit Queued Transactions:  TransactionCount:") ;
      if i mod 2 = 0 then 
        GetErrorCount(StreamTxRec, ErrorCount) ;
        AffirmIfEqual(ErrorCount, 0, "Transmitter, GetErrorCount: Verify that ErrorCount is 0") ;
      else
        GetAlertLogID(StreamTxRec, TxAlertLogID) ;
        ErrorCount := GetAlertCount(TxAlertLogID) ; 
        AffirmIfEqual(ErrorCount, 0, "Transmitter, GetAlertLogID/GetAlertCount: Verify that ErrorCount is 0") ;
      end if ; 
      if (i mod 32) = 0 then
        CurTime := now ; 
        WaitForTransaction(StreamTxRec) ;
        AffirmIf(now > CurTime, 
           "Transmitter: WaitForTransaction started at: " & to_string(CurTime, 1 ns) & 
           "  finished at: " & to_string(now, 1 ns)) ;
        WaitForClock(StreamTxRec, 4) ; 
      end if ; 
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
    variable ExpData, RxData : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable OffSet : integer ; 
    variable TransactionCount : integer ;     
    variable ErrorCount : integer; 
    variable CurTime : time ; 
    variable TxAlertLogID : AlertLogIDType ; 
    variable TryCount : integer ; 
    variable Available : boolean ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    
    -- Get and check the 256 words
    log("Send 256 words with each byte incrementing") ;
    for i in 1 to 256 loop 
      -- Create words one byte at a time
      OffSet := i * DATA_BYTES ;
      for j in 0 to DATA_BYTES-1 loop 
        ExpData := to_slv((OffSet + j) mod 256, 8) & ExpData(ExpData'left downto 8) ;
      end loop ; 
      -- Alternate using Get and Check
      TryCount := 0 ; 
      if (i mod 2) /= 0 then 
        loop 
          TryGet(StreamRxRec, RxData, Available) ; 
          exit when Available ; 
          WaitForClock(StreamRxRec, 1) ; 
          TryCount := TryCount + 1 ;
        end loop ; 
        GetTransactionCount(StreamRxRec, TransactionCount) ;
        AffirmIfEqual(TransactionCount, i, "Receive TranasctionCount:") ;
        AffirmIfEqual(RxData, ExpData, "Get: ") ;
      else 
        -- Create two check failures
        if (i mod 128) /= 0 then 
          loop 
            TryCheck(StreamRxRec, ExpData, Available) ; 
            exit when Available ; 
            WaitForClock(StreamRxRec, 1) ; 
            TryCount := TryCount + 1 ;
          end loop ; 
        else
          -- Create error on model side
          loop 
            TryCheck(StreamRxRec, ExpData+1, Available) ; 
            exit when Available ; 
            WaitForClock(StreamRxRec, 1) ; 
            TryCount := TryCount + 1 ;
          end loop ; 
        end if ; 
        GetTransactionCount(StreamRxRec, TransactionCount) ;
        AffirmIfEqual(TransactionCount, i, "Receive TranasctionCount:") ;
      end if ; 
      AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
      if i mod 2 = 0 then 
        GetErrorCount(StreamRxRec, ErrorCount) ;
        AffirmIfEqual(ErrorCount, i/128, "Transmitter, GetErrorCount: Verify that ErrorCount is 0") ;
      else
        GetAlertLogID(StreamRxRec, TxAlertLogID) ;
        ErrorCount := GetAlertCount(TxAlertLogID) ; 
        AffirmIfEqual(ErrorCount, i/128, "Transmitter, GetAlertLogID/GetAlertCount: Verify that ErrorCount is 0") ;
      end if ; 
      if (i mod 32) = 0 then
        -- Verify that no transactions are pending
        CurTime := now ; 
        WaitForTransaction(StreamRxRec) ;
        AffirmIfEqual(now, CurTime, "Receiver: WaitForTransaction executes in 0 time when using blocking transactions") ;
      end if ; 
     end loop ;
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end SendGetAsync1 ;

Configuration TbStream_SendGetAsync1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SendGetAsync1) ; 
    end for ; 
  end for ; 
end TbStream_SendGetAsync1 ; 
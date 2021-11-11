--
--  File Name:         TbStream_ByteHandlingBurstByteAsync1.vhd
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
architecture ByteHandlingBurstByteAsync1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_ByteHandlingBurstByteAsync1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_ByteHandlingBurstByteAsync1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_ByteHandlingBurstByteAsync1.txt", "../sim_shared/validated_results/TbStream_ByteHandlingBurstByteAsync1.txt", "") ; 
    
    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc : process
    variable Data, Data2 : std_logic_vector(DATA_WIDTH-1 downto 0) ;
    variable BytesToSend : integer ; 
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    SetBurstMode(StreamTxRec, STREAM_BURST_BYTE_MODE) ;
    
    -- Single Bytes - with Z
    BytesToSend := 0 ; 
    Data := (DATA_WIDTH-1 downto 8 => 'W') & X"01" ;
    Data2 := to_slv(1, Data2'length) ;
    for i in 1 to DATA_BYTES loop 
      PushWord(TxBurstFifo, Data2, FALSE) ;
      Data2 := Data2 + 1 ; 
      PushWord(TxBurstFifo, Data, FALSE) ;
      Data := Data(DATA_WIDTH-8-1 downto 0) & X"WW" ;
      BytesToSend := BytesToSend + 2*DATA_BYTES ;
    end loop ; 
    
    -- Two Bytes - with Z
    If DATA_BYTES > 2 then
      Data := (DATA_WIDTH-1 downto 16 => 'W') & X"0302" ;
      for i in 1 to DATA_BYTES-1 loop 
        PushWord(TxBurstFifo, Data2, FALSE) ;
        Data2 := Data2 + 1 ; 
        PushWord(TxBurstFifo, Data, FALSE) ;
        Data := Data(DATA_WIDTH-8-1 downto 0) & X"WW" ;
        BytesToSend := BytesToSend + 2*DATA_BYTES ;
      end loop ; 
    end if; 

    -- Three Bytes - with Z
    If DATA_BYTES > 3 then
      Data := (DATA_WIDTH-1 downto 24 => 'W') & X"060504" ;
      for i in 1 to DATA_BYTES-2 loop 
        PushWord(TxBurstFifo, Data2, FALSE) ;
        Data2 := Data2 + 1 ; 
        PushWord(TxBurstFifo, Data, FALSE) ;
        Data := Data(DATA_WIDTH-8-1 downto 0) & X"WW" ;
        BytesToSend := BytesToSend + 2*DATA_BYTES ;
      end loop ; 
    end if; 
    
    SendBurstAsync(StreamTxRec, BytesToSend) ; -- 18 
    
    -- Single Bytes - with U
    BytesToSend := 0 ;
    Data := (DATA_WIDTH-1 downto 8 => 'U') & X"01" ;
    for i in 1 to DATA_BYTES loop 
      PushWord(TxBurstFifo, Data2, FALSE) ;
      Data2 := Data2 + 1 ; 
      PushWord(TxBurstFifo, Data, FALSE) ;
      Data := Data(DATA_WIDTH-8-1 downto 0) & X"UU" ;
      BytesToSend := BytesToSend + 2*DATA_BYTES ;
    end loop ; 
    
    -- Two Bytes - with U
    If DATA_BYTES > 2 then
      Data := (DATA_WIDTH-1 downto 16 => 'U') & X"0302" ;
      for i in 1 to DATA_BYTES-1 loop 
        PushWord(TxBurstFifo, Data2, FALSE) ;
        Data2 := Data2 + 1 ; 
        PushWord(TxBurstFifo, Data, FALSE) ;
        Data := Data(DATA_WIDTH-8-1 downto 0) & X"UU" ;
        BytesToSend := BytesToSend + 2*DATA_BYTES ;
      end loop ; 
    end if; 

    -- Three Bytes - with U
    If DATA_BYTES > 3 then
      Data := (DATA_WIDTH-1 downto 24 => 'U') & X"060504" ;
      for i in 1 to DATA_BYTES-2 loop 
        PushWord(TxBurstFifo, Data2, FALSE) ;
        Data2 := Data2 + 1 ; 
        PushWord(TxBurstFifo, Data, FALSE) ;
        Data := Data(DATA_WIDTH-8-1 downto 0) & X"UU" ;
        BytesToSend := BytesToSend + 2*DATA_BYTES ;
      end loop ; 
    end if; 
   
    SendBurstAsync(StreamTxRec, BytesToSend) ; -- 18 

    WaitForTransaction(StreamTxRec) ;
    
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
    variable Data, Data2, RxData : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable NumBytes  : integer ; 
    variable PopValid  : boolean ; 
    variable TryCount  : integer ; 
    variable Available : boolean ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    SetBurstMode(StreamRxRec, STREAM_BURST_BYTE_MODE) ;
    
    Data2 := to_slv(1, Data2'length) ;
    for i in 1 to 2 loop 
      TryCount := 0 ; 
      loop 
        TryGetBurst (StreamRxRec, NumBytes, Available) ;
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
        TryCount := TryCount + 1 ;
      end loop ;
      AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
      
      -- Single Bytes - with Z, then U
      Data  := (DATA_WIDTH-1 downto 8 => '-') & X"01" ;
      for i in 1 to DATA_BYTES loop 
        PopWord(RxBurstFifo, PopValid, RxData, NumBytes) ; 
        AffirmIfEqual(RxData, Data2, "GetBurst: ") ;
        Data2 := Data2 + 1 ; 
        PopWord(RxBurstFifo, PopValid, RxData, NumBytes) ; 
        AffirmIfEqual(RxData, Data, "GetBurst: ") ;
        Data := Data(DATA_WIDTH-8-1 downto 0) & X"--" ;
      end loop ; 
      
      -- Two Bytes - with Z, then U
      If DATA_BYTES > 2 then
        Data := (DATA_WIDTH-1 downto 16 => '-') & X"0302" ;
        for i in 1 to DATA_BYTES-1 loop 
          PopWord(RxBurstFifo, PopValid, RxData, NumBytes) ; 
          AffirmIfEqual(RxData, Data2, "GetBurst: ") ;
          Data2 := Data2 + 1 ; 
          PopWord(RxBurstFifo, PopValid, RxData, NumBytes) ; 
          AffirmIfEqual(RxData, Data, "GetBurst: ") ;
          Data := Data(DATA_WIDTH-8-1 downto 0) & X"--" ;
        end loop ; 
      end if; 

      -- Three Bytes - with Z, then U
      If DATA_BYTES > 3 then
        Data := (DATA_WIDTH-1 downto 24 => '-') & X"060504" ;
        for i in 1 to DATA_BYTES-2 loop 
          PopWord(RxBurstFifo, PopValid, RxData, NumBytes) ; 
          AffirmIfEqual(RxData, Data2, "GetBurst: ") ;
          Data2 := Data2 + 1 ; 
          PopWord(RxBurstFifo, PopValid, RxData, NumBytes) ; 
          AffirmIfEqual(RxData, Data, "GetBurst: ") ;
          Data := Data(DATA_WIDTH-8-1 downto 0) & X"--" ;
        end loop ; 
      end if; 
    
    end loop ;
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end ByteHandlingBurstByteAsync1 ;

Configuration TbStream_ByteHandlingBurstByteAsync1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ByteHandlingBurstByteAsync1) ; 
    end for ; 
  end for ; 
end TbStream_ByteHandlingBurstByteAsync1 ; 
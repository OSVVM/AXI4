--
--  File Name:         TbStream_SendGetBurstPattern1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Burst Transactions with Full Data Width
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
architecture SendGetBurstPattern1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
  
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_SendGetBurstPattern1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_SendGetBurstPattern1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms) ;
    AlertIf(now >= 5 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_SendGetBurstPattern1.txt", "../sim_shared/validated_results/TbStream_SendGetBurstPattern1.txt", "") ; 
    
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
    
    log("Transmit 16 words.  Incrementing.  Starting with X00010003") ;
    SendBurstIncrement(StreamTxRec, X"00010003", 16) ;

    WaitForClock(StreamTxRec, 4) ; 

    log("Transmit 8 words.") ;
    SendBurst(StreamTxRec, (X"00010203", X"04050607", X"08090A0B", X"0C0D0E0F", X"10111213", X"14151617", X"18191A1B", X"1C1D1E1F")) ; 

    WaitForClock(StreamTxRec, 4) ; 

    log("Transmit 8 words.  Random.  Starting with X00010001") ;
    SendBurstRandom(StreamTxRec, X"00010001", 8) ;
    
    for i in 0 to 6 loop 
      log("Transmit " & to_string(32+5*i) & " Bytes. Starting with " & to_string(i*32)) ;
      SendBurstIncrement(StreamTxRec, to_slv(i*32, 32), 32 + 5*i) ;
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
    
--    log("Transmit 16 words.  Incrementing.  Starting with X00010003") ;
    CheckBurstIncrement(StreamRxRec, X"00010003", 16) ;
    
--    log("Transmit 30 Bytes -- unaligned") ;
    CheckBurst (StreamRxRec, (X"00010203", X"04050607", X"08090A0B", X"0C0D0E0F", X"10111213", X"14151617", X"18191A1B", X"1C1D1E1F")) ; 

--    log("Transmit 8 words.") ;
    CheckBurstRandom(StreamRxRec, X"00010001", 8) ;
         
    for i in 0 to 6 loop 
      -- log("Transmit " & to_string(32+5*i) & " Bytes. Starting with " & to_string(i*32)) ;
      CheckBurstIncrement(StreamRxRec, to_slv(i*32, 32), 32 + 5*i) ;
    end loop ; 

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end SendGetBurstPattern1 ;

Configuration TbStream_SendGetBurstPattern1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SendGetBurstPattern1) ; 
    end for ; 
  end for ; 
end TbStream_SendGetBurstPattern1 ; 
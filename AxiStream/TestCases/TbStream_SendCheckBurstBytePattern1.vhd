--
--  File Name:         TbStream_SendCheckBurstBytePattern1.vhd
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
--      SendBurstVector, GetBurst
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
architecture SendCheckBurstBytePattern1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
--    constant FIFO_WIDTH : integer := DATA_WIDTH ; 
  constant FIFO_WIDTH : integer := 8 ; -- BYTE 
  constant DATA_ZERO  : std_logic_vector := (FIFO_WIDTH - 1 downto 0 => '0') ; 
  
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_SendCheckBurstBytePattern1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_SendCheckBurstBytePattern1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms) ;
    AlertIf(now >= 5 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_SendCheckBurstBytePattern1.txt", "../sim_shared/validated_results/TbStream_SendCheckBurstBytePattern1.txt", "") ; 
    
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
    
    log("Transmit 16 bytes.  Incrementing.  Starting with 03") ;
    SendBurstIncrement(StreamTxRec, DATA_ZERO+3, 16) ;

    WaitForClock(StreamTxRec, 4) ; 

    log("Transmit 13 bytes.") ;
    SendBurstVector(StreamTxRec, 
--        (DATA_ZERO+1, DATA_ZERO+3,  DATA_ZERO+5,  DATA_ZERO+7,  DATA_ZERO+9,
        (X"01",        DATA_ZERO+3,  DATA_ZERO+5,  DATA_ZERO+7,  DATA_ZERO+9,
        DATA_ZERO+11,  DATA_ZERO+13, DATA_ZERO+15, DATA_ZERO+17, DATA_ZERO+19,
        DATA_ZERO+21,  DATA_ZERO+23, DATA_ZERO+25) ) ;

    WaitForClock(StreamTxRec, 4) ; 

    log("Transmit 8 bytes.  Random.  Starting with XAA") ;
    SendBurstRandom(StreamTxRec, DATA_ZERO+16#AA#, 8) ;
    
    for i in 0 to 6 loop 
      log("Transmit " & to_string(8 + 3*i) & " bytes. Starting with " & to_string(i*32)) ;
      SendBurstIncrement(StreamTxRec, DATA_ZERO+i*32, 8 + 3*i) ;
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
    
--    log("Transmit 16 bytes.  Incrementing.  Starting with X00010003") ;
    CheckBurstIncrement(StreamRxRec, DATA_ZERO+3, 16) ;
    
--    log("Transmit 13 bytes -- unaligned") ;
    CheckBurstVector (StreamRxRec, 
--        (DATA_ZERO+1, DATA_ZERO+3,  DATA_ZERO+5,  DATA_ZERO+7,  DATA_ZERO+9,
        (X"01",        DATA_ZERO+3,  DATA_ZERO+5,  DATA_ZERO+7,  DATA_ZERO+9,
        DATA_ZERO+11,  DATA_ZERO+13, DATA_ZERO+15, DATA_ZERO+17, DATA_ZERO+19,
        DATA_ZERO+21,  DATA_ZERO+23, DATA_ZERO+25) ) ;

--    log("Transmit 8 bytes.") ;
    CheckBurstRandom(StreamRxRec, DATA_ZERO+16#AA#, 8) ;
         
    for i in 0 to 6 loop 
      -- log("Transmit " & to_string(8 + 3*i) & " bytes. Starting with " & to_string(i*32)) ;
      CheckBurstIncrement(StreamRxRec, DATA_ZERO+i*32, 8 + 3*i) ;
    end loop ; 
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end SendCheckBurstBytePattern1 ;

Configuration TbStream_SendCheckBurstBytePattern1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SendCheckBurstBytePattern1) ; 
    end for ; 
  end for ; 
end TbStream_SendCheckBurstBytePattern1 ; 
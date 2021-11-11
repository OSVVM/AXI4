--
--  File Name:         TbStream_AxiTimingBurst2.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Set AXI Ready Time.   Check Timeout on Valid (nominally large or infinite?)
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
architecture AxiTimingBurst2 of TestCtrl is

  signal TestDone, TestPhaseStart : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_AxiTimingBurst2") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    SetAlertStopCount(FAILURE, integer'right) ;  -- Allow FAILURES

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiTimingBurst2.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiTimingBurst2.txt", "../sim_shared/validated_results/TbStream_AxiTimingBurst2.txt", "") ; 
    
    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc : process
    variable Data : std_logic_vector(DATA_WIDTH-1 downto 0) ;
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    SetBurstMode(StreamTxRec, STREAM_BURST_BYTE_MODE) ;
    
log("Ready before Valid Tests.") ;
WaitForBarrier(TestPhaseStart) ;
    -- Cycle to allow settings to update
    WaitForClock(StreamTxRec, 5) ; 
    Data := (others => '0') ;
    Send(StreamTxRec,  Data) ;  

    for i in 0 to 4 loop 
      WaitForClock(StreamTxRec, 5) ; 
    
      PushBurstIncrement(TxBurstFifo, i*32, 32) ;
      SendBurst(StreamTxRec, 32) ;
    end loop ; 
          
log("Ready after Valid Tests.") ;
WaitForBarrier(TestPhaseStart) ;
    -- Cycle to allow settings to update
    WaitForClock(StreamTxRec, 5) ; 
    Data := (others => '0') ;
    Send(StreamTxRec,  Data) ;  

    for i in 0 to 4 loop 
      WaitForClock(StreamTxRec, 5) ; 
    
      PushBurstIncrement(TxBurstFifo, i*32, 32) ;
      SendBurst(StreamTxRec, 32) ;
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
    variable Data : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable NumBytes : integer ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    SetBurstMode(StreamRxRec, STREAM_BURST_BYTE_MODE) ;
    
-- Start test phase 1:  
WaitForBarrier(TestPhaseStart) ;
-- log("Ready before Valid Tests.") ;
SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_BEFORE_VALID, TRUE) ;
    -- Cycle to allow settings to update
    -- WaitForClock(StreamRxRec, 5) ; 
    Data := (others => '0') ;
    Check(StreamRxRec,   Data) ;  

    for i in 0 to 4 loop 
      SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_DELAY_CYCLES, i) ;
      -- WaitForClock(StreamRxRec, 5) ; 
    
      GetBurst (StreamRxRec, NumBytes) ;
      AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
      CheckBurstIncrement(RxBurstFifo, i*32, NumBytes) ;
    end loop ; 
          
WaitForBarrier(TestPhaseStart) ;
-- log("Ready after Valid Tests.") ;
    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_BEFORE_VALID, FALSE) ;
    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_DELAY_CYCLES, 0) ;
    -- Cycle to allow settings to update
    -- WaitForClock(StreamRxRec, 5) ; 
    Data := (others => '0') ;
    Check(StreamRxRec,   Data) ;  

    for i in 0 to 4 loop 
      SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_DELAY_CYCLES, i) ;
      -- WaitForClock(StreamRxRec, 5) ; 

      GetBurst (StreamRxRec, NumBytes) ;
      AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
      CheckBurstIncrement(RxBurstFifo, i*32, NumBytes) ;
    end loop ;   
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end AxiTimingBurst2 ;

Configuration TbStream_AxiTimingBurst2 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiTimingBurst2) ; 
    end for ; 
  end for ; 
end TbStream_AxiTimingBurst2 ; 
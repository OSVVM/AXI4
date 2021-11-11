--
--  File Name:         TbStream_MultipleDriversReceiver1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Validates Multiple Driver detection works
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    02/2021   2021.02    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2021 by SynthWorks Design Inc.  
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
architecture MultipleDriversReceiver1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_MultipleDriversReceiver1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    SetAlertStopCount(FAILURE, 2) ;    -- Allow 2 FAILURE Alerts

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_MultipleDriversReceiver1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
--    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_MultipleDriversReceiver1.txt", "../sim_shared/validated_results/TbStream_MultipleDriversReceiver1.txt", "") ; 
    
    EndOfTestReports(ExternalErrors => (FAILURE => -1, ERROR => 0, WARNING => 0)) ; 
    std.env.stop(SumAlertCount(GetAlertCount + (FAILURE => -1, ERROR => 0, WARNING => 0))) ;
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- TransmitterProc
  --   Generate transactions for Transmitter
  ------------------------------------------------------------
  TransmitterProc : process
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    WaitForClock(StreamTxRec, 2) ; 
    WaitForClock(StreamRxRec, 2) ; 

    WaitForBarrier(TestDone) ;
    wait ;
  end process TransmitterProc ;


  ------------------------------------------------------------
  -- ReceiverProc
  --   Generate transactions for Receiver
  ------------------------------------------------------------
  ReceiverProc : process
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamRxRec, 2) ; 
    WaitForClock(StreamRxRec, 3) ; 
    
    WaitForBarrier(TestDone) ;
    wait ;
  end process ReceiverProc ;

end MultipleDriversReceiver1 ;

Configuration TbStream_MultipleDriversReceiver1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MultipleDriversReceiver1) ; 
    end for ; 
  end for ; 
end TbStream_MultipleDriversReceiver1 ; 
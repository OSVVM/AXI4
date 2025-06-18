--
--  File Name:         TbStream_WaitForGet2.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Validates RECEIVE_READY_WAIT_FOR_GET with 
--      word and burst receive transactions
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
architecture WaitForGet2 of TestCtrl is

  signal   Sync     : integer_barrier := 1 ;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbStream_WaitForGet2") ;
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
    if CHECK_TRANSCRIPT then 
    --   AffirmIfTranscriptsMatch(PATH_TO_VALIDATED_RESULTS) ; 
    end if ;   
   
    EndOfTestReports(ExternalErrors => (0, 0, 0)) ;
    std.env.stop ;
    wait ;
  end process ControlProc ;


  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  TransmitterProc : process
    variable CoverID : CoverageIdType ;
  begin

    WaitForClock(StreamTxRec, 2) ;

-- Send and Get
    BlankLine(2) ; 
    log("Send and Get: Transmit 4 words") ;
    for I in 0 to 3 loop
      Send( StreamTxRec, X"0000_1000" + I ) ;
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
    variable RxData : std_logic_vector(DATA_WIDTH-1 downto 0) ;
    variable NumWords : integer ;
    variable GetStartTime  : time ;
  begin
    WaitForClock(StreamRxRec, 6) ;
    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_WAIT_FOR_GET, TRUE) ;
    
    WaitForBarrier(VcInit) ; 
    
    for I in 0 to 3 loop
      Check(StreamRxRec, X"0000_1000" + I) ;
      WaitForClock(StreamRxRec, 2) ;
    end loop ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ReceiverProc ;

end WaitForGet2 ;

Configuration TbStream_WaitForGet2 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(WaitForGet2) ;
    end for ;
  end for ;
end TbStream_WaitForGet2 ;
--
--  File Name:         TbStream_WaitForGetAsync1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Validates RECEIVE_READY_WAIT_FOR_GET with Asynchronous
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
architecture WaitForGetAsync1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
  signal   Sync     : integer_barrier := 1 ;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_WaitForGetAsync1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for simulation elaboration/initialization
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_WaitForGetAsync1.txt") ;
    SetTranscriptMirror(TRUE) ;

    -- Wait for Design Reset
    wait until nReset = '1' ;
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");

    TranscriptClose ;
--    AlertIfDiff("./results/TbStream_WaitForGetAsync1.txt", "../sim_shared/validated_results/TbStream_WaitForGetAsync1.txt", "") ;

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

    WaitForClock(StreamTxRec, 2) ;

-- Send and Get
    BlankLine(2) ; 
    log("Send and Get: Transmit 12 words") ;
    for I in 1 to 4 loop
      Send( StreamTxRec, X"0000_0000" + I ) ;
    end loop ;

    WaitForBarrier(Sync) ;
    WaitForClock(StreamTxRec, 2) ;
    -- Extra Cycle to allow switch over
    Send( StreamTxRec, X"0000_0000" + 5 ) ;

    for I in 1 to 4 loop
      Send( StreamTxRec, X"0000_1000" + I ) ;
    end loop ;

    WaitForBarrier(Sync) ;
    WaitForClock(StreamTxRec, 2) ;
    -- Extra Cycle to allow switch over
    Send( StreamTxRec, X"0000_1000" + 5 ) ;
    WaitForClock(StreamTxRec, 2) ;

    for I in 1 to 4 loop
      Send( StreamTxRec, X"0000_2000" + I ) ;
    end loop ;

-- Send and Check
    WaitForBarrier(Sync) ;
    BlankLine(2) ; 
    WaitForClock(StreamTxRec, 2) ;
    log("Send and Check: Transmit 12 words") ;
    for I in 1 to 4 loop
      Send( StreamTxRec, X"0001_0000" + I ) ;
    end loop ;

    WaitForBarrier(Sync) ;
    WaitForClock(StreamTxRec, 2) ;
    -- Extra Cycle to allow switch over
    Send( StreamTxRec, X"0001_0000" + 5 ) ;

    for I in 1 to 4 loop
      Send( StreamTxRec, X"0001_1000" + I ) ;
    end loop ;

    WaitForBarrier(Sync) ;
    WaitForClock(StreamTxRec, 2) ;
    -- Extra Cycle to allow switch over
    Send( StreamTxRec, X"0001_1000" + 5 ) ;
    WaitForClock(StreamTxRec, 2) ;

    for I in 1 to 4 loop
      Send( StreamTxRec, X"0001_2000" + I ) ;
    end loop ;


-- SendBurstIncrement and GetBurst + CheckBurstIncrement
    log("SendBurstIncrement and GetBurst + CheckBurstIncrement: 6 x 4 word bursts") ;
    WaitForBarrier(Sync) ;
    BlankLine(2) ; 
    WaitForClock(StreamTxRec, 2) ;
    SendBurstIncrement(StreamTxRec, X"0002_0000", 4) ;
    SendBurstIncrement(StreamTxRec, X"0002_1000", 4) ;

    WaitForBarrier(Sync) ;
    WaitForClock(StreamTxRec, 2) ;
    -- Extra Cycle to allow switch over
    Send( StreamTxRec, X"0002_0000" + 5 ) ;

    SendBurstIncrement(StreamTxRec, X"0002_2000", 4) ;
    SendBurstIncrement(StreamTxRec, X"0002_3000", 4) ;

    WaitForBarrier(Sync) ;
    WaitForClock(StreamTxRec, 2) ;
    -- Extra Cycle to allow switch over
    Send( StreamTxRec, X"0002_1000" + 5 ) ;
    WaitForClock(StreamTxRec, 2) ;

    SendBurstIncrement(StreamTxRec, X"0002_4000", 4) ;
    SendBurstIncrement(StreamTxRec, X"0002_5000", 4) ;

-- SendBurstIncrement and CheckBurstIncrement
    log("SendBurstIncrement and CheckBurstIncrement: Send 6 x 4 word bursts") ;
    WaitForBarrier(Sync) ;
    BlankLine(2) ; 
    WaitForClock(StreamTxRec, 2) ;
    SendBurstIncrement(StreamTxRec, X"0003_0000", 4) ;
    SendBurstIncrement(StreamTxRec, X"0003_1000", 4) ;

    WaitForBarrier(Sync) ;
    WaitForClock(StreamTxRec, 2) ;
    -- Extra Cycle to allow switch over
    Send( StreamTxRec, X"0003_1000" + 5 ) ;

    SendBurstIncrement(StreamTxRec, X"0003_2000", 4) ;
    WaitForClock(StreamTxRec, 2) ;
    SendBurstIncrement(StreamTxRec, X"0003_3000", 4) ;
    WaitForClock(StreamTxRec, 2) ;

    WaitForBarrier(Sync) ;
    WaitForClock(StreamTxRec, 2) ;
    -- Extra Cycle to allow switch over
    Send( StreamTxRec, X"0003_3000" + 5 ) ;
    WaitForClock(StreamTxRec, 2) ;

    SendBurstIncrement(StreamTxRec, X"0003_4000", 4) ;
    SendBurstIncrement(StreamTxRec, X"0003_5000", 4) ;


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
    variable Available : boolean ; 
  begin
    WaitForClock(StreamRxRec, 2) ;

-- Send and Get
--    log("Transmit 12 words") ;
    WaitForClock( StreamRxRec, 2) ;
    for I in 1 to 4 loop
      WaitForClock( StreamRxRec, 1) ;
      GetStartTime := Now ;
--      Get(StreamRxRec, RxData) ;
      loop 
        TryGet(StreamRxRec, RxData, Available) ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
      end loop ; 
      AffirmIfEqual(RxData, X"0000_0000" + I, "RxData") ;
      AffirmIf(GetStartTime = Now, "Get Start: " & to_string(GetStartTime, 1 ns) &
          " = Finish: "  & to_string(Now, 1 ns) ) ;
    end loop ;

    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_WAIT_FOR_GET, TRUE) ;
    WaitForBarrier(Sync) ;
    -- Extra Cycle to allow switch over
    WaitForClock( StreamRxRec, 2) ;
    Check(StreamRxRec, X"0000_0000" + 5 ) ;

    for I in 1 to 4 loop
      WaitForClock( StreamRxRec, I mod 2 + 1) ;
      GetStartTime := Now ;
--      Get(StreamRxRec, RxData) ;
      loop 
        TryGet(StreamRxRec, RxData, Available) ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
      end loop ; 
      AffirmIfEqual(RxData, X"0000_1000" + I, "RxData") ;
      AffirmIf(GetStartTime + 10 ns = Now, "Get Start + 10 ns: " & to_string(GetStartTime, 1 ns) &
          " = Finish: "  & to_string(Now, 1 ns) ) ;
    end loop ;

    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_WAIT_FOR_GET, FALSE) ;
    WaitForBarrier(Sync) ;
    -- Extra Cycle to allow switch over
    WaitForClock( StreamRxRec, 4) ;
    Check(StreamRxRec, X"0000_1000" + 5 ) ;
    WaitForClock( StreamRxRec, 4) ;

    for I in 1 to 4 loop
      WaitForClock( StreamRxRec, 1) ;
      GetStartTime := Now ;
--      Get(StreamRxRec, RxData) ;
      loop 
        TryGet(StreamRxRec, RxData, Available) ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
      end loop ; 
      AffirmIfEqual(RxData, X"0000_2000" + I, "RxData") ;
      AffirmIf(GetStartTime = Now, "Get Start: " & to_string(GetStartTime, 1 ns) &
          " = Finish: "  & to_string(Now, 1 ns) ) ;
    end loop ;

-- Send and Check
    WaitForBarrier(Sync) ;
    WaitForClock(StreamRxRec, 3) ;
--    log("Transmit 12 words") ;
    for I in 1 to 4 loop
      WaitForClock(StreamRxRec, 1) ;
      GetStartTime := Now ;
--      Check(StreamRxRec, X"0001_0000" + I ) ;
      loop 
        TryCheck(StreamRxRec, X"0001_0000" + I, Available ) ;
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
      end loop ; 
      AffirmIf(GetStartTime = Now, "Get Start: " & to_string(GetStartTime, 1 ns) &
          " = Finish: "  & to_string(Now, 1 ns) ) ;
    end loop ;

    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_WAIT_FOR_GET, TRUE) ;
    WaitForBarrier(Sync) ;
    -- Extra Cycle to allow switch over
    WaitForClock( StreamRxRec, 2) ;
    Check(StreamRxRec, X"0001_0000" + 5 ) ;

    for I in 1 to 4 loop
      WaitForClock( StreamRxRec, I mod 2 + 1) ;
      GetStartTime := Now ;
--      Check(StreamRxRec, X"0001_1000" + I ) ;
      loop 
        TryCheck(StreamRxRec, X"0001_1000" + I, Available ) ;
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
      end loop ; 
      AffirmIf(GetStartTime + 10 ns = Now, "Get Start + 10 ns: " & to_string(GetStartTime, 1 ns) &
          " = Finish: "  & to_string(Now, 1 ns) ) ;
    end loop ;

    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_WAIT_FOR_GET, FALSE) ;
    WaitForBarrier(Sync) ;
    -- Extra Cycle to allow switch over
    WaitForClock( StreamRxRec, 4) ;
    Check(StreamRxRec, X"0001_1000" + 5 ) ;
    WaitForClock( StreamRxRec, 2) ;

    for I in 1 to 4 loop
      WaitForClock(StreamRxRec, 1) ;
      GetStartTime := Now ;
--      Check(StreamRxRec, X"0001_2000" + I ) ;
      loop 
        TryCheck(StreamRxRec, X"0001_2000" + I, Available ) ;
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
      end loop ; 
      AffirmIf(GetStartTime = Now, "Get Start: " & to_string(GetStartTime, 1 ns) &
          " = Finish: "  & to_string(Now, 1 ns) ) ;
    end loop ;

-- SendBurstIncrement and GetBurst + CheckBurstIncrement
--    log("Send 6 x 4 word bursts") ;
    WaitForBarrier(Sync) ;
    WaitForClock(StreamRxRec, 2 + 8) ;
--! Add Check For Timing - GetBurst finishes without time passing
--    GetBurst(StreamRxRec, NumWords) ;
    loop 
      TryGetBurst (StreamRxRec, NumWords, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;
    AffirmIfEqual(NumWords, 4, "NumWords") ;
    CheckBurstIncrement(StreamRxRec.BurstFifo, X"0002_0000", 4) ;
--    GetBurst(StreamRxRec, NumWords) ;
    loop 
      TryGetBurst (StreamRxRec, NumWords, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;
    AffirmIfEqual(NumWords, 4, "NumWords") ;
    CheckBurstIncrement(StreamRxRec.BurstFifo, X"0002_1000", 4) ;


    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_WAIT_FOR_GET, TRUE) ;
    WaitForBarrier(Sync) ;
    -- Extra Cycle to allow switch over
    WaitForClock( StreamRxRec, 2) ;
    Check(StreamRxRec, X"0002_0000" + 5 ) ;

    WaitForClock( StreamRxRec, 4) ;
--! Add Check For Timing - GetBurst takes time to finish
--    GetBurst(StreamRxRec, NumWords) ;
    loop 
      TryGetBurst (StreamRxRec, NumWords, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;
    AffirmIfEqual(NumWords, 4, "NumWords") ;
    CheckBurstIncrement(StreamRxRec.BurstFifo, X"0002_2000", 4) ;
    WaitForClock( StreamRxRec, 2) ;
--    GetBurst(StreamRxRec, NumWords) ;
    loop 
      TryGetBurst (StreamRxRec, NumWords, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;
    AffirmIfEqual(NumWords, 4, "NumWords") ;
    CheckBurstIncrement(StreamRxRec.BurstFifo, X"0002_3000", 4) ;

    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_WAIT_FOR_GET, FALSE) ;
    WaitForBarrier(Sync) ;
    -- Extra Cycle to allow switch over
    WaitForClock( StreamRxRec, 4) ;
    Check(StreamRxRec, X"0002_1000" + 5 ) ;
    WaitForClock( StreamRxRec, 2 + 8) ;

--! Add Check For Timing - GetBurst finishes without time passing
--    GetBurst(StreamRxRec, NumWords) ;
    loop 
      TryGetBurst (StreamRxRec, NumWords, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;
    AffirmIfEqual(NumWords, 4, "NumWords") ;
    CheckBurstIncrement(StreamRxRec.BurstFifo, X"0002_4000", 4) ;
--    GetBurst(StreamRxRec, NumWords) ;
    loop 
      TryGetBurst (StreamRxRec, NumWords, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;
    AffirmIfEqual(NumWords, 4, "NumWords") ;
    CheckBurstIncrement(StreamRxRec.BurstFifo, X"0002_5000", 4) ;


-- SendBurstIncrement and CheckBurstIncrement
--    log("Send 6 x 4 word bursts") ;
    WaitForBarrier(Sync) ;
    WaitForClock(StreamRxRec, 2) ;
-- PushBurstIncrement followed by TryCheckBurst
--    CheckBurstIncrement(StreamRxRec, X"0003_0000", 4) ;
    PushBurstIncrement(RxBurstFifo, X"0003_0000", 4) ;
    loop 
      TryCheckBurst (StreamRxRec, 4, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;
-- TryCheckBurstIncrement    
--    CheckBurstIncrement(StreamRxRec, X"0003_1000", 4) ;
    loop 
      TryCheckBurstIncrement(StreamRxRec, X"0003_1000", 4, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;

    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_WAIT_FOR_GET, TRUE) ;
    WaitForBarrier(Sync) ;
    -- Extra Cycle to allow switch over
    WaitForClock( StreamRxRec, 2) ;
    Check(StreamRxRec, X"0003_1000" + 5 ) ;

    WaitForClock( StreamRxRec, 2) ;
-- PushBurstIncrement followed by TryCheckBurst
--    CheckBurstIncrement(StreamRxRec, X"0003_2000", 4) ;
    PushBurstIncrement(RxBurstFifo, X"0003_2000", 4) ;
    loop 
      TryCheckBurst (StreamRxRec, 4, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;
    WaitForClock( StreamRxRec, 2) ;
-- TryCheckBurstIncrement    
--    CheckBurstIncrement(StreamRxRec, X"0003_3000", 4) ;
    loop 
      TryCheckBurstIncrement(StreamRxRec, X"0003_3000", 4, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;

    SetAxiStreamOptions(StreamRxRec, RECEIVE_READY_WAIT_FOR_GET, FALSE) ;
    WaitForBarrier(Sync) ;
    -- Extra Cycle to allow switch over
    WaitForClock( StreamRxRec, 4) ;
    Check(StreamRxRec, X"0003_3000" + 5 ) ;
    WaitForClock( StreamRxRec, 2 + 8) ;

--! Add Check For Timing - GetBurst finishes without time passing
-- PushBurstIncrement followed by TryCheckBurst
--    CheckBurstIncrement(StreamRxRec, X"0003_4000", 4) ;
    PushBurstIncrement(RxBurstFifo, X"0003_4000", 4) ;
    loop 
      TryCheckBurst (StreamRxRec, 4, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;
    WaitForClock( StreamRxRec, 2) ;
-- TryCheckBurstIncrement    
--    CheckBurstIncrement(StreamRxRec, X"0003_5000", 4) ;
    loop 
      TryCheckBurstIncrement(StreamRxRec, X"0003_5000", 4, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
    end loop ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ReceiverProc ;

end WaitForGetAsync1 ;

Configuration TbStream_WaitForGetAsync1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(WaitForGetAsync1) ;
    end for ;
  end for ;
end TbStream_WaitForGetAsync1 ;
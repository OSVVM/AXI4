--
--  File Name:         TbStream_ReleaseAcquireTransmitter1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      ReleaseTransactionRecord / AcquireTransactionRecord
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
architecture ReleaseAcquireTransmitter1 of TestCtrl is

  signal   Sync1, TestDone : integer_barrier := 1 ;
  constant ID1   : std_logic_vector(ID_LEN-1 downto 0)   := to_slv(15, ID_LEN) ;    -- 8
  constant DEST1 : std_logic_vector(DEST_LEN-1 downto 0) := to_slv(10, DEST_LEN) ;  -- 4
  constant USER1 : std_logic_vector(USER_LEN-1 downto 0) := to_slv( 4, USER_LEN) ;  -- 4
  constant ID2   : std_logic_vector(ID_LEN-1 downto 0)   := to_slv( 7, ID_LEN) ;    -- 8
  constant DEST2 : std_logic_vector(DEST_LEN-1 downto 0) := to_slv( 5, DEST_LEN) ;  -- 4
  constant USER2 : std_logic_vector(USER_LEN-1 downto 0) := to_slv( 2, USER_LEN) ;  -- 4
  signal TbID : AlertLogIDType ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_ReleaseAcquireTransmitter1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    TbID <= GetAlertLogID("Testbench") ;

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_ReleaseAcquireTransmitter1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms) ;
    AlertIf(now >= 5 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_ReleaseAcquireTransmitter1.txt", "../sim_shared/validated_results/TbStream_ReleaseAcquireTransmitter1.txt", "") ; 
    
    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc1
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc1 : process
    variable StartTime : time ; 
    variable IntOption  : integer ; 
    variable BoolOption : boolean ; 
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 1) ; 
    StartTime := now ; 
    WaitForClock(StreamTxRec, 2) ; 
    AffirmIfEqual(NOW, StartTime + 20 ns, "Expected Completion Time") ;

    SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_DELAY_CYCLES, 2) ;
    GetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbID, IntOption, 2, "TRANSMIT_VALID_DELAY_CYCLES") ;

    Send(StreamTxRec, X"AAAA_AAAA", ID1 & DEST1 & USER1 & '0', TRUE) ;
    Send(StreamTxRec, X"BBBB_BBBB", ID1 & DEST1 & USER1 & '0', TRUE) ;

    PushBurstIncrement(TxBurstFifo, 0, 8, DATA_WIDTH) ;
    SendBurst(StreamTxRec, 8, ID1 & DEST1 & USER1 & '1', TRUE) ;
    
    WaitForBarrier(Sync1) ; 
    ReleaseTransactionRecord(StreamTxRec) ; 

    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiTransmitterProc1 ;
  
  ------------------------------------------------------------
  -- AxiTransmitterProc2
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc2 : process
    variable StartTime : time ; 
    variable IntOption  : integer ; 
    variable BoolOption : boolean ; 
  begin
    WaitForBarrier(Sync1) ; 
    AcquireTransactionRecord(StreamTxRec) ;
    
    StartTime := now ; 
    WaitForClock(StreamTxRec, 1) ; 
    AffirmIfEqual(NOW, StartTime + 10 ns, "Expected Completion Time") ;
    
    SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_DELAY_CYCLES, 1) ;
    GetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbID, IntOption, 1, "TRANSMIT_VALID_DELAY_CYCLES") ;
    
    Send(StreamTxRec, X"CCCC_CCCC", ID2 & DEST2 & USER2 & '0') ;
    Send(StreamTxRec, X"DDDD_DDDD", ID2 & DEST2 & USER2 & '0') ;

    PushBurstIncrement(TxBurstFifo, 16, 8, DATA_WIDTH) ;
    SendBurst(StreamTxRec, 8, ID2 & DEST2 & USER2 & '1') ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamTxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiTransmitterProc2 ;


  ------------------------------------------------------------
  -- AxiReceiverProc
  --   Generate transactions for AxiReceiver
  ------------------------------------------------------------
  AxiReceiverProc : process
    variable NumBytes : integer ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    
    Check(StreamRxRec, X"AAAA_AAAA", ID1 & DEST1 & USER1 & '0') ;
    Check(StreamRxRec, X"BBBB_BBBB", ID1 & DEST1 & USER1 & '0') ;

    PushBurstIncrement(RxBurstFifo, 0, 8, DATA_WIDTH) ;
    CheckBurst(StreamRxRec, 8, ID1 & DEST1 & USER1 & '1') ;

    WaitForBarrier(Sync1) ; 

    Check(StreamRxRec, X"CCCC_CCCC", ID2 & DEST2 & USER2 & '0') ;
    Check(StreamRxRec, X"DDDD_DDDD", ID2 & DEST2 & USER2 & '0') ;

    PushBurstIncrement(RxBurstFifo, 16, 8, DATA_WIDTH) ;
    CheckBurst(StreamRxRec, 8, ID2 & DEST2 & USER2 & '1') ;
  
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end ReleaseAcquireTransmitter1 ;

Configuration TbStream_ReleaseAcquireTransmitter1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ReleaseAcquireTransmitter1) ; 
    end for ; 
  end for ; 
end TbStream_ReleaseAcquireTransmitter1 ; 
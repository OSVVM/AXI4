--
--  File Name:         TbStream_AxiTxValidDelayBurst1.vhd
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
--      Send, Get, Check with 2nd parameter, with ID, Dest, User
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
architecture AxiTxValidDelayBurst1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_AxiTxValidDelayBurst1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiTxValidDelayBurst1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiTxValidDelayBurst1.txt", "../sim_shared/validated_results/TbStream_AxiTxValidDelayBurst1.txt", "") ; 
    
    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc : process
    variable IntOption : integer ; 
    variable Data      : std_logic_vector(DATA_WIDTH-1 downto 0) ;
    variable ByteVal   : integer := 0 ; 
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    
    -- Check Defaults
    GetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(IntOption, 0, "TRANSMIT_VALID_DELAY_CYCLES") ;
    GetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_BURST_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(IntOption, 0, "TRANSMIT_VALID_BURST_DELAY_CYCLES") ;

    for h in 0 to 3 loop
      case h is 
        when 0 => 
          log("Valid Delay Cycles Default 0") ;
        when 1 => 
          log("Valid Delay Cycles 2") ;
          SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_DELAY_CYCLES, 4) ;
          SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_BURST_DELAY_CYCLES, 2) ;
        when 2 => 
          log("Valid Delay Cycles 4") ;
          SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_DELAY_CYCLES, 6) ;
          SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_BURST_DELAY_CYCLES, 4) ;
        when 3 => 
          log("Valid Delay Cycles 0") ;
          SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_DELAY_CYCLES, 2) ;
          SetAxiStreamOptions(StreamTxRec, TRANSMIT_VALID_BURST_DELAY_CYCLES, 0) ;
        when others => 
          Alert("Unimplemented test case", FAILURE)  ; 
      end case ; 
      log("Transmit 2 bursts of 8 words each") ;
      PushBurstIncrement(TxBurstFifo, ByteVal, 8, DATA_WIDTH) ;
      SendBurst(StreamTxRec, 8) ;
      ByteVal := ByteVal + 8 ;
      PushBurstIncrement(TxBurstFifo, ByteVal, 8, DATA_WIDTH) ;
      SendBurst(StreamTxRec, 8) ;
      ByteVal := ByteVal + 8 ;
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
    variable ExpData : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable ByteVal : integer := 0 ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    
    for h in 0 to 3 loop 
--      log("Receive 2 bursts of 8 words each") ;
      PushBurstIncrement(RxBurstFifo, ByteVal, 8, DATA_WIDTH) ;
      CheckBurst(StreamRxRec, 8) ;
      ByteVal := ByteVal + 8 ;
      PushBurstIncrement(RxBurstFifo, ByteVal, 8, DATA_WIDTH) ;
      CheckBurst(StreamRxRec, 8) ;
      ByteVal := ByteVal + 8 ;
    end loop ;
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end AxiTxValidDelayBurst1 ;

Configuration TbStream_AxiTxValidDelayBurst1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiTxValidDelayBurst1) ; 
    end for ; 
  end for ; 
end TbStream_AxiTxValidDelayBurst1 ; 
--
--  File Name:         TbStream_SendCheckBurstAsyncPattern2.vhd
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
--      SendBurstRandom, CheckBurstRandom using Coverage
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
architecture SendCheckBurstAsyncPattern2 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
  constant FIFO_WIDTH : integer := DATA_WIDTH ; 
--    constant FIFO_WIDTH : integer := 8 ; -- BYTE 
  constant DATA_ZERO  : std_logic_vector := (FIFO_WIDTH - 1 downto 0 => '0') ; 

 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_SendCheckBurstAsyncPattern2") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_SendCheckBurstAsyncPattern2.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms) ;
    AlertIf(now >= 5 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_SendCheckBurstAsyncPattern2.txt", "../sim_shared/validated_results/TbStream_SendCheckBurstAsyncPattern2.txt", "") ; 
    
    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc : process
    variable CoverID : CoverageIdType ; 
  begin
    CoverID := NewID("Cov1") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, GenBin(0,7) & GenBin(32,39) & GenBin(64,71) & GenBin(96,103)) ; 
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    
    SendBurstRandomAsync(StreamTxRec, CoverID, 16, FIFO_WIDTH) ; 

    SendBurstRandomAsync(StreamTxRec, CoverID, 14, FIFO_WIDTH) ; 

    SendBurstRandomAsync(StreamTxRec, CoverID, 17, FIFO_WIDTH) ; 

    SendBurstRandomAsync(StreamTxRec, CoverID, 13, FIFO_WIDTH) ; 


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
    variable CoverID : CoverageIdType ; 
    variable TryCount  : integer ; 
    variable Available : boolean ; 
  begin
    CoverID := NewID("Cov2") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, GenBin(0,7) & GenBin(32,39) & GenBin(64,71) & GenBin(96,103)) ; 
    
    WaitForClock(StreamRxRec, 2) ; 
    
    TryCount := 0 ; 
    loop 
      TryCheckBurstRandom(StreamRxRec, CoverID, 16, FIFO_WIDTH, Available) ; 
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
      TryCount := TryCount + 1 ;
    end loop ;
    AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;

    TryCount := 0 ; 
    loop 
      TryCheckBurstRandom(StreamRxRec, CoverID, 14, FIFO_WIDTH, Available) ; 
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
      TryCount := TryCount + 1 ;
    end loop ;
    AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
    
    TryCount := 0 ; 
    loop 
      TryCheckBurstRandom(StreamRxRec, CoverID, 17, FIFO_WIDTH, Available) ; 
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
      TryCount := TryCount + 1 ;
    end loop ;
    AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;

    TryCount := 0 ; 
    loop 
      TryCheckBurstRandom(StreamRxRec, CoverID, 13, FIFO_WIDTH, Available) ; 
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
      TryCount := TryCount + 1 ;
    end loop ;
    AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end SendCheckBurstAsyncPattern2 ;

Configuration TbStream_SendCheckBurstAsyncPattern2 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SendCheckBurstAsyncPattern2) ; 
    end for ; 
  end for ; 
end TbStream_SendCheckBurstAsyncPattern2 ; 
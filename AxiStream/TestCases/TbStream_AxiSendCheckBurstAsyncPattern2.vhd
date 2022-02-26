--
--  File Name:         TbStream_AxiSendCheckBurstAsyncPattern2.vhd
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
--      SendBurstVector, GetBurst with 2 parameters
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
--  Copyright (c) 2020 by SynthWorks Design Inc.  
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
architecture AxiSendCheckBurstAsyncPattern2 of TestCtrl is

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
    SetAlertLogName("TbStream_AxiSendCheckBurstAsyncPattern2") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiSendCheckBurstAsyncPattern2.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms) ;
    AlertIf(now >= 5 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiSendCheckBurstAsyncPattern2.txt", "../sim_shared/validated_results/TbStream_AxiSendCheckBurstAsyncPattern2.txt", "") ; 
    
    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc : process
    variable ID   : std_logic_vector(ID_LEN-1 downto 0) ;    -- 8
    variable Dest : std_logic_vector(DEST_LEN-1 downto 0) ;  -- 4
    variable User : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
    variable CoverID : CoverageIdType ; 
  begin
    CoverID := NewID("Cov1") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, GenBin(0,7) & GenBin(32,39) & GenBin(64,71) & GenBin(96,103)) ; 
    
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    SetBurstMode(StreamTxRec, STREAM_BURST_BYTE_MODE) ;
    
    ID   := to_slv(1, ID_LEN);
    Dest := to_slv(2, DEST_LEN) ; 
    User := to_slv(3, USER_LEN) ; 

    log("Transmit 16 bytes.  Cover Random") ;
    SendBurstRandomAsync(StreamTxRec, CoverID, 16, FIFO_WIDTH, ID & Dest & User & '1') ;
    WaitForClock(StreamTxRec, 4) ; 

    log("Transmit 14 bytes.") ;
    SendBurstRandomAsync(StreamTxRec, CoverID, 14, FIFO_WIDTH, (ID+1) & (Dest+1) & (User+1) & '1') ;

    log("Transmit 17 bytes.") ;
    SendBurstRandomAsync(StreamTxRec, CoverID, 17, FIFO_WIDTH, (ID+2) & (Dest+2) & (User+2) & '1') ;
    WaitForClock(StreamTxRec, 7) ; 

    log("Transmit 13 bytes.") ;
    SendBurstRandomAsync(StreamTxRec, CoverID, 13, FIFO_WIDTH, (ID+3) & (Dest+3) & (User+3) & '1') ;


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
    variable NumBytes  : integer ; 
    variable ID   : std_logic_vector(ID_LEN-1 downto 0) ;    -- 8
    variable Dest : std_logic_vector(DEST_LEN-1 downto 0) ;  -- 4
    variable User : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
    variable TryCount  : integer ; 
    variable Available : boolean ; 
    variable CoverID : CoverageIdType ; 
  begin
    CoverID := NewID("Cov2") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, GenBin(0,7) & GenBin(32,39) & GenBin(64,71) & GenBin(96,103)) ; 

    WaitForClock(StreamRxRec, 2) ; 
    SetBurstMode(StreamRxRec, STREAM_BURST_BYTE_MODE) ;
    
    ID   := to_slv(1, ID_LEN);
    Dest := to_slv(2, DEST_LEN) ; 
    User := to_slv(3, USER_LEN) ; 

--    log("Transmit 16 bytes.  Cover Random") ;
    TryCount := 0 ; 
    loop 
      TryCheckBurstRandom(StreamRxRec, CoverID, 16, FIFO_WIDTH, ID & Dest & User & '1', Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
      TryCount := TryCount + 1 ;
    end loop ;
    AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
    
--    log("Transmit 14 Bytes -- unaligned") ;
    TryCount := 0 ; 
    loop 
      TryCheckBurstRandom(StreamRxRec, CoverID, 14, FIFO_WIDTH, (ID+1) & (Dest+1) & (User+1) & '1', Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
      TryCount := TryCount + 1 ;
    end loop ;
    AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;

    WaitForClock(StreamRxRec, 7) ; 

--    log("Transmit 17 Bytes -- unaligned") ;
    TryCount := 0 ; 
    loop 
      TryCheckBurstRandom(StreamRxRec, CoverID, 17, FIFO_WIDTH, (ID+2) & (Dest+2) & (User+2) & '1', Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1) ; 
      TryCount := TryCount + 1 ;
    end loop ;
    Print("TryCount " & to_string(TryCount)) ;
    
--    log("Transmit 13 Bytes -- unaligned") ;
    TryCount := 0 ; 
    loop 
      TryCheckBurstRandom(StreamRxRec, CoverID, 13, FIFO_WIDTH, (ID+3) & (Dest+3) & (User+3) & '1', Available) ;
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

end AxiSendCheckBurstAsyncPattern2 ;

Configuration TbStream_AxiSendCheckBurstAsyncPattern2 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiSendCheckBurstAsyncPattern2) ; 
    end for ; 
  end for ; 
end TbStream_AxiSendCheckBurstAsyncPattern2 ; 
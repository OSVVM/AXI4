--
--  File Name:         TbStream_AxiSetOptionsBurst1.vhd
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
--      SendBurst, GetBurst with 2 parameters
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
architecture AxiSetOptionsBurst1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
  
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_AxiSetOptionsBurst1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiSetOptionsBurst1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms) ;
    AlertIf(now >= 5 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiSetOptionsBurst1.txt", "../sim_shared/validated_results/TbStream_AxiSetOptionsBurst1.txt", "") ; 
    
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
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    SetBurstMode(StreamTxRec, STREAM_BURST_BYTE_MODE) ;
    
    ID   := to_slv(1, ID_LEN);
    Dest := to_slv(2, DEST_LEN) ; 
    User := to_slv(3, USER_LEN) ; 
    SetAxiStreamOptions(StreamTxRec, DEFAULT_ID,   ID) ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_DEST, Dest) ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_USER, User) ;

    log("Transmit 32 Bytes -- word aligned") ;
    PushBurstIncrement(TxBurstFifo, 3, 32) ;
    SendBurst(StreamTxRec, 32) ;

    WaitForClock(StreamTxRec, 4) ; 

    log("Transmit 30 Bytes -- unaligned") ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_ID  , (  ID+1)) ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_DEST, (Dest+1)) ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_USER, (User+1)) ;
    PushBurst(TxBurstFifo, (1,3,5,7,9,11,13,15,17,19,21,23,25,27,29)) ;
    PushBurst(TxBurstFifo, (31,33,35,37,39,41,43,45,47,49,51,53,55,57,59)) ;
    SendBurst(StreamTxRec, 30) ;

    WaitForClock(StreamTxRec, 4) ; 

    log("Transmit 34 Bytes -- unaligned") ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_ID  , (  ID+2)) ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_DEST, (Dest+2)) ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_USER, (User+2)) ;
    PushBurstRandom(TxBurstFifo, 7, 34) ;
    SendBurst(StreamTxRec, 34) ;
    
    ID   := to_slv(8, ID_LEN);
    Dest := to_slv(9, DEST_LEN) ; 
    User := to_slv(10, USER_LEN) ; 

    for i in 0 to 6 loop 
      log("Transmit " & to_string(32+5*i) & " Bytes. Starting with " & to_string(i*32)) ;
      SetAxiStreamOptions(StreamTxRec, DEFAULT_ID  , (  ID+i/2)) ;
      SetAxiStreamOptions(StreamTxRec, DEFAULT_DEST, (Dest+i/2)) ;
      SetAxiStreamOptions(StreamTxRec, DEFAULT_USER, (User+i/2)) ;
      PushBurstIncrement(TxBurstFifo, i*32, 32 + 5*i) ;
      SendBurst(StreamTxRec, 32 + 5*i) ;
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
    constant PARAM_LEN : integer := ID_LEN + DEST_LEN + USER_LEN + 1 ; 
    variable RxParam : std_logic_vector(PARAM_LEN-1 downto 0) ;
    alias RxID   : std_logic_vector(ID_LEN-1 downto 0) is RxParam(PARAM_LEN-1 downto PARAM_LEN-ID_LEN) ;
    alias RxDest : std_logic_vector(DEST_LEN-1 downto 0) is RxParam(DEST_LEN-1 + USER_LEN+1 downto USER_LEN+1) ;
    alias RxUser : std_logic_vector(USER_LEN-1 downto 0) is RxParam(USER_LEN downto 1) ;
    variable ID   : std_logic_vector(ID_LEN-1 downto 0) ;    -- 8
    variable Dest : std_logic_vector(DEST_LEN-1 downto 0) ;  -- 4
    variable User : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
  begin
    WaitForClock(StreamRxRec, 2) ; 
    SetBurstMode(StreamRxRec, STREAM_BURST_BYTE_MODE) ;
    
    ID   := to_slv(1, ID_LEN);
    Dest := to_slv(2, DEST_LEN) ; 
    User := to_slv(3, USER_LEN) ; 
    
--    log("Transmit 32 Bytes -- word aligned") ;
    GetBurst (StreamRxRec, NumBytes, RxParam) ;
    AffirmIfEqual(NumBytes, 32, "Receiver: NumBytes Received") ;
    AffirmIfEqual(RxID,   ID,   "Receiver, ID: ") ; 
    AffirmIfEqual(RxDest, Dest, "Receiver, Dest: ") ; 
    AffirmIfEqual(RxUser, User, "Receiver, User: ") ; 
    CheckBurstIncrement(RxBurstFifo, 3, NumBytes) ;
    
--    log("Transmit 30 Bytes -- unaligned") ;
    GetBurst (StreamRxRec, NumBytes, RxParam) ;
    AffirmIfEqual(NumBytes, 30, "Receiver: NumBytes Received") ;
    AffirmIfEqual(RxID,   (ID  +1), "Receiver, ID: ") ; 
    AffirmIfEqual(RxDest, (Dest+1), "Receiver, Dest: ") ; 
    AffirmIfEqual(RxUser, (User+1), "Receiver, User: ") ; 
    CheckBurst(RxBurstFifo, (1,3,5,7,9,11,13,15,17,19,21,23,25,27,29)) ;
    CheckBurst(RxBurstFifo, (31,33,35,37,39,41,43,45,47,49,51,53,55,57,59)) ;

--    log("Transmit 34 Bytes -- unaligned") ;
    GetBurst (StreamRxRec, NumBytes, RxParam) ;
    AffirmIfEqual(NumBytes, 34, "Receiver: NumBytes Received") ;
    AffirmIfEqual(RxID,   (ID  +2), "Receiver, ID: ") ; 
    AffirmIfEqual(RxDest, (Dest+2), "Receiver, Dest: ") ; 
    AffirmIfEqual(RxUser, (User+2), "Receiver, User: ") ; 
    CheckBurstRandom(RxBurstFifo, 7, NumBytes) ;
    
    ID   := to_slv(8, ID_LEN);
    Dest := to_slv(9, DEST_LEN) ; 
    User := to_slv(10, USER_LEN) ; 

    for i in 0 to 6 loop 
--      log("Transmit " & to_string(32+5*i) & " Bytes. Starting with " & to_string(i*32)) ;
      GetBurst (StreamRxRec, NumBytes, RxParam) ;
      AffirmIfEqual(NumBytes, 32 + 5*i, "Receiver: NumBytes Received") ;
      AffirmIfEqual(RxID,   (ID  +i/2), "Receiver, ID: ") ; 
      AffirmIfEqual(RxDest, (Dest+i/2), "Receiver, Dest: ") ; 
      AffirmIfEqual(RxUser, (User+i/2), "Receiver, User: ") ; 
      CheckBurstIncrement(RxBurstFifo, i*32, NumBytes) ;
    end loop ; 
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end AxiSetOptionsBurst1 ;

Configuration TbStream_AxiSetOptionsBurst1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiSetOptionsBurst1) ; 
    end for ; 
  end for ; 
end TbStream_AxiSetOptionsBurst1 ; 
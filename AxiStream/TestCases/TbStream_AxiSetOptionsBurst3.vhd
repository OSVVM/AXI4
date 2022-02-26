--
--  File Name:         TbStream_AxiSetOptionsBurst3.vhd
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
--      Send, Get, Check in Word Mode with 2nd parameter, with ID, Dest, User
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
architecture AxiSetOptionsBurst3 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
  constant MAX_LEN  : integer := maximum(maximum(ID_LEN, DEST_LEN), USER_LEN)  ;
  constant DASH     : std_logic_vector(MAX_LEN-1 downto 0) := (others => '-') ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_AxiSetOptionsBurst3") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiSetOptionsBurst3.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiSetOptionsBurst3.txt", "../sim_shared/validated_results/TbStream_AxiSetOptionsBurst3.txt", "") ; 
    
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
    variable User, TxUser : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
    variable Data : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    SetBurstMode(StreamTxRec, STREAM_BURST_WORD_PARAM_MODE) ;
    
    ID   := (others => '0') ;
    Dest := (others => '0') ;
    User := (others => '0') ;
    Data := (others => '0') ; 
    TxUser := (others => '0') ;

    SetAxiStreamOptions(StreamTxRec, DEFAULT_ID,   ID   + 3) ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_DEST, Dest + 2) ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_USER, User + 1) ;
    
    for i in 1 to 32 loop
      Push(TxBurstFifo, Data & TxUser) ;
      Data   := Data + 1 ; 
      TxUser := TxUser + 1 ; 
    end loop ; 
    SendBurst(StreamTxRec, 32) ;
    
    for i in 1 to 32 loop
      Push(TxBurstFifo, Data & TxUser) ;
      Data   := Data + 1 ; 
      TxUser := TxUser + 1 ; 
    end loop ; 
    SendBurst(StreamTxRec, 32, (USER+5) & "1") ;
    
    for i in 1 to 32 loop
      Push(TxBurstFifo, Data & TxUser) ;
      Data   := Data + 1 ; 
      TxUser := TxUser + 1 ; 
    end loop ; 
    SendBurst(StreamTxRec, 32, (Dest+6) & (USER+5) & "1") ;
    
    for i in 1 to 32 loop
      Push(TxBurstFifo, Data & TxUser) ;
      Data   := Data + 1 ; 
      TxUser := TxUser + 1 ; 
    end loop ; 
    SendBurst(StreamTxRec, 32, (ID+7) & (Dest+6) & (USER+5) & "1") ;
    
    for i in 1 to 32 loop
      Push(TxBurstFifo, Data & TxUser) ;
      Data   := Data + 1 ; 
      TxUser := TxUser + 1 ; 
    end loop ; 
    SendBurst(StreamTxRec, 32, Dash(ID'range) & Dash(Dest'range) & (USER+5) & "-") ;

    for i in 1 to 32 loop
      Push(TxBurstFifo, Data & TxUser) ;
      Data   := Data + 1 ; 
      TxUser := TxUser + 1 ; 
    end loop ; 
    SendBurst(StreamTxRec, 32, Dash(ID'range) & (Dest+6) & Dash(USER'range) & "-") ;

    for i in 1 to 32 loop
      Push(TxBurstFifo, Data & TxUser) ;
      Data   := Data + 1 ; 
      TxUser := TxUser + 1 ; 
    end loop ; 
    SendBurst(StreamTxRec, 32, (ID+7) & Dash(Dest'range) & Dash(USER'range) & "-") ;
   
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
    variable ExpData, RxData : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable NumBytes : integer ; 
    variable ID   : std_logic_vector(ID_LEN-1 downto 0) ;    -- 5
    variable Dest : std_logic_vector(DEST_LEN-1 downto 0) ;  -- 4
    variable User,  ExpUser, RxUser : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
    variable Param, RxParam : std_logic_vector(ID_LEN + DEST_LEN + USER_LEN downto 0) ;
  begin
    WaitForClock(StreamRxRec, 2) ; 
    SetBurstMode(StreamRxRec, STREAM_BURST_WORD_PARAM_MODE) ;
    
    ID   := (others => '0') ;
    Dest := (others => '0') ;
    User := (others => '0') ;
    ExpData := (others => '0') ;
    ExpUser := (others => '0') ;

    SetAxiStreamOptions(StreamRxRec, DEFAULT_ID,   ID   + 3) ;
    SetAxiStreamOptions(StreamRxRec, DEFAULT_DEST, Dest + 2) ;
    SetAxiStreamOptions(StreamRxRec, DEFAULT_USER, User + 1) ;
    
    Param := (ID+3) & (Dest+2) & (X"F") & "1" ;
    GetBurst (StreamRxRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    for i in 1 to NumBytes loop
      (RxData, RxUser) := Pop(RxBurstFifo) ; 
      AffirmIfEqual(RxData, ExpData, "Data") ;
      AffirmIfEqual(RxUser, ExpUser, "User") ;
      ExpData := ExpData + 1 ; 
      ExpUser := ExpUser + 1 ; 
    end loop ;    
    
    Param := (ID+3) & (Dest+2) & (X"F") & "1" ;
    GetBurst (StreamRxRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    for i in 1 to NumBytes loop
      (RxData, RxUser) := Pop(RxBurstFifo) ; 
      AffirmIfEqual(RxData, ExpData, "Data") ;
      AffirmIfEqual(RxUser, ExpUser, "User") ;
      ExpData := ExpData + 1 ; 
      ExpUser := ExpUser + 1 ; 
    end loop ;    
    
    Param := (ID+3) & (Dest+6) & (X"F") & "1" ;
    GetBurst (StreamRxRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    for i in 1 to NumBytes loop
      (RxData, RxUser) := Pop(RxBurstFifo) ; 
      AffirmIfEqual(RxData, ExpData, "Data") ;
      AffirmIfEqual(RxUser, ExpUser, "User") ;
      ExpData := ExpData + 1 ; 
      ExpUser := ExpUser + 1 ; 
    end loop ;    
    
    Param := (ID+7) & (Dest+6) & (X"F") & "1" ;
    GetBurst (StreamRxRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    for i in 1 to NumBytes loop
      (RxData, RxUser) := Pop(RxBurstFifo) ; 
      AffirmIfEqual(RxData, ExpData, "Data") ;
      AffirmIfEqual(RxUser, ExpUser, "User") ;
      ExpData := ExpData + 1 ; 
      ExpUser := ExpUser + 1 ; 
    end loop ;    
    
    Param := (ID+3) & (Dest+2) & (X"F") & "1" ;
    GetBurst (StreamRxRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    for i in 1 to NumBytes loop
      (RxData, RxUser) := Pop(RxBurstFifo) ; 
      AffirmIfEqual(RxData, ExpData, "Data") ;
      AffirmIfEqual(RxUser, ExpUser, "User") ;
      ExpData := ExpData + 1 ; 
      ExpUser := ExpUser + 1 ; 
    end loop ;    

    Param := (ID+3) & (Dest+6) & (X"F") & "1" ;
    GetBurst (StreamRxRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    for i in 1 to NumBytes loop
      (RxData, RxUser) := Pop(RxBurstFifo) ; 
      AffirmIfEqual(RxData, ExpData, "Data") ;
      AffirmIfEqual(RxUser, ExpUser, "User") ;
      ExpData := ExpData + 1 ; 
      ExpUser := ExpUser + 1 ; 
    end loop ;    

    Param := (ID+7) & (Dest+2) & (X"F") & "1" ;
    GetBurst (StreamRxRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    for i in 1 to NumBytes loop
      (RxData, RxUser) := Pop(RxBurstFifo) ; 
      AffirmIfEqual(RxData, ExpData, "Data") ;
      AffirmIfEqual(RxUser, ExpUser, "User") ;
      ExpData := ExpData + 1 ; 
      ExpUser := ExpUser + 1 ; 
    end loop ;    
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end AxiSetOptionsBurst3 ;

Configuration TbStream_AxiSetOptionsBurst3 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiSetOptionsBurst3) ; 
    end for ; 
  end for ; 
end TbStream_AxiSetOptionsBurst3 ; 
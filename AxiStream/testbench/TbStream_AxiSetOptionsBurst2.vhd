--
--  File Name:         TbStream_AxiSetOptionsBurst2.vhd
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
--    05/2017   2018.05    Initial revision
--    01/2020   2020.01    Updated license notice
--    10/2020   2020.10    Updated test to include Check, ...
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
architecture AxiSetOptionsBurst2 of TestCtrl is

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
    SetAlertLogName("TbStream_AxiSetOptionsBurst2") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiSetOptionsBurst2.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiSetOptionsBurst2.txt", "../sim_shared/validated_results/TbStream_AxiSetOptionsBurst2.txt", "") ; 
    
    print("") ;
    -- Expecting five check errors 
    ReportAlerts(ExternalErrors => (0, 0, 0)) ; 
    print("") ;
    std.env.stop ; 
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
    WaitForClock(StreamTransmitterTransRec, 2) ; 
    
    ID   := (others => '0') ;
    Dest := (others => '0') ;
    User := (others => '0') ;

    SetModelOptions(StreamTransmitterTransRec, SET_ID,   ID   + 3) ;
    SetModelOptions(StreamTransmitterTransRec, SET_DEST, Dest + 2) ;
    SetModelOptions(StreamTransmitterTransRec, SET_USER, User + 1) ;
    
    PushBurstIncrement(TxBurstFifo, 0, 32) ;
    SendBurst(StreamTransmitterTransRec, 32) ;
    
    PushBurstIncrement(TxBurstFifo, 32, 32) ;
    SendBurst(StreamTransmitterTransRec, 32, (USER+5) & "0") ;
    
    PushBurstIncrement(TxBurstFifo, 64, 32) ;
    SendBurst(StreamTransmitterTransRec, 32, (Dest+6) & (USER+5) & "0") ;
    
    PushBurstIncrement(TxBurstFifo, 96, 32) ;
    SendBurst(StreamTransmitterTransRec, 32, (ID+7) & (Dest+6) & (USER+5) & "0") ;
    
    PushBurstIncrement(TxBurstFifo, 128, 32) ;
    SendBurst(StreamTransmitterTransRec, 32, Dash(ID'range) & Dash(Dest'range) & (USER+5) & "-") ;

    PushBurstIncrement(TxBurstFifo, 160, 32) ;
    SendBurst(StreamTransmitterTransRec, 32, Dash(ID'range) & (Dest+6) & Dash(USER'range) & "-") ;

    PushBurstIncrement(TxBurstFifo, 192, 32) ;
    SendBurst(StreamTransmitterTransRec, 32, (ID+7) & Dash(Dest'range) & Dash(USER'range) & "-") ;
   
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamTransmitterTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiTransmitterProc ;


  ------------------------------------------------------------
  -- AxiReceiverProc
  --   Generate transactions for AxiReceiver
  ------------------------------------------------------------
  AxiReceiverProc : process
    variable Data, RxData : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable NumBytes : integer ; 
    variable ID   : std_logic_vector(ID_LEN-1 downto 0) ;    -- 5
    variable Dest : std_logic_vector(DEST_LEN-1 downto 0) ;  -- 4
    variable User : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
    variable Param, RxParam : std_logic_vector(ID_LEN + DEST_LEN + USER_LEN downto 0) ;
  begin
    WaitForClock(StreamReceiverTransRec, 2) ; 
    
    ID   := (others => '0') ;
    Dest := (others => '0') ;
    User := (others => '0') ;
    Data := (others => '0') ;

    SetModelOptions(StreamReceiverTransRec, SET_ID,   ID   + 3) ;
    SetModelOptions(StreamReceiverTransRec, SET_DEST, Dest + 2) ;
    SetModelOptions(StreamReceiverTransRec, SET_USER, User + 1) ;
    
    Param := (ID+3) & (Dest+2) & (User+1) & "1" ;
    GetBurst (StreamReceiverTransRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    CheckBurstIncrement(RxBurstFifo, 0, NumBytes) ;
    
    
    Param := (ID+3) & (Dest+2) & (User+5) & "1" ;
    GetBurst (StreamReceiverTransRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    CheckBurstIncrement(RxBurstFifo, 32, NumBytes) ;
    
    Param := (ID+3) & (Dest+6) & (User+5) & "1" ;
    GetBurst (StreamReceiverTransRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    CheckBurstIncrement(RxBurstFifo, 64, NumBytes) ;
    
    Param := (ID+7) & (Dest+6) & (User+5) & "1" ;
    GetBurst (StreamReceiverTransRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    CheckBurstIncrement(RxBurstFifo, 96, NumBytes) ;
    
    Param := (ID+3) & (Dest+2) & (User+5) & "1" ;
    GetBurst (StreamReceiverTransRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    CheckBurstIncrement(RxBurstFifo, 128, NumBytes) ;

    Param := (ID+3) & (Dest+6) & (User+1) & "1" ;
    GetBurst (StreamReceiverTransRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    CheckBurstIncrement(RxBurstFifo, 160, NumBytes) ;

    Param := (ID+7) & (Dest+2) & (User+1) & "1" ;
    GetBurst (StreamReceiverTransRec, NumBytes, RxParam) ;
    AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
    AffirmIfEqual(NumBytes,  32,    "NumBytes ") ; 
    CheckBurstIncrement(RxBurstFifo, 192, NumBytes) ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamReceiverTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end AxiSetOptionsBurst2 ;

Configuration TbStream_AxiSetOptionsBurst2 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiSetOptionsBurst2) ; 
    end for ; 
  end for ; 
end TbStream_AxiSetOptionsBurst2 ; 
--
--  File Name:         TbStream_AxiLastOptionAsync1.vhd
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
architecture AxiLastOptionAsync1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
  
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_AxiLastOptionAsync1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiLastOptionAsync1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms) ;
    AlertIf(now >= 5 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiLastOptionAsync1.txt", "../sim_shared/validated_results/TbStream_AxiLastOptionAsync1.txt", "") ; 
    
    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc : process
    variable Data : std_logic_vector(DATA_WIDTH-1 downto 0) ;
    variable ID   : std_logic_vector(ID_LEN-1 downto 0) ;    -- 8
    variable Dest : std_logic_vector(DEST_LEN-1 downto 0) ;  -- 4
    variable User : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    Data := (others => '0') ;
    for i in 0 to 15 loop 
      ID   := to_slv(i/2,   ID_LEN);
      Dest := to_slv(1+i/2, DEST_LEN) ; 
      User := to_slv(2+i/2, USER_LEN) ; 
      SetAxiStreamOptions(StreamTxRec, DEFAULT_LAST, 0) ;
      for j in 0 to 63+i loop 
        Data := Data + 1 ; 
        exit when j = 63+i ; 
        SendAsync(StreamTxRec, Data, ID & Dest & User & '-') ;
      end loop ;
      SetAxiStreamOptions(StreamTxRec, DEFAULT_LAST, 1) ;
      SendAsync(StreamTxRec, Data, ID & Dest & User & '-') ;
      WaitForClock(StreamTxRec, i/4) ; 
      if i mod 4 = 0 then 
        WaitForTransaction(StreamTxRec) ; 
      end if ; 
    end loop ; 
    
    WaitForTransaction(StreamTxRec) ; 

    Data := X"00_01_00_00" ; 
    SetAxiStreamOptions(StreamTxRec, DEFAULT_LAST, 8) ;
    for i in 1 to 8*4 loop 
      Data := Data + 1 ; 
      SendAsync(StreamTxRec, Data) ;
    end loop ; 
    
    WaitForTransaction(StreamTxRec) ; 

    Data := X"00_02_00_00" ; 
    SetAxiStreamOptions(StreamTxRec, DEFAULT_LAST, 16) ;
    for i in 1 to 16*4 loop 
      Data := Data + 1 ; 
      SendAsync(StreamTxRec, Data) ;
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
    variable RxData, Data : std_logic_vector(DATA_WIDTH-1 downto 0) ;
    variable NumBytes  : integer ; 
    constant PARAM_LEN : integer := ID_LEN + DEST_LEN + USER_LEN + 1 ; 
    variable RxParam   : std_logic_vector(PARAM_LEN-1 downto 0) ;
    alias RxID    : std_logic_vector(ID_LEN-1 downto 0) is RxParam(PARAM_LEN-1 downto PARAM_LEN-ID_LEN) ;
    alias RxDest  : std_logic_vector(DEST_LEN-1 downto 0) is RxParam(DEST_LEN-1 + USER_LEN+1 downto USER_LEN+1) ;
    alias RxUser  : std_logic_vector(USER_LEN-1 downto 0) is RxParam(USER_LEN downto 1) ;
    variable ID   : std_logic_vector(ID_LEN-1 downto 0) ;    -- 8
    variable Dest : std_logic_vector(DEST_LEN-1 downto 0) ;  -- 4
    variable User : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
    variable PopValid : boolean ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    SetBurstMode(StreamRxRec, STREAM_BURST_BYTE_MODE) ;
    Data := (others => '0') ;

    for i in 0 to 15 loop 
      ID   := to_slv(i/2,   ID_LEN);
      Dest := to_slv(1+i/2, DEST_LEN) ; 
      User := to_slv(2+i/2, USER_LEN) ; 
      GetBurst (StreamRxRec, NumBytes, RxParam) ;
      AffirmIfEqual(NumBytes, (64+i) * DATA_BYTES, "Receiver: NumBytes Received") ;
      AffirmIfEqual(RxID,   ID,   "Receiver, ID: ") ; 
      AffirmIfEqual(RxDest, Dest, "Receiver, Dest: ") ; 
      AffirmIfEqual(RxUser, User, "Receiver, User: ") ; 
      for j in 0 to 63+i loop 
        Data := Data + 1 ; 
        PopWord(RxBurstFifo, PopValid, RxData, NumBytes) ; 
        AlertIfNot(PopValid, "BurstFifo Empty during burst transfer", FAILURE) ; 
        AffirmIfEqual(RxData, Data, "Receiver: ") ;
      end loop ; 
    end loop ; 
    
    Data := X"00_01_00_00" ; 
    for i in 1 to 4 loop 
      GetBurst (StreamRxRec, NumBytes) ;
      AffirmIfEqual(NumBytes, 8 * DATA_BYTES, "Receiver: NumBytes Received") ;
      for j in 1 to 8 loop 
        Data := Data + 1 ; 
        PopWord(RxBurstFifo, PopValid, RxData, NumBytes) ; 
        AlertIfNot(PopValid, "BurstFifo Empty during burst transfer", FAILURE) ; 
        AffirmIfEqual(RxData, Data, "Receiver: ") ;
      end loop ; 
    end loop ; 
     
    Data := X"00_02_00_00" ; 
    for i in 1 to 4 loop 
      GetBurst (StreamRxRec, NumBytes) ;
      AffirmIfEqual(NumBytes, 16 * DATA_BYTES, "Receiver: NumBytes Received") ;
      for j in 1 to 16 loop 
        Data := Data + 1 ; 
        PopWord(RxBurstFifo, PopValid, RxData, NumBytes) ; 
        AlertIfNot(PopValid, "BurstFifo Empty during burst transfer", FAILURE) ; 
        AffirmIfEqual(RxData, Data, "Receiver: ") ;
      end loop ; 
    end loop ; 
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end AxiLastOptionAsync1 ;

Configuration TbStream_AxiLastOptionAsync1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiLastOptionAsync1) ; 
    end for ; 
  end for ; 
end TbStream_AxiLastOptionAsync1 ; 
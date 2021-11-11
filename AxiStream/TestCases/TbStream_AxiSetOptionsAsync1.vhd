--
--  File Name:         TbStream_AxiSetOptionsAsync1.vhd
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
architecture AxiSetOptionsAsync1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_AxiSetOptionsAsync1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiSetOptionsAsync1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiSetOptionsAsync1.txt", "../sim_shared/validated_results/TbStream_AxiSetOptionsAsync1.txt", "") ; 
    
    EndOfTestReports(ExternalErrors => (0, -5, 0)) ; 
    std.env.stop(SumAlertCount(GetAlertCount + (0, -5, 0))) ;
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc : process
    variable Data : std_logic_vector(DATA_WIDTH-1 downto 0) ;
    variable OffSet : integer ; 
    variable ID   : std_logic_vector(ID_LEN-1 downto 0) ;    -- 8
    variable Dest : std_logic_vector(DEST_LEN-1 downto 0) ;  -- 4
    variable User : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    
    log("Send 256 words with each byte incrementing") ;
    for i in 1 to 256 loop 
      -- Create words one byte at a time
      OffSet := i * DATA_BYTES ;
      for j in 0 to DATA_BYTES-1 loop 
        Data := to_slv((OffSet + j) mod 256, 8) & Data(Data'left downto 8) ;
      end loop ; 
      
      ID   := to_slv((i-1)/32, ID_LEN);
      Dest := to_slv((256 - i)/16, DEST_LEN) ; 
      User := to_slv((i-1)/16, USER_LEN) ; 
      
      SetAxiStreamOptions(StreamTxRec, DEFAULT_ID,   ID) ;
      SetAxiStreamOptions(StreamTxRec, DEFAULT_DEST, Dest) ;
      SetAxiStreamOptions(StreamTxRec, DEFAULT_USER, User) ;
      
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
    variable ExpData, RxData : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable OffSet : integer ; 
    variable ExpID   : std_logic_vector(ID_LEN-1 downto 0) ;    -- 8
    variable ExpDest : std_logic_vector(DEST_LEN-1 downto 0) ;  -- 4
    variable ExpUser : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
    variable TryCount : integer ; 
    variable Available : boolean ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    
    -- Get and check the 256 words
    log("Send 256 words with each byte incrementing") ;
    for i in 1 to 256 loop 
      -- Create words one byte at a time
      OffSet := i * DATA_BYTES ;
      for j in 0 to DATA_BYTES-1 loop 
        ExpData := to_slv((OffSet + j) mod 256, 8) & ExpData(ExpData'left downto 8) ;
      end loop ; 
      
      ExpID    := to_slv((i-1)/32, ID_LEN);
      ExpDest  := to_slv((256 - i)/16, DEST_LEN) ; 
      ExpUser  := to_slv((i-1)/16, USER_LEN) ; 

      SetAxiStreamOptions(StreamRxRec, DEFAULT_ID,   ExpID) ;
      SetAxiStreamOptions(StreamRxRec, DEFAULT_DEST, ExpDest) ;
      SetAxiStreamOptions(StreamRxRec, DEFAULT_USER, ExpUser) ;
       
      TryCount := 0 ; 
      loop 
        case i is
          when 252 =>   -- Error in Data
            TryCheck(StreamRxRec, ExpData+1, Available) ; 
          when 253 =>   -- Error in LAST
            SetAxiStreamOptions(StreamRxRec, DEFAULT_LAST, 1) ;
            TryCheck(StreamRxRec, ExpData, Available) ; 
            SetAxiStreamOptions(StreamRxRec, DEFAULT_LAST, 0) ;
          when 254 =>   -- Error in USER
            SetAxiStreamOptions(StreamRxRec, DEFAULT_USER, ExpUser+1) ;
            TryCheck(StreamRxRec, ExpData, Available) ; 
            SetAxiStreamOptions(StreamRxRec, DEFAULT_USER, ExpUser) ;
          when 255 =>   -- Error in DEST
            SetAxiStreamOptions(StreamRxRec, DEFAULT_DEST, ExpDest+1) ;
            TryCheck(StreamRxRec, ExpData, Available) ; 
            SetAxiStreamOptions(StreamRxRec, DEFAULT_DEST, ExpDest) ;
          when 256 =>   -- Error in ID
            SetAxiStreamOptions(StreamRxRec, DEFAULT_ID,   ExpID+1) ;
            TryCheck(StreamRxRec, ExpData, Available) ; 
            SetAxiStreamOptions(StreamRxRec, DEFAULT_ID,   ExpID) ;
          when others =>  -- No Errors 
            TryCheck(StreamRxRec, ExpData, Available) ; 
        end case ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
        TryCount := TryCount + 1 ;
      end loop ; 
      AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
    end loop ;
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end AxiSetOptionsAsync1 ;

Configuration TbStream_AxiSetOptionsAsync1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiSetOptionsAsync1) ; 
    end for ; 
  end for ; 
end TbStream_AxiSetOptionsAsync1 ; 
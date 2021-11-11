--
--  File Name:         TbStream_AxiSetOptionsAsync2.vhd
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
architecture AxiSetOptionsAsync2 of TestCtrl is

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
    SetAlertLogName("TbStream_AxiSetOptionsAsync2") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiSetOptionsAsync2.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiSetOptionsAsync2.txt", "../sim_shared/validated_results/TbStream_AxiSetOptionsAsync2.txt", "") ; 
    
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
    
    ID   := (others => '0') ;
    Dest := (others => '0') ;
    User := (others => '0') ;
    Data := (others => '0') ;

    SetAxiStreamOptions(StreamTxRec, DEFAULT_ID,   ID   + 3) ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_DEST, Dest + 2) ;
    SetAxiStreamOptions(StreamTxRec, DEFAULT_USER, User + 1) ;
    
    for i in 1 to 4 loop 
      SendAsync(StreamTxRec, Data) ;
      Data := Data + 1; 
    end loop ;
    
    for i in 1 to 4 loop 
      SendAsync(StreamTxRec, Data, (USER+5) & "0") ;
      Data := Data + 1; 
    end loop ;
    
    for i in 1 to 4 loop 
      SendAsync(StreamTxRec, Data, (Dest+6) & (USER+5) & "0") ;
      Data := Data + 1; 
    end loop ;
    
    for i in 1 to 4 loop 
      SendAsync(StreamTxRec, Data, (ID+7) & (Dest+6) & (USER+5) & "0") ;
      Data := Data + 1; 
    end loop ;
    
    for i in 1 to 4 loop 
      SendAsync(StreamTxRec, Data, Dash(ID'range) & Dash(Dest'range) & (USER+5) & "-") ;
      Data := Data + 1; 
    end loop ;

    for i in 1 to 4 loop 
      SendAsync(StreamTxRec, Data, Dash(ID'range) & (Dest+6) & Dash(USER'range) & "-") ;
      Data := Data + 1; 
    end loop ;

    for i in 1 to 4 loop 
      SendAsync(StreamTxRec, Data, (ID+7) & Dash(Dest'range) & Dash(USER'range) & "-") ;
      Data := Data + 1; 
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
    variable Data, RxData : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable OffSet : integer ; 
    variable ID   : std_logic_vector(ID_LEN-1 downto 0) ;    -- 5
    variable Dest : std_logic_vector(DEST_LEN-1 downto 0) ;  -- 4
    variable User : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
    variable Param, RxParam : std_logic_vector(ID_LEN + DEST_LEN + USER_LEN downto 0) ;
    variable TryCount  : integer ; 
    variable Available : boolean ; 
  begin
    WaitForClock(StreamRxRec, 2) ; 
    
    ID   := (others => '0') ;
    Dest := (others => '0') ;
    User := (others => '0') ;
    Data := (others => '0') ;

    SetAxiStreamOptions(StreamRxRec, DEFAULT_ID,   ID   + 3) ;
    SetAxiStreamOptions(StreamRxRec, DEFAULT_DEST, Dest + 2) ;
    SetAxiStreamOptions(StreamRxRec, DEFAULT_USER, User + 1) ;
    
    Param := (ID+3) & (Dest+2) & (User+1) & "0" ;
    for i in 1 to 4 loop 
      TryCount := 0 ; 
      loop 
        case i is 
          when 1 =>
            TryGet(StreamRxRec, RxData, RxParam, Available) ;
            if Available then
              AffirmIfEqual(RxData,  Data,    "Data ") ; 
              AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
            end if ; 
          when 2 => 
            TryCheck(StreamRxRec, Data, Param, Available) ;
          when others =>
            TryCheck(StreamRxRec, Data, Available) ;
        end case ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
        TryCount := TryCount + 1 ;
      end loop ;
      AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
      Data := Data + 1; 
    end loop ;
    
    Param := (ID+3) & (Dest+2) & (User+5) & "0" ;
    for i in 1 to 4 loop 
      TryCount := 0 ; 
      loop 
        case i is 
          when 1 =>
            TryGet(StreamRxRec, RxData, RxParam, Available) ;
            if Available then
              AffirmIfEqual(RxData,  Data,    "Data ") ; 
              AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
            end if ; 
          when 2 => 
            TryCheck(StreamRxRec, Data, Param, Available) ;
          when others =>
            TryCheck(StreamRxRec, Data, (USER+5) & "0", Available) ;
        end case ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
        TryCount := TryCount + 1 ;
      end loop ;
      AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
      Data := Data + 1; 
    end loop ;
    
    Param := (ID+3) & (Dest+6) & (User+5) & "0" ;
    for i in 1 to 4 loop 
      TryCount := 0 ; 
      loop 
        case i is 
          when 1 =>
            TryGet(StreamRxRec, RxData, RxParam, Available) ;
            if Available then
              AffirmIfEqual(RxData,  Data,    "Data ") ; 
              AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
            end if ; 
          when 2 => 
            TryCheck(StreamRxRec, Data, Param, Available) ;
          when others =>
            TryCheck(StreamRxRec, Data, (Dest+6) & (USER+5) & "0", Available) ;
        end case ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
        TryCount := TryCount + 1 ;
      end loop ;
      AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
      Data := Data + 1; 
    end loop ;
    
    Param := (ID+7) & (Dest+6) & (User+5) & "0" ;
    for i in 1 to 4 loop 
      TryCount := 0 ; 
      loop 
        case i is 
          when 1 =>
            TryGet(StreamRxRec, RxData, RxParam, Available) ;
            if Available then
              AffirmIfEqual(RxData,  Data,    "Data ") ; 
              AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
            end if ; 
          when 2 => 
            TryCheck(StreamRxRec, Data, Param, Available) ;
          when others =>
            TryCheck(StreamRxRec, Data, (ID+7) & (Dest+6) & (USER+5) & "0", Available) ;
        end case ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
        TryCount := TryCount + 1 ;
      end loop ;
      AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
      Data := Data + 1; 
    end loop ;
    
    Param := (ID+3) & (Dest+2) & (User+5) & "0" ;
    for i in 1 to 4 loop 
      TryCount := 0 ; 
      loop 
        case i is 
          when 1 =>
            TryGet(StreamRxRec, RxData, RxParam, Available) ;
            if Available then
              AffirmIfEqual(RxData,  Data,    "Data ") ; 
              AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
            end if ; 
          when 2 => 
            TryCheck(StreamRxRec, Data, Param, Available) ;
          when others =>
            TryCheck(StreamRxRec, Data, Dash(ID'range) & Dash(Dest'range) & (USER+5) & "-", Available) ;
        end case ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
        TryCount := TryCount + 1 ;
      end loop ;
      AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
      Data := Data + 1; 
    end loop ;

    Param := (ID+3) & (Dest+6) & (User+1) & "0" ;
    for i in 1 to 4 loop 
      TryCount := 0 ; 
      loop 
        case i is 
          when 1 =>
            TryGet(StreamRxRec, RxData, RxParam, Available) ;
            if Available then
              AffirmIfEqual(RxData,  Data,    "Data ") ; 
              AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
            end if ; 
          when 2 => 
            TryCheck(StreamRxRec, Data, Param, Available) ;
          when others =>
            TryCheck(StreamRxRec, Data, Dash(ID'range) & (Dest+6) & Dash(USER'range) & "-", Available) ;
        end case ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
        TryCount := TryCount + 1 ;
      end loop ;
      AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
      Data := Data + 1; 
    end loop ;

    Param := (ID+7) & (Dest+2) & (User+1) & "0" ;
    for i in 1 to 4 loop 
      TryCount := 0 ; 
      loop 
        case i is 
          when 1 =>
            TryGet(StreamRxRec, RxData, RxParam, Available) ;
            if Available then
              AffirmIfEqual(RxData,  Data,    "Data ") ; 
              AffirmIfEqual(RxParam, Param,   "Param ID & Dest & User ") ; 
            end if ; 
          when 2 => 
            TryCheck(StreamRxRec, Data, Param, Available) ;
          when others =>
            TryCheck(StreamRxRec, Data, (ID+7) & Dash(Dest'range) & Dash(USER'range) & "-", Available) ;
        end case ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1) ; 
        TryCount := TryCount + 1 ;
      end loop ;
      AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
      Data := Data + 1; 
    end loop ;     
    
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end AxiSetOptionsAsync2 ;

Configuration TbStream_AxiSetOptionsAsync2 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiSetOptionsAsync2) ; 
    end for ; 
  end for ; 
end TbStream_AxiSetOptionsAsync2 ; 
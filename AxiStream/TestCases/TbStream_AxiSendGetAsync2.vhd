--
--  File Name:         TbStream_AxiSendGetAsync2.vhd
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
architecture AxiSendGetAsync2 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_AxiSendGetAsync2") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiSendGetAsync2.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 1 ms) ;
    AlertIf(now >= 1 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiSendGetAsync2.txt", "../sim_shared/validated_results/TbStream_AxiSendGetAsync2.txt", "") ; 
    
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
    variable CurTime : time ; 
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
      
      SendAsync(StreamTxRec, Data, ID & Dest & User & '0') ;
      
      if (i mod 32) = 0 then
        CurTime := now ; 
        WaitForTransaction(StreamTxRec) ;
        AffirmIf(now > CurTime, 
           "Transmitter: WaitForTransaction started at: " & to_string(CurTime, 1 ns) & 
           "  finished at: " & to_string(now, 1 ns)) ;
        WaitForClock(StreamTxRec, 4) ; 
      end if ; 
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
    variable ExpParam, RxParam : std_logic_vector(ID_LEN + DEST_LEN + USER_LEN downto 0) ;
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
      ExpParam := ExpID & ExpDest & ExpUser & '0' ;
       
      -- Alternate using Get and Check
      TryCount := 0 ; 
      if (i mod 2) /= 0 and i < 252 then 
        loop 
          TryGet(StreamRxRec, RxData, RxParam, Available) ; 
          exit when Available ; 
          WaitForClock(StreamRxRec, 1) ; 
          TryCount := TryCount + 1 ;
        end loop ; 
        AffirmIfEqual(RxData, ExpData, "Get, Data: ") ;
        AffirmIfEqual(RxParam, ExpParam, "Get, Param: ") ;
      else 
        -- Inject Errors on last 5 transfers
        loop 
          case i is
            when 252 =>   -- Error in Data
              TryCheck(StreamRxRec, ExpData+1, ExpParam, Available) ; 
            when 253 =>   -- Error in LAST
              TryCheck(StreamRxRec, ExpData, ExpID & ExpDest & ExpUser & '1', Available) ; 
            when 254 =>   -- Error in USER
              TryCheck(StreamRxRec, ExpData, ExpID & ExpDest & (ExpUser+1) & '0', Available) ; 
            when 255 =>   -- Error in DEST
              TryCheck(StreamRxRec, ExpData, ExpID & (ExpDest+1) & ExpUser & '0', Available) ; 
            when 256 =>   -- Error in ID
              TryCheck(StreamRxRec, ExpData, (ExpID + 1) & ExpDest & ExpUser & '0', Available) ; 
            when others =>  -- No Errors 
              TryCheck(StreamRxRec, ExpData, ExpParam, Available) ; 
          end case ; 
          exit when Available ; 
          WaitForClock(StreamRxRec, 1) ; 
          TryCount := TryCount + 1 ;
        end loop ; 
      end if ; 
      AffirmIf(TryCount > 0, "TryCount " & to_string(TryCount)) ;
     end loop ;
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end AxiSendGetAsync2 ;

Configuration TbStream_AxiSendGetAsync2 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiSendGetAsync2) ; 
    end for ; 
  end for ; 
end TbStream_AxiSendGetAsync2 ; 
--
--  File Name:         TbStream_ByteHandling1.vhd
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
--      Send, Get, Check, 
--      WaitForTransaction, GetTransactionCount
--      GetAlertLogID, GetErrorCount, 
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
architecture ByteHandling1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_ByteHandling1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_ByteHandling1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_ByteHandling1.txt", "../sim_shared/validated_results/TbStream_ByteHandling1.txt", "") ; 
    
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
  begin
    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    
    -- Single Bytes - with Z
    Data := (DATA_WIDTH-1 downto 8 => 'Z') & X"01" ;
    for i in 1 to DATA_BYTES loop 
      Send(StreamTxRec, Data) ;
      Data := Data(DATA_WIDTH-8-1 downto 0) & X"ZZ" ;
    end loop ; 
    
    -- Two Bytes - with Z
    If DATA_BYTES > 2 then
      Data := (DATA_WIDTH-1 downto 16 => 'Z') & X"0302" ;
      for i in 1 to DATA_BYTES-1 loop 
        Send(StreamTxRec, Data) ;
        Data := Data(DATA_WIDTH-8-1 downto 0) & X"ZZ" ;
      end loop ; 
    end if; 

    -- Three Bytes - with Z
    If DATA_BYTES > 3 then
      Data := (DATA_WIDTH-1 downto 24 => 'Z') & X"060504" ;
      for i in 1 to DATA_BYTES-2 loop 
        Send(StreamTxRec, Data) ;
        Data := Data(DATA_WIDTH-8-1 downto 0) & X"ZZ" ;
      end loop ; 
    end if; 
    
    -- Single Bytes - with U
    Data := (DATA_WIDTH-1 downto 8 => 'U') & X"01" ;
    for i in 1 to DATA_BYTES loop 
      Send(StreamTxRec, Data) ;
      Data := Data(DATA_WIDTH-8-1 downto 0) & X"UU" ;
    end loop ; 
    
    -- Two Bytes - with U
    If DATA_BYTES > 2 then
      Data := (DATA_WIDTH-1 downto 16 => 'U') & X"0302" ;
      for i in 1 to DATA_BYTES-1 loop 
        Send(StreamTxRec, Data) ;
        Data := Data(DATA_WIDTH-8-1 downto 0) & X"UU" ;
      end loop ; 
    end if; 

    -- Three Bytes - with U
    If DATA_BYTES > 3 then
      Data := (DATA_WIDTH-1 downto 24 => 'U') & X"060504" ;
      for i in 1 to DATA_BYTES-2 loop 
        Send(StreamTxRec, Data) ;
        Data := Data(DATA_WIDTH-8-1 downto 0) & X"UU" ;
      end loop ; 
    end if; 
   
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
  begin
    WaitForClock(StreamRxRec, 2) ; 
    
    
    for i in 1 to 2 loop 
      -- Single Bytes - with Z, then U
      Data := (DATA_WIDTH-1 downto 8 => '-') & X"01" ;
      for i in 1 to DATA_BYTES loop 
        Get(StreamRxRec, RxData) ; 
        AffirmIfEqual(RxData, Data, "Get One Byte: ") ;
        Data := Data(DATA_WIDTH-8-1 downto 0) & X"--" ;
      end loop ; 
      
      -- Two Bytes - with Z, then U
      If DATA_BYTES > 2 then
        Data := (DATA_WIDTH-1 downto 16 => '-') & X"0302" ;
        for i in 1 to DATA_BYTES-1 loop 
          Get(StreamRxRec, RxData) ; 
          AffirmIfEqual(RxData, Data, "Get Two Bytes: ") ;
          Data := Data(DATA_WIDTH-8-1 downto 0) & X"--" ;
        end loop ; 
      end if; 

      -- Three Bytes - with Z, then U
      If DATA_BYTES > 3 then
        Data := (DATA_WIDTH-1 downto 24 => '-') & X"060504" ;
        for i in 1 to DATA_BYTES-2 loop 
          Get(StreamRxRec, RxData) ; 
          AffirmIfEqual(RxData, Data, "Get Three Bytes: ") ;
          Data := Data(DATA_WIDTH-8-1 downto 0) & X"--" ;
        end loop ; 
      end if; 
    
    end loop ;
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end ByteHandling1 ;

Configuration TbStream_ByteHandling1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ByteHandling1) ; 
    end for ; 
  end for ; 
end TbStream_ByteHandling1 ; 
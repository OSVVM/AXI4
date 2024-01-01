--
--  File Name:         TbStream_Xilinx1.vhd
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
architecture Xilinx1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbStream_Xilinx1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for simulation elaboration/initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
    AffirmIfNotDiff(GetTranscriptName, OSVVM_VALIDATED_RESULTS_DIR & GetTranscriptName, "") ;   
    
    -- Expecting two check errors at 128 and 256
    EndOfTestReports(ExternalErrors => (0, 0, 0)) ; 
    std.env.stop ;
    wait ; 
  end process ControlProc ; 



  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  TransmitterProc : process
    variable Data : std_logic_vector(DATA_WIDTH-1 downto 0) ;
--    variable CoverID : CoverageIdType ; 
  begin
    StreamTxRec.Rdy <= 0 ;   --x bug work around
    StreamTxRec.Ack <= -1 ;   --x bug work around

    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 2) ; 
    
-- Send and Get    
    log("Transmit 32 words") ;
    for I in 1 to 32 loop 
--x      Send( StreamTxRec, X"0000_0000" + I ) ; 
      Data := X"0000_0000" + I ;
      Send( StreamTxRec, Data ) ; 
    end loop ; 

    WaitForClock(StreamTxRec, 1) ; 

-- Send and Check    
    log("Transmit 32 words") ;
    for I in 1 to 32 loop 
--x      Send( StreamTxRec, X"0000_1000" + I ) ; 
      Data := X"0000_1000" + I ;
      Send( StreamTxRec, Data ) ; 
    end loop ; 


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamTxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process TransmitterProc ;

  ------------------------------------------------------------
  -- AxiReceiverProc
  --   Generate transactions for AxiReceiver
  ------------------------------------------------------------
  ReceiverProc : process
    variable ExpData, RxData : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable NumBytes : integer ; 
--    variable CoverID : CoverageIdType ; 
--    variable slvBurstVector : slv_vector(1 to 5)(31 downto 0) ; 
--    variable intBurstVector : integer_vector(1 to 5) ; 
  begin
    StreamRxRec.Rdy <= 0 ;   --x bug work around
    StreamRxRec.Ack <= -1 ;   --x bug work around
    wait for 0 ns ; wait for 0 ns ; 
    WaitForClock(StreamRxRec, 2) ; 
    
--    log("Transmit 32 words") ;
    for I in 1 to 32 loop 
--x      Check(StreamRxRec, X"0000_0000" + I ) ;      
      ExpData := X"0000_0000" + I ;
      Check(StreamRxRec, ExpData ) ;      
    end loop ; 

-- --    log("Transmit 32 words") ;
--     for I in 1 to 32 loop 
-- --      ExpData := X"0000_0000" + I ;
--       Get(StreamRxRec, RxData) ;      
--       wait for 0 ns ; 
--       AffirmIfEqual(RxData,  X"0000_0000" + I, "RxData") ;
-- --      AffirmIfEqual(RxData, ExpData, "RxData") ;
--     end loop ; 

    for I in 1 to 32 loop 
--      ExpData := X"0000_0000" + I ;
      Get(StreamRxRec, RxData) ;      
      wait for 0 ns ; 
      AffirmIfEqual(RxData,  X"0000_1000" + I, "RxData") ;
--      AffirmIfEqual(RxData, ExpData, "RxData") ;
    end loop ; 

----    log("Transmit 32 words") ;
--    for I in 1 to 32 loop 
----x      Check(StreamRxRec, X"0000_1000" + I ) ;      
--      ExpData := X"0000_1000" + I ;
--      Check(StreamRxRec, ExpData ) ;      
--    end loop ; 


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ReceiverProc ;

end Xilinx1 ;

/*
Configuration TbStream_Xilinx1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(Xilinx1) ; 
    end for ; 
  end for ; 
end TbStream_Xilinx1 ; 
*/
--
--  File Name:         TbStream_AxiTiming1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Set AXI Ready Time.   Check Timeout on Valid (nominally large or infinite?)
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
architecture AxiTiming1 of TestCtrl is

  signal TestDone, TestPhaseStart : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_AxiTiming1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    SetAlertStopCount(FAILURE, integer'right) ;  -- Allow FAILURES

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiTiming1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiTiming1.txt", "../sim_shared/validated_results/TbStream_AxiTiming1.txt", "") ; 
    
    print("") ;
    -- Expecting two check errors at 128 and 256
    ReportAlerts(ExternalErrors => (FAILURE => -4, ERROR => -2, WARNING => 0)) ; 
    print("") ;
    std.env.stop ; 
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
    WaitForClock(StreamTransmitterTransRec, 2) ; 
    
-- Start test phase 1:  Write Address
WaitForBarrier(TestPhaseStart) ;
log("Transmit Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    WaitForClock(StreamTransmitterTransRec, 2) ; 

    Send(StreamTransmitterTransRec,  X"0001_0010") ;  -- Pass
    WaitForClock(StreamTransmitterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(StreamTransmitterTransRec, TRANSMIT_READY_TIME_OUT, 5) ;
    Send(StreamTransmitterTransRec,  X"BAD0_0010") ;  -- Write Address Fail
    WaitForClock(StreamTransmitterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(StreamTransmitterTransRec, TRANSMIT_READY_TIME_OUT, 10) ;
    Send(StreamTransmitterTransRec,  X"0002_0020") ;  -- Pass
    WaitForClock(StreamTransmitterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(StreamTransmitterTransRec, TRANSMIT_READY_TIME_OUT, 5) ;
    Send(StreamTransmitterTransRec,  X"BAD0_0020") ;  -- Write Address Fail
    WaitForClock(StreamTransmitterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(StreamTransmitterTransRec, TRANSMIT_READY_TIME_OUT, 25) ;
    Send(StreamTransmitterTransRec,  X"0003_0030") ;  -- Pass
    WaitForClock(StreamTransmitterTransRec, 10) ; 
    print("") ;  print("") ;  
       
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
    variable Data : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
  begin
    WaitForClock(StreamReceiverTransRec, 2) ; 
    
-- Start test phase 1:  Write Address
WaitForBarrier(TestPhaseStart) ;
    SetModelOptions(StreamReceiverTransRec, RECEIVE_READY_DELAY_CYCLES, 7) ;
    SetModelOptions(StreamReceiverTransRec, RECEIVE_READY_BEFORE_VALID, FALSE) ;

    Get(StreamReceiverTransRec, Data) ;  -- Pass.  Ready Delay still = 0.
    AffirmIfEqual(Data, X"0001_0010", "Get Data: ") ;

    Get(StreamReceiverTransRec, Data) ;  -- Fail
    AffirmIfEqual(Data, X"BAD0_0010", "Get Data: ") ;
    
    Get(StreamReceiverTransRec, Data) ;  -- Pass
    AffirmIfEqual(Data, X"0002_0020", "Get Data: ") ;
    
    Get(StreamReceiverTransRec, Data) ;  -- Fail
    AffirmIfEqual(Data, X"BAD0_0020", "Get Data: ") ;
    
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(StreamReceiverTransRec, RECEIVE_READY_DELAY_CYCLES, 0) ;
    SetModelOptions(StreamReceiverTransRec, RECEIVE_READY_BEFORE_VALID, TRUE) ;

    Get(StreamReceiverTransRec, Data) ;  -- Pass
    AffirmIfEqual(Data, X"0003_0030", "Get Data: ") ;
    
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamReceiverTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end AxiTiming1 ;

Configuration TbStream_AxiTiming1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiTiming1) ; 
    end for ; 
  end for ; 
end TbStream_AxiTiming1 ; 
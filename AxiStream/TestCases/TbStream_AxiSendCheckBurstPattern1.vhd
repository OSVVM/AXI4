--
--  File Name:         TbStream_AxiSendCheckBurstPattern1.vhd
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
--      SendBurstVector, GetBurst with 2 parameters
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
architecture AxiSendCheckBurstPattern1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
--    constant FIFO_WIDTH : integer := DATA_WIDTH ; 
  constant FIFO_WIDTH : integer := 8 ; -- BYTE 
  constant DATA_ZERO  : std_logic_vector := (FIFO_WIDTH - 1 downto 0 => '0') ; 
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbStream_AxiSendCheckBurstPattern1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbStream_AxiSendCheckBurstPattern1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms) ;
    AlertIf(now >= 5 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbStream_AxiSendCheckBurstPattern1.txt", "../sim_shared/validated_results/TbStream_AxiSendCheckBurstPattern1.txt", "") ; 
    
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

    log("Transmit 16 bytes.  Incrementing.  Starting with X03") ;
    SendBurstIncrement(StreamTxRec, DATA_ZERO+3, 16, ID & Dest & User & '1') ;

    WaitForClock(StreamTxRec, 4) ; 

    log("Transmit 13 bytes.") ;
    SendBurstVector(StreamTxRec, 
      (X"01",        DATA_ZERO+3,  DATA_ZERO+5,  DATA_ZERO+7,  DATA_ZERO+9,
      DATA_ZERO+11,  DATA_ZERO+13, DATA_ZERO+15, DATA_ZERO+17, DATA_ZERO+19,
      DATA_ZERO+21,  DATA_ZERO+23, DATA_ZERO+25),
      (ID+1) & (Dest+1) & (User+1) & '1') ;

    WaitForClock(StreamTxRec, 4) ; 

    log("Transmit 15 Bytes.  Random.  Starting with X01") ;
    SendBurstRandom(StreamTxRec, DATA_ZERO+1, 15, (ID+2) & (Dest+2) & (User+2) & '1') ;
    
    ID   := to_slv(8, ID_LEN);
    Dest := to_slv(9, DEST_LEN) ; 
    User := to_slv(10, USER_LEN) ; 

    for i in 0 to 6 loop 
      log("Transmit " & to_string(i + 1) & " Bytes. Starting with " & to_string(i*32)) ;
      SendBurstIncrement(StreamTxRec, DATA_ZERO+i*32, 1+i, (ID+i/2) & (Dest+i/2) & (User+i/2) & '1') ;
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
    variable ID   : std_logic_vector(ID_LEN-1 downto 0) ;    -- 8
    variable Dest : std_logic_vector(DEST_LEN-1 downto 0) ;  -- 4
    variable User : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
  begin
    WaitForClock(StreamRxRec, 2) ; 
    SetBurstMode(StreamRxRec, STREAM_BURST_BYTE_MODE) ;
    
    ID   := to_slv(1, ID_LEN);
    Dest := to_slv(2, DEST_LEN) ; 
    User := to_slv(3, USER_LEN) ; 

--    log("Transmit 16 Bytes -- word aligned") ;
    CheckBurstIncrement(StreamRxRec, DATA_ZERO+3, 16, ID & Dest & User & '1') ;

--    log("Transmit 13 Bytes -- unaligned") ;
    CheckBurstVector (StreamRxRec, 
      (X"01",        DATA_ZERO+3,  DATA_ZERO+5,  DATA_ZERO+7,  DATA_ZERO+9,
      DATA_ZERO+11,  DATA_ZERO+13, DATA_ZERO+15, DATA_ZERO+17, DATA_ZERO+19,
      DATA_ZERO+21,  DATA_ZERO+23, DATA_ZERO+25),
      (ID+1) & (Dest+1) & (User+1) & '1') ;

--    log("Transmit 15 Bytes -- unaligned") ;
    CheckBurstRandom(StreamRxRec, DATA_ZERO+1, 15, (ID+2) & (Dest+2) & (User+2) & '1') ;
    
    ID   := to_slv(8, ID_LEN);
    Dest := to_slv(9, DEST_LEN) ; 
    User := to_slv(10, USER_LEN) ; 

    for i in 0 to 6 loop 
--      log("Transmit " & to_string(8+3*i) & " Bytes. Starting with " & to_string(i*32)) ;
      CheckBurstIncrement(StreamRxRec, DATA_ZERO+i*32, 1+i, (ID+i/2) & (Dest+i/2) & (User+i/2) & '1') ;
    end loop ; 
     
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end AxiSendCheckBurstPattern1 ;

Configuration TbStream_AxiSendCheckBurstPattern1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiSendCheckBurstPattern1) ; 
    end for ; 
  end for ; 
end TbStream_AxiSendCheckBurstPattern1 ; 
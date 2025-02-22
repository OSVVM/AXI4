--
--  File Name:         TbStream_SendGetRandom2.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--    Validates AxiStream usage of delay randomization for TReady and TValid
--    Demonstrates how to:
--      1) Activate the VC's internal randomization capability
--      2) Change the randomization values by overwriting the existing ones
--      3) Swap between two different settings quickly
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    04/2023   2023.04    Initial.   Tests delay randomization
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2023 by SynthWorks Design Inc.
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
architecture SendGetRandom2 of TestCtrl is

  constant MIN_PACKET_SIZE : integer := 128 ; 
  constant MAX_PACKET_SIZE : integer := 256 ; 

  signal   SequenceNumber : integer := 0 ; 
  signal   TestDone : integer_barrier := 1 ;
  constant TbID : AlertLogIDType := NewID("Testbench") ;

  use osvvm.ScoreboardPkg_slv.all ; 
  constant SB : ScoreboardIDType := NewID("SB1", TbID) ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbStream_SendGetRandom2") ;
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
    if CHECK_TRANSCRIPT then 
    --   AffirmIfTranscriptsMatch(AXISTREAM_VALIDATED_RESULTS_DIR) ; 
    end if ;   
   


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
		variable PacketRV, DataRV   : RandomPType ;
    variable Data : integer_vector(1 to MAX_PACKET_SIZE) ;
    variable PacketLength : integer ; 
  begin
    PacketRV.InitSeed(PacketRV'instance_name);
    DataRV.InitSeed(DataRV'instance_name);

    wait until nReset = '1' ;
    WaitForClock(StreamTxRec, 2) ;
    SetBurstMode(StreamTxRec, STREAM_BURST_BYTE_MODE) ;  -- Put Burst FIFO in Byte Mode

    --
    -- Part 1: Randomize using existing VC delay coverage
    --
    -- Turn on Delay Coverage randomization by calling SetUseRandomDelays.  
    -- Note that whether randomization is on initially or not 
    -- is up to a particular VC.   AxiStreamTransmitter currently 
    -- has it off to support historical modes of operation.   
    SetUseRandomDelays(StreamTxRec) ;

    -- Using the Delay Coverage settings from the VC, 
    -- transfer 32 packets of data 
    
    for I in 1 to 32 loop 
      PacketLength := PacketRV.RandInt(MIN_PACKET_SIZE, MAX_PACKET_SIZE);
      Data(1 to PacketLength) := DataRV.RandIntV(0, 255, PacketLength) ;  -- Generate a packet
      Log("Sending Packet " & to_string(i) & " of length " & to_string(PacketLength)) ; 
      PushBurstVector(SB, Data(1 to PacketLength), 8) ;
			SendBurstVector(StreamTxRec, Data(1 to PacketLength), 8) ;
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
    variable Data : integer_vector(1 to MAX_PACKET_SIZE) ;
    variable PacketLength : integer ; 
  begin
    WaitForClock(StreamRxRec, 1) ;
    SetUseRandomDelays(StreamRxRec) ;
    SetBurstMode(StreamRxRec, STREAM_BURST_BYTE_MODE) ;  -- Put Burst FIFO in Byte Mode
    
    -- Check
    for I in 1 to 32 loop
      GetBurst(StreamRxRec, PacketLength) ;
      if I mod 2 = 1 then 
        Log("Received Packet A" & to_string(i) & " of length " & to_string(PacketLength)) ; 
        CheckBurstFifo(SB, StreamRxRec.BurstFifo, PacketLength) ; 
      else
        Log("Received Packet B" & to_string(i) & " of length " & to_string(PacketLength)) ; 
        PopBurstVector(StreamRxRec.BurstFifo, Data(1 to PacketLength)) ; 
        CheckBurstVector(SB, Data(1 to PacketLength), 8) ; 
      end if ;
    end loop ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ReceiverProc ;

end SendGetRandom2 ;

Configuration TbStream_SendGetRandom2 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SendGetRandom2) ;
    end for ;
  end for ;
end TbStream_SendGetRandom2 ;
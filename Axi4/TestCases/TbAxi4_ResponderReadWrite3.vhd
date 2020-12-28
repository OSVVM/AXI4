--
--  File Name:         TbAxi4_ResponderReadWrite3.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Test transaction source
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    12/2020   2020.12    Initial
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

architecture ResponderReadWrite3 of TestCtrl is

  signal TestDone, Sync : integer_barrier := 1 ;
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_ResponderReadWrite3") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_ResponderReadWrite3.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4_ResponderReadWrite3.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_ResponderReadWrite3.txt", "") ; 
    
    print("") ;
    ReportAlerts ; 
    print("") ;
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- MasterProc
  --   Generate transactions for AxiMaster
  ------------------------------------------------------------
  MasterProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
  begin
    wait until nReset = '1' ;  
    WaitForClock(MasterRec, 2) ; 
    log("Write and Read with ByteAddr = 0, 4 Bytes") ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, X"AAAA_AAA0", X"5555_5555" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Read(MasterRec,  X"1111_1110", Data) ;
    AffirmIfEqual(Data, X"2222_2222", "Master Read Data: ") ;
    
    log("Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, X"AAAA_AAA0", X"11" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, X"AAAA_AAA1", X"22" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, X"AAAA_AAA2", X"33" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, X"AAAA_AAA3", X"44" ) ;
    
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Read(MasterRec,  X"1111_1110", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"AA", "Master Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Read(MasterRec,  X"1111_1111", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"BB", "Master Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Read(MasterRec,  X"1111_1112", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"CC", "Master Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Read(MasterRec,  X"1111_1113", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"DD", "Master Read Data: ") ;

    log("Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, X"BBBB_BBB0", X"2211" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, X"BBBB_BBB1", X"33_22" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, X"BBBB_BBB2", X"4433" ) ;

    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Read(MasterRec,  X"1111_1110", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"BBAA", "Master Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Read(MasterRec,  X"1111_1111", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"CCBB", "Master Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Read(MasterRec,  X"1111_1112", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"DDCC", "Master Read Data: ") ;

    log("Write and Read with 3 Bytes and ByteAddr = 0. 1") ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, X"CCCC_CCC0", X"33_2211" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Write(MasterRec, X"CCCC_CCC1", X"4433_22" ) ;

    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Read(MasterRec,  X"1111_1110", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"CC_BBAA", "Master Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(MasterRec, 4) ; 
    Read(MasterRec,  X"1111_1111", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"DDCC_BB", "Master Read Data: ") ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(MasterRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MasterProc ;


  ------------------------------------------------------------
  -- ResponderProc
  --   Generate transactions for AxiResponder
  ------------------------------------------------------------
  ResponderProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    WaitForClock(ResponderRec, 2) ; 
    -- Write and Read with ByteAddr = 0, 4 Bytes
    WaitForBarrier(Sync) ;
    GetWriteAddress(ResponderRec, Addr) ;
    GetWriteData(ResponderRec, Data) ;
    AffirmIfEqual(Addr, X"AAAA_AAA0", "Responder Write Addr: ") ;
    AffirmIfEqual(Data, X"5555_5555", "Responder Write Data: ") ;
    
    WaitForBarrier(Sync) ;
    GetReadAddress(ResponderRec, Addr) ; 
    SendReadData(ResponderRec, X"2222_2222") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Responder Read Addr: ") ;

    -- Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3
    -- Write(MasterRec, X"AAAA_AAA0", X"11" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(ResponderRec, Addr) ;
    GetWriteData(ResponderRec, Addr, Data(7 downto 0)) ;
    AffirmIfEqual(Addr, X"AAAA_AAA0", "Responder Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"11", "Responder Write Data: ") ;
    -- Write(MasterRec, X"AAAA_AAA1", X"22" ) ;
    WaitForBarrier(Sync) ;
    GetWriteData(ResponderRec, X"AAAA_AAA1", Data(7 downto 0)) ;
    GetWriteAddress(ResponderRec, Addr) ;
    AffirmIfEqual(Addr, X"AAAA_AAA1", "Responder Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"22", "Responder Write Data: ") ;
    -- Write(MasterRec, X"AAAA_AAA2", X"33" ) ;
    WaitForBarrier(Sync) ;
    GetWriteData(ResponderRec, X"AAAA_AAA2", Data(7 downto 0)) ;
    GetWriteAddress(ResponderRec, Addr) ;
    AffirmIfEqual(Addr, X"AAAA_AAA2", "Responder Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"33", "Responder Write Data: ") ;  --
    -- Write(MasterRec, X"AAAA_AAA3", X"44" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(ResponderRec, Addr) ;
    GetWriteData(ResponderRec, Addr, Data(7 downto 0)) ;
    AffirmIfEqual(Addr, X"AAAA_AAA3", "Responder Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"44", "Responder Write Data: ") ;  --

    WaitForBarrier(Sync) ;
    GetReadAddress(ResponderRec, Addr) ; 
    SendReadData(ResponderRec, X"AA") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Responder Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(ResponderRec, Addr) ; 
    SendReadData(ResponderRec, X"BB") ; 
    AffirmIfEqual(Addr, X"1111_1111", "Responder Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(ResponderRec, Addr) ; 
    SendReadData(ResponderRec, X"CC") ; 
    AffirmIfEqual(Addr, X"1111_1112", "Responder Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(ResponderRec, Addr) ; 
    SendReadData(ResponderRec, X"DD") ; 
    AffirmIfEqual(Addr, X"1111_1113", "Responder Read Addr: ") ;


    -- Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2
    -- Write(MasterRec, X"BBBB_BBB0", X"2211" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(ResponderRec, Addr) ;
    GetWriteData(ResponderRec, Addr, Data(15 downto 0)) ;
    AffirmIfEqual(Addr, X"BBBB_BBB0", "Responder Write Addr: ") ;
    AffirmIfEqual(Data(15 downto 0), X"2211", "Responder Write Data: ") ;
    -- Write(MasterRec, X"BBBB_BBB1", X"3322" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(ResponderRec, Addr) ;
    GetWriteData(ResponderRec, Addr, Data(15 downto 0)) ;
    AffirmIfEqual(Addr, X"BBBB_BBB1", "Responder Write Addr: ") ;
    AffirmIfEqual(Data(15 downto 0), X"3322", "Responder Write Data: ") ;
    -- Write(MasterRec, X"BBBB_BBB2", X"4433" ) ;  --
    WaitForBarrier(Sync) ;
    GetWriteAddress(ResponderRec, Addr) ;
    GetWriteData(ResponderRec, Addr, Data(15 downto 0)) ;
    AffirmIfEqual(Addr, X"BBBB_BBB2", "Responder Write Addr: ") ;
    AffirmIfEqual(Data(15 downto 0), X"4433", "Responder Write Data: ") ;

    WaitForBarrier(Sync) ;
    GetReadAddress(ResponderRec, Addr) ; 
    SendReadData(ResponderRec, X"BBAA") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Responder Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(ResponderRec, Addr) ; 
    SendReadData(ResponderRec, X"CC_BB") ; 
    AffirmIfEqual(Addr, X"1111_1111", "Responder Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(ResponderRec, Addr) ; 
    SendReadData(ResponderRec, X"DDCC") ; 
    AffirmIfEqual(Addr, X"1111_1112", "Responder Read Addr: ") ;

    -- Write and Read with 3 Bytes and ByteAddr = 0. 1
    -- Write(MasterRec, X"CCCC_CCC0", X"332211" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(ResponderRec, Addr) ;
    GetWriteData(ResponderRec, Addr, Data(23 downto 0)) ;
    AffirmIfEqual(Addr, X"CCCC_CCC0", "Responder Write Addr: ") ;
    AffirmIfEqual(Data(23 downto 0), X"33_2211", "Responder Write Data: ") ;
    -- Write(MasterRec, X"CCCC_CCC1", X"443322" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(ResponderRec, Addr) ;
    GetWriteData(ResponderRec, Addr, Data(23 downto 0)) ;
    AffirmIfEqual(Addr, X"CCCC_CCC1", "Responder Write Addr: ") ;
    AffirmIfEqual(Data(23 downto 0), X"4433_22", "Responder Write Data: ") ;

    WaitForBarrier(Sync) ;
    GetReadAddress(ResponderRec, Addr) ; 
    SendReadData(ResponderRec, X"CC_BBAA") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Responder Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(ResponderRec, Addr) ; 
    SendReadData(ResponderRec, X"DDCC_BB") ; 
    AffirmIfEqual(Addr, X"1111_1111", "Responder Read Addr: ") ;


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ResponderRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ResponderProc ;


end ResponderReadWrite3 ;

Configuration TbAxi4_ResponderReadWrite3 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ResponderReadWrite3) ; 
    end for ; 
  end for ; 
end TbAxi4_ResponderReadWrite3 ; 
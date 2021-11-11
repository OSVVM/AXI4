--
--  File Name:         TbAxi4_SubordinateReadWrite3.vhd
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

architecture SubordinateReadWrite3 of TestCtrl is

  signal TestDone, Sync : integer_barrier := 1 ;
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_SubordinateReadWrite3") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_SubordinateReadWrite3.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_SubordinateReadWrite3.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_SubordinateReadWrite3.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- ManagerProc
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
  begin
    wait until nReset = '1' ;  
    WaitForClock(ManagerRec, 2) ; 
    log("Write and Read with ByteAddr = 0, 4 Bytes") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Write(ManagerRec, X"AAAA_AAA0", X"5555_5555" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Read(ManagerRec,  X"1111_1110", Data) ;
    AffirmIfEqual(Data, X"2222_2222", "Manager Read Data: ") ;
    
    log("Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Write(ManagerRec, X"AAAA_AAA0", X"11" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Write(ManagerRec, X"AAAA_AAA1", X"22" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Write(ManagerRec, X"AAAA_AAA2", X"33" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Write(ManagerRec, X"AAAA_AAA3", X"44" ) ;
    
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Read(ManagerRec,  X"1111_1110", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"AA", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Read(ManagerRec,  X"1111_1111", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"BB", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Read(ManagerRec,  X"1111_1112", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"CC", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Read(ManagerRec,  X"1111_1113", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"DD", "Manager Read Data: ") ;

    log("Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Write(ManagerRec, X"BBBB_BBB0", X"2211" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Write(ManagerRec, X"BBBB_BBB1", X"33_22" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Write(ManagerRec, X"BBBB_BBB2", X"4433" ) ;

    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Read(ManagerRec,  X"1111_1110", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"BBAA", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Read(ManagerRec,  X"1111_1111", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"CCBB", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Read(ManagerRec,  X"1111_1112", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"DDCC", "Manager Read Data: ") ;

    log("Write and Read with 3 Bytes and ByteAddr = 0. 1") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Write(ManagerRec, X"CCCC_CCC0", X"33_2211" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Write(ManagerRec, X"CCCC_CCC1", X"4433_22" ) ;

    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Read(ManagerRec,  X"1111_1110", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"CC_BBAA", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 4) ; 
    Read(ManagerRec,  X"1111_1111", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"DDCC_BB", "Manager Read Data: ") ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc ;


  ------------------------------------------------------------
  -- SubordinateProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  SubordinateProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    WaitForClock(SubordinateRec, 2) ; 
    -- Write and Read with ByteAddr = 0, 4 Bytes
    WaitForBarrier(Sync) ;
    GetWriteAddress(SubordinateRec, Addr) ;
    GetWriteData(SubordinateRec, Data) ;
    AffirmIfEqual(Addr, X"AAAA_AAA0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"5555_5555", "Subordinate Write Data: ") ;
    
    WaitForBarrier(Sync) ;
    GetReadAddress(SubordinateRec, Addr) ; 
    SendReadData(SubordinateRec, X"2222_2222") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Subordinate Read Addr: ") ;

    -- Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3
    -- Write(ManagerRec, X"AAAA_AAA0", X"11" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(SubordinateRec, Addr) ;
    GetWriteData(SubordinateRec, Addr, Data(7 downto 0)) ;
    AffirmIfEqual(Addr, X"AAAA_AAA0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"11", "Subordinate Write Data: ") ;
    -- Write(ManagerRec, X"AAAA_AAA1", X"22" ) ;
    WaitForBarrier(Sync) ;
    GetWriteData(SubordinateRec, X"AAAA_AAA1", Data(7 downto 0)) ;
    GetWriteAddress(SubordinateRec, Addr) ;
    AffirmIfEqual(Addr, X"AAAA_AAA1", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"22", "Subordinate Write Data: ") ;
    -- Write(ManagerRec, X"AAAA_AAA2", X"33" ) ;
    WaitForBarrier(Sync) ;
    GetWriteData(SubordinateRec, X"AAAA_AAA2", Data(7 downto 0)) ;
    GetWriteAddress(SubordinateRec, Addr) ;
    AffirmIfEqual(Addr, X"AAAA_AAA2", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"33", "Subordinate Write Data: ") ;  --
    -- Write(ManagerRec, X"AAAA_AAA3", X"44" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(SubordinateRec, Addr) ;
    GetWriteData(SubordinateRec, Addr, Data(7 downto 0)) ;
    AffirmIfEqual(Addr, X"AAAA_AAA3", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"44", "Subordinate Write Data: ") ;  --

    WaitForBarrier(Sync) ;
    GetReadAddress(SubordinateRec, Addr) ; 
    SendReadData(SubordinateRec, X"AA") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Subordinate Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(SubordinateRec, Addr) ; 
    SendReadData(SubordinateRec, X"BB") ; 
    AffirmIfEqual(Addr, X"1111_1111", "Subordinate Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(SubordinateRec, Addr) ; 
    SendReadData(SubordinateRec, X"CC") ; 
    AffirmIfEqual(Addr, X"1111_1112", "Subordinate Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(SubordinateRec, Addr) ; 
    SendReadData(SubordinateRec, X"DD") ; 
    AffirmIfEqual(Addr, X"1111_1113", "Subordinate Read Addr: ") ;


    -- Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2
    -- Write(ManagerRec, X"BBBB_BBB0", X"2211" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(SubordinateRec, Addr) ;
    GetWriteData(SubordinateRec, Addr, Data(15 downto 0)) ;
    AffirmIfEqual(Addr, X"BBBB_BBB0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(15 downto 0), X"2211", "Subordinate Write Data: ") ;
    -- Write(ManagerRec, X"BBBB_BBB1", X"3322" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(SubordinateRec, Addr) ;
    GetWriteData(SubordinateRec, Addr, Data(15 downto 0)) ;
    AffirmIfEqual(Addr, X"BBBB_BBB1", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(15 downto 0), X"3322", "Subordinate Write Data: ") ;
    -- Write(ManagerRec, X"BBBB_BBB2", X"4433" ) ;  --
    WaitForBarrier(Sync) ;
    GetWriteAddress(SubordinateRec, Addr) ;
    GetWriteData(SubordinateRec, Addr, Data(15 downto 0)) ;
    AffirmIfEqual(Addr, X"BBBB_BBB2", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(15 downto 0), X"4433", "Subordinate Write Data: ") ;

    WaitForBarrier(Sync) ;
    GetReadAddress(SubordinateRec, Addr) ; 
    SendReadData(SubordinateRec, X"BBAA") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Subordinate Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(SubordinateRec, Addr) ; 
    SendReadData(SubordinateRec, X"CC_BB") ; 
    AffirmIfEqual(Addr, X"1111_1111", "Subordinate Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(SubordinateRec, Addr) ; 
    SendReadData(SubordinateRec, X"DDCC") ; 
    AffirmIfEqual(Addr, X"1111_1112", "Subordinate Read Addr: ") ;

    -- Write and Read with 3 Bytes and ByteAddr = 0. 1
    -- Write(ManagerRec, X"CCCC_CCC0", X"332211" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(SubordinateRec, Addr) ;
    GetWriteData(SubordinateRec, Addr, Data(23 downto 0)) ;
    AffirmIfEqual(Addr, X"CCCC_CCC0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(23 downto 0), X"33_2211", "Subordinate Write Data: ") ;
    -- Write(ManagerRec, X"CCCC_CCC1", X"443322" ) ;
    WaitForBarrier(Sync) ;
    GetWriteAddress(SubordinateRec, Addr) ;
    GetWriteData(SubordinateRec, Addr, Data(23 downto 0)) ;
    AffirmIfEqual(Addr, X"CCCC_CCC1", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(23 downto 0), X"4433_22", "Subordinate Write Data: ") ;

    WaitForBarrier(Sync) ;
    GetReadAddress(SubordinateRec, Addr) ; 
    SendReadData(SubordinateRec, X"CC_BBAA") ; 
    AffirmIfEqual(Addr, X"1111_1110", "Subordinate Read Addr: ") ;
    WaitForBarrier(Sync) ;
    GetReadAddress(SubordinateRec, Addr) ; 
    SendReadData(SubordinateRec, X"DDCC_BB") ; 
    AffirmIfEqual(Addr, X"1111_1111", "Subordinate Read Addr: ") ;


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;


end SubordinateReadWrite3 ;

Configuration TbAxi4_SubordinateReadWrite3 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SubordinateReadWrite3) ; 
    end for ; 
  end for ; 
end TbAxi4_SubordinateReadWrite3 ; 
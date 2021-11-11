--
--  File Name:         TbAxi4_MemoryReadWrite2.vhd
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
--    09/2017   2017       Initial revision
--    01/2020   2020.01    Updated license notice
--    12/2020   2020.12    Updated signal and port names
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2017 - 2021 by SynthWorks Design Inc.  
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

architecture MemoryReadWrite2 of TestCtrl is

  signal ManagerSync1, MemorySync1, TestDone : integer_barrier := 1 ;
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_MemoryReadWrite2") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_MemoryReadWrite2.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_MemoryReadWrite2.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_MemoryReadWrite2.txt", "") ; 

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
    log("In Manager, Write to Memory") ;
    log("Write with ByteAddr = 0, 4 Bytes") ;
    Write(ManagerRec, X"1000_1000", X"5555_5555" ) ;
    Write(ManagerRec, X"1000_1100", X"AAAA_AAAA" ) ;
    
    log("Write with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    Write(ManagerRec, X"1000_2000", X"11" ) ;
    Write(ManagerRec, X"1000_2001", X"22" ) ;
    Write(ManagerRec, X"1000_2002", X"33" ) ;
    Write(ManagerRec, X"1000_2003", X"44" ) ;
    Write(ManagerRec, X"1000_2004", X"55" ) ;
    Write(ManagerRec, X"1000_2005", X"66" ) ;
    Write(ManagerRec, X"1000_2006", X"77" ) ;
    Write(ManagerRec, X"1000_2007", X"88" ) ;
    
    log("Write with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    Write(ManagerRec, X"1000_3000", X"2211" ) ;
    Write(ManagerRec, X"1000_3011", X"33_22" ) ;
    Write(ManagerRec, X"1000_3022", X"4433" ) ;
    Write(ManagerRec, X"1000_3100", X"6655" ) ;
    Write(ManagerRec, X"1000_3111", X"88_77" ) ;
    Write(ManagerRec, X"1000_3122", X"AA99" ) ;
    
    log("Write with 3 Bytes and ByteAddr = 0, 1") ;
    Write(ManagerRec, X"1000_4000", X"33_2211" ) ;
    Write(ManagerRec, X"1000_4011", X"4433_22" ) ;
    Write(ManagerRec, X"1000_4100", X"77_6655" ) ;
    Write(ManagerRec, X"1000_4111", X"AA99_88" ) ;

    WaitForBarrier(ManagerSync1) ;
    WaitForBarrier(MemorySync1) ;

    log("In Manager, Check What Memory Wrote") ;
    log("Read with ByteAddr = 0, 4 Bytes") ;
    ReadCheck(ManagerRec,  X"A000_1000", X"2222_2222") ;

    log("Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    ReadCheck(ManagerRec, X"A000_2000", X"AA") ; 
    ReadCheck(ManagerRec, X"A000_2001", X"BB") ; 
    ReadCheck(ManagerRec, X"A000_2002", X"CC") ; 
    ReadCheck(ManagerRec, X"A000_2003", X"DD") ; 

    log("Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    ReadCheck(ManagerRec, X"A000_3000", X"BBAA") ; 
    ReadCheck(ManagerRec, X"A000_3011", X"CC_BB") ; 
    ReadCheck(ManagerRec, X"A000_3022", X"DDCC") ; 

    -- Write with 3 Bytes and ByteAddr = 0. 1
    ReadCheck(ManagerRec, X"A000_4000", X"CC_BBAA") ; 
    ReadCheck(ManagerRec, X"A000_4011", X"DDCC_BB") ; 
    
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
    
    WaitForBarrier(ManagerSync1) ;
    log("In MemorySubordinate, Check What Manager Wrote") ;
    -- Write and Read with ByteAddr = 0, 4 Bytes
    Read(SubordinateRec, X"1000_1000", Data) ;
    AffirmIfEqual(Data, X"5555_5555", "Memory Verify Write") ;
    ReadCheck(SubordinateRec, X"1000_1100", X"AAAA_AAAA" ) ;

    -- Read with 1 Byte, and ByteAddr = 0, 1, 2, 3
    Read(SubordinateRec, X"1000_2000", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"11", "Memory Verify Write") ;
    Read(SubordinateRec, X"1000_2001", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"22", "Memory Verify Write") ;
    Read(SubordinateRec, X"1000_2002", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"33", "Memory Verify Write") ;
    Read(SubordinateRec, X"1000_2003", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"44", "Memory Verify Write") ;
    ReadCheck(SubordinateRec, X"1000_2004", X"55" ) ;
    ReadCheck(SubordinateRec, X"1000_2005", X"66" ) ;
    ReadCheck(SubordinateRec, X"1000_2006", X"77" ) ;
    ReadCheck(SubordinateRec, X"1000_2007", X"88" ) ;

    -- Read with 2 Bytes, and ByteAddr = 0, 1, 2
    Read(SubordinateRec, X"1000_3000", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"2211", "Subordinate Write Data: ") ;
    Read(SubordinateRec, X"1000_3011", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"33_22", "Subordinate Write Data: ") ;
    Read(SubordinateRec, X"1000_3022", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"4433", "Subordinate Write Data: ") ;
    ReadCheck(SubordinateRec, X"1000_3100", X"6655" ) ;
    ReadCheck(SubordinateRec, X"1000_3111", X"88_77" ) ;
    ReadCheck(SubordinateRec, X"1000_3122", X"AA99" ) ;

    -- Read with 3 Bytes and ByteAddr = 0. 1
    Read(SubordinateRec, X"1000_4000", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"332211", "Subordinate Write Data: ") ;
    Read(SubordinateRec, X"1000_4011", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"443322", "Subordinate Write Data: ") ;
    ReadCheck(SubordinateRec, X"1000_4100", X"77_6655" ) ;
    ReadCheck(SubordinateRec, X"1000_4111", X"AA99_88" ) ;

    
    log("In MemorySubordinate, Write to Memory") ;
    -- Write with ByteAddr = 0, 4 Bytes
    Write(SubordinateRec, X"A000_1000", X"2222_2222") ; 

    -- Write with 1 Byte, and ByteAddr = 0, 1, 2, 3
    Write(SubordinateRec, X"A000_2000", X"AA") ; 
    Write(SubordinateRec, X"A000_2001", X"BB") ; 
    Write(SubordinateRec, X"A000_2002", X"CC") ; 
    Write(SubordinateRec, X"A000_2003", X"DD") ; 

    -- Write with 2 Bytes, and ByteAddr = 0, 1, 2
    Write(SubordinateRec, X"A000_3000", X"BBAA") ; 
    Write(SubordinateRec, X"A000_3011", X"CC_BB") ; 
    Write(SubordinateRec, X"A000_3022", X"DDCC") ; 

    -- Write with 3 Bytes and ByteAddr = 0. 1
    Write(SubordinateRec, X"A000_4000", X"CC_BBAA") ; 
    Write(SubordinateRec, X"A000_4011", X"DDCC_BB") ; 

    WaitForBarrier(MemorySync1) ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;


end MemoryReadWrite2 ;

Configuration TbAxi4_MemoryReadWrite2 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MemoryReadWrite2) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_MemoryReadWrite2 ; 
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
--  Copyright (c) 2017 - 2020 by SynthWorks Design Inc.  
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

  signal MasterSync1, MemorySync1, TestDone : integer_barrier := 1 ;
 
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
    log("In Master, Write to Memory") ;
    log("Write with ByteAddr = 0, 4 Bytes") ;
    Write(MasterRec, X"1000_1000", X"5555_5555" ) ;
    Write(MasterRec, X"1000_1100", X"AAAA_AAAA" ) ;
    
    log("Write with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    Write(MasterRec, X"1000_2000", X"11" ) ;
    Write(MasterRec, X"1000_2001", X"22" ) ;
    Write(MasterRec, X"1000_2002", X"33" ) ;
    Write(MasterRec, X"1000_2003", X"44" ) ;
    Write(MasterRec, X"1000_2004", X"55" ) ;
    Write(MasterRec, X"1000_2005", X"66" ) ;
    Write(MasterRec, X"1000_2006", X"77" ) ;
    Write(MasterRec, X"1000_2007", X"88" ) ;
    
    log("Write with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    Write(MasterRec, X"1000_3000", X"2211" ) ;
    Write(MasterRec, X"1000_3011", X"33_22" ) ;
    Write(MasterRec, X"1000_3022", X"4433" ) ;
    Write(MasterRec, X"1000_3100", X"6655" ) ;
    Write(MasterRec, X"1000_3111", X"88_77" ) ;
    Write(MasterRec, X"1000_3122", X"AA99" ) ;
    
    log("Write with 3 Bytes and ByteAddr = 0, 1") ;
    Write(MasterRec, X"1000_4000", X"33_2211" ) ;
    Write(MasterRec, X"1000_4011", X"4433_22" ) ;
    Write(MasterRec, X"1000_4100", X"77_6655" ) ;
    Write(MasterRec, X"1000_4111", X"AA99_88" ) ;

    WaitForBarrier(MasterSync1) ;
    WaitForBarrier(MemorySync1) ;

    log("In Master, Check What Memory Wrote") ;
    log("Read with ByteAddr = 0, 4 Bytes") ;
    ReadCheck(MasterRec,  X"A000_1000", X"2222_2222") ;

    log("Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    ReadCheck(MasterRec, X"A000_2000", X"AA") ; 
    ReadCheck(MasterRec, X"A000_2001", X"BB") ; 
    ReadCheck(MasterRec, X"A000_2002", X"CC") ; 
    ReadCheck(MasterRec, X"A000_2003", X"DD") ; 

    log("Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    ReadCheck(MasterRec, X"A000_3000", X"BBAA") ; 
    ReadCheck(MasterRec, X"A000_3011", X"CC_BB") ; 
    ReadCheck(MasterRec, X"A000_3022", X"DDCC") ; 

    -- Write with 3 Bytes and ByteAddr = 0. 1
    ReadCheck(MasterRec, X"A000_4000", X"CC_BBAA") ; 
    ReadCheck(MasterRec, X"A000_4011", X"DDCC_BB") ; 
    
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
    
    WaitForBarrier(MasterSync1) ;
    log("In MemoryResponder, Check What Master Wrote") ;
    -- Write and Read with ByteAddr = 0, 4 Bytes
    Read(ResponderRec, X"1000_1000", Data) ;
    AffirmIfEqual(Data, X"5555_5555", "Memory Verify Write") ;
    ReadCheck(ResponderRec, X"1000_1100", X"AAAA_AAAA" ) ;

    -- Read with 1 Byte, and ByteAddr = 0, 1, 2, 3
    Read(ResponderRec, X"1000_2000", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"11", "Memory Verify Write") ;
    Read(ResponderRec, X"1000_2001", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"22", "Memory Verify Write") ;
    Read(ResponderRec, X"1000_2002", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"33", "Memory Verify Write") ;
    Read(ResponderRec, X"1000_2003", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"44", "Memory Verify Write") ;
    ReadCheck(ResponderRec, X"1000_2004", X"55" ) ;
    ReadCheck(ResponderRec, X"1000_2005", X"66" ) ;
    ReadCheck(ResponderRec, X"1000_2006", X"77" ) ;
    ReadCheck(ResponderRec, X"1000_2007", X"88" ) ;

    -- Read with 2 Bytes, and ByteAddr = 0, 1, 2
    Read(ResponderRec, X"1000_3000", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"2211", "Responder Write Data: ") ;
    Read(ResponderRec, X"1000_3011", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"33_22", "Responder Write Data: ") ;
    Read(ResponderRec, X"1000_3022", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"4433", "Responder Write Data: ") ;
    ReadCheck(ResponderRec, X"1000_3100", X"6655" ) ;
    ReadCheck(ResponderRec, X"1000_3111", X"88_77" ) ;
    ReadCheck(ResponderRec, X"1000_3122", X"AA99" ) ;

    -- Read with 3 Bytes and ByteAddr = 0. 1
    Read(ResponderRec, X"1000_4000", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"332211", "Responder Write Data: ") ;
    Read(ResponderRec, X"1000_4011", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"443322", "Responder Write Data: ") ;
    ReadCheck(ResponderRec, X"1000_4100", X"77_6655" ) ;
    ReadCheck(ResponderRec, X"1000_4111", X"AA99_88" ) ;

    
    log("In MemoryResponder, Write to Memory") ;
    -- Write with ByteAddr = 0, 4 Bytes
    Write(ResponderRec, X"A000_1000", X"2222_2222") ; 

    -- Write with 1 Byte, and ByteAddr = 0, 1, 2, 3
    Write(ResponderRec, X"A000_2000", X"AA") ; 
    Write(ResponderRec, X"A000_2001", X"BB") ; 
    Write(ResponderRec, X"A000_2002", X"CC") ; 
    Write(ResponderRec, X"A000_2003", X"DD") ; 

    -- Write with 2 Bytes, and ByteAddr = 0, 1, 2
    Write(ResponderRec, X"A000_3000", X"BBAA") ; 
    Write(ResponderRec, X"A000_3011", X"CC_BB") ; 
    Write(ResponderRec, X"A000_3022", X"DDCC") ; 

    -- Write with 3 Bytes and ByteAddr = 0. 1
    Write(ResponderRec, X"A000_4000", X"CC_BBAA") ; 
    Write(ResponderRec, X"A000_4011", X"DDCC_BB") ; 

    WaitForBarrier(MemorySync1) ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ResponderRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ResponderProc ;


end MemoryReadWrite2 ;

Configuration TbAxi4_MemoryReadWrite2 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MemoryReadWrite2) ; 
    end for ; 
--!!    for Responder_1 : Axi4Responder 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_MemoryReadWrite2 ; 
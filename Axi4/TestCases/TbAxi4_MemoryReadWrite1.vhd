--
--  File Name:         TbAxi4_MemoryReadWrite1.vhd
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

architecture MemoryReadWrite1 of TestCtrl is

  signal TestDone, ManagerDone : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_MemoryReadWrite1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_MemoryReadWrite1.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_MemoryReadWrite1.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_MemoryReadWrite1.txt", "") ; 

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
    Write(ManagerRec, X"0000_0000", X"5555_5555" ) ;
    Read(ManagerRec,  X"0000_0000", Data) ;
    AffirmIfEqual(Data, X"5555_5555", "Manager Read Data: ") ;
    
    log("Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    Write(ManagerRec, X"0000_0010", X"11" ) ;
    Write(ManagerRec, X"0000_0011", X"22" ) ;
    Write(ManagerRec, X"0000_0012", X"33" ) ;
    Write(ManagerRec, X"0000_0013", X"44" ) ;
    
    ReadCheck(ManagerRec, X"0000_0010", X"11" ) ;
    ReadCheck(ManagerRec, X"0000_0011", X"22" ) ;
    ReadCheck(ManagerRec, X"0000_0012", X"33" ) ;
    ReadCheck(ManagerRec, X"0000_0013", X"44" ) ;
    

    log("Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    Write(ManagerRec, X"0000_0020", X"2211"  ) ;
    Write(ManagerRec, X"0000_0031", X"44_33" ) ;
    Write(ManagerRec, X"0000_0042", X"6655"  ) ;
    
    ReadCheck(ManagerRec, X"0000_0020", X"2211"  ) ;
    ReadCheck(ManagerRec, X"0000_0031", X"44_33" ) ;
    ReadCheck(ManagerRec, X"0000_0042", X"6655"  ) ;

    log("Write and Read with 3 Bytes and ByteAddr = 0. 1") ;
    Write(ManagerRec, X"0000_0050", X"33_2211" ) ;
    Write(ManagerRec, X"0000_0061", X"6655_44" ) ;

    ReadCheck(ManagerRec, X"0000_0050", X"33_2211" ) ;
    ReadCheck(ManagerRec, X"0000_0061", X"6655_44" ) ;
    
    WaitForBarrier(ManagerDone) ;
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc ;


  ------------------------------------------------------------
  -- MemoryProc
  --   Generate transactions for AxiMemory
  ------------------------------------------------------------
  MemoryProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;   
  begin
    WaitForClock(SubordinateRec, 2) ;
    
    -- ReadBack after Manager finishes
    WaitForBarrier(ManagerDone) ;
    ReadCheck(SubordinateRec, X"0000_0000", X"5555_5555" ) ;
    
    ReadCheck(SubordinateRec, X"0000_0010", X"11" ) ;
    ReadCheck(SubordinateRec, X"0000_0011", X"22" ) ;
    ReadCheck(SubordinateRec, X"0000_0012", X"33" ) ;
    ReadCheck(SubordinateRec, X"0000_0013", X"44" ) ;
    
    ReadCheck(SubordinateRec, X"0000_0020", X"2211"  ) ;
    ReadCheck(SubordinateRec, X"0000_0031", X"44_33" ) ;
    ReadCheck(SubordinateRec, X"0000_0042", X"6655"  ) ;

    ReadCheck(SubordinateRec, X"0000_0050", X"33_2211" ) ;
    ReadCheck(SubordinateRec, X"0000_0061", X"6655_44" ) ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MemoryProc ;


end MemoryReadWrite1 ;

library OSVVM_AXI4 ;

Configuration TbAxi4_MemoryReadWrite1 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MemoryReadWrite1) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_MemoryReadWrite1 ; 
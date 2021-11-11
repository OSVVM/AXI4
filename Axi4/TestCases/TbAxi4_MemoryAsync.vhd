--
--  File Name:         TbAxi4_MemoryAsync.vhd
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

architecture MemoryAsync of TestCtrl is

  signal TestDone, InitiatorDone : integer_barrier := 1 ;
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_MemoryAsync") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_MemoryAsync.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_MemoryAsync.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_MemoryAsync.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- InitiatorProc
  --   Generate Address Bus Initiator transactions
  ------------------------------------------------------------
  InitiatorProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
--    alias AddrRec : ManagerRec'subtype is ManagerRec ;
  begin
    wait until nReset = '1' ;  
    WaitForClock(ManagerRec, 2) ; 
    log("Write Address and Data sent at same time") ;
    log("Queue 3 Write Transactions for A1/D1, A2/D2, A3/D3") ;
    WriteAsync       (ManagerRec, X"0000_0A10", X"030201D1");  -- Async = Queue
    WriteAsync       (ManagerRec, X"0000_0A20", X"030201D2");
    WriteAsync       (ManagerRec, X"0000_0A30", X"030201D3");

    log("Wait Cne Cycle") ;
    WaitForClock     (ManagerRec, 1) ;      -- Stop for 1 Clock

    log("Queue 3 Read Address Cycles for A1, A2, A3") ;
    ReadAddressAsync (ManagerRec, X"0000_0A10");      -- Queue Reads
    ReadAddressAsync (ManagerRec, X"0000_0A20");
    ReadAddressAsync (ManagerRec, X"0000_0A30");

    log("Block and Check D1, D2, D3") ;
    ReadCheckData    (ManagerRec, X"030201D1"); -- Blocking, checks D1
    ReadCheckData    (ManagerRec, X"030201D2"); -- Blocking, checks D2
    ReadCheckData    (ManagerRec, X"030201D3");  -- Blocking, checks D3
    
    log("Write Address sent 1 cycle before Write Data") ;
    log("Queue 3 Write Address Cycles for A5, A6, and A7") ;
    WriteAddressAsync(ManagerRec, X"0000_0A50");  -- Queue Write Address
    WriteAddressAsync(ManagerRec, X"0000_0A60");  -- Queue Write Address
    WriteAddressAsync(ManagerRec, X"0000_0A70");  -- Queue Write Address

    log("Wait Cne Cycle") ;
    WaitForClock     (ManagerRec, 1);

    log("Queue 3 Write Data Cycles for D5, D6, and D7") ;
    WriteDataAsync   (ManagerRec, X"0", X"030201D5"); 
    WriteDataAsync   (ManagerRec, X"0", X"030201D6"); 
    WriteDataAsync   (ManagerRec, X"0", X"030201D7"); 

    log("Wait Cne Cycle") ;
    WaitForClock     (ManagerRec, 1);

    log("Read A5 and Check D5") ;
    ReadCheck        (ManagerRec, X"0000_0A50", X"030201D5"); -- Blocking, read and checks D5

    log("Queue Read Address a6") ;
    ReadAddressAsync (ManagerRec, X"0000_0A60");       -- Queue Read

    log("Wait Cne Cycle") ;
    WaitForClock     (ManagerRec, 1) ;       -- Stops for 1 Clock
    
    log("Write Data sent 1 cycle before Write Address") ;
    log("Write Data D8") ;
    WriteDataAsync   (ManagerRec, X"0", X"030201D8"); -- Queue Write Data 

    log("Block and Check D6") ;
    ReadCheckData    (ManagerRec, X"030201D6");       -- Blocking, checks D6
    
    log("Queue Write Address") ;
    WriteAddressAsync(ManagerRec, X"0000_0A80");
    
    log("Block and Check A7/D7") ;
    ReadCheck (ManagerRec, X"0000_0A70", X"030201D7") ; 

    log("Block and Check A8/D8") ;
    ReadCheck (ManagerRec, X"0000_0A80", X"030201D8") ; 

    WaitForBarrier(InitiatorDone) ;
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process InitiatorProc ;


  ------------------------------------------------------------
  -- MemoryProc
  --   Generate transactions for AxiMemory
  ------------------------------------------------------------
  MemoryTransProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;   
--    alias MemoryTransRec is SubordinateRec ;    
  begin
    WaitForClock(SubordinateRec, 2) ;
    
    -- ReadBack after Initiator finishes
    WaitForBarrier(InitiatorDone) ;
    ReadCheck(SubordinateRec, X"0000_0A10", X"030201D1" ) ;
    ReadCheck(SubordinateRec, X"0000_0A20", X"030201D2" ) ;
    ReadCheck(SubordinateRec, X"0000_0A30", X"030201D3" ) ;
    
    ReadCheck(SubordinateRec, X"0000_0A50", X"030201D5" ) ;
    ReadCheck(SubordinateRec, X"0000_0A60", X"030201D6" ) ;
    ReadCheck(SubordinateRec, X"0000_0A70", X"030201D7" ) ;
    ReadCheck(SubordinateRec, X"0000_0A80", X"030201D8" ) ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MemoryTransProc ;


end MemoryAsync ;

library OSVVM_AXI4 ;

Configuration TbAxi4_MemoryAsync of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MemoryAsync) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_MemoryAsync ; 
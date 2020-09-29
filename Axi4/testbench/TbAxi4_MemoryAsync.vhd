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
    
    print("") ;
    ReportAlerts ; 
    print("") ;
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- InitiatorProc
  --   Generate Address Bus Initiator transactions
  ------------------------------------------------------------
  InitiatorProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
    alias AddrRec is AxiSuperTransRec ;
  begin
    wait until nReset = '1' ;  
    WaitForClock(AddrRec, 2) ; 
    log("Write Address and Data sent at same time") ;
    log("Queue 3 Write Transactions for A1/D1, A2/D2, A3/D3") ;
    WriteAsync       (AddrRec, X"0000_0A10", X"030201D1");  -- Async = Queue
    WriteAsync       (AddrRec, X"0000_0A20", X"030201D2");
    WriteAsync       (AddrRec, X"0000_0A30", X"030201D3");

    log("Wait Cne Cycle") ;
    WaitForClock     (AddrRec, 1) ;      -- Stop for 1 Clock

    log("Queue 3 Read Address Cycles for A1, A2, A3") ;
    ReadAddressAsync (AddrRec, X"0000_0A10");      -- Queue Reads
    ReadAddressAsync (AddrRec, X"0000_0A20");
    ReadAddressAsync (AddrRec, X"0000_0A30");

    log("Block and Check D1, D2, D3") ;
    ReadCheckData    (AddrRec, X"030201D1"); -- Blocking, checks D1
    ReadCheckData    (AddrRec, X"030201D2"); -- Blocking, checks D2
    ReadCheckData    (AddrRec, X"030201D3");  -- Blocking, checks D3
    
    log("Write Address sent 1 cycle before Write Data") ;
    log("Queue 3 Write Address Cycles for A5, A6, and A7") ;
    WriteAddressAsync(AddrRec, X"0000_0A50");  -- Queue Write Address
    WriteAddressAsync(AddrRec, X"0000_0A60");  -- Queue Write Address
    WriteAddressAsync(AddrRec, X"0000_0A70");  -- Queue Write Address

    log("Wait Cne Cycle") ;
    WaitForClock     (AddrRec, 1);

    log("Queue 3 Write Data Cycles for D5, D6, and D7") ;
    WriteDataAsync   (AddrRec, X"0", X"030201D5"); 
    WriteDataAsync   (AddrRec, X"0", X"030201D6"); 
    WriteDataAsync   (AddrRec, X"0", X"030201D7"); 

    log("Wait Cne Cycle") ;
    WaitForClock     (AddrRec, 1);

    log("Read A5 and Check D5") ;
    ReadCheck        (AddrRec, X"0000_0A50", X"030201D5"); -- Blocking, read and checks D5

    log("Queue Read Address a6") ;
    ReadAddressAsync (AddrRec, X"0000_0A60");       -- Queue Read

    log("Wait Cne Cycle") ;
    WaitForClock     (AddrRec, 1) ;       -- Stops for 1 Clock
    
    log("Write Data sent 1 cycle before Write Address") ;
    log("Write Data D8") ;
    WriteDataAsync   (AddrRec, X"0", X"030201D8"); -- Queue Write Data 

    log("Block and Check D6") ;
    ReadCheckData    (AddrRec, X"030201D6");       -- Blocking, checks D6
    
    log("Queue Write Address") ;
    WriteAddressAsync(AddrRec, X"0000_0A80");
    
    log("Block and Check A7/D7") ;
    ReadCheck (AddrRec, X"0000_0A70", X"030201D7") ; 

    log("Block and Check A8/D8") ;
    ReadCheck (AddrRec, X"0000_0A80", X"030201D8") ; 

    WaitForBarrier(InitiatorDone) ;
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(AddrRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process InitiatorProc ;


  ------------------------------------------------------------
  -- AxiMemoryProc
  --   Generate transactions for AxiMemory
  ------------------------------------------------------------
  MemoryTransProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;   
    alias MemoryTransRec is AxiMinionTransRec ;    
  begin
    WaitForClock(MemoryTransRec, 2) ;
    
    -- ReadBack after Initiator finishes
    WaitForBarrier(InitiatorDone) ;
    ReadCheck(MemoryTransRec, X"0000_0A10", X"030201D1" ) ;
    ReadCheck(MemoryTransRec, X"0000_0A20", X"030201D2" ) ;
    ReadCheck(MemoryTransRec, X"0000_0A30", X"030201D3" ) ;
    
    ReadCheck(MemoryTransRec, X"0000_0A50", X"030201D5" ) ;
    ReadCheck(MemoryTransRec, X"0000_0A60", X"030201D6" ) ;
    ReadCheck(MemoryTransRec, X"0000_0A70", X"030201D7" ) ;
    ReadCheck(MemoryTransRec, X"0000_0A80", X"030201D8" ) ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(MemoryTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MemoryTransProc ;


end MemoryAsync ;

library OSVVM_AXI4 ;

Configuration TbAxi4_MemoryAsync of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MemoryAsync) ; 
    end for ; 
  for Axi4Minion_1 : Axi4Responder 
      use entity OSVVM_AXI4.Axi4Memory ; 
    end for ; 
  end for ; 
end TbAxi4_MemoryAsync ; 
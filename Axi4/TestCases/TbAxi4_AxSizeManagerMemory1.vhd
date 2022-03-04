--
--  File Name:         TbAxi4_AxSizeManagerMemory1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--    For Manager and Memory: 
--        AWSIZE, ARSIZE
--        Addresses are on word boundaries
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    12/2020   2020.12    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2018 - 2021 by SynthWorks Design Inc.  
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

architecture AxSizeManagerMemory1 of TestCtrl is

  signal TestDone, SetParams, RunTest, Sync : integer_barrier := 1 ;

  signal TbManagerID : AlertLogIDType ; 
  signal TbSubordinateID  : AlertLogIDType ; 
  signal TransactionCount : integer := 0 ; 
  constant BURST_MODE : AddressBusFifoBurstModeType := ADDRESS_BUS_BURST_WORD_MODE ;   
--  constant BURST_MODE : AddressBusFifoBurstModeType := ADDRESS_BUS_BURST_BYTE_MODE ;   
  constant DATA_WIDTH : integer := IfElse(BURST_MODE = ADDRESS_BUS_BURST_BYTE_MODE, 8, AXI_DATA_WIDTH)  ;  

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_AxSizeManagerMemory1") ;
    TbManagerID <= GetAlertLogID("TB Manager Proc") ;
    TbSubordinateID <= GetAlertLogID("TB Subordinate Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_AxSizeManagerMemory1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    -- SetAlertLogJustify ;
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4_AxSizeManagerMemory1.txt", "../sim_shared/validated_results/TbAxi4_AxSizeManagerMemory1.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- ManagerProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  ManagerProc : process
    variable Addr, ExpAddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data, ExpData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;  
    variable ValidDelayCycleOption : Axi4OptionsType ; 
    variable IntOption  : integer ; 
  begin
    -- Must set Manager options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 
   
------------------------------------------------------  Check Defaults
    --------------------------------  Get and Check Defaults - Write
    log(TbManagerID, "Checking IF Parameters for Write Address") ;
    GetAxi4Options(ManagerRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbManagerID, IntOption,  2, "AWSIZE") ; 


    WaitForClock(ManagerRec, 4) ; 
    
------------------------------------------------------  Write Test 1.
    --------------------------------  Set #1
    SetAxi4Options(ManagerRec, AWSIZE,   1) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #1
    GetAxi4Options(ManagerRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbManagerID, IntOption,  1, "AWSIZE") ; 
    
    --------------------------------  Do Writes #1
    log(TbManagerID, "Write with parameters setting #1, Defaults") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" ; 
    Push(WriteBurstFifo, X"UUUU_2211") ;  
    Push(WriteBurstFifo, X"4433_UUUU") ;  
    Push(WriteBurstFifo, X"UUUU_6655") ;  
    Push(WriteBurstFifo, X"8877_UUUU") ;  
    Push(WriteBurstFifo, X"UUUU_AA99") ;  
    Push(WriteBurstFifo, X"CCBB_UUUU") ;  
    Push(WriteBurstFifo, X"UUUU_EEDD") ;  
    Push(WriteBurstFifo, X"00FF_UUUU") ;  
    WriteBurst(ManagerRec, Addr, 8) ;
    
    Push(WriteBurstFifo, X"UUUU_1111") ;  
    Push(WriteBurstFifo, X"2222_UUUU") ;  
    Push(WriteBurstFifo, X"UUUU_3333") ;  
    Push(WriteBurstFifo, X"4444_UUUU") ;  
    Push(WriteBurstFifo, X"UUUU_5555") ;  
    Push(WriteBurstFifo, X"6666_UUUU") ;  
    Push(WriteBurstFifo, X"UUUU_7777") ;  
    Push(WriteBurstFifo, X"8888_UUUU") ;  
    WriteBurst(ManagerRec, Addr+128, 8) ;
    
    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Write Test 2.
    --------------------------------  Set #2
    SetAxi4Options(ManagerRec, AWSIZE,   2) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #2
    GetAxi4Options(ManagerRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbManagerID, IntOption,  2, "AWSIZE") ; 
    
    --------------------------------  Do Writes #2
    log(TbManagerID, "Write with parameters setting #2") ;
    increment(TransactionCount) ;
    Addr := Addr + 256 ; 
    Push(WriteBurstFifo, X"CCDD_EEFF") ;  
    Push(WriteBurstFifo, X"8899_AABB") ;  
    Push(WriteBurstFifo, X"4455_6677") ;  
    Push(WriteBurstFifo, X"1122_3344") ;  
    WriteBurst(ManagerRec, Addr, 4) ;
    
    Push(WriteBurstFifo, X"9999_8888") ;  
    Push(WriteBurstFifo, X"7777_6666") ;  
    Push(WriteBurstFifo, X"5555_4444") ;  
    Push(WriteBurstFifo, X"3333_2222") ;  
    WriteBurst(ManagerRec, Addr+128, 4) ;
    
    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Write Test 3.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #3, None - Using Defaults
    SetAxi4Options(ManagerRec, AWSIZE,   0) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #3
    GetAxi4Options(ManagerRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbManagerID, IntOption,  0, "AWSIZE") ; 
    
    --------------------------------  Do Writes #3
    WaitForBarrier(RunTest) ;
    log(TbManagerID, "Write with parameters setting #3") ;
    Addr := Addr + 256 ; 
    Push(WriteBurstFifo, X"UUUU_UU11") ;  
    Push(WriteBurstFifo, X"UUUU_22UU") ;  
    Push(WriteBurstFifo, X"UU33_UUUU") ;  
    Push(WriteBurstFifo, X"44UU_UUUU") ;  
    Push(WriteBurstFifo, X"UUUU_UU55") ;  
    Push(WriteBurstFifo, X"UUUU_66UU") ;  
    Push(WriteBurstFifo, X"UU77_UUUU") ;  
    Push(WriteBurstFifo, X"88UU_UUUU") ;  
    WriteBurst(ManagerRec, Addr, 8) ;
    
    Push(WriteBurstFifo, X"UUUU_UU11") ;  
    Push(WriteBurstFifo, X"UUUU_33UU") ;  
    Push(WriteBurstFifo, X"UU22_UUUU") ;  
    Push(WriteBurstFifo, X"44UU_UUUU") ;  
    Push(WriteBurstFifo, X"UUUU_UU55") ;  
    Push(WriteBurstFifo, X"UUUU_77UU") ;  
    Push(WriteBurstFifo, X"UU66_UUUU") ;  
    Push(WriteBurstFifo, X"88UU_UUUU") ;  
    WriteBurst(ManagerRec, Addr+128, 8) ;

    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Write Test 4.
    --------------------------------  Set #4
    SetAxi4Options(ManagerRec, AWSIZE,   2) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #4
    GetAxi4Options(ManagerRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbManagerID, IntOption,  2, "AWSIZE") ; 
    
    --------------------------------  Do Writes #4
    log(TbManagerID, "Write with parameters setting #4") ;
    increment(TransactionCount) ;
    Addr := Addr + 256 ; 
    Push(WriteBurstFifo, X"CCDD_EEFF") ;  
    Push(WriteBurstFifo, X"8899_AABB") ;  
    WriteBurst(ManagerRec, Addr, 2) ;
    
    Push(WriteBurstFifo, X"9999_8888") ;  
    Push(WriteBurstFifo, X"7777_6666") ;  
    WriteBurst(ManagerRec, Addr+128, 2) ;
    
    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;

--  ==================================================  Read Tests
    WaitForBarrier(Sync) ;
    
    
------------------------------------------------------  Read Test 1.
    --------------------------------  Set #1
    SetAxi4Options(ManagerRec, ARSIZE,   2) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #1
    GetAxi4Options(ManagerRec, ARSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbManagerID, IntOption,  2, "ARSIZE") ; 
    
    --------------------------------  Do Reads #1
    log(TbManagerID, "Read with parameters setting #1, Defaults") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" ; 
    ReadBurst(ManagerRec, Addr, 4) ;
   CheckExpected(ReadBurstFifo, X"4433_2211") ;  
   CheckExpected(ReadBurstFifo, X"8877_6655") ;  
   CheckExpected(ReadBurstFifo, X"CCBB_AA99") ;  
   CheckExpected(ReadBurstFifo, X"00FF_EEDD") ;  
    
    ReadBurst(ManagerRec, Addr+128, 4) ;
   CheckExpected(ReadBurstFifo, X"2222_1111") ;  
   CheckExpected(ReadBurstFifo, X"4444_3333") ;  
   CheckExpected(ReadBurstFifo, X"6666_5555") ;  
   CheckExpected(ReadBurstFifo, X"8888_7777") ;  
    
    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Read Test 2.
    --------------------------------  Set #2
    SetAxi4Options(ManagerRec, ARSIZE,   1) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #2
    GetAxi4Options(ManagerRec, ARSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbManagerID, IntOption,  1, "ARSIZE") ; 
    
    --------------------------------  Do Reads #2
    log(TbManagerID, "Read with parameters setting #2") ;
    increment(TransactionCount) ;
    Addr := Addr + 256 ; 
    ReadBurst(ManagerRec, Addr, 8) ;
   CheckExpected(ReadBurstFifo, X"----_EEFF") ;  
   CheckExpected(ReadBurstFifo, X"CCDD_----") ;  
   CheckExpected(ReadBurstFifo, X"----_AABB") ;  
   CheckExpected(ReadBurstFifo, X"8899_----") ;  
   CheckExpected(ReadBurstFifo, X"----_6677") ;  
   CheckExpected(ReadBurstFifo, X"4455_----") ;  
   CheckExpected(ReadBurstFifo, X"----_3344") ;  
   CheckExpected(ReadBurstFifo, X"1122_----") ;  
    
    ReadBurst(ManagerRec, Addr+128, 8) ;
   CheckExpected(ReadBurstFifo, X"----_8888") ;  
   CheckExpected(ReadBurstFifo, X"9999_8888") ;  
   CheckExpected(ReadBurstFifo, X"----_6666") ;  
   CheckExpected(ReadBurstFifo, X"7777_----") ;  
   CheckExpected(ReadBurstFifo, X"----_4444") ;  
   CheckExpected(ReadBurstFifo, X"5555_----") ;  
   CheckExpected(ReadBurstFifo, X"----_2222") ;  
   CheckExpected(ReadBurstFifo, X"3333_----") ;  
    
    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Read Test 3.  Set and Get, Do Read
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #3, None - Using Defaults
    SetAxi4Options(ManagerRec, ARSIZE,   2) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #3
    GetAxi4Options(ManagerRec, ARSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbManagerID, IntOption,  2, "ARSIZE") ; 
    
    --------------------------------  Do Reads #3
    WaitForBarrier(RunTest) ;
    log(TbManagerID, "Read with parameters setting #3") ;
    Addr := Addr + 256 ; 
    ReadBurst(ManagerRec, Addr, 2) ;
   CheckExpected(ReadBurstFifo, X"4433_2211") ;  
   CheckExpected(ReadBurstFifo, X"8877_6655") ;  
    
    ReadBurst(ManagerRec, Addr+128, 2) ;
   CheckExpected(ReadBurstFifo, X"4422_3311") ;  
   CheckExpected(ReadBurstFifo, X"8866_7755") ;  

    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Read Test 4.
    --------------------------------  Set #4
    SetAxi4Options(ManagerRec, ARSIZE,   0) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #4
    GetAxi4Options(ManagerRec, ARSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbManagerID, IntOption,  0, "ARSIZE") ; 
    
    --------------------------------  Do Reads #4
    log(TbManagerID, "Read with parameters setting #4") ;
    increment(TransactionCount) ;
    Addr := Addr + 256 ; 
    ReadBurst(ManagerRec, Addr, 8) ;
   CheckExpected(ReadBurstFifo, X"----_--FF") ;  
   CheckExpected(ReadBurstFifo, X"----_EE--") ;  
   CheckExpected(ReadBurstFifo, X"--DD_----") ;  
   CheckExpected(ReadBurstFifo, X"CC--_----") ;  
   CheckExpected(ReadBurstFifo, X"----_--BB") ;  
   CheckExpected(ReadBurstFifo, X"----_AA--") ;  
   CheckExpected(ReadBurstFifo, X"--99_----") ;  
   CheckExpected(ReadBurstFifo, X"88--_----") ;  
    
    ReadBurst(ManagerRec, Addr+128, 8) ;
   CheckExpected(ReadBurstFifo, X"----_--88") ;  
   CheckExpected(ReadBurstFifo, X"----_88--") ;  
   CheckExpected(ReadBurstFifo, X"--99_----") ;  
   CheckExpected(ReadBurstFifo, X"99--_----") ;  
   CheckExpected(ReadBurstFifo, X"----_--66") ;  
   CheckExpected(ReadBurstFifo, X"----_66--") ;  
   CheckExpected(ReadBurstFifo, X"--77_----") ;  
   CheckExpected(ReadBurstFifo, X"77--_----") ;  
    
    WaitForClock(ManagerRec, 4) ; 
    BlankLine(2) ;
    
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
    variable IntOption : integer ; 
  begin
    wait for 0 ns ; 
    
    -- Memory only responds during this test
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;

end AxSizeManagerMemory1 ;

Configuration TbAxi4_AxSizeManagerMemory1 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxSizeManagerMemory1) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_AxSizeManagerMemory1 ; 
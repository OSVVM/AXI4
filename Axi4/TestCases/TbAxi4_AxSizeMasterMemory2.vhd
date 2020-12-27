--
--  File Name:         TbAxi4_AxSizeMasterMemory2.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--    For Master and Memory: 
--        AWSIZE, ARSIZE
--        Address boundaries on non-word boundaries
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
--  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.  
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

architecture AxSizeMasterMemory2 of TestCtrl is

  signal TestDone, SetParams, RunTest, Sync : integer_barrier := 1 ;

  signal TbMasterID : AlertLogIDType ; 
  signal TbResponderID  : AlertLogIDType ; 
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
    SetAlertLogName("TbAxi4_AxSizeMasterMemory2") ;
    TbMasterID <= GetAlertLogID("TB Master Proc") ;
    TbResponderID <= GetAlertLogID("TB Responder Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_AxSizeMasterMemory2.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_AxSizeMasterMemory2.txt", "../sim_shared/validated_results/TbAxi4_AxSizeMasterMemory2.txt", "") ; 
    
    print("") ;
    ReportAlerts ; 
    print("") ;
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- MasterProc
  --   Generate transactions for AxiResponder
  ------------------------------------------------------------
  MasterProc : process
    variable Addr, ExpAddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data, ExpData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;  
    variable ValidDelayCycleOption : Axi4OptionsType ; 
    variable IntOption  : integer ; 
  begin
    -- Must set Master options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 
   
------------------------------------------------------  Check Defaults
    --------------------------------  Get and Check Defaults - Write
    log(TbMasterID, "Checking IF Parameters for Write Address") ;
    GetAxi4Options(MasterRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbMasterID, IntOption,  2, "AWSIZE") ; 


    WaitForClock(MasterRec, 4) ; 
    
------------------------------------------------------  Write Test 1.
    --------------------------------  Set #1
    SetAxi4Options(MasterRec, AWSIZE,   1) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #1
    GetAxi4Options(MasterRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbMasterID, IntOption,  1, "AWSIZE") ; 
    
    --------------------------------  Do Writes #1
    log(TbMasterID, "Write with parameters setting #1, Defaults") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" + 2 ; 
    WriteBurstFifo.Push(X"00FF_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_2211") ;  
    WriteBurstFifo.Push(X"4433_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_6655") ;  
    WriteBurstFifo.Push(X"8877_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_AA99") ;  
    WriteBurstFifo.Push(X"CCBB_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_EEDD") ;  
    WriteBurst(MasterRec, Addr, 8) ;
    
    WriteBurstFifo.Push(X"0000_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_1111") ;  
    WriteBurstFifo.Push(X"2222_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_3333") ;  
    WriteBurstFifo.Push(X"4444_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_5555") ;  
    WriteBurstFifo.Push(X"6666_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_7777") ;  
    WriteBurst(MasterRec, Addr+128, 8) ;
    
    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Write Test 2.
    --------------------------------  Set #2
    SetAxi4Options(MasterRec, AWSIZE,   2) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #2
    GetAxi4Options(MasterRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbMasterID, IntOption,  2, "AWSIZE") ; 
    
    --------------------------------  Do Writes #2
    log(TbMasterID, "Write with parameters setting #2") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" + 256 + 2 ; 
    WriteBurstFifo.Push(X"CCDD_UUUU") ;  
    WriteBurstFifo.Push(X"8899_AABB") ;  
    WriteBurstFifo.Push(X"4455_6677") ;  
    WriteBurstFifo.Push(X"1122_3344") ;  
    WriteBurstFifo.Push(X"UUUU_EEFF") ;  
    WriteBurst(MasterRec, Addr, 5) ;
    
    WriteBurstFifo.Push(X"9999_UUUU") ;  
    WriteBurstFifo.Push(X"7777_6666") ;  
    WriteBurstFifo.Push(X"5555_4444") ;  
    WriteBurstFifo.Push(X"3333_2222") ;  
    WriteBurstFifo.Push(X"UUUU_0000") ;  
    WriteBurst(MasterRec, Addr+128, 5) ;
    
    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Write Test 3.  Set and Get, Do Write
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #3, None - Using Defaults
    SetAxi4Options(MasterRec, AWSIZE,   0) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #3
    GetAxi4Options(MasterRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbMasterID, IntOption,  0, "AWSIZE") ; 
    
    --------------------------------  Do Writes #3
    WaitForBarrier(RunTest) ;
    log(TbMasterID, "Write with parameters setting #3") ;
    Addr := X"0000_0000" + 512 + 1 ;  -- Byte 1
    WriteBurstFifo.Push(X"UUUU_22UU") ;  
    WriteBurstFifo.Push(X"UU33_UUUU") ;  
    WriteBurstFifo.Push(X"44UU_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_UU55") ;  
    WriteBurstFifo.Push(X"UUUU_66UU") ;  
    WriteBurstFifo.Push(X"UU77_UUUU") ;  
    WriteBurstFifo.Push(X"88UU_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_UU99") ;  
    WriteBurst(MasterRec, Addr, 8) ;
    
    WriteBurstFifo.Push(X"44UU_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_UU55") ;  
    WriteBurstFifo.Push(X"UUUU_77UU") ;  
    WriteBurstFifo.Push(X"UU66_UUUU") ;  
    WriteBurstFifo.Push(X"88UU_UUUU") ;  
    WriteBurstFifo.Push(X"UUUU_UU99") ;  
    WriteBurstFifo.Push(X"UUUU_BBUU") ;  
    WriteBurstFifo.Push(X"UUAA_UUUU") ;  
    WriteBurst(MasterRec, Addr+128+2, 8) ;  -- Byte 3

    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Write Test 4.
    --------------------------------  Set #4
    SetAxi4Options(MasterRec, AWSIZE,   2) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #4
    GetAxi4Options(MasterRec, AWSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbMasterID, IntOption,  2, "AWSIZE") ; 
    
    --------------------------------  Do Writes #4
    log(TbMasterID, "Write with parameters setting #4") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" + 1024 + 1 ;  -- Byte 1
    WriteBurstFifo.Push(X"CCDD_EEUU") ;  
    WriteBurstFifo.Push(X"8899_AABB") ;  
    WriteBurstFifo.Push(X"UUUU_UU77") ;  
    WriteBurst(MasterRec, Addr, 3) ;
    
    WriteBurstFifo.Push(X"99UU_UUUU") ;  
    WriteBurstFifo.Push(X"7777_6666") ;  
    WriteBurstFifo.Push(X"UU55_4444") ;  
    WriteBurst(MasterRec, Addr+128+2, 3) ; -- Byte 3
    
    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;

--  ==================================================  Read Tests
    WaitForBarrier(Sync) ;
    
    
------------------------------------------------------  Read Test 1.
    --------------------------------  Set #1
    SetAxi4Options(MasterRec, ARSIZE,   2) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #1
    GetAxi4Options(MasterRec, ARSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbMasterID, IntOption,  2, "ARSIZE") ; 
    
    --------------------------------  Do Reads #1
    log(TbMasterID, "Read with parameters setting #1, Defaults") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" + 2 ; 
    ReadBurst(MasterRec, Addr, 5) ;
    ReadBurstFifo.Check(X"00FF_----") ;  
    ReadBurstFifo.Check(X"4433_2211") ;  
    ReadBurstFifo.Check(X"8877_6655") ;  
    ReadBurstFifo.Check(X"CCBB_AA99") ;  
    ReadBurstFifo.Check(X"----_EEDD") ;  
    
    ReadBurst(MasterRec, Addr+128, 5) ;
    ReadBurstFifo.Check(X"0000_----") ;  
    ReadBurstFifo.Check(X"2222_1111") ;  
    ReadBurstFifo.Check(X"4444_3333") ;  
    ReadBurstFifo.Check(X"6666_5555") ;  
    ReadBurstFifo.Check(X"----_7777") ;  
    
    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Read Test 2.
    --------------------------------  Set #2
    SetAxi4Options(MasterRec, ARSIZE,   1) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #2
    GetAxi4Options(MasterRec, ARSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbMasterID, IntOption,  1, "ARSIZE") ; 
    
    --------------------------------  Do Reads #2
    log(TbMasterID, "Read with parameters setting #2") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" + 256 + 2 ; 
    ReadBurst(MasterRec, Addr, 8) ;
    ReadBurstFifo.Check(X"CCDD_----") ;  
    ReadBurstFifo.Check(X"----_AABB") ;  
    ReadBurstFifo.Check(X"8899_----") ;  
    ReadBurstFifo.Check(X"----_6677") ;  
    ReadBurstFifo.Check(X"4455_----") ;  
    ReadBurstFifo.Check(X"----_3344") ;  
    ReadBurstFifo.Check(X"1122_----") ;  
    ReadBurstFifo.Check(X"----_EEFF") ;  
    
    ReadBurst(MasterRec, Addr+128, 8) ;
    ReadBurstFifo.Check(X"9999_----") ;  
    ReadBurstFifo.Check(X"----_6666") ;  
    ReadBurstFifo.Check(X"7777_----") ;  
    ReadBurstFifo.Check(X"----_4444") ;  
    ReadBurstFifo.Check(X"5555_----") ;  
    ReadBurstFifo.Check(X"----_2222") ;  
    ReadBurstFifo.Check(X"3333_----") ;  
    ReadBurstFifo.Check(X"----_0000") ;  
    
    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Read Test 3.  Set and Get, Do Read
    WaitForBarrier(SetParams) ;
    increment(TransactionCount) ;
    --------------------------------  Set #3, None - Using Defaults
    SetAxi4Options(MasterRec, ARSIZE,   2) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #3
    GetAxi4Options(MasterRec, ARSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbMasterID, IntOption,  2, "ARSIZE") ; 
    
    --------------------------------  Do Reads #3
    WaitForBarrier(RunTest) ;
    log(TbMasterID, "Read with parameters setting #3") ;
    Addr := X"0000_0000" + 512 + 1 ;  -- Byte 1
    ReadBurst(MasterRec, Addr, 3) ;
    ReadBurstFifo.Check(X"4433_22--") ;  
    ReadBurstFifo.Check(X"8877_6655") ;  
    ReadBurstFifo.Check(X"----_--99") ;  
    
    ReadBurst(MasterRec, Addr+128+2, 3) ; -- Byte 3
    ReadBurstFifo.Check(X"44--_----") ;  
    ReadBurstFifo.Check(X"8866_7755") ;  
    ReadBurstFifo.Check(X"--AA_BB99") ;  

    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;

------------------------------------------------------  Read Test 4.
    --------------------------------  Set #4
    SetAxi4Options(MasterRec, ARSIZE,   0) ;      -- 3 bits 2**N bytes
    
    --------------------------------  Get and Check #4
    GetAxi4Options(MasterRec, ARSIZE,   IntOption) ;      -- 3 bits 2**N bytes
    AffirmIfEqual(TbMasterID, IntOption,  0, "ARSIZE") ; 
    
    --------------------------------  Do Reads #4
    log(TbMasterID, "Read with parameters setting #4") ;
    increment(TransactionCount) ;
    Addr := X"0000_0000" + 1024 + 1 ;  -- Byte 1
    ReadBurst(MasterRec, Addr, 8) ;
    ReadBurstFifo.Check(X"----_EE--") ;  
    ReadBurstFifo.Check(X"--DD_----") ;  
    ReadBurstFifo.Check(X"CC--_----") ;  
    ReadBurstFifo.Check(X"----_--BB") ;  
    ReadBurstFifo.Check(X"----_AA--") ;  
    ReadBurstFifo.Check(X"--99_----") ;  
    ReadBurstFifo.Check(X"88--_----") ;  
    ReadBurstFifo.Check(X"----_--77") ;  
    
    ReadBurst(MasterRec, Addr+128+2, 8) ; -- Byte 3
    ReadBurstFifo.Check(X"99--_----") ;  
    ReadBurstFifo.Check(X"----_--66") ;  
    ReadBurstFifo.Check(X"----_66--") ;  
    ReadBurstFifo.Check(X"--77_----") ;  
    ReadBurstFifo.Check(X"77--_----") ;  
    ReadBurstFifo.Check(X"----_--44") ;  
    ReadBurstFifo.Check(X"----_44--") ;  
    ReadBurstFifo.Check(X"--55_----") ;  

    WaitForClock(MasterRec, 4) ; 
    BlankLine(2) ;
    
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
    variable IntOption : integer ; 
  begin
    wait for 0 ns ; 
    
    -- Memory only responds during this test
    WaitForBarrier(TestDone) ;
    wait ;
  end process ResponderProc ;

end AxSizeMasterMemory2 ;

Configuration TbAxi4_AxSizeMasterMemory2 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxSizeMasterMemory2) ; 
    end for ; 
    for Responder_1 : Axi4Responder 
      use entity OSVVM_AXI4.Axi4Memory ; 
    end for ; 
  end for ; 
end TbAxi4_AxSizeMasterMemory2 ; 
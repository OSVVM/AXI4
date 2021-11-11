--
--  File Name:         TbAxi4_ValidTimingBurstMemory.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--    WRITE_RESPONSE & READ_DATA
--        Verify Initial values
--        READY_BEFORE_VALID  F/T/T w/ WFC(C,6)
--        READY_DELAY_CYCLES 0,2,4 
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

architecture ValidTimingBurstMemory of TestCtrl is

  signal TestDone, MemorySync : integer_barrier := 1 ;
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
    SetAlertLogName("TbAxi4_ValidTimingBurstMemory") ;
    TbManagerID <= GetAlertLogID("TB Manager Proc") ;
    TbSubordinateID <= GetAlertLogID("TB Subordinate Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_ValidTimingBurstMemory.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_ValidTimingBurstMemory.txt", "../sim_shared/validated_results/TbAxi4_ValidTimingBurstMemory.txt", "") ; 

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
  begin
    -- Must set Manager options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 
    WaitForClock(ManagerRec, 3) ; 

    for k in 0 to 1 loop 
      for j in 0 to 3 loop 
        WaitForClock(ManagerRec, 4) ; 

        Addr := X"0000_0000" + k*(2**12) + j*(2**8) ; 
        Data := X"0000_0000" + k*(2**12) + j*(2**8) ; 
        PushBurstIncrement(WriteBurstFifo, to_integer(Data), 4*8, DATA_WIDTH) ;
        WriteBurstAsync(ManagerRec, Addr,        8) ;
        WriteBurstAsync(ManagerRec, Addr+(8*4),  8) ;
        WriteBurstAsync(ManagerRec, Addr+(16*4), 8) ;
        WriteBurst(ManagerRec, Addr+(24*4), 8) ;
        WaitForClock(ManagerRec, 8) ; 
        WaitForTransaction(ManagerRec) ;
--!!        -- Make sure Writes finish before reads start when write data is delayed
--!!        if k = 1 then WaitForTransaction(ManagerRec) ;  end if ; 
        
        ReadBurst(ManagerRec, Addr,        8) ;
--        if k = 1 then 
----!!          WaitForTransaction(ManagerRec) ;
--          WaitForClock(ManagerRec, 8) ;
--        end if ; 
        ReadBurst(ManagerRec, Addr+(8*4),  8) ;
--        if k = 1 then 
----!!          WaitForTransaction(ManagerRec) ;
--          WaitForClock(ManagerRec, 8) ;
--        end if ; 
        ReadBurst(ManagerRec, Addr+(16*4), 8) ;
--        if k = 1 then 
----!!          WaitForTransaction(ManagerRec) ;
--          WaitForClock(ManagerRec, 8) ;
--        end if ; 
        ReadBurst(ManagerRec, Addr+(24*4), 8) ;
        CheckBurstIncrement(ReadBurstFifo, to_integer(Data), 4*8, DATA_WIDTH) ;
        WaitForClock(ManagerRec, 8) ; 
        WaitForBarrier(MemorySync) ;
      end loop ; 
    end loop ; 

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
    variable ValidDelayCycleOption : Axi4OptionsType ; 
    variable IntOption  : integer ; 
  begin
    -- Check Defaults
    GetAxi4Options(SubordinateRec, WRITE_RESPONSE_VALID_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbSubordinateID, IntOption, 0, "WRITE_RESPONSE_VALID_DELAY_CYCLES") ;

    GetAxi4Options(SubordinateRec, READ_DATA_VALID_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbSubordinateID, IntOption, 0, "READ_DATA_VALID_DELAY_CYCLES") ;

    GetAxi4Options(SubordinateRec, READ_DATA_VALID_BURST_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbSubordinateID, IntOption, 0, "READ_DATA_VALID_BURST_DELAY_CYCLES") ;

    for k in 0 to 1 loop 
      case k is 
        when 0 => 
          log(TbSubordinateID, "Write Response") ;
          ValidDelayCycleOption  := WRITE_RESPONSE_VALID_DELAY_CYCLES ;
        when 1 => 
          log(TbSubordinateID, "Read Data") ;
          ValidDelayCycleOption  := READ_DATA_VALID_DELAY_CYCLES ;
        when others => 
          alert("K Loop Index Out of Range", FAILURE) ;
      end case ; 
      for j in 0 to 3 loop 
        case j is 
          when 0 => 
            log(TbSubordinateID, "Valid Delay Cycles Default 0") ;
          when 1 => 
            log(TbSubordinateID, "Valid Delay Cycles 2") ;
            SetAxi4Options(SubordinateRec, ValidDelayCycleOption, 2) ;
            if k = 1 then  
              SetAxi4Options(SubordinateRec, READ_DATA_VALID_BURST_DELAY_CYCLES, 2) ;
            end if ; 
          when 2 => 
            log(TbSubordinateID, "Valid Delay Cycles 4") ;
            SetAxi4Options(SubordinateRec, ValidDelayCycleOption, 4) ;
            if k = 1 then  
              SetAxi4Options(SubordinateRec, READ_DATA_VALID_BURST_DELAY_CYCLES, 1) ;
            end if ; 
          when 3 => 
            log(TbSubordinateID, "Valid Delay Cycles 0") ;
            SetAxi4Options(SubordinateRec, ValidDelayCycleOption, 0) ;
            if k = 1 then  
              SetAxi4Options(SubordinateRec, READ_DATA_VALID_BURST_DELAY_CYCLES, 0) ;
            end if ; 
          when others => 
            Alert(TbSubordinateID, "Unimplemented test case", FAILURE)  ; 
        end case ; 
        increment(TransactionCount) ;

        WaitForBarrier(MemorySync) ;
        print("") ; print("") ;
      end loop ; 
    end loop ; 
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;

end ValidTimingBurstMemory ;

Configuration TbAxi4_ValidTimingBurstMemory of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ValidTimingBurstMemory) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_ValidTimingBurstMemory ; 
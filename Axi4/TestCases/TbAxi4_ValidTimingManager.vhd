--
--  File Name:         TbAxi4_ValidTimingManager.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--    WRITE_ADDRESS, WRITE_DATA, READ_ADDRESS
--        Verify Initial values
--        VALID_DELAY_CYCLES D, 2, 4, 6, 0 
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

architecture ValidTimingManager of TestCtrl is

  signal TestDone, MemorySync : integer_barrier := 1 ;
  signal TbManagerID : AlertLogIDType ; 
  signal TbSubordinateID  : AlertLogIDType ; 
  signal TransactionCount : integer := 0 ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_ValidTimingManager") ;
    TbManagerID <= GetAlertLogID("TB Manager Proc") ;
    TbSubordinateID <= GetAlertLogID("TB Subordinate Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_ValidTimingManager.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_ValidTimingManager.txt", "../sim_shared/validated_results/TbAxi4_ValidTimingManager.txt", "") ; 

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
    WaitForClock(ManagerRec, 3) ; 
    
    -- Check Defaults
    GetAxi4Options(ManagerRec, WRITE_ADDRESS_VALID_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbManagerID, IntOption, 0, "WRITE_ADDRESS_VALID_DELAY_CYCLES") ;

    GetAxi4Options(ManagerRec, WRITE_DATA_VALID_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbManagerID, IntOption, 0, "WRITE_DATA_VALID_DELAY_CYCLES") ;

    GetAxi4Options(ManagerRec, READ_ADDRESS_VALID_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbManagerID, IntOption, 0, "READ_ADDRESS_VALID_DELAY_CYCLES") ;


    for k in 0 to 2 loop 
      case k is 
        when 0 => 
          log(TbManagerID, "Write Address") ;
          ValidDelayCycleOption  := WRITE_ADDRESS_VALID_DELAY_CYCLES ;
        when 1 => 
          log(TbManagerID, "Write Data") ;
          ValidDelayCycleOption  := WRITE_DATA_VALID_DELAY_CYCLES ;
        when 2 => 
          log(TbManagerID, "Read Address") ;
          ValidDelayCycleOption  := READ_ADDRESS_VALID_DELAY_CYCLES ;
        when others => 
          alert("K Loop Index Out of Range", FAILURE) ;
      end case ; 
      for j in 0 to 4 loop 
        case j is 
          when 0 => 
            log(TbManagerID, "Valid Delay Cycles Default 0") ;
          when 1 => 
            log(TbManagerID, "Valid Delay Cycles 2") ;
            SetAxi4Options(ManagerRec, ValidDelayCycleOption, 2) ;
          when 2 => 
            log(TbManagerID, "Valid Delay Cycles 4") ;
            SetAxi4Options(ManagerRec, ValidDelayCycleOption, 4) ;
          when 3 => 
            log(TbManagerID, "Valid Delay Cycles 6") ;
            SetAxi4Options(ManagerRec, ValidDelayCycleOption, 6) ;
          when 4 => 
            log(TbManagerID, "Valid Delay Cycles 0") ;
            SetAxi4Options(ManagerRec, ValidDelayCycleOption, 0) ;
          when others => 
            Alert(TbManagerID, "Unimplemented test case", FAILURE)  ; 
        end case ; 
        increment(TransactionCount) ;
        WaitForClock(ManagerRec, 4) ; 
        Addr := X"0000_0000" + k*256 + j*16 ; 
        Data := X"0000_0000" + k*256 + j*16 ; 
--        if k /= 2 then 
        log(TbManagerID, "ManagerRec, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
        WriteAsync(ManagerRec, Addr,    Data) ;
        WriteAsync(ManagerRec, Addr+4,  Data+1) ;
        WriteAsync(ManagerRec, Addr+8,  Data+2) ;
        WriteAsync(ManagerRec, Addr+12, Data+3) ;
--          WaitForClock(ManagerRec, 16) ; 
        WaitForTransaction(ManagerRec) ;
        WaitForClock(ManagerRec, 4) ; 
--        else
        log(TbManagerID, "ManagerRec, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
        ReadAddressAsync(ManagerRec, Addr) ;
        ReadAddressAsync(ManagerRec, Addr+4) ;
        ReadAddressAsync(ManagerRec, Addr+8) ;
        ReadAddressAsync(ManagerRec, Addr+12) ;
        ReadCheckData(ManagerRec, Data) ;
        ReadCheckData(ManagerRec, Data+1) ;
        ReadCheckData(ManagerRec, Data+2) ;
        ReadCheckData(ManagerRec, Data+3) ;
        WaitForClock(ManagerRec, 4) ; 
--        end if ; 
--        WaitForBarrier(MemorySync) ;
        print("") ; print("") ;
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
  begin
    -- Memory Subordinate does nothing active during this test
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;

end ValidTimingManager ;

Configuration TbAxi4_ValidTimingManager of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ValidTimingManager) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_ValidTimingManager ; 
--
--  File Name:         TbAxi4_ReadyTimingManager.vhd
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

architecture ReadyTimingManager of TestCtrl is

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
    SetAlertLogName("TbAxi4_ReadyTimingManager") ;
    TbManagerID <= GetAlertLogID("TB Manager Proc") ;
    TbSubordinateID <= GetAlertLogID("TB Subordinate Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_ReadyTimingManager.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_ReadyTimingManager.txt", "../sim_shared/validated_results/TbAxi4_ReadyTimingManager.txt", "") ; 

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
    variable ReadyDelayCycleOption, ReadyBeforeValidOption : Axi4OptionsType ; 
    variable IntOption  : integer ; 
    variable BoolOption : boolean ; 
  begin
    -- Must set Manager options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 
    WaitForClock(ManagerRec, 3) ; 
    
    -- Check Defaults
    GetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbManagerID, IntOption, 0, "WRITE_RESPONSE_READY_DELAY_CYCLES") ;
    GetAxi4Options(ManagerRec, WRITE_RESPONSE_READY_BEFORE_VALID, BoolOption) ;
    AffirmIfEqual(TbManagerID, BoolOption, TRUE, "WRITE_RESPONSE_READY_BEFORE_VALID") ;

    GetAxi4Options(ManagerRec, READ_DATA_READY_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbManagerID, IntOption, 0, "READ_DATA_READY_DELAY_CYCLES") ;
    GetAxi4Options(ManagerRec, READ_DATA_READY_BEFORE_VALID, BoolOption) ;
    AffirmIfEqual(TbManagerID, BoolOption, TRUE, "READ_DATA_READY_BEFORE_VALID") ;

    for k in 0 to 1 loop 
      case k is 
        when 0 => 
          log(TbManagerID, "Write Address") ;
          ReadyDelayCycleOption  := WRITE_RESPONSE_READY_DELAY_CYCLES ;
          ReadyBeforeValidOption := WRITE_RESPONSE_READY_BEFORE_VALID ;
        when 1 => 
          log(TbManagerID, "Read Data") ;
          ReadyDelayCycleOption  := READ_DATA_READY_DELAY_CYCLES ;
          ReadyBeforeValidOption := READ_DATA_READY_BEFORE_VALID ;
        when others => 
          alert("K Loop Index Out of Range", FAILURE) ;
      end case ; 
      for j in 0 to 5 loop 
        case j is 
          when 0 => 
            log(TbManagerID, "Valid Before Ready, Delay Cycles 0") ;
            SetAxi4Options(ManagerRec, ReadyDelayCycleOption, 0) ;
            SetAxi4Options(ManagerRec, ReadyBeforeValidOption, FALSE) ;
          when 1 => 
            log(TbManagerID, "Valid Before Ready, Delay Cycles 2") ;
            SetAxi4Options(ManagerRec, ReadyDelayCycleOption, 2) ;
            SetAxi4Options(ManagerRec, ReadyBeforeValidOption, FALSE) ;
          when 2 => 
            log(TbManagerID, "Valid Before Ready, Delay Cycles 4") ;
            SetAxi4Options(ManagerRec, ReadyDelayCycleOption, 4) ;
            SetAxi4Options(ManagerRec, ReadyBeforeValidOption, FALSE) ;
          when 3 => 
            log(TbManagerID, "Ready Before Valid, Delay Cycles 4") ;
            SetAxi4Options(ManagerRec, ReadyDelayCycleOption, 4) ;
            SetAxi4Options(ManagerRec, ReadyBeforeValidOption, TRUE) ;
          when 4 => 
            log(TbManagerID, "Ready Before Valid, Delay Cycles 4") ;
            SetAxi4Options(ManagerRec, ReadyDelayCycleOption, 4) ;
            SetAxi4Options(ManagerRec, ReadyBeforeValidOption, TRUE) ;
          when 5 => 
            log(TbManagerID, "Ready Before Valid, Delay Cycles 0") ;
            SetAxi4Options(ManagerRec, ReadyDelayCycleOption, 0) ;
            SetAxi4Options(ManagerRec, ReadyBeforeValidOption, TRUE) ;
          when others => 
            Alert(TbManagerID, "Unimplemented test case", FAILURE)  ; 
        end case ; 
        increment(TransactionCount) ;
        WaitForClock(ManagerRec, 4) ; 
        -- Allow settings to update
        Write(ManagerRec,     X"0000_0000", X"0000_0000" + k*16 + j) ;
        ReadCheck(ManagerRec, X"0000_0000", X"0000_0000" + k*16 + j) ;
        WaitForClock(ManagerRec, 12) ; 

        Addr := X"0000_0000" + k*256 + j*16 ; 
        Data := X"0000_0000" + k*256 + j*16 ; 
--        if k /= 2 then 
        log(TbManagerID, "ManagerRec, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
        WriteAsync(ManagerRec, Addr,    Data) ;
        if j = 4 then WaitForClock(ManagerRec, 6) ;  end if ; 
        WriteAsync(ManagerRec, Addr+4,  Data+1) ;
        if j = 4 then WaitForClock(ManagerRec, 6) ;  end if ; 
        WriteAsync(ManagerRec, Addr+8,  Data+2) ;
        if j = 4 then WaitForClock(ManagerRec, 6) ;  end if ; 
        WriteAsync(ManagerRec, Addr+12, Data+3) ;
--          WaitForClock(ManagerRec, 16) ; 
        WaitForTransaction(ManagerRec) ;
        WaitForClock(ManagerRec, 4) ; 
--        else
        log(TbManagerID, "ManagerRec, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
        ReadAddressAsync(ManagerRec, Addr) ;
        if j = 4 then WaitForClock(ManagerRec, 6) ;  end if ; 
        ReadAddressAsync(ManagerRec, Addr+4) ;
        if j = 4 then WaitForClock(ManagerRec, 6) ;  end if ; 
        ReadAddressAsync(ManagerRec, Addr+8) ;
        if j = 4 then WaitForClock(ManagerRec, 6) ;  end if ; 
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
    -- Memory repsonder does nothing active during this test
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;

end ReadyTimingManager ;

Configuration TbAxi4_ReadyTimingManager of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ReadyTimingManager) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_ReadyTimingManager ; 
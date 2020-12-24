--
--  File Name:         TbAxi4_ValidTimingMaster.vhd
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

architecture ValidTimingMaster of TestCtrl is

  signal TestDone, MemorySync : integer_barrier := 1 ;
  signal TbMasterID : AlertLogIDType ; 
  signal TbResponderID  : AlertLogIDType ; 
  signal TransactionCount : integer := 0 ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_ValidTimingMaster") ;
    TbMasterID <= GetAlertLogID("TB Master Proc") ;
    TbResponderID <= GetAlertLogID("TB Responder Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_ValidTimingMaster.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_ValidTimingMaster.txt", "../sim_shared/validated_results/TbAxi4_ValidTimingMaster.txt", "") ; 
    
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
    WaitForClock(MasterRec, 3) ; 
    
    -- Check Defaults
    GetAxi4Options(MasterRec, WRITE_ADDRESS_VALID_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbMasterID, IntOption, 0, "WRITE_ADDRESS_VALID_DELAY_CYCLES") ;

    GetAxi4Options(MasterRec, WRITE_DATA_VALID_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbMasterID, IntOption, 0, "WRITE_DATA_VALID_DELAY_CYCLES") ;

    GetAxi4Options(MasterRec, READ_ADDRESS_VALID_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbMasterID, IntOption, 0, "READ_ADDRESS_VALID_DELAY_CYCLES") ;


    for k in 0 to 2 loop 
      case k is 
        when 0 => 
          log(TbMasterID, "Write Address") ;
          ValidDelayCycleOption  := WRITE_ADDRESS_VALID_DELAY_CYCLES ;
        when 1 => 
          log(TbMasterID, "Write Data") ;
          ValidDelayCycleOption  := WRITE_DATA_VALID_DELAY_CYCLES ;
        when 2 => 
          log(TbMasterID, "Read Address") ;
          ValidDelayCycleOption  := READ_ADDRESS_VALID_DELAY_CYCLES ;
        when others => 
          alert("K Loop Index Out of Range", FAILURE) ;
      end case ; 
      for j in 0 to 4 loop 
        case j is 
          when 0 => 
            log(TbMasterID, "Valid Delay Cycles Default 0") ;
          when 1 => 
            log(TbMasterID, "Valid Delay Cycles 2") ;
            SetAxi4Options(MasterRec, ValidDelayCycleOption, 2) ;
          when 2 => 
            log(TbMasterID, "Valid Delay Cycles 4") ;
            SetAxi4Options(MasterRec, ValidDelayCycleOption, 4) ;
          when 3 => 
            log(TbMasterID, "Valid Delay Cycles 6") ;
            SetAxi4Options(MasterRec, ValidDelayCycleOption, 6) ;
          when 4 => 
            log(TbMasterID, "Valid Delay Cycles 0") ;
            SetAxi4Options(MasterRec, ValidDelayCycleOption, 0) ;
          when others => 
            Alert(TbMasterID, "Unimplemented test case", FAILURE)  ; 
        end case ; 
        increment(TransactionCount) ;
        WaitForClock(MasterRec, 4) ; 
        Addr := X"0000_0000" + k*256 + j*16 ; 
        Data := X"0000_0000" + k*256 + j*16 ; 
--        if k /= 2 then 
        log(TbMasterID, "MasterRec, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
        WriteAsync(MasterRec, Addr,    Data) ;
        WriteAsync(MasterRec, Addr+4,  Data+1) ;
        WriteAsync(MasterRec, Addr+8,  Data+2) ;
        WriteAsync(MasterRec, Addr+12, Data+3) ;
--          WaitForClock(MasterRec, 16) ; 
        WaitForTransaction(MasterRec) ;
        WaitForClock(MasterRec, 4) ; 
--        else
        log(TbMasterID, "MasterRec, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
        ReadAddressAsync(MasterRec, Addr) ;
        ReadAddressAsync(MasterRec, Addr+4) ;
        ReadAddressAsync(MasterRec, Addr+8) ;
        ReadAddressAsync(MasterRec, Addr+12) ;
        ReadCheckData(MasterRec, Data) ;
        ReadCheckData(MasterRec, Data+1) ;
        ReadCheckData(MasterRec, Data+2) ;
        ReadCheckData(MasterRec, Data+3) ;
        WaitForClock(MasterRec, 4) ; 
--        end if ; 
--        WaitForBarrier(MemorySync) ;
        print("") ; print("") ;
      end loop ; 
    end loop ; 

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
    -- Memory responder does nothing active during this test
    WaitForBarrier(TestDone) ;
    wait ;
  end process ResponderProc ;

end ValidTimingMaster ;

Configuration TbAxi4_ValidTimingMaster of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ValidTimingMaster) ; 
    end for ; 
    for Responder_1 : Axi4Responder 
      use entity OSVVM_AXI4.Axi4Memory ; 
    end for ; 
  end for ; 
end TbAxi4_ValidTimingMaster ; 
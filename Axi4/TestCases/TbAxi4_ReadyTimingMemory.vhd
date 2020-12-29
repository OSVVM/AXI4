--
--  File Name:         TbAxi4_ReadyTimingMemory.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--    WRITE_ADDRESS, WRITE_DATA & READ_ ADDRESS
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

architecture ReadyTimingMemory of TestCtrl is

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
    SetAlertLogName("TbAxi4_ReadyTimingMemory") ;
    TbMasterID <= GetAlertLogID("TB Master Proc") ;
    TbResponderID <= GetAlertLogID("TB Responder Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_ReadyTimingMemory.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_ReadyTimingMemory.txt", "../sim_shared/validated_results/TbAxi4_ReadyTimingMemory.txt", "") ; 
    
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
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
  begin
    wait until nReset = '1' ;  
    WaitForClock(MasterRec, 4) ; 
    -- Do 6 sets of 4 write operations
    for k in 0 to 2 loop 
      for j in 0 to 5 loop 
        WaitForClock(MasterRec, 4) ; 
        -- Allow settings to update
        Write(MasterRec,     X"0000_0000", X"0000_0000" + k*16 + j) ;
        ReadCheck(MasterRec, X"0000_0000", X"0000_0000" + k*16 + j) ;
        WaitForClock(MasterRec, 12) ; 

        Addr := X"0000_0000" + k*256 + j*16 ; 
        Data := X"0000_0000" + k*256 + j*16 ; 
--        if k /= 2 then 
        log(TbMasterID, "MasterRec, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
        WriteAsync(MasterRec, Addr,    Data) ;
        if j = 4 then WaitForClock(MasterRec, 6) ;  end if ; 
        WriteAsync(MasterRec, Addr+4,  Data+1) ;
        if j = 4 then WaitForClock(MasterRec, 6) ;  end if ; 
        WriteAsync(MasterRec, Addr+8,  Data+2) ;
        if j = 4 then WaitForClock(MasterRec, 6) ;  end if ; 
        WriteAsync(MasterRec, Addr+12, Data+3) ;
--          WaitForClock(MasterRec, 16) ; 
        WaitForTransaction(MasterRec) ;
        WaitForClock(MasterRec, 4) ; 
--        else
        log(TbMasterID, "MasterRec, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
        ReadAddressAsync(MasterRec, Addr) ;
        if j = 4 then WaitForClock(MasterRec, 6) ;  end if ; 
        ReadAddressAsync(MasterRec, Addr+4) ;
        if j = 4 then WaitForClock(MasterRec, 6) ;  end if ; 
        ReadAddressAsync(MasterRec, Addr+8) ;
        if j = 4 then WaitForClock(MasterRec, 6) ;  end if ; 
        ReadAddressAsync(MasterRec, Addr+12) ;
        ReadCheckData(MasterRec, Data) ;
        ReadCheckData(MasterRec, Data+1) ;
        ReadCheckData(MasterRec, Data+2) ;
        ReadCheckData(MasterRec, Data+3) ;
        WaitForClock(MasterRec, 4) ; 
--        end if ; 
        WaitForBarrier(MemorySync) ;
      end loop ; 
    end loop ; 


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(MasterRec, 4) ;  
    WaitForBarrier(TestDone) ;
    wait ;
  end process MasterProc ;


  ------------------------------------------------------------
  -- MemoryProc
  --   Generate transactions for AxiResponder
  ------------------------------------------------------------
  MemoryProc : process
    variable Addr, ExpAddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data, ExpData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;  
    variable ReadyDelayCycleOption, ReadyBeforeValidOption : Axi4OptionsType ; 
    variable IntOption  : integer ; 
    variable BoolOption : boolean ; 
  begin
    -- Must set Responder options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 
    WaitForClock(ResponderRec, 3) ; 
    
    -- Check Defaults
    GetAxi4Options(ResponderRec, WRITE_ADDRESS_READY_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbResponderID, IntOption, 0, "WRITE_ADDRESS_READY_DELAY_CYCLES") ;
    GetAxi4Options(ResponderRec, WRITE_ADDRESS_READY_BEFORE_VALID, BoolOption) ;
    AffirmIfEqual(TbResponderID, BoolOption, TRUE, "WRITE_ADDRESS_READY_BEFORE_VALID") ;

    GetAxi4Options(ResponderRec, WRITE_DATA_READY_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbResponderID, IntOption, 0, "WRITE_DATA_READY_DELAY_CYCLES") ;
    GetAxi4Options(ResponderRec, WRITE_DATA_READY_BEFORE_VALID, BoolOption) ;
    AffirmIfEqual(TbResponderID, BoolOption, TRUE, "WRITE_DATA_READY_BEFORE_VALID") ;

    GetAxi4Options(ResponderRec, READ_ADDRESS_READY_DELAY_CYCLES, IntOption) ;
    AffirmIfEqual(TbResponderID, IntOption, 0, "READ_ADDRESS_READY_DELAY_CYCLES") ;
    GetAxi4Options(ResponderRec, READ_ADDRESS_READY_BEFORE_VALID, BoolOption) ;
    AffirmIfEqual(TbResponderID, BoolOption, TRUE, "READ_ADDRESS_READY_BEFORE_VALID") ;

    for k in 0 to 2 loop 
      case k is 
        when 0 => 
          log(TbResponderID, "Write Address") ;
          ReadyDelayCycleOption  := WRITE_ADDRESS_READY_DELAY_CYCLES ;
          ReadyBeforeValidOption := WRITE_ADDRESS_READY_BEFORE_VALID ;
        when 1 => 
          log(TbResponderID, "Write Data") ;
          ReadyDelayCycleOption  := WRITE_DATA_READY_DELAY_CYCLES ;
          ReadyBeforeValidOption := WRITE_DATA_READY_BEFORE_VALID ;
        when 2 => 
          log(TbResponderID, "Read Address") ;
          ReadyDelayCycleOption  := READ_ADDRESS_READY_DELAY_CYCLES ;
          ReadyBeforeValidOption := READ_ADDRESS_READY_BEFORE_VALID ;       
        when others => 
          alert("K Loop Index Out of Range", FAILURE) ;
      end case ; 
      for j in 0 to 5 loop 
        case j is 
          when 0 => 
            log(TbResponderID, "Valid Before Ready, Delay Cycles 0") ;
            SetAxi4Options(ResponderRec, ReadyDelayCycleOption, 0) ;
            SetAxi4Options(ResponderRec, ReadyBeforeValidOption, FALSE) ;
          when 1 => 
            log(TbResponderID, "Valid Before Ready, Delay Cycles 2") ;
            SetAxi4Options(ResponderRec, ReadyDelayCycleOption, 2) ;
            SetAxi4Options(ResponderRec, ReadyBeforeValidOption, FALSE) ;
          when 2 => 
            log(TbResponderID, "Valid Before Ready, Delay Cycles 4") ;
            SetAxi4Options(ResponderRec, ReadyDelayCycleOption, 4) ;
            SetAxi4Options(ResponderRec, ReadyBeforeValidOption, FALSE) ;
          when 3 => 
            log(TbResponderID, "Ready Before Valid, Delay Cycles 4") ;
            SetAxi4Options(ResponderRec, ReadyDelayCycleOption, 4) ;
            SetAxi4Options(ResponderRec, ReadyBeforeValidOption, TRUE) ;
          when 4 => 
            log(TbResponderID, "Ready Before Valid, Delay Cycles 4") ;
            SetAxi4Options(ResponderRec, ReadyDelayCycleOption, 4) ;
            SetAxi4Options(ResponderRec, ReadyBeforeValidOption, TRUE) ;
          when 5 => 
            log(TbResponderID, "Ready Before Valid, Delay Cycles 0") ;
            SetAxi4Options(ResponderRec, ReadyDelayCycleOption, 0) ;
            SetAxi4Options(ResponderRec, ReadyBeforeValidOption, TRUE) ;
          when others => 
            Alert(TbResponderID, "Unimplemented test case", FAILURE)  ; 
        end case ; 
        increment(TransactionCount) ;
--        -- Check Set of 4 Data items      
--        for i in 0 to 3 loop 
--          ExpAddr := X"0000_0000" + k*256 + j*16 + i*4 ; 
--          ExpData := X"0000_0000" + k*256 + j*16 + i ; 
--          if k /= 2 then 
--            GetWrite(ResponderRec, Addr, Data) ;
--            AffirmIfEqual(TbResponderID, Addr, ExpAddr, "Responder Write Addr: ") ;
--            AffirmIfEqual(TbResponderID, Data, ExpData, "Responder Write Data: ") ;
--          else
--            SendRead(ResponderRec, Addr, ExpData) ;
--            AffirmIfEqual(TbResponderID, Addr, ExpAddr, "Responder Read Addr: ") ;
--          end if ; 
--        end loop ; 
--        WaitForClock(ResponderRec, 8) ;  
        WaitForBarrier(MemorySync) ;
        print("") ; print("") ;
      end loop ; 
    end loop ; 


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ResponderRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MemoryProc ;


end ReadyTimingMemory ;

Configuration TbAxi4_ReadyTimingMemory of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ReadyTimingMemory) ; 
    end for ; 
--!!    for Responder_1 : Axi4Responder 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_ReadyTimingMemory ; 
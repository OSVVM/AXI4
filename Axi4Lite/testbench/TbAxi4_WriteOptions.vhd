--
--  File Name:         TbAxi4_WriteOptions.vhd
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
--    05/2018   2018       Initial revision
--    01/2020   2020.01    Updated license notice
--    12/2020   2020.12    Updated signal and port names
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

architecture WriteOptions of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
  signal TbMasterID : AlertLogIDType ; 
  signal TbResponderID  : AlertLogIDType ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_WriteOptions") ;
    TbMasterID <= GetAlertLogID("TB Master Proc") ;
    TbResponderID <= GetAlertLogID("TB Responder Proc") ;
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_WriteOptions.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_WriteOptions.txt", "../sim_shared/validated_results/TbAxi4_WriteOptions.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
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
    WaitForClock(ManagerRec, 4) ; 
    -- Do 6 sets of 4 write operations
    for j in 0 to 5 loop 
      Addr := X"0000_0000" + j*16 ; 
      Data := X"0000_0000" + j*16 ; 
      log(TbMasterID, "ManagerRec, Addr: " & to_hstring(Addr) & ",  Data: " & to_hstring(Data)) ; 
      Write(ManagerRec, Addr,    Data) ;
      if j = 4 then WaitForClock(ManagerRec, 6) ;  end if ; 
      Write(ManagerRec, Addr+4,  Data+1) ;
      if j = 4 then WaitForClock(ManagerRec, 6) ;  end if ; 
      Write(ManagerRec, Addr+8,  Data+2) ;
      if j = 4 then WaitForClock(ManagerRec, 6) ;  end if ; 
      Write(ManagerRec, Addr+12, Data+3) ;
      WaitForClock(ManagerRec, 16) ; 
    end loop ; 


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 4) ;  
    WaitForBarrier(TestDone) ;
    wait ;
  end process MasterProc ;


  ------------------------------------------------------------
  -- ResponderProc
  --   Generate transactions for AxiResponder
  ------------------------------------------------------------
  ResponderProc : process
    variable Addr, ExpAddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data, ExpData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    -- Must set Responder options before start otherwise, ready will be active on first cycle.
    wait for 0 ns ; 
    WaitForClock(SubordinateRec, 2) ; 

    for j in 0 to 5 loop 
      case j is 
        when 0 => 
          log(TbResponderID, "Write Address:  Valid Before Ready, Delay Cycles 0") ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 0) ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, FALSE) ;
        when 1 => 
          log(TbResponderID, "Write Address:  Valid Before Ready, Delay Cycles 2") ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 2) ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, FALSE) ;
        when 2 => 
          log(TbResponderID, "Write Address:  Valid Before Ready, Delay Cycles 4") ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 4) ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, FALSE) ;
        when 3 => 
          log(TbResponderID, "Write Address:  Ready Before Valid, Delay Cycles 4") ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 4) ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, TRUE) ;
        when 4 => 
          log(TbResponderID, "Write Address:  Ready Before Valid, Delay Cycles 4") ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 4) ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, TRUE) ;
        when 5 => 
          log(TbResponderID, "Write Address:  Ready Before Valid, Delay Cycles 0") ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 0) ;
          SetAxi4Options(SubordinateRec, WRITE_ADDRESS_READY_BEFORE_VALID, TRUE) ;
        when others => Alert(TbResponderID, "Unimplemented test case", FAILURE)  ; 
      end case ; 
      -- Check Set of 4 Data items      
      for i in 0 to 3 loop 
        ExpAddr := X"0000_0000" + j*16 + i*4; 
        ExpData := X"0000_0000" + j*16 + i ; 
        GetWrite(SubordinateRec, Addr, Data) ;
        AffirmIfEqual(TbResponderID, Addr, ExpAddr, "Responder Write Addr: ") ;
        AffirmIfEqual(TbResponderID, Data, ExpData, "Responder Write Data: ") ;
      end loop ; 
      WaitForClock(SubordinateRec, 8) ;  
      print("") ; print("") ;
    end loop ; 


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ResponderProc ;


end WriteOptions ;

Configuration TbAxi4_WriteOptions of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(WriteOptions) ; 
    end for ; 
  end for ; 
end TbAxi4_WriteOptions ; 
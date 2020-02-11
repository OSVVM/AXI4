--
--  File Name:         TbAxi4Lite_TimeOut.vhd
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

architecture TimeOut of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
  signal TestPhaseStart : integer_barrier := 1 ;
  signal TbMasterID : AlertLogIDType ; 
  signal TbSlaveID  : AlertLogIDType ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4Lite_TimeOut") ;
    TbMasterID <= GetAlertLogID("TB Master Proc") ;
    TbSlaveID  <= GetAlertLogID("TB Slave Proc") ;
    SetLogEnable(PASSED, TRUE) ;      -- Enable PASSED logs
    SetLogEnable(INFO,   TRUE) ;      -- Enable INFO logs
    SetLogEnable(DEBUG,  TRUE) ;      -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    SetAlertLogJustify ;
    TranscriptOpen("./results/TbAxi4Lite_TimeOut.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;
    SetAlertStopCount(FAILURE, integer'right) ;  -- Allow up to 2 FAILURES

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4Lite_TimeOut.txt", "../sim_shared/validated_results/TbAxi4Lite_TimeOut.txt", "") ; 
    
    print("") ;
    ReportAlerts(ExternalErrors => (FAILURE => -10, ERROR => -4, WARNING => 0)) ; 
    print("") ;
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- AxiMasterProc
  --   Generate transactions for AxiMaster
  ------------------------------------------------------------
  AxiMasterProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable ReadData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
  begin
    wait until nReset = '1' ;  
    NoOp(AxiMasterTransRec, 2) ; 
    
    WaitForBarrier(TestPhaseStart) ;
log(TbMasterID, "Write Address Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    NoOp(AxiMasterTransRec, 2) ;  -- Allow Model Options to Set.
    MasterWrite(AxiMasterTransRec, X"0001_0010",  X"0001_0010") ;  -- Pass
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, WRITE_ADDRESS_READY_TIME_OUT, 5) ;
    MasterWrite(AxiMasterTransRec, X"BAD0_0010",  X"BAD0_0010") ;  -- Write Address Fail
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, WRITE_ADDRESS_READY_TIME_OUT, 10) ;
    MasterWrite(AxiMasterTransRec, X"0002_0020",  X"0002_0020") ;  -- Pass
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, WRITE_ADDRESS_READY_TIME_OUT, 5) ;
    MasterWrite(AxiMasterTransRec, X"BAD0_0020",  X"BAD0_0020") ;  -- Write Address Fail
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, WRITE_ADDRESS_READY_TIME_OUT, 25) ;
    MasterWrite(AxiMasterTransRec, X"0003_0030",  X"0003_0030") ;  -- Pass
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    
    WaitForBarrier(TestPhaseStart) ;
    
    ReportNonZeroAlerts ;
    -- TestPhaseErrors := TestPhaseErrors + GetAlertCount - 2 ; -- Factor out expected errors
    -- ClearAlerts ;
    -- SetAlertStopCount(FAILURE, 2) ;  -- Allow up to 2 FAILURES
    print("") ;  print("") ;  
    
 log(TbMasterID, "Write DATA Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    NoOp(AxiMasterTransRec, 2) ;  -- Allow model options to set.
    MasterWrite(AxiMasterTransRec, X"0001_0110",  X"0001_0110") ;  -- Pass
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  

    SetModelOptions(AxiMasterTransRec, WRITE_DATA_READY_TIME_OUT, 5) ;
    MasterWrite(AxiMasterTransRec, X"BAD0_0110",  X"BAD0_0110") ;  -- Write Data Fail
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, WRITE_DATA_READY_TIME_OUT, 10) ;
    MasterWrite(AxiMasterTransRec, X"0002_0120",  X"0002_0120") ;  -- Pass
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, WRITE_DATA_READY_TIME_OUT, 5) ;
    MasterWrite(AxiMasterTransRec, X"BAD0_0120",  X"BAD0_0120") ;  -- Write DATA Fail
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, WRITE_DATA_READY_TIME_OUT, 25) ;
    MasterWrite(AxiMasterTransRec, X"0003_0130",  X"0003_0130") ;  -- Pass
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  


    ReportNonZeroAlerts ;
    print("") ;  print("") ;  
    
WaitForBarrier(TestPhaseStart) ;
log(TbMasterID, "Write Response Ready TimeOut test.  Trigger Ready TimeOut twice.") ;

    SetModelOptions(AxiMasterTransRec, WRITE_RESPONSE_READY_DELAY_CYCLES, 7) ;
    SetModelOptions(AxiMasterTransRec, WRITE_RESPONSE_READY_BEFORE_VALID, FALSE) ;

    NoOp(AxiMasterTransRec, 2) ;  -- Allow model options to set.
    MasterWrite(AxiMasterTransRec, X"0001_0210",  X"0001_0210") ;  -- Pass
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  

    MasterWrite(AxiMasterTransRec, X"BAD0_0210",  X"BAD0_0210") ;  -- Write Data Fail
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    MasterWrite(AxiMasterTransRec, X"0002_0220",  X"0002_0220") ;  -- Pass
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    MasterWrite(AxiMasterTransRec, X"BAD0_0220",  X"BAD0_0220") ;  -- Write DATA Fail
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, WRITE_RESPONSE_READY_DELAY_CYCLES, 0) ;
    SetModelOptions(AxiMasterTransRec, WRITE_RESPONSE_READY_BEFORE_VALID, FALSE) ;

    SetModelOptions(AxiMasterTransRec, WRITE_DATA_READY_TIME_OUT, 25) ;
    MasterWrite(AxiMasterTransRec, X"0003_0230",  X"0003_0230") ;  -- Pass
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  

    ReportNonZeroAlerts ;
    print("") ;  print("") ;  
    
WaitForBarrier(TestPhaseStart) ;
log(TbMasterID, "Read Address Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    NoOp(AxiMasterTransRec, 2) ;  -- Allow Model Options to Set.
    MasterRead(AxiMasterTransRec, X"0001_0010",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0001_0010", "AXI Master Read Data: ") ;
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, READ_ADDRESS_READY_TIME_OUT, 5) ;
    MasterRead(AxiMasterTransRec, X"BAD0_0010",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbMasterID, ReadData, X"BAD0_0010", "AXI Master Read Data: ") ;
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, READ_ADDRESS_READY_TIME_OUT, 10) ;
    MasterRead(AxiMasterTransRec, X"0002_0020",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0002_0020", "AXI Master Read Data: ") ;
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, READ_ADDRESS_READY_TIME_OUT, 5) ;
    MasterRead(AxiMasterTransRec, X"BAD0_0020",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbMasterID, ReadData, X"BAD0_0020", "AXI Master Read Data: ") ;
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, READ_ADDRESS_READY_TIME_OUT, 25) ;
    MasterRead(AxiMasterTransRec, X"0003_0030",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0003_0030", "AXI Master Read Data: ") ;
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    ReportNonZeroAlerts ;
    print("") ;  print("") ;  
    
    
WaitForBarrier(TestPhaseStart) ;
log(TbMasterID, "Read Data Ready TimeOut test.  Trigger Ready TimeOut twice.") ;
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiMasterTransRec, READ_DATA_READY_DELAY_CYCLES, 7) ;
    SetModelOptions(AxiMasterTransRec, READ_DATA_READY_BEFORE_VALID, FALSE) ;

    NoOp(AxiMasterTransRec, 2) ;  -- Allow Model Options to Set.
    MasterRead(AxiMasterTransRec, X"0001_0010",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0001_0010", "AXI Master Read Data: ") ;
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    MasterRead(AxiMasterTransRec, X"BAD0_0010",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbMasterID, ReadData, not(X"BAD0_0010"), "AXI Master Read Data: ") ;
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    MasterRead(AxiMasterTransRec, X"0002_0020",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0002_0020", "AXI Master Read Data: ") ;
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    MasterRead(AxiMasterTransRec, X"BAD0_0020",  ReadData) ;  -- Read Address Fail
    AffirmIfEqual(TbMasterID, ReadData, not(X"BAD0_0020"), "AXI Master Read Data: ") ;
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    SetModelOptions(AxiMasterTransRec, READ_DATA_READY_DELAY_CYCLES, 0) ;
    SetModelOptions(AxiMasterTransRec, READ_DATA_READY_BEFORE_VALID, TRUE) ;

    MasterRead(AxiMasterTransRec, X"0003_0030",  ReadData) ;  -- Pass
    AffirmIfEqual(TbMasterID, ReadData, X"0003_0030", "AXI Master Read Data: ") ;
    NoOp(AxiMasterTransRec, 10) ; 
    print("") ;  print("") ;  
    
    
    ReportNonZeroAlerts ;
    -- TestPhaseErrors := TestPhaseErrors + GetAlertCount - 2 ; -- Factor out expected errors
    -- ClearAlerts ;
    -- SetAlertStopCount(FAILURE, 2) ;  -- Allow up to 2 FAILURES
    print("") ;  print("") ;  
    

--! TODO move these to the appropriate test.
--!      Must prove that each of these settings impacts the intended item
--       Setting all at the beginning can hide issues.
--       There is a delay of one cycle before these are effective, so it requires
--       One "practice cycle" before doing the test cycles  
--    SetModelOptions(AxiMasterTransRec, READ_DATA_READY_DELAY_CYCLES, 7) ;
--    SetModelOptions(AxiMasterTransRec, READ_DATA_READY_BEFORE_VALID, FALSE) ;

    
    -- Wait for outputs to propagate and signal TestDone
    NoOp(AxiMasterTransRec, 20) ;  
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiMasterProc ;


  ------------------------------------------------------------
  -- AxiSlaveProc
  --   Generate transactions for AxiSlave
  ------------------------------------------------------------
  AxiSlaveProc : process
    variable Addr, ExpAddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data, ExpData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    -- Must set slave options before start otherwise, ready will be active on first cycle.
    
    -- test preparation
    
-- Start test phase 1:  Write Address
WaitForBarrier(TestPhaseStart) ;
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiSlaveTransRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 7) ;
    SetModelOptions(AxiSlaveTransRec, WRITE_ADDRESS_READY_BEFORE_VALID, FALSE) ;

    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Pass.  Ready Delay still = 0.
    AffirmIfEqual(TbSlaveID, Addr, X"0001_0010", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0001_0010", "Slave Write Data: ") ;

    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbSlaveID, Addr, X"BAD0_0011", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"BAD0_0010", "Slave Write Data: ") ;
    
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ; -- Pass
    AffirmIfEqual(TbSlaveID, Addr, X"0002_0020", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0002_0020", "Slave Write Data: ") ;
    
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbSlaveID, Addr, X"BAD0_0021", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"BAD0_0020", "Slave Write Data: ") ;
    
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiSlaveTransRec, WRITE_ADDRESS_READY_DELAY_CYCLES, 0) ;
    SetModelOptions(AxiSlaveTransRec, WRITE_ADDRESS_READY_BEFORE_VALID, TRUE) ;

    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Pass
    AffirmIfEqual(TbSlaveID, Addr, X"0003_0030", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0003_0030", "Slave Write Data: ") ;
    

-- Start test phase 2:  Write Data
WaitForBarrier(TestPhaseStart) ;

    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiSlaveTransRec, WRITE_DATA_READY_DELAY_CYCLES, 7) ;
    SetModelOptions(AxiSlaveTransRec, WRITE_DATA_READY_BEFORE_VALID, FALSE) ;

    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Pass.  Ready Delay still = 0.
    AffirmIfEqual(TbSlaveID, Addr, X"0001_0110", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0001_0110", "Slave Write Data: ") ;

    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbSlaveID, Addr, X"BAD0_0110", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, not(X"BAD0_0110"), "Slave Write Data: ") ;
    
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ; -- Pass
    AffirmIfEqual(TbSlaveID, Addr, X"0002_0120", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0002_0120", "Slave Write Data: ") ;
    
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbSlaveID, Addr, X"BAD0_0120", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, not(X"BAD0_0120"), "Slave Write Data: ") ;
    
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiSlaveTransRec, WRITE_DATA_READY_DELAY_CYCLES, 0) ;
    SetModelOptions(AxiSlaveTransRec, WRITE_DATA_READY_BEFORE_VALID, TRUE) ;

    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Pass
    AffirmIfEqual(TbSlaveID, Addr, X"0003_0130", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0003_0130", "Slave Write Data: ") ;
    

-- Start test phase 3:  Write Response
WaitForBarrier(TestPhaseStart) ;
    
    -- Warning:  it takes one operation before these take impact
    -- SetModelOptions(AxiMasterTransRec, WRITE_RESPONSE_READY_DELAY_CYCLES, 7) ;
    -- SetModelOptions(AxiMasterTransRec, WRITE_RESPONSE_READY_BEFORE_VALID, FALSE) ;

    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Pass.  Ready Delay still = 0.
    AffirmIfEqual(TbSlaveID, Addr, X"0001_0210", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0001_0210", "Slave Write Data: ") ;

    SetModelOptions(AxiSlaveTransRec, WRITE_RESPONSE_READY_TIME_OUT, 5) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbSlaveID, Addr, X"BAD0_0210", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"BAD0_0210", "Slave Write Data: ") ;
    
    SetModelOptions(AxiSlaveTransRec, WRITE_RESPONSE_READY_TIME_OUT, 10) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ; -- Pass
    AffirmIfEqual(TbSlaveID, Addr, X"0002_0220", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0002_0220", "Slave Write Data: ") ;
    
    SetModelOptions(AxiSlaveTransRec, WRITE_RESPONSE_READY_TIME_OUT, 5) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Fail
    AffirmIfEqual(TbSlaveID, Addr, X"BAD0_0220", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"BAD0_0220", "Slave Write Data: ") ;
    
    SetModelOptions(AxiSlaveTransRec, WRITE_RESPONSE_READY_TIME_OUT, 10) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;  -- Pass
    AffirmIfEqual(TbSlaveID, Addr, X"0003_0230", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0003_0230", "Slave Write Data: ") ;
    
    
-- Start test phase 4: Read Address
WaitForBarrier(TestPhaseStart) ;
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiSlaveTransRec, READ_ADDRESS_READY_DELAY_CYCLES, 7) ;
    SetModelOptions(AxiSlaveTransRec, READ_ADDRESS_READY_BEFORE_VALID, FALSE) ;

    SlaveRead(AxiSlaveTransRec, Addr, X"0001_0010") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"0001_0010", "Slave Read Addr: ") ;

    SlaveRead(AxiSlaveTransRec, Addr, X"BAD0_0010") ; -- Fail
    AffirmIfEqual(TbSlaveID, Addr, X"BAD0_0011", "Slave Read Addr: ") ;
    
    SlaveRead(AxiSlaveTransRec, Addr, X"0002_0020") ; -- Pass
    AffirmIfEqual(TbSlaveID, Addr, X"0002_0020", "Slave Read Addr: ") ;

    SlaveRead(AxiSlaveTransRec, Addr, X"BAD0_0020") ; -- Fail
    AffirmIfEqual(TbSlaveID, Addr, X"BAD0_0021", "Slave Read Addr: ") ;
    
    -- Warning:  it takes one operation before these take impact
    SetModelOptions(AxiSlaveTransRec, READ_ADDRESS_READY_DELAY_CYCLES, 0) ;
    SetModelOptions(AxiSlaveTransRec, READ_ADDRESS_READY_BEFORE_VALID, TRUE) ;

    SlaveRead(AxiSlaveTransRec, Addr, X"0003_0030") ; -- Pass
    AffirmIfEqual(TbSlaveID, Addr, X"0003_0030", "Slave Read Addr: ") ;

-- Start test phase 5: Read Data
WaitForBarrier(TestPhaseStart) ;

    SlaveRead(AxiSlaveTransRec, Addr, X"0001_0010") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"0001_0010", "Slave Read Addr: ") ;

    SetModelOptions(AxiSlaveTransRec, READ_DATA_READY_TIME_OUT, 5) ;
    SlaveRead(AxiSlaveTransRec, Addr, X"BAD0_0010") ; -- Fail
    AffirmIfEqual(TbSlaveID, Addr, X"BAD0_0010", "Slave Read Addr: ") ;
    
    SetModelOptions(AxiSlaveTransRec, READ_DATA_READY_TIME_OUT, 10) ;
    SlaveRead(AxiSlaveTransRec, Addr, X"0002_0020") ; -- Pass
    AffirmIfEqual(TbSlaveID, Addr, X"0002_0020", "Slave Read Addr: ") ;

    SetModelOptions(AxiSlaveTransRec, READ_DATA_READY_TIME_OUT, 5) ;
    SlaveRead(AxiSlaveTransRec, Addr, X"BAD0_0020") ; -- Fail
    AffirmIfEqual(TbSlaveID, Addr, X"BAD0_0020", "Slave Read Addr: ") ;
    
    SetModelOptions(AxiSlaveTransRec, READ_DATA_READY_TIME_OUT, 25) ;
    SlaveRead(AxiSlaveTransRec, Addr, X"0003_0030") ; -- Pass
    AffirmIfEqual(Addr, X"0003_0030", "Slave Read Addr: ") ;

    
    -- Wait for outputs to propagate and signal TestDone
    NoOp(AxiSlaveTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiSlaveProc ;


end TimeOut ;

Configuration TbAxi4Lite_TimeOut of TbAxi4Lite is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(TimeOut) ; 
    end for ; 
  end for ; 
end TbAxi4Lite_TimeOut ; 
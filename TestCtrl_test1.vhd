--
--  File Name:         TestCtrl_AxiMasterSlave1.vhd
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
--    Date       Version    Description
--    09/2017:   2017       Initial revision
--
--
-- Copyright 2017 SynthWorks Design Inc
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
--
architecture Test1 of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
  constant AXI_ADDR_WIDTH : integer := 32 ; 
  constant AXI_DATA_WIDTH : integer := 32 ; 
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("Test1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/Test1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    
    TranscriptClose ; 
--    AlertIfDiff("./results/Test1.txt", "../sim_shared/validated_results/Test1.txt", "") ; 
    
    print("") ;
    ReportAlerts ; 
    print("") ;
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- AxiMasterProc
  --   Generate transactions for AxiMaster
  ------------------------------------------------------------
  AxiMasterProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
  begin
    wait until nReset = '1' ;  
    NoOp(AxiMasterTransRec, 2) ; 
    MasterWrite(AxiMasterTransRec, X"AAAA_AAAA", X"5555_5555" ) ;
    MasterRead(AxiMasterTransRec,  X"1111_1111", Data) ;
    AffirmIfEqual(Data, X"2222_2222", "Master Read Data: ") ;
    
    -- Wait for outputs to propagate and signal TestDone
    NoOp(AxiMasterTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiMasterProc ;


  ------------------------------------------------------------
  -- AxiSlaveProc
  --   Generate transactions for AxiSlave
  ------------------------------------------------------------
  AxiSlaveProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    -- Transactions
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"AAAA_AAAA", "Slave Write Addr: ") ;
    AffirmIfEqual(Data, X"5555_5555", "Slave Write Data: ") ;
    SlaveRead(AxiSlaveTransRec, Addr, X"2222_2222") ; 
    AffirmIfEqual(Addr, X"1111_1111", "Slave Read Addr: ") ;


    -- Wait for outputs to propagate and signal TestDone
    NoOp(AxiSlaveTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiSlaveProc ;


end Test1 ;

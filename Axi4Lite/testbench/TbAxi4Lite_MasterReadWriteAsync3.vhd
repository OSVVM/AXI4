--
--  File Name:         TbAxi4Lite_MasterReadWriteAsync3.vhd
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

architecture MasterReadWriteAsync3 of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
  signal TestStart : integer_barrier := 1 ;
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
    SetAlertLogName("TbAxi4Lite_MasterReadWriteAsync3") ;
    TbMasterID <= GetAlertLogID("TestCtrl: AxiMaster") ;
    TbSlaveID <= GetAlertLogID("TestCtrl: AxiSlave") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
--    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4Lite_MasterReadWriteAsync3.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;
    WaitForBarrier(TestStart, 1 ns) ; -- every process should be waiting

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4Lite_MasterReadWriteAsync3.txt", "../sim_shared/validated_results/TbAxi4Lite_MasterReadWriteAsync3.txt", "") ; 
    
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
    WaitForBarrier(TestStart) ;  -- Wait for initialization in ControlProc
    SetLogEnable(INFO, FALSE) ;    -- Enable INFO logs
    NoOp(AxiMasterTransRec, 2) ; 
    
    log(TbMasterID, "Testing 32 Bit Write Asynchronous Transaction", INFO) ;
    MasterWriteAsync(AxiMasterTransRec, X"AAAA_AAA0", X"5555_5555" ) ;
    
    NoOp(AxiMasterTransRec, 4) ; 
    blankline(1);
    
    log(TbMasterID, "Testing 32 Bit Read Address Asynchronous Transaction", INFO) ;
    MasterReadAddressAsync(AxiMasterTransRec, X"1111_1110") ;
    log(TbMasterID, "Testing 32 Bit Read Data Transaction", INFO) ;
    MasterReadData(AxiMasterTransRec, Data) ;
    AffirmIfEqual(TbMasterID, Data, X"2222_2222", "Master Read Data: ") ;
    
    NoOp(AxiMasterTransRec, 2) ; 
    blankline(2);
    
--%% ADD Your Test Code After Here:


    -- 5.2, 8 bit Writes
    log(TbMasterID, "Testing 8 Bit Write Asynchronous Transaction", INFO) ; 
    MasterWriteAsync(AxiMasterTransRec, X"AAAA_AAA0", X"11" ) ;
    MasterWriteAsync(AxiMasterTransRec, X"AAAA_AAA1", X"22" ) ;
    MasterWriteAsync(AxiMasterTransRec, X"AAAA_AAA2", X"33" ) ;
    MasterWriteAsync(AxiMasterTransRec, X"AAAA_AAA3", X"44" ) ;
    
    NoOp(AxiMasterTransRec, 8) ; 
    blankline(2);
    
    -- 5.2, 8 bit Reads
    log(TbMasterID, "Testing 8 Bit Read Address Asynchronous Transaction", INFO) ; 
    MasterReadAddressAsync(AxiMasterTransRec,  X"1111_1110") ;
    MasterReadAddressAsync(AxiMasterTransRec,  X"1111_1111") ;
    MasterReadAddressAsync(AxiMasterTransRec,  X"1111_1112") ;
    MasterReadAddressAsync(AxiMasterTransRec,  X"1111_1113") ;
    
    log(TbMasterID, "Testing 8 Bit Read Data Transaction", INFO) ; 
    MasterReadData(AxiMasterTransRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"AA", "Master Read Data: ") ;
    MasterReadData(AxiMasterTransRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"BB", "Master Read Data: ") ;
    MasterReadData(AxiMasterTransRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"CC", "Master Read Data: ") ;
    MasterReadData(AxiMasterTransRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"DD", "Master Read Data: ") ;
    
    NoOp(AxiMasterTransRec, 2) ; 
    blankline(2);
    -- SetLogEnable(INFO, FALSE) ;    -- Disable INFO logs
    

    -- 5.3, 16 bit Write Address
    log(TbMasterID, "Testing 16 Bit Write Address Asynchronous Transaction", INFO) ; 
    MasterWriteAddressAsync(AxiMasterTransRec, X"BBBB_BBB0" ) ;
    MasterWriteAddressAsync(AxiMasterTransRec, X"BBBB_BBB1" ) ;
    MasterWriteAddressAsync(AxiMasterTransRec, X"BBBB_BBB2" ) ;
    
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    NoOp(AxiMasterTransRec, 2) ; 
    blankline(2);

    -- 5.3, 16 bit Write Data
    log(TbMasterID, "Testing 16 Bit Write Data Asynchronous Transaction", INFO) ; 
    MasterWriteDataAsync(AxiMasterTransRec, X"2211" ) ;
    MasterWriteDataAsync(AxiMasterTransRec, X"01", X"33_22" ) ;
    MasterWriteDataAsync(AxiMasterTransRec, X"02", X"4433" ) ;

    blankline(2);

    -- 5.3, 16 bit Reads
    log(TbMasterID, "Testing 16 Bit Read Address Asynchronous Transaction", INFO) ; 
    MasterReadAddressAsync(AxiMasterTransRec,  X"1111_1110") ;
    MasterReadAddressAsync(AxiMasterTransRec,  X"1111_1111") ;
    MasterReadAddressAsync(AxiMasterTransRec,  X"1111_1112") ;
    
    log(TbMasterID, "Testing 16 Bit Read Data Transaction", INFO) ; 
    MasterReadData(AxiMasterTransRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(15 downto 0), X"BBAA", "Master Read Data: ") ;
    MasterReadData(AxiMasterTransRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(15 downto 0), X"CCBB", "Master Read Data: ") ;
    MasterReadData(AxiMasterTransRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(15 downto 0), X"DDCC", "Master Read Data: ") ;

    NoOp(AxiMasterTransRec, 2) ; 
    blankline(2);
    

    -- 5.4, 24 bit Write Data
    log(TbMasterID, "Testing 24 Bit Write Data Asynchronous Transaction", INFO) ;
    MasterWriteDataAsync(AxiMasterTransRec, X"33_2211" ) ;
    MasterWriteDataAsync(AxiMasterTransRec, X"01", X"4433_22" ) ;

    NoOp(AxiMasterTransRec, 1) ; 
    blankline(2);

    -- 5.4, 24 bit Write Address
    log(TbMasterID, "Testing 24 Bit Write Address Asynchronous Transaction", INFO) ;
    MasterWriteAddressAsync(AxiMasterTransRec, X"CCCC_CCC0" ) ;
    MasterWriteAddressAsync(AxiMasterTransRec, X"CCCC_CCC1" ) ;

    blankline(2);

    -- 5.3, 24 bit Reads
    log(TbMasterID, "Testing 24 Bit Read Address Asynchronous Transaction", INFO) ;
    log(TbMasterID, "MasterReadAddressAsync, Addr: 1111_1110") ;
    MasterReadAddressAsync(AxiMasterTransRec,  X"1111_1110") ;
    log(TbMasterID, "MasterReadAddressAsync, Addr: 1111_1111") ;
    MasterReadAddressAsync(AxiMasterTransRec,  X"1111_1111") ;
    log(TbMasterID, "MasterReadData, Data: CC_BBAA") ;
    MasterReadData(AxiMasterTransRec,  Data(23 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(23 downto 0), X"CC_BBAA", "Master Read Data: ") ;
    log(TbMasterID, "MasterReadData, Data: DDCC_BB") ;
    MasterReadData(AxiMasterTransRec,  Data(23 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(23 downto 0), X"DDCC_BB", "Master Read Data: ") ;
    
-- %% ADD Your Test Code Before Here

    blankline(1) ;
    ReportAlerts ; 
    print("") ;
    std.env.stop ; 


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
    NoOp(AxiSlaveTransRec, 2) ; 
    -- Write and Read with ByteAddr = 0, 4 Bytes
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;
    AffirmIfEqual(TbSlaveID, Addr, X"AAAA_AAA0", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"5555_5555", "Slave Write Data: ") ;
    
    SlaveRead(AxiSlaveTransRec, Addr, X"2222_2222") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"1111_1110", "Slave Read Addr: ") ;

    
    -- Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3
    -- MasterWrite(AxiMasterTransRec, X"AAAA_AAA0", X"11" ) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;
    AffirmIfEqual(TbSlaveID, Addr, X"AAAA_AAA0", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0000_0011", "Slave Write Data: ") ;
    -- MasterWrite(AxiMasterTransRec, X"AAAA_AAA1", X"22" ) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;
    AffirmIfEqual(TbSlaveID, Addr, X"AAAA_AAA1", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0000_2200", "Slave Write Data: ") ;
    -- MasterWrite(AxiMasterTransRec, X"AAAA_AAA2", X"33" ) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;
    AffirmIfEqual(TbSlaveID, Addr, X"AAAA_AAA2", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0033_0000", "Slave Write Data: ") ;
    -- MasterWrite(AxiMasterTransRec, X"AAAA_AAA3", X"44" ) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;
    AffirmIfEqual(TbSlaveID, Addr, X"AAAA_AAA3", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"4400_0000", "Slave Write Data: ") ;

    SlaveRead(AxiSlaveTransRec, Addr, X"0000_00AA") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"1111_1110", "Slave Read Addr: ") ;
    SlaveRead(AxiSlaveTransRec, Addr, X"0000_BB00") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"1111_1111", "Slave Read Addr: ") ;
    SlaveRead(AxiSlaveTransRec, Addr, X"00CC_0000") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"1111_1112", "Slave Read Addr: ") ;
    SlaveRead(AxiSlaveTransRec, Addr, X"DD00_0000") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"1111_1113", "Slave Read Addr: ") ;


    -- Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2
    -- MasterWrite(AxiMasterTransRec, X"BBBB_BBB0", X"2211" ) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;
    AffirmIfEqual(TbSlaveID, Addr, X"BBBB_BBB0", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0000_2211", "Slave Write Data: ") ;
    -- MasterWrite(AxiMasterTransRec, X"BBBB_BBB1", X"3322" ) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;
    AffirmIfEqual(TbSlaveID, Addr, X"BBBB_BBB1", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0033_2200", "Slave Write Data: ") ;
    -- MasterWrite(AxiMasterTransRec, X"BBBB_BBB2", X"4433" ) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;
    AffirmIfEqual(TbSlaveID, Addr, X"BBBB_BBB2", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"4433_0000", "Slave Write Data: ") ;

    SlaveRead(AxiSlaveTransRec, Addr, X"0000_BBAA") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"1111_1110", "Slave Read Addr: ") ;
    SlaveRead(AxiSlaveTransRec, Addr, X"00CC_BB00") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"1111_1111", "Slave Read Addr: ") ;
    SlaveRead(AxiSlaveTransRec, Addr, X"DDCC_0000") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"1111_1112", "Slave Read Addr: ") ;

    -- Write and Read with 3 Bytes and ByteAddr = 0. 1
    -- MasterWrite(AxiMasterTransRec, X"CCCC_CCC0", X"332211" ) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;
    AffirmIfEqual(TbSlaveID, Addr, X"CCCC_CCC0", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"0033_2211", "Slave Write Data: ") ;
    -- MasterWrite(AxiMasterTransRec, X"CCCC_CCC1", X"443322" ) ;
    SlaveGetWrite(AxiSlaveTransRec, Addr, Data) ;
    AffirmIfEqual(TbSlaveID, Addr, X"CCCC_CCC1", "Slave Write Addr: ") ;
    AffirmIfEqual(TbSlaveID, Data, X"4433_2200", "Slave Write Data: ") ;

    SlaveRead(AxiSlaveTransRec, Addr, X"00CC_BBAA") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"1111_1110", "Slave Read Addr: ") ;
    SlaveRead(AxiSlaveTransRec, Addr, X"DDCC_BB00") ; 
    AffirmIfEqual(TbSlaveID, Addr, X"1111_1111", "Slave Read Addr: ") ;


    -- Wait for outputs to propagate and signal TestDone
    NoOp(AxiSlaveTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiSlaveProc ;


end MasterReadWriteAsync3 ;

Configuration TbAxi4Lite_MasterReadWriteAsync3 of TbAxi4Lite is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MasterReadWriteAsync3) ; 
    end for ; 
  end for ; 
end TbAxi4Lite_MasterReadWriteAsync3 ; 
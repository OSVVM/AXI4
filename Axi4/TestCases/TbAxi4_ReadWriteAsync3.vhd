--
--  File Name:         TbAxi4_ReadWriteAsync3.vhd
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

architecture ReadWriteAsync3 of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
  signal TestStart : integer_barrier := 1 ;
  signal TbManagerID : AlertLogIDType ; 
  signal TbSubordinateID  : AlertLogIDType ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_ReadWriteAsync3") ;
    TbManagerID <= GetAlertLogID("TestCtrl: AxiManager") ;
    TbSubordinateID <= GetAlertLogID("TestCtrl: AxiSubordinate") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
--    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_ReadWriteAsync3.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_ReadWriteAsync3.txt", "../sim_shared/validated_results/TbAxi4_ReadWriteAsync3.txt", "") ; 
    

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- ManagerProc
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
  begin
    WaitForBarrier(TestStart) ;  -- Wait for initialization in ControlProc
    SetLogEnable(INFO, FALSE) ;    -- Enable INFO logs
    WaitForClock(ManagerRec, 2) ; 
    
    log(TbManagerID, "Testing 32 Bit Write Asynchronous Transaction", INFO) ;
    WriteAsync(ManagerRec, X"AAAA_AAA0", X"5555_5555" ) ;
    
    WaitForClock(ManagerRec, 4) ; 
    blankline(1);
    
    log(TbManagerID, "Testing 32 Bit Read Address Asynchronous Transaction", INFO) ;
    ReadAddressAsync(ManagerRec, X"1111_1110") ;
    log(TbManagerID, "Testing 32 Bit Read Data Transaction", INFO) ;
    ReadCheckData(ManagerRec, X"2222_2222") ;
    
    WaitForClock(ManagerRec, 2) ; 
    blankline(2);
    
--%% ADD Your Test Code After Here:


    -- 5.2, 8 bit Writes
    log(TbManagerID, "Testing 8 Bit Write Asynchronous Transaction", INFO) ; 
    WriteAsync(ManagerRec, X"AAAA_AAA0", X"11" ) ;
    WriteAsync(ManagerRec, X"AAAA_AAA1", X"22" ) ;
    WriteAsync(ManagerRec, X"AAAA_AAA2", X"33" ) ;
    WriteAsync(ManagerRec, X"AAAA_AAA3", X"44" ) ;
    
    WaitForClock(ManagerRec, 8) ; 
    blankline(2);
    
    -- 5.2, 8 bit Reads
    log(TbManagerID, "Testing 8 Bit Read Address Asynchronous Transaction", INFO) ; 
    ReadAddressAsync(ManagerRec,  X"1111_1110") ;
    ReadAddressAsync(ManagerRec,  X"1111_1111") ;
    ReadAddressAsync(ManagerRec,  X"1111_1112") ;
    ReadAddressAsync(ManagerRec,  X"1111_1113") ;
    
    log(TbManagerID, "Testing 8 Bit Read Data Transaction", INFO) ; 
    ReadCheckData(ManagerRec,  X"AA") ;
    ReadCheckData(ManagerRec,  X"BB") ;
    ReadCheckData(ManagerRec,  X"CC") ;
    ReadCheckData(ManagerRec,  X"DD") ;
    
    WaitForClock(ManagerRec, 2) ; 
    blankline(2);
    -- SetLogEnable(INFO, FALSE) ;    -- Disable INFO logs
    

    -- 5.3, 16 bit Write Address
    log(TbManagerID, "Testing 16 Bit Write Address Asynchronous Transaction", INFO) ; 
    WriteAddressAsync(ManagerRec, X"BBBB_BBB0" ) ;
    WriteAddressAsync(ManagerRec, X"BBBB_BBB1" ) ;
    WriteAddressAsync(ManagerRec, X"BBBB_BBB2" ) ;
    
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    WaitForClock(ManagerRec, 2) ; 
    blankline(2);

    -- 5.3, 16 bit Write Data
    log(TbManagerID, "Testing 16 Bit Write Data Asynchronous Transaction", INFO) ; 
    WriteDataAsync(ManagerRec, X"2211" ) ;
    WriteDataAsync(ManagerRec, X"01", X"33_22" ) ;
    WriteDataAsync(ManagerRec, X"02", X"4433" ) ;

    blankline(2);

    -- 5.3, 16 bit Reads
    log(TbManagerID, "Testing 16 Bit Read Address Asynchronous Transaction", INFO) ; 
    ReadAddressAsync(ManagerRec,  X"1111_1110") ;
    ReadAddressAsync(ManagerRec,  X"1111_1111") ;
    ReadAddressAsync(ManagerRec,  X"1111_1112") ;
    
    log(TbManagerID, "Testing 16 Bit Read Data Transaction", INFO) ; 
    ReadCheckData(ManagerRec,  X"BBAA") ;
    ReadCheckData(ManagerRec,  X"CCBB") ;
    ReadCheckData(ManagerRec,  X"DDCC") ;

    WaitForClock(ManagerRec, 2) ; 
    blankline(2);
    

    -- 5.4, 24 bit Write Data
    log(TbManagerID, "Testing 24 Bit Write Data Asynchronous Transaction", INFO) ;
    WriteDataAsync(ManagerRec, X"33_2211" ) ;
    WriteDataAsync(ManagerRec, X"01", X"4433_22" ) ;

    WaitForClock(ManagerRec, 1) ; 
    blankline(2);

    -- 5.4, 24 bit Write Address
    log(TbManagerID, "Testing 24 Bit Write Address Asynchronous Transaction", INFO) ;
    WriteAddressAsync(ManagerRec, X"CCCC_CCC0" ) ;
    WriteAddressAsync(ManagerRec, X"CCCC_CCC1" ) ;

    blankline(2);

    -- 5.3, 24 bit Reads
    log(TbManagerID, "Testing 24 Bit Read Address Asynchronous Transaction", INFO) ;
    log(TbManagerID, "ReadAddressAsync, Addr: 1111_1110") ;
    ReadAddressAsync(ManagerRec,  X"1111_1110") ;
    log(TbManagerID, "ReadAddressAsync, Addr: 1111_1111") ;
    ReadAddressAsync(ManagerRec,  X"1111_1111") ;
    log(TbManagerID, "ReadData, Data: CC_BBAA") ;
    ReadCheckData(ManagerRec,  X"CC_BBAA") ;
    log(TbManagerID, "ReadData, Data: DDCC_BB") ;
    ReadCheckData(ManagerRec,  X"DDCC_BB") ;
    
-- %% ADD Your Test Code Before Here

--??--    blankline(1) ;
--??--    ReportAlerts ; 
--??--    print("") ;
--??--    std.env.stop ; 


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
    WaitForClock(SubordinateRec, 2) ; 
    -- Write and Read with ByteAddr = 0, 4 Bytes
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbSubordinateID, Addr, X"AAAA_AAA0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(TbSubordinateID, Data, X"5555_5555", "Subordinate Write Data: ") ;
    
    SendRead(SubordinateRec, Addr, X"2222_2222") ; 
    AffirmIfEqual(TbSubordinateID, Addr, X"1111_1110", "Subordinate Read Addr: ") ;

    
    -- Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3
    -- Write(ManagerRec, X"AAAA_AAA0", X"11" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbSubordinateID, Addr, X"AAAA_AAA0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(TbSubordinateID, Data, X"0000_0011", "Subordinate Write Data: ") ;
    -- Write(ManagerRec, X"AAAA_AAA1", X"22" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbSubordinateID, Addr, X"AAAA_AAA1", "Subordinate Write Addr: ") ;
    AffirmIfEqual(TbSubordinateID, Data, X"0000_2200", "Subordinate Write Data: ") ;
    -- Write(ManagerRec, X"AAAA_AAA2", X"33" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbSubordinateID, Addr, X"AAAA_AAA2", "Subordinate Write Addr: ") ;
    AffirmIfEqual(TbSubordinateID, Data, X"0033_0000", "Subordinate Write Data: ") ;
    -- Write(ManagerRec, X"AAAA_AAA3", X"44" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbSubordinateID, Addr, X"AAAA_AAA3", "Subordinate Write Addr: ") ;
    AffirmIfEqual(TbSubordinateID, Data, X"4400_0000", "Subordinate Write Data: ") ;

    SendRead(SubordinateRec, Addr, X"0000_00AA") ; 
    AffirmIfEqual(TbSubordinateID, Addr, X"1111_1110", "Subordinate Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"0000_BB00") ; 
    AffirmIfEqual(TbSubordinateID, Addr, X"1111_1111", "Subordinate Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"00CC_0000") ; 
    AffirmIfEqual(TbSubordinateID, Addr, X"1111_1112", "Subordinate Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"DD00_0000") ; 
    AffirmIfEqual(TbSubordinateID, Addr, X"1111_1113", "Subordinate Read Addr: ") ;


    -- Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2
    -- Write(ManagerRec, X"BBBB_BBB0", X"2211" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbSubordinateID, Addr, X"BBBB_BBB0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(TbSubordinateID, Data, X"0000_2211", "Subordinate Write Data: ") ;
    -- Write(ManagerRec, X"BBBB_BBB1", X"3322" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbSubordinateID, Addr, X"BBBB_BBB1", "Subordinate Write Addr: ") ;
    AffirmIfEqual(TbSubordinateID, Data, X"0033_2200", "Subordinate Write Data: ") ;
    -- Write(ManagerRec, X"BBBB_BBB2", X"4433" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbSubordinateID, Addr, X"BBBB_BBB2", "Subordinate Write Addr: ") ;
    AffirmIfEqual(TbSubordinateID, Data, X"4433_0000", "Subordinate Write Data: ") ;

    SendRead(SubordinateRec, Addr, X"0000_BBAA") ; 
    AffirmIfEqual(TbSubordinateID, Addr, X"1111_1110", "Subordinate Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"00CC_BB00") ; 
    AffirmIfEqual(TbSubordinateID, Addr, X"1111_1111", "Subordinate Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"DDCC_0000") ; 
    AffirmIfEqual(TbSubordinateID, Addr, X"1111_1112", "Subordinate Read Addr: ") ;

    -- Write and Read with 3 Bytes and ByteAddr = 0. 1
    -- Write(ManagerRec, X"CCCC_CCC0", X"332211" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbSubordinateID, Addr, X"CCCC_CCC0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(TbSubordinateID, Data, X"0033_2211", "Subordinate Write Data: ") ;
    -- Write(ManagerRec, X"CCCC_CCC1", X"443322" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbSubordinateID, Addr, X"CCCC_CCC1", "Subordinate Write Addr: ") ;
    AffirmIfEqual(TbSubordinateID, Data, X"4433_2200", "Subordinate Write Data: ") ;

    SendRead(SubordinateRec, Addr, X"00CC_BBAA") ; 
    AffirmIfEqual(TbSubordinateID, Addr, X"1111_1110", "Subordinate Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"DDCC_BB00") ; 
    AffirmIfEqual(TbSubordinateID, Addr, X"1111_1111", "Subordinate Read Addr: ") ;


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;


end ReadWriteAsync3 ;

Configuration TbAxi4_ReadWriteAsync3 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ReadWriteAsync3) ; 
    end for ; 
  end for ; 
end TbAxi4_ReadWriteAsync3 ; 
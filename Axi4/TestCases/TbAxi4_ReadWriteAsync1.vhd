--
--  File Name:         TbAxi4_ReadWriteAsync1.vhd
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

architecture ReadWriteAsync1 of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
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
    SetAlertLogName("TbAxi4_ReadWriteAsync1") ;
    TbManagerID <= GetAlertLogID("TB Manager Proc") ;
    TbSubordinateID <= GetAlertLogID("TB Subordinate Proc") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
--    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_ReadWriteAsync1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4_ReadWriteAsync1.txt", "../sim_shared/validated_results/TbAxi4_ReadWriteAsync1.txt", "") ; 

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
    wait until nReset = '1' ;  
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    WaitForClock(ManagerRec, 2) ; 
    log(TbManagerID, "Write and Read with ByteAddr = 0, 4 Bytes") ;
    log(TbManagerID, "WriteAsync, Addr: AAAA_AAA0, Data: 5555_5555") ;
    WriteAsync(ManagerRec, X"AAAA_AAA0", X"5555_5555" ) ;
    WaitForClock(ManagerRec, 4) ; 

    print("") ; 
    log(TbManagerID, "ReadAddressAsync, Addr 1111_1110") ;
    ReadAddressAsync(ManagerRec, X"1111_1110") ;
    log(TbManagerID, "ReadData, Data 2222_2222") ;
    ReadData(ManagerRec, Data) ;
    AffirmIfEqual(TbManagerID, Data, X"2222_2222", "Manager Read Data: ") ;
    WaitForClock(ManagerRec, 2) ; 
    
    print("") ;     print("") ; 
    log(TbManagerID, "Write with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    log(TbManagerID, "WriteAsync,  Addr: AAAA_AAA0, Data: 11") ;
    WriteAsync(ManagerRec, X"AAAA_AAA0", X"11" ) ;
    log(TbManagerID, "WriteAsync,  Addr: AAAA_AAA1, Data: 22") ;
    WriteAsync(ManagerRec, X"AAAA_AAA1", X"22" ) ;
    log(TbManagerID, "WriteAsync,  Addr: AAAA_AAA2, Data: 33") ;
    WriteAsync(ManagerRec, X"AAAA_AAA2", X"33" ) ;
    log(TbManagerID, "WriteAsync,  Addr: AAAA_AAA3, Data: 44") ;
    WriteAsync(ManagerRec, X"AAAA_AAA3", X"44" ) ;
    WaitForClock(ManagerRec, 8) ; 
    
    print("") ; 
    log(TbManagerID, "Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    log(TbManagerID, "ReadAddressAsync, Addr: 1111_1110") ;
    ReadAddressAsync(ManagerRec,  X"1111_1110") ;
    log(TbManagerID, "ReadAddressAsync, Addr: 1111_1111") ;
    ReadAddressAsync(ManagerRec,  X"1111_1111") ;
    log(TbManagerID, "ReadAddressAsync, Addr: 1111_1112") ;
    ReadAddressAsync(ManagerRec,  X"1111_1112") ;
    log(TbManagerID, "ReadAddressAsync, Addr: 1111_1113") ;
    ReadAddressAsync(ManagerRec,  X"1111_1113") ;
    log(TbManagerID, "ReadData, Data: AA") ;
    ReadData(ManagerRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbManagerID, Data(7 downto 0), X"AA", "Manager Read Data: ") ;
    log(TbManagerID, "ReadData, Data: BB") ;
    ReadData(ManagerRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbManagerID, Data(7 downto 0), X"BB", "Manager Read Data: ") ;
    log(TbManagerID, "ReadData, Data: CC") ;
    ReadData(ManagerRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbManagerID, Data(7 downto 0), X"CC", "Manager Read Data: ") ;
    log(TbManagerID, "ReadData, Data: DD") ;
    ReadData(ManagerRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbManagerID, Data(7 downto 0), X"DD", "Manager Read Data: ") ;
    SetLogEnable(INFO, FALSE) ;    -- Disable INFO logs

    print("") ;     print("") ; 
    log(TbManagerID, "Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    log(TbManagerID, "WriteAsync,  Addr: BBBB_BBB0, Data: 2211") ;
    WriteAsync(ManagerRec, X"BBBB_BBB0", X"2211" ) ;
    log(TbManagerID, "WriteAsync,  Addr: BBBB_BBB1, Data: 33_22") ;
    WriteAsync(ManagerRec, X"BBBB_BBB1", X"33_22" ) ;
    log(TbManagerID, "WriteAsync,  Addr: BBBB_BBB2, Data: 4433") ;
    WriteAsync(ManagerRec, X"BBBB_BBB2", X"4433" ) ;

    print("") ; 
    log(TbManagerID, "ReadAddressAsync, Addr: 1111_1110") ;
    ReadAddressAsync(ManagerRec,  X"1111_1110") ;
    log(TbManagerID, "ReadAddressAsync, Addr: 1111_1111") ;
    ReadAddressAsync(ManagerRec,  X"1111_1111") ;
    log(TbManagerID, "ReadAddressAsync, Addr: 1111_1112") ;
    ReadAddressAsync(ManagerRec,  X"1111_1112") ;
    log(TbManagerID, "ReadData, Data: BBAA") ;
    ReadData(ManagerRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbManagerID, Data(15 downto 0), X"BBAA", "Manager Read Data: ") ;
    log(TbManagerID, "ReadData, Data: CCBB") ;
    ReadData(ManagerRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbManagerID, Data(15 downto 0), X"CCBB", "Manager Read Data: ") ;
    log(TbManagerID, "ReadData, Data: DDCC") ;
    ReadData(ManagerRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbManagerID, Data(15 downto 0), X"DDCC", "Manager Read Data: ") ;

    print("") ;     print("") ; 
    log(TbManagerID, "Write and Read with 3 Bytes and ByteAddr = 0. 1") ;
    log(TbManagerID, "WriteAsync,  Addr: CCCC_CCC0, Data: 33_2211") ;
    WriteAsync(ManagerRec, X"CCCC_CCC0", X"33_2211" ) ;
    log(TbManagerID, "WriteAsync,  Addr: CCCC_CCC1, Data: 4433_22") ;
    WriteAsync(ManagerRec, X"CCCC_CCC1", X"4433_22" ) ;

    print("") ; 
    log(TbManagerID, "ReadAddressAsync, Addr: 1111_1110") ;
    ReadAddressAsync(ManagerRec,  X"1111_1110") ;
    log(TbManagerID, "ReadAddressAsync, Addr: 1111_1111") ;
    ReadAddressAsync(ManagerRec,  X"1111_1111") ;
    log(TbManagerID, "ReadData, Data: CC_BBAA") ;
    ReadData(ManagerRec,  Data(23 downto 0)) ;
    AffirmIfEqual(TbManagerID, Data(23 downto 0), X"CC_BBAA", "Manager Read Data: ") ;
    log(TbManagerID, "ReadData, Data: DDCC_BB") ;
    ReadData(ManagerRec,  Data(23 downto 0)) ;
    AffirmIfEqual(TbManagerID, Data(23 downto 0), X"DDCC_BB", "Manager Read Data: ") ;
    
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


end ReadWriteAsync1 ;

Configuration TbAxi4_ReadWriteAsync1 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ReadWriteAsync1) ; 
    end for ; 
  end for ; 
end TbAxi4_ReadWriteAsync1 ; 
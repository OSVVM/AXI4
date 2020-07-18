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

architecture ReadWriteAsync1 of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
  signal TbSuperID : AlertLogIDType ; 
  signal TbMinionID  : AlertLogIDType ; 

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_ReadWriteAsync1") ;
    TbSuperID <= GetAlertLogID("TB Super Proc") ;
    TbMinionID <= GetAlertLogID("TB Minion Proc") ;
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
    
    print("") ;
    ReportAlerts ; 
    print("") ;
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- AxiSuperProc
  --   Generate transactions for AxiSuper
  ------------------------------------------------------------
  AxiSuperProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
  begin
    wait until nReset = '1' ;  
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    NoOp(AxiSuperTransRec, 2) ; 
    log(TbSuperID, "Write and Read with ByteAddr = 0, 4 Bytes") ;
    log(TbSuperID, "WriteAsync, Addr: AAAA_AAA0, Data: 5555_5555") ;
    WriteAsync(AxiSuperTransRec, X"AAAA_AAA0", X"5555_5555" ) ;
    NoOp(AxiSuperTransRec, 4) ; 

    print("") ; 
    log(TbSuperID, "ReadAddressAsync, Addr 1111_1110") ;
    ReadAddressAsync(AxiSuperTransRec, X"1111_1110") ;
    log(TbSuperID, "ReadData, Data 2222_2222") ;
    ReadData(AxiSuperTransRec, Data) ;
    AffirmIfEqual(TbSuperID, Data, X"2222_2222", "Super Read Data: ") ;
    NoOp(AxiSuperTransRec, 2) ; 
    
    print("") ;     print("") ; 
    log(TbSuperID, "Write with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    log(TbSuperID, "WriteAsync,  Addr: AAAA_AAA0, Data: 11") ;
    WriteAsync(AxiSuperTransRec, X"AAAA_AAA0", X"11" ) ;
    log(TbSuperID, "WriteAsync,  Addr: AAAA_AAA1, Data: 22") ;
    WriteAsync(AxiSuperTransRec, X"AAAA_AAA1", X"22" ) ;
    log(TbSuperID, "WriteAsync,  Addr: AAAA_AAA2, Data: 33") ;
    WriteAsync(AxiSuperTransRec, X"AAAA_AAA2", X"33" ) ;
    log(TbSuperID, "WriteAsync,  Addr: AAAA_AAA3, Data: 44") ;
    WriteAsync(AxiSuperTransRec, X"AAAA_AAA3", X"44" ) ;
    NoOp(AxiSuperTransRec, 8) ; 
    
    print("") ; 
    log(TbSuperID, "Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    log(TbSuperID, "ReadAddressAsync, Addr: 1111_1110") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1110") ;
    log(TbSuperID, "ReadAddressAsync, Addr: 1111_1111") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1111") ;
    log(TbSuperID, "ReadAddressAsync, Addr: 1111_1112") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1112") ;
    log(TbSuperID, "ReadAddressAsync, Addr: 1111_1113") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1113") ;
    log(TbSuperID, "ReadData, Data: AA") ;
    ReadData(AxiSuperTransRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbSuperID, Data(7 downto 0), X"AA", "Super Read Data: ") ;
    log(TbSuperID, "ReadData, Data: BB") ;
    ReadData(AxiSuperTransRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbSuperID, Data(7 downto 0), X"BB", "Super Read Data: ") ;
    log(TbSuperID, "ReadData, Data: CC") ;
    ReadData(AxiSuperTransRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbSuperID, Data(7 downto 0), X"CC", "Super Read Data: ") ;
    log(TbSuperID, "ReadData, Data: DD") ;
    ReadData(AxiSuperTransRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbSuperID, Data(7 downto 0), X"DD", "Super Read Data: ") ;
    SetLogEnable(INFO, FALSE) ;    -- Disable INFO logs

    print("") ;     print("") ; 
    log(TbSuperID, "Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    log(TbSuperID, "WriteAsync,  Addr: BBBB_BBB0, Data: 2211") ;
    WriteAsync(AxiSuperTransRec, X"BBBB_BBB0", X"2211" ) ;
    log(TbSuperID, "WriteAsync,  Addr: BBBB_BBB1, Data: 33_22") ;
    WriteAsync(AxiSuperTransRec, X"BBBB_BBB1", X"33_22" ) ;
    log(TbSuperID, "WriteAsync,  Addr: BBBB_BBB2, Data: 4433") ;
    WriteAsync(AxiSuperTransRec, X"BBBB_BBB2", X"4433" ) ;

    print("") ; 
    log(TbSuperID, "ReadAddressAsync, Addr: 1111_1110") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1110") ;
    log(TbSuperID, "ReadAddressAsync, Addr: 1111_1111") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1111") ;
    log(TbSuperID, "ReadAddressAsync, Addr: 1111_1112") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1112") ;
    log(TbSuperID, "ReadData, Data: BBAA") ;
    ReadData(AxiSuperTransRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbSuperID, Data(15 downto 0), X"BBAA", "Super Read Data: ") ;
    log(TbSuperID, "ReadData, Data: CCBB") ;
    ReadData(AxiSuperTransRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbSuperID, Data(15 downto 0), X"CCBB", "Super Read Data: ") ;
    log(TbSuperID, "ReadData, Data: DDCC") ;
    ReadData(AxiSuperTransRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbSuperID, Data(15 downto 0), X"DDCC", "Super Read Data: ") ;

    print("") ;     print("") ; 
    log(TbSuperID, "Write and Read with 3 Bytes and ByteAddr = 0. 1") ;
    log(TbSuperID, "WriteAsync,  Addr: CCCC_CCC0, Data: 33_2211") ;
    WriteAsync(AxiSuperTransRec, X"CCCC_CCC0", X"33_2211" ) ;
    log(TbSuperID, "WriteAsync,  Addr: CCCC_CCC1, Data: 4433_22") ;
    WriteAsync(AxiSuperTransRec, X"CCCC_CCC1", X"4433_22" ) ;

    print("") ; 
    log(TbSuperID, "ReadAddressAsync, Addr: 1111_1110") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1110") ;
    log(TbSuperID, "ReadAddressAsync, Addr: 1111_1111") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1111") ;
    log(TbSuperID, "ReadData, Data: CC_BBAA") ;
    ReadData(AxiSuperTransRec,  Data(23 downto 0)) ;
    AffirmIfEqual(TbSuperID, Data(23 downto 0), X"CC_BBAA", "Super Read Data: ") ;
    log(TbSuperID, "ReadData, Data: DDCC_BB") ;
    ReadData(AxiSuperTransRec,  Data(23 downto 0)) ;
    AffirmIfEqual(TbSuperID, Data(23 downto 0), X"DDCC_BB", "Super Read Data: ") ;
    
    -- Wait for outputs to propagate and signal TestDone
    NoOp(AxiSuperTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiSuperProc ;


  ------------------------------------------------------------
  -- AxiMinionProc
  --   Generate transactions for AxiMinion
  ------------------------------------------------------------
  AxiMinionProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    NoOp(AxiMinionTransRec, 2) ; 
    -- Write and Read with ByteAddr = 0, 4 Bytes
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(TbMinionID, Addr, X"AAAA_AAA0", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"5555_5555", "Minion Write Data: ") ;
    
    SendRead(AxiMinionTransRec, Addr, X"2222_2222") ; 
    AffirmIfEqual(TbMinionID, Addr, X"1111_1110", "Minion Read Addr: ") ;

    
    -- Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3
    -- Write(AxiSuperTransRec, X"AAAA_AAA0", X"11" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(TbMinionID, Addr, X"AAAA_AAA0", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0000_0011", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"AAAA_AAA1", X"22" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(TbMinionID, Addr, X"AAAA_AAA1", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0000_2200", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"AAAA_AAA2", X"33" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(TbMinionID, Addr, X"AAAA_AAA2", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0033_0000", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"AAAA_AAA3", X"44" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(TbMinionID, Addr, X"AAAA_AAA3", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"4400_0000", "Minion Write Data: ") ;

    SendRead(AxiMinionTransRec, Addr, X"0000_00AA") ; 
    AffirmIfEqual(TbMinionID, Addr, X"1111_1110", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"0000_BB00") ; 
    AffirmIfEqual(TbMinionID, Addr, X"1111_1111", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"00CC_0000") ; 
    AffirmIfEqual(TbMinionID, Addr, X"1111_1112", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"DD00_0000") ; 
    AffirmIfEqual(TbMinionID, Addr, X"1111_1113", "Minion Read Addr: ") ;


    -- Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2
    -- Write(AxiSuperTransRec, X"BBBB_BBB0", X"2211" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(TbMinionID, Addr, X"BBBB_BBB0", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0000_2211", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"BBBB_BBB1", X"3322" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(TbMinionID, Addr, X"BBBB_BBB1", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0033_2200", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"BBBB_BBB2", X"4433" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(TbMinionID, Addr, X"BBBB_BBB2", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"4433_0000", "Minion Write Data: ") ;

    SendRead(AxiMinionTransRec, Addr, X"0000_BBAA") ; 
    AffirmIfEqual(TbMinionID, Addr, X"1111_1110", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"00CC_BB00") ; 
    AffirmIfEqual(TbMinionID, Addr, X"1111_1111", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"DDCC_0000") ; 
    AffirmIfEqual(TbMinionID, Addr, X"1111_1112", "Minion Read Addr: ") ;

    -- Write and Read with 3 Bytes and ByteAddr = 0. 1
    -- Write(AxiSuperTransRec, X"CCCC_CCC0", X"332211" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(TbMinionID, Addr, X"CCCC_CCC0", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"0033_2211", "Minion Write Data: ") ;
    -- Write(AxiSuperTransRec, X"CCCC_CCC1", X"443322" ) ;
    GetWrite(AxiMinionTransRec, Addr, Data) ;
    AffirmIfEqual(TbMinionID, Addr, X"CCCC_CCC1", "Minion Write Addr: ") ;
    AffirmIfEqual(TbMinionID, Data, X"4433_2200", "Minion Write Data: ") ;

    SendRead(AxiMinionTransRec, Addr, X"00CC_BBAA") ; 
    AffirmIfEqual(TbMinionID, Addr, X"1111_1110", "Minion Read Addr: ") ;
    SendRead(AxiMinionTransRec, Addr, X"DDCC_BB00") ; 
    AffirmIfEqual(TbMinionID, Addr, X"1111_1111", "Minion Read Addr: ") ;


    -- Wait for outputs to propagate and signal TestDone
    NoOp(AxiMinionTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiMinionProc ;


end ReadWriteAsync1 ;

Configuration TbAxi4_ReadWriteAsync1 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ReadWriteAsync1) ; 
    end for ; 
  end for ; 
end TbAxi4_ReadWriteAsync1 ; 
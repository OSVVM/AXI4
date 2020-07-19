--
--  File Name:         TbAxi4_ReadWriteAsync2.vhd
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

architecture ReadWriteAsync2 of TestCtrl is

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
    SetAlertLogName("TbAxi4_ReadWriteAsync2") ;
    TbSuperID <= GetAlertLogID("TB Super Proc") ;
    TbMinionID <= GetAlertLogID("TB Minion Proc") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_ReadWriteAsync2.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_ReadWriteAsync2.txt", "../sim_shared/validated_results/TbAxi4_ReadWriteAsync2.txt", "") ; 
    
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
    variable Available : boolean ; 
    variable NumTryRead : integer ; 
  begin
    wait until nReset = '1' ;  
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    NoOp(AxiSuperTransRec, 2) ; 
    log(TbSuperID, "Write and Read with ByteAddr = 0, 4 Bytes") ;
    log(TbSuperID, "WriteAddressAsync,  Addr: AAAA_AAA0") ;
    WriteAddressAsync(AxiSuperTransRec, X"AAAA_AAA0") ;
    log(TbSuperID, "WriteDataAsync, Data: 5555_5555") ;
    WriteDataAsync   (AxiSuperTransRec, X"5555_5555" ) ;
    NoOp(AxiSuperTransRec, 4) ; 
    
    print("") ; 
    log(TbSuperID, "ReadAddressAsync,  Addr: 1111_1110") ;
    ReadAddressAsync(AxiSuperTransRec, X"1111_1110") ;
    NumTryRead := 1 ; 
    loop 
      log(TbSuperID, "TryReadData, Data: 2222_2222, Try # " & to_string(NumTryRead)) ;
      TryReadData(AxiSuperTransRec, Data, Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      NoOp(AxiSuperTransRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbSuperID, Data, X"2222_2222", "Super Read Data: ") ;
    NoOp(AxiSuperTransRec, 2) ; 
    SetLogEnable(INFO, FALSE) ;    -- Disable INFO logs

    print("") ;  print("") ; 
    log(TbSuperID, "Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    log(TbSuperID, "WriteAddressAsync,  Addr: AAAA_AAA0") ;
    WriteAddressAsync(AxiSuperTransRec, X"AAAA_AAA0") ;
    log(TbSuperID, "WriteAddressAsync,  Addr: AAAA_AAA1") ;
    WriteAddressAsync(AxiSuperTransRec, X"AAAA_AAA1") ;
    log(TbSuperID, "WriteAddressAsync,  Addr: AAAA_AAA2") ;
    WriteAddressAsync(AxiSuperTransRec, X"AAAA_AAA2") ;
    log(TbSuperID, "WriteAddressAsync,  Addr: AAAA_AAA3") ;
    WriteAddressAsync(AxiSuperTransRec, X"AAAA_AAA3") ;
    -- Allow Write Address to get two clocks ahead of Write Data
    log(TbSuperID, "NoOp 2") ;
    NoOp(AxiSuperTransRec, 2) ; 
    log(TbSuperID, "WriteDataAsync, ByteAddr: 00, Data: 11") ;
    WriteDataAsync   (AxiSuperTransRec, X"00", X"11" ) ;
    log(TbSuperID, "WriteDataAsync, ByteAddr: 01, Data: 22") ;
    WriteDataAsync   (AxiSuperTransRec, X"01", X"22" ) ;
    log(TbSuperID, "WriteDataAsync, ByteAddr: 02, Data: 33") ;
    WriteDataAsync   (AxiSuperTransRec, X"02", X"33" ) ;
    log(TbSuperID, "WriteDataAsync, ByteAddr: 03, Data: 44") ;
    WriteDataAsync   (AxiSuperTransRec, X"03", X"44" ) ;
    NoOp(AxiSuperTransRec, 8) ; 
    
    print("") ;  
    log(TbSuperID, "ReadAddressAsync,  Addr: 1111_1110") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1110") ;
    log(TbSuperID, "ReadAddressAsync,  Addr: 1111_1111") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1111") ;
    log(TbSuperID, "ReadAddressAsync,  Addr: 1111_1112") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1112") ;
    log(TbSuperID, "ReadAddressAsync,  Addr: 1111_1113") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1113") ;
    NumTryRead := 1 ; 
    loop 
      log(TbSuperID, "TryReadData, Data: AA, Try # " & to_string(NumTryRead)) ;
      TryReadData(AxiSuperTransRec, Data(7 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      NoOp(AxiSuperTransRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbSuperID, Data(7 downto 0), X"AA", "Super Read Data: ") ;
    NumTryRead := 1 ; 
    loop 
      log(TbSuperID, "TryReadData, Data: BB, Try # " & to_string(NumTryRead)) ;
      TryReadData(AxiSuperTransRec, Data(7 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      NoOp(AxiSuperTransRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbSuperID, Data(7 downto 0), X"BB", "Super Read Data: ") ;
    NumTryRead := 1 ; 
    loop 
      log(TbSuperID, "TryReadData, Data: CC, Try # " & to_string(NumTryRead)) ;
      TryReadData(AxiSuperTransRec, Data(7 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      NoOp(AxiSuperTransRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbSuperID, Data(7 downto 0), X"CC", "Super Read Data: ") ;
    NumTryRead := 1 ; 
    loop 
      log(TbSuperID, "TryReadData, Data: DD, Try # " & to_string(NumTryRead)) ;
      TryReadData(AxiSuperTransRec, Data(7 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      NoOp(AxiSuperTransRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbSuperID, Data(7 downto 0), X"DD", "Super Read Data: ") ;
    SetLogEnable(INFO, FALSE) ;    -- Disable INFO logs

    print("") ;  print("") ; 
    log(TbSuperID, "Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    log(TbSuperID, "WriteAddressAsync,  Addr: BBBB_BBB0") ;
    WriteAddressAsync(AxiSuperTransRec, X"BBBB_BBB0") ;
    log(TbSuperID, "WriteAddressAsync,  Addr: BBBB_BBB1") ;
    WriteAddressAsync(AxiSuperTransRec, X"BBBB_BBB1") ;
    log(TbSuperID, "WriteAddressAsync,  Addr: BBBB_BBB2") ;
    WriteAddressAsync(AxiSuperTransRec, X"BBBB_BBB2") ;
    log(TbSuperID, "WriteDataAsync, ByteAddr: 00, Data: 2211") ;
    WriteDataAsync   (AxiSuperTransRec, X"00", X"2211" ) ;
    log(TbSuperID, "WriteDataAsync, ByteAddr: 01, Data: 33_22") ;
    WriteDataAsync   (AxiSuperTransRec, X"01", X"33_22" ) ;
    log(TbSuperID, "WriteDataAsync, ByteAddr: 02, Data: 4433") ;
    WriteDataAsync   (AxiSuperTransRec, X"02", X"4433" ) ;

    print("") ;  
    log(TbSuperID, "ReadAddressAsync,  Addr: 1111_1110") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1110") ;
    log(TbSuperID, "ReadAddressAsync,  Addr: 1111_1111") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1111") ;
    log(TbSuperID, "ReadAddressAsync,  Addr: 1111_1112") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1112") ;
    NumTryRead := 1 ; 
    loop 
      log(TbSuperID, "TryReadData, Data: BBAA, Try # " & to_string(NumTryRead)) ;
      TryReadData(AxiSuperTransRec, Data(15 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      NoOp(AxiSuperTransRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbSuperID, Data(15 downto 0), X"BBAA", "Super Read Data: ") ;
    log(TbSuperID, "ReadData") ;
    NumTryRead := 1 ; 
    loop 
      log(TbSuperID, "TryReadData, Data: CCBB, Try # " & to_string(NumTryRead)) ;
      TryReadData(AxiSuperTransRec, Data(15 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      NoOp(AxiSuperTransRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbSuperID, Data(15 downto 0), X"CCBB", "Super Read Data: ") ;
    log(TbSuperID, "ReadData") ;
    NumTryRead := 1 ; 
    loop 
      log(TbSuperID, "TryReadData, Data: DDCC, Try # " & to_string(NumTryRead)) ;
      TryReadData(AxiSuperTransRec, Data(15 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      NoOp(AxiSuperTransRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbSuperID, Data(15 downto 0), X"DDCC", "Super Read Data: ") ;

    print("") ;  print("") ; 
    log(TbSuperID, "Write and Read with 3 Bytes and ByteAddr = 0. 1") ;
    log(TbSuperID, "WriteAddressAsync,  Addr: CCCC_CCC0") ;
    WriteAddressAsync(AxiSuperTransRec, X"CCCC_CCC0") ;
    log(TbSuperID, "WriteDataAsync, ByteAddr: 00, Data: 33_2211") ;
    WriteDataAsync   (AxiSuperTransRec, X"00", X"33_2211" ) ;
    log(TbSuperID, "WriteAddressAsync,  Addr: CCCC_CCC1") ;
    WriteAddressAsync(AxiSuperTransRec, X"CCCC_CCC1") ;
    log(TbSuperID, "WriteDataAsync, ByteAddr: 01, Data: 4433_22") ;
    WriteDataAsync   (AxiSuperTransRec, X"01", X"4433_22" ) ;

    print("") ;  
    log(TbSuperID, "ReadAddressAsync,  Addr: 1111_1110") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1110") ;
    log(TbSuperID, "ReadAddressAsync,  Addr: 1111_1111") ;
    ReadAddressAsync(AxiSuperTransRec,  X"1111_1111") ;
    NumTryRead := 1 ; 
    loop 
      log(TbSuperID, "TryReadData, Data: CC_BBAA, Try # " & to_string(NumTryRead)) ;
      TryReadData(AxiSuperTransRec, Data(23 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      NoOp(AxiSuperTransRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbSuperID, Data(23 downto 0), X"CC_BBAA", "Super Read Data: ") ;
    NumTryRead := 1 ; 
    loop 
      log(TbSuperID, "TryReadData, Data: DDCC_BB, Try # " & to_string(NumTryRead)) ;
      TryReadData(AxiSuperTransRec, Data(23 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      NoOp(AxiSuperTransRec, 1) ; 
    end loop ;
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


end ReadWriteAsync2 ;

Configuration TbAxi4_ReadWriteAsync2 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ReadWriteAsync2) ; 
    end for ; 
  end for ; 
end TbAxi4_ReadWriteAsync2 ; 
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

architecture ReadWriteAsync2 of TestCtrl is

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
    SetAlertLogName("TbAxi4_ReadWriteAsync2") ;
    TbMasterID <= GetAlertLogID("TB Master Proc") ;
    TbResponderID <= GetAlertLogID("TB Responder Proc") ;
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

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- MasterProc
  --   Generate transactions for AxiMaster
  ------------------------------------------------------------
  MasterProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
    variable Available : boolean ; 
    variable NumTryRead : integer ; 
  begin
    wait until nReset = '1' ;  
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    WaitForClock(ManagerRec, 2) ; 
    log(TbMasterID, "Write and Read with ByteAddr = 0, 4 Bytes") ;
    log(TbMasterID, "WriteAddressAsync,  Addr: AAAA_AAA0") ;
    WriteAddressAsync(ManagerRec, X"AAAA_AAA0") ;
    log(TbMasterID, "WriteDataAsync, Data: 5555_5555") ;
    WriteDataAsync   (ManagerRec, X"5555_5555" ) ;
    WaitForClock(ManagerRec, 4) ; 
    
    print("") ; 
    log(TbMasterID, "ReadAddressAsync,  Addr: 1111_1110") ;
    ReadAddressAsync(ManagerRec, X"1111_1110") ;
    NumTryRead := 1 ; 
    loop 
      log(TbMasterID, "TryReadData, Data: 2222_2222, Try # " & to_string(NumTryRead)) ;
      TryReadData(ManagerRec, Data, Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      WaitForClock(ManagerRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbMasterID, Data, X"2222_2222", "Master Read Data: ") ;
    WaitForClock(ManagerRec, 2) ; 
    SetLogEnable(INFO, FALSE) ;    -- Disable INFO logs

    print("") ;  print("") ; 
    log(TbMasterID, "Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    log(TbMasterID, "WriteAddressAsync,  Addr: AAAA_AAA0") ;
    WriteAddressAsync(ManagerRec, X"AAAA_AAA0") ;
    log(TbMasterID, "WriteAddressAsync,  Addr: AAAA_AAA1") ;
    WriteAddressAsync(ManagerRec, X"AAAA_AAA1") ;
    log(TbMasterID, "WriteAddressAsync,  Addr: AAAA_AAA2") ;
    WriteAddressAsync(ManagerRec, X"AAAA_AAA2") ;
    log(TbMasterID, "WriteAddressAsync,  Addr: AAAA_AAA3") ;
    WriteAddressAsync(ManagerRec, X"AAAA_AAA3") ;
    -- Allow Write Address to get two clocks ahead of Write Data
    log(TbMasterID, "WaitForClock 2") ;
    WaitForClock(ManagerRec, 2) ; 
    log(TbMasterID, "WriteDataAsync, ByteAddr: 00, Data: 11") ;
    WriteDataAsync   (ManagerRec, X"00", X"11" ) ;
    log(TbMasterID, "WriteDataAsync, ByteAddr: 01, Data: 22") ;
    WriteDataAsync   (ManagerRec, X"01", X"22" ) ;
    log(TbMasterID, "WriteDataAsync, ByteAddr: 02, Data: 33") ;
    WriteDataAsync   (ManagerRec, X"02", X"33" ) ;
    log(TbMasterID, "WriteDataAsync, ByteAddr: 03, Data: 44") ;
    WriteDataAsync   (ManagerRec, X"03", X"44" ) ;
    WaitForClock(ManagerRec, 8) ; 
    
    print("") ;  
    log(TbMasterID, "ReadAddressAsync,  Addr: 1111_1110") ;
    ReadAddressAsync(ManagerRec,  X"1111_1110") ;
    log(TbMasterID, "ReadAddressAsync,  Addr: 1111_1111") ;
    ReadAddressAsync(ManagerRec,  X"1111_1111") ;
    log(TbMasterID, "ReadAddressAsync,  Addr: 1111_1112") ;
    ReadAddressAsync(ManagerRec,  X"1111_1112") ;
    log(TbMasterID, "ReadAddressAsync,  Addr: 1111_1113") ;
    ReadAddressAsync(ManagerRec,  X"1111_1113") ;
    NumTryRead := 1 ; 
    loop 
      log(TbMasterID, "TryReadData, Data: AA, Try # " & to_string(NumTryRead)) ;
      TryReadData(ManagerRec, Data(7 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      WaitForClock(ManagerRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"AA", "Master Read Data: ") ;
    NumTryRead := 1 ; 
    loop 
      log(TbMasterID, "TryReadData, Data: BB, Try # " & to_string(NumTryRead)) ;
      TryReadData(ManagerRec, Data(7 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      WaitForClock(ManagerRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"BB", "Master Read Data: ") ;
    NumTryRead := 1 ; 
    loop 
      log(TbMasterID, "TryReadData, Data: CC, Try # " & to_string(NumTryRead)) ;
      TryReadData(ManagerRec, Data(7 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      WaitForClock(ManagerRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"CC", "Master Read Data: ") ;
    NumTryRead := 1 ; 
    loop 
      log(TbMasterID, "TryReadData, Data: DD, Try # " & to_string(NumTryRead)) ;
      TryReadData(ManagerRec, Data(7 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      WaitForClock(ManagerRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"DD", "Master Read Data: ") ;
    SetLogEnable(INFO, FALSE) ;    -- Disable INFO logs

    print("") ;  print("") ; 
    log(TbMasterID, "Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    log(TbMasterID, "WriteAddressAsync,  Addr: BBBB_BBB0") ;
    WriteAddressAsync(ManagerRec, X"BBBB_BBB0") ;
    log(TbMasterID, "WriteAddressAsync,  Addr: BBBB_BBB1") ;
    WriteAddressAsync(ManagerRec, X"BBBB_BBB1") ;
    log(TbMasterID, "WriteAddressAsync,  Addr: BBBB_BBB2") ;
    WriteAddressAsync(ManagerRec, X"BBBB_BBB2") ;
    log(TbMasterID, "WriteDataAsync, ByteAddr: 00, Data: 2211") ;
    WriteDataAsync   (ManagerRec, X"00", X"2211" ) ;
    log(TbMasterID, "WriteDataAsync, ByteAddr: 01, Data: 33_22") ;
    WriteDataAsync   (ManagerRec, X"01", X"33_22" ) ;
    log(TbMasterID, "WriteDataAsync, ByteAddr: 02, Data: 4433") ;
    WriteDataAsync   (ManagerRec, X"02", X"4433" ) ;

    print("") ;  
    log(TbMasterID, "ReadAddressAsync,  Addr: 1111_1110") ;
    ReadAddressAsync(ManagerRec,  X"1111_1110") ;
    log(TbMasterID, "ReadAddressAsync,  Addr: 1111_1111") ;
    ReadAddressAsync(ManagerRec,  X"1111_1111") ;
    log(TbMasterID, "ReadAddressAsync,  Addr: 1111_1112") ;
    ReadAddressAsync(ManagerRec,  X"1111_1112") ;
    NumTryRead := 1 ; 
    loop 
      log(TbMasterID, "TryReadData, Data: BBAA, Try # " & to_string(NumTryRead)) ;
      TryReadData(ManagerRec, Data(15 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      WaitForClock(ManagerRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbMasterID, Data(15 downto 0), X"BBAA", "Master Read Data: ") ;
    log(TbMasterID, "ReadData") ;
    NumTryRead := 1 ; 
    loop 
      log(TbMasterID, "TryReadData, Data: CCBB, Try # " & to_string(NumTryRead)) ;
      TryReadData(ManagerRec, Data(15 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      WaitForClock(ManagerRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbMasterID, Data(15 downto 0), X"CCBB", "Master Read Data: ") ;
    log(TbMasterID, "ReadData") ;
    NumTryRead := 1 ; 
    loop 
      log(TbMasterID, "TryReadData, Data: DDCC, Try # " & to_string(NumTryRead)) ;
      TryReadData(ManagerRec, Data(15 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      WaitForClock(ManagerRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbMasterID, Data(15 downto 0), X"DDCC", "Master Read Data: ") ;

    print("") ;  print("") ; 
    log(TbMasterID, "Write and Read with 3 Bytes and ByteAddr = 0. 1") ;
    log(TbMasterID, "WriteAddressAsync,  Addr: CCCC_CCC0") ;
    WriteAddressAsync(ManagerRec, X"CCCC_CCC0") ;
    log(TbMasterID, "WriteDataAsync, ByteAddr: 00, Data: 33_2211") ;
    WriteDataAsync   (ManagerRec, X"00", X"33_2211" ) ;
    log(TbMasterID, "WriteAddressAsync,  Addr: CCCC_CCC1") ;
    WriteAddressAsync(ManagerRec, X"CCCC_CCC1") ;
    log(TbMasterID, "WriteDataAsync, ByteAddr: 01, Data: 4433_22") ;
    WriteDataAsync   (ManagerRec, X"01", X"4433_22" ) ;

    print("") ;  
    log(TbMasterID, "ReadAddressAsync,  Addr: 1111_1110") ;
    ReadAddressAsync(ManagerRec,  X"1111_1110") ;
    log(TbMasterID, "ReadAddressAsync,  Addr: 1111_1111") ;
    ReadAddressAsync(ManagerRec,  X"1111_1111") ;
    NumTryRead := 1 ; 
    loop 
      log(TbMasterID, "TryReadData, Data: CC_BBAA, Try # " & to_string(NumTryRead)) ;
      TryReadData(ManagerRec, Data(23 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      WaitForClock(ManagerRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbMasterID, Data(23 downto 0), X"CC_BBAA", "Master Read Data: ") ;
    NumTryRead := 1 ; 
    loop 
      log(TbMasterID, "TryReadData, Data: DDCC_BB, Try # " & to_string(NumTryRead)) ;
      TryReadData(ManagerRec, Data(23 downto 0), Available) ;
      exit when Available ; 
      NumTryRead := NumTryRead + 1 ; 
      WaitForClock(ManagerRec, 1) ; 
    end loop ;
    AffirmIfEqual(TbMasterID, Data(23 downto 0), X"DDCC_BB", "Master Read Data: ") ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 2) ;
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
    WaitForClock(SubordinateRec, 2) ; 
    -- Write and Read with ByteAddr = 0, 4 Bytes
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"AAAA_AAA0", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"5555_5555", "Responder Write Data: ") ;
    
    SendRead(SubordinateRec, Addr, X"2222_2222") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1110", "Responder Read Addr: ") ;

    
    -- Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3
    -- Write(ManagerRec, X"AAAA_AAA0", X"11" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"AAAA_AAA0", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0000_0011", "Responder Write Data: ") ;
    -- Write(ManagerRec, X"AAAA_AAA1", X"22" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"AAAA_AAA1", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0000_2200", "Responder Write Data: ") ;
    -- Write(ManagerRec, X"AAAA_AAA2", X"33" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"AAAA_AAA2", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0033_0000", "Responder Write Data: ") ;
    -- Write(ManagerRec, X"AAAA_AAA3", X"44" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"AAAA_AAA3", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"4400_0000", "Responder Write Data: ") ;

    SendRead(SubordinateRec, Addr, X"0000_00AA") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1110", "Responder Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"0000_BB00") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1111", "Responder Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"00CC_0000") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1112", "Responder Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"DD00_0000") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1113", "Responder Read Addr: ") ;


    -- Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2
    -- Write(ManagerRec, X"BBBB_BBB0", X"2211" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"BBBB_BBB0", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0000_2211", "Responder Write Data: ") ;
    -- Write(ManagerRec, X"BBBB_BBB1", X"3322" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"BBBB_BBB1", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0033_2200", "Responder Write Data: ") ;
    -- Write(ManagerRec, X"BBBB_BBB2", X"4433" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"BBBB_BBB2", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"4433_0000", "Responder Write Data: ") ;

    SendRead(SubordinateRec, Addr, X"0000_BBAA") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1110", "Responder Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"00CC_BB00") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1111", "Responder Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"DDCC_0000") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1112", "Responder Read Addr: ") ;

    -- Write and Read with 3 Bytes and ByteAddr = 0. 1
    -- Write(ManagerRec, X"CCCC_CCC0", X"332211" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"CCCC_CCC0", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0033_2211", "Responder Write Data: ") ;
    -- Write(ManagerRec, X"CCCC_CCC1", X"443322" ) ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"CCCC_CCC1", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"4433_2200", "Responder Write Data: ") ;

    SendRead(SubordinateRec, Addr, X"00CC_BBAA") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1110", "Responder Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"DDCC_BB00") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1111", "Responder Read Addr: ") ;


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ResponderProc ;


end ReadWriteAsync2 ;

Configuration TbAxi4_ReadWriteAsync2 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ReadWriteAsync2) ; 
    end for ; 
  end for ; 
end TbAxi4_ReadWriteAsync2 ; 
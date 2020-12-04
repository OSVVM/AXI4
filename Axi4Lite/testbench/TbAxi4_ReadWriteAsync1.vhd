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
    SetAlertLogName("TbAxi4_ReadWriteAsync1") ;
    TbMasterID <= GetAlertLogID("TB Master Proc") ;
    TbResponderID <= GetAlertLogID("TB Responder Proc") ;
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
  -- MasterProc
  --   Generate transactions for AxiMaster
  ------------------------------------------------------------
  MasterProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
  begin
    wait until nReset = '1' ;  
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    WaitForClock(MasterRec, 2) ; 
    log(TbMasterID, "Write and Read with ByteAddr = 0, 4 Bytes") ;
    log(TbMasterID, "WriteAsync, Addr: AAAA_AAA0, Data: 5555_5555") ;
    WriteAsync(MasterRec, X"AAAA_AAA0", X"5555_5555" ) ;
    WaitForClock(MasterRec, 4) ; 

    print("") ; 
    log(TbMasterID, "ReadAddressAsync, Addr 1111_1110") ;
    ReadAddressAsync(MasterRec, X"1111_1110") ;
    log(TbMasterID, "ReadData, Data 2222_2222") ;
    ReadData(MasterRec, Data) ;
    AffirmIfEqual(TbMasterID, Data, X"2222_2222", "Master Read Data: ") ;
    WaitForClock(MasterRec, 2) ; 
    
    print("") ;     print("") ; 
    log(TbMasterID, "Write with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    log(TbMasterID, "WriteAsync,  Addr: AAAA_AAA0, Data: 11") ;
    WriteAsync(MasterRec, X"AAAA_AAA0", X"11" ) ;
    log(TbMasterID, "WriteAsync,  Addr: AAAA_AAA1, Data: 22") ;
    WriteAsync(MasterRec, X"AAAA_AAA1", X"22" ) ;
    log(TbMasterID, "WriteAsync,  Addr: AAAA_AAA2, Data: 33") ;
    WriteAsync(MasterRec, X"AAAA_AAA2", X"33" ) ;
    log(TbMasterID, "WriteAsync,  Addr: AAAA_AAA3, Data: 44") ;
    WriteAsync(MasterRec, X"AAAA_AAA3", X"44" ) ;
    WaitForClock(MasterRec, 8) ; 
    
    print("") ; 
    log(TbMasterID, "Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    log(TbMasterID, "ReadAddressAsync, Addr: 1111_1110") ;
    ReadAddressAsync(MasterRec,  X"1111_1110") ;
    log(TbMasterID, "ReadAddressAsync, Addr: 1111_1111") ;
    ReadAddressAsync(MasterRec,  X"1111_1111") ;
    log(TbMasterID, "ReadAddressAsync, Addr: 1111_1112") ;
    ReadAddressAsync(MasterRec,  X"1111_1112") ;
    log(TbMasterID, "ReadAddressAsync, Addr: 1111_1113") ;
    ReadAddressAsync(MasterRec,  X"1111_1113") ;
    log(TbMasterID, "ReadData, Data: AA") ;
    ReadData(MasterRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"AA", "Master Read Data: ") ;
    log(TbMasterID, "ReadData, Data: BB") ;
    ReadData(MasterRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"BB", "Master Read Data: ") ;
    log(TbMasterID, "ReadData, Data: CC") ;
    ReadData(MasterRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"CC", "Master Read Data: ") ;
    log(TbMasterID, "ReadData, Data: DD") ;
    ReadData(MasterRec,  Data(7 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(7 downto 0), X"DD", "Master Read Data: ") ;
    SetLogEnable(INFO, FALSE) ;    -- Disable INFO logs

    print("") ;     print("") ; 
    log(TbMasterID, "Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    log(TbMasterID, "WriteAsync,  Addr: BBBB_BBB0, Data: 2211") ;
    WriteAsync(MasterRec, X"BBBB_BBB0", X"2211" ) ;
    log(TbMasterID, "WriteAsync,  Addr: BBBB_BBB1, Data: 33_22") ;
    WriteAsync(MasterRec, X"BBBB_BBB1", X"33_22" ) ;
    log(TbMasterID, "WriteAsync,  Addr: BBBB_BBB2, Data: 4433") ;
    WriteAsync(MasterRec, X"BBBB_BBB2", X"4433" ) ;

    print("") ; 
    log(TbMasterID, "ReadAddressAsync, Addr: 1111_1110") ;
    ReadAddressAsync(MasterRec,  X"1111_1110") ;
    log(TbMasterID, "ReadAddressAsync, Addr: 1111_1111") ;
    ReadAddressAsync(MasterRec,  X"1111_1111") ;
    log(TbMasterID, "ReadAddressAsync, Addr: 1111_1112") ;
    ReadAddressAsync(MasterRec,  X"1111_1112") ;
    log(TbMasterID, "ReadData, Data: BBAA") ;
    ReadData(MasterRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(15 downto 0), X"BBAA", "Master Read Data: ") ;
    log(TbMasterID, "ReadData, Data: CCBB") ;
    ReadData(MasterRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(15 downto 0), X"CCBB", "Master Read Data: ") ;
    log(TbMasterID, "ReadData, Data: DDCC") ;
    ReadData(MasterRec,  Data(15 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(15 downto 0), X"DDCC", "Master Read Data: ") ;

    print("") ;     print("") ; 
    log(TbMasterID, "Write and Read with 3 Bytes and ByteAddr = 0. 1") ;
    log(TbMasterID, "WriteAsync,  Addr: CCCC_CCC0, Data: 33_2211") ;
    WriteAsync(MasterRec, X"CCCC_CCC0", X"33_2211" ) ;
    log(TbMasterID, "WriteAsync,  Addr: CCCC_CCC1, Data: 4433_22") ;
    WriteAsync(MasterRec, X"CCCC_CCC1", X"4433_22" ) ;

    print("") ; 
    log(TbMasterID, "ReadAddressAsync, Addr: 1111_1110") ;
    ReadAddressAsync(MasterRec,  X"1111_1110") ;
    log(TbMasterID, "ReadAddressAsync, Addr: 1111_1111") ;
    ReadAddressAsync(MasterRec,  X"1111_1111") ;
    log(TbMasterID, "ReadData, Data: CC_BBAA") ;
    ReadData(MasterRec,  Data(23 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(23 downto 0), X"CC_BBAA", "Master Read Data: ") ;
    log(TbMasterID, "ReadData, Data: DDCC_BB") ;
    ReadData(MasterRec,  Data(23 downto 0)) ;
    AffirmIfEqual(TbMasterID, Data(23 downto 0), X"DDCC_BB", "Master Read Data: ") ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(MasterRec, 2) ;
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
    WaitForClock(ResponderRec, 2) ; 
    -- Write and Read with ByteAddr = 0, 4 Bytes
    GetWrite(ResponderRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"AAAA_AAA0", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"5555_5555", "Responder Write Data: ") ;
    
    SendRead(ResponderRec, Addr, X"2222_2222") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1110", "Responder Read Addr: ") ;

    
    -- Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3
    -- Write(MasterRec, X"AAAA_AAA0", X"11" ) ;
    GetWrite(ResponderRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"AAAA_AAA0", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0000_0011", "Responder Write Data: ") ;
    -- Write(MasterRec, X"AAAA_AAA1", X"22" ) ;
    GetWrite(ResponderRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"AAAA_AAA1", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0000_2200", "Responder Write Data: ") ;
    -- Write(MasterRec, X"AAAA_AAA2", X"33" ) ;
    GetWrite(ResponderRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"AAAA_AAA2", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0033_0000", "Responder Write Data: ") ;
    -- Write(MasterRec, X"AAAA_AAA3", X"44" ) ;
    GetWrite(ResponderRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"AAAA_AAA3", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"4400_0000", "Responder Write Data: ") ;

    SendRead(ResponderRec, Addr, X"0000_00AA") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1110", "Responder Read Addr: ") ;
    SendRead(ResponderRec, Addr, X"0000_BB00") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1111", "Responder Read Addr: ") ;
    SendRead(ResponderRec, Addr, X"00CC_0000") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1112", "Responder Read Addr: ") ;
    SendRead(ResponderRec, Addr, X"DD00_0000") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1113", "Responder Read Addr: ") ;


    -- Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2
    -- Write(MasterRec, X"BBBB_BBB0", X"2211" ) ;
    GetWrite(ResponderRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"BBBB_BBB0", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0000_2211", "Responder Write Data: ") ;
    -- Write(MasterRec, X"BBBB_BBB1", X"3322" ) ;
    GetWrite(ResponderRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"BBBB_BBB1", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0033_2200", "Responder Write Data: ") ;
    -- Write(MasterRec, X"BBBB_BBB2", X"4433" ) ;
    GetWrite(ResponderRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"BBBB_BBB2", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"4433_0000", "Responder Write Data: ") ;

    SendRead(ResponderRec, Addr, X"0000_BBAA") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1110", "Responder Read Addr: ") ;
    SendRead(ResponderRec, Addr, X"00CC_BB00") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1111", "Responder Read Addr: ") ;
    SendRead(ResponderRec, Addr, X"DDCC_0000") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1112", "Responder Read Addr: ") ;

    -- Write and Read with 3 Bytes and ByteAddr = 0. 1
    -- Write(MasterRec, X"CCCC_CCC0", X"332211" ) ;
    GetWrite(ResponderRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"CCCC_CCC0", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"0033_2211", "Responder Write Data: ") ;
    -- Write(MasterRec, X"CCCC_CCC1", X"443322" ) ;
    GetWrite(ResponderRec, Addr, Data) ;
    AffirmIfEqual(TbResponderID, Addr, X"CCCC_CCC1", "Responder Write Addr: ") ;
    AffirmIfEqual(TbResponderID, Data, X"4433_2200", "Responder Write Data: ") ;

    SendRead(ResponderRec, Addr, X"00CC_BBAA") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1110", "Responder Read Addr: ") ;
    SendRead(ResponderRec, Addr, X"DDCC_BB00") ; 
    AffirmIfEqual(TbResponderID, Addr, X"1111_1111", "Responder Read Addr: ") ;


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ResponderRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ResponderProc ;


end ReadWriteAsync1 ;

Configuration TbAxi4_ReadWriteAsync1 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(ReadWriteAsync1) ; 
    end for ; 
  end for ; 
end TbAxi4_ReadWriteAsync1 ; 
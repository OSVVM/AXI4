--
--  File Name:         TbAxi4_AxiXResp3_slv.vhd
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
--    03/2022   2022.03    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2022 by SynthWorks Design Inc.  
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

architecture AxiXResp3_slv of TestCtrl is

  signal TestDone, Sync1 : integer_barrier := 1 ;
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbAxi4_AxiXResp3_slv") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("TbAxi4_AxiXResp3_slv.txt") ;
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
    -- AlertIfDiff("./results/TbAxi4_AxiXResp3_slv.txt", "../AXI4/Axi4/testbench/validated_results/TbAxi4_AxiXResp3_slv.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop ; 
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
    WaitForClock(ManagerRec, 2) ; 
log("Word Write, BRESP = OKAY") ;
    Write(ManagerRec, X"0001_0000", X"0001_0101" ) ;
    WaitForClock(ManagerRec, 2) ; 
    blankline ; 
    Write(ManagerRec, X"0001_0004", X"0001_0202" ) ;
    
    WaitForClock(ManagerRec, 4) ; 
    blankline(2) ; 


log("Word Write, Set BRESP each time") ;
    SetAxi4Options(ManagerRec, BRESP,     AXI4_RESP_EXOKAY) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    Write(ManagerRec, X"0002_0000", X"0002_0101" ) ;
    WaitForClock(ManagerRec, 2) ; 
    blankline ; 
    SetAxi4Options(ManagerRec, BRESP,     AXI4_RESP_SLVERR) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    Write(ManagerRec, X"0002_0004", X"0002_0202" ) ;
    WaitForClock(ManagerRec, 2) ; 
    blankline ; 
    SetAxi4Options(ManagerRec, BRESP,     AXI4_RESP_DECERR) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    Write(ManagerRec, X"0002_0008", X"0002_0303" ) ;
    WaitForClock(ManagerRec, 2) ; 
    blankline ; 
    SetAxi4Options(ManagerRec, BRESP,     AXI4_RESP_OKAY) ;        -- (OKAY, EXOKAY, SLVERR, DECERR)
    Write(ManagerRec, X"0002_000C", X"0002_0404" ) ;

    WaitForClock(ManagerRec, 4) ; 
    blankline(2) ; 

log("Word Read, BRESP = OKAY") ;
    Read(ManagerRec,    X"0003_0000", Data) ;
    AffirmIfEqual(Data, X"0003_0101", "Manager Read Data: ") ;
    WaitForClock(ManagerRec, 2) ; 
    blankline ; 
    Read(ManagerRec,    X"0003_0004", Data) ;
    AffirmIfEqual(Data, X"0003_0202", "Manager Read Data: ") ;

    WaitForClock(ManagerRec, 4) ; 
    blankline(2) ; 

log("Word Read, Set BRESP each time") ;
    SetAxi4Options(ManagerRec, RRESP,     AXI4_RESP_EXOKAY) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    Read(ManagerRec,    X"0004_0000", Data) ;
    AffirmIfEqual(Data, X"0004_0101", "Manager Read Data: ") ;
    WaitForClock(ManagerRec, 2) ; 
    blankline ; 
    SetAxi4Options(ManagerRec, RRESP,     AXI4_RESP_SLVERR) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    Read(ManagerRec,    X"0004_0004", Data) ;
    AffirmIfEqual(Data, X"0004_0202", "Manager Read Data: ") ;
    WaitForClock(ManagerRec, 2) ; 
    blankline ; 
    SetAxi4Options(ManagerRec, RRESP,     AXI4_RESP_DECERR) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    Read(ManagerRec,    X"0004_0008", Data) ;
    AffirmIfEqual(Data, X"0004_0303", "Manager Read Data: ") ;
    WaitForClock(ManagerRec, 2) ; 
    blankline ; 
    SetAxi4Options(ManagerRec, RRESP,     AXI4_RESP_OKAY) ;        -- (OKAY, EXOKAY, SLVERR, DECERR)
    Read(ManagerRec,    X"0004_000C", Data) ;
    AffirmIfEqual(Data, X"0004_0404", "Manager Read Data: ") ;


    
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

-- Word Write Transfers
    -- Write and Read with ByteAddr = 0, 4 Bytes
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"0001_0000", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"0001_0101", "Subordinate Write Data: ") ;
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"0001_0004", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"0001_0202", "Subordinate Write Data: ") ;

-- Word Write Transfers with BRESP
    SetAxi4Options(SubordinateRec, BRESP,     AXI4_RESP_EXOKAY) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"0002_0000", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"0002_0101", "Subordinate Write Data: ") ;
    SetAxi4Options(SubordinateRec, BRESP,     AXI4_RESP_SLVERR) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"0002_0004", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"0002_0202", "Subordinate Write Data: ") ;
    SetAxi4Options(SubordinateRec, BRESP,     AXI4_RESP_DECERR) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"0002_0008", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"0002_0303", "Subordinate Write Data: ") ;
    SetAxi4Options(SubordinateRec, BRESP,     AXI4_RESP_OKAY) ;        -- (OKAY, EXOKAY, SLVERR, DECERR)
    GetWrite(SubordinateRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"0002_000C", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"0002_0404", "Subordinate Write Data: ") ;

-- Word Read Transfers
    SendRead(SubordinateRec, Addr, X"0003_0101") ; 
    AffirmIfEqual(Addr, X"0003_0000", "Subordinate Read Addr: ") ;
    SendRead(SubordinateRec, Addr, X"0003_0202") ; 
    AffirmIfEqual(Addr, X"0003_0004", "Subordinate Read Addr: ") ;

-- Word Read Transfers with RRESP
    SetAxi4Options(SubordinateRec, RRESP,     AXI4_RESP_EXOKAY) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    SendRead(SubordinateRec, Addr, X"0004_0101") ; 
    AffirmIfEqual(Addr, X"0004_0000", "Subordinate Read Addr: ") ;
    SetAxi4Options(SubordinateRec, RRESP,     AXI4_RESP_SLVERR) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    SendRead(SubordinateRec, Addr, X"0004_0202") ; 
    AffirmIfEqual(Addr, X"0004_0004", "Subordinate Read Addr: ") ;
    SetAxi4Options(SubordinateRec, RRESP,     AXI4_RESP_DECERR) ;      -- (OKAY, EXOKAY, SLVERR, DECERR)
    SendRead(SubordinateRec, Addr, X"0004_0303") ; 
    AffirmIfEqual(Addr, X"0004_0008", "Subordinate Read Addr: ") ;
    SetAxi4Options(SubordinateRec, RRESP,     AXI4_RESP_OKAY) ;        -- (OKAY, EXOKAY, SLVERR, DECERR)
    SendRead(SubordinateRec, Addr, X"0004_0404") ; 
    AffirmIfEqual(Addr, X"0004_000C", "Subordinate Read Addr: ") ;



    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;


end AxiXResp3_slv ;

Configuration TbAxi4_AxiXResp3_slv of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(AxiXResp3_slv) ; 
    end for ; 
  end for ; 
end TbAxi4_AxiXResp3_slv ; 
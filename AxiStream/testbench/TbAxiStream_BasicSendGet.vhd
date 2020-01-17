--
--  File Name:         TbAxiStream_BasicSendGet.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Test transaction source for AxiStreamMaster and AxiStreamSlave
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    05/2017   2018.05    Initial revision
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
architecture BasicSendGet of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
  constant AXI_DATA_WIDTH : integer := 32 ; 
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxiStream_BasicSendGet") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxiStream_BasicSendGet.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AlertIfDiff("./results/TbAxiStream_BasicSendGet.txt", "../sim_shared/validated_results/TbAxiStream_BasicSendGet.txt", "") ; 
    
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
    NoOp(AxiStreamMasterTransRec, 2) ; 
    
    log("Send 256 words with each byte incrementing") ;
    for i in 0 to 2**8-1 loop 
       -- Create words one byte at a time
       Data := to_slv(i, 8) & Data(Data'left downto 8) ;
       if ((i+1) mod 4) = 0 then 
        Send(AxiStreamMasterTransRec, Data) ;
       end if ; 
    end loop ;
   
    -- Wait for outputs to propagate and signal TestDone
    NoOp(AxiStreamMasterTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiMasterProc ;


  ------------------------------------------------------------
  -- AxiSlaveProc
  --   Generate transactions for AxiSlave
  ------------------------------------------------------------
  AxiSlaveProc : process
    variable ExpData, RxData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    NoOp(AxiStreamSlaveTransRec, 2) ; 
    
    -- Get and check the 256 words
    for i in 0 to 2**8-1 loop
       -- Create words one byte at a time
       ExpData := to_slv(i, 8) & ExpData(ExpData'left downto 8) ;
       if ((i+1) mod 4) = 0 then 
         Get(AxiStreamSlaveTransRec, RxData) ; 
         AffirmIfEqual(RxData, ExpData, "AxiStreamSlave Get: ") ;
       end if ; 
     end loop ;
     
    -- Wait for outputs to propagate and signal TestDone
    NoOp(AxiStreamSlaveTransRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiSlaveProc ;

end BasicSendGet ;

Configuration TbAxiStream_BasicSendGet of TbAxiStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(BasicSendGet) ; 
    end for ; 
  end for ; 
end TbAxiStream_BasicSendGet ; 
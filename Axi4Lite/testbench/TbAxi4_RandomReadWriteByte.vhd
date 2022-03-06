--
--  File Name:         TbAxi4_RandomReadWriteByte.vhd
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
--    09/2017   2017       Initial revision
--    01/2020   2020.01    Updated license notice
--    12/2020   2020.12    Updated signal and port names
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2017 - 2020 by SynthWorks Design Inc.  
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

architecture RandomReadWriteByte of TestCtrl is

  signal TestDone : integer_barrier := 1 ;
  constant AXI_DATA_BYTES : integer := AXI_DATA_WIDTH / 8 ; 
  
  type OperationType is (WRITE_OP, READ_OP) ;  -- Add TEST_DONE?
  constant WRITE_OP_INDEX : integer := OperationType'pos(WRITE_OP) ;
  constant READ_OP_INDEX  : integer := OperationType'pos(READ_OP) ;
  subtype OperationSlvType is std_logic_vector(0 downto 0) ;

  shared variable OperationFifo  : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 
  
  signal TestActive : boolean := TRUE ;
  
  signal OperationCount : integer := 0 ; 
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbAxi4_RandomReadWriteByte") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("./results/TbAxi4_RandomReadWriteByte.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;
    SetAlertStopCount(ERROR, 2) ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 1 ms) ;
    AlertIf(now >= 1 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbAxi4_RandomReadWriteByte.txt", "../sim_shared/validated_results/TbAxi4_RandomReadWriteByte.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop(GetAlertCount) ; 
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- MasterProc
  --   Generate transactions for AxiMaster
  ------------------------------------------------------------
  MasterProc : process
    variable OpRV           : RandomPType ;   
    variable WaitForClockRV         : RandomPType ;   
    variable DataRV         : RandomPType ;   
    variable OperationInt   : integer ; 
    variable OperationSlv   : OperationSlvType ; 
    variable Address        : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable ByteAddress    : integer ;
    variable NumberOfBytes  : integer ;
    variable MasterData      : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
    variable ResponderData     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
    variable ReadData       : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
    
    variable counts : integer_vector(0 to OperationType'Pos(OperationType'Right)) ; 
  begin
    -- Initialize Randomization Objects
    OpRV.InitSeed(OpRv'instance_name) ;
    WaitForClockRV.InitSeed(WaitForClockRV'instance_name) ;
    DataRV.InitSeed(DataRV'instance_name) ;
    
    -- Find exit of reset
    wait until nReset = '1' ;  
    WaitForClock(ManagerRec, 2) ; 
    
    -- Distribution for Test Operations
    counts := (WRITE_OP_INDEX => 500, READ_OP_INDEX => 500) ;
    
    OperationLoop : loop
      -- Calculate Address and Data if Write or Read Operation
      OperationInt   := OpRV.DistInt(counts) ;
      OperationSlv   := to_slv(OperationInt, OperationSlv'length) ;
      Address        := OpRV.RandSlv(size => AXI_ADDR_WIDTH) ;
      ByteAddress    := to_integer(Address(1 downto 0)) ;
      NumberOfBytes  := OpRv.RandInt(1, AXI_DATA_BYTES - ByteAddress) ;

      -- Get MasterData right aligned and ResponderData word aligned
      ResponderData      := (others => '0') ;
      MasterData     := (others => '0') ;
      for i in AXI_DATA_BYTES - 1 downto 0 loop
        ResponderData := ResponderData(AXI_DATA_BYTES*8 - 9 downto 0) & (0 to 7 => '0') ;
        if i >= ByteAddress and i < ByteAddress + NumberOfBytes then
          ResponderData(7 downto 0) := DataRV.RandSlv(0, 255, 8) ;
          MasterData := MasterData(AXI_DATA_BYTES*8 - 9 downto 0) & ResponderData(7 downto 0) ;
        end if ; 
      end loop ;
      
      -- Send the operation to the Responder Handler
      OperationFifo.push(OperationSlv & Address & ResponderData) ;
      Increment(OperationCount) ;
      
      -- 20 % of the time add a no-op cycle with a delay of 1 to 5 clocks
      if WaitForClockRV.DistInt((8, 2)) = 1 then 
        WaitForClock(ManagerRec, WaitForClockRV.RandInt(1, 5)) ; 
      end if ; 
      
      -- Do the Operation
      case OperationType'val(OperationInt) is
        when WRITE_OP =>  
          counts(WRITE_OP_INDEX) := counts(WRITE_OP_INDEX) - 1 ; 
          -- Log("Starting: Master Write with Address: " & to_hstring(Address) & "  Data: " & to_hstring(Data) ) ;
          Write(ManagerRec, Address, MasterData(NumberOfBytes*8-1 downto 0)) ;
          
        when READ_OP =>  
          counts(READ_OP_INDEX) := counts(READ_OP_INDEX) - 1 ; 
          -- Log("Starting: Master Read with Address: " & to_hstring(Address) & "  Data: " & to_hstring(Data) ) ;
          ReadData := (others => '0') ;  -- Clear out all data values for short reads
          Read(ManagerRec, Address, ReadData(NumberOfBytes*8-1 downto 0)) ;
          AffirmIf(ReadData = MasterData, "AXI Master Read Data: "& to_hstring(ReadData), 
                   "  Expected: " & to_hstring(MasterData) & "  ByteAddress: " & to_string(ByteAddress)) ;

        when others =>
          Alert("Invalid Operation Generated", FAILURE) ;
      end case ;
      
      exit when counts = (0, 0) ;
    end loop OperationLoop ; 
    
    TestActive <= FALSE ; 
    -- Allow Responder to catch up before signaling OperationCount (needed when WRITE_OP is last)
    -- wait for 0 ns ;  -- this is enough
    WaitForClock(ManagerRec, 2) ;
    Increment(OperationCount) ;
    
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
    variable WaitForClockRV         : RandomPType ;   
    variable OperationSlv   : OperationSlvType ; 
    variable Address        : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable ActualAddress  : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data           : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
    variable WriteData      : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;    
  begin
    WaitForClockRV.InitSeed(WaitForClockRV'instance_name) ;

    OperationLoop : loop   
      if OperationFifo.empty then
        WaitForToggle(OperationCount) ; 
      end if ; 
      
      exit OperationLoop when TestActive = FALSE ; 
      
      -- 20 % of the time add a no-op cycle with a delay of 1 to 5 clocks
      if WaitForClockRV.DistInt((8, 2)) = 1 then 
        WaitForClock(SubordinateRec, WaitForClockRV.RandInt(1, 5)) ; 
      end if ; 
      
      -- Get the Operation
      (OperationSlv, Address, Data) := OperationFifo.pop ; 
      
      -- Do the Operation
      case OperationType'val(to_integer(OperationSlv)) is
        when WRITE_OP =>  
          -- Log("Starting: Responder Write with Expected Address: " & to_hstring(Address) & "  Data: " & to_hstring(Data) ) ;
          GetWrite(SubordinateRec, ActualAddress, WriteData) ;
          AffirmIf(ActualAddress = Address, "AXI Responder Write Address: " & to_hstring(ActualAddress), 
                   "  Expected: " & to_hstring(Address)) ;
          AffirmIf(WriteData = Data, "AXI Responder Write Data: "& to_hstring(WriteData), 
                   "  Expected: " & to_hstring(Data)) ;
          
        when READ_OP =>  
          -- Log("Starting: Responder Read with Expected Address: " & to_hstring(Address) & "  Data: " & to_hstring(Data) ) ;
          SendRead(SubordinateRec, ActualAddress, Data) ; 
          AffirmIf(ActualAddress = Address, "AXI Responder Read Address: " & to_hstring(ActualAddress), 
                   "  Expected: " & to_hstring(Address)) ;

        when others =>
          Alert("Invalid Operation Generated", FAILURE) ;
          
      end case ;
      
    end loop OperationLoop ; 

    -- Wait for outputs to propagate and signal TestDone
    -- WaitForClock(SubordinateRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ResponderProc ;


end RandomReadWriteByte ;

Configuration TbAxi4_RandomReadWriteByte of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(RandomReadWriteByte) ; 
    end for ; 
  end for ; 
end TbAxi4_RandomReadWriteByte ; 
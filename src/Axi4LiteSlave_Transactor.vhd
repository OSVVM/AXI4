--
--  File Name:         Axi4LiteSlave_Transactor.vhd
--  Design Unit Name:  Axi4LiteSlave
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Simple AXI Lite Master Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date       Version    Description
--    09/2017:   2017       Initial revision
--
--
-- Copyright 2017 SynthWorks Design Inc
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;

  use work.Axi4TransactionPkg.all ; 
  use work.Axi4LiteInterfacePkg.all ; 
  use work.Axi4CommonPkg.all ; 

entity Axi4LiteSlave is
generic (
  tperiod_Clk     : time := 10 ns ;
  
  tpd_Clk_AWReady : time := 2 ns ; 

  tpd_Clk_WReady  : time := 2 ns ; 

  tpd_Clk_BValid  : time := 2 ns ; 
  tpd_Clk_BResp   : time := 2 ns ; 

  tpd_Clk_ARReady : time := 2 ns ; 

  tpd_Clk_RValid  : time := 2 ns ; 
  tpd_Clk_RData   : time := 2 ns ; 
  tpd_Clk_RResp   : time := 2 ns 
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- Testbench Transaction Interface
  TransRec    : inout Axi4TransactionRecType ;

  -- AXI Master Functional Interface
  AxiLiteBus  : inout Axi4LiteRecType 
) ;

    alias AWValid : std_logic        is AxiLiteBus.WriteAddress.AWValid ;
    alias AWReady : std_logic        is AxiLiteBus.WriteAddress.AWReady ;
    alias AWProt  : Axi4ProtType is AxiLiteBus.WriteAddress.AWProt ;
    alias AWAddr  : std_logic_vector is AxiLiteBus.WriteAddress.AWAddr ;

    alias WValid  : std_logic        is AxiLiteBus.WriteData.WValid ;
    alias WReady  : std_logic        is AxiLiteBus.WriteData.WReady ;
    alias WData   : std_logic_vector is AxiLiteBus.WriteData.WData ;
    alias WStrb   : std_logic_vector is AxiLiteBus.WriteData.WStrb ;

    alias BValid  : std_logic        is AxiLiteBus.WriteResponse.BValid ;
    alias BReady  : std_logic        is AxiLiteBus.WriteResponse.BReady ;
    alias BResp   : Axi4RespType is AxiLiteBus.WriteResponse.BResp ;

    alias ARValid : std_logic        is AxiLiteBus.ReadAddress.ARValid ;
    alias ARReady : std_logic        is AxiLiteBus.ReadAddress.ARReady ;
    alias ARProt  : Axi4ProtType is AxiLiteBus.ReadAddress.ARProt ;
    alias ARAddr  : std_logic_vector is AxiLiteBus.ReadAddress.ARAddr ;

    alias RValid  : std_logic        is AxiLiteBus.ReadData.RValid ;
    alias RReady  : std_logic        is AxiLiteBus.ReadData.RReady ;
    alias RData   : std_logic_vector is AxiLiteBus.ReadData.RData ;
    alias RResp   : Axi4RespType is AxiLiteBus.ReadData.RResp ;
    
end entity Axi4LiteSlave ;

architecture SlaveTransactor of Axi4LiteSlave is

  constant MODEL_INSTANCE_NAME : string     := PathTail(to_lower(Axi4LiteSlave'PATH_NAME)) ;
  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ; 
  
  shared variable WriteAddressFifo     : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 
  shared variable WriteDataFifo        : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 
  shared variable WriteTransactionFifo : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 
  shared variable WriteResponseFifo    : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 

  shared variable ReadAddressFifo      : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 
  shared variable ReadDataFifo         : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 

  -- Setup so that if no configuration is done, accept transactions 
  signal WriteAddressExpectCount     : integer := 0 ; 
  signal WriteDataExpectCount        : integer := 0 ; 
  
  signal WriteAddressReceiveCount    : integer := 0 ; 
  signal WriteDataReceiveCount       : integer := 0 ; 
  signal WriteReceiveCount           : integer := 0 ;   
  signal WriteResponseDoneCount      : integer := 0 ; 

  signal ReadAddressReceiveCount     : integer := 0 ; 
  
  signal ReadDataRequestCount        : integer := 0 ; 
  signal ReadDataDoneCount           : integer := 0 ; 
  

  signal WriteResponseTimeOutPeriod, ReadDataTimeOutPeriod : time := time'high; 
  
  signal WriteAddressReadyBeforeValid  : boolean := TRUE ; 
  signal WriteAddressReadyDelayCycles  : integer := 0 ; 
  signal WriteDataReadyBeforeValid     : boolean := TRUE ; 
  signal WriteDataReadyDelayCycles     : integer := 0 ; 
  signal ReadAddressReadyBeforeValid   : boolean := TRUE ; 
  signal ReadAddressReadyDelayCycles   : integer := 0 ; 

begin

  ------------------------------------------------------------
  -- Turn off drivers not being driven by this model
  ------------------------------------------------------------
  InitAxi4LiteRec (AxiBusRec => AxiLiteBus ) ;

  
  ------------------------------------------------------------
  --  Initialize AlertLogIDs
  ------------------------------------------------------------
  Initalize : process
    variable ID : AlertLogIDType ; 
  begin
    -- Transaction Interface
    TransRec.AxiAddrWidth   <= AWAddr'length ; 
    TransRec.AxiDataWidth   <= WData'length ; 

    -- Alerts
    ID                      := GetAlertLogID(MODEL_INSTANCE_NAME) ; 
    ModelID                 <= ID ; 
    TransRec.AlertLogID     <= ID ; 
    ProtocolID              <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Protocol Error", ID ) ;
    DataCheckID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Data Check", ID ) ;
    BusFailedID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": No response", ID ) ;

    -- FIFOs
    WriteAddressFifo.SetAlertLogID(     "AXI Slave WriteAddressFIFO"); 
    WriteDataFifo.SetAlertLogID(        "AXI Slave WriteDataFifo"); 
    WriteTransactionFifo.SetAlertLogID( "AXI Slave WriteTransactionFifo"); 
    WriteResponseFifo.SetAlertLogID(    "AXI Slave WriteResponseFifo"); 

    ReadAddressFifo.SetAlertLogID(      "AXI Slave ReadAddressFifo"); 
    ReadDataFifo.SetAlertLogID(         "AXI Slave ReadDataFifo"); 
    wait ; 
  end process Initalize ;


  ------------------------------------------------------------
  --  Transaction Dispatcher
  --    Handles transactions between TestCtrl and Model
  ------------------------------------------------------------
  TransactionDispatcher : process
    variable NoOpCycles : integer ; 
    variable WriteAddr  : AWAddr'subtype ; 
    variable WriteProt  : AWProt'subtype ;
    variable WriteData  : WData'subtype ; 
    variable WriteStrb  : WStrb'subtype ;
    variable ReadAddr   : ARAddr'subtype ; 
    variable ReadProt   : ARProt'subtype ;
    variable ReadData   : RData'subtype ; 
    variable ReadResp   : RResp'subtype ; 
  begin
    WaitForTransaction(
       Clk      => Clk,
       Rdy      => TransRec.Rdy,
       Ack      => TransRec.Ack
    ) ;

    case TransRec.Operation is
      when WRITE =>
--!TODO, how does a response value get coordinated with a write operation?        
        -- Put Response value into FIFO
        WriteResponseFifo.push(to_Axi4RespType(TransRec.Resp)) ; 
        
        wait for 0 ns ; 
        if WriteTransactionFifo.empty then 
          WaitForToggle(WriteReceiveCount) ; 
        end if ; 
        
        -- Get Write Operation from FIFO
        (WriteAddr, WriteProt, WriteData, WriteStrb) := WriteTransactionFifo.pop ;
        TransRec.Address        <= ToTransaction(WriteAddr) ; 
        TransRec.Prot           <= to_integer(WriteProt) ; 
        TransRec.DataFromModel  <= ToTransaction(Extend(WriteData, TransRec.DataFromModel'length)) ;
        TransRec.Strb           <= to_integer(WriteStrb) ; 
        wait for 0 ns ; 
        
        
      when READ =>
        -- Get Read Data Response Values
        ReadData := FromTransaction(TransRec.DataToModel) ;
        ReadResp := to_Axi4RespType(TransRec.Resp) ; 
           
        -- Expect Read Address Cycle
        if ReadAddressFifo.empty then 
          WaitForToggle(ReadAddressReceiveCount) ;
        end if ; 
        (ReadAddr, ReadProt) := ReadAddressFifo.pop ;
        TransRec.Address        <= ToTransaction(ReadAddr) ; 
        TransRec.Prot           <= to_integer(ReadProt) ; 
        
        -- Push Read Data Response Values
        ReadDataFifo.push(ReadData & ReadResp) ; 
        Increment(ReadDataRequestCount) ;
        wait for 0 ns ; 

      when NO_OP =>
        NoOpCycles := FromTransaction(TransRec.DataToModel) ;
        wait for (NoOpCycles * tperiod_Clk) - 1 ns ;
        wait until Clk = '1' ;

      when GET_ERRORS =>
        -- Report and Get Errors
        print("") ;
        ReportNonZeroAlerts(AlertLogID => ModelID) ;
        TransRec.DataFromModel <= ToTransaction(GetAlertCount(AlertLogID => ModelID), TransRec.DataFromModel'length) ;
        wait until Clk = '1' ;

      when others =>
        Alert(ModelID, "Unimplemented Transaction") ;
    end case ;

    -- Wait for 1 delta cycle, required if a wait is not in all case branches above
    wait for 0 ns ;

  end process TransactionDispatcher ;


  ------------------------------------------------------------
  --  WriteAddressHandler
  --    Execute Write Address Transactions
  ------------------------------------------------------------
  WriteAddressHandler : process
  begin 
    AWReady <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize
      
    WriteAddressOperation : loop 
      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => AWValid,
        Ready                   => AWReady,
        ReadyBeforeValid        => WriteAddressReadyBeforeValid,
        ReadyDelayCycles        => WriteAddressReadyDelayCycles,
        tperiod_Clk             => tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_AWReady
      ) ;
            
      -- capture address, prot
      WriteAddressFifo.push(AWAddr & AWProt) ;
      
      -- Signal completion
      increment(WriteAddressReceiveCount) ;
    end loop WriteAddressOperation ;
  end process WriteAddressHandler ;

  
  ------------------------------------------------------------
  --  WriteDataHandler
  --    Execute Write Data Transactions
  ------------------------------------------------------------
  WriteDataHandler : process
  begin
    WReady <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize
    
    WriteDataOperation : loop 
      ---------------------
      DoAxiReadyHandshake(
      ---------------------
        Clk                     => Clk,
        Valid                   => WValid,
        Ready                   => WReady,
        ReadyBeforeValid        => WriteDataReadyBeforeValid,
        ReadyDelayCycles        => WriteDataReadyDelayCycles,
        tperiod_Clk             => tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_WReady
      ) ;
      
      -- capture Data, wstrb
      WriteDataFifo.push(WData & WStrb) ;
      
      -- Signal completion
      increment(WriteDataReceiveCount) ;
    end loop WriteDataOperation ; 
  end process WriteDataHandler ;


  ------------------------------------------------------------
  --  WriteHandler
  --    Collect Write Address and Data transactions
  ------------------------------------------------------------
  WriteHandler : process
    variable WriteAddr  : AWAddr'subtype ; 
    variable WriteProt  : AWProt'subtype ; 
    variable WriteData  : WData'subtype ; 
    variable WriteStrb : WStrb'subtype ; 
  begin
    -- Find Write Address and Data transaction
    if WriteAddressFifo.empty then 
      WaitForToggle(WriteAddressReceiveCount) ;
    end if ;
    (WriteAddr, WriteProt) := WriteAddressFifo.pop ; 
    
    if WriteDataFifo.empty then
      WaitForToggle(WriteDataReceiveCount) ;
    end if ; 
    (WriteData, WriteStrb) := WriteDataFifo.pop ; 

--! TODO:   Add handshaking/handoff with TransactionDispatcher
--          Must be conditional so transactions do not need to pull from it
    WriteTransactionFifo.push(WriteAddr & WriteProt & WriteData & WriteStrb) ;
    increment(WriteReceiveCount) ;
    wait for 0 ns ;  -- allow update before looping

    -- Log this operation
    Log(ModelID, 
      "Address Write." &
      "  AWAddr: "  & to_hstring(WriteAddr) &
      "  AWProt: "  & to_string(WriteProt) &
      "  WData: "  & to_hstring(WriteData) &
      "  WStrb: "  & to_string(WriteStrb) &
      "  Operation# " & to_string(WriteReceiveCount),
      INFO
    ) ;
  end process WriteHandler ;

  
  ------------------------------------------------------------
  -- WriteResponseHandler
  --   Receive and Check Write Responses
  ------------------------------------------------------------
  WriteResponseHandler : process
    variable localResp : BResp'subtype ;
  begin
    -- initialize 
    BValid <= '0' ;
    BResp  <= (BResp'range => '0') ;

    WriteResponseLoop : loop 
      -- Find Transaction
      if WriteResponseDoneCount >= WriteReceiveCount then
        WaitForToggle(WriteReceiveCount) ;
      end if ; 
      if not WriteResponseFifo.Empty then
        localResp := WriteResponseFifo.pop ; 
      else
       localResp := AXI4_RESP_OKAY ;
      end if ;

      -- Do Transaction
      BResp  <= localResp  after tpd_Clk_BResp ;
      
      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk, 
        Valid          =>  BValid, 
        Ready          =>  BReady, 
        tpd_Clk_Valid  =>  tpd_Clk_BValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Response # " & to_string(WriteReceiveCount),
        TimeOutPeriod  =>  WriteResponseTimeOutPeriod
      ) ;

      Log(ModelID,
        "Write Response." &
        "  BResp: "  & to_hstring(BResp) &
        "  Operation# " & to_string(WriteReceiveCount),
        INFO
      ) ;

      -- State after operation
      BResp  <= not localResp after tpd_Clk_BResp ;

      -- Signal completion
      Increment(WriteResponseDoneCount) ;
      wait for 0 ns ; 
    end loop WriteResponseLoop ;
  end process WriteResponseHandler ;


  ------------------------------------------------------------
  --  ReadAddressHandler
  --    Execute Read Address Transactions
  ------------------------------------------------------------
  ReadAddressHandler : process
  begin
    -- Initialize
    ARReady <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize
      
    ReadAddressOperation : loop 
      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => ARValid,
        Ready                   => ARReady,
        ReadyBeforeValid        => ReadAddressReadyBeforeValid,
        ReadyDelayCycles        => ReadAddressReadyDelayCycles,
        tperiod_Clk             => tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_ARReady
      ) ;
      
      -- capture address, prot
      ReadAddressFifo.push(ARAddr & ARProt) ;
      increment(ReadAddressReceiveCount) ;

      Log(ModelID,
        "Read Operation." &
        "  ARAddr: "  & to_hstring(ARAddr) &
        "  ARProt: "  & to_string(ARProt) &
        "  Operation# " & to_string(ReadAddressReceiveCount),
        INFO
      ) ;
    end loop ReadAddressOperation ;
  end process ReadAddressHandler ;


  ------------------------------------------------------------
  --  ReadDataHandler
  --    Receive Read Data Transactions
  ------------------------------------------------------------
  ReadDataHandler : process
    variable ReadData  : RData'subtype ;
    variable ReadResp  : RResp'subtype ;
  begin
    -- initialize
    RValid <= '0' ;
    RData  <= (RData'range => '0') ;
    RResp  <= (RResp'range => '0') ;

    ReadDataLoop : loop 
      -- Start a Read Data Response Transaction after receiving a read address
      if ReadAddressReceiveCount <= ReadDataDoneCount then 
        WaitForToggle(ReadAddressReceiveCount) ;
      end if ; 
      
      if ReadDataFifo.Empty then
        WaitForToggle(ReadDataRequestCount) ;
      end if ; 
      
      (ReadData, ReadResp) := ReadDataFifo.pop ; 
      
--      -- Find Response if available
--      if not ReadDataFifo.Empty then
--        (ReadData, ReadResp) := ReadDataFifo.pop ; 
--      else
--        ReadData := to_slv(ReadAddressReceiveCount, RData'length) ;
--        ReadResp := AXI4_RESP_OKAY ;
--      end if ;

      -- Transaction Values 
      RData  <= ReadData  after tpd_Clk_RDATA ;
      RResp  <= ReadResp  after tpd_Clk_RResp ;
      
      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk, 
        Valid          =>  RValid, 
        Ready          =>  RReady, 
        tpd_Clk_Valid  =>  tpd_Clk_RValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Read Data # " & to_string(ReadAddressReceiveCount),
        TimeOutPeriod  =>  ReadDataTimeOutPeriod
      ) ;

      Log(ModelID,
        "Read Operation." &
        "  RData: "  & to_hstring(RData) &
        "  RResp: "  & to_hstring(RResp) &
        "  Operation# " & to_string(ReadAddressReceiveCount),
        INFO
      ) ;

      -- State after operation
      RValid <= '0' after tpd_Clk_RValid ;
      RData  <= not ReadData after tpd_clk_RData ; 
      RResp  <= not ReadResp after tpd_Clk_RResp ;

      -- Signal completion
      Increment(ReadDataDoneCount) ;
      wait for 0 ns ; 
    end loop ReadDataLoop ; 
  end process ReadDataHandler ;

end architecture SlaveTransactor ;

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
--      Simple AXI Lite Slave Tansactor Model
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

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;

  use work.Axi4LiteSlaveOptionsTypePkg.all ;
  use work.Axi4LiteSlaveTransactionPkg.all ;
  use work.Axi4LiteInterfacePkg.all ;
  use work.Axi4CommonPkg.all ;

entity Axi4LiteSlave is
generic (
  MODEL_ID_NAME   : string :="" ;
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
  TransRec    : inout AddressBusSlaveTransactionRecType ;

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

  constant AXI_ADDR_WIDTH : integer := AWAddr'length ;
  constant AXI_DATA_WIDTH : integer := WData'length ;
  constant AXI_DATA_BYTE_WIDTH : integer := AXI_DATA_WIDTH / 8 ;

  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4LiteSlave'PATH_NAME))) ;

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


  signal WriteResponseReadyTimeOut, ReadDataReadyTimeOut : integer := 25 ;

  signal WriteAddressReadyBeforeValid  : boolean := TRUE ;
  signal WriteAddressReadyDelayCycles  : integer := 0 ;
  signal WriteDataReadyBeforeValid     : boolean := TRUE ;
  signal WriteDataReadyDelayCycles     : integer := 0 ;
  signal ReadAddressReadyBeforeValid   : boolean := TRUE ;
  signal ReadAddressReadyDelayCycles   : integer := 0 ;

  signal ModelWriteProt : Axi4ProtType := (others => '0') ;
  signal ModelReadProt  : Axi4ProtType := (others => '0') ;

  signal ModelWriteResp : Axi4RespType := to_Axi4RespType(OKAY) ;
  signal ModelReadResp  : Axi4RespType := to_Axi4RespType(OKAY) ;

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
--    TransRec.AxiAddrWidth   <= AWAddr'length ;
--    TransRec.AxiDataWidth   <= WData'length ;

    -- Alerts
    ID                      := GetAlertLogID(MODEL_INSTANCE_NAME) ;
    ModelID                 <= ID ;
--    TransRec.AlertLogID     <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Transaction", ID ) ;
    ProtocolID              <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Protocol Error", ID ) ;
    DataCheckID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Data Check", ID ) ;
    BusFailedID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": No response", ID ) ;

    -- FIFOS.  FIFOS share main ID as they only generate errors if the model uses them wrong
    WriteAddressFifo.SetAlertLogID(ID);
    WriteAddressFifo.SetName(     MODEL_INSTANCE_NAME & ": WriteAddressFIFO");
    WriteDataFifo.SetAlertLogID(ID);
    WriteDataFifo.SetName(        MODEL_INSTANCE_NAME & ": WriteDataFifo");
    WriteTransactionFifo.SetAlertLogID(ID);
    WriteTransactionFifo.SetName( MODEL_INSTANCE_NAME & ": WriteTransactionFifo");
    WriteResponseFifo.SetAlertLogID(ID);
    WriteResponseFifo.SetName(    MODEL_INSTANCE_NAME & ": WriteResponseFifo");

    ReadAddressFifo.SetAlertLogID(ID);
    ReadAddressFifo.SetName(      MODEL_INSTANCE_NAME & ": ReadAddressFifo");
    ReadDataFifo.SetAlertLogID(ID);
    ReadDataFifo.SetName(         MODEL_INSTANCE_NAME & ": ReadDataFifo");
    wait ;
  end process Initalize ;


  ------------------------------------------------------------
  --  Transaction Dispatcher
  --    Handles transactions between TestCtrl and Model
  ------------------------------------------------------------
  TransactionDispatcher : process
    variable WaitClockCycles : integer ;
    variable WriteAddr  : AWAddr'subtype ;
    variable WriteProt  : AWProt'subtype ;
    variable WriteData  : WData'subtype ;
    variable WriteStrb  : WStrb'subtype ;
    variable WriteResp  : BResp'subtype ;
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
      when WAIT_CLOCK =>
        WaitClockCycles := FromTransaction(TransRec.DataToModel) ;
        wait for (WaitClockCycles * tperiod_Clk) - 1 ns ;
        wait until Clk = '1' ;

      when GET_ALERTLOG_ID =>
        TransRec.IntFromModel <= integer(ModelID) ;
        wait until Clk = '1' ;

      when GET_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= WriteAddressReceiveCount + ReadAddressReceiveCount ;
        wait until Clk = '1' ;

      when GET_WRITE_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= WriteAddressReceiveCount ;
        wait until Clk = '1' ;

      when GET_READ_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= ReadAddressReceiveCount ;
        wait until Clk = '1' ;    

      when WRITE =>
        WriteResponseFifo.push(ModelWriteResp) ;

        wait for 0 ns ;
        if WriteTransactionFifo.empty then
          WaitForToggle(WriteReceiveCount) ;
        end if ;

        -- Get Write Operation from FIFO
        (WriteAddr, WriteProt, WriteData, WriteStrb) := WriteTransactionFifo.pop ;
        TransRec.Address        <= ToTransaction(WriteAddr) ;
        AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Slave Get Write, Address length does not match", FAILURE) ;
--!TODO Add Check here for actual PROT vs expected PROT
--        TransRec.Prot           <= to_integer(WriteProt) ;

        TransRec.DataFromModel  <= ToTransaction(Extend(WriteData, TransRec.DataFromModel'length)) ;

        -- Data Sizing Checks
        AlertIf(ModelID, TransRec.DataWidth > AXI_DATA_WIDTH, "Slave Get Write, Expected Data length to large", FAILURE) ;
        AlertIf(ModelID, TransRec.DataWidth mod 8 /= 0, "Slave Get Write, Expected Data not on a byte boundary", FAILURE) ;

--!TODO replace with data width checking here
--        variable ByteCount : integer ;
--        ByteCount := TransRec.DataWidth / 8 ;
--        TransRec.Strb           <= to_integer(WriteStrb) ;


        wait for 0 ns ;


      when READ =>
        -- Get Read Data Response Values
        ReadData := FromTransaction(TransRec.DataToModel) ;

        -- Expect Read Address Cycle
        if ReadAddressFifo.empty then
          WaitForToggle(ReadAddressReceiveCount) ;
        end if ;
        (ReadAddr, ReadProt) := ReadAddressFifo.pop ;
        TransRec.Address        <= ToTransaction(ReadAddr) ;
        AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Slave Read, Address length does not match", FAILURE) ;
--!TODO Add Check here for actual PROT vs expected PROT
--        TransRec.Prot           <= to_integer(ReadProt) ;

        -- Push Read Data Response Values
        ReadDataFifo.push(ReadData & ModelReadResp) ;

        -- Data Sizing Checks
        AlertIf(ModelID, TransRec.DataWidth > AXI_DATA_WIDTH, "Slave Read, Data length to large", FAILURE) ;
        AlertIf(ModelID, TransRec.DataWidth mod 8 /= 0, "Slave Read, Data not on a byte boundary", FAILURE) ;
--!TODO replace with data width checking here
--        variable ByteCount : integer ;
--        ByteCount := TransRec.DataWidth / 8 ;
--        Check ReadStrb and Byte Count to make sure they correlate
        Increment(ReadDataRequestCount) ;
        wait for 0 ns ;

      when SET_MODEL_OPTIONS =>
        -- Set Model Options
        case TransRec.Options is
          -- Slave Ready TimeOut Checks
          when WRITE_RESPONSE_READY_TIME_OUT =>       WriteResponseReadyTimeOut     <= TransRec.IntToModel ;
          when READ_DATA_READY_TIME_OUT =>            ReadDataReadyTimeOut          <= TransRec.IntToModel ;
          -- Slave Ready Before Valid
          when WRITE_ADDRESS_READY_BEFORE_VALID =>    WriteAddressReadyBeforeValid  <= TransRec.BoolToModel ;
          when WRITE_DATA_READY_BEFORE_VALID =>       WriteDataReadyBeforeValid     <= TransRec.BoolToModel ;
          when READ_ADDRESS_READY_BEFORE_VALID =>     ReadAddressReadyBeforeValid   <= TransRec.BoolToModel ;
          -- Slave Ready Delay Cycles
          when WRITE_ADDRESS_READY_DELAY_CYCLES =>    WriteAddressReadyDelayCycles  <= TransRec.IntToModel ;
          when WRITE_DATA_READY_DELAY_CYCLES =>       WriteDataReadyDelayCycles     <= TransRec.IntToModel ;
          when READ_ADDRESS_READY_DELAY_CYCLES =>     ReadAddressReadyDelayCycles   <= TransRec.IntToModel ;
          -- Slave PROT Settings
          when WRITE_PROT =>                          ModelWriteProt <= to_slv(TransRec.IntToModel, ModelWriteProt'length) ;
          when READ_PROT =>                           ModelReadProt  <= to_slv(TransRec.IntToModel, ModelReadProt'length) ;
          -- Slave RESP Settings
          when WRITE_RESP =>                          ModelWriteResp <= to_slv(TransRec.IntToModel, ModelWriteResp'length) ;
          when READ_RESP =>                           ModelReadResp  <= to_slv(TransRec.IntToModel, ModelReadResp'length) ;
          --
          -- The End -- Done
          when others =>
            Alert(ModelID, "Unimplemented Option", FAILURE) ;
        end case ;
        wait for 0 ns ;
        
      when GET_MODEL_OPTIONS =>
        -- Set Model Options
        case TransRec.Options is
          -- Slave Ready TimeOut Checks
          when WRITE_RESPONSE_READY_TIME_OUT =>       TransRec.IntFromModel  <= WriteResponseReadyTimeOut ;
          when READ_DATA_READY_TIME_OUT =>            TransRec.IntFromModel  <= ReadDataReadyTimeOut ;
          -- Slave Ready Before Valid
          when WRITE_ADDRESS_READY_BEFORE_VALID =>    TransRec.BoolFromModel <= WriteAddressReadyBeforeValid ;
          when WRITE_DATA_READY_BEFORE_VALID =>       TransRec.BoolFromModel <= WriteDataReadyBeforeValid    ;
          when READ_ADDRESS_READY_BEFORE_VALID =>     TransRec.BoolFromModel <= ReadAddressReadyBeforeValid  ;
          -- Slave Ready Delay Cycles
          when WRITE_ADDRESS_READY_DELAY_CYCLES =>    TransRec.IntFromModel  <= WriteAddressReadyDelayCycles ;
          when WRITE_DATA_READY_DELAY_CYCLES =>       TransRec.IntFromModel  <= WriteDataReadyDelayCycles    ;
          when READ_ADDRESS_READY_DELAY_CYCLES =>     TransRec.IntFromModel  <= ReadAddressReadyDelayCycles  ;
          -- Slave PROT Settings
          when WRITE_PROT =>                          TransRec.IntFromModel <= to_integer(ModelWriteProt) ;
          when READ_PROT =>                           TransRec.IntFromModel <= to_integer(ModelReadProt ) ;
          -- Slave RESP Settings
          when WRITE_RESP =>                          TransRec.IntFromModel <= to_integer(ModelWriteResp) ;
          when READ_RESP =>                           TransRec.IntFromModel <= to_integer(ModelReadResp) ;
          --
          -- The End -- Done
          when others =>
            Alert(ModelID, "Unimplemented Option", FAILURE) ;
        end case ;
        wait for 0 ns ;

      when others =>
        Alert(ModelID, "Unimplemented Transaction", FAILURE) ;
        wait for 0 ns ;
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
        ReadyDelayCycles        => WriteAddressReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_AWReady
      ) ;

      -- capture address, prot
      WriteAddressFifo.push(AWAddr & AWProt) ;

      -- Log this operation
      Log(ModelID,
        "Write Address." &
        "  AWAddr: "  & to_hstring(AWAddr) &
        "  AWProt: "  & to_string(AWProt) &
        "  Operation# " & to_string(WriteAddressReceiveCount + 1),
        INFO
      ) ;

    -- Signal completion
      increment(WriteAddressReceiveCount) ;
      wait for 0 ns ;
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
        ReadyDelayCycles        => WriteDataReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_WReady
      ) ;

      -- capture Data, wstrb
      WriteDataFifo.push(WData & WStrb) ;

    -- Log this operation
    Log(ModelID,
      "Write Data." &
      "  WData: "  & to_hstring(WData) &
      "  WStrb: "  & to_string(WStrb) &
      "  Operation# " & to_string(WriteDataReceiveCount + 1),
      INFO
    ) ;

      -- Signal completion
      increment(WriteDataReceiveCount) ;
      wait for 0 ns ;
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
      "Write Operation." &
      "  AWAddr: "  & to_hstring(WriteAddr) &
      "  AWProt: "  & to_string(WriteProt) &
      "  WData: "  & to_hstring(WriteData) &
      "  WStrb: "  & to_string(WriteStrb) &
      "  Operation# " & to_string(WriteReceiveCount),
      DEBUG
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
--! Done always less than Receive, change to just "="
--! ">" will break due to roll over if there are more than 2**30 transfers
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

      Log(ModelID,
        "Write Response." &
        "  BResp: "  & to_hstring(localResp) &
        "  Operation# " & to_string(WriteResponseDoneCount + 1),
        INFO
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  BValid,
        Ready          =>  BReady,
        tpd_Clk_Valid  =>  tpd_Clk_BValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Response # " & to_string(WriteResponseDoneCount + 1),
        TimeOutPeriod  =>  WriteResponseReadyTimeOut * tperiod_Clk
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
        ReadyDelayCycles        => ReadAddressReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_ARReady
      ) ;

      -- capture address, prot
      ReadAddressFifo.push(ARAddr & ARProt) ;
      increment(ReadAddressReceiveCount) ;
      wait for 0 ns ;

      Log(ModelID,
        "Read Address." &
        "  ARAddr: "  & to_hstring(ARAddr) &
        "  ARProt: "  & to_string(ARProt) &
        "  Operation# " & to_string(ReadAddressReceiveCount), -- adjusted for delay of ReadAddressReceiveCount
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

      Log(ModelID,
        "Read Data." &
        "  RData: "  & to_hstring(ReadData) &
        "  RResp: "  & to_hstring(ReadResp) &
        "  Operation# " & to_string(ReadDataDoneCount + 1),
        INFO
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  RValid,
        Ready          =>  RReady,
        tpd_Clk_Valid  =>  tpd_Clk_RValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Read Data # " & to_string(ReadDataDoneCount + 1),
        TimeOutPeriod  =>  ReadDataReadyTimeOut * tperiod_Clk
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

--
--  File Name:         Axi4LiteMaster.vhd
--  Design Unit Name:  Axi4LiteMaster
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      AXI Full Master Model
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
--    04/2018   2018.04    First Release
--    01/2020   2020.01    Updated license notice
--    07/2020   2020.07    Created Axi4 FULL from Axi4Lite
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
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

  use work.Axi4OptionsTypePkg.all ;
  use work.Axi4ModelPkg.all ;
  use work.Axi4LiteInterfacePkg.all ;
  use work.Axi4CommonPkg.all ;

entity Axi4LiteMaster is
generic (
  MODEL_ID_NAME    : string :="" ;
  tperiod_Clk      : time   := 10 ns ;

  tpd_Clk_AWAddr   : time   := 2 ns ;
  tpd_Clk_AWProt   : time   := 2 ns ;
  tpd_Clk_AWValid  : time   := 2 ns ;
  -- AXI4 Full
  tpd_clk_AWLen    : time   := 2 ns ;
  tpd_clk_AWID     : time   := 2 ns ;
  tpd_clk_AWSize   : time   := 2 ns ;
  tpd_clk_AWBurst  : time   := 2 ns ;
  tpd_clk_AWLock   : time   := 2 ns ;
  tpd_clk_AWCache  : time   := 2 ns ;
  tpd_clk_AWQOS    : time   := 2 ns ;
  tpd_clk_AWRegion : time   := 2 ns ;
  tpd_clk_AWUser   : time   := 2 ns ;

  tpd_Clk_WValid   : time   := 2 ns ;
  tpd_Clk_WData    : time   := 2 ns ;
  tpd_Clk_WStrb    : time   := 2 ns ;
  -- AXI4 Full
  tpd_Clk_WLast    : time   := 2 ns ;
  tpd_Clk_WUser    : time   := 2 ns ;
  -- AXI3
  tpd_Clk_WID      : time   := 2 ns ;

  tpd_Clk_BReady   : time   := 2 ns ;

  tpd_Clk_ARValid  : time   := 2 ns ;
  tpd_Clk_ARProt   : time   := 2 ns ;
  tpd_Clk_ARAddr   : time   := 2 ns ;
  -- AXI4 Full
  tpd_clk_ARLen    : time   := 2 ns ;
  tpd_clk_ARID     : time   := 2 ns ;
  tpd_clk_ARSize   : time   := 2 ns ;
  tpd_clk_ARBurst  : time   := 2 ns ;
  tpd_clk_ARLock   : time   := 2 ns ;
  tpd_clk_ARCache  : time   := 2 ns ;
  tpd_clk_ARQOS    : time   := 2 ns ;
  tpd_clk_ARRegion : time   := 2 ns ;
  tpd_clk_ARUser   : time   := 2 ns ;

  tpd_Clk_RReady   : time   := 2 ns
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- AXI Master Functional Interface
  AxiBus      : inout Axi4LiteRecType ;

  -- Testbench Transaction Interface
  TransRec    : inout AddressBusRecType
) ;

  -- External Burst Interface
  shared variable WriteBurstFifo              : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable ReadBurstFifo               : osvvm.ScoreboardPkg_slv.ScoreboardPType ;

end entity Axi4LiteMaster ;
architecture AxiFull of Axi4LiteMaster is

  alias    AxiAddr is AxiBus.WriteAddress.Addr ;
  alias    AxiData is AxiBus.WriteData.Data ;
  constant AXI_ADDR_WIDTH : integer := AxiAddr'length ;
  constant AXI_DATA_WIDTH : integer := AxiData'length ;
  constant AXI_DATA_BYTE_WIDTH : integer := AXI_DATA_WIDTH / 8 ;
  constant AXI_BYTE_ADDR_WIDTH : integer := integer(ceil(log2(real(AXI_DATA_BYTE_WIDTH)))) ;
  constant AXI_STRB_WIDTH : integer := AXI_DATA_WIDTH/8 ;

  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, to_lower(PathTail(Axi4LiteMaster'PATH_NAME))) ;
  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ;

  -- Internal Resources
  shared variable WriteAddressFifo            : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable WriteDataFifo               : osvvm.ScoreboardPkg_slv.ScoreboardPType ;

  shared variable ReadAddressFifo             : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable ReadAddressTransactionFifo  : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable ReadDataFifo                : osvvm.ScoreboardPkg_slv.ScoreboardPType ;

  shared variable WriteResponseScoreboard     : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable ReadResponseScoreboard      : osvvm.ScoreboardPkg_slv.ScoreboardPType ;

  signal WriteAddressRequestCount, WriteAddressDoneCount      : integer := 0 ;
  signal WriteDataRequestCount,    WriteDataDoneCount         : integer := 0 ;
  signal WriteResponseExpectCount, WriteResponseReceiveCount  : integer := 0 ;
  signal ReadAddressRequestCount,  ReadAddressDoneCount       : integer := 0 ;
  signal ReadDataExpectCount,      ReadDataReceiveCount       : integer := 0 ;

  signal WriteResponseActive, ReadDataActive : boolean ;

  -- Model Configuration
  shared variable params : ModelParametersPType ;

--  signal BurstFifoMode     : integer := ADDRESS_BUS_BURST_WORD_MODE ;
  signal BurstFifoMode     : integer := ADDRESS_BUS_BURST_BYTE_MODE ;
  signal BurstFifoByteMode : boolean := (BurstFifoMode = ADDRESS_BUS_BURST_BYTE_MODE) ; 

begin

  ------------------------------------------------------------
  -- Turn off drivers not being driven by this model
  ------------------------------------------------------------
  InitAxi4LiteRec (AxiBusRec => AxiBus) ;


  ------------------------------------------------------------
  --  Initialize alerts
  ------------------------------------------------------------
  Initialize : process
    variable ID : AlertLogIDType ;
  begin
    InitAxiOptions(Params) ;

    -- Alerts
    ID                      := GetAlertLogID(MODEL_INSTANCE_NAME) ;
    ModelID                 <= ID ;
    ProtocolID              <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Protocol Error", ID ) ;
    DataCheckID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Data Check", ID ) ;
    BusFailedID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": No response", ID ) ;

    WriteBurstFifo.SetAlertLogID( MODEL_INSTANCE_NAME & ": Write Burst FIFO", ID) ;
    ReadBurstFifo.SetAlertLogID( MODEL_INSTANCE_NAME & ": Read Burst FIFO", ID) ;
    WriteResponseScoreboard.SetAlertLogID( MODEL_INSTANCE_NAME & ": WriteResponse Scoreboard", ID);
    ReadResponseScoreboard.SetAlertLogID(  MODEL_INSTANCE_NAME & ": ReadResponse Scoreboard",  ID);

    -- FIFOS.  FIFOS share main ID as they only generate errors if the model uses them wrong
    WriteAddressFifo.SetAlertLogID(ID);
    WriteDataFifo.SetAlertLogID(ID);
    ReadAddressFifo.SetAlertLogID(ID);
    ReadAddressTransactionFifo.SetAlertLogID(ID);
    ReadDataFifo.SetAlertLogID(ID);

    -- Giving each FIFO a unique name
    WriteAddressFifo.SetName(            MODEL_INSTANCE_NAME & ": WriteAddressFIFO");
    WriteDataFifo.SetName(               MODEL_INSTANCE_NAME & ": WriteDataFifo");
    ReadAddressFifo.SetName(             MODEL_INSTANCE_NAME & ": ReadAddressFifo");
    ReadAddressTransactionFifo.SetName(  MODEL_INSTANCE_NAME & ": ReadAddressTransactionFifo");
    ReadDataFifo.SetName(                MODEL_INSTANCE_NAME & ": ReadDataFifo");

    wait ;
  end process Initialize ;


  ------------------------------------------------------------
  --  Transaction Dispatcher
  --    Dispatches transactions to
  ------------------------------------------------------------
  TransactionDispatcher : process
    variable WaitClockCycles    : integer ;
    variable ReadDataTransactionCount : integer := 1 ;
    variable ByteCount          : integer ;
    variable TransfersInBurst   : integer ;

    variable Axi4Option    : Axi4OptionsType ;
    variable Axi4OptionVal : integer ;

--!GHDL    variable AxiDefaults    : AxiBus'subtype ;
    variable AxiDefaults    : Axi4LiteRecType(
      WriteAddress( Addr(AXI_ADDR_WIDTH-1 downto 0) ),
      WriteData   ( Data (AXI_DATA_WIDTH-1 downto 0),   Strb(AXI_STRB_WIDTH-1 downto 0) ),
      ReadAddress ( Addr(AXI_ADDR_WIDTH-1 downto 0) ),
      ReadData    ( Data (AXI_DATA_WIDTH-1 downto 0) )
    ) ;    
    alias    LAW is AxiDefaults.WriteAddress ;
    alias    LWD is AxiDefaults.WriteData ;
    alias    LWR is AxiDefaults.WriteResponse ;
    alias    LAR is AxiDefaults.ReadAddress ;
    alias    LRD is AxiDefaults.ReadData ;

    variable WriteByteAddr   : integer ;
    alias    WriteAddress    is LAW.Addr ;

    variable BytesToSend              : integer ;
    variable BytesPerTransfer         : integer ;
    variable MaxBytesInFirstTransfer  : integer ;
    alias    WriteData       is LWD.Data ;
    alias    WriteStrb       is LWD.Strb ;

    variable BytesInTransfer : integer ;
    variable BytesToReceive  : integer ;
    variable DataBitOffset   : integer ;

    variable ReadByteAddr    : integer ;
    alias    ReadAddress     is LAR.Addr ;
    alias    DefaultReadProt is LAR.Prot ;

--!GHDL    variable ReadProt        : DefaultReadProt'subtype ;
    variable ReadProt        : Axi4ProtType ;

    alias    ReadData    is LRD.Data ;

--!GHDL    variable ExpectedData    : ReadData'subtype ;
    variable ExpectedData    : std_logic_vector(ReadData'range) ;

    variable Operation       : AddressBusOperationType ;
  begin
    
    AxiDefaults.WriteAddress.Prot  := (others => '0') ;
    AxiDefaults.WriteResponse.Resp := to_Axi4RespType(OKAY);
    AxiDefaults.ReadAddress.Prot   := (others => '0') ;
    AxiDefaults.ReadData.Resp      := to_Axi4RespType(OKAY) ;

    loop
      WaitForTransaction(
         Clk      => Clk,
         Rdy      => TransRec.Rdy,
         Ack      => TransRec.Ack
      ) ;

      Operation := TransRec.Operation ;

      case Operation is
        -- Execute Standard Directive Transactions
        when WAIT_FOR_TRANSACTION =>
          -- Waits for All WRITE and READ Transactions to complete
          if WriteAddressRequestCount /= WriteAddressDoneCount then
            -- Block until both write address done.
            wait until WriteAddressRequestCount = WriteAddressDoneCount ;
          end if ;
          if WriteDataRequestCount /= WriteDataDoneCount then
            -- Block until both write data done.
            wait until WriteDataRequestCount = WriteDataDoneCount ;
          end if ;
          if WriteResponseExpectCount /= WriteResponseReceiveCount then
            -- Block until both write response done.
            wait until WriteResponseExpectCount = WriteResponseReceiveCount ;
          end if ;

          if ReadAddressRequestCount /= ReadAddressDoneCount then
            -- Block until both read address done.
            wait until ReadAddressRequestCount = ReadAddressDoneCount ;
          end if ;
          if ReadDataExpectCount /= ReadDataReceiveCount then
            -- Block until both read data done.
            wait until ReadDataExpectCount = ReadDataReceiveCount ;
          end if ;

        when WAIT_FOR_WRITE_TRANSACTION =>
          if WriteAddressRequestCount /= WriteAddressDoneCount then
            -- Block until both write address done.
            wait until WriteAddressRequestCount = WriteAddressDoneCount ;
          end if ;
          if WriteDataRequestCount /= WriteDataDoneCount then
            -- Block until both write data done.
            wait until WriteDataRequestCount = WriteDataDoneCount ;
          end if ;
          if WriteResponseExpectCount /= WriteResponseReceiveCount then
            -- Block until both write response done.
            wait until WriteResponseExpectCount = WriteResponseReceiveCount ;
          end if ;
          wait for 0 ns ; 

        when WAIT_FOR_READ_TRANSACTION =>
          if ReadAddressRequestCount /= ReadAddressDoneCount then
            -- Block until both read address done.
            wait until ReadAddressRequestCount = ReadAddressDoneCount ;
          end if ;
          if ReadDataExpectCount /= ReadDataReceiveCount then
            -- Block until both read data done.
            wait until ReadDataExpectCount = ReadDataReceiveCount ;
          end if ;
          wait for 0 ns ; 

        when WAIT_FOR_CLOCK =>
          WaitClockCycles := FromTransaction(TransRec.DataToModel) ;
          wait for (WaitClockCycles * tperiod_Clk) - 1 ns ;
          wait until Clk = '1' ;

        when GET_ALERTLOG_ID =>
          TransRec.IntFromModel <= integer(ModelID) ;
          wait until Clk = '1' ;

        when SET_BURST_MODE =>                      
          BurstFifoMode       <= TransRec.IntToModel ;
          BurstFifoByteMode   <= (TransRec.IntToModel = STREAM_BURST_BYTE_MODE) ;
          wait for 0 ns ; 
          AlertIf(ModelID, IsAddressBusBurstMode(BurstFifoMode), 
            "Invalid Burst Mode " & to_string(BurstFifoMode), FAILURE) ;
              
        when GET_BURST_MODE =>                      
          TransRec.IntToModel <= BurstFifoMode ;

        when GET_TRANSACTION_COUNT =>
          TransRec.IntFromModel <= WriteAddressDoneCount + ReadAddressDoneCount ;
          wait until Clk = '1' ;

        when GET_WRITE_TRANSACTION_COUNT =>
          TransRec.IntFromModel <= WriteAddressDoneCount ;
          wait until Clk = '1' ;

        when GET_READ_TRANSACTION_COUNT =>
          TransRec.IntFromModel <= ReadAddressDoneCount ;
          wait until Clk = '1' ;

        -- Model Transaction Dispatch
        when WRITE_OP | WRITE_ADDRESS | WRITE_DATA | ASYNC_WRITE | ASYNC_WRITE_ADDRESS | ASYNC_WRITE_DATA =>
          -- For All Write Operations - Write Address and Write Data
          WriteAddress  := FromTransaction(TransRec.Address, WriteAddress'length) ;
          WriteByteAddr := CalculateAxiByteAddress(WriteAddress, AXI_BYTE_ADDR_WIDTH);

          if IsWriteAddress(Operation) then
            -- AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Write Address length does not match", FAILURE) ;

            -- Initiate Write Address
            WriteAddressFifo.Push(WriteAddress  & LAW.Prot) ;
            Increment(WriteAddressRequestCount) ;

            -- Queue Write Response
            WriteResponseScoreboard.Push(LWR.Resp) ;
            Increment(WriteResponseExpectCount) ;
          end if ;

          if IsWriteData(Operation) then
            -- Single Transfer Write Data Handling
            CheckDataIsBytes(ModelID, WriteDataRequestCount+1, TransRec.DataWidth) ;
            CheckDataWidth  (ModelID, WriteDataRequestCount+1, TransRec.DataWidth, WriteByteAddr, AXI_DATA_WIDTH) ;
            WriteData  := AlignAxiWriteData(FromTransaction(TransRec.DataToModel), TransRec.DataWidth, WriteByteAddr) ;
            WriteStrb  := CalculateAxiWriteStrobe(WriteData) ;
            WriteDataFifo.Push(WriteData & WriteStrb) ;

            Increment(WriteDataRequestCount) ;
          end if ;

          -- Transaction wait time and allow RequestCounts a delta cycle to update
          wait for 0 ns ;  wait for 0 ns ;

          if IsBlockOnWriteAddress(Operation) and
              WriteAddressRequestCount /= WriteAddressDoneCount then
            -- Block until both write address done.
            wait until WriteAddressRequestCount = WriteAddressDoneCount ;
          end if ;
          if IsBlockOnWriteData(Operation) and
              WriteDataRequestCount /= WriteDataDoneCount then
            -- Block until both write data done.
            wait until WriteDataRequestCount = WriteDataDoneCount ;
          end if ;


        -- Model Transaction Dispatch
        when WRITE_BURST | ASYNC_WRITE_BURST =>
          WriteAddress  := FromTransaction(TransRec.Address) ;
          WriteByteAddr := CalculateAxiByteAddress(WriteAddress, AXI_BYTE_ADDR_WIDTH);
          BytesPerTransfer := AXI_DATA_BYTE_WIDTH ;

          if IsWriteAddress(Operation) then
            -- Write Address Handling
--!! Translate into multiple single cycle addresses          
            -- Burst transfer, calculate burst length
--            WriteBurstLen := to_slv(CalculateAxiBurstLen(TransRec.DataWidth, WriteByteAddr, BytesPerTransfer), WriteBurstLen'length) ;

            -- Initiate Write Address
            WriteAddressFifo.Push(WriteAddress  & LAW.Prot) ;

            Increment(WriteAddressRequestCount) ;

            -- Queue Write Response
            WriteResponseScoreboard.Push(LWR.Resp) ;
            Increment(WriteResponseExpectCount) ;
          end if ;

          if IsWriteData(Operation) then
            if BurstFifoByteMode then 
              BytesToSend       := TransRec.DataWidth ;
              TransfersInBurst  := 1 + CalculateAxiBurstLen(BytesToSend, WriteByteAddr, BytesPerTransfer) ;
            else
              TransfersInBurst := TransRec.DataWidth ;
            end if ; 
            
           PopWriteBurstData(WriteBurstFifo, BurstFifoMode, WriteData, WriteStrb, BytesToSend, WriteByteAddr) ;

            for BurstLoop in TransfersInBurst downto 2 loop    
              WriteDataFifo.Push(WriteData & WriteStrb) ;
              PopWriteBurstData(WriteBurstFifo, BurstFifoMode, WriteData, WriteStrb, BytesToSend, 0) ;
            end loop ; 
            
            -- Special handle last push
            WriteDataFifo.Push(WriteData & WriteStrb) ;

            -- Increment(WriteDataRequestCount) ;
            WriteDataRequestCount <= WriteDataRequestCount + TransfersInBurst ;
          end if ;

          -- Transaction wait time and allow RequestCounts a delta cycle to update
          wait for 0 ns ;  wait for 0 ns ;

          if IsBlockOnWriteAddress(Operation) and
              WriteAddressRequestCount /= WriteAddressDoneCount then
            -- Block until both write address done.
            wait until WriteAddressRequestCount = WriteAddressDoneCount ;
          end if ;
          if IsBlockOnWriteData(Operation) and
              WriteDataRequestCount /= WriteDataDoneCount then
            -- Block until both write data done.
            wait until WriteDataRequestCount = WriteDataDoneCount ;
          end if ;

        when READ_OP | READ_CHECK | READ_ADDRESS | READ_DATA | READ_DATA_CHECK | ASYNC_READ_ADDRESS | ASYNC_READ_DATA | ASYNC_READ_DATA_CHECK =>
          if IsReadAddress(Operation) then
            -- Send Read Address to Read Address Handler and Read Data Handler
            ReadAddress   :=  FromTransaction(TransRec.Address) ;
            ReadByteAddr  :=  CalculateAxiByteAddress(ReadAddress, AXI_BYTE_ADDR_WIDTH);
            AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Read Address length does not match", FAILURE) ;
--            BytesPerTransfer := 2**to_integer(LAR.Size);
            BytesPerTransfer := AXI_DATA_BYTE_WIDTH ;

            ReadAddressFifo.Push(ReadAddress & LAR.Prot) ;
            ReadAddressTransactionFifo.Push(ReadAddress & LAR.Prot);
            Increment(ReadAddressRequestCount) ;

            -- Expect a Read Data Cycle
            ReadResponseScoreboard.Push(LRD.Resp) ;
            increment(ReadDataExpectCount) ;
          end if ;

          if IsTryReadData(Operation) and ReadDataFifo.Empty then
            -- Data not available
            -- ReadDataReceiveCount < ReadDataTransactionCount then
            TransRec.BoolFromModel <= FALSE ;
          elsif IsReadData(Operation) then
            (ReadAddress, ReadProt) := ReadAddressTransactionFifo.Pop ;

            -- Wait for Data Ready
            if ReadDataFifo.Empty then
              WaitForToggle(ReadDataReceiveCount) ;
            end if ;
            TransRec.BoolFromModel <= TRUE ;

            -- Get Read Data
            ReadData := ReadDataFifo.Pop ;
            AxiReadDataAlignCheck (ModelID, ReadData, TransRec.DataWidth, ReadAddress, AXI_DATA_BYTE_WIDTH, AXI_BYTE_ADDR_WIDTH) ;
            TransRec.DataFromModel <= ToTransaction(ReadData) ;

            -- Check or Log Read Data
            if IsReadCheck(TransRec.Operation) then
              ExpectedData := FromTransaction(TransRec.DataToModel) ;
  --!!9 TODO:  Change format to Transaction #, Address, Prot, Read Data
  --!! Run regressions before changing
              AffirmIf( DataCheckID, ReadData = ExpectedData,
                "Read Data: " & to_hstring(ReadData) &
                "  Read Address: " & to_hstring(ReadAddress) &
                "  Prot: " & to_hstring(ReadProt),
                "  Expected: " & to_hstring(ExpectedData),
                TransRec.StatusMsgOn or IsLogEnabled(ModelID, INFO) ) ;
            else
  --!!9 TODO:  Change format to Transaction #, Address, Prot, Read Data
  --!! Run regressions before changing
              Log( ModelID,
                "Read Data: " & to_hstring(ReadData) &
                "  Read Address: " & to_hstring(ReadAddress) &
                "  Prot: " & to_hstring(ReadProt),
                INFO,
                TransRec.StatusMsgOn
              ) ;
            end if ;
          end if ;

          -- Transaction wait time
          wait for 0 ns ;  wait for 0 ns ;

        when READ_BURST =>
          if IsReadAddress(Operation) then
            -- Send Read Address to Read Address Handler and Read Data Handler
            ReadAddress   :=  FromTransaction(TransRec.Address) ;
            ReadByteAddr  :=  CalculateAxiByteAddress(ReadAddress, AXI_BYTE_ADDR_WIDTH);
--            AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Read Address length does not match", FAILURE) ;
--            BytesPerTransfer := 2**to_integer(LAR.Size);
            BytesPerTransfer := AXI_DATA_BYTE_WIDTH ;

            -- Burst transfer, calculate burst length
            TransfersInBurst := 1 + CalculateAxiBurstLen(TransRec.DataWidth, ReadByteAddr, BytesPerTransfer) ;

            ReadAddressFifo.Push(ReadAddress & LAR.Prot) ;
            ReadAddressTransactionFifo.Push(ReadAddress & LAR.Prot);
            Increment(ReadAddressRequestCount) ;

            -- Expect a Read Data Cycle
            for i in 1 to TransfersInBurst loop
              ReadResponseScoreboard.Push(LRD.Resp) ;
            end loop ;
  -- Should this be + TransfersInBurst + 1 ; ???
--            ReadDataExpectCount <= ReadDataExpectCount + to_integer(ReadBurstLen) + 1 ;
            ReadDataExpectCount <= ReadDataExpectCount + 1 ;
          end if ;

  --!!3 Implies that any separate ReadDataBurst or TryReadDataBurst
  --!!3 must include the transfer length and for Try
  --!!3 if ReadDataFifo has that number of transfers.
  --!!3 First Check IsReadData, then Calculate #Transfers,
  --!!3 Then if TryRead, and ReadDataFifo.FifoCount < #Transfers, then FALSE
  --!!3 Which reverses the order of the following IF statements
          if IsTryReadData(Operation) and ReadDataFifo.Empty then
            -- Data not available
            -- ReadDataReceiveCount < ReadDataTransactionCount then
            TransRec.BoolFromModel <= FALSE ;
          elsif IsReadData(Operation) then
            TransRec.BoolFromModel <= TRUE ;
            (ReadAddress, ReadProt) := ReadAddressTransactionFifo.Pop ;
            ReadByteAddr := CalculateAxiByteAddress(ReadAddress, AXI_BYTE_ADDR_WIDTH);
            BytesPerTransfer := AXI_DATA_BYTE_WIDTH ;
--!!            BytesPerTransfer := 2**to_integer(LAR.Size);
            
--!!            AlertIf(ModelID, BytesPerTransfer /= AXI_DATA_BYTE_WIDTH,
--!!              "Write Bytes Per Transfer (" & to_string(BytesPerTransfer) & ") " &
--!!              "/= AXI_DATA_BYTE_WIDTH (" & to_string(AXI_DATA_BYTE_WIDTH) & ")"
--!!            );

            if BurstFifoByteMode then 
              BytesToReceive    := TransRec.DataWidth ;
              TransfersInBurst  := 1 + CalculateAxiBurstLen(BytesToReceive, ReadByteAddr, BytesPerTransfer) ;
            else
              TransfersInBurst  := TransRec.DataWidth ;
            end if ; 

            for i in 1 to TransfersInBurst loop
              if ReadDataFifo.Empty then
                WaitForToggle(ReadDataReceiveCount) ;
              end if ;
              ReadData := ReadDataFifo.Pop ;

              PushReadBurstData(ReadBurstFifo, BurstFifoMode, ReadData, BytesToReceive, ReadByteAddr) ;
              ReadByteAddr := 0 ;
            end loop ;
          end if ;

          -- Transaction wait time
          wait for 0 ns ;  wait for 0 ns ;

        -- Model Configuration Options
        when SET_MODEL_OPTIONS =>
          Axi4Option := Axi4OptionsType'val(TransRec.Options) ;
          if IsAxiInterface(Axi4Option) then
--            SetAxi4InterfaceDefault(AxiDefaults, Axi4Option, TransRec.IntToModel) ;
          else
            SetAxi4Parameter(Params, Axi4Option, TransRec.IntToModel) ;
          end if ;
          wait for 0 ns ;  wait for 0 ns ;

        when GET_MODEL_OPTIONS =>
          Axi4Option := Axi4OptionsType'val(TransRec.Options) ;
          if IsAxiInterface(Axi4Option) then
--            TransRec.IntFromModel <= GetAxi4InterfaceDefault(AxiDefaults, Axi4Option) ;
          else
            GetAxi4Parameter(Params, Axi4Option, Axi4OptionVal) ;
            TransRec.IntToModel <= Axi4OptionVal ;
          end if ;
          wait for 0 ns ;  wait for 0 ns ;

        when others =>
          Alert(ModelID, "Unimplemented Transaction", FAILURE) ;
          wait for 0 ns ;  wait for 0 ns ;
      end case ;
  end loop ;
  end process TransactionDispatcher ;

  ------------------------------------------------------------
  --  WriteAddressHandler
  --    Execute Write Address Transactions
  ------------------------------------------------------------
  WriteAddressHandler : process
--!GHDL    alias    AB : AxiBus'subtype is AxiBus ;
--!GHDL    alias    AW is AB.WriteAddress ;
    alias AW : Axi4LiteWriteAddressRecType(Addr(AXI_ADDR_WIDTH-1 downto 0)) is AxiBus.WriteAddress ;

--!GHDL     variable Local : AxiBus.WriteAddress'subtype ;
    variable Local    : Axi4LiteWriteAddressRecType(Addr(AXI_ADDR_WIDTH-1 downto 0) );
    variable WriteAddressReadyTimeOut : integer ;
  begin
    -- AXI4 LIte Signaling
    AW.Valid  <= '0' ;
    AW.Addr   <= (Local.Addr'range   => '0') ;
    AW.Prot   <= (Local.Prot'range   => '0') ;

    WriteAddressLoop : loop
      -- Find Transaction
      if WriteAddressFifo.Empty then
         WaitForToggle(WriteAddressRequestCount) ;
      end if ;
      (Local.Addr, Local.Prot) := WriteAddressFifo.Pop ;


      -- Do Transaction
      AW.Addr   <= Local.Addr      after tpd_Clk_AWAddr   ;
      AW.Prot   <= Local.Prot      after tpd_clk_AWProt   ;

      Log(ModelID,
        "Write Address." &
        "  AWAddr: "    & to_hstring(Local.Addr) &
        "  AWProt: "    & to_string (Local.Prot) &
        "  Operation# " & to_string (WriteAddressDoneCount + 1),
        INFO
      ) ;

      GetAxiOption(Params, WRITE_ADDRESS_READY_TIME_OUT, WriteAddressReadyTimeOut) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  AW.Valid,
        Ready          =>  AW.Ready,
        tpd_Clk_Valid  =>  tpd_Clk_AWValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Address # " & to_string(WriteAddressDoneCount + 1),
        TimeOutPeriod  =>  WriteAddressReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      AW.Addr   <= Local.Addr   + 1  after tpd_Clk_AWAddr   ;
      AW.Prot   <= Local.Prot   + 1  after tpd_clk_AWProt   ;

      -- Signal completion
      Increment(WriteAddressDoneCount) ;
      wait for 0 ns ;
    end loop WriteAddressLoop ;
  end process WriteAddressHandler ;

  ------------------------------------------------------------
  --  WriteDataHandler
  --    Execute Write Data Transactions
  ------------------------------------------------------------
  WriteDataHandler : process
--!GHDL    alias    AB : AxiBus'subtype is AxiBus ;
--!GHDL    alias    WD is AB.WriteData ;
    alias WD : Axi4LiteWriteDataRecType(Data (AXI_DATA_WIDTH-1 downto 0),   Strb(AXI_STRB_WIDTH-1 downto 0) ) is AxiBus.WriteData ; 
    
--!GHDL    variable Local : AxiBus.WriteData'subtype ;
    variable Local    : Axi4LiteWriteDataRecType(Data (AXI_DATA_WIDTH-1 downto 0),   Strb(AXI_STRB_WIDTH-1 downto 0) ) ;

    variable WriteDataReadyTimeOut : integer ;
  begin
    -- initialize
    WD.Valid <= '0' ;
    WD.Data  <= (Local.Data'range => '0') ;
    WD.Strb  <= (Local.Strb'range => '0') ;

    WriteDataLoop : loop
      -- Find Transaction
      if WriteDataFifo.Empty then
         WaitForToggle(WriteDataRequestCount) ;
      end if ;
      (Local.Data, Local.Strb) := WriteDataFifo.Pop ;

      -- Do Transaction
      WD.Data  <= Local.Data after tpd_clk_WStrb ;
      WD.Strb  <= Local.Strb after tpd_Clk_WData ;

      Log(ModelID,
        "Write Data." &
        "  WData: "     & to_hstring(Local.Data) &
        "  WStrb: "     & to_string (Local.Strb) &
        "  Operation# " & to_string (WriteDataDoneCount + 1),
        INFO
      ) ;

      GetAxiOption(Params, WRITE_DATA_READY_TIME_OUT, WriteDataReadyTimeOut) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  WD.Valid,
        Ready          =>  WD.Ready,
        tpd_Clk_Valid  =>  tpd_Clk_WValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Data # " & to_string(WriteDataDoneCount + 1),
        TimeOutPeriod  =>  WriteDataReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      WD.Data  <= not Local.Data      after tpd_Clk_WData ;
      WD.Strb  <= Local.Strb          after tpd_clk_WStrb ; -- allow writes

      -- Signal completion
      Increment(WriteDataDoneCount) ;
      wait for 0 ns ;
    end loop WriteDataLoop ;
  end process WriteDataHandler ;

  ------------------------------------------------------------
  -- WriteResponseHandler
  --   Receive and Check Write Responses
  ------------------------------------------------------------
  WriteResponseHandler : process
    variable WriteResponseReadyBeforeValid  : boolean ;
    variable WriteResponseReadyDelayCycles  : integer ;
    variable WriteResponseValidTimeOut : integer ;
  begin
    -- initialize
    AxiBus.WriteResponse.Ready <= '0' ;

    WriteResponseOperation : loop
      -- Find Expected Transaction
      WriteResponseActive <= FALSE ;
      if WriteResponseScoreboard.empty then
        WaitForToggle(WriteResponseExpectCount) ;
      end if ;
      WriteResponseActive <= TRUE ;

      Log(ModelID, "Waiting for Write Response.", DEBUG) ;


      GetAxiOption(Params, WRITE_RESPONSE_READY_BEFORE_VALID, WriteResponseReadyBeforeValid) ;
      GetAxiOption(Params, WRITE_RESPONSE_READY_DELAY_CYCLES, WriteResponseReadyDelayCycles) ;
      GetAxiOption(Params, WRITE_RESPONSE_VALID_TIME_OUT,     WriteResponseValidTimeOut) ;

      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => AxiBus.WriteResponse.Valid,
        Ready                   => AxiBus.WriteResponse.Ready,
        ReadyBeforeValid        => WriteResponseReadyBeforeValid,
        ReadyDelayCycles        => WriteResponseReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_BReady,
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Write Response # " & to_string(WriteResponseReceiveCount + 1),
        TimeOutPeriod           => WriteResponseValidTimeOut * tperiod_Clk
      ) ;

      -- Check Write Response
      WriteResponseScoreboard.Check(AxiBus.WriteResponse.Resp) ;

      -- Signal Completion
      increment(WriteResponseReceiveCount) ;
      wait for 0 ns ;
    end loop WriteResponseOperation ;
  end process WriteResponseHandler ;


  ------------------------------------------------------------
  --  WriteResponseProtocolChecker
  --    Error if Write Response BValid happens without a Write cycle
  ------------------------------------------------------------
  WriteResponseProtocolChecker : process
  begin
    wait on Clk until Clk = '1' and AxiBus.WriteResponse.Valid = '1' ;
    AlertIf(ProtocolID, not WriteResponseActive,
      "Unexpected Write Response Cycle. " &
      " BValid: " & to_string(AxiBus.WriteResponse.Valid) &
      " BResp: "  & to_string(AxiBus.WriteResponse.Resp) &
      "  Operation# " & to_string(WriteResponseReceiveCount + 1),
      FAILURE
    ) ;
  end process WriteResponseProtocolChecker ;

  ------------------------------------------------------------
  --  ReadAddressHandler
  --    Execute Read Address Transactions
  ------------------------------------------------------------
  ReadAddressHandler : process
--!GHDL    alias    AB : AxiBus'subtype is AxiBus ;
--!GHDL    alias    AR is AB.ReadAddress ;
    alias AR : Axi4LiteReadAddressRecType(Addr(AXI_ADDR_WIDTH-1 downto 0) ) is AxiBus.ReadAddress ;

--!GHDL    variable Local : AxiBus.ReadAddress'subtype ;
    variable Local    : Axi4LiteReadAddressRecType(Addr(AXI_ADDR_WIDTH-1 downto 0) );

    variable ReadAddressReadyTimeOut : integer ;
  begin
    -- AXI4 Lite Signaling
    AR.Valid  <= '0' ;
    AR.Addr   <= (Local.Addr'range   => '0') ;
    AR.Prot   <= (Local.Prot'range   => '0') ;


    AddressReadLoop : loop
      -- Find Transaction
      if ReadAddressFifo.Empty then
         WaitForToggle(ReadAddressRequestCount) ;
      end if ;
      (Local.Addr, Local.Prot) := ReadAddressFifo.Pop ;

      -- Do Transaction
      AR.Addr   <= Local.Addr   after tpd_Clk_ARAddr   ;
      AR.Prot   <= Local.Prot   after tpd_clk_ARProt   ;

      Log(ModelID,
        "Read Address." &
        "  ARAddr: "    & to_hstring(Local.Addr) &
        "  ARProt: "    & to_string (Local.Prot) &
        "  Operation# " & to_string (ReadAddressDoneCount + 1),
        INFO
      ) ;

      GetAxiOption(Params, READ_ADDRESS_READY_TIME_OUT, ReadAddressReadyTimeOut) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  AR.Valid,
        Ready          =>  AR.Ready,
        tpd_Clk_Valid  =>  tpd_Clk_ARValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Read Address # " & to_string(ReadAddressDoneCount + 1),
        TimeOutPeriod  =>  ReadAddressReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      AR.Addr   <= Local.Addr   + 1  after tpd_Clk_ARAddr   ;
      AR.Prot   <= Local.Prot   + 1  after tpd_clk_ARProt   ;

      -- Signal completion
      Increment(ReadAddressDoneCount) ;
      wait for 0 ns;
    end loop AddressReadLoop ;
  end process ReadAddressHandler ;


  ------------------------------------------------------------
  --  ReadDataHandler
  --    Receive Read Data Transactions
  ------------------------------------------------------------
  ReadDataHandler : process
    variable ReadDataReadyBeforeValid : boolean ;
    variable ReadDataReadyDelayCycles : integer ;
    variable ReadDataValidTimeOut     : integer ;
  begin
    AxiBus.ReadData.Ready <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    ReadDataOperation : loop
      -- Find Expected Transaction
      ReadDataActive <= FALSE ;
      if ReadDataReceiveCount >= ReadDataExpectCount then
        WaitForToggle(ReadDataExpectCount) ;
      end if ;
      ReadDataActive <= TRUE ;

      GetAxiOption(Params, READ_DATA_READY_BEFORE_VALID, ReadDataReadyBeforeValid) ;
      GetAxiOption(Params, READ_DATA_READY_DELAY_CYCLES, ReadDataReadyDelayCycles) ;
      GetAxiOption(Params, READ_DATA_VALID_TIME_OUT,     ReadDataValidTimeOut) ;

      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => AxiBus.ReadData.Valid,
        Ready                   => AxiBus.ReadData.Ready,
        ReadyBeforeValid        => ReadDataReadyBeforeValid,
        ReadyDelayCycles        => ReadDataReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_RReady,
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Read Data # " & to_string(ReadDataReceiveCount + 1),
        TimeOutPeriod           => ReadDataValidTimeOut * tperiod_Clk
      ) ;

      -- capture data
      ReadDataFifo.push(AxiBus.ReadData.Data) ;
      ReadResponseScoreboard.Check(AxiBus.ReadData.Resp) ;

      increment(ReadDataReceiveCount) ;
      wait for 0 ns ; -- Allow ReadDataReceiveCount to update
    end loop ReadDataOperation ;
  end process ReadDataHandler ;

  ------------------------------------------------------------
  --  ReadDataProtocolChecker
  --    Receive Read Data Transactions
  ------------------------------------------------------------
  ReadDataProtocolChecker : process
  begin
    wait on Clk until Clk = '1' and AxiBus.ReadData.Valid = '1' ;
    AlertIf(ProtocolID, not ReadDataActive,
      "Unexpected Read Data Cycle. " &
      " RValid: " & to_string (AxiBus.ReadData.Valid) &
      " RData: "  & to_hstring(AxiBus.ReadData.Data) &
      " RResp: "  & to_string (AxiBus.ReadData.Resp) &
      "  Operation# " & to_string(ReadDataReceiveCount + 1),
      FAILURE
    ) ;
  end process ReadDataProtocolChecker ;

end architecture AxiFull ;

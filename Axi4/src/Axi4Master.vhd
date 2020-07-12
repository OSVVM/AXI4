--
--  File Name:         Axi4Master.vhd
--  Design Unit Name:  Axi4Master
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
  use work.Axi4Pkg.all ;     
  use work.Axi4InterfacePkg.all ; 
  use work.Axi4CommonPkg.all ;

entity Axi4Master is
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

  -- Testbench Transaction Interface
  TransRec    : inout AddressBusTransactionRecType ;

  -- AXI Master Functional Interface
  AxiBus      : inout Axi4RecType
) ;
end entity Axi4Master ;
architecture AxiFull of Axi4Master is

  alias    AxiAddr is AxiBus.WriteAddress.AWAddr ;
  alias    AxiData is AxiBus.WriteData.WData ;
  constant AXI_ADDR_WIDTH : integer := AxiAddr'length ;
  constant AXI_DATA_WIDTH : integer := AxiData'length ;
  constant AXI_DATA_BYTE_WIDTH : integer := AXI_DATA_WIDTH / 8 ;
  constant AXI_BYTE_ADDR_WIDTH : integer := integer(ceil(log2(real(AXI_DATA_BYTE_WIDTH)))) ; 

  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4Master'PATH_NAME))) ;
  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ;

  -- External Burst Interface
  shared variable WriteBurstFifo              : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable ReadBurstFifo               : osvvm.ScoreboardPkg_slv.ScoreboardPType ;

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
  
begin

  ------------------------------------------------------------
  -- Turn off drivers not being driven by this model
  ------------------------------------------------------------
  InitAxi4Rec (AxiBusRec => AxiBus) ;


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
    
    variable AxiDefaults    : AxiBus'subtype ; 
    alias    LAW is AxiDefaults.WriteAddress ; 
    alias    LWD is AxiDefaults.WriteData ; 
    alias    LWR is AxiDefaults.WriteResponse ; 
    alias    LAR is AxiDefaults.ReadAddress ; 
    alias    LRD is AxiDefaults.ReadData ;

    variable WriteByteAddr   : integer ;
    alias    WriteAddress    is LAW.AWAddr ; 
    alias    WriteBurstLen   is LAW.AWLen ; 
    alias    AWSize          is LAW.AWSize ;
  
    variable BytesToSend              : integer ; 
    variable BytesPerTransfer         : integer ; 
    variable MaxBytesInFirstTransfer  : integer ; 
    alias    WriteData       is LWD.WData ; 
    alias    WriteStrb       is LWD.WStrb ; 
    
    variable BytesInTransfer : integer ; 
    variable BytesToReceive  : integer ; 
    variable DataBitOffset   : integer ;
    
    variable ReadByteAddr    : integer ;
    alias    ReadAddress     is LAR.ARAddr ; 
    alias    ReadBurstLen    is LAR.ARLen ; 
    alias    ARSize          is LAR.ARSize ;
    alias    DefaultReadProt is LAR.ARProt ; 
    variable ReadProt        : DefaultReadProt'subtype ;
    
    alias    ReadData    is LRD.RData ;
    variable ExpectedData    : ReadData'subtype ;
    
    variable Operation       : AddressBusOperationType ;
  begin
    AxiDefaults.WriteAddress.AWSize := to_slv(AXI_BYTE_ADDR_WIDTH, AWSize'length) ;
    AxiDefaults.WriteResponse.BResp := to_Axi4RespType(OKAY);
    AxiDefaults.ReadAddress.ARSize  := to_slv(AXI_BYTE_ADDR_WIDTH, ARSize'length) ;
    AxiDefaults.ReadData.RResp      := to_Axi4RespType(OKAY) ;

    loop
      WaitForTransaction(
         Clk      => Clk,
         Rdy      => TransRec.Rdy,
         Ack      => TransRec.Ack
      ) ;

      Operation := TransRec.Operation ;

      case Operation is
        -- Execute Standard Directive Transactions
        when WAIT_CLOCK =>
          WaitClockCycles := FromTransaction(TransRec.DataToModel) ;
          wait for (WaitClockCycles * tperiod_Clk) - 1 ns ;
          wait until Clk = '1' ;

        when GET_ALERTLOG_ID =>
          TransRec.IntFromModel <= integer(ModelID) ;
          wait until Clk = '1' ;

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
          WriteAddress  := FromTransaction(TransRec.Address, WriteAddress'length) ;
          WriteByteAddr := CalculateAxiByteAddress(WriteAddress, AXI_BYTE_ADDR_WIDTH);
          
          if IsWriteAddress(Operation) then
            -- Write Address Handling
            -- AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Write Address length does not match", FAILURE) ;
            
            WriteBurstLen := (others => '0') ; 
            
            -- Initiate Write Address
            WriteAddressFifo.Push(WriteAddress  & WriteBurstLen & LAW.AWProt & LAW.AWID & LAW.AWSize & LAW.AWBurst & LAW.AWLock & LAW.AWCache & LAW.AWQOS & LAW.AWRegion & LAW.AWUser) ;            
            Increment(WriteAddressRequestCount) ;

            -- Queue Write Response
            WriteResponseScoreboard.Push(LWR.BResp) ;
            Increment(WriteResponseExpectCount) ;
          end if ;

          if IsWriteData(Operation) then
            WriteAddress  := FromTransaction(TransRec.Address) ; 
            WriteByteAddr := CalculateAxiByteAddress(WriteAddress, AXI_BYTE_ADDR_WIDTH);
            
            -- Single Transfer Write Data Handling
            WriteData     := FromTransaction(TransRec.DataToModel) ;
            AlignCheckWriteData (ModelID, WriteData, WriteStrb, TransRec.DataWidth, WriteByteAddr) ;
            WriteDataFifo.Push(WriteData & WriteStrb & '1' & LWD.WUser & LWD.WID) ;

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
          
          if IsWriteAddress(Operation) then
            -- Write Address Handling
            AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Write Address length does not match", FAILURE) ;
            BytesPerTransfer := 2**to_integer(LAW.AWSize);
            
            -- Burst transfer, calcualte burst length 
            WriteBurstLen := to_slv(CalculateAxiBurstLen(TransRec.DataWidth, WriteByteAddr, BytesPerTransfer), WriteBurstLen'length) ;
            
            -- Initiate Write Address
            WriteAddressFifo.Push(WriteAddress  & WriteBurstLen & LAW.AWProt & LAW.AWID & LAW.AWSize & LAW.AWBurst & LAW.AWLock & LAW.AWCache & LAW.AWQOS & LAW.AWRegion & LAW.AWUser) ;            
   
            Increment(WriteAddressRequestCount) ;

            -- Queue Write Response
            WriteResponseScoreboard.Push(LWR.BResp) ;
            Increment(WriteResponseExpectCount) ;
          end if ;

          if IsWriteData(Operation) then
            WriteAddress  := FromTransaction(TransRec.Address) ; 
            WriteByteAddr := CalculateAxiByteAddress(WriteAddress, AXI_BYTE_ADDR_WIDTH);
            
            -- Burst Transfer Write Data Handling
  --!! WriteBurstData -  must have BytesToSend in TransRec.DataWidth
            BytesToSend       := TransRec.DataWidth ; 
            BytesPerTransfer  := 2 ** to_integer(LAW.AWSize) ;
            MaxBytesInFirstTransfer := BytesPerTransfer - WriteByteAddr ; 
            AlertIf(ModelID, BytesPerTransfer /= AXI_DATA_BYTE_WIDTH, 
              "Write Bytes Per Transfer (" & to_string(BytesPerTransfer) & ") " & 
              "/= AXI_DATA_BYTE_WIDTH (" & to_string(AXI_DATA_BYTE_WIDTH) & ")"
            );
            
            TransfersInBurst := 1 + CalculateAxiBurstLen(BytesToSend, WriteByteAddr, BytesPerTransfer) ;

            -- First Word of Burst, maybe a 1 word burst
            if BytesToSend > MaxBytesInFirstTransfer then
              -- More than 1 transfer in burst
              GetWriteBurstData(WriteBurstFifo, WriteData, WriteStrb, MaxBytesInFirstTransfer, WriteByteAddr) ; 
              WriteDataFifo.Push(WriteData & WriteStrb & '0' & LWD.WUser & LWD.WID) ;
              BytesToSend       := BytesToSend - MaxBytesInFirstTransfer; 
            else
              -- Only one transfer in Burst.  # Bytes may be less than a whole word
              GetWriteBurstData(WriteBurstFifo, WriteData, WriteStrb, BytesToSend, WriteByteAddr) ; 
              WriteDataFifo.Push(WriteData & WriteStrb & '1' & LWD.WUser & LWD.WID) ;
              BytesToSend := 0 ; 
            end if ; 

            -- Middle words of burst
            while BytesToSend >= BytesPerTransfer loop
              GetWriteBurstData(WriteBurstFifo, WriteData, WriteStrb, BytesPerTransfer) ;
              WriteDataFifo.Push(WriteData & WriteStrb & '0' & LWD.WUser & LWD.WID) ;
              BytesToSend := BytesToSend - BytesPerTransfer ; 
            end loop ; 
            
            -- End of Burst
            if BytesToSend > 0 then 
              GetWriteBurstData(WriteBurstFifo, WriteData, WriteStrb, BytesToSend) ;
              WriteDataFifo.Push(WriteData & WriteStrb & '1' & LWD.WUser & LWD.WID) ;
            end if ; 
            
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
            BytesPerTransfer := 2**to_integer(LAR.ARSize);

            ReadBurstLen := (others => '0') ; 
            
            ReadAddressFifo.Push(ReadAddress & ReadBurstLen & LAR.ARProt & LAR.ARID & LAR.ARSize & LAR.ARBurst & LAR.ARLock & LAR.ARCache & LAR.ARQOS & LAR.ARRegion & LAR.ARUser) ;                        
            ReadAddressTransactionFifo.Push(ReadAddress & LAR.ARProt);
            Increment(ReadAddressRequestCount) ;

            -- Expect a Read Data Cycle
            ReadResponseScoreboard.Push(LRD.RResp) ;
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
  --!!9 TODO:  Change format to Address, Data Transaction #, Read Data 
  --!! Run regressions before changing          
              AffirmIf( DataCheckID, ReadData = ExpectedData,
                "Read Data: " & to_hstring(ReadData) &
                "  Read Address: " & to_hstring(ReadAddress) &
                "  Prot: " & to_hstring(ReadProt),
                "  Expected: " & to_hstring(ExpectedData),
                TransRec.StatusMsgOn or IsLogEnabled(ModelID, INFO) ) ;
            else
  --!!9 TODO:  Change format to Address, Data Transaction #, Read Data  
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
            AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Read Address length does not match", FAILURE) ;
            BytesPerTransfer := 2**to_integer(LAR.ARSize);

            -- Burst transfer, calcualte burst length 
            TransfersInBurst := 1 + CalculateAxiBurstLen(TransRec.DataWidth, ReadByteAddr, BytesPerTransfer) ;
            ReadBurstLen := to_slv(TransfersInBurst - 1, ReadBurstLen'length) ;
            
            ReadAddressFifo.Push(ReadAddress & ReadBurstLen & LAR.ARProt & LAR.ARID & LAR.ARSize & LAR.ARBurst & LAR.ARLock & LAR.ARCache & LAR.ARQOS & LAR.ARRegion & LAR.ARUser) ;
            ReadAddressTransactionFifo.Push(ReadAddress & LAR.ARProt);
            Increment(ReadAddressRequestCount) ;

            -- Expect a Read Data Cycle
            for i in 1 to TransfersInBurst loop 
              ReadResponseScoreboard.Push(LRD.RResp) ;
            end loop ;
  -- Should this be + TransfersInBurst + 1 ; ???          
            ReadDataExpectCount <= ReadDataExpectCount + to_integer(ReadBurstLen) + 1 ;
          end if ;

  --!!3 For Bursts, any TryReadData would need to specify length and 
  --!!3 if ReadDataFifo has that number of transfers.   
  --!!3 First Check IsReadData, then Calculate #Transfers, 
  --!!3 Then if TryRead, and ReadDataFifo.FifoCount < #Transfers, then FALSE
  --!!3 Which reverses the order of the following IF statements
          if IsTryReadData(Operation) and ReadDataFifo.Empty then
            -- Data not available
            -- ReadDataReceiveCount < ReadDataTransactionCount then
            TransRec.BoolFromModel <= FALSE ;
          elsif IsReadData(Operation) then
            (ReadAddress, ReadProt) := ReadAddressTransactionFifo.Pop ;

  --!!** Implies that any separate ReadDataBurst must TryReadDataBurst
  --!!** must include the transfer length     
  --!!19 update to handle different interface size - see Axi4Memory
            -- Pull Burst out of Read Data FIFO (Word Oriented) and put in ReadBurstFifo (ByteOriented)
            -- Address
            -- First and Last bytes
  --!! f(ReadAddress, TransRec, Params, AXI_DATA_BYTE_WIDTH, ReadDataFifo, ReadDataReceiveCount, ReadBurstFifo)            
            ReadByteAddr := CalculateAxiByteAddress(ReadAddress, AXI_BYTE_ADDR_WIDTH);
            BytesToReceive    := TransRec.DataWidth ; 
            BytesPerTransfer  := 2 ** to_integer(LAR.ARSize) ;
            AlertIf(ModelID, BytesPerTransfer /= AXI_DATA_BYTE_WIDTH, 
              "Write Bytes Per Transfer (" & to_string(BytesPerTransfer) & ") " & 
              "/= AXI_DATA_BYTE_WIDTH (" & to_string(AXI_DATA_BYTE_WIDTH) & ")"
            );
            
            TransfersInBurst := 1 + CalculateAxiBurstLen(BytesToReceive, ReadByteAddr, BytesPerTransfer) ;
            
            BytesInTransfer   := BytesPerTransfer - ReadByteAddr ;
            
            for i in 1 to TransfersInBurst loop
              if ReadDataFifo.Empty then
                WaitForToggle(ReadDataReceiveCount) ;
              end if ;
              ReadData := ReadDataFifo.Pop ;
              TransRec.BoolFromModel <= TRUE ;
              
              -- Adjust for last transfer
              if BytesInTransfer > BytesToReceive then
                BytesInTransfer := BytesToReceive ;
              end if ; 
              
  --!!f(ReadData, ReadBurstFifo, BytesInTransfer, ByteAddr)
              -- Move ReadData into ReadBurstFifo
              for i in 0 to BytesInTransfer - 1 loop
                 DataBitOffset := ReadByteAddr*8 + i*8 ; 
                 ReadBurstFifo.Push(ReadData(DataBitOffset+7 downto DataBitOffset)) ; 
              end loop ; 
              
              BytesToReceive := BytesToReceive - BytesInTransfer ; 
              ReadByteAddr := 0 ;
              BytesInTransfer := AXI_DATA_BYTE_WIDTH ;
            end loop ;
          end if ;

          -- Transaction wait time
          wait for 0 ns ;  wait for 0 ns ;
          
        -- Model Configuration Options
        when SET_MODEL_OPTIONS =>
          Axi4Option := Axi4OptionsType'val(TransRec.Options) ;
          if IsAxiInterface(Axi4Option) then
            SetAxiParameter(AxiDefaults, Axi4Option, TransRec.IntToModel) ;
          else
            SetAxiOption(Params, Axi4Option, TransRec.IntToModel) ;
          end if ; 
          wait for 0 ns ;  wait for 0 ns ;

        when GET_MODEL_OPTIONS =>
          Axi4Option := Axi4OptionsType'val(TransRec.Options) ;
          if IsAxiInterface(Axi4Option) then
            TransRec.IntFromModel <= GetAxiParameter(AxiDefaults, Axi4Option) ;
          else
            GetAxiOption(Params, Axi4Option, Axi4OptionVal) ;
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
    alias    AB : AxiBus'subtype is AxiBus ; 
    alias    AW is AB.WriteAddress ;
    variable Local : AxiBus.WriteAddress'subtype ;  
    variable WriteAddressReadyTimeOut : integer ; 
  begin
    -- AXI4 LIte Signaling
    AW.AWValid  <= '0' ;
    AW.AWAddr   <= (Local.AWAddr'range   => '0') ;
    AW.AWProt   <= (Local.AWProt'range   => '0') ;
    -- AXI4 Full Signaling
    AW.AWLen    <= (Local.AWLen'range    => '0') ;
    AW.AWID     <= (Local.AWID'range     => '0') ;
    AW.AWSize   <= (Local.AWSize'range   => '0') ;
    AW.AWBurst  <= (Local.AWBurst'range  => '0') ;
    AW.AWLock   <= '0' ;
    AW.AWCache  <= (Local.AWCache'range  => '0') ;
    AW.AWQOS    <= (Local.AWQOS'range    => '0') ;
    AW.AWRegion <= (Local.AWRegion'range => '0') ;
    AW.AWUser   <= (Local.AWUser'range   => '0') ;
    
    WriteAddressLoop : loop
      -- Find Transaction
      if WriteAddressFifo.Empty then
         WaitForToggle(WriteAddressRequestCount) ;
      end if ;
      (Local.AWAddr, Local.AWLen, Local.AWProt, Local.AWID, Local.AWSize, Local.AWBurst, Local.AWLock, Local.AWCache, Local.AWQOS, Local.AWRegion, Local.AWUser) := WriteAddressFifo.Pop ;


      -- Do Transaction
      AW.AWAddr   <= Local.AWAddr      after tpd_Clk_AWAddr   ;
      AW.AWProt   <= Local.AWProt      after tpd_clk_AWProt   ;
      -- AXI4 Full
      AW.AWLen    <= Local.AWLen       after tpd_clk_AWLen    ;
      AW.AWID     <= Local.AWID        after tpd_clk_AWID     ;
      AW.AWSize   <= Local.AWSize      after tpd_clk_AWSize   ;
      AW.AWBurst  <= Local.AWBurst     after tpd_clk_AWBurst  ;
      AW.AWLock   <= Local.AWLock      after tpd_clk_AWLock   ;
      AW.AWCache  <= Local.AWCache     after tpd_clk_AWCache  ;
      AW.AWQOS    <= Local.AWQOS       after tpd_clk_AWQOS    ;
      AW.AWRegion <= Local.AWRegion    after tpd_clk_AWRegion ;
      AW.AWUser   <= Local.AWUser      after tpd_clk_AWUser   ;

      Log(ModelID,
        "Write Address." &
        "  AWAddr: "  & to_hstring(Local.AWAddr) &
        "  AWProt: "  & to_string(Local.AWProt) &
        "  Operation# " & to_string(WriteAddressDoneCount + 1),
        INFO
      ) ;

      GetAxiOption(Params, WRITE_ADDRESS_READY_TIME_OUT, WriteAddressReadyTimeOut) ; 
      
      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  AW.AWValid,
        Ready          =>  AW.AWReady,
        tpd_Clk_Valid  =>  tpd_Clk_AWValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Address # " & to_string(WriteAddressDoneCount + 1),
        TimeOutPeriod  =>  WriteAddressReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      AW.AWAddr   <= Local.AWAddr   + 1  after tpd_Clk_AWAddr   ;
      AW.AWProt   <= Local.AWProt   + 1  after tpd_clk_AWProt   ;
      -- AXI4 Full
      AW.AWLen    <= Local.AWLen    + 1  after tpd_clk_AWLen    ;
      AW.AWID     <= Local.AWID     + 1  after tpd_clk_AWID     ;
      AW.AWSize   <= Local.AWSize   + 1  after tpd_clk_AWSize   ;
      AW.AWBurst  <= Local.AWBurst  + 1  after tpd_clk_AWBurst  ;
      AW.AWLock   <= Local.AWLock        after tpd_clk_AWLock   ;
      AW.AWCache  <= Local.AWCache  + 1  after tpd_clk_AWCache  ;
      AW.AWQOS    <= Local.AWQOS    + 1  after tpd_clk_AWQOS    ;
      AW.AWRegion <= Local.AWRegion + 1  after tpd_clk_AWRegion ;
      AW.AWUser   <= Local.AWUser   + 1  after tpd_clk_AWUser   ;

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
    alias    AB : AxiBus'subtype is AxiBus ; 
    alias    WD is AB.WriteData ;

    variable Local : AxiBus.WriteData'subtype ; 

    variable WriteDataReadyTimeOut : integer ; 
  begin
    -- initialize
    WD.WValid <= '0' ;
    WD.WData  <= (Local.WData'range => '0') ;
    WD.WStrb  <= (Local.WStrb'range => '0') ;
    -- AXI4 Full
    WD.WLast  <= '0' ;
    WD.WUser  <= (Local.WUser'range => '0') ;
    -- AXI3
    WD.WID    <= (Local.WID'range   => '0') ;

    WriteDataLoop : loop
      -- Find Transaction
      if WriteDataFifo.Empty then
         WaitForToggle(WriteDataRequestCount) ;
      end if ;
      (Local.WData, Local.WStrb, Local.WLast, Local.WUser, Local.WID) := WriteDataFifo.Pop ;

      -- Do Transaction
      WD.WData  <= Local.WData after tpd_clk_WStrb ;
      WD.WStrb  <= Local.WStrb after tpd_Clk_WData ;
      -- AXI4 Full
      WD.WLast  <= Local.WLast after tpd_Clk_WLast ;
      WD.WUser  <= Local.WUser after tpd_Clk_WUser ;
      -- AXI3
      WD.WID    <= Local.WID   after tpd_Clk_WID ;

      Log(ModelID,
        "Write Data." &
        "  WData: "  & to_hstring(Local.WData) &
        "  WStrb: "  & to_string( Local.WStrb) &
        "  Operation# " & to_string(WriteDataDoneCount + 1),
        INFO
      ) ;
      
      GetAxiOption(Params, WRITE_DATA_READY_TIME_OUT, WriteDataReadyTimeOut) ; 

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  WD.WValid,
        Ready          =>  WD.WReady,
        tpd_Clk_Valid  =>  tpd_Clk_WValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Data # " & to_string(WriteDataDoneCount + 1),
        TimeOutPeriod  =>  WriteDataReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      WD.WData  <= not Local.WData      after tpd_Clk_WData ;
      WD.WStrb  <= Local.WStrb          after tpd_clk_WStrb ; -- allow writes
      -- AXI4 Full
      WD.WLast  <= not Local.WLast      after tpd_Clk_WLast ;
      WD.WUser  <= Local.WUser          after tpd_Clk_WUser ;
      -- AXI3
      WD.WID    <= Local.WID            after tpd_Clk_WID ;

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
    AxiBus.WriteResponse.BReady <= '0' ;

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
        Valid                   => AxiBus.WriteResponse.BValid,
        Ready                   => AxiBus.WriteResponse.BReady,
        ReadyBeforeValid        => WriteResponseReadyBeforeValid,
        ReadyDelayCycles        => WriteResponseReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_BReady,
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Write Response # " & to_string(WriteResponseReceiveCount + 1),
        TimeOutPeriod           => WriteResponseValidTimeOut * tperiod_Clk
      ) ;

      -- Check Write Response
      WriteResponseScoreboard.Check(AxiBus.WriteResponse.BResp) ;

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
    wait on Clk until Clk = '1' and AxiBus.WriteResponse.BValid = '1' ;
    AlertIf(ProtocolID, not WriteResponseActive,
      "Unexpected Write Response Cycle. " &
      " BValid: " & to_string(AxiBus.WriteResponse.BValid) &
      " BResp: "  & to_string(AxiBus.WriteResponse.BResp) &
      "  Operation# " & to_string(WriteResponseReceiveCount + 1),
      FAILURE
    ) ;
  end process WriteResponseProtocolChecker ;

  ------------------------------------------------------------
  --  ReadAddressHandler
  --    Execute Read Address Transactions
  ------------------------------------------------------------
  ReadAddressHandler : process
    alias    AB : AxiBus'subtype is AxiBus ; 
    alias    AR is AB.ReadAddress ;

    variable Local : AxiBus.ReadAddress'subtype ; 
    
    variable ReadAddressReadyTimeOut : integer ; 
  begin
    -- AXI4 LIte Signaling
    AR.ARValid  <= '0' ;
    AR.ARAddr   <= (Local.ARAddr'range   => '0') ;
    AR.ARProt   <= (Local.ARProt'range   => '0') ;
    -- AXI4 Full Signaling
    AR.ARLen    <= (Local.ARLen'range    => '0') ;
    AR.ARID     <= (Local.ARID'range     => '0') ;
    AR.ARSize   <= (Local.ARSize'range   => '0') ;
    AR.ARBurst  <= (Local.ARBurst'range  => '0') ;
    AR.ARLock   <= '0' ;
    AR.ARCache  <= (Local.ARCache'range  => '0') ;
    AR.ARQOS    <= (Local.ARQOS'range    => '0') ;
    AR.ARRegion <= (Local.ARRegion'range => '0') ;
    AR.ARUser   <= (Local.ARUser'range   => '0') ;


    AddressReadLoop : loop
      -- Find Transaction
      if ReadAddressFifo.Empty then
         WaitForToggle(ReadAddressRequestCount) ;
      end if ;
      (Local.ARAddr, Local.ARLen, Local.ARProt, Local.ARID, Local.ARSize, Local.ARBurst, Local.ARLock, Local.ARCache, Local.ARQOS, Local.ARRegion, Local.ARUser) := ReadAddressFifo.Pop ;

      -- Do Transaction
      AR.ARAddr   <= Local.ARAddr   after tpd_Clk_ARAddr   ;
      AR.ARProt   <= Local.ARProt   after tpd_clk_ARProt   ;
      -- AXI4 Full
      AR.ARLen    <= Local.ARLen    after tpd_clk_ARLen    ;
      AR.ARID     <= Local.ARID     after tpd_clk_ARID     ;
      AR.ARSize   <= Local.ARSize   after tpd_clk_ARSize   ;
      AR.ARBurst  <= Local.ARBurst  after tpd_clk_ARBurst  ;
      AR.ARLock   <= Local.ARLock   after tpd_clk_ARLock   ;
      AR.ARCache  <= Local.ARCache  after tpd_clk_ARCache  ;
      AR.ARQOS    <= Local.ARQOS    after tpd_clk_ARQOS    ;
      AR.ARRegion <= Local.ARRegion after tpd_clk_ARRegion ;
      AR.ARUser   <= Local.ARUser   after tpd_clk_ARUser   ;

      Log(ModelID,
        "Read Address." &
        "  ARAddr: "  & to_hstring(Local.ARAddr) &
        "  ARProt: "  & to_string( Local.ARProt) &
        "  Operation# " & to_string(ReadAddressDoneCount + 1),
        INFO
      ) ;

      GetAxiOption(Params, READ_ADDRESS_READY_TIME_OUT, ReadAddressReadyTimeOut) ; 

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  AR.ARValid,
        Ready          =>  AR.ARReady,
        tpd_Clk_Valid  =>  tpd_Clk_ARValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Read Address # " & to_string(ReadAddressDoneCount + 1),
        TimeOutPeriod  =>  ReadAddressReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      AR.ARAddr   <= Local.ARAddr   + 1  after tpd_Clk_ARAddr   ;
      AR.ARProt   <= Local.ARProt   + 1  after tpd_clk_ARProt   ;
      -- AXI4 Full
      AR.ARLen    <= Local.ARLen    + 1  after tpd_clk_ARLen    ;
      AR.ARID     <= Local.ARID     + 1  after tpd_clk_ARID     ;
      AR.ARSize   <= Local.ARSize   + 1  after tpd_clk_ARSize   ;
      AR.ARBurst  <= Local.ARBurst  + 1  after tpd_clk_ARBurst  ;
      AR.ARLock   <= Local.ARLock        after tpd_clk_ARLock   ;
      AR.ARCache  <= Local.ARCache  + 1  after tpd_clk_ARCache  ;
      AR.ARQOS    <= Local.ARQOS    + 1  after tpd_clk_ARQOS    ;
      AR.ARRegion <= Local.ARRegion + 1  after tpd_clk_ARRegion ;
      AR.ARUser   <= Local.ARUser   + 1  after tpd_clk_ARUser   ;

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
    AxiBus.ReadData.RReady <= '0' ;
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
        Valid                   => AxiBus.ReadData.RValid,
        Ready                   => AxiBus.ReadData.RReady,
        ReadyBeforeValid        => ReadDataReadyBeforeValid,
        ReadyDelayCycles        => ReadDataReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_RReady,
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Read Data # " & to_string(ReadDataReceiveCount + 1),
        TimeOutPeriod           => ReadDataValidTimeOut * tperiod_Clk
      ) ;

      -- capture data
      ReadDataFifo.push(AxiBus.ReadData.RData) ;
      ReadResponseScoreboard.Check(AxiBus.ReadData.RResp) ;

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
    wait on Clk until Clk = '1' and AxiBus.ReadData.RValid = '1' ;
    AlertIf(ProtocolID, not ReadDataActive,
      "Unexpected Read Data Cycle. " &
      " RValid: " & to_string (AxiBus.ReadData.RValid) &
      " RData: "  & to_hstring(AxiBus.ReadData.RData) &
      " RResp: "  & to_string (AxiBus.ReadData.RResp) &
      "  Operation# " & to_string(ReadDataReceiveCount + 1),
      FAILURE
    ) ;
  end process ReadDataProtocolChecker ;

end architecture AxiFull ;

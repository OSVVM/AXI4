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
--      Simple AXI Lite Master Model
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
  
  use work.Axi4LiteMasterOptionsTypePkg.all ; 
  use work.Axi4LiteMasterTransactionPkg.all ; 
  use work.Axi4LiteInterfacePkg.all ; 
  use work.Axi4CommonPkg.all ; 

entity Axi4LiteMaster is
generic (
  MODEL_ID_NAME   : string :="" ; 
  tperiod_Clk     : time   := 10 ns ;
  
  tpd_Clk_AWValid : time   := 2 ns ; 
  tpd_Clk_AWProt  : time   := 2 ns ; 
  tpd_Clk_AWAddr  : time   := 2 ns ; 

  tpd_Clk_WValid  : time   := 2 ns ; 
  tpd_Clk_WData   : time   := 2 ns ; 
  tpd_Clk_WStrb   : time   := 2 ns ; 

  tpd_Clk_BReady  : time   := 2 ns ; 

  tpd_Clk_ARValid : time   := 2 ns ; 
  tpd_Clk_ARProt  : time   := 2 ns ; 
  tpd_Clk_ARAddr  : time   := 2 ns ; 

  tpd_Clk_RReady  : time   := 2 ns  
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- Testbench Transaction Interface
  TransRec    : inout AddressBusMasterTransactionRecType ;

  -- AXI Master Functional Interface
  AxiLiteBus  : inout Axi4LiteRecType 
) ;

    alias AWValid : std_logic        is AxiLiteBus.WriteAddress.AWValid ;
    alias AWReady : std_logic        is AxiLiteBus.WriteAddress.AWReady ;
    alias AWProt  : Axi4ProtType     is AxiLiteBus.WriteAddress.AWProt ;
    alias AWAddr  : std_logic_vector is AxiLiteBus.WriteAddress.AWAddr ;

    alias WValid  : std_logic        is AxiLiteBus.WriteData.WValid ;
    alias WReady  : std_logic        is AxiLiteBus.WriteData.WReady ;
    alias WData   : std_logic_vector is AxiLiteBus.WriteData.WData ;
    alias WStrb   : std_logic_vector is AxiLiteBus.WriteData.WStrb ;

    alias BValid  : std_logic        is AxiLiteBus.WriteResponse.BValid ;
    alias BReady  : std_logic        is AxiLiteBus.WriteResponse.BReady ;
    alias BResp   : Axi4RespType     is AxiLiteBus.WriteResponse.BResp ;

    alias ARValid : std_logic        is AxiLiteBus.ReadAddress.ARValid ;
    alias ARReady : std_logic        is AxiLiteBus.ReadAddress.ARReady ;
    alias ARProt  : Axi4ProtType     is AxiLiteBus.ReadAddress.ARProt ;
    alias ARAddr  : std_logic_vector is AxiLiteBus.ReadAddress.ARAddr ;

    alias RValid  : std_logic        is AxiLiteBus.ReadData.RValid ;
    alias RReady  : std_logic        is AxiLiteBus.ReadData.RReady ;
    alias RData   : std_logic_vector is AxiLiteBus.ReadData.RData ;
    alias RResp   : Axi4RespType     is AxiLiteBus.ReadData.RResp ;
    
end entity Axi4LiteMaster ;
architecture SimpleMaster of Axi4LiteMaster is

  constant AXI_ADDR_WIDTH : integer := AWAddr'length ;
  constant AXI_DATA_WIDTH : integer := WData'length ;
  constant AXI_DATA_BYTE_WIDTH : integer := AXI_DATA_WIDTH / 8 ;


  constant MODEL_INSTANCE_NAME : string := 
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4LiteMaster'PATH_NAME))) ;
  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ; 
  
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

  signal WriteAddressReadyTimeOut, WriteDataReadyTimeOut, ReadAddressReadyTimeOut, 
         WriteResponseValidTimeOut, ReadDataValidTimeOut : integer := 25 ; 
         
  signal WriteResponseReadyBeforeValid  : boolean := TRUE ; 
  signal ReadDataReadyBeforeValid       : boolean := TRUE ; 
  signal WriteResponseReadyDelayCycles  : integer := 0 ; 
  signal ReadDataReadyDelayCycles       : integer := 0 ; 
  
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
  --  Initialize alerts
  ------------------------------------------------------------
  Initialize : process
    variable ID : AlertLogIDType ; 
  begin
    -- Alerts 
    ID                      := GetAlertLogID(MODEL_INSTANCE_NAME) ; 
    ModelID                 <= ID ; 
    ProtocolID              <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Protocol Error", ID ) ;
    DataCheckID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Data Check", ID ) ;
    BusFailedID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": No response", ID ) ;

    -- FIFOS.  FIFOS share main ID as they only generate errors if the model uses them wrong  
    WriteAddressFifo.SetAlertLogID(ID); 
    WriteAddressFifo.SetName(            MODEL_INSTANCE_NAME & ": WriteAddressFIFO"); 
    WriteDataFifo.SetAlertLogID(ID); 
    WriteDataFifo.SetName(               MODEL_INSTANCE_NAME & ": WriteDataFifo"); 
    ReadAddressFifo.SetAlertLogID(ID); 
    ReadAddressFifo.SetName(             MODEL_INSTANCE_NAME & ": ReadAddressFifo"); 
    ReadAddressTransactionFifo.SetAlertLogID(ID); 
    ReadAddressTransactionFifo.SetName(  MODEL_INSTANCE_NAME & ": ReadAddressTransactionFifo"); 
    ReadDataFifo.SetAlertLogID(ID); 
    ReadDataFifo.SetName(                MODEL_INSTANCE_NAME & ": ReadDataFifo"); 
    
    WriteResponseScoreboard.SetAlertLogID( MODEL_INSTANCE_NAME & ": WriteResponse Scoreboard", ID); 
    ReadResponseScoreboard.SetAlertLogID(  MODEL_INSTANCE_NAME & ": ReadResponse Scoreboard",  ID); 
    wait ; 
  end process Initialize ;


  ------------------------------------------------------------
  --  Transaction Dispatcher
  --    Dispatches transactions to
  ------------------------------------------------------------
  TransactionDispatcher : process
    variable WaitClockCycles    : integer ; 
    variable ReadDataTransactionCount : integer := 1 ; 
    variable ByteCount     : integer ;
    variable WriteAddress  : AWAddr'subtype ; 
    variable WriteByteAddr : integer ; 
    variable WriteData     : WData'subtype ; 
    variable WriteStrb     : WStrb'subtype ;
    variable ReadAddress   : ARAddr'subtype ; 
    variable ReadByteAddr  : integer ; 
    variable ReadProt      : ARProt'subtype ;
    variable ReadData      : RData'subtype ; 
    variable ExpectedData  : RData'subtype ; 
    variable Operation     : TransRec.Operation'subtype ; 
  begin
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
      when WRITE | ASYNC_WRITE | ASYNC_WRITE_ADDRESS | ASYNC_WRITE_DATA =>
        if IsWriteAddress(Operation) then 
          -- Queue Write Address
          WriteAddress  := FromTransaction(TransRec.Address) ;
          AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Write Address length does not match", FAILURE) ;
          
          -- Initiate Write Address
          WriteAddressFifo.Push(WriteAddress & ModelWriteProt) ; 
          Increment(WriteAddressRequestCount) ;

          -- Queue Write Response 
          WriteResponseScoreboard.Push(ModelWriteResp) ;
          Increment(WriteResponseExpectCount) ;
        end if ; 
        
        if IsWriteData(Operation) then 
          -- Queue Write Data 
          WriteAddress  := FromTransaction(TransRec.Address) ; -- WriteDataAsync
          ByteCount     := TransRec.DataWidth / 8 ;
          WriteByteAddr := CalculateAxiByteAddress(WriteAddress, AXI_DATA_BYTE_WIDTH);
          WriteStrb     := CalculateAxiWriteStrobe(WriteByteAddr, ByteCount, AXI_DATA_BYTE_WIDTH) ; 
          WriteData     := FromTransaction(TransRec.DataToModel) ;
          AlertIf(ModelID, TransRec.DataWidth mod 8 /= 0, "Master Write, Data not on a byte boundary", FAILURE) ;
          AlertIf(ModelID, TransRec.DataWidth > AXI_DATA_WIDTH, "Master Write, Data length too large", FAILURE) ;

          if ByteCount /= AXI_DATA_BYTE_WIDTH then 
            AlignAxiWriteData(WriteData, WriteByteAddr) ; 
            AlertIf(ModelID, AXI_DATA_BYTE_WIDTH - WriteByteAddr < ByteCount, 
              "Master Write, Byte Address not consistent with number of bytes sent", FAILURE) ; 
          end if ; 

          -- Initiate Write Data
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


      when READ | READ_CHECK | ASYNC_READ_ADDRESS | READ_DATA | READ_DATA_CHECK | TRY_READ_DATA =>
        if IsReadAddress(Operation) then
          -- Queue Read Address ; 
          ReadAddress   :=  FromTransaction(TransRec.Address) ;
          AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Read Address length does not match", FAILURE) ;
          ReadAddressFifo.Push(ReadAddress & ModelReadProt);
          ReadAddressTransactionFifo.Push(ReadAddress & ModelReadProt);
          Increment(ReadAddressRequestCount) ;

          -- Expect a Read Data Cycle - one read data cycle for each address issued.
          ReadResponseScoreboard.Push(ModelReadResp) ;
          Increment(ReadDataExpectCount) ;
        end if ; 

        if IsTryReadData(Operation) and ReadDataFifo.Empty then
          -- ReadDataReceiveCount < ReadDataTransactionCount then 
            TransRec.BoolFromModel <= FALSE ; 
        elsif IsReadData(Operation) then
          if ReadDataFifo.Empty then 
            WaitForToggle(ReadDataReceiveCount) ;
          end if ; 
          TransRec.BoolFromModel <= TRUE ; 
          
          -- Get Read Data and Check
          (ReadAddress, ReadProt) := ReadAddressTransactionFifo.Pop ;
          ReadByteAddr  :=  CalculateAxiByteAddress(ReadAddress, RData'length/8);
          ReadData := ReadDataFifo.Pop ;
          ByteCount := TransRec.DataWidth / 8 ;
          AlertIf(ModelID, TransRec.DataWidth mod 8 /= 0, "Master Read, Data not on a byte boundary", FAILURE) ;
          AlertIf(ModelID, TransRec.DataWidth > AXI_DATA_WIDTH, "Master Read, Data length too large", FAILURE) ;
          if ByteCount /= AXI_DATA_BYTE_WIDTH then 
            AlignAxiReadData(ReadData, ReadByteAddr, ByteCount) ; 
            AlertIf(ModelID, AXI_DATA_BYTE_WIDTH - ReadByteAddr < ByteCount, 
              "Master Read, Byte Address not consistent with number of bytes expected", FAILURE) ; 
          end if ; 
          TransRec.DataFromModel <= ToTransaction(ReadData) ;

          if IsReadCheck(TransRec.Operation) then
            ExpectedData := FromTransaction(TransRec.DataToModel) ;
            AffirmIf( DataCheckID, ReadData = ExpectedData,
              "Read Data: " & to_hstring(ReadData) & 
              "  Read Address: " & to_hstring(ReadAddress) &
              "  Prot: " & to_hstring(ReadProt),
              "  Expected: " & to_hstring(ExpectedData),
              TransRec.StatusMsgOn or IsLogEnabled(ModelID, INFO) ) ;
          else
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


      -- Model Configuration Options
      when SET_MODEL_OPTIONS =>
        -- Set Model Options
        case TransRec.Options is
          -- Master Ready TimeOut Checks
          when WRITE_ADDRESS_READY_TIME_OUT =>        WriteAddressReadyTimeOut      <= TransRec.IntToModel ; 
          when WRITE_DATA_READY_TIME_OUT =>           WriteDataReadyTimeOut         <= TransRec.IntToModel ;
          when READ_ADDRESS_READY_TIME_OUT =>         ReadAddressReadyTimeOut       <= TransRec.IntToModel ;
          -- Master Valid TimeOut Checks                                            
          when WRITE_RESPONSE_VALID_TIME_OUT =>       WriteResponseValidTimeOut     <= TransRec.IntToModel ;
          when READ_DATA_VALID_TIME_OUT =>            ReadDataValidTimeOut          <= TransRec.IntToModel ;
          -- Master Ready Before Valid
          when WRITE_RESPONSE_READY_BEFORE_VALID =>   WriteResponseReadyBeforeValid <= TransRec.BoolToModel ;
          when READ_DATA_READY_BEFORE_VALID =>        ReadDataReadyBeforeValid      <= TransRec.BoolToModel ;
          -- Master Ready Delay Cycles                
          when WRITE_RESPONSE_READY_DELAY_CYCLES =>   WriteResponseReadyDelayCycles <= TransRec.IntToModel ;
          when READ_DATA_READY_DELAY_CYCLES =>        ReadDataReadyDelayCycles      <= TransRec.IntToModel ;
          -- Master PROT Settings
          when WRITE_PROT =>                          ModelWriteProt <= to_slv(TransRec.IntToModel, ModelWriteProt'length) ; 
          when READ_PROT =>                           ModelReadProt  <= to_slv(TransRec.IntToModel, ModelReadProt'length) ; 
          -- Master RESP Settings
          when WRITE_RESP =>                          ModelWriteResp <= to_slv(TransRec.IntToModel, ModelWriteResp'length) ; 
          when READ_RESP =>                           ModelReadResp  <= to_slv(TransRec.IntToModel, ModelReadResp'length) ; 
          --
          -- The End -- Done  
          when others => 
            Alert(ModelID, "Unknown model option", FAILURE) ;
        end case ;
        wait for 0 ns ;  wait for 0 ns ; 


      when GET_MODEL_OPTIONS =>
        -- Set Model Options
        case TransRec.Options is
          -- Master Ready TimeOut Checks
          when WRITE_ADDRESS_READY_TIME_OUT =>        TransRec.IntFromModel  <= WriteAddressReadyTimeOut ; 
          when WRITE_DATA_READY_TIME_OUT =>           TransRec.IntFromModel  <= WriteDataReadyTimeOut ;
          when READ_ADDRESS_READY_TIME_OUT =>         TransRec.IntFromModel  <= ReadAddressReadyTimeOut ;
          -- Master Valid TimeOut Checks                                             
          when WRITE_RESPONSE_VALID_TIME_OUT =>       TransRec.IntFromModel  <= WriteResponseValidTimeOut ;
          when READ_DATA_VALID_TIME_OUT =>            TransRec.IntFromModel  <= ReadDataValidTimeOut ;
          -- Master Ready Before Valid                                       
          when WRITE_RESPONSE_READY_BEFORE_VALID =>   TransRec.BoolFromModel <= WriteResponseReadyBeforeValid ;
          when READ_DATA_READY_BEFORE_VALID =>        TransRec.BoolFromModel <= ReadDataReadyBeforeValid ;
          -- Master Ready Delay Cycles                                       
          when WRITE_RESPONSE_READY_DELAY_CYCLES =>   TransRec.IntFromModel  <= WriteResponseReadyDelayCycles ;
          when READ_DATA_READY_DELAY_CYCLES =>        TransRec.IntFromModel  <= ReadDataReadyDelayCycles ;
          -- Master PROT Settings
          when WRITE_PROT =>                          TransRec.IntFromModel  <= to_integer(ModelWriteProt) ; 
          when READ_PROT =>                           TransRec.IntFromModel  <= to_integer(ModelReadProt) ; 
          -- Master RESP Settings
          when WRITE_RESP =>                          TransRec.IntFromModel  <= to_integer(ModelWriteResp) ; 
          when READ_RESP =>                           TransRec.IntFromModel  <= to_integer(ModelReadResp) ; 
          -- The End -- Done  
          when others => 
            Alert(ModelID, "Unknown model option", FAILURE) ;
        end case ;
        wait for 0 ns ;  wait for 0 ns ; 
        
      when others =>
        Alert(ModelID, "Unimplemented Transaction", FAILURE) ;
        wait for 0 ns ;  wait for 0 ns ; 
    end case ;

  end process TransactionDispatcher ;


  ------------------------------------------------------------
  --  WriteAddressHandler
  --    Execute Write Address Transactions
  ------------------------------------------------------------
  WriteAddressHandler : process
    variable WriteProt    : AWProt'subtype ; 
    variable WriteAddress : AWAddr'subtype ; 
  begin
    AWValid <= '0' ;
    AWAddr  <= (AWAddr'range => '0') ;
    AWProt  <= (AWProt'range => '0') ;

    WriteAddressLoop : loop 
      -- Find Transaction
      if WriteAddressFifo.Empty then
         WaitForToggle(WriteAddressRequestCount) ;
      end if ;
      (WriteAddress, WriteProt) := WriteAddressFifo.Pop ;

      -- Do Transaction
      AWAddr  <= WriteAddress after tpd_Clk_AWAddr ; 
      AWProt  <= WriteProt after tpd_clk_AWProt ;

      Log(ModelID, 
        "Write Address." &
        "  AWAddr: "  & to_hstring(WriteAddress) &
        "  AWProt: "  & to_string( WriteProt) &
        "  Operation# " & to_string(WriteAddressDoneCount + 1),
        INFO
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk, 
        Valid          =>  AWValid, 
        Ready          =>  AWReady, 
        tpd_Clk_Valid  =>  tpd_Clk_AWValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Address # " & to_string(WriteAddressDoneCount + 1),
        TimeOutPeriod  =>  WriteAddressReadyTimeOut * tperiod_Clk
      ) ;
      
      -- State after operation
      AWAddr  <= WriteAddress + 1 after tpd_Clk_AWAddr ;
      AWProt  <= WriteProt + 1 after tpd_clk_AWProt ;

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
    variable WriteData : WData'subtype ; 
    variable WriteStrb : WStrb'subtype ;
  begin
    -- initialize
    WValid <= '0' ; 
    WData  <= (WData'range => '0') ;
    WStrb  <= (WStrb'range => '0') ;
    
    WriteDataLoop : loop
      -- Find Transaction
      if WriteDataFifo.Empty then
         WaitForToggle(WriteDataRequestCount) ;
      end if ;
      (WriteData, WriteStrb) := WriteDataFifo.Pop ;
      
      -- Do Transaction
      WData  <= WriteData after tpd_clk_WStrb ;
      WStrb  <= WriteStrb after tpd_Clk_WData ;
      
      Log(ModelID, 
        "Write Data." &
        "  WData: "  & to_hstring(WriteData) &
        "  WStrb: "  & to_string(WriteStrb) &
        "  Operation# " & to_string(WriteDataDoneCount + 1),
        INFO
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk, 
        Valid          =>  WValid, 
        Ready          =>  WReady, 
        tpd_Clk_Valid  =>  tpd_Clk_WValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Data # " & to_string(WriteDataDoneCount + 1),
        TimeOutPeriod  =>  WriteDataReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      WData  <= not WriteData after tpd_Clk_WData ;
      WStrb  <= (WStrb'range => '1') after tpd_clk_WStrb ; -- allow writes

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
  begin
    -- initialize
    BReady <= '0' ;
      
    WriteResponseOperation : loop 
      -- Find Expected Transaction
      WriteResponseActive <= FALSE ;
      if WriteResponseScoreboard.empty then
        WaitForToggle(WriteResponseExpectCount) ;
      end if ;
      WriteResponseActive <= TRUE ;
      
      Log(ModelID, "Waiting for Write Response.", DEBUG) ;

      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => BValid,
        Ready                   => BReady,
        ReadyBeforeValid        => WriteResponseReadyBeforeValid,
        ReadyDelayCycles        => WriteResponseReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_BReady,
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Write Response # " & to_string(WriteResponseReceiveCount + 1),
        TimeOutPeriod           => WriteResponseValidTimeOut * tperiod_Clk
      ) ;

      -- Check Write Response
      WriteResponseScoreboard.Check(BResp) ;
      
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
    wait on Clk until Clk = '1' and BValid = '1' ;
    AlertIf(ProtocolID, not WriteResponseActive,
      "Unexpected Write Response Cycle. " &
      " BValid: " & to_string(BValid) &
      " BResp: "  & to_string(BResp) &
      "  Operation# " & to_string(WriteResponseReceiveCount + 1),
      FAILURE
    ) ;
  end process WriteResponseProtocolChecker ;

  ------------------------------------------------------------
  --  ReadAddressHandler
  --    Execute Read Address Transactions
  ------------------------------------------------------------
  ReadAddressHandler : process
    variable ReadAddress : ARAddr'subtype ; 
    variable ReadProt    : ARProt'subtype ; 
  begin
    -- initialize 
    ARValid <= '0'  ; 
    ARAddr  <= (ARAddr'range => '0') ;
    ARProt  <= (ARProt'range => '0') ;

    AddressReadLoop : loop 
      -- Find Transaction
      if ReadAddressFifo.Empty then
         WaitForToggle(ReadAddressRequestCount) ;
      end if ;
      (ReadAddress, ReadProt) := ReadAddressFifo.Pop ;

      -- Do Transaction
      ARAddr  <= ReadAddress after tpd_Clk_ARAddr ;
      ARProt  <= ReadProt after tpd_clk_ARProt ;
      
      Log(ModelID, 
        "Read Address." &
        "  ARAddr: "  & to_hstring(ReadAddress) &
        "  ARProt: "  & to_string( ReadProt) &
        "  Operation# " & to_string(ReadAddressDoneCount + 1),
        INFO
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk, 
        Valid          =>  ARValid, 
        Ready          =>  ARReady, 
        tpd_Clk_Valid  =>  tpd_Clk_ARValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Read Address # " & to_string(ReadAddressDoneCount + 1),
        TimeOutPeriod  =>  ReadAddressReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      ARAddr  <= ReadAddress + 1 after tpd_clk_ARAddr ;
      ARProt  <= ReadProt + 1 after tpd_clk_ARProt ;

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
  begin
    RReady <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize
      
    ReadDataOperation : loop 
      -- Find Expected Transaction
      ReadDataActive <= FALSE ;
      if ReadDataReceiveCount >= ReadDataExpectCount then
        WaitForToggle(ReadDataExpectCount) ;
      end if ;
      ReadDataActive <= TRUE ;
      
      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => RValid,
        Ready                   => RReady,
        ReadyBeforeValid        => ReadDataReadyBeforeValid,
        ReadyDelayCycles        => ReadDataReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_RReady,
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Read Data # " & to_string(ReadDataReceiveCount + 1),
        TimeOutPeriod           => ReadDataValidTimeOut * tperiod_Clk
      ) ;

      -- capture data
      ReadDataFifo.push(RData) ;
      ReadResponseScoreboard.Check(RResp) ;

  --!TODO factor in data checking here or keep it in transaction handler?

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
    wait on Clk until Clk = '1' and RValid = '1' ;
    AlertIf(ProtocolID, not ReadDataActive,
      "Unexpected Read Data Cycle. " &
      " RValid: " & to_string(RValid) &
      " RData: "  & to_hstring(RData) &
      " RResp: "  & to_string(RResp) &
      "  Operation# " & to_string(ReadDataReceiveCount + 1),
      FAILURE
    ) ;
  end process ReadDataProtocolChecker ;

end architecture SimpleMaster ;

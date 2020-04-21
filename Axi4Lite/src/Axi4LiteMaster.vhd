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
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;

  use work.Axi4LiteMasterOptionsTypePkg.all ;
  use work.Axi4LiteMasterTransactionPkg.all ;
  use work.Axi4LiteMasterPkg.all ;
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

  -- Testbench Transaction Interface
  TransRec    : inout AddressBusMasterTransactionRecType ;

  -- AXI Master Functional Interface
  AxiLiteBus  : inout Axi4LiteRecType
) ;
    constant TBD : integer := 7 ;

    -- Write Address
    alias  AWAddr    : std_logic_vector is AxiLiteBus.WriteAddress.AWAddr ;
    alias  AWProt    : Axi4ProtType     is AxiLiteBus.WriteAddress.AWProt ;
    alias  AWValid   : std_logic        is AxiLiteBus.WriteAddress.AWValid ;
    alias  AWReady   : std_logic        is AxiLiteBus.WriteAddress.AWReady ;
    -- Axi4 Full
    alias  AWID      : std_logic_vector is AxiLiteBus.WriteAddress.AWID ;
    alias  AWLen     : std_logic_vector is AxiLiteBus.WriteAddress.AWLen ;
    alias  AWSize    : std_logic_vector is AxiLiteBus.WriteAddress.AWSize ;
    alias  AWBurst   : std_logic_vector is AxiLiteBus.WriteAddress.AWBurst ;
    alias  AWLock    : std_logic        is AxiLiteBus.WriteAddress.AWLock ;
    alias  AWCache   : std_logic_vector is AxiLiteBus.WriteAddress.AWCache ;
    alias  AWQOS     : std_logic_vector is AxiLiteBus.WriteAddress.AWQOS ;
    alias  AWRegion  : std_logic_vector is AxiLiteBus.WriteAddress.AWRegion ;
    alias  AWUser    : std_logic_vector is AxiLiteBus.WriteAddress.AWUser ;

    -- Write Data
    alias  WData     : std_logic_vector is AxiLiteBus.WriteData.WData ;
    alias  WStrb     : std_logic_vector is AxiLiteBus.WriteData.WStrb ;
    alias  WValid    : std_logic        is AxiLiteBus.WriteData.WValid ;
    alias  WReady    : std_logic        is AxiLiteBus.WriteData.WReady ;
    -- AXI4 Full
    alias  WLast     : std_logic        is AxiLiteBus.WriteData.WLast ;
    alias  WUser     : std_logic_vector is AxiLiteBus.WriteData.WUser ;
    -- AXI3
    alias  WID       : std_logic_vector is AxiLiteBus.WriteData.WID ;

    -- Write Response
    alias  BResp     : Axi4RespType     is AxiLiteBus.WriteResponse.BResp ;
    alias  BValid    : std_logic        is AxiLiteBus.WriteResponse.BValid ;
    alias  BReady    : std_logic        is AxiLiteBus.WriteResponse.BReady ;
    -- AXI4 Full
    alias  BID       : std_logic_vector is AxiLiteBus.WriteResponse.BID ;
    alias  BUser     : std_logic_vector is AxiLiteBus.WriteResponse.BUser ;

    -- Read Address
    alias  ARAddr    : std_logic_vector is AxiLiteBus.ReadAddress.ARAddr ;
    alias  ARProt    : Axi4ProtType     is AxiLiteBus.ReadAddress.ARProt ;
    alias  ARValid   : std_logic        is AxiLiteBus.ReadAddress.ARValid ;
    alias  ARReady   : std_logic        is AxiLiteBus.ReadAddress.ARReady ;
    -- Axi4 Full
    alias  ARID      : std_logic_vector is AxiLiteBus.ReadAddress.ARID ;
    -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
    alias  ARLen     : std_logic_vector is AxiLiteBus.ReadAddress.ARLen ;
    -- #Bytes in transfer = 2**AxSize
    alias  ARSize    : std_logic_vector is AxiLiteBus.ReadAddress.ARSize ;
    -- AxBurst = (Fixed, Incr, Wrap, NotDefined)
    alias  ARBurst   : std_logic_vector is AxiLiteBus.ReadAddress.ARBurst ;
    alias  ARLock    : std_logic is AxiLiteBus.ReadAddress.ARLock ;
    -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
    alias  ARCache   : std_logic_vector is AxiLiteBus.ReadAddress.ARCache  ;
    alias  ARQOS     : std_logic_vector is AxiLiteBus.ReadAddress.ARQOS    ;
    alias  ARRegion  : std_logic_vector is AxiLiteBus.ReadAddress.ARRegion ;
    alias  ARUser    : std_logic_vector is AxiLiteBus.ReadAddress.ARUser   ;

    -- Read Data
    alias  RData     : std_logic_vector is AxiLiteBus.ReadData.RData ;
    alias  RResp     : Axi4RespType     is AxiLiteBus.ReadData.RResp ;
    alias  RValid    : std_logic        is AxiLiteBus.ReadData.RValid ;
    alias  RReady    : std_logic        is AxiLiteBus.ReadData.RReady ;
    -- AXI4 Full
    alias  RID       : std_logic_vector is AxiLiteBus.ReadData.RID   ;
    alias  RLast     : std_logic        is AxiLiteBus.ReadData.RLast ;
    alias  RUser     : std_logic_vector is AxiLiteBus.ReadData.RUser ;

end entity Axi4LiteMaster ;
architecture SimpleMaster of Axi4LiteMaster is

  constant AXI_ADDR_WIDTH : integer := AWAddr'length ;
  constant AXI_DATA_WIDTH : integer := WData'length ;
  constant AXI_DATA_BYTE_WIDTH : integer := AXI_DATA_WIDTH / 8 ;
  constant AXI_BYTE_ADDR_WIDTH : integer := integer(ceil(log2(real(AXI_DATA_BYTE_WIDTH)))) ; 

  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4LiteMaster'PATH_NAME))) ;
  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ;

  shared variable WriteAddressFifo            : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable WriteDataFifo               : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable WriteBurstFifo              : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  
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

--!! TODO All of these need defaults that accomodate either Axi4Lite or Axi4Full
--!! TODO Check Resize to see if allows throwing bits away indiscriminately (AXI4Lite)
  -- Write Address
  -- AXI
  signal ModelAWProt     : AWProt'subtype    := (others => '0') ;
  -- AXI4 Full
  signal ModelAWID       : AWID'subtype      := (others => '0') ;
  signal ModelAWSize     : AWSize'subtype    := to_slv(AXI_DATA_BYTE_WIDTH, AWSize'length) ;
  signal ModelAWBurst    : AWBurst'subtype   := (others => '0') ; 
  signal ModelAWLock     : AWLock'subtype    := '0' ;
  signal ModelAWCache    : AWCache'subtype   := (others => '0') ;
  signal ModelAWQOS      : AWQOS'subtype     := (others => '0') ;
  signal ModelAWRegion   : AWRegion'subtype  := (others => '0') ;
  signal ModelAWUser     : AWUser'subtype    := (others => '0') ;

  -- Write Data
  -- AXI
  -- AXI4 Full
  signal ModelWLast      : WLast'subtype ;
  signal ModelWUser      : WUser'subtype ;
  -- AXI3
  signal ModelWID        : WID'subtype ;


  -- Write Response
  signal WriteResponseReadyBeforeValid  : boolean := TRUE ;
  signal WriteResponseReadyDelayCycles  : integer := 0 ;

  -- AXI
  signal ModelBResp     : BResp'subtype := to_Axi4RespType(OKAY);
  -- AXI4 Full
  signal ModelBID       : BID'subtype ;
  signal ModelBUser     : BUser'subtype ;

  -- Read Address
  signal ModelARProt  : Axi4ProtType         := (others => '0') ;

  signal ModelARID       : ARID'subtype      := (others => '0') ;
  signal ModelARSize     : ARSize'subtype    := to_slv(AXI_DATA_BYTE_WIDTH, ARSize'length) ;
  signal ModelARBurst    : ARBurst'subtype   := (others => '0') ;
  signal ModelARLock     : ARLock'subtype    := '0' ;
  signal ModelARCache    : ARCache'subtype   := (others => '0') ;
  signal ModelARQOS      : ARQOS'subtype     := (others => '0') ;
  signal ModelARRegion   : ARRegion'subtype  := (others => '0') ;
  signal ModelARUser     : ARUser'subtype    := (others => '0') ;

  -- Read Data
  signal ReadDataReadyBeforeValid       : boolean := TRUE ;
  signal ReadDataReadyDelayCycles       : integer := 0 ;

  -- AXI
  signal ModelRResp     : RResp'subtype := to_Axi4RespType(OKAY) ;
  -- AXI4 Full
  signal ModelRID       : RID'subtype ;
  signal ModelRLast     : RLast'subtype ;
  signal ModelRUser     : RUser'subtype ;


begin

  ------------------------------------------------------------
  -- Turn off drivers not being driven by this model
  ------------------------------------------------------------
  InitAxi4LiteRec (AxiBusRec => AxiLiteBus) ;


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
    
    variable WriteAddress    : AWAddr'subtype ;
    variable WriteBurstLen   : AWLen'subtype ; 
    
    variable WriteByteAddr   : integer ;
    variable WriteData       : WData'subtype ;
    variable WriteStrb       : WStrb'subtype ;
    variable WriteLast       : WLast'subtype ;
    
    variable BytesToSend              : integer ; 
    variable BytesPerTransfer         : integer ; 
    variable MaxBytesInFirstTransfer  : integer ; 

    
    variable ReadAddress     : ARAddr'subtype ;
    variable ReadAddressLen  : ARLen'subtype ; 
    variable ReadByteAddr    : integer ;
    variable ReadProt        : ARProt'subtype ;
    
    variable ReadData        : RData'subtype ;
    variable ExpectedData    : RData'subtype ;
    
    variable Operation       : TransRec.Operation'subtype ;
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
      when WRITE | ASYNC_WRITE | ASYNC_WRITE_ADDRESS | ASYNC_WRITE_DATA |
           WRITE_BURST | ASYNC_WRITE_BURST =>
        if IsWriteAddress(Operation) then
          -- Write Address Handling
          WriteAddress  := FromTransaction(TransRec.Address) ;
          WriteByteAddr := CalculateAxiByteAddress(WriteAddress, AXI_BYTE_ADDR_WIDTH);
          AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Write Address length does not match", FAILURE) ;
          
          if not IsBurst(Operation) then 
            -- Single word transfer, burst length = 0
            WriteBurstLen := (others => '0') ; 
          else
            -- Burst transfer, calcualte burst length 
            WriteBurstLen := to_slv(CalculateAxiBurstLen(TransRec.DataWidth, WriteByteAddr, to_integer(ModelAWSize)), WriteBurstLen'length) ;
          end if ; 
          
          -- Initiate Write Address
          WriteAddressFifo.Push(WriteAddress & ModelAWProt & WriteBurstLen & ModelAWID & ModelAWSize & ModelAWBurst & ModelAWLock & ModelAWCache & ModelAWQOS & ModelAWRegion & ModelAWUser) ;            
          Increment(WriteAddressRequestCount) ;

          -- Queue Write Response
          WriteResponseScoreboard.Push(ModelBResp) ;
          Increment(WriteResponseExpectCount) ;
        end if ;

        if IsWriteData(Operation) then
          WriteAddress  := FromTransaction(TransRec.Address) ; 
          WriteByteAddr := CalculateAxiByteAddress(WriteAddress, AXI_BYTE_ADDR_WIDTH);
          
          if not IsBurst(Operation) then
            -- Single Transfer Write Data Handling
            WriteData     := FromTransaction(TransRec.DataToModel) ;
            AlignCheckWriteData (ModelID, WriteData, WriteStrb, TransRec.DataWidth, WriteByteAddr) ;
            WriteDataFifo.Push(WriteData & WriteStrb & '1' & ModelWUser & ModelWID) ;

            Increment(WriteDataRequestCount) ;
            
          else
            -- Burst Transfer Write Data Handling
            BytesToSend       := TransRec.DataWidth ; 
            BytesPerTransfer  := to_integer(ModelAWSize) ;
            MaxBytesInFirstTransfer := BytesPerTransfer - WriteByteAddr ; 
            AlertIf(ModelID, BytesPerTransfer /= AXI_DATA_BYTE_WIDTH, 
              "Write Bytes Per Transfer (" & to_string(BytesPerTransfer) & ") " & 
              "/= AXI_DATA_BYTE_WIDTH (" & to_string(AXI_DATA_BYTE_WIDTH) & ")"
            );
            
            WriteBurstLen := to_slv(CalculateAxiBurstLen(BytesToSend, WriteByteAddr, to_integer(ModelAWSize)), WriteBurstLen'length) ;

            -- First Word of Burst, maybe a 1 word burst
            if BytesToSend > MaxBytesInFirstTransfer then
              -- More than 1 transfer in burst
              GetWriteBurstData(WriteBurstFifo, WriteData, WriteStrb, MaxBytesInFirstTransfer, WriteByteAddr) ; 
              WriteDataFifo.Push(WriteData & WriteStrb & '0' & ModelWUser & ModelWID) ;
              BytesToSend       := BytesToSend - MaxBytesInFirstTransfer; 
            else
              -- Only one transfer in Burst.  # Bytes may be less than a whole word
              GetWriteBurstData(WriteBurstFifo, WriteData, WriteStrb, BytesToSend, WriteByteAddr) ; 
              WriteDataFifo.Push(WriteData & WriteStrb & '1' & ModelWUser & ModelWID) ;
              BytesToSend := 0 ; 
            end if ; 

            -- Middle words of burst
            while BytesToSend >= BytesPerTransfer loop
              GetWriteBurstData(WriteBurstFifo, WriteData, WriteStrb, BytesPerTransfer) ;
              WriteDataFifo.Push(WriteData & WriteStrb & '0' & ModelWUser & ModelWID) ;
              BytesToSend := BytesToSend - BytesPerTransfer ; 
            end loop ; 
            
            -- End of Burst
            if BytesToSend > 0 then 
              GetWriteBurstData(WriteBurstFifo, WriteData, WriteStrb, BytesToSend) ;
              WriteDataFifo.Push(WriteData & WriteStrb & '1' & ModelWUser & ModelWID) ;
            end if ; 
            
            -- Increment(WriteDataRequestCount) ;
            WriteDataRequestCount <= WriteDataRequestCount + to_integer(WriteBurstLen) ;

          end if ;
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
          -- Send Read Address to Read Address Handler and Read Data Handler
          ReadAddress   :=  FromTransaction(TransRec.Address) ;
          ReadByteAddr  :=  CalculateAxiByteAddress(ReadAddress, AXI_BYTE_ADDR_WIDTH);
          AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Read Address length does not match", FAILURE) ;
          if not IsBurst(Operation) then 
            ReadAddressLen := (others => '0') ; 
          else
            Alert(ModelID, "Bursts Not Implemented") ;
            ReadAddressLen := to_slv(CalculateAxiBurstLen(TransRec.DataWidth, ReadByteAddr, to_integer(ModelARSize)), ReadAddressLen'length) ;
          end if ; 
          
          ReadAddressFifo.Push(ReadAddress & ModelARProt & ReadAddressLen & ModelARID & ModelARSize & ModelARBurst & ModelARLock & ModelARCache & ModelARQOS & ModelARRegion & ModelARUser) ;            
          ReadAddressTransactionFifo.Push(ReadAddress & ModelARProt);
          Increment(ReadAddressRequestCount) ;

          -- Expect a Read Data Cycle
          ReadResponseScoreboard.Push(ModelRResp) ;
          Increment(ReadDataExpectCount) ;
        end if ;

        if IsTryReadData(Operation) and ReadDataFifo.Empty then
          -- Data not available
          -- ReadDataReceiveCount < ReadDataTransactionCount then
          TransRec.BoolFromModel <= FALSE ;
        elsif IsReadData(Operation) then
          if not IsBurst(Operation) then
            -- Wait for Data Ready
            if ReadDataFifo.Empty then
              WaitForToggle(ReadDataReceiveCount) ;
            end if ;
            TransRec.BoolFromModel <= TRUE ;

            -- Get Read Data
            ReadData := ReadDataFifo.Pop ;
            (ReadAddress, ReadProt) := ReadAddressTransactionFifo.Pop ;
            AxiReadDataAlignCheck (ModelID, ReadData, TransRec.DataWidth, ReadAddress, AXI_DATA_BYTE_WIDTH) ;
            TransRec.DataFromModel <= ToTransaction(ReadData) ;

            -- Check or Log Read Data
            if IsReadCheck(TransRec.Operation) then
              ExpectedData := FromTransaction(TransRec.DataToModel) ;
--!! TODO:  Change format to Address, Data Transaction #, Read Data           
              AffirmIf( DataCheckID, ReadData = ExpectedData,
                "Read Data: " & to_hstring(ReadData) &
                "  Read Address: " & to_hstring(ReadAddress) &
                "  Prot: " & to_hstring(ReadProt),
                "  Expected: " & to_hstring(ExpectedData),
                TransRec.StatusMsgOn or IsLogEnabled(ModelID, INFO) ) ;
            else
--!! TODO:  Change format to Address, Data Transaction #, Read Data           
              Log( ModelID,
                "Read Data: " & to_hstring(ReadData) &
                "  Read Address: " & to_hstring(ReadAddress) &
                "  Prot: " & to_hstring(ReadProt),
                INFO,
                TransRec.StatusMsgOn
              ) ;
            end if ;
          else
            Alert(ModelID, "Bursts Not Implemented") ;
            -- Pull Burst out of Read Data FIFO (Word Oriented) and put in ReadBurstFifo (ByteOriented)
            -- Address
            -- First and Last bytes
          end if ;
        end if ;

        -- Transaction wait time
        wait for 0 ns ;  wait for 0 ns ;


      -- Model Configuration Options
      when SET_MODEL_OPTIONS =>
        -- Set Model Options
        case TransRec.Options is
          -- Write Address Settings
          when WRITE_ADDRESS_READY_TIME_OUT =>        WriteAddressReadyTimeOut      <= TransRec.IntToModel ;
          -- AXI
          when WRITE_PROT =>                          ModelAWProt   <= to_slv(TransRec.IntToModel, ModelAWProt'length) ;
          -- AXI4 Full
          when WRITE_ADDRESS_ID =>                    ModelAWID     <= to_slv(TransRec.IntToModel, ModelAWID'length) ;
          when WRITE_ADDRESS_SIZE =>                  ModelAWSize   <= to_slv(TransRec.IntToModel, ModelAWSize'length) ;
          when WRITE_ADDRESS_BURST =>                 ModelAWBurst  <= to_slv(TransRec.IntToModel, ModelAWBurst'length) ;
          when WRITE_ADDRESS_LOCK =>                  ModelAWLock   <= '1' when TransRec.IntToModel mod 2 = 1 else '0' ; 
          when WRITE_ADDRESS_CACHE =>                 ModelAWCache  <= to_slv(TransRec.IntToModel, ModelAWCache'length) ;
          when WRITE_ADDRESS_QOS =>                   ModelAWQOS    <= to_slv(TransRec.IntToModel, ModelAWQOS'length) ;
          when WRITE_ADDRESS_REGION =>                ModelAWRegion <= to_slv(TransRec.IntToModel, ModelAWRegion'length) ;
          when WRITE_ADDRESS_USER =>                  ModelAWUser   <= to_slv(TransRec.IntToModel, ModelAWUser'length) ;

          -- Write Data Settings
          when WRITE_DATA_READY_TIME_OUT =>           WriteDataReadyTimeOut         <= TransRec.IntToModel ;
          -- AXI
          -- AXI4 Full
          when WRITE_DATA_LAST =>                     ModelWLast    <= '1' when TransRec.IntToModel mod 2 = 1 else '0' ;
          when WRITE_DATA_USER =>                     ModelWUser    <= to_slv(TransRec.IntToModel, TransRec.IntFromModel) ; 
          -- AXI3
          when WRITE_DATA_ID =>                       ModelWID      <= to_slv(TransRec.IntToModel, TransRec.IntFromModel) ; 


          -- Write Response Settings
          when WRITE_RESPONSE_VALID_TIME_OUT =>       WriteResponseValidTimeOut     <= TransRec.IntToModel ;
          when WRITE_RESPONSE_READY_BEFORE_VALID =>   WriteResponseReadyBeforeValid <= TransRec.BoolToModel ;
          when WRITE_RESPONSE_READY_DELAY_CYCLES =>   WriteResponseReadyDelayCycles <= TransRec.IntToModel ;
          
          -- AXI
          when WRITE_RESPONSE_RESP =>                 ModelBResp <= to_slv(TransRec.IntToModel, ModelBResp'length) ;
          -- AXI4 Full
          when WRITE_RESPONSE_ID =>                   ModelBID   <= to_slv(TransRec.IntFromModel, ModelBID'length) ; 
          when WRITE_RESPONSE_USER =>                 ModelBUser <= to_slv(TransRec.IntFromModel, ModelBUser'length) ; 

          -- Read Address Settings
          when READ_ADDRESS_READY_TIME_OUT =>         ReadAddressReadyTimeOut       <= TransRec.IntToModel ;
          -- AXI
          when READ_PROT =>                           ModelARProt  <= to_slv(TransRec.IntToModel, ModelARProt'length) ;
          -- AXI4 Full
          when Read_ADDRESS_ID =>                     ModelARID     <= to_slv(TransRec.IntToModel, ModelARID'length) ;
          when Read_ADDRESS_SIZE =>                   ModelARSize   <= to_slv(TransRec.IntToModel, ModelARSize'length) ;
          when Read_ADDRESS_BURST =>                  ModelARBurst  <= to_slv(TransRec.IntToModel, ModelARBurst'length) ;
          when Read_ADDRESS_LOCK =>                   ModelARLock   <= '1' when TransRec.IntToModel mod 2 = 1 else '0' ;
          when Read_ADDRESS_CACHE =>                  ModelARCache  <= to_slv(TransRec.IntToModel, ModelARCache'length) ;
          when Read_ADDRESS_QOS =>                    ModelARQOS    <= to_slv(TransRec.IntToModel, ModelARQOS'length) ;
          when Read_ADDRESS_REGION =>                 ModelARRegion <= to_slv(TransRec.IntToModel, ModelARRegion'length) ;
          when Read_ADDRESS_USER =>                   ModelARUser   <= to_slv(TransRec.IntToModel, ModelARUser'length) ;

          -- Read Data / Response Settings
          when READ_DATA_VALID_TIME_OUT =>            ReadDataValidTimeOut          <= TransRec.IntToModel ;
          when READ_DATA_READY_BEFORE_VALID =>        ReadDataReadyBeforeValid      <= TransRec.BoolToModel ;
          when READ_DATA_READY_DELAY_CYCLES =>        ReadDataReadyDelayCycles      <= TransRec.IntToModel ;
          -- AXI
          when READ_DATA_RESP =>                      ModelRResp   <= to_slv(TransRec.IntToModel, ModelRResp'length) ;
          -- AXI4 Full
          when READ_DATA_ID =>                        ModelRID   <= to_slv(TransRec.IntFromModel, ModelRID'length) ; 
          when READ_DATA_LAST =>                      ModelRLast    <= '1' when TransRec.IntToModel mod 2 = 1 else '0' ;
          when READ_DATA_USER =>                      ModelRUser <= to_slv(TransRec.IntFromModel, ModelRUser'length) ; 


          -- The End -- Done
          when others =>
            Alert(ModelID, "Unknown model option", FAILURE) ;
        end case ;
        wait for 0 ns ;  wait for 0 ns ;


      when GET_MODEL_OPTIONS =>
        -- Set Model Options
        case TransRec.Options is

          -- Write Address Settings
          when WRITE_ADDRESS_READY_TIME_OUT =>        TransRec.IntFromModel  <= WriteAddressReadyTimeOut ;
          -- AXI
          when WRITE_PROT =>                          TransRec.IntFromModel  <= to_integer(ModelAWProt) ;
          -- AXI4 Full
          when WRITE_ADDRESS_ID =>                    TransRec.IntFromModel  <= to_integer(ModelAWID     ) ; 
          when WRITE_ADDRESS_SIZE =>                  TransRec.IntFromModel  <= to_integer(ModelAWSize   ) ; 
          when WRITE_ADDRESS_BURST =>                 TransRec.IntFromModel  <= to_integer(ModelAWBurst  ) ; 
          when WRITE_ADDRESS_LOCK =>                  TransRec.IntFromModel  <= to_integer(unsigned'('0' & ModelAWLock)   ) ; 
          when WRITE_ADDRESS_CACHE =>                 TransRec.IntFromModel  <= to_integer(ModelAWCache  ) ; 
          when WRITE_ADDRESS_QOS =>                   TransRec.IntFromModel  <= to_integer(ModelAWQOS    ) ; 
          when WRITE_ADDRESS_REGION =>                TransRec.IntFromModel  <= to_integer(ModelAWRegion ) ; 
          when WRITE_ADDRESS_USER =>                  TransRec.IntFromModel  <= to_integer(ModelAWUser   ) ; 

          -- Write Data Settings
          when WRITE_DATA_READY_TIME_OUT =>           TransRec.IntFromModel  <= WriteDataReadyTimeOut ;

          -- AXI
          -- AXI4 Full
          when WRITE_DATA_LAST =>                     TransRec.IntFromModel  <= to_integer(unsigned'('0' & ModelWLast)   ) ; 
          when WRITE_DATA_USER =>                     TransRec.IntFromModel  <= to_integer(ModelWUser   ) ; 
          -- AXI3
          when WRITE_DATA_ID =>                       TransRec.IntFromModel  <= to_integer(ModelWID     ) ; 

          -- Write Response Settings
          when WRITE_RESPONSE_VALID_TIME_OUT =>       TransRec.IntFromModel  <= WriteResponseValidTimeOut ;
          when WRITE_RESPONSE_READY_BEFORE_VALID =>   TransRec.BoolFromModel <= WriteResponseReadyBeforeValid ;
          when WRITE_RESPONSE_READY_DELAY_CYCLES =>   TransRec.IntFromModel  <= WriteResponseReadyDelayCycles ;
          -- AXI
          when WRITE_RESPONSE_RESP =>                 TransRec.IntFromModel  <= to_integer(ModelBResp) ;
          -- AXI4 Full
          when WRITE_RESPONSE_ID =>                   TransRec.IntFromModel  <= to_integer(ModelBID     ) ; 
          when WRITE_RESPONSE_USER =>                 TransRec.IntFromModel  <= to_integer(ModelBUser   ) ; 

          -- Read Address Settings
          when READ_ADDRESS_READY_TIME_OUT =>         TransRec.IntFromModel  <= ReadAddressReadyTimeOut ;
          -- AXI
          when READ_PROT =>                           TransRec.IntFromModel  <= to_integer(ModelARProt) ;
          -- AXI4 Full
          when READ_ADDRESS_ID =>                     TransRec.IntFromModel  <= to_integer(ModelARID     ) ; 
          when READ_ADDRESS_SIZE =>                   TransRec.IntFromModel  <= to_integer(ModelARSize   ) ; 
          when READ_ADDRESS_BURST =>                  TransRec.IntFromModel  <= to_integer(ModelARBurst  ) ; 
          when READ_ADDRESS_LOCK =>                   TransRec.IntFromModel  <= to_integer(unsigned'('0' & ModelARLock)   ) ; 
          when READ_ADDRESS_CACHE =>                  TransRec.IntFromModel  <= to_integer(ModelARCache  ) ; 
          when READ_ADDRESS_QOS =>                    TransRec.IntFromModel  <= to_integer(ModelARQOS    ) ; 
          when READ_ADDRESS_REGION =>                 TransRec.IntFromModel  <= to_integer(ModelARRegion ) ; 
          when READ_ADDRESS_USER =>                   TransRec.IntFromModel  <= to_integer(ModelARUser   ) ; 

          -- Read Data / Response Settings
          when READ_DATA_VALID_TIME_OUT =>            TransRec.IntFromModel  <= ReadDataValidTimeOut ;
          when READ_DATA_READY_BEFORE_VALID =>        TransRec.BoolFromModel <= ReadDataReadyBeforeValid ;
          when READ_DATA_READY_DELAY_CYCLES =>        TransRec.IntFromModel  <= ReadDataReadyDelayCycles ;
          -- AXI
          when READ_DATA_RESP =>                      TransRec.IntFromModel  <= to_integer(ModelRResp) ;
          -- AXI4 Full
          when READ_DATA_ID =>                        TransRec.IntFromModel  <= to_integer(ModelRID     ) ; 
          when READ_DATA_LAST =>                      TransRec.IntFromModel  <= to_integer(unsigned'('0' & ModelRLast)) ; 
          when READ_DATA_USER =>                      TransRec.IntFromModel  <= to_integer(ModelRUser   ) ; 

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
    variable Address : AWAddr'subtype   := (others => '0') ;
    variable Prot    : AWProt'subtype   := (others => '0') ;
    variable Len     : AWLen'subtype    := (others => '0') ;
    variable ID      : AWID'subtype     := (others => '0') ;
    variable Size    : AWSize'subtype   := (others => '0') ;
    variable Burst   : AWBurst'subtype  := (others => '0') ;
    variable Lock    : AWLock'subtype   := '0' ;
    variable Cache   : AWCache'subtype  := (others => '0') ;
    variable QOS     : AWQOS'subtype    := (others => '0') ;
    variable Region  : AWRegion'subtype := (others => '0') ;
    variable User    : AWUser'subtype   := (others => '0') ;

  begin
    -- AXI4 LIte Signaling
    AWValid  <= '0' ;
    AWAddr   <= Address ;
    AWProt   <= Prot    ;
    -- AXI4 Full Signaling
    AWLen    <= Len     ;
    AWID     <= ID      ;
    AWSize   <= Size    ;
    AWBurst  <= Burst   ;
    AWLock   <= Lock    ;
    AWCache  <= Cache   ;
    AWQOS    <= QOS     ;
    AWRegion <= Region  ;
    AWUser   <= User    ;
    
    WriteAddressLoop : loop
      -- Find Transaction
      if WriteAddressFifo.Empty then
         WaitForToggle(WriteAddressRequestCount) ;
      end if ;
      (Address, Prot, Len, ID, Size, Burst, Lock, Cache, QOS, Region, User) := WriteAddressFifo.Pop ;

      -- Do Transaction
      AWAddr   <= Address   after tpd_Clk_AWAddr   ;
      AWProt   <= Prot      after tpd_clk_AWProt   ;
      -- AXI4 Full
      AWLen    <= Len       after tpd_clk_AWLen    ;
      AWID     <= ID        after tpd_clk_AWID     ;
      AWSize   <= Size      after tpd_clk_AWSize   ;
      AWBurst  <= Burst     after tpd_clk_AWBurst  ;
      AWLock   <= Lock      after tpd_clk_AWLock   ;
      AWCache  <= Cache     after tpd_clk_AWCache  ;
      AWQOS    <= QOS       after tpd_clk_AWQOS    ;
      AWRegion <= Region    after tpd_clk_AWRegion ;
      AWUser   <= User      after tpd_clk_AWUser   ;

      Log(ModelID,
        "Write Address." &
        "  AWAddr: "  & to_hstring(Address) &
        "  AWProt: "  & to_string( Prot) &
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
      AWAddr  <= Address + 1  after tpd_Clk_AWAddr   ;
      AWProt  <= Prot    + 1  after tpd_clk_AWProt   ;
      -- AXI4 Full
      AWLen    <= Len    + 1  after tpd_clk_AWLen    ;
      AWID     <= ID     + 1  after tpd_clk_AWID     ;
      AWSize   <= Size   + 1  after tpd_clk_AWSize   ;
      AWBurst  <= Burst  + 1  after tpd_clk_AWBurst  ;
      AWLock   <= Lock        after tpd_clk_AWLock   ;
      AWCache  <= Cache  + 1  after tpd_clk_AWCache  ;
      AWQOS    <= QOS    + 1  after tpd_clk_AWQOS    ;
      AWRegion <= Region + 1  after tpd_clk_AWRegion ;
      AWUser   <= User   + 1  after tpd_clk_AWUser   ;

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
    variable Data : WData'subtype := (others => '0') ;
    variable Strb : WStrb'subtype := (others => '0') ;
    variable Last : WLast'subtype ;
    variable User : WUser'subtype := (others => '0') ;
    variable ID   : WID'subtype   := (others => '0') ;
  begin
    -- initialize
    WValid <= '0' ;
    WData  <= Data ;
    WStrb  <= Strb ;
    -- AXI4 Full
    WLast  <= '0' ;
    WUser  <= User ;
    -- AXI3
    WID    <= ID ;

    WriteDataLoop : loop
      -- Find Transaction
      if WriteDataFifo.Empty then
         WaitForToggle(WriteDataRequestCount) ;
      end if ;
      (Data, Strb, Last, User, ID) := WriteDataFifo.Pop ;

      -- Do Transaction
      WData  <= Data after tpd_clk_WStrb ;
      WStrb  <= Strb after tpd_Clk_WData ;
      -- AXI4 Full
      WLast  <= Last after tpd_Clk_WLast ;
      WUser  <= User after tpd_Clk_WUser ;
      -- AXI3
      WID    <= ID   after tpd_Clk_WID ;

      Log(ModelID,
        "Write Data." &
        "  WData: "  & to_hstring(Data) &
        "  WStrb: "  & to_string( Strb) &
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
      WData  <= not Data             after tpd_Clk_WData ;
      WStrb  <= (WStrb'range => '1') after tpd_clk_WStrb ; -- allow writes
      -- AXI4 Full
      WLast  <= not Last             after tpd_Clk_WLast ;
      WUser  <= User                 after tpd_Clk_WUser ;
      -- AXI3
      WID    <= ID                   after tpd_Clk_WID ;

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
    variable Address : ARAddr'subtype   := (others => '0') ;
    variable Prot    : ARProt'subtype   := (others => '0') ;
    variable Len     : ARLen'subtype    := (others => '0') ;
    variable ID      : ARID'subtype     := (others => '0') ;
    variable Size    : ARSize'subtype   := (others => '0') ;
    variable Burst   : ARBurst'subtype  := (others => '0') ;
    variable Lock    : ARLock'subtype   := '0' ;
    variable Cache   : ARCache'subtype  := (others => '0') ;
    variable QOS     : ARQOS'subtype    := (others => '0') ;
    variable Region  : ARRegion'subtype := (others => '0') ;
    variable User    : ARUser'subtype   := (others => '0') ;

  begin
    -- AXI4 LIte Signaling
    ARValid  <= '0' ;
    ARAddr   <= Address ;
    ARProt   <= Prot    ;
    -- AXI4 Full Signaling
    ARLen    <= Len     ;
    ARID     <= ID      ;
    ARSize   <= Size    ;
    ARBurst  <= Burst   ;
    ARLock   <= Lock    ;
    ARCache  <= Cache   ;
    ARQOS    <= QOS     ;
    ARRegion <= Region  ;
    ARUser   <= User    ;


    AddressReadLoop : loop
      -- Find Transaction
      if ReadAddressFifo.Empty then
         WaitForToggle(ReadAddressRequestCount) ;
      end if ;
      (Address, Prot, Len, ID, Size, Burst, Lock, Cache, QOS, Region, User) := ReadAddressFifo.Pop ;

      -- Do Transaction
      ARAddr   <= Address   after tpd_Clk_ARAddr   ;
      ARProt   <= Prot      after tpd_clk_ARProt   ;
      -- AXI4 Full
      ARLen    <= Len       after tpd_clk_ARLen    ;
      ARID     <= ID        after tpd_clk_ARID     ;
      ARSize   <= Size      after tpd_clk_ARSize   ;
      ARBurst  <= Burst     after tpd_clk_ARBurst  ;
      ARLock   <= Lock      after tpd_clk_ARLock   ;
      ARCache  <= Cache     after tpd_clk_ARCache  ;
      ARQOS    <= QOS       after tpd_clk_ARQOS    ;
      ARRegion <= Region    after tpd_clk_ARRegion ;
      ARUser   <= User      after tpd_clk_ARUser   ;

      Log(ModelID,
        "Read Address." &
        "  ARAddr: "  & to_hstring(Address) &
        "  ARProt: "  & to_string( Prot) &
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
      ARAddr  <= Address + 1  after tpd_Clk_ARAddr   ;
      ARProt  <= Prot    + 1  after tpd_clk_ARProt   ;
      -- AXI4 Full
      ARLen    <= Len    + 1  after tpd_clk_ARLen    ;
      ARID     <= ID     + 1  after tpd_clk_ARID     ;
      ARSize   <= Size   + 1  after tpd_clk_ARSize   ;
      ARBurst  <= Burst  + 1  after tpd_clk_ARBurst  ;
      ARLock   <= Lock        after tpd_clk_ARLock   ;
      ARCache  <= Cache  + 1  after tpd_clk_ARCache  ;
      ARQOS    <= QOS    + 1  after tpd_clk_ARQOS    ;
      ARRegion <= Region + 1  after tpd_clk_ARRegion ;
      ARUser   <= User   + 1  after tpd_clk_ARUser   ;

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

      -- (Len, ID, USER) := ReadDataTransaction.pop ;
      
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

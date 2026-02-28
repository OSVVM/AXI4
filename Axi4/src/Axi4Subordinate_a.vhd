--
--  File Name:         Axi4Subordinate_a.vhd
--  Design Unit Name:  Transactor of Axi4Subordinate
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Simple AXI Full Subordinate Transactor Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    10/2025   2025.10    Split entity from architecture to simplify support of 2019 interfaces
--    07/2024   2024.07    Shortened AlertLog and data structure names for better printing
--    03/2024   2024.03    Updated SafeResize to use ModelID
--    01/2024   2024.01    Updated Params to use singleton data structure
--    09/2023   2023.09    Unimplemented transactions handled with ClassifyUnimplementedOperation
--    05/2023   2023.05    Adding Randomization of Valid and Ready timing   
--    10/2022   2022.10    Changed enum value PRIVATE to PRIVATE_NAME due to VHDL-2019 keyword conflict.   
--    05/2022   2022.05    Updated FIFOs so they are Search => PRIVATE
--    03/2022   2022.03    Updated calls to NewID for AlertLogID and FIFOs
--    02/2022   2022.02    Replaced to_hstring with to_hxstring
--    01/2022   2022.01    Moved MODEL_INSTANCE_NAME and MODEL_NAME to entity declarative region
--    09/2021   2021.09    Minor fix to push WriteDataFifo 
--    07/2021   2021.07    All FIFOs and Scoreboards now use the New Scoreboard/FIFO capability 
--    06/2021   2021.06    Updates for GHDL.   
--    02/2021   2021.02    Added MultiDriver Detect.  Updated Generics.   
--    12/2020   2020.12    Updated.  
--    09/2017   2017       Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2017 - 2024 by SynthWorks Design Inc.
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

architecture Transactor of Axi4Subordinate is
  -- Derive ModelInstance label from path_name
  -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
  constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4Subordinate'PATH_NAME))) ;

  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ;
  signal ArrDelayCovID         : DelayCoverageIDArrayType(1 to READ_DATA_ID) ;
  alias  WriteAddressDelayCov  is ArrDelayCovID(WRITE_ADDRESS_ID) ;
  alias  WriteDataDelayCov     is ArrDelayCovID(WRITE_DATA_ID) ;
  alias  WriteResponseDelayCov is ArrDelayCovID(WRITE_RESPONSE_ID) ;
  alias  ReadAddressDelayCov   is ArrDelayCovID(READ_ADDRESS_ID) ;
  alias  ReadDataDelayCov      is ArrDelayCovID(READ_DATA_ID) ;
  signal UseCoverageDelays : boolean := FALSE ; 

  constant AXI_DATA_BYTE_WIDTH : integer := AXI_DATA_WIDTH / 8 ;
  constant AXI_BYTE_ADDR_WIDTH : integer := integer(ceil(log2(real(AXI_DATA_BYTE_WIDTH)))) ;

  signal Params    : ModelParametersIDType ;

  signal WriteAddressFifo           : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
  signal WriteDataFifo              : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
--  signal WriteTransactionFifo       : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
  signal WriteResponseFifo          : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
  signal ReadAddressFifo            : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
  signal ReadAddressTransactionFifo : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
  signal ReadDataFifo               : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;

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

  -- A hack of a way to set the parameters for now.
  signal ModelBResp  : Axi4RespType := to_Axi4RespType(OKAY) ;
  signal ModelRResp  : Axi4RespType := to_Axi4RespType(OKAY) ;
  
  signal ModelBUSER  : std_logic_vector(AxiBus.WriteResponse.User'length - 1 downto 0) := (others => '0') ;
  signal ModelBID    : std_logic_vector(AxiBus.WriteResponse.ID'length - 1 downto 0) := (others => '0') ;

  signal ModelRUSER  : std_logic_vector(AxiBus.ReadData.User'length - 1 downto 0) := (others => '0') ;
  signal ModelRID    : std_logic_vector(AxiBus.ReadData.ID'length - 1 downto 0) := (others => '0') ;

  -- Placeholders
  signal TransactionDone, WriteTransactionDone, ReadTransactionDone : boolean := FALSE ; 
  signal BurstFifoMode      : AddressBusFifoBurstModeType := ADDRESS_BUS_BURST_WORD_MODE ;

begin

  ------------------------------------------------------------
  -- Turn off drivers not being driven by this model
  ------------------------------------------------------------
  --%%UncommentFor2008 InitAxi4Rec (AxiBusRec => AxiBus) ;


  ------------------------------------------------------------
  --  Initialize AlertLogIDs
  ------------------------------------------------------------
  Initalize : process
    variable ID      : AlertLogIDType ;
    variable vParams : ModelParametersIDType ; 
  begin
    -- Alerts
    ID                      := NewID(MODEL_INSTANCE_NAME) ;
    ModelID                 <= ID ;
--    TransRec.AlertLogID     <= NewID("Transaction", ID ) ;
    ProtocolID              <= NewID("Protocol Error", ID ) ;
    DataCheckID             <= NewID("Data Check",     ID ) ;
    BusFailedID             <= NewID("No response",    ID ) ;

    vParams                 := NewID("AxiS Parameters", to_integer(OPTIONS_MARKER), ID) ; 
    InitAxiOptions(vParams) ;
    Params                  <= vParams ; 

    -- FIFOs get an AlertLogID with NewID, however, it does not print in ReportAlerts (due to DoNotReport)
    --   FIFOS only generate usage type errors 
    WriteAddressFifo           <= NewID("WriteAddrFifo",          ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
    WriteDataFifo              <= NewID("WriteDataFifo",          ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
--    WriteTransactionFifo       <= NewID("WriteTransactionFifo",   ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
    WriteResponseFifo          <= NewID("WriteResponseFifo",      ID, ReportMode => DISABLED, Search => PRIVATE_NAME);

    ReadAddressFifo            <= NewID("ReadAddrFifo",           ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
    ReadAddressTransactionFifo <= NewID("ReadByteAddrFifo",       ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
    ReadDataFifo               <= NewID("ReadDataFifo",           ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
    wait ;
  end process Initalize ;


  ------------------------------------------------------------
  --  Transaction Dispatcher
  --    Handles transactions between TestCtrl and Model
  ------------------------------------------------------------
  TransactionDispatcher : process

    -- Formulate local copies of values for AXI Interface
    variable LocalAW : AxiBus.WriteAddress'subtype ;
    variable LocalWD : AxiBus.WriteData'subtype ;
--    variable LocalWR : AxiBus.WriteResponse'subtype ;
    variable LocalAR : AxiBus.ReadAddress'subtype ;
    variable LocalRD : AxiBus.ReadData'subtype ;

    variable WriteAvailable      : boolean := FALSE ;

    variable WriteByteCount : integer ;
    variable WriteByteAddr  : integer ;

    variable ReadByteAddr  : integer ;
    variable ReadAvailable : boolean := FALSE ;

    variable Axi4Option    : Axi4OptionsType ; 
    variable Axi4OptionVal : integer ; 
    
    variable FilterUndrivenWriteData       : boolean := TRUE ;
    variable UndrivenWriteDataValue        : std_logic := '0' ;

    variable WriteAddressTransactionCount  : integer := 0 ; 
    variable WriteDataTransactionCount     : integer := 0 ; 
    variable WriteResponseTransactionCount : integer := 0 ; 
  begin
    wait for 0 ns ; -- Allow ModelID to become valid
    TransRec.Params         <= Params ; 
--
-- AxiLite does not support bursts
--    TransRec.WriteBurstFifo <= NewID("WriteBurstFifo",         ModelID, Search => PRIVATE_NAME) ;
--    TransRec.ReadBurstFifo  <= NewID("ReadBurstFifo",          ModelID, Search => PRIVATE_NAME) ;
    WriteAddressDelayCov    <= NewID("WriteAddrDelayCov",   ModelID, ReportMode => DISABLED) ; 
    WriteDataDelayCov       <= NewID("WriteDataDelayCov",   ModelID, ReportMode => DISABLED) ; 
    WriteResponseDelayCov   <= NewID("WriteRespDelayCov",   ModelID, ReportMode => DISABLED) ; 
    ReadAddressDelayCov     <= NewID("ReadAddrDelayCov",    ModelID, ReportMode => DISABLED) ; 
    ReadDataDelayCov        <= NewID("ReadDataDelayCov",    ModelID, ReportMode => DISABLED) ; 

    DispatchLoop : loop
      WaitForTransaction(
         Clk      => Clk,
         Rdy      => TransRec.Rdy,
         Ack      => TransRec.Ack
      ) ;

      case TransRec.Operation is
        when WRITE_OP | WRITE_ADDRESS | WRITE_DATA |
             ASYNC_WRITE | ASYNC_WRITE_ADDRESS | ASYNC_WRITE_DATA =>

          if (IsTryWriteAddress(TransRec.Operation) and IsEmpty(WriteAddressFifo)) or
             (IsTryWriteData(TransRec.Operation)    and IsEmpty(WriteDataFifo)) then
            WriteAvailable         := FALSE ;
            TransRec.DataFromModel <= (TransRec.DataFromModel'range => '0') ; 
          else
            WriteAvailable         := TRUE ;
          end if ;
          TransRec.BoolFromModel <= WriteAvailable ;

          if WriteAvailable and IsWriteAddress(TransRec.Operation) then
            -- Find Write Address transaction
            if IsEmpty(WriteAddressFifo) then
              WaitForToggle(WriteAddressReceiveCount) ;
            end if ;

            (LocalAW.Addr, LocalAW.Prot) := pop(WriteAddressFifo) ;
            TransRec.Address       <= SafeResize(ModelID, LocalAW.Addr, TransRec.Address'length) ;
            WriteAddressTransactionCount := Increment(WriteAddressTransactionCount) ; 

  --!! Address checks intentionally removed - only want an error if the value changes.  
  --          AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "SlaveGetWrite, Address length does not match", FAILURE) ;
  --!! Add checking for AWProt?
  --     Suppress signaling of error during timeout?  return "----" on timeout
  --          AlertIfNotEqual(ModelID, LocalAW.Prot, ModelWProt, "SlaveGetWrite, WProt", ERROR) ;
          end if ;

          if WriteAvailable and IsWriteData(TransRec.Operation) then
            -- Find Write Data transaction
            if IsEmpty(WriteDataFifo) then
              WaitForToggle(WriteDataReceiveCount) ;
            end if ;

            (LocalWD.Data, LocalWD.Strb, LocalWD.Last, LocalWD.User, LocalWD.ID) := pop(WriteDataFifo) ;

            if IsWriteAddress(TransRec.Operation) then
              WriteByteAddr := CalculateByteAddress(LocalAW.Addr, AXI_BYTE_ADDR_WIDTH) ;
            else 
              -- Calculate byte address based on strobes
              WriteByteAddr := 0 ; 
              for i in LocalWD.Strb'reverse_range loop 
                exit when LocalWD.Strb(i) = '1' ; 
                WriteByteAddr := WriteByteAddr + 1 ; 
              end loop ; 
            end if ; 
            
            FilterUndrivenWriteData := Get(Params, to_integer(WRITE_DATA_FILTER_UNDRIVEN)) ;
            UndrivenWriteDataValue  := GetAxi4Parameter(Params, WRITE_DATA_UNDRIVEN_VALUE) ;
--            GetAxi4Parameter(Params, WRITE_DATA_FILTER_UNDRIVEN, FilterUndrivenWriteData) ;
--            GetAxi4Parameter(Params, WRITE_DATA_UNDRIVEN_VALUE,  UndrivenWriteDataValue) ;
            if FilterUndrivenWriteData then
              FilterUndrivenData(LocalWD.Data, LocalWD.Strb, UndrivenWriteDataValue) ;
            end if ;

            
            LocalWD.Data := AlignDataBusToBytes(LocalWD.Data, TransRec.DataWidth, WriteByteAddr) ;
            TransRec.DataFromModel  <= SafeResize(ModelID, LocalWD.Data, TransRec.DataFromModel'length) ;
            
            if LocalWD.Last = '1' then
              WriteDataTransactionCount := Increment(WriteDataTransactionCount) ; 
            end if ;


            -- Check Data Size
            CheckDataIsBytes(ModelID, TransRec.DataWidth, "GetWrite", WriteDataTransactionCount) ;
            CheckDataWidth(ModelID, TransRec.DataWidth, WriteByteAddr, AXI_DATA_WIDTH, "GetWrite", WriteDataTransactionCount) ; 

  --!! ??? Add Checking for WSTRB?
  -- Works for SlaveGetWriteData - but only if access is correct sized, but not SlaveGetWrite
  --          -- Check WStrb
  --          ByteCount := TransRec.DataWidth / 8 ;
  --          ExpectedWStrb := CalculateWriteStrobe(WriteByteAddr, ByteCount, AXI_DATA_BYTE_WIDTH) ;
  --          AlertIfNotEqual(ModelID, LocalWD.Strb, ExpectedWStrb, "SlaveGetWrite, WStrb", ERROR) ;

          end if ;

          if WriteAddressTransactionCount /= WriteResponseTransactionCount and 
                WriteDataTransactionCount /= WriteResponseTransactionCount then
            push(WriteResponseFifo, ModelBResp) ;
            increment(WriteReceiveCount) ;
            WriteResponseTransactionCount := Increment(WriteResponseTransactionCount) ; 
          end if ;

  --    -- Log this operation
  --    Log(ModelID,
  --      "Write Operation." &
  --      "  AWAddr: "    & to_hxstring(LocalAW.Addr) &
  --      "  AWProt: "    & to_string(LocalAW.Prot) &
  --      "  WData: "     & to_hxstring(LocalWD.Data) &
  --      "  WStrb: "     & to_string(LocalWD.Strb) &
  --      "  Operation# " & to_string(WriteReceiveCount),
  --      DEBUG
  --    ) ;

          wait for 0 ns ;


        when READ_OP | READ_ADDRESS | READ_DATA |
             ASYNC_READ | ASYNC_READ_ADDRESS | ASYNC_READ_DATA =>

          if (IsTryReadAddress(TransRec.Operation) and IsEmpty(ReadAddressFifo)) then
            ReadAvailable          := FALSE ;
          else
            ReadAvailable          := TRUE ;
          end if ;
          TransRec.BoolFromModel <= ReadAvailable ;

          if ReadAvailable and IsReadAddress(TransRec.Operation) then
            -- Expect Read Address Cycle
            if IsEmpty(ReadAddressFifo) then
              WaitForToggle(ReadAddressReceiveCount) ;
            end if ;
            (LocalAR.Addr, LocalAR.Prot)  := pop(ReadAddressFifo) ;
            TransRec.Address         <= SafeResize(ModelID, LocalAR.Addr, TransRec.Address'length) ;
  --         AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Slave Read, Address length does not match", FAILURE) ;
  --!TODO Add Check here for actual PROT vs expected (ModelRProt)
  --        TransRec.Prot           <= to_integer(LocalAR.Prot) ;
          end if ;

          if ReadAvailable and IsReadData(TransRec.Operation) then
            LocalAR.Addr := pop(ReadAddressTransactionFifo) ;
            ReadByteAddr  :=  CalculateByteAddress(LocalAR.Addr, AXI_BYTE_ADDR_WIDTH);

            -- Data Sizing Checks
            CheckDataIsBytes(ModelID, TransRec.DataWidth, "Read Data", ReadDataRequestCount) ;
            CheckDataWidth  (ModelID, TransRec.DataWidth, ReadByteAddr, AXI_DATA_WIDTH, "Read Data", ReadDataRequestCount) ; 
   
            -- Get Read Data Response Values
            LocalRD.Data  := AlignBytesToDataBus(SafeResize(ModelID, TransRec.DataToModel, LocalRD.Data'length), TransRec.DataWidth, ReadByteAddr) ;
            push(ReadDataFifo, LocalRD.Data & ModelRResp) ;
            Increment(ReadDataRequestCount) ;

  -- Currently all ReadData Operations are Async
  -- Add blocking until completion here
          end if ;

          wait for 0 ns ;
         
        when SET_MODEL_OPTIONS =>
          -- Set Model Options
          Axi4Option := Axi4OptionsType'val(TransRec.Options) ;
          if IsAxiParameter(Axi4Option) then
            Set(Params, TransRec.Options, TransRec.IntToModel) ;
--            SetAxi4Parameter(Params, Axi4Option, TransRec.IntToModel) ;
          else
            case Axi4Option is
              -- RESP Settings
              when BRESP =>                ModelBResp <= to_slv(TransRec.IntToModel, ModelBResp'length) ;
              when RRESP =>                ModelRResp <= to_slv(TransRec.IntToModel, ModelRResp'length) ;
              -- ID Settings
              when BID =>                  ModelBID <= to_slv(TransRec.IntToModel, ModelBID'length) ;
              when RID =>                  ModelRID <= to_slv(TransRec.IntToModel, ModelRID'length) ;
              -- User Settings
              when BUSER =>                ModelBUser <= to_slv(TransRec.IntToModel, ModelBUser'length) ;
              when RUSER =>                ModelRUser <= to_slv(TransRec.IntToModel, ModelRUser'length) ;
              --
              -- The End -- Done
              when others =>              
                Alert(ModelID, "SetOptions, Unimplemented Option: " & to_string(Axi4OptionsType'val(TransRec.Options)), FAILURE) ;
            end case ;
          end if ;

        when GET_MODEL_OPTIONS =>
          Axi4Option := Axi4OptionsType'val(TransRec.Options) ;
          if IsAxiParameter(Axi4Option) then
            TransRec.IntFromModel <= Get(Params, TransRec.Options) ;
--            GetAxi4Parameter(Params, Axi4Option, Axi4OptionVal) ;
--            TransRec.IntFromModel <= Axi4OptionVal ;
          else
            case Axi4Option is
              -- RESP Settings
              when BRESP =>                TransRec.IntFromModel <= to_integer(ModelBResp) ;
              when RRESP =>                TransRec.IntFromModel <= to_integer(ModelRResp) ;
              -- ID Settings
              when BID =>                  TransRec.IntFromModel <= to_integer(ModelBID) ;
              when RID =>                  TransRec.IntFromModel <= to_integer(ModelRID) ;
              -- User Settings
              when BUSER =>                TransRec.IntFromModel <= to_integer(ModelBUser) ;
              when RUSER =>                TransRec.IntFromModel <= to_integer(ModelRUser) ;
              --
              -- The End -- Done
              when others =>              
                Alert(ModelID, "GetOptions, Unimplemented Option: " & to_string(Axi4OptionsType'val(TransRec.Options)), FAILURE) ;
            end case ;
          end if ;

        when WAIT_FOR_TRANSACTION =>
          -- wait for write or read transaction to be available
          loop
            exit when not IsEmpty(WriteAddressFifo) and not IsEmpty(WriteDataFifo) ; -- Write Available
            exit when not IsEmpty(ReadAddressFifo) ; -- Read Available
            wait on WriteAddressReceiveCount, WriteDataReceiveCount, ReadAddressReceiveCount ;
          end loop ;

        when WAIT_FOR_WRITE_TRANSACTION =>
          -- wait for write transaction to be available
          if IsEmpty(WriteAddressFifo) then
            WaitForToggle(WriteAddressReceiveCount) ;
          end if ;
          if IsEmpty(WriteDataFifo) then
            WaitForToggle(WriteDataReceiveCount) ;
          end if ;

        when WAIT_FOR_READ_TRANSACTION =>
          -- wait for read transaction to be available
          if IsEmpty(ReadAddressFifo) then
            WaitForToggle(ReadAddressReceiveCount) ;
          end if ;

  --  Alternate interpretation of wait for transaction
  --      when WAIT_FOR_WRITE_TRANSACTION =>
  --        -- Wait for next write to memory to complete
  --        if (WriteAddressReceiveCount /= WriteReceiveCount) or (WriteReceiveCount /= WriteResponseDoneCount) then
  --          wait until (WriteAddressReceiveCount = WriteReceiveCount) and (WriteReceiveCount = WriteResponseDoneCount) ;
  --        end if ;
  --
  --      when WAIT_FOR_READ_TRANSACTION =>
  --        -- Wait for a requested Read Data Transaction to complete
  --        if ReadDataRequestCount /= ReadDataDoneCount then
  --          wait until ReadDataRequestCount = ReadDataDoneCount ;
  --        end if ;
  --

        when others =>
          -- Do Standard Directive Transactions or Error Handling
          DoDirectiveTransactions (
            TransRec              => TransRec             ,
            Clk                   => Clk                  ,
            ModelID               => ModelID              ,
            UseCoverageDelays     => UseCoverageDelays    ,
            DelayCovID            => ArrDelayCovID        ,
            BurstFifoMode         => BurstFifoMode        ,      -- Not used in Memory
            TransactionDone       => TransactionDone      ,      -- implemented above
            WriteTransactionDone  => WriteTransactionDone ,      -- implemented above
            ReadTransactionDone   => ReadTransactionDone  ,      -- implemented above
            WriteTransactionCount => WriteAddressReceiveCount,
            ReadTransactionCount  => ReadAddressReceiveCount
          ) ;

      end case ;

      -- Wait for 1 delta cycle, required if a wait is not in all case branches above
      wait for 0 ns ;
    end loop DispatchLoop ; 

  end process TransactionDispatcher ;

  ------------------------------------------------------------
  --  WriteAddressHandler
  --    Execute Write Address Transactions
  ------------------------------------------------------------
  WriteAddressHandler : process
    alias    AW : AxiBus.WriteAddress'subtype is AxiBus.WriteAddress ;
    variable ReadyBeforeValid    : boolean := TRUE ;
    variable intReadyBeforeValid : integer ;
    variable ReadyDelayCycles    : integer := 0 ;
  begin
    AW.Ready <= '0' ;
    wait for 0 ns ; -- Allow Cov models to initialize 
    wait for 0 ns ; -- Allow Cov models to initialize 
    -- Delays for Ready
    AddBins (WriteAddressDelayCov.BurstLengthCov,  GenBin(2,10,1)) ;
    AddCross(WriteAddressDelayCov.BurstDelayCov,   GenBin(0,1,1), GenBin(2,5,1)) ;
    AddCross(WriteAddressDelayCov.BeatDelayCov,    GenBin(0),     GenBin(0)) ;  -- No beat delay
    WaitForClock(Clk, 2) ;  -- Initialize

    WriteAddressOperation : loop
      if UseCoverageDelays then 
        -- BurstCoverage Delays
        (intReadyBeforeValid, ReadyDelayCycles)  := GetRandDelay(WriteAddressDelayCov) ; 
        ReadyBeforeValid := intReadyBeforeValid = 0 ; 
      else
        -- Deprecated static settings
        ReadyBeforeValid := Get(Params, to_integer(WRITE_ADDRESS_READY_BEFORE_VALID)) ;
        ReadyDelayCycles := Get(Params, to_integer(WRITE_ADDRESS_READY_DELAY_CYCLES)) ;
--        GetAxi4Parameter(Params, WRITE_ADDRESS_READY_BEFORE_VALID, ReadyBeforeValid) ;
--        GetAxi4Parameter(Params, WRITE_ADDRESS_READY_DELAY_CYCLES, ReadyDelayCycles) ;
      end if ; 

      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => AxiBus.WriteAddress.Valid,
        Ready                   => AxiBus.WriteAddress.Ready,
        ReadyBeforeValid        => ReadyBeforeValid,
--        ReadyDelayCycles        => ReadyDelayCycles * tperiod_Clk,
        ReadyDelayCycles        => ReadyDelayCycles,
        tpd_Clk_Ready           => tpd_Clk_AWReady,
        AlertLogID              => BusFailedID -- ,
--        TimeOutMessage          => "Write Address # " & to_string(WriteAddressReceiveCount + 1)
      ) ;

      -- capture address, prot
      push(WriteAddressFifo, AW.Addr & AW.Prot) ;

      -- Log this operation
      Log(ModelID,
        "Write Address." &
        "  AWAddr: "  & to_hxstring(AW.Addr) &
        "  AWProt: "  & to_string(AW.Prot) &
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
    alias    WD : AxiBus.WriteData'subtype is AxiBus.WriteData ;
    variable ReadyBeforeValid     : boolean := TRUE ;
    variable intReadyBeforeValid  : integer ;
    variable ReadyDelayCycles     : integer := 0 ;
  begin
    WD.Ready <= '0' ;
    wait for 0 ns ; -- Allow Cov models to initialize 
    wait for 0 ns ; -- Allow Cov models to initialize 
    -- Delays for Ready
    AddBins (WriteDataDelayCov.BurstLengthCov,  GenBin(2,10,1)) ;
    AddCross(WriteDataDelayCov.BurstDelayCov,   GenBin(0,1,1), GenBin(2,5,1)) ;
    AddCross(WriteDataDelayCov.BeatDelayCov,    GenBin(0),     GenBin(0)) ;  -- No beat delay
    WaitForClock(Clk, 2) ;  -- Initialize

    WriteDataOperation : loop
      if UseCoverageDelays then 
        -- BurstCoverage Delays
        (intReadyBeforeValid, ReadyDelayCycles)  := GetRandDelay(WriteDataDelayCov) ; 
        ReadyBeforeValid := intReadyBeforeValid = 0 ; 
      else
        -- Deprecated static delays
        ReadyBeforeValid := Get(Params, to_integer(WRITE_DATA_READY_BEFORE_VALID)) ;
        ReadyDelayCycles := Get(Params, to_integer(WRITE_DATA_READY_DELAY_CYCLES)) ;
--        GetAxi4Parameter(Params, WRITE_DATA_READY_BEFORE_VALID, ReadyBeforeValid) ;
--        GetAxi4Parameter(Params, WRITE_DATA_READY_DELAY_CYCLES, ReadyDelayCycles) ;
      end if ; 

      ---------------------
      DoAxiReadyHandshake(
      ---------------------
        Clk                     => Clk,
        Valid                   => AxiBus.WriteData.Valid,
        Ready                   => AxiBus.WriteData.Ready,
        ReadyBeforeValid        => ReadyBeforeValid,
--        ReadyDelayCycles        => ReadyDelayCycles * tperiod_Clk,
        ReadyDelayCycles        => ReadyDelayCycles,
        tpd_Clk_Ready           => tpd_Clk_WReady,  
        AlertLogID              => BusFailedID  -- ,
--        TimeOutMessage          => "Write Data # " & to_string(WriteDataReceiveCount + 1)
      ) ;

      -- capture Data, wstrb
      if WD.Valid = '1' then
        push(WriteDataFifo, WD.Data & WD.Strb & WD.Last & WD.User & WD.ID) ;
      else
        -- On failure to receive Valid, assert LAST
        push(WriteDataFifo, WD.Data & WD.Strb & '1' & WD.User & WD.ID) ;
      end if ;

      -- Log this operation
      Log(ModelID,
        "Write Data." &
        "  WData: "  & to_hxstring(WD.Data) &
        "  WStrb: "  & to_string(WD.Strb) &
        "  Operation# " & to_string(WriteDataReceiveCount + 1),
        INFO
      ) ;

      -- Signal completion
      increment(WriteDataReceiveCount) ;
      wait for 0 ns ;
    end loop WriteDataOperation ;
  end process WriteDataHandler ;


  ------------------------------------------------------------
  -- WriteResponseHandler
  --   Receive and Check Write Responses
  ------------------------------------------------------------
  WriteResponseHandler : process
    alias    WR    : AxiBus.WriteResponse'subtype is AxiBus.WriteResponse ;
    variable Local : AxiBus.WriteResponse'subtype ;
    variable WriteResponseReadyTimeOut: integer := 25 ;
    variable DelayCycles : integer ; 
  begin
    -- initialize
    WR.Valid <= '0' ;
    WR.Resp  <= (WR.Resp'range => '0') ;
    WR.ID    <= (WR.ID'range => '0') ;
    WR.User  <= (WR.User'range => '0') ;
    wait for 0 ns ; -- Allow WriteResponseFifo to initialize
    wait for 0 ns ; -- Allow Cov models to initialize 
    AddBins (WriteResponseDelayCov.BurstLengthCov,  GenBin(2,10,1)) ;
    AddBins (WriteResponseDelayCov.BurstDelayCov,   GenBin(2,5,1)) ;
    AddBins (WriteResponseDelayCov.BeatDelayCov,    GenBin(0)) ;

    WriteResponseLoop : loop
      -- Find Transaction
--! Done always less than Receive, change to just "="
--! ">" will break due to roll over if there are more than 2**30 transfers
      if WriteResponseDoneCount >= WriteReceiveCount then
        WaitForToggle(WriteReceiveCount) ;
      end if ;
      if not IsEmpty(WriteResponseFifo) then
        Local.Resp := pop(WriteResponseFifo) ;
      else
        Local.Resp := AXI4_RESP_OKAY ;
      end if ;
      
      if UseCoverageDelays then 
        -- BurstCoverage Delays
        DelayCycles := GetRandDelay(WriteResponseDelayCov) ; 
        WaitForClock(Clk, DelayCycles) ;
      else
        -- Deprecated delays
        WaitForClock(Clk, integer'(Get(Params, to_integer(WRITE_RESPONSE_VALID_DELAY_CYCLES)))) ; 
--        WaitForClock(Clk, integer'(Params.Get(Axi4OptionsType'POS(WRITE_RESPONSE_VALID_DELAY_CYCLES)))) ; 
      end if ; 

      -- Do Transaction
      WR.Resp  <= Local.Resp  after tpd_Clk_BResp ;
      WR.ID    <= ModelBID    after tpd_Clk_BID ; 
      WR.User  <= ModelBUser  after tpd_Clk_BUser ; 

      Log(ModelID,
        "Write Response." &
        "  BResp: "  & to_hxstring(Local.Resp) &
        "  Operation# " & to_string(WriteResponseDoneCount + 1),
        INFO
      ) ;
      
      WriteResponseReadyTimeOut := Get(Params, to_integer(WRITE_RESPONSE_READY_TIME_OUT)) ;
--      GetAxi4Parameter(Params, WRITE_RESPONSE_READY_TIME_OUT, WriteResponseReadyTimeOut) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  AxiBus.WriteResponse.Valid,
        Ready          =>  AxiBus.WriteResponse.Ready,
        tpd_Clk_Valid  =>  tpd_Clk_BValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Response # " & to_string(WriteResponseDoneCount + 1),
        TimeOutPeriod  =>  WriteResponseReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      WR.Resp  <= not Local.Resp after tpd_Clk_BResp ;
      WR.ID    <= not ModelBID    after tpd_Clk_BID ; 
      WR.User  <= not ModelBUser  after tpd_Clk_BUser ; 

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
    alias    AR : AxiBus.ReadAddress'subtype is AxiBus.ReadAddress ;
    variable ReadyBeforeValid    : boolean := TRUE ;
    variable intReadyBeforeValid : integer ;
    variable ReadyDelayCycles    : integer := 0 ;
  begin
    -- Initialize
    AR.Ready <= '0' ;
    wait for 0 ns ; -- Allow Cov models to initialize 
    wait for 0 ns ; -- Allow Cov models to initialize 
    -- Delays for Ready
    AddBins (ReadAddressDelayCov.BurstLengthCov,  GenBin(2,10,1)) ;
    AddCross(ReadAddressDelayCov.BurstDelayCov,   GenBin(0,1,1), GenBin(2,5,1)) ;
    AddCross(ReadAddressDelayCov.BeatDelayCov,    GenBin(0),     GenBin(0)) ;  -- No beat delay
    WaitForClock(Clk, 2) ;  -- Initialize

    ReadAddressOperation : loop
      if UseCoverageDelays then 
        -- BurstCoverage Delays
        (intReadyBeforeValid, ReadyDelayCycles)  := GetRandDelay(ReadAddressDelayCov) ; 
        ReadyBeforeValid := intReadyBeforeValid = 0 ; 
      else
        -- Deprecated static settings
        ReadyBeforeValid := Get(Params, to_integer(READ_ADDRESS_READY_BEFORE_VALID)) ;
        ReadyDelayCycles := Get(Params, to_integer(READ_ADDRESS_READY_DELAY_CYCLES)) ;
--        GetAxi4Parameter(Params, READ_ADDRESS_READY_BEFORE_VALID, ReadyBeforeValid) ;
--        GetAxi4Parameter(Params, READ_ADDRESS_READY_DELAY_CYCLES, ReadyDelayCycles) ;
      end if ; 
      
      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => AxiBus.ReadAddress.Valid,
        Ready                   => AxiBus.ReadAddress.Ready,
        ReadyBeforeValid        => ReadyBeforeValid,
--        ReadyDelayCycles        => ReadyDelayCycles * tperiod_Clk,
        ReadyDelayCycles        => ReadyDelayCycles,
        tpd_Clk_Ready           => tpd_Clk_ARReady,
        AlertLogID              => BusFailedID  --,
--        TimeOutMessage          => "Read Address # " & to_string(ReadAddressReceiveCount + 1)
      ) ;

      -- capture address, prot
      push(ReadAddressFifo, AR.Addr & AR.Prot) ;
      push(ReadAddressTransactionFifo, AR.Addr) ;
      increment(ReadAddressReceiveCount) ;
      wait for 0 ns ;

      Log(ModelID,
        "Read Address." &
        "  ARAddr: "  & to_hxstring(AR.Addr) &
        "  ARProt: "  & to_string(AR.Prot) &
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
    alias    RD    : AxiBus.ReadData'subtype is AxiBus.ReadData ;
    variable Local : AxiBus.ReadData'subtype ;
    variable ReadDataReadyTimeOut: integer := 25 ;
    variable DelayCycles : integer ; 
  begin
    -- initialize
    RD.Valid <= '0' ;
    RD.Data  <= (RD.Data'range => '0') ;
    RD.Resp  <= (RD.Resp'range => '0') ;
    RD.ID    <= (RD.ID'range => '0') ;
    RD.User  <= (RD.User'range => '0') ; 
    RD.Last  <= '0' ; 
    wait for 0 ns ; -- Allow Cov models to initialize
    wait for 0 ns ; -- Allow Cov models to initialize 
    AddBins (ReadDataDelayCov.BurstLengthCov,  GenBin(2,10,1)) ;
    AddBins (ReadDataDelayCov.BurstDelayCov,   GenBin(2,5,1)) ;
    AddBins (ReadDataDelayCov.BeatDelayCov,    GenBin(0)) ;

    ReadDataLoop : loop
      -- Start a Read Data Response Transaction after receiving a read address
      if ReadAddressReceiveCount <= ReadDataDoneCount then
        WaitForToggle(ReadAddressReceiveCount) ;
      end if ;

      -- Read Data Valid Delays
      if UseCoverageDelays then 
        -- BurstCoverage Delays
        DelayCycles := GetRandDelay(ReadDataDelayCov) ; 
        WaitForClock(Clk, DelayCycles) ;
      else
        -- Deprecated delays
        WaitForClock(Clk, integer'(Get(Params, to_integer(READ_DATA_VALID_DELAY_CYCLES)))) ; 
--        WaitForClock(Clk, integer'(Params.Get(Axi4OptionsType'POS(READ_DATA_VALID_DELAY_CYCLES)))) ; 
      end if ;

      if IsEmpty(ReadDataFifo) then
        WaitForToggle(ReadDataRequestCount) ;
      end if ;

      (Local.Data, Local.Resp) := pop(ReadDataFifo) ;

--      -- Find Response if available
--      if not IsEmpty(ReadDataFifo) then
--        (Local.Data, Local.Resp) := pop(ReadDataFifo) ;
--      else
--        Local.Data := to_slv(ReadAddressReceiveCount, RData'length) ;
--        Local.Resp := AXI4_RESP_OKAY ;
--      end if ;

      -- Transaction Values
      RD.Data  <= Local.Data  after tpd_Clk_RDATA ;
      RD.Resp  <= Local.Resp  after tpd_Clk_RResp ;
      RD.ID    <= ModelRID    after tpd_Clk_RID ; 
      RD.User  <= ModelRUser  after tpd_Clk_RUser ; 
      RD.Last  <= '1'         after tpd_Clk_RLast ;

      Log(ModelID,
        "Read Data." &
        "  RData: "  & to_hxstring(Local.Data) &
        "  RResp: "  & to_hxstring(Local.Resp) &
        "  Operation# " & to_string(ReadDataDoneCount + 1),
        INFO
      ) ;

      ReadDataReadyTimeOut := Get(Params, to_integer(READ_DATA_READY_TIME_OUT)) ; 
--      GetAxi4Parameter(Params, READ_DATA_READY_TIME_OUT, ReadDataReadyTimeOut) ;
      
      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  AxiBus.ReadData.Valid,
        Ready          =>  AxiBus.ReadData.Ready,
        tpd_Clk_Valid  =>  tpd_Clk_RValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Read Data # " & to_string(ReadDataDoneCount + 1),
        TimeOutPeriod  =>  ReadDataReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      RD.Valid <= '0' after tpd_Clk_RValid ;
      RD.Data  <= not Local.Data after tpd_clk_RData ;
      RD.Resp  <= not Local.Resp after tpd_Clk_RResp ;
      RD.ID    <= not ModelRID   after tpd_Clk_RID ; 
      RD.User  <= not ModelRUser after tpd_Clk_RUser ; 
      RD.Last  <= '0'            after tpd_Clk_RLast ;

      -- Signal completion
      Increment(ReadDataDoneCount) ;
      wait for 0 ns ;
    end loop ReadDataLoop ;
  end process ReadDataHandler ;
end architecture Transactor ;

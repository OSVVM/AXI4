--
--  File Name:         Axi4LiteSubordinate.vhd
--  Design Unit Name:  Axi4LiteSubordinate
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Simple AXI Lite Subordinate Transactor Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    07/2024   2024.07    Shortened AlertLog and data structure names for better printing
--    03/2024   2024.03    Updated SafeResize to use ModelID
--    01/2024   2024.01    Updated Params to use singleton data structure
--                         Unimplemented transactions handled with ClassifyUnimplementedOperation
--                         Added Randomization of Valid and Ready timing   
--    10/2022   2022.10    Changed enum value PRIVATE to PRIVATE_NAME due to VHDL-2019 keyword conflict.   
--    05/2022   2022.05    Updated FIFOs so they are Search => PRIVATE
--    03/2022   2022.03    Rederived from 2022.02 Axi4Subordinate.vhd
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

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;

library OSVVM_Common ;
  context OSVVM_Common.OsvvmCommonContext ;

  use work.Axi4OptionsPkg.all ;
  use work.Axi4InterfaceCommonPkg.all ;
  use work.Axi4LiteInterfacePkg.all ;
  use work.Axi4ModelPkg.all ;
  use work.Axi4CommonPkg.all ;

entity Axi4LiteSubordinate is
generic (
  MODEL_ID_NAME   : string := "" ;
  tperiod_Clk     : time   := 10 ns ;

  DEFAULT_DELAY   : time   := 1 ns ; 

  tpd_Clk_AWReady : time   := DEFAULT_DELAY ;

  tpd_Clk_WReady  : time   := DEFAULT_DELAY ;

  tpd_Clk_BValid  : time   := DEFAULT_DELAY ;
  tpd_Clk_BResp   : time   := DEFAULT_DELAY ;

  tpd_Clk_ARReady : time   := DEFAULT_DELAY ;

  tpd_Clk_RValid  : time   := DEFAULT_DELAY ;
  tpd_Clk_RData   : time   := DEFAULT_DELAY ;
  tpd_Clk_RResp   : time   := DEFAULT_DELAY 
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- AXI Manager Functional Interface
  AxiBus      : inout Axi4LiteRecType ;

  -- Testbench Transaction Interface
  TransRec    : inout AddressBusRecType
) ;

  -- Derive AXI interface properties from the AxiBus
  constant AXI_ADDR_WIDTH : integer := AxiBus.WriteAddress.Addr'length ;
  constant AXI_DATA_WIDTH : integer := AxiBus.WriteData.Data'length ;

  -- Derive ModelInstance label from path_name
  -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
  constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4LiteSubordinate'PATH_NAME))) ;

end entity Axi4LiteSubordinate ;

architecture Transactor of Axi4LiteSubordinate is

  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ;
  signal WriteAddressDelayCov, WriteDataDelayCov, WriteResponseDelayCov : DelayCoverageIDType ;
  signal ReadAddressDelayCov,  ReadDataDelayCov : DelayCoverageIDType ;
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
  
begin

  ------------------------------------------------------------
  -- Turn off drivers not being driven by this model
  ------------------------------------------------------------
  InitAxi4LiteRec (AxiBusRec => AxiBus ) ;


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
    ProtocolID              <= NewID("Protocol Error", ID ) ;
    DataCheckID             <= NewID("Data Check",     ID ) ;
    BusFailedID             <= NewID("No response",    ID ) ;

    vParams                 := NewID("Axi4Subordinate Parameters", to_integer(OPTIONS_MARKER), ID) ; 
    InitAxiOptions(vParams) ;
    Params                  <= vParams ; 

    -- FIFOs get an AlertLogID with NewID, however, it does not print in ReportAlerts (due to ReportMode)
    --   FIFOS only generate usage type errors 
--    WriteTransactionFifo       <= NewID("WriteTransactionFifo",         ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
    WriteAddressFifo           <= NewID("WriteAddrFifo",      ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
    WriteDataFifo              <= NewID("WriteDataFifo",      ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
    WriteResponseFifo          <= NewID("WriteRespFifo",      ID, ReportMode => DISABLED, Search => PRIVATE_NAME);

    ReadAddressFifo            <= NewID("ReadAddrFifo",       ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
    ReadAddressTransactionFifo <= NewID("ReadByteAddrFifo",   ID, ReportMode => DISABLED, Search => PRIVATE_NAME);
    ReadDataFifo               <= NewID("ReadDataFifo",       ID, ReportMode => DISABLED, Search => PRIVATE_NAME);

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

        when WAIT_FOR_CLOCK =>
          WaitForClock(Clk, TransRec.IntToModel) ;

        when GET_ALERTLOG_ID =>
          TransRec.IntFromModel <= integer(ModelID) ;

        when SET_USE_RANDOM_DELAYS =>        
          UseCoverageDelays      <= TransRec.BoolToModel ; 

        when GET_USE_RANDOM_DELAYS =>
          TransRec.BoolFromModel <= UseCoverageDelays ;

        when SET_DELAYCOV_ID =>
          case TransRec.Options is
            when WRITE_ADDRESS_ID  =>  WriteAddressDelayCov  <= GetDelayCoverage(TransRec.IntToModel) ;
            when WRITE_DATA_ID     =>  WriteDataDelayCov     <= GetDelayCoverage(TransRec.IntToModel) ;
            when WRITE_RESPONSE_ID =>  WriteResponseDelayCov <= GetDelayCoverage(TransRec.IntToModel) ;
            when READ_ADDRESS_ID   =>  ReadAddressDelayCov   <= GetDelayCoverage(TransRec.IntToModel) ;
            when READ_DATA_ID      =>  ReadDataDelayCov      <= GetDelayCoverage(TransRec.IntToModel) ;
            when others =>  Alert(ModelID, "SetDelayCoverageID, Invalid ID requested = " & to_string(TransRec.IntToModel), FAILURE) ;  
          end case ; 
          UseCoverageDelays <= TRUE ; 

        when GET_DELAYCOV_ID =>
          case TransRec.Options is
            when WRITE_ADDRESS_ID  =>  TransRec.IntFromModel <= WriteAddressDelayCov.ID  ;
            when WRITE_DATA_ID     =>  TransRec.IntFromModel <= WriteDataDelayCov.ID     ;
            when WRITE_RESPONSE_ID =>  TransRec.IntFromModel <= WriteResponseDelayCov.ID ;
            when READ_ADDRESS_ID   =>  TransRec.IntFromModel <= ReadAddressDelayCov.ID   ;
            when READ_DATA_ID      =>  TransRec.IntFromModel <= ReadDataDelayCov.ID      ;
            when others =>  Alert(ModelID, "GetDelayCoverageID, Invalid ID requested = " & to_string(TransRec.IntToModel), FAILURE) ;  
          end case ; 
          UseCoverageDelays <= TRUE ; 

        when GET_TRANSACTION_COUNT =>
          TransRec.IntFromModel <= integer(TransRec.Rdy) ;

        when GET_WRITE_TRANSACTION_COUNT =>
          TransRec.IntFromModel <= WriteAddressReceiveCount ;

        when GET_READ_TRANSACTION_COUNT =>
          TransRec.IntFromModel <= ReadAddressReceiveCount ;

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

  --          AlertIfNotEqual(ModelID, LocalAW.Prot, ModelWProt, "SlaveGetWrite, WProt", ERROR) ;
          end if ;

          if WriteAvailable and IsWriteData(TransRec.Operation) then
            -- Find Write Data transaction
            if IsEmpty(WriteDataFifo) then
              WaitForToggle(WriteDataReceiveCount) ;
            end if ;

            (LocalWD.Data, LocalWD.Strb) := pop(WriteDataFifo) ;
            
            if IsWriteAddress(TransRec.Operation) then
              WriteByteAddr := CalculateByteAddress(LocalAW.Addr, AXI_BYTE_ADDR_WIDTH) ;
            else 
              -- Calculate byte address based on strobes
  --            WriteByteAddr := 0 when LocalWD.Strb(0) = '1' else
  --                             1 when LocalWD.Strb(1) = '1' else
  --                             2 when LocalWD.Strb(2) = '1' else
  --                             3 ;
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

            
            LocalWD.Data :=   AlignDataBusToBytes(LocalWD.Data, TransRec.DataWidth, WriteByteAddr) ;
            TransRec.DataFromModel  <= SafeResize(ModelID, LocalWD.Data, TransRec.DataFromModel'length) ;
            
            WriteDataTransactionCount := Increment(WriteDataTransactionCount) ; 


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
            LocalAR.Addr  :=  pop(ReadAddressTransactionFifo) ;
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
              --
              -- The End -- Done
              when others =>              
                Alert(ModelID, "GetOptions, Unimplemented Option: " & to_string(Axi4OptionsType'val(TransRec.Options)), FAILURE) ;
            end case ;
          end if ;

        when MULTIPLE_DRIVER_DETECT =>
          Alert(ModelID, "Multiple Drivers on Transaction Record." & 
                         "  Transaction # " & to_string(TransRec.Rdy), FAILURE) ;

        when others =>
            Alert(ModelID, "Unimplemented Transaction: " & to_string(TransRec.Operation), FAILURE) ;
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
        ReadyDelayCycles        => ReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_AWReady,
        AlertLogID              => BusFailedID -- ,
--        TimeOutMessage          => "Write Address # " & to_string(WriteAddressReceiveCount + 1)
      ) ;

      -- capture address, prot
      push(WriteAddressFifo, AW.Addr & AW.Prot) ;

      -- Log this operation
      Log(ModelID,
        "Write Address." &
        "  AWAddr: "    & to_hxstring(AW.Addr) &
        "  AWProt: "    & to_string(AW.Prot) &
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
        ReadyDelayCycles        => ReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_WReady,  
        AlertLogID              => BusFailedID  -- ,
--        TimeOutMessage          => "Write Data # " & to_string(WriteDataReceiveCount + 1)
      ) ;

      -- capture Data, wstrb
      push(WriteDataFifo, WD.Data & WD.Strb) ;

      -- Log this operation
      Log(ModelID,
        "Write Data." &
        "  WData: "     & to_hxstring(WD.Data) &
        "  WStrb: "     & to_string(WD.Strb) &
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
    variable ReadyBeforeValid   : boolean := TRUE ;
    variable intReadyBeforeValid : integer ;
    variable ReadyDelayCycles   : integer := 0 ;
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
        ReadyDelayCycles        => ReadyDelayCycles * tperiod_Clk,
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
        "  ARAddr: "    & to_hxstring(AR.Addr) &
        "  ARProt: "    & to_string(AR.Prot) &
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
    wait for 0 ns ; -- Allow ReadDataFifo to initialize
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

      -- Transaction Values
      RD.Data  <= Local.Data  after tpd_Clk_RDATA ;
      RD.Resp  <= Local.Resp  after tpd_Clk_RResp ;

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

      -- Signal completion
      Increment(ReadDataDoneCount) ;
      wait for 0 ns ;
    end loop ReadDataLoop ;
  end process ReadDataHandler ;
end architecture Transactor ;

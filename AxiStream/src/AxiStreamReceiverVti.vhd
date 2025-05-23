--
--  File Name:         AxiStreamReceiverVti.vhd
--  Design Unit Name:  AxiStreamReceiverVti
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      AXI Stream Master Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    07/2024   2024.07    Added OsvvmVcInit barrier before starting to receive.
--    03/2024   2024.03    Updated SafeResize to use ModelID
--    05/2023   2023.05    Updated methods for Randomized delays 
--    04/2023   2023.04    Update delays on TReady to be randomized
--    10/2022   2022.10    Changed enum value PRIVATE to PRIVATE_NAME due to VHDL-2019 keyword conflict.   
--    05/2022   2022.05    Updated FIFOs so they are Search => PRIVATE
--    03/2022   2022.03    Updated calls to NewID for AlertLogID and FIFOs
--    02/2022   2022.02    WaitForGet, don't send TReady until have a Get transaction
--                         Replaced to_hstring to to_hxstring
--    01/2022   2022.01    Moved MODEL_INSTANCE_NAME and MODEL_NAME to entity declarative region
--                         Added GotBurst transaction Y check for BurstLen vs Expected BurstLen in CheckBurst
--    07/2021   2021.07    All FIFOs and Scoreboards now use the New Scoreboard/FIFO capability 
--    06/2021   2021.06    Updated Burst FIFOs.
--    02/2021   2021.02    Added MultiDriver Detect.  Updated Generics.   
--    12/2020   2020.12    Created Virtual Transaction Interface from AxiStreamReceiver.vhd
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2018 - 2024 by SynthWorks Design Inc.  
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

  use work.AxiStreamOptionsPkg.all ; 
  use work.Axi4CommonPkg.all ; 
  use work.AxiStreamTbPkg.all ;

entity AxiStreamReceiverVti is
  generic (
    MODEL_ID_NAME  : string :="" ;
    INIT_ID        : std_logic_vector := "" ; 
    INIT_DEST      : std_logic_vector := "" ; 
    INIT_USER      : std_logic_vector := "" ; 
    INIT_LAST      : natural := 0 ; 
    tperiod_Clk    : time := 10 ns ;
    
    DEFAULT_DELAY  : time := 1 ns ;

    tpd_Clk_TReady : time := DEFAULT_DELAY
  ) ;
  port (
    -- Globals
    Clk       : in  std_logic ;
    nReset    : in  std_logic ;
    
    -- AXI Master Functional Interface
    TValid    : in  std_logic ;
    TReady    : out std_logic ; 
    TID       : in  std_logic_vector ; 
    TDest     : in  std_logic_vector ; 
    TUser     : in  std_logic_vector ; 
    TData     : in  std_logic_vector ; 
    TStrb     : in  std_logic_vector ; 
    TKeep     : in  std_logic_vector ; 
    TLast     : in  std_logic
  ) ;
  
  -- Derive AXI interface properties from interface signals
  constant AXI_STREAM_DATA_WIDTH   : integer := TData'length ;
  constant AXI_STREAM_PARAM_WIDTH  : integer := TID'length + TDest'length + TUser'length + 1 ;

  -- Testbench Transaction Interface
  -- Access via external names
  signal TransRec  : StreamRecType (
    DataToModel   (AXI_STREAM_DATA_WIDTH-1  downto 0),
    DataFromModel (AXI_STREAM_DATA_WIDTH-1  downto 0),
    ParamToModel  (AXI_STREAM_PARAM_WIDTH-1 downto 0),
    ParamFromModel(AXI_STREAM_PARAM_WIDTH-1 downto 0)
  ) ;  

  -- Use MODEL_ID_NAME Generic if set, otherwise,
  -- use model instance label (preferred if set as entityname_1)
  constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME'length > 0, MODEL_ID_NAME, 
      to_lower(PathTail(AxiStreamReceiverVti'PATH_NAME))) ;

end entity AxiStreamReceiverVti ;
architecture behavioral of AxiStreamReceiverVti is

  signal ModelID, ProtocolID, DataCheckID, BusFailedID, BurstFifoID : AlertLogIDType ;
  signal BurstCov : DelayCoverageIDType ;
  
  signal UseCoverageDelays : Boolean := FALSE ;

  constant ID_LEN       : integer := TID'length ;
  constant DEST_LEN     : integer := TDest'length ;
  constant USER_LEN     : integer := TUser'length ;
  constant PARAM_LENGTH : integer := ID_LEN + DEST_LEN + USER_LEN + 1 ;
  constant USER_RIGHT   : integer := 1 ;
  constant DEST_RIGHT   : integer := USER_RIGHT + USER_LEN ;
  constant ID_RIGHT     : integer := DEST_RIGHT + DEST_LEN ;

  signal ReceiveFifo : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;

  signal WordRequestCount, BurstRequestCount : integer := 0 ; 
  signal WordReceiveCount, BurstReceiveCount : integer := 0 ;
  signal ReceiveByteCount, TransferByteCount : integer := 0 ;

  -- Verification Component Configuration
  signal ReceiveReadyBeforeValid : boolean := TRUE ;
  signal ReceiveReadyDelayCycles : integer := 0 ;

  signal ParamID           : std_logic_vector(TID'range)   := ifelse(INIT_ID'length > 0,   INIT_ID,   (TID'range => '0')) ;
  signal ParamDest         : std_logic_vector(TDest'range) := ifelse(INIT_DEST'length > 0, INIT_DEST, (TDest'range => '0')) ;
  signal ParamUser         : std_logic_vector(TUser'range) := ifelse(INIT_USER'length > 0, INIT_USER, (TUser'range => '0')) ;
  signal ParamLast         : natural := INIT_LAST ;
  signal LastOffsetCount   : integer := 0 ;
  constant DEFAULT_BURST_MODE : StreamFifoBurstModeType := STREAM_BURST_WORD_MODE ;
  signal   BurstFifoMode      : StreamFifoBurstModeType := DEFAULT_BURST_MODE ;
  signal   BurstFifoByteMode  : boolean := (DEFAULT_BURST_MODE = STREAM_BURST_BYTE_MODE) ;
  
  signal WaitForGet : boolean := FALSE ;
begin


  ------------------------------------------------------------
  --  Initialize alerts
  ------------------------------------------------------------
  Initialize : process
    variable ID : AlertLogIDType ;
  begin
    -- Alerts
    ID            := NewID(MODEL_INSTANCE_NAME) ;
    ModelID       <= ID ;
--    ProtocolID    <= NewID("Protocol Error", ID ) ;
    DataCheckID   <= NewID("Data Check", ID ) ;
    BusFailedID   <= NewID("No response", ID ) ;
    ReceiveFifo   <= NewID("ReceiveFifo", ID, ReportMode => DISABLED, Search => PRIVATE_NAME) ;
    wait ;
  end process Initialize ;


  ------------------------------------------------------------
  --  Transaction Dispatcher
  --    Dispatches transactions to
  ------------------------------------------------------------
  TransactionDispatcher : process
    alias Operation : StreamOperationType is TransRec.Operation ;
    variable Data,  ExpectedData,  PopData  : std_logic_vector(TData'range) ;
    variable Param, ExpectedParam, PopParam : std_logic_vector(PARAM_LENGTH-1 downto 0) ;
    variable ExpectedUser : std_logic_vector(USER_LEN-1 downto 0) ;
    variable TryWordWaiting, TryBurstWaiting : boolean ; 
    variable DispatcherReceiveCount : integer := 0 ;
    variable BurstTransferCount     : integer := 0 ;
    variable WordCount : integer ;
    variable FifoWordCount, CheckWordCount : integer ;
    variable BurstBoundary  : std_logic ;
    variable DropUndriven   : boolean := FALSE ;
    function param_to_string(Param : std_logic_vector) return string is
      alias aParam : std_logic_vector(Param'length-1 downto 0) is Param ;
      alias ID   : std_logic_vector(ID_LEN-1 downto 0)   is aParam(PARAM_LENGTH-1 downto PARAM_LENGTH-ID_LEN);
      alias Dest : std_logic_vector(DEST_LEN-1 downto 0) is aParam(DEST_LEN+USER_LEN downto USER_LEN+1);
      alias User : std_logic_vector(USER_LEN-1 downto 0) is aParam(USER_LEN downto 1) ;
      alias Last : std_logic is Param(0) ;
    begin
      return
        ifelse(ID_LEN > 0,   "  TID: "       & to_hxstring(ID),   "") &
        ifelse(DEST_LEN > 0, "  TDest: "     & to_hxstring(Dest), "") &
        ifelse(USER_LEN > 0, "  TUser: "     & to_hxstring(User), "") &
        "  TLast: "     & to_string(Last) ;
    end function param_to_string ;

  begin
    wait for 0 ns ;  -- Allow ModelID to initialize
    TransRec.BurstFifo <= NewID("RxBurstFifo", ModelID, Search => PRIVATE_NAME) ;
    BurstCov           <= NewID("DelayCov",    ModelID, ReportMode => DISABLED, Search => NAME_AND_PARENT) ;
    wait for 0 ns ;  -- Allow TransRec.BurstFifo to update.
    BurstFifoID        <= GetAlertLogID(TransRec.BurstFifo) ;

    DispatchLoop : loop
      WaitForTransaction(
         Clk      => Clk,
         Rdy      => TransRec.Rdy,
         Ack      => TransRec.Ack
      ) ;

      case Operation is
        when WAIT_FOR_CLOCK =>
          WaitForClock(Clk, TransRec.IntToModel) ;

        when WAIT_FOR_TRANSACTION =>
          -- Receiver either blocks or does "try" operations
          -- There are no operations in flight
          -- There can be values received but not Get yet.
          -- Cannot block on those.
          wait for 0 ns ;

        when GET_TRANSACTION_COUNT =>
  --!! This is GetTotalTransactionCount vs. GetPendingTransactionCount
  --!!  Get Pending Get Count = GetFifoCount(ReceiveFifo)
          TransRec.IntFromModel <= WordReceiveCount ;
          wait for 0 ns ;

        when GET_ALERTLOG_ID =>
          TransRec.IntFromModel <= integer(ModelID) ;
          wait for 0 ns ;

        when SET_USE_RANDOM_DELAYS =>
          UseCoverageDelays <= TransRec.BoolToModel ; 

        when GET_USE_RANDOM_DELAYS =>
          TransRec.BoolFromModel <= UseCoverageDelays ;

        when SET_DELAYCOV_ID =>
          BurstCov          <= GetDelayCoverage(TransRec.IntToModel) ;
          UseCoverageDelays <= TRUE ; 

        when GET_DELAYCOV_ID =>
          TransRec.IntFromModel <= BurstCov.ID ;
          UseCoverageDelays <= TRUE ; 

        when SET_BURST_MODE =>
          BurstFifoMode       <= TransRec.IntToModel ;
          BurstFifoByteMode   <= (TransRec.IntToModel = STREAM_BURST_BYTE_MODE) ;

        when GET_BURST_MODE =>
          TransRec.IntFromModel <= BurstFifoMode ;

        when GOT_BURST =>
          -- Used with TryCheckBurst with Patterns VectorOfWords, Increment, Random
          if not TryBurstWaiting then
            increment(BurstRequestCount) ; 
          end if ;
          TryBurstWaiting := TRUE ; 
          if (BurstReceiveCount - BurstTransferCount) = 0 then
            TransRec.BoolFromModel  <= FALSE ;
          else
            TransRec.BoolFromModel <= TRUE ;
          end if ;

        when GET | TRY_GET | CHECK | TRY_CHECK =>
          if IsEmpty(ReceiveFifo) and  IsTry(Operation) then
            if not TryWordWaiting then
              increment(WordRequestCount) ; 
            end if ;
            TryWordWaiting := TRUE ; 
            -- Return if no data
            TransRec.BoolFromModel  <= FALSE ;
            TransRec.DataFromModel  <= (TransRec.DataFromModel'range => '0') ;
            TransRec.ParamFromModel <= (TransRec.ParamFromModel'range => '0') ;
            wait for 0 ns ;
          else
            if not TryWordWaiting then
              increment(WordRequestCount) ; 
            end if ;
            TryWordWaiting := FALSE ; 
            DispatcherReceiveCount := DispatcherReceiveCount + 1 ;

            -- Get data
            TransRec.BoolFromModel <= TRUE ;
            if IsEmpty(ReceiveFifo) then
              -- Wait for data
              WaitForToggle(WordReceiveCount) ;
            end if ;
            -- Put Data and Parameters into record
            (Data, Param, BurstBoundary) := pop(ReceiveFifo) ;
            if BurstBoundary = '1' then
              -- At BurstBoundary, there is always another word that
              -- follows that triggered the Burst Boundary
              (Data, Param, BurstBoundary) := pop(ReceiveFifo) ;
              BurstTransferCount := BurstTransferCount + 1 ;
            end if ;
            TransRec.DataFromModel  <= SafeResize(ModelID, Data, TransRec.DataFromModel'length) ;
            TransRec.ParamFromModel <= SafeResize(ModelID, Param, TransRec.ParamFromModel'length) ;

            -- Param: (TID & TDest & TUser & TLast)
            if Param(0) = '1' then
              BurstTransferCount := BurstTransferCount + 1 ;
            end if ;

            if IsCheck(Operation) then
              ExpectedData  := SafeResize(ModelID, TransRec.DataToModel, ExpectedData'length) ;
              ExpectedParam  := UpdateOptions(
                          Param      => SafeResize(ModelID, TransRec.ParamToModel, ExpectedParam'length),
                          ParamID    => ParamID,
                          ParamDest  => ParamDest,
                          ParamUser  => ParamUser,
                          ParamLast  => ParamLast,
                          Count      => WordReceiveCount - LastOffsetCount
                        ) ;
              AffirmIf( DataCheckID,
  --                (Data ?= ExpectedData and Param ?= ExpectedParam) = '1',
                  (MetaMatch(Data, ExpectedData) and MetaMatch(Param, ExpectedParam)),
                  "Operation# " & to_string (DispatcherReceiveCount) & " " &
                  " Received.  Data: " & to_hxstring(Data) &         param_to_string(Param),
                  " Expected.  Data: " & to_hxstring(ExpectedData) & param_to_string(ExpectedParam),
                  TransRec.BoolToModel or IsLogEnabled(ModelID, INFO)
                ) ;
            else
              Log(ModelID,
                  "Word Receive. " &
                  " Operation# " & to_string (DispatcherReceiveCount) &  " " &
                  " Data: "     & to_hxstring(Data) & param_to_string(Param),
                  INFO, TransRec.BoolToModel
                ) ;
            end if ;
          end if ;

        when GET_BURST | TRY_GET_BURST =>
          if (BurstReceiveCount - BurstTransferCount) = 0 and IsTry(Operation) then
            if not TryBurstWaiting then
              increment(BurstRequestCount) ; 
            end if ;
            TryBurstWaiting := TRUE ; 
            -- Return if no data
            TransRec.BoolFromModel  <= FALSE ;
            TransRec.DataFromModel  <= (TransRec.DataFromModel'range => '0') ;
            TransRec.ParamFromModel <= (TransRec.ParamFromModel'range => '0') ;
            wait for 0 ns ;
          else
            if not TryBurstWaiting then
              increment(BurstRequestCount) ; 
            end if ;
            TryBurstWaiting := FALSE ; 
            DispatcherReceiveCount := DispatcherReceiveCount + 1 ; -- Operation or #Words Transfered based?

            -- Get data
            TransRec.BoolFromModel <= TRUE ;
            if (BurstReceiveCount - BurstTransferCount) = 0 then
              -- Wait for data
              WaitForToggle(BurstReceiveCount) ;
            end if ;
            -- ReceiveFIFO: (TData & TID & TDest & TUser & TLast)
            FifoWordCount := 0 ;
            WordCount := 0 ; 
            loop
              (PopData, PopParam, BurstBoundary) := pop(ReceiveFifo) ;
              -- BurstBoundary indication does not contain data for
              -- this transaction so exit
              exit when BurstBoundary = '1' ;
              WordCount := WordCount + 1 ; 
              Data  := PopData ;
              Param := PopParam ;
              case BurstFifoMode is
                when STREAM_BURST_BYTE_MODE =>
                  PushWord(TransRec.BurstFifo, Data, DropUndriven) ;
                  FifoWordCount := FifoWordCount + CountBytes(Data, DropUndriven) ;

                when STREAM_BURST_WORD_MODE =>
                  Push(TransRec.BurstFifo, Data) ;
                  FifoWordCount := FifoWordCount + 1 ;

                when STREAM_BURST_WORD_PARAM_MODE =>
                  Push(TransRec.BurstFifo, Data & Param(USER_LEN downto 1)) ;
                  FifoWordCount := FifoWordCount + 1 ;

                when others =>
                  Alert(ModelID, "BurstFifoMode: Invalid Mode: " & to_string(BurstFifoMode)) ;
              end case ;
              exit when Param(0) = '1' ;
            end loop ;

            -- Adjust WordRequestCount for the number of words consumed during the burst
            WordRequestCount        <= Increment(WordRequestCount, WordCount) ; 

            BurstTransferCount      := BurstTransferCount + 1 ;
            TransRec.IntFromModel   <= FifoWordCount ;
            TransRec.DataFromModel  <= SafeResize(ModelID, Data, TransRec.DataFromModel'length) ;
            TransRec.ParamFromModel <= SafeResize(ModelID, Param, TransRec.ParamFromModel'length) ;

            Log(ModelID,
              "Burst Receive. " &
              " Operation# " & to_string (DispatcherReceiveCount) &  " " &
              " Last Data: "     & to_hxstring(Data) & param_to_string(Param),
              INFO, TransRec.BoolToModel or IsLogEnabled(ModelID, PASSED)
            ) ;
            wait for 0 ns ;
          end if ;

        when CHECK_BURST | TRY_CHECK_BURST =>
          if (BurstReceiveCount - BurstTransferCount) = 0 and IsTry(Operation) then
            if not TryBurstWaiting then
              increment(BurstRequestCount) ; 
            end if ;
            TryBurstWaiting := TRUE ; 
            -- Return if no data
            TransRec.BoolFromModel  <= FALSE ;
            TransRec.DataFromModel  <= (TransRec.DataFromModel'range => '0') ;
            TransRec.ParamFromModel <= (TransRec.ParamFromModel'range => '0') ;
            wait for 0 ns ;
          else
            if not TryBurstWaiting then
              increment(BurstRequestCount) ; 
            end if ;
            TryBurstWaiting := FALSE ; 
            DispatcherReceiveCount := DispatcherReceiveCount + 1 ; -- Operation or #Words Transfered based?
            -- Get data
            TransRec.BoolFromModel <= TRUE ;
            if (BurstReceiveCount - BurstTransferCount) = 0 then
              -- Wait for data
              WaitForToggle(BurstReceiveCount) ;
            end if ;
            CheckWordCount := TransRec.IntToModel ;
            FifoWordCount  := 0 ;
            WordCount := 0 ; 
            loop
             -- ReceiveFIFO: (TData & TID & TDest & TUser & TLast)
             (PopData, PopParam, BurstBoundary) := pop(ReceiveFifo) ;
              -- BurstBoundary indication does not contain data for
              -- this transaction so exit
              exit when BurstBoundary = '1' ;
              WordCount := WordCount + 1 ; 
              Data  := PopData ;
              Param := PopParam ;
              case BurstFifoMode is
                when STREAM_BURST_BYTE_MODE =>
                  CheckWord(TransRec.BurstFifo, Data, DropUndriven) ;
                  FifoWordCount := FifoWordCount + CountBytes(Data, DropUndriven) ;

                when STREAM_BURST_WORD_MODE =>
                  Check(TransRec.BurstFifo, Data) ;
                  FifoWordCount := FifoWordCount + 1 ;

                when STREAM_BURST_WORD_PARAM_MODE =>
                  -- Checking done here to differentiate data from user
                  (ExpectedData, ExpectedUser) := Pop(TransRec.BurstFifo) ;
                  AffirmIfEqual(BurstFifoID, Data, ExpectedData, "Data") ;
                  AffirmIfEqual(BurstFifoID, Param(USER_LEN downto 1), ExpectedUser, "User") ;
  --                Check(TransRec.BurstFifo, Data & Param(USER_LEN downto 1)) ;
                  FifoWordCount := FifoWordCount + 1 ;

                when others =>
                  Alert(ModelID, "BurstFifoMode: Invalid Mode: " & to_string(BurstFifoMode)) ;
              end case ;
              exit when Param(0) = '1' ;
              exit when FifoWordCount >= CheckWordCount ;
            end loop ;
            
            -- Adjust WordRequestCount for the number of words consumed during the burst
            WordRequestCount        <= Increment(WordRequestCount, WordCount) ; 

            BurstTransferCount      := BurstTransferCount + 1 ;
            TransRec.IntFromModel   <= FifoWordCount ;
            TransRec.DataFromModel  <= SafeResize(ModelID, Data, TransRec.DataFromModel'length) ;
            TransRec.ParamFromModel <= SafeResize(ModelID, Param, TransRec.ParamFromModel'length) ;

            Log(ModelID,
              "Burst Check. " &
              " Operation# " & to_string (DispatcherReceiveCount) &  " " &
              " Last Data: "     & to_hxstring(Data) & param_to_string(Param),
              INFO, TransRec.BoolToModel or IsLogEnabled(ModelID, PASSED)
            ) ;
            if not (BurstBoundary = '1' or Param(0) = '1') then
              Log(ModelID,
                "Burst Check finished without Last or BurstBoundary - normal when next word is burst boundary",
                DEBUG
              ) ;
            end if ;
            AffirmIfEqual(ModelID, FifoWordCount, CheckWordCount, "Burst Check WordCount") ;
            ExpectedParam  := UpdateOptions(
                        Param      => SafeResize(ModelID, TransRec.ParamToModel, ExpectedParam'length),
                        ParamID    => ParamID,
                        ParamDest  => ParamDest,
                        ParamUser  => ParamUser,
                        ParamLast  => 1,
                        Count      => 0
                      ) ;
            -- ID, Dest, User, Last
            if ID_LEN > 0 then
              AffirmIfEqual(ModelID, Param(ID_RIGHT+ID_LEN-1 downto ID_RIGHT),
                  ExpectedParam(ID_RIGHT+ID_LEN-1 downto ID_RIGHT), "ID") ;
            end if ;
            if DEST_LEN > 0 then
              AffirmIfEqual(ModelID, Param(DEST_RIGHT+DEST_LEN-1 downto DEST_RIGHT),
                  ExpectedParam(DEST_RIGHT+DEST_LEN-1 downto DEST_RIGHT), "DEST") ;
            end if ;
            if USER_LEN > 0 and BurstFifoMode /= STREAM_BURST_WORD_PARAM_MODE then
              AffirmIfEqual(ModelID, Param(USER_RIGHT+USER_LEN-1 downto USER_RIGHT),
                  ExpectedParam(USER_RIGHT+USER_LEN-1 downto USER_RIGHT), "USER") ;
            end if ;
            AffirmIfEqual(ModelID, Param(0) or BurstBoundary, ExpectedParam(0), "Last") ;

            wait for 0 ns ;
          end if ;

        when SET_MODEL_OPTIONS =>

          case AxiStreamOptionsType'val(TransRec.Options) is

            when RECEIVE_READY_BEFORE_VALID =>
              ReceiveReadyBeforeValid <= TransRec.BoolToModel ;
              UseCoverageDelays <= FALSE ; 

            when RECEIVE_READY_DELAY_CYCLES =>
              ReceiveReadyDelayCycles <= TransRec.IntToModel ;
              UseCoverageDelays <= FALSE ; 

            when RECEIVE_READY_WAIT_FOR_GET =>
              WaitForGet      <= TransRec.BoolToModel ;

            when DROP_UNDRIVEN =>
              DropUndriven    := TransRec.BoolToModel ;

            when DEFAULT_ID =>
              ParamID         <= SafeResize(ModelID, TransRec.ParamToModel, ParamID'length) ;

            when DEFAULT_DEST =>
              ParamDest       <= SafeResize(ModelID, TransRec.ParamToModel, ParamDest'length) ;

            when DEFAULT_USER =>
              ParamUser       <= SafeResize(ModelID, TransRec.ParamToModel, ParamUser'length) ;

            when DEFAULT_LAST =>
              ParamLast       <= TransRec.IntToModel ;
              LastOffsetCount <= WordReceiveCount ;

            when others =>
              Alert(ModelID, "SetOptions, Unimplemented Option: " & to_string(AxiStreamOptionsType'val(TransRec.Options)), FAILURE) ;
              wait for 0 ns ;
          end case ;

        when GET_MODEL_OPTIONS =>
          case AxiStreamOptionsType'val(TransRec.Options) is
            when RECEIVE_READY_BEFORE_VALID =>
              TransRec.BoolFromModel   <=  ReceiveReadyBeforeValid ;

            when RECEIVE_READY_DELAY_CYCLES =>
              TransRec.IntFromModel <= ReceiveReadyDelayCycles ;

            when RECEIVE_READY_WAIT_FOR_GET =>
              TransRec.BoolFromModel <= WaitForGet ;

            when DROP_UNDRIVEN =>
              TransRec.BoolFromModel <= DropUndriven ;

            when DEFAULT_ID =>
              TransRec.ParamFromModel <= SafeResize(ModelID, ParamID, TransRec.ParamFromModel'length) ;

            when DEFAULT_DEST =>
              TransRec.ParamFromModel <= SafeResize(ModelID, ParamDest, TransRec.ParamFromModel'length) ;

            when DEFAULT_USER =>
              TransRec.ParamFromModel <= SafeResize(ModelID, ParamUser, TransRec.ParamFromModel'length) ;

            when DEFAULT_LAST =>
              TransRec.IntFromModel   <= ParamLast ;

            when others =>
              Alert(ModelID, "GetOptions, Unimplemented Option: " & to_string(AxiStreamOptionsType'val(TransRec.Options)), FAILURE) ;
              wait for 0 ns ;
          end case ;
        -- The End -- Done

--!! Replaced by ClassifyUnimplementedReceiverOperation
--        when MULTIPLE_DRIVER_DETECT =>
--          Alert(ModelID, "Multiple Drivers on Transaction Record." & 
--                         "  Transaction # " & to_string(TransRec.Rdy), FAILURE) ;

        -- The End -- Done
        when others =>
--          Alert(ModelID, "Unimplemented Transaction: " & to_string(TransRec.Operation), FAILURE) ;
          Alert(ModelID, ClassifyUnimplementedReceiverOperation(TransRec.Operation, TransRec.Rdy), FAILURE) ;
      end case ;

      -- Wait for 1 delta cycle, required if a wait is not in all case branches above
      wait for 0 ns ;
    end loop DispatchLoop ;
  end process TransactionDispatcher ;


  ------------------------------------------------------------
  --  ReceiveHandler
  --    Receive Stream Data Transactions
  ------------------------------------------------------------
  ReceiveHandler : process
    variable Data           : std_logic_vector(TData'length-1 downto 0) ;
    variable Last           : std_logic ;
    variable BurstBoundary  : std_logic ;
    variable LastID         : std_logic_vector(TID'range)   := (TID'range   => '-') ;
    variable LastDest       : std_logic_vector(TDest'range) := (TDest'range => '-') ;
    variable LastLast       : std_logic := '1' ;
--    alias Strb : std_logic_vector(TStrb'length-1 downto 0) is TStrb ;
--    alias Keep : std_logic_vector(TKeep'length-1 downto 0) is TKeep ;
    variable Strb : std_logic_vector(TStrb'length-1 downto 0) ;
    variable Keep : std_logic_vector(TKeep'length-1 downto 0) ;

    variable ReadyBeforeValid, ReadyDelayCycles : integer ; 
  begin
    -- Initialize
    TReady  <= '0' ;
    wait for 0 ns ; -- Allow Cov models to initialize 
    wait for 0 ns ; -- Allow Cov models to initialize 
    -- BurstLength - once per BurstLength, use BurstDelay, otherwise use BeatDelay
    AddBins (BurstCov.BurstLengthCov,  80, GenBin(3,11,1)) ;      -- 80% Small Burst Length
    AddBins (BurstCov.BurstLengthCov,  20, GenBin(109,131,1)) ;   -- 20% Large Burst Length
    -- BurstDelay - happens at BurstLength boundaries
    AddCross(BurstCov.BurstDelayCov,   65, GenBin(0), GenBin(2,8,1)) ;     -- 65% Ready Before Valid, small delay
    AddCross(BurstCov.BurstDelayCov,   10, GenBin(0), GenBin(108,156,1)) ; -- 10% Ready Before Valid, large delay
    AddCross(BurstCov.BurstDelayCov,   15, GenBin(1), GenBin(2,8,1)) ;     -- 15% Ready After Valid, small delay
    AddCross(BurstCov.BurstDelayCov,   10, GenBin(1), GenBin(108,156,1)) ; -- 10% Ready After Valid, large delay
    -- BeatDelay - happens between each transfer it not at a BurstLength boundary
    AddCross(BurstCov.BeatDelayCov,    85, GenBin(0), GenBin(0)) ;       -- 85% Ready Before Valid, no delay
    AddCross(BurstCov.BeatDelayCov,     5, GenBin(0), GenBin(1)) ;       --  5% Ready Before Valid, 1 cycle delay
    AddCross(BurstCov.BeatDelayCov,     5, GenBin(1), GenBin(0)) ;       --  5% Ready After Valid, no delay
    AddCross(BurstCov.BeatDelayCov,     5, GenBin(1), GenBin(1)) ;       --  5% Ready After Valid, 1 cycle delay

    WaitForBarrier(OsvvmVcInit) ;
    ReceiveLoop : loop

      if WaitForGet then 
        -- if no request, wait until we have one
        --!! Note:  > breaks when **RequestCount > 2**30 
        if not ((BurstRequestCount > BurstReceiveCount) or (WordRequestCount > WordReceiveCount)) then 
          wait until (BurstRequestCount > BurstReceiveCount) or (WordRequestCount > WordReceiveCount) or not WaitForGet ; 
        end if ;
      end if ; 
      
      -- Delay between consecutive signaling of Ready
      if UseCoverageDelays then 
        -- BurstCoverage Delays
        (ReadyBeforeValid, ReadyDelayCycles)  := GetRandDelay(BurstCov) ; 
      else
        -- Deprecated static settings
        ReadyBeforeValid := to_integer(not ReceiveReadyBeforeValid) ; 
        ReadyDelayCycles := ReceiveReadyDelayCycles ; 
      end if ; 

      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => TValid,
        Ready                   => TReady,
        ReadyBeforeValid        => ReadyBeforeValid = 0,
        ReadyDelayCycles        => ReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_TReady,
        AlertLogID              => ModelID
      ) ;

      Data := to_x01(TData) ;
      Last := to_01(TLast) ;
      Strb := to_x01(TStrb) ;
      Keep := to_x01(TKeep) ;
      -- Either Strb or Keep can have a null range
      -- Make Data a Z if Strb(i) is position byte
      for i in Strb'range loop
        if Strb(i) = '0' then
          Data(i*8 + 7 downto i*8) := (others => 'W') ;
        end if;
      end loop ;
      -- Make Data a U if Keep(i) is null byte
      for i in Keep'range loop
        if Keep(i) = '0' then
          Data(i*8 + 7 downto i*8) := (others => 'U') ;
        end if;
      end loop ;
      
      if BurstFifoByteMode then 
        -- For ByteMode, we drop words with X"--"
        -- For first Word in Transfer, Drop leading bytes until TKeep(i) = '1'
        if LastLast = '1' then
          for i in Keep'reverse_range loop
            exit when Keep(i) /= '0' ;
            Data(i*8 + 7 downto i*8) := (others => '-') ;
          end loop ;
        end if ;
        -- For last Word in Transfer, Drop ending bytes until TKeep(i) = '1'
        if Last = '1' then
          for i in Keep'range loop
            exit when Keep(i) /= '0' ;
            Data(i*8 + 7 downto i*8) := (others => '-') ;
          end loop ;
        end if ;
      end if ;

      if (not MetaMatch(TID, LastID) or not MetaMatch(TDest, LastDest)) and LastLast /= '1' then
        -- push a burst boundary word, only the Burst Boundary value matters
        push(ReceiveFifo, Data & TID & TDest & TUser & Last & '1') ;
        BurstReceiveCount <= BurstReceiveCount + 1 ;
        if Last = '1' then
          wait for 0 ns ;
        end if ;
      end if ;
--      BurstBoundary := '1' when (not MetaMatch(TID, LastID) or not MetaMatch(TDest, LastDest)) and LastLast /= '1' else '0' ;
      LastID   := TID ;
      LastDest := TDest ;
      LastLast := Last ;
      -- capture this transaction
      push(ReceiveFifo, Data & TID & TDest & TUser & Last & '0') ;
      if Last = '1' then
        BurstReceiveCount <= BurstReceiveCount + 1 ;
      end if ;

      -- Log this operation
      Log(ModelID,
        "Axi Stream Receive." &
        "  TData: "     & to_hxstring(TData) &
        ifelse(TStrb'length > 0, "  TStrb: "     & to_string (TStrb), "") &
        ifelse(TKeep'length > 0, "  TKeep: "     & to_string (TKeep), "") &
        ifelse(TID'length > 0,   "  TID: "       & to_hxstring(TID),   "") &
        ifelse(TDest'length > 0, "  TDest: "     & to_hxstring(TDest), "") &
        ifelse(TUser'length > 0, "  TUser: "     & to_hxstring(TUser), "") &
        "  TLast: "     & to_string (TLast) &
        "  Operation# " & to_string (WordReceiveCount + 1),
        DEBUG
      ) ;

      -- Signal completion
      increment(WordReceiveCount) ;
      wait for 0 ns ;
    end loop ReceiveLoop ;
  end process ReceiveHandler ;
end architecture behavioral ;


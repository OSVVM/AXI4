--
--  File Name:         AxiStreamTransmitterVti.vhd
--  Design Unit Name:  AxiStreamTransmitterVti
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      AXI Stream Transmitter Model with Virtual Transaction Interface
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    05/2022   2022.05    Updated FIFOs so they are Search => PRIVATE
--    03/2022   2022.03    Updated calls to NewID for AlertLogID and FIFOs
--                         Updated handling of TStrb
--    02/2022   2022.02    Replaced to_hstring to to_hxstring
--    01/2022   2022.01    Moved MODEL_INSTANCE_NAME and MODEL_NAME to entity declarative region
--    07/2021   2021.07    All FIFOs and Scoreboards now use the New Scoreboard/FIFO capability 
--    06/2021   2021.06    Updated Burst FIFOs.
--    02/2021   2021.02    Added Valid Delays.  Added MultiDriver Detect.  Updated Generics.
--    12/2020   2020.12    Created Virtual Transaction Interface from AxiStreamTransmitter.vhd
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2018 - 2021 by SynthWorks Design Inc.
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

entity AxiStreamTransmitterVti is
  generic (
    MODEL_ID_NAME  : string := "" ;
    INIT_ID        : std_logic_vector := "" ;
    INIT_DEST      : std_logic_vector := "" ;
    INIT_USER      : std_logic_vector := "" ;
    INIT_LAST      : natural := 0 ;

    tperiod_Clk    : time := 10 ns ;

    DEFAULT_DELAY  : time := 1 ns ;

    tpd_Clk_TValid : time := DEFAULT_DELAY ;
    tpd_Clk_TID    : time := DEFAULT_DELAY ;
    tpd_Clk_TDest  : time := DEFAULT_DELAY ;
    tpd_Clk_TUser  : time := DEFAULT_DELAY ;
    tpd_Clk_TData  : time := DEFAULT_DELAY ;
    tpd_Clk_TStrb  : time := DEFAULT_DELAY ;
    tpd_Clk_TKeep  : time := DEFAULT_DELAY ;
    tpd_Clk_TLast  : time := DEFAULT_DELAY
  ) ;
  port (
    -- Globals
    Clk       : in  std_logic ;
    nReset    : in  std_logic ;

    -- AXI Transmitter Functional Interface
    TValid    : out std_logic ;
    TReady    : in  std_logic ;
    TID       : out std_logic_vector ;
    TDest     : out std_logic_vector ;
    TUser     : out std_logic_vector ;
    TData     : out std_logic_vector ;
    TStrb     : out std_logic_vector ;
    TKeep     : out std_logic_vector ;
    TLast     : out std_logic
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
      to_lower(PathTail(AxiStreamTransmitterVti'PATH_NAME))) ;

end entity AxiStreamTransmitterVti ;
architecture SimpleTransmitter of AxiStreamTransmitterVti is
  signal ModelID, BusFailedID : AlertLogIDType ;
--  signal ProtocolID, DataCheckID : AlertLogIDType ;

  constant AXI_STREAM_DATA_BYTE_WIDTH  : integer := integer(ceil(real(AXI_STREAM_DATA_WIDTH) / 8.0)) ;
  constant AXI_ID_WIDTH   : integer    := TID'length ;
  constant AXI_DEST_WIDTH : integer    := TDest'length ;

  signal TransmitFifo : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;

  signal TransmitRequestCount, TransmitDoneCount      : integer := 0 ;


  -- Verification Component Configuration
  signal TransmitReadyTimeOut : integer := integer'right ;

  signal ParamID           : std_logic_vector(TID'range)   := IfElse(INIT_ID'length > 0,   INIT_ID,   (TID'range => '0')) ;
  signal ParamDest         : std_logic_vector(TDest'range) := IfElse(INIT_DEST'length > 0, INIT_DEST, (TDest'range => '0')) ;
  signal ParamUser         : std_logic_vector(TUser'range) := IfElse(INIT_USER'length > 0, INIT_USER, (TUser'range => '0')) ;
  signal ParamLast         : natural := INIT_LAST ;
  signal LastOffsetCount   : integer := 0 ;
  signal ValidDelayCycles  : integer := 0 ;
  signal ValidBurstDelayCycles  : integer := 0 ;

  constant DEFAULT_BURST_MODE : StreamFifoBurstModeType := STREAM_BURST_WORD_MODE ;
  signal   BurstFifoMode      : StreamFifoBurstModeType := DEFAULT_BURST_MODE ;
  signal   BurstFifoByteMode  : boolean := (DEFAULT_BURST_MODE = STREAM_BURST_BYTE_MODE) ;

begin

  ------------------------------------------------------------
  --  Initialize alerts
  ------------------------------------------------------------
  Initialize : process
    variable ID : AlertLogIDType ;
  begin
    -- Alerts
    ID              := NewID(MODEL_INSTANCE_NAME) ;
    ModelID         <= ID ;
--    ProtocolID      <= NewID("Protocol Error", ID ) ;
--    DataCheckID     <= NewID("Data Check", ID ) ;
    BusFailedID     <= NewID("No response",  ID) ;
    TransmitFifo    <= NewID("TransmitFifo", ID, ReportMode => DISABLED, Search => PRIVATE) ; 
    wait ;
  end process Initialize ;


  ------------------------------------------------------------
  --  Transaction Dispatcher
  --    Dispatches transactions to
  ------------------------------------------------------------
  TransactionDispatcher : process
    variable Data : std_logic_vector(TData'range) ;
    variable Param : std_logic_vector(TransRec.ParamToModel'length-1 downto 0) ;
    variable BytesToSend, NumberTransfers : integer ;
    variable PopValid : boolean ;
    variable Last : std_logic ;
    variable User : std_logic_vector(TUser'range) ;
  begin
    wait for 0 ns ; 
    TransRec.BurstFifo <= NewID("TxBurstFifo", ModelID, Search => PRIVATE) ;
    
    DispatchLoop : loop 
      WaitForTransaction(
         Clk      => Clk,
         Rdy      => TransRec.Rdy,
         Ack      => TransRec.Ack
      ) ;

      case TransRec.Operation is
        when WAIT_FOR_CLOCK =>
          WaitForClock(Clk, TransRec.IntToModel) ;

        when WAIT_FOR_TRANSACTION =>
          if TransmitRequestCount /= TransmitDoneCount then
            wait until TransmitRequestCount = TransmitDoneCount ;
          end if ;

        when GET_TRANSACTION_COUNT =>
          TransRec.IntFromModel <= TransmitDoneCount ;
          wait for 0 ns ;

        when GET_ALERTLOG_ID =>
          TransRec.IntFromModel <= integer(ModelID) ;
          wait for 0 ns ;

        when SET_BURST_MODE =>
          BurstFifoMode       <= TransRec.IntToModel ;
          BurstFifoByteMode   <= (TransRec.IntToModel = STREAM_BURST_BYTE_MODE) ;

        when GET_BURST_MODE =>
          TransRec.IntToModel <= BurstFifoMode ;

        when SEND | SEND_ASYNC =>
          Data   := SafeResize(TransRec.DataToModel, Data'length) ;
          Param  := UpdateOptions(
                      Param      => SafeResize(TransRec.ParamToModel, TransRec.ParamToModel'length),
                      ParamID    => ParamID,
                      ParamDest  => ParamDest,
                      ParamUser  => ParamUser,
                      ParamLast  => ParamLast,
                      Count      => ((TransmitRequestCount+1) - LastOffsetCount)
                    ) ;
          Push(TransmitFifo, '0' & Data & Param) ;
          Increment(TransmitRequestCount) ;
          wait for 0 ns ;
          if IsBlocking(TransRec.Operation) then
            wait until TransmitRequestCount = TransmitDoneCount ;
          end if ;

        when SEND_BURST | SEND_BURST_ASYNC =>
          Param  := UpdateOptions(
                      Param      => SafeResize(TransRec.ParamToModel, TransRec.ParamToModel'length),
                      ParamID    => ParamID,
                      ParamDest  => ParamDest,
                      ParamUser  => ParamUser,
--Last                      ParamLast  => ParamLast,
                      ParamLast  => 1,
                      Count      => ((TransmitRequestCount+1) - LastOffsetCount)
                    ) ;
          if BurstFifoByteMode then
            BytesToSend := TransRec.IntToModel ;
            NumberTransfers := integer(ceil(real(BytesToSend) / real(AXI_STREAM_DATA_BYTE_WIDTH))) ;
          else
            NumberTransfers := TransRec.IntToModel ;
          end if ;
          TransmitRequestCount <= TransmitRequestCount + NumberTransfers ;
          Last := Param(0) ;
          for i in NumberTransfers-1 downto 0 loop
            case BurstFifoMode is
              when STREAM_BURST_BYTE_MODE =>
                PopWord(TransRec.BurstFifo, PopValid, Data, BytesToSend) ;
                AlertIfNot(ModelID, PopValid, "BurstFifo Empty during burst transfer", FAILURE) ;

              when STREAM_BURST_WORD_MODE =>
                Data := Pop(TransRec.BurstFifo) ;

              when STREAM_BURST_WORD_PARAM_MODE =>
                (Data, User) := Pop(TransRec.BurstFifo) ;
                Param(User'length downto 1) := User ;

  --            when WORD_USER_LAST_MODE =>
  --              (Data, User, Last) := BurstFifo.Pop ;
  --              Param(User'length downto 1) := User ;

              when others =>
                Alert(ModelID, "BurstFifoMode: Invalid Mode: " & to_string(BurstFifoMode)) ;
            end case ;
--Last            Param(0) := '1' when i = 0 else '0' ;  -- TLast
            Param(0) := Last when i = 0 else '0' ;  -- TLast
            Push(TransmitFifo, '1' & Data & Param) ;
          end loop ;

          wait for 0 ns ;
          if IsBlocking(TransRec.Operation) then
            wait until TransmitRequestCount = TransmitDoneCount ;
          end if ;

        when SET_MODEL_OPTIONS =>
          case AxiStreamOptionsType'val(TransRec.Options) is
            when TRANSMIT_VALID_DELAY_CYCLES =>
              ValidDelayCycles <= TransRec.IntToModel ;

            when TRANSMIT_VALID_BURST_DELAY_CYCLES =>
              ValidBurstDelayCycles <= TransRec.IntToModel ;

            when TRANSMIT_READY_TIME_OUT =>
              TransmitReadyTimeOut      <= TransRec.IntToModel ;

            when DEFAULT_ID =>
              ParamID         <= SafeResize(TransRec.ParamToModel, ParamID'length) ;

            when DEFAULT_DEST =>
              ParamDest       <= SafeResize(TransRec.ParamToModel, ParamDest'length) ;

            when DEFAULT_USER =>
              ParamUser       <= SafeResize(TransRec.ParamToModel, ParamUser'length) ;

            when DEFAULT_LAST =>
              ParamLast       <= TransRec.IntToModel ;
              LastOffsetCount <= TransmitRequestCount ;

            when others =>
              Alert(ModelID, "SetOptions, Unimplemented Option: " & to_string(AxiStreamOptionsType'val(TransRec.Options)), FAILURE) ;
              wait for 0 ns ;
          end case ;

        when GET_MODEL_OPTIONS =>
          case AxiStreamOptionsType'val(TransRec.Options) is
            when TRANSMIT_VALID_DELAY_CYCLES =>
              TransRec.IntFromModel   <= ValidDelayCycles ;

            when TRANSMIT_VALID_BURST_DELAY_CYCLES =>
              TransRec.IntFromModel   <= ValidBurstDelayCycles ;

            when TRANSMIT_READY_TIME_OUT =>
              TransRec.IntFromModel   <=  TransmitReadyTimeOut ;

            when DEFAULT_ID =>
              TransRec.ParamFromModel <= SafeResize(ParamID, TransRec.ParamFromModel'length) ;

            when DEFAULT_DEST =>
              TransRec.ParamFromModel <= SafeResize(ParamDest, TransRec.ParamFromModel'length) ;

            when DEFAULT_USER =>
              TransRec.ParamFromModel <= SafeResize(ParamUser, TransRec.ParamFromModel'length) ;

            when DEFAULT_LAST =>
              TransRec.IntFromModel   <= ParamLast ;

            when others =>
              Alert(ModelID, "GetOptions, Unimplemented Option: " & to_string(AxiStreamOptionsType'val(TransRec.Options)), FAILURE) ;
          end case ;

        when MULTIPLE_DRIVER_DETECT =>
          Alert(ModelID, "Multiple Drivers on Transaction Record." & 
                         "  Transaction # " & to_string(TransRec.Rdy), FAILURE) ;

        -- The End -- Done
        when others =>
          Alert(ModelID, "Unimplemented Transaction: " & to_string(TransRec.Operation), FAILURE) ;
      end case ;

      -- Wait for 1 delta cycle, required if a wait is not in all case branches above
      wait for 0 ns ;
    end loop DispatchLoop ;
  end process TransactionDispatcher ;


  ------------------------------------------------------------
  --  TransmitHandler
  --    Execute Write Address Transactions
  ------------------------------------------------------------
  TransmitHandler : process
    variable ID    : std_logic_vector(TID'range)   ;
    variable Dest  : std_logic_vector(TDest'range) ;
    variable User  : std_logic_vector(TUser'range) ;
    variable Data  : std_logic_vector(TData'length-1 downto 0) ;
    variable Strb  : std_logic_vector(TStrb'length-1 downto 0) ;
    variable Keep  : std_logic_vector(TKeep'length-1 downto 0) ;
    variable Last  : std_logic ;
    variable NewTransfer : std_logic := '1' ;
    variable Burst : std_logic ;
  begin
    -- Initialize
    TValid  <= '0' ;
    TID     <= (TID'range => 'X') ;
    TDest   <= (TDest'range => 'X') ;
    TUser   <= (TUser'range => 'X') ;
    TData   <= (TData'range => 'X') ;
    TStrb   <= (TStrb'range => 'X') ;
    TKeep   <= (TKeep'range => 'X') ;
    TLast   <= 'X' ;
    wait for 0 ns ; -- Allow TransmitFifo to initialize 

    TransmitLoop : loop
      -- Find Transaction
      if Empty(TransmitFifo) then
         WaitForToggle(TransmitRequestCount) ;
      end if ;

      -- Get Transaction
      (Burst, Data, ID, Dest, User, Last) := Pop(TransmitFifo) ;

      if NewTransfer or not Burst then
        WaitForClock(Clk, ValidDelayCycles) ;
      else
        WaitForClock(Clk, ValidBurstDelayCycles) ;
      end if ;
      NewTransfer := Last or not Burst ;

      -- Calculate Strb. 1 when data else 0
      -- If Strb is unused it may be null range
      for i in Strb'range loop
        if Data(i*8) = 'W' or Data(i*8) = 'U' then
          Strb(i) := '0' ;
        else
          Strb(i) := '1' ;
        end if ;
      end loop ;

      -- Calculate Keep.  1 when data /= 'U' else 0
      -- If Keep is unused it may be null range
      for i in Keep'range loop
        if Data(i*8) = 'U' then
          Keep(i) := '0' ;
        else
          Keep(i) := '1' ;
        end if ;
      end loop ;

      -- Do Transaction
      TID     <= ID   after tpd_Clk_tid ;
      TDest   <= Dest after tpd_Clk_TDest ;
      TUser   <= User after tpd_Clk_TUser ;
      TData   <= to_x01(Data) after tpd_Clk_TData ;
      TStrb   <= Strb after tpd_Clk_TStrb ;
      TKeep   <= Keep after tpd_Clk_TKeep ;
      TLast   <= Last after tpd_Clk_TLast ;

      Log(ModelID,
        "Axi Stream Send." &
        "  TData: "     & to_hxstring(to_x01(Data)) &
        IfElse(TStrb'length > 0, "  TStrb: "     & to_string( Strb), "") &
        IfElse(TKeep'length > 0, "  TKeep: "     & to_string( Keep), "") &
        IfElse(TID'length   > 0, "  TID: "       & to_hxstring(ID),   "") &
        IfElse(TDest'length > 0, "  TDest: "     & to_hxstring(Dest), "") &
        IfElse(TUser'length > 0, "  TUser: "     & to_hxstring(User), "") &
        "  TLast: "     & to_string( Last) &
        -- Must be DoneCount and not RequestCount due to queuing/Async and burst operations
        "  Operation# " & to_string( TransmitDoneCount + 1),
        INFO
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  TValid,
        Ready          =>  TReady,
        tpd_Clk_Valid  =>  tpd_Clk_TValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "AXI Stream Send Operation # " & to_string(TransmitDoneCount + 1),
        TimeOutPeriod  =>  TransmitReadyTimeOut * tperiod_Clk
      ) ;

      -- State after transaction
      TID     <= ID + 1    after tpd_Clk_tid ;
      TDest   <= Dest + 1  after tpd_Clk_TDest ;
      TUser   <= not User  after tpd_Clk_TUser ;
      TData   <= not Data  after tpd_Clk_TData ;
      TStrb   <= (TStrb'range => '1') after tpd_Clk_TStrb ;
      TKeep   <= (TKeep'range => '1') after tpd_Clk_TKeep ;

      -- Signal completion
      Increment(TransmitDoneCount) ;
      wait for 0 ns ;
    end loop TransmitLoop ;
  end process TransmitHandler ;
end architecture SimpleTransmitter ;


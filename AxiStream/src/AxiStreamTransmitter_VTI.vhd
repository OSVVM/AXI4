--
--  File Name:         AxiStreamTransmitter_VTI.vhd
--  Design Unit Name:  AxiStreamTransmitter_VTI
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
--    Date       Version    Description
--    05/2018    2018.05    First Release
--    01/2020    2020.01    Updated license notice
--    07/2020    2020.07    Updated for Streaming Model Independent Transactions
--    10/2020    2020.10    Added Bursting per updates to Model Independent Transactions
--    12/2020    2020.12    Added Virtual Transaction Interface
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.  
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

entity AxiStreamTransmitter_VTI is
  generic (
    MODEL_ID_NAME  : string := "" ;
    INIT_ID        : std_logic_vector := "" ; 
    INIT_DEST      : std_logic_vector := "" ; 
    INIT_USER      : std_logic_vector := "" ; 
    INIT_LAST      : natural := 0 ; 

    tperiod_Clk    : time := 10 ns ;
    
    tpd_Clk_TValid : time := 2 ns ; 
    tpd_Clk_TID    : time := 2 ns ; 
    tpd_Clk_TDest  : time := 2 ns ; 
    tpd_Clk_TUser  : time := 2 ns ; 
    tpd_Clk_TData  : time := 2 ns ; 
    tpd_Clk_TStrb  : time := 2 ns ; 
    tpd_Clk_TKeep  : time := 2 ns ; 
    tpd_Clk_TLast  : time := 2 ns 
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
  constant AXI_STREAM_DATA_WIDTH   : integer := TData'length ;
  constant AXI_STREAM_PARAM_WIDTH  : integer := TID'length + TDest'length + TUser'length + 1 ;

  -- Testbench Virtual Transaction Interface
  signal TransRec  : StreamRecType (
    DataToModel   (AXI_STREAM_DATA_WIDTH-1  downto 0),
    DataFromModel (AXI_STREAM_DATA_WIDTH-1  downto 0),
    ParamToModel  (AXI_STREAM_PARAM_WIDTH-1 downto 0),
    ParamFromModel(AXI_STREAM_PARAM_WIDTH-1 downto 0)
  ) ;  
  
  shared variable BurstFifo     : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 

end entity AxiStreamTransmitter_VTI ;
architecture SimpleTransmitter of AxiStreamTransmitter_VTI is


  constant AXI_STREAM_DATA_BYTE_WIDTH  : integer := integer(ceil(real(AXI_STREAM_DATA_WIDTH) / 8.0)) ;

  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME'length > 0, MODEL_ID_NAME, to_lower(PathTail(AxiStreamTransmitter_VTI'PATH_NAME))) ;

  signal ModelID, BusFailedID : AlertLogIDType ; 
--  signal ProtocolID, DataCheckID : AlertLogIDType ; 
  
  shared variable TransmitFifo  : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 

  signal TransmitRequestCount, TransmitDoneCount      : integer := 0 ;   


  -- Verification Component Configuration
  signal TransmitReadyTimeOut : integer := integer'right ; 

  signal ParamID           : std_logic_vector(TID'range)   := IfElse(INIT_ID'length > 0,   INIT_ID,   (TID'range => '0')) ;
  signal ParamDest         : std_logic_vector(TDest'range) := IfElse(INIT_DEST'length > 0, INIT_DEST, (TDest'range => '0')) ;
  signal ParamUser         : std_logic_vector(TUser'range) := IfElse(INIT_USER'length > 0, INIT_USER, (TUser'range => '0')) ;
  signal ParamLast         : natural := INIT_LAST ;
  signal LastOffsetCount   : integer := 0 ; 
  signal BurstFifoMode     : integer := STREAM_BURST_WORD_MODE;
  signal BurstFifoByteMode : boolean := (BurstFifoMode = STREAM_BURST_BYTE_MODE) ; 

begin


  ------------------------------------------------------------
  --  Initialize alerts
  ------------------------------------------------------------
  Initialize : process
    variable ID : AlertLogIDType ; 
  begin
    -- Alerts 
    ID                      := GetAlertLogID(MODEL_INSTANCE_NAME) ; 
    ModelID                 <= ID ; 
--    ProtocolID              <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Protocol Error", ID ) ;
--    DataCheckID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Data Check", ID ) ;
    BusFailedID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": No response", ID ) ;
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
        Data   := FromTransaction(TransRec.DataToModel, Data'length) ;
        Param  := UpdateOptions(
                    Param      => FromTransaction(TransRec.ParamToModel, TransRec.ParamToModel'length),
                    ParamID    => ParamID, 
                    ParamDest  => ParamDest,
                    ParamUser  => ParamUser,
                    ParamLast  => ParamLast,           
                    Count      => ((TransmitRequestCount+1) - LastOffsetCount)
                  ) ;
        TransmitFifo.Push(Data & Param) ; 
        Increment(TransmitRequestCount) ;
        wait for 0 ns ; 
        if IsBlocking(TransRec.Operation) then 
          wait until TransmitRequestCount = TransmitDoneCount ;
        end if ; 

      when SEND_BURST | SEND_BURST_ASYNC =>
        Param  := UpdateOptions(
                    Param      => FromTransaction(TransRec.ParamToModel, TransRec.ParamToModel'length),
                    ParamID    => ParamID, 
                    ParamDest  => ParamDest,
                    ParamUser  => ParamUser,
                    ParamLast  => ParamLast,           
                    Count      => ((TransmitRequestCount+1) - LastOffsetCount)
                  ) ;
        If BurstFifoByteMode then 
          BytesToSend := TransRec.IntToModel ;
          NumberTransfers := integer(ceil(real(BytesToSend) / real(AXI_STREAM_DATA_BYTE_WIDTH))) ;
        else 
          NumberTransfers := TransRec.IntToModel ; 
        end if ; 
        TransmitRequestCount <= TransmitRequestCount + NumberTransfers ;
--        Last := '0' ;
        for i in NumberTransfers-1 downto 0 loop 
          case BurstFifoMode is
            when STREAM_BURST_BYTE_MODE => 
              PopWord(BurstFifo, PopValid, Data, BytesToSend) ; 
              AlertIfNot(ModelID, PopValid, "BurstFifo Empty during burst transfer", FAILURE) ; 
          
            when STREAM_BURST_WORD_MODE => 
              Data := BurstFifo.Pop ; 
            
            when STREAM_BURST_WORD_PARAM_MODE =>
              (Data, User) := BurstFifo.Pop ; 
              Param(User'length downto 1) := User ; 
              
--            when WORD_USER_LAST_MODE => 
--              (Data, User, Last) := BurstFifo.Pop ; 
--              Param(User'length downto 1) := User ; 
              
            when others => 
              Alert(ModelID, "BurstFifoMode: Invalid Mode: " & to_string(BurstFifoMode)) ;
          end case ; 
--          Param(0) := '1' when i = 0 else Last ;  -- TLast
          Param(0) := '1' when i = 0 else '0' ;  -- TLast
          TransmitFifo.Push(Data & Param) ; 
        end loop ; 
        
        wait for 0 ns ; 
        if IsBlocking(TransRec.Operation) then 
          wait until TransmitRequestCount = TransmitDoneCount ;
        end if ; 

      when SET_MODEL_OPTIONS =>
        case AxiStreamOptionsType'val(TransRec.Options) is
          when TRANSMIT_READY_TIME_OUT =>       
            TransmitReadyTimeOut      <= TransRec.IntToModel ; 
            
          when DEFAULT_ID =>                      
            ParamID         <= FromTransaction(TransRec.ParamToModel, ParamID'length) ;
            
          when DEFAULT_DEST => 
            ParamDest       <= FromTransaction(TransRec.ParamToModel, ParamDest'length) ;
            
          when DEFAULT_USER =>
            ParamUser       <= FromTransaction(TransRec.ParamToModel, ParamUser'length) ;
            
          when DEFAULT_LAST =>
            ParamLast       <= TransRec.IntToModel ;
            LastOffsetCount <= TransmitRequestCount ; 

          when others =>
            Alert(ModelID, "SetOptions, Unimplemented Option: " & to_string(AxiStreamOptionsType'val(TransRec.Options)), FAILURE) ;
            wait for 0 ns ; 
        end case ;
        
      when GET_MODEL_OPTIONS =>
        case AxiStreamOptionsType'val(TransRec.Options) is
          when TRANSMIT_READY_TIME_OUT =>       
            TransRec.IntFromModel   <=  TransmitReadyTimeOut ; 
            
          when DEFAULT_ID =>                      
            TransRec.ParamFromModel <= ToTransaction(ParamID, TransRec.ParamFromModel'length) ;
            
          when DEFAULT_DEST => 
            TransRec.ParamFromModel <= ToTransaction(ParamDest, TransRec.ParamFromModel'length) ;
            
          when DEFAULT_USER =>
            TransRec.ParamFromModel <= ToTransaction(ParamUser, TransRec.ParamFromModel'length) ;
            
          when DEFAULT_LAST =>
            TransRec.IntFromModel   <= ParamLast ;

          when others =>
            Alert(ModelID, "GetOptions, Unimplemented Option: " & to_string(AxiStreamOptionsType'val(TransRec.Options)), FAILURE) ;
            wait for 0 ns ; 
        end case ;

      -- The End -- Done  
      when others =>
        Alert(ModelID, "Unimplemented Transaction: " & to_string(TransRec.Operation), FAILURE) ;
        wait for 0 ns ; 
    end case ;

    -- Wait for 1 delta cycle, required if a wait is not in all case branches above
    wait for 0 ns ;
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
  
    TransmitLoop : loop 
      -- Find Transaction
      if TransmitFifo.Empty then
         WaitForToggle(TransmitRequestCount) ;
      end if ;
      
      -- Get Transaction
      (Data, ID, Dest, User, Last) := TransmitFifo.Pop ;
      
      -- Calculate Strb. 1 when data else 0  
      -- If Strb is unused it may be null range
      for i in Strb'range loop
        if is_x(Data(i*8)) then 
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
        "  TID: "       & to_hstring(ID) &
        "  TDest: "     & to_hstring(Dest) &
        "  TData: "     & to_hstring(Data) &
        "  TUser: "     & to_hstring(User) &
        "  TStrb: "     & to_string( Strb) &
        "  TKeep: "     & to_string( Keep) &
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

--
--  File Name:         AxiStreamTransmitter.vhd
--  Design Unit Name:  AxiStreamTransmitter
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      AXI Stream Transmitter Model
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
--
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

  use work.AxiStreamOptionsTypePkg.all ; 
  use work.Axi4CommonPkg.all ; 

entity AxiStreamTransmitter is
  generic (
    MODEL_ID_NAME  : string :="" ;
    DEFAULT_ID     : std_logic_vector ; 
    DEFAULT_DEST   : std_logic_vector ; 
    DEFAULT_USER   : std_logic_vector ; 
    DEFAULT_LAST   : natural := 0 ; 

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
    TLast     : out std_logic ; 

    -- Testbench Transaction Interface
    TransRec  : inout StreamRecType 
  ) ;
end entity AxiStreamTransmitter ;
architecture SimpleTransmitter of AxiStreamTransmitter is

  constant AXI_STREAM_DATA_WIDTH       : integer := TData'length ;
  constant AXI_STREAM_DATA_BYTE_WIDTH  : integer := integer(ceil(real(AXI_STREAM_DATA_WIDTH) / 8.0)) ;
  constant AXI_ID_WIDTH   : integer    := TID'length ;
  constant AXI_DEST_WIDTH : integer    := TDest'length ;

  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, to_lower(PathTail(AxiStreamTransmitter'PATH_NAME))) ;

  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ; 
  
  shared variable BurstFifo     : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 
  shared variable TransmitFifo  : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 

  signal TransmitRequestCount, TransmitDoneCount      : integer := 0 ;   


  -- Verification Component Configuration
  signal TransmitReadyTimeOut : integer := integer'right ; 

  signal ParamID         : TID'subtype   := DEFAULT_ID ;
  signal ParamDest       : TDest'subtype := DEFAULT_DEST ;
  signal ParamUser       : TUser'subtype := DEFAULT_USER;
  signal ParamLast       : natural       := DEFAULT_LAST ;
  signal LastOffsetCount : integer    := 0 ; 

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
    ProtocolID              <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Protocol Error", ID ) ;
    DataCheckID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Data Check", ID ) ;
    BusFailedID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": No response", ID ) ;
    wait ; 
  end process Initialize ;


  ------------------------------------------------------------
  --  Transaction Dispatcher
  --    Dispatches transactions to
  ------------------------------------------------------------
  TransactionDispatcher : process
    constant ID_LEN       : integer := TID'length ;
    constant DEST_LEN     : integer := TDest'length ;
    constant USER_LEN     : integer := TUser'length ;
    constant PARAM_LEN : integer := ID_LEN + DEST_LEN + USER_LEN + 1 ; 
    variable Data : std_logic_vector(TData'range) ; 
    variable Param : std_logic_vector(PARAM_LEN-1 downto 0) ;
--    alias Operation : StreamOperationType is TransRec.Operation ;
    variable BytesToSend, NumberTransfers : integer ; 
    variable PopValid : boolean ; 
    
    ------------------------------------------------------------
    impure function UpdateOptions (Param : std_logic_vector(PARAM_LEN-1 downto 0)) return std_logic_vector is
    ------------------------------------------------------------
      variable ResultParam : std_logic_vector(Param'range) ; 
      alias ID    : std_logic_vector(ID_LEN-1 downto 0) is ResultParam(PARAM_LEN-1 downto PARAM_LEN-ID_LEN) ;
      alias Dest  : std_logic_vector(DEST_LEN-1 downto 0) is ResultParam(DEST_LEN-1 + USER_LEN+1 downto USER_LEN+1) ;
      alias User  : std_logic_vector(USER_LEN-1 downto 0) is ResultParam(USER_LEN downto 1) ;
      alias Last  : std_logic is ResultParam(0) ;
    begin    
      ResultParam := Param ;
      
      if ID'Length > 0 and ID(ID'right) = '-' then
        ID := ParamID ; 
      end if ; 
      
      if Dest'length > 0 and Dest(Dest'right) = '-' then 
        Dest := ParamDest ; 
      end if ; 
      
      if User'length > 0 and User(User'right) = '-' then 
        User := ParamUser ; 
      end if ; 
      
      -- Calculate Last.  
      if Last = '-' then  -- use defaults
        if ParamLast <= 1 then 
          Last := '1' when ParamLast = 1 else '0' ; 
        else 
          -- generate last once every ParamLast cycles
          Last := '1' when ((TransmitRequestCount+1) - LastOffsetCount) mod ParamLast = 0 else '0' ; 
        end if ; 
      end if ; 
      return ResultParam ; 
    end function UpdateOptions ; 
    
  begin
    WaitForTransaction(
       Clk      => Clk,
       Rdy      => TransRec.Rdy,
       Ack      => TransRec.Ack
    ) ;

    case TransRec.Operation is
      when WAIT_FOR_TRANSACTION =>
        if TransmitRequestCount /= TransmitDoneCount then 
          wait until TransmitRequestCount = TransmitDoneCount ;
        end if ; 

      when WAIT_FOR_CLOCK =>
        WaitForClock(Clk, TransRec.IntToModel) ;

      when GET_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= TransmitDoneCount ;
--        wait until Clk = '1' ;
        wait for 0 ns ; 
    
      when GET_ALERTLOG_ID =>
        TransRec.IntFromModel <= integer(ModelID) ;
--        wait until Clk = '1' ;
        wait for 0 ns ; 

      when SEND | SEND_ASYNC =>
        Data   := FromTransaction(TransRec.DataToModel, Data'length) ;
        Param  := UpdateOptions(FromTransaction(TransRec.ParamToModel, Param'length)) ;
        TransmitFifo.Push(Data & Param) ; 
        Increment(TransmitRequestCount) ;
        wait for 0 ns ; 
        if IsBlocking(TransRec.Operation) then 
          wait until TransmitRequestCount = TransmitDoneCount ;
        end if ; 

      when SEND_BURST | SEND_BURST_ASYNC =>
        BytesToSend := TransRec.IntToModel ;
        NumberTransfers := integer(ceil(real(BytesToSend) / real(AXI_STREAM_DATA_BYTE_WIDTH))) ;
        TransmitRequestCount <= TransmitRequestCount + NumberTransfers ; 
        Param  := UpdateOptions(FromTransaction(TransRec.ParamToModel, Param'length)) ;
        while BytesToSend > 0 loop
          PopWord(BurstFifo, PopValid, Data, BytesToSend) ; 
          AlertIfNot(ModelID, PopValid, "BurstFifo Empty during burst transfer", FAILURE) ; 
          Param(0) := '1' when BytesToSend = 0 else '0' ;  -- TLast
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
            
          when SET_ID =>                      
            ParamID         <= FromTransaction(TransRec.ParamToModel, ParamID'length) ;
            
          when SET_DEST => 
            ParamDest       <= FromTransaction(TransRec.ParamToModel, ParamDest'length) ;
            
          when SET_USER =>
            ParamUser       <= FromTransaction(TransRec.ParamToModel, ParamUser'length) ;
            
          when SET_LAST =>
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
            
          when SET_ID =>                      
            TransRec.ParamFromModel <= ToTransaction(ParamID, TransRec.ParamFromModel'length) ;
            
          when SET_DEST => 
            TransRec.ParamFromModel <= ToTransaction(ParamDest, TransRec.ParamFromModel'length) ;
            
          when SET_USER =>
            TransRec.ParamFromModel <= ToTransaction(ParamUser, TransRec.ParamFromModel'length) ;
            
          when SET_LAST =>
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
    end loop TransmitLoop ; 
  end process TransmitHandler ;


end architecture SimpleTransmitter ;

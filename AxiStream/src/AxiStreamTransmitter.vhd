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
--    01/2020   2020.01    Updated license notice
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

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;
  
library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

  use work.AxiStreamOptionsTypePkg.all ; 
  use work.Axi4CommonPkg.all ; 

entity AxiStreamTransmitter is
  generic (
    DEFAULT_ID     : std_logic_vector ; 
    DEFAULT_DEST   : std_logic_vector ; 
    DEFAULT_USER   : std_logic_vector ; 

    tperiod_Clk     : time := 10 ns ;
    
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

  constant AXI_STREAM_DATA_WIDTH : integer := TData'length ;
  constant AXI_ID_WIDTH : integer := TID'length ;
  constant AXI_DEST_WIDTH : integer := TDest'length ;

  constant MODEL_INSTANCE_NAME : string := 
      PathTail(to_lower(AxiStreamTransmitter'PATH_NAME)) & " AxiStreamTransmitter" ;

  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ; 
  
  shared variable TransmitFifo     : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 

  signal TransmitRequestCount, TransmitDoneCount      : integer := 0 ;   

  signal TransmitReadyTimeOut : integer := integer'right ; 

  signal ID      : TID'subtype := DEFAULT_ID ;
  signal Dest    : TDest'subtype := DEFAULT_DEST ;
  signal User    : TUser'subtype := DEFAULT_USER;

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
    variable Data : TData'subtype ; 
--    variable Operation : TransRec.Operation'subtype ;
    variable Operation : StreamOperationType ;
  begin
    WaitForTransaction(
       Clk      => Clk,
       Rdy      => TransRec.Rdy,
       Ack      => TransRec.Ack
    ) ;
    
    Operation := TransRec.Operation ; 

    case Operation is
      when SEND =>
        Data     := FromTransaction(TransRec.DataToModel, Data'length) ;
        TransmitFifo.Push(Data) ; 
        Increment(TransmitRequestCount) ;
        WaitForToggle(TransmitDoneCount) ;
        wait for 0 ns ; 
      
      when WAIT_FOR_CLOCK =>
        WaitForClock(Clk, TransRec.IntToModel) ;

      when GET_ALERTLOG_ID =>
        TransRec.IntFromModel <= integer(ModelID) ;
        wait until Clk = '1' ;

      when GET_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= TransmitDoneCount ;
        wait until Clk = '1' ;

      when SET_MODEL_OPTIONS =>
      
        case AxiStreamOptionsType'val(TransRec.Options) is
          when TRANSMIT_READY_TIME_OUT =>       
            TransmitReadyTimeOut      <= FromTransaction(TransRec.DataToModel) ; 
            
          when SET_ID =>                      
            ID       <= FromTransaction(TransRec.DataToModel, ID'length) ;
            -- IdSet    <= TRUE ; 
            
          when SET_DEST => 
            Dest     <= FromTransaction(TransRec.DataToModel, Dest'length) ;
            -- DestSet  <= TRUE ; 
            
          when SET_USER =>
            User     <= FromTransaction(TransRec.DataToModel, User'length) ;
            -- UserSet  <= TRUE ; 
            
          when others =>
            Alert(ModelID, "SetOptions, Unimplemented Option: " & to_string(AxiStreamOptionsType'val(TransRec.Options)), FAILURE) ;
            wait for 0 ns ; 
        end case ;

      -- The End -- Done  
      when others =>
        Alert(ModelID, "Unimplemented Transaction: " & to_string(Operation), FAILURE) ;
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
    variable ID   :   TID'subtype := (others => '0') ;
    variable Dest : TDest'subtype := (others => '0') ;
    variable User : TUser'subtype := (others => '0') ;
    variable Data : TData'subtype := (others => '1') ;
    variable Strb : TStrb'subtype := (others => '1') ;
    variable Keep : TKeep'subtype := (others => '1') ;
  begin
    -- Initialize
    TValid  <= '0' ;
    TID     <= (TID'range => 'X') ;
    TDest   <= (TDest'range => 'X') ;
    TUser   <= (TUser'range => 'X') ;
    TData   <= (TData'range => 'X') ;
    TStrb   <= (TStrb'range => 'X') ;
    TKeep   <= (TKeep'range => 'X') ;
    TLast   <= '0' ; 
  
    TransmitLoop : loop 
      -- Find Transaction
      if TransmitFifo.Empty then
         WaitForToggle(TransmitRequestCount) ;
      end if ;
      
      -- Get Transaction
      -- (ID, Dest, User, Data, Strb, Keep) := TransmitFifo.Pop ;
      Data := TransmitFifo.Pop ;

      -- Do Transaction
      TID     <= ID   after tpd_Clk_tid ;
      TDest   <= Dest after tpd_Clk_TDest ;
      TUser   <= User after tpd_Clk_TUser ;
      TData   <= Data after tpd_Clk_TData ;
      TStrb   <= Strb after tpd_Clk_TStrb ;
      TKeep   <= Keep after tpd_Clk_TKeep ;

      Log(ModelID, 
        "Axi Stream Send." &
        "  TID: "       & to_hstring(ID) &
        "  TDest: "     & to_hstring(Dest) &
        "  TData: "     & to_hstring(Data) &
        "  TStrb: "     & to_string( Strb) &
        "  TKeep: "     & to_string( Keep) &
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

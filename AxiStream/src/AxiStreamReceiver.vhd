--
--  File Name:         AxiStreamReceiver.vhd
--  Design Unit Name:  AxiStreamReceiver
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
--    05/2018   2018.05    First Release
--    05/2019   2019.05    Removed generics for DEFAULT_ID, DEFAULT_DEST, DEFAULT_USER
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

entity AxiStreamReceiver is
  generic (
    tperiod_Clk     : time := 10 ns ;
    
    tpd_Clk_TReady : time := 2 ns  
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
    TLast     : in  std_logic ; 

    -- Testbench Transaction Interface
    TransRec  : inout StreamRecType 
  ) ;
end entity AxiStreamReceiver ;
architecture SimpleMaster of AxiStreamReceiver is

  constant AXI_STREAM_DATA_WIDTH : integer := TData'length ;
  constant AXI_ID_WIDTH : integer := TID'length ;
  constant AXI_DEST_WIDTH : integer := TDest'length ;

  constant MODEL_INSTANCE_NAME : string := 
      PathTail(to_lower(AxiStreamReceiver'PATH_NAME)) & " AxiStreamReceiver" ;

  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ; 
  
  shared variable ReceiveFifo : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 

  signal ReceiveCount : integer := 0 ;   

  signal ReceiveReadyBeforeValid : boolean := TRUE ; 
  signal ReceiveReadyDelayCycles : integer := 0 ;

--!  For future checking
--  signal ID      : TID'subtype   := (others => '0') ;
--  signal Dest    : TDest'subtype := (others => '0') ;
--  signal User    : TUser'subtype := (others => '0') ;
--  signal ID      : TID'subtype   := DEFAULT_ID ;
--  signal Dest    : TDest'subtype := DEFAULT_DEST ;
--  signal User    : TUser'subtype := DEFAULT_USER;

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
      when GET | TRY_GET =>
        if ReceiveFifo.empty and  Operation = TRY_GET then
          -- Return if no data
          TransRec.BoolToModel <= FALSE ; 
          wait for 0 ns ; 
        else
          -- Get data
          TransRec.BoolToModel <= TRUE ; 
          if ReceiveFifo.empty then 
            -- Wait for data
            WaitForToggle(ReceiveCount) ;
          end if ; 
          -- Put Data into record
          -- (ID, Dest, User, Data, Strb, Keep) := ReceiveFifo.pop ;
          Data := ReceiveFifo.pop ;
          TransRec.DataFromModel  <= ToTransaction(Data, TransRec.DataFromModel'length) ; 
          wait for 0 ns ; 
        end if ; 
      
      when WAIT_FOR_CLOCK =>
        WaitForClock(Clk, TransRec.IntToModel) ;

      when GET_ALERTLOG_ID =>
        TransRec.IntFromModel <= integer(ModelID) ;
        wait until Clk = '1' ;

      when GET_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= ReceiveCount ;
        wait until Clk = '1' ;

      when SET_MODEL_OPTIONS =>
      
        case AxiStreamOptionsType'val(TransRec.Options) is

          when RECEIVE_READY_BEFORE_VALID =>       
            ReceiveReadyBeforeValid <= TransRec.DataToModel(0) = '0' ; 

          when RECEIVE_READY_DELAY_CYCLES =>       
            ReceiveReadyDelayCycles <= FromTransaction(TransRec.DataToModel) ;
    
--! Currently not used    
--          when SET_ID =>                      
--            ID       <= FromTransaction(TransRec.DataToModel, ID'length) ;
--            -- IdSet    <= TRUE ; 
--            
--          when SET_DEST => 
--            Dest     <= FromTransaction(TransRec.DataToModel, Dest'length) ;
--            -- DestSet  <= TRUE ; 
--            
--          when SET_USER =>
--            User     <= FromTransaction(TransRec.DataToModel, User'length) ;
--            -- UserSet  <= TRUE ; 

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
  --  ReceiveHandler
  --    Execute Write Address Transactions
  ------------------------------------------------------------
  ReceiveHandler : process
  begin
    -- Initialize
    TReady  <= '0' ;
  
    ReceiveLoop : loop 
      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => TValid,
        Ready                   => TReady,
        ReadyBeforeValid        => ReceiveReadyBeforeValid,
        ReadyDelayCycles        => ReceiveReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_TReady
      ) ;
            
      -- capture address, prot
      ReceiveFifo.push(TData) ;
      
      -- Log this operation
      Log(ModelID, 
        "AXI Receiver receive." &
        "  TData: "  & to_hstring(TData) &
        "  Operation# " & to_string(ReceiveCount + 1),
        INFO
      ) ;

      -- Signal completion
      increment(ReceiveCount) ;
      wait for 0 ns ;
    end loop ReceiveLoop ; 
  end process ReceiveHandler ;


end architecture SimpleMaster ;

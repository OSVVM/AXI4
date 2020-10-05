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
    MODEL_ID_NAME  : string :="" ;
    tperiod_Clk    : time := 10 ns ;
    
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
architecture behavioral of AxiStreamReceiver is
  constant AXI_STREAM_DATA_WIDTH : integer := TData'length ;
  constant AXI_STREAM_DATA_BYTE_WIDTH : integer := integer(ceil(real(AXI_STREAM_DATA_WIDTH) / 8.0)) ;
  constant AXI_ID_WIDTH : integer := TID'length ;
  constant AXI_DEST_WIDTH : integer := TDest'length ;

  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, to_lower(PathTail(AxiStreamReceiver'PATH_NAME))) ;

  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ; 
  
  shared variable BurstFifo     : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 
  shared variable ReceiveFifo   : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 

  signal ReceiveCount : integer := 0 ;   
  signal ReceiveByteCount, TransferByteCount : integer := 0 ;   

  signal ReceiveReadyBeforeValid : boolean := TRUE ; 
  signal ReceiveReadyDelayCycles : integer := 0 ;

--!  For future checking
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
--    alias Operation : StreamOperationType is TransRec.Operation ;
    variable Data,  ExpectedData  : std_logic_vector(TData'range) ; 
    variable Param, ExpectedParam : std_logic_vector(PARAM_LENGTH-1 downto 0) ;
    variable BurstByteCount : integer ; 
    variable BurstBoundary  : std_logic ; 
    function param_to_string(Param : std_logic_vector) return string is 
      alias aParam : std_logic_vector(Param'length-1 downto 0) ;
      alias ID   : std_logic_vector(ID_LEN-1 downto 0)   is aParam(PARAM_LENGTH-1 downto PARAM_LENGTH-ID_LEN);
      alias Dest : std_logic_vector(DEST_LEN-1 downto 0) is aParam(DEST_LEN+USER_LEN downto USER_LEN+1);
      alias User : std_logic_vector(USER_LEN-1 downto 0) is aParam(USER_LEN downto 1) ;
      alias Last : std_logic is Param(0) ;
    begin
      return         
        "  TID: "       & to_hstring(ID) &
        "  TDest: "     & to_hstring(Dest) &
        "  TUser: "     & to_hstring(User) & 
        "  TLast: "     & to_string(Last) ; 
    end function param_to_string ; 

      
  begin
    WaitForTransaction(
       Clk      => Clk,
       Rdy      => TransRec.Rdy,
       Ack      => TransRec.Ack
    ) ;
    
    case TransRec.Operation is
--!!  Get Pending Get Count = ReceiveFifo.GetFifoCount
      when WAIT_FOR_TRANSACTION =>
        -- Receiver either blocks or does "try" operations
        -- There are no operations in flight   
        -- There can be values received but not Get yet.
        -- Cannot block on those.
        wait for 0 ns ; 

      when GET_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= ReceiveCount ;
        wait until Clk = '1' ;

      when WAIT_FOR_CLOCK =>
        WaitForClock(Clk, TransRec.IntToModel) ;

      when GET_ALERTLOG_ID =>
        TransRec.IntFromModel <= integer(ModelID) ;
        wait until Clk = '1' ;    
    
      when GET | TRY_GET | CHECK | TRY_CHECK =>
        if ReceiveFifo.empty and  IsTry(Operation) then
          -- Return if no data
          TransRec.BoolFromModel <= FALSE ; 
          wait for 0 ns ; 
        else 
          -- Get data
          TransRec.BoolFromModel <= TRUE ;  ; 
          if ReceiveFifo.empty then 
            -- Wait for data
            WaitForToggle(ReceiveCount) ;
          end if ; 
          -- Put Data and Parameters into record
          (Data, Param, BurstBoundary) := ReceiveFifo.pop ;
          TransRec.DataFromModel  <= ToTransaction(Data, TransRec.DataFromModel'length) ; 
          TransRec.ParamFromModel <= ToTransaction(Param, TransRec.ParamFromModel'length) ; 
          
          DispatcherReceiveCount := DispatcherReceiveCount + 1 ; 
          
          -- Param: (TID & TDest & TUser & TLast & BurstBoundary) 
          if BurstBoundary = '1' then 
            BurstTransferCount := BurstTransferCount + 1 ; 
          end if ; 
          
          if IsCheck(Operation) then 
            ExpectedData  := std_logic_vector(TransactionRec.DataToModel) ;
            ExpectedParam := std_logic_vector(TransactionRec.ParamToModel) ;
            AffirmIf( ModelID, 
                Data ?= ExpectedData and Param ?= ExpectedParam,
                "Operation# " & to_string (DispatcherReceiveCount) & " " & 
                " Received.  Data: " & to_hstring(Data) &         param_to_string(Param),
                " Expected.  Data: " & to_hstring(ExpectedData) & param_to_string(ExpectedParam) &  
                TransactionRec.BoolToModel or IsLogEnabled(ModelID, INFO) ) ;
            ) ;
          else 
            Log(ModelID, 
              "Word Receive. " &
              " Operation# " & to_string (DispatcherReceiveCount) &  " " & 
              " Data: "     & to_hstring(Data) & param_to_string(Param),
              INFO, TransactionRec.BoolToModel 
            ) ;
          end if ; 
        end if ; 

      when GET_BURST | TRY_GET_BURST =>
        if (BurstReceiveCount - BurstTransferCount) = 0 and IsTry(Operation) then
          -- Return if no data
          TransRec.BoolFromModel <= FALSE ; 
          wait for 0 ns ; 
        else
          -- Get data
          TransRec.BoolFromModel <= TRUE ;  ; 
          if (BurstReceiveCount - BurstTransferCount) = 0 then 
            -- Wait for data
            WaitForToggle(BurstReceiveCount) ;
          end loop ; 
          -- ReceiveFIFO: (TData & TID & TDest & TUser & TLast) 
          DropUndriven   := TransRec.BoolToModel ; 
          BurstByteCount := 0 ; 
          loop
            (Data, Param, BurstBoundary) := ReceiveFifo.pop ;
            PushWord(BurstFifo, Data, DropUndriven) ; 
            BurstByteCount := BurstByteCount + CountBytes(Data, DropUndriven) ;
            exit when BurstBoundary = '1' ; 
          end loop ; 
          BurstTransferCount      := BurstTransferCount + 1 ; 
          TransRec.IntFromModel   <= BurstByteCount ; 
          TransRec.DataFromModel  <= ToTransaction(Data, TransRec.DataFromModel'length) ; 
          TransRec.ParamFromModel <= ToTransaction(Param, TransRec.ParamFromModel'length) ; 
          
          DispatcherReceiveCount := DispatcherReceiveCount + 1 ; -- Operation or #Words Transfered based?
          Log(ModelID, 
            "Burst Receive. " &
            " Operation# " & to_string (DispatcherReceiveCount) &  " " & 
            " Last Data: "     & to_hstring(Data) & param_to_string(Param),
            INFO, TransactionRec.BoolToModel or IsLogEnabled(ModelID, PASSED) 
          ) ;
          wait for 0 ns ; 
        end if ; 
        
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
    variable Data : std_logic_vector(TData'range) ; 
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
      
      Data := TData ; 
      -- Either Strb or Keep can have a null range
      -- Make Data a Z if Strb(i) is position byte
      for i in TStrb'range loop
        if TStrb(i) = '0' then
          Data(i*8 + 7 downto i*8) := (others => 'Z') ;
        end if; 
      end loop ;
      -- Make Data a U if Keep(i) is null byte
      for i in TKeep'range loop
        if TKeep(i) = '0' then
          Data(i*8 + 7 downto i*8) := (others => 'U') ;
        end if; 
      end loop ;
      
      Last := to_01(TLast) ; 
      BurstBoundary := Last when ID ?= LastID and Dest ?= LastDest else '1' ;
      
      -- capture interface values
      ReceiveFifo.push(Data & TID & TDest & TUser & Last & BurstBoundary) ;
      if BurstBoundary = '1' then 
        BurstReceiveCount := BurstReceiveCount + 1 ; 
      end if ; 
      
      -- Log this operation
      Log(ModelID, 
        "Axi Stream Receive." &
        "  TData: "     & to_hstring(TData) &
        "  TStrb: "     & to_string (TStrb) &
        "  TKeep: "     & to_string (TKeep) &
        "  TID: "       & to_hstring(TID) &
        "  TDest: "     & to_hstring(TDest) &
        "  TUser: "     & to_hstring(TUser) &
        "  TLast: "     & to_string (TLast) &
        "  Operation# " & to_string (ReceiveCount + 1),  
        DEBUG
      ) ;

      -- Signal completion
      increment(ReceiveCount) ;
      wait for 0 ns ;
    end loop ReceiveLoop ; 
  end process ReceiveHandler ;


end architecture behavioral ;

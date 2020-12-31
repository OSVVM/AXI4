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
--    Date       Version    Description
--    05/2018    2018.05    First Release
--    05/2019    2019.05    Removed generics for DEFAULT_ID, DEFAULT_DEST, DEFAULT_USER
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

  use work.AxiStreamOptionsPkg.all ; 
  use work.Axi4CommonPkg.all ; 
  use work.AxiStreamTbPkg.all ;

entity AxiStreamReceiver is
  generic (
    MODEL_ID_NAME  : string :="" ;
    INIT_ID        : std_logic_vector := "" ; 
    INIT_DEST      : std_logic_vector := "" ; 
    INIT_USER      : std_logic_vector := "" ; 
    INIT_LAST      : natural := 0 ; 
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
  
  -- Burst Interface
  -- Access via external names
  shared variable BurstFifo     : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 

  -- Derive AXI interface properties from interface signals
  constant AXI_STREAM_DATA_WIDTH   : integer := TData'length ;

end entity AxiStreamReceiver ;
architecture behavioral of AxiStreamReceiver is
  constant ID_LEN       : integer := TID'length ;
  constant DEST_LEN     : integer := TDest'length ;
  constant USER_LEN     : integer := TUser'length ;
  constant PARAM_LENGTH : integer := ID_LEN + DEST_LEN + USER_LEN + 1 ;
  constant USER_RIGHT   : integer := 1 ; 
  constant DEST_RIGHT   : integer := USER_RIGHT + USER_LEN ; 
  constant ID_RIGHT     : integer := DEST_RIGHT + DEST_LEN ; 

  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME'length > 0, MODEL_ID_NAME, to_lower(PathTail(AxiStreamReceiver'PATH_NAME))) ;

  signal ModelID, ProtocolID, DataCheckID, BusFailedID, BurstFifoID : AlertLogIDType ; 
  
  shared variable ReceiveFifo   : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 

  signal ReceiveCount : integer := 0 ;   
  signal ReceiveByteCount, TransferByteCount : integer := 0 ;   
  
  signal BurstReceiveCount     : integer := 0 ; 

  -- Verification Component Configuration
  signal ReceiveReadyBeforeValid : boolean := TRUE ; 
  signal ReceiveReadyDelayCycles : integer := 0 ;

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
    DataCheckID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Data Check", ID ) ;
    BusFailedID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": No response", ID ) ;
    BurstFifo.SetAlertLogID(MODEL_INSTANCE_NAME & ": BurstFifo", ID) ;
    BurstFifoID             <= BurstFifo.GetAlertLogID ; 
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
    variable DispatcherReceiveCount : integer := 0 ; 
    variable BurstTransferCount     : integer := 0 ; 
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
--!!  Get Pending Get Count = ReceiveFifo.GetFifoCount
        TransRec.IntFromModel <= ReceiveCount ;
        wait for 0 ns ; 

      when GET_ALERTLOG_ID =>
        TransRec.IntFromModel <= integer(ModelID) ;
        wait for 0 ns ; 
    
      when SET_BURST_MODE =>                      
        BurstFifoMode       <= TransRec.IntToModel ;
        BurstFifoByteMode   <= (TransRec.IntToModel = STREAM_BURST_BYTE_MODE) ;
            
      when GET_BURST_MODE =>                      
        TransRec.IntToModel <= BurstFifoMode ;

      when GET | TRY_GET | CHECK | TRY_CHECK =>
        if ReceiveFifo.empty and  IsTry(Operation) then
          -- Return if no data
          TransRec.BoolFromModel  <= FALSE ; 
          TransRec.DataFromModel  <= (others => '0') ; 
          TransRec.ParamFromModel <= (others => '0') ;  
          wait for 0 ns ; 
        else 
          -- Get data
          TransRec.BoolFromModel <= TRUE ; 
          if ReceiveFifo.empty then 
            -- Wait for data
            WaitForToggle(ReceiveCount) ;
          end if ; 
          -- Put Data and Parameters into record
          (Data, Param, BurstBoundary) := ReceiveFifo.pop ;
          if BurstBoundary = '1' then 
            -- At BurstBoundary, there is always another word that 
            -- follows that triggered the Burst Boundary
            (Data, Param, BurstBoundary) := ReceiveFifo.pop ;
            BurstTransferCount := BurstTransferCount + 1 ; 
          end if ; 
          TransRec.DataFromModel  <= ToTransaction(Data, TransRec.DataFromModel'length) ; 
          TransRec.ParamFromModel <= ToTransaction(Param, TransRec.ParamFromModel'length) ; 
          
          DispatcherReceiveCount := DispatcherReceiveCount + 1 ; 
          
          -- Param: (TID & TDest & TUser & TLast) 
          if Param(0) = '1' then 
            BurstTransferCount := BurstTransferCount + 1 ; 
          end if ; 
          
          if IsCheck(Operation) then 
            ExpectedData  := FromTransaction(TransRec.DataToModel, ExpectedData'length) ;
            ExpectedParam  := UpdateOptions(
                        Param      => FromTransaction(TransRec.ParamToModel, ExpectedParam'length),
                        ParamID    => ParamID, 
                        ParamDest  => ParamDest,
                        ParamUser  => ParamUser,
                        ParamLast  => ParamLast,           
                        Count      => ReceiveCount - LastOffsetCount
                      ) ;
            AffirmIf( DataCheckID, 
--                (Data ?= ExpectedData and Param ?= ExpectedParam) = '1',
                (MetaMatch(Data, ExpectedData) and MetaMatch(Param, ExpectedParam)),
                "Operation# " & to_string (DispatcherReceiveCount) & " " & 
                " Received.  Data: " & to_hstring(Data) &         param_to_string(Param),
                " Expected.  Data: " & to_hstring(ExpectedData) & param_to_string(ExpectedParam), 
                TransRec.BoolToModel or IsLogEnabled(ModelID, INFO) 
              ) ;
          else 
            Log(ModelID, 
              "Word Receive. " &
              " Operation# " & to_string (DispatcherReceiveCount) &  " " & 
              " Data: "     & to_hstring(Data) & param_to_string(Param),
              INFO, TransRec.BoolToModel 
            ) ;
          end if ; 
        end if ; 

      when GET_BURST | TRY_GET_BURST =>
        if (BurstReceiveCount - BurstTransferCount) = 0 and IsTry(Operation) then
          -- Return if no data
          TransRec.BoolFromModel  <= FALSE ; 
          TransRec.DataFromModel  <= (others => '0') ; 
          TransRec.ParamFromModel <= (others => '0') ;  
          wait for 0 ns ; 
        else
          -- Get data
          TransRec.BoolFromModel <= TRUE ;
          if (BurstReceiveCount - BurstTransferCount) = 0 then 
            -- Wait for data
            WaitForToggle(BurstReceiveCount) ;
          end if ; 
          -- ReceiveFIFO: (TData & TID & TDest & TUser & TLast) 
          FifoWordCount := 0 ; 
          loop
            (PopData, PopParam, BurstBoundary) := ReceiveFifo.pop ;
            -- BurstBoundary indication does not contain data for 
            -- this transaction so exit
            exit when BurstBoundary = '1' ;  
            Data  := PopData ; 
            Param := PopParam ; 
            case BurstFifoMode is
              when STREAM_BURST_BYTE_MODE => 
                PushWord(BurstFifo, Data, DropUndriven) ; 
                FifoWordCount := FifoWordCount + CountBytes(Data, DropUndriven) ;
            
              when STREAM_BURST_WORD_MODE => 
                BurstFifo.push(Data) ;
                FifoWordCount := FifoWordCount + 1 ;
              
              when STREAM_BURST_WORD_PARAM_MODE =>
                BurstFifo.push(Data & Param(USER_LEN downto 1)) ;
                FifoWordCount := FifoWordCount + 1 ;
                              
              when others => 
                Alert(ModelID, "BurstFifoMode: Invalid Mode: " & to_string(BurstFifoMode)) ;
            end case ; 
            exit when Param(0) = '1' ; 
          end loop ; 
        
          BurstTransferCount      := BurstTransferCount + 1 ; 
          TransRec.IntFromModel   <= FifoWordCount ; 
          TransRec.DataFromModel  <= ToTransaction(Data, TransRec.DataFromModel'length) ; 
          TransRec.ParamFromModel <= ToTransaction(Param, TransRec.ParamFromModel'length) ; 
          
          DispatcherReceiveCount := DispatcherReceiveCount + 1 ; -- Operation or #Words Transfered based?
          Log(ModelID, 
            "Burst Receive. " &
            " Operation# " & to_string (DispatcherReceiveCount) &  " " & 
            " Last Data: "     & to_hstring(Data) & param_to_string(Param),
            INFO, TransRec.BoolToModel or IsLogEnabled(ModelID, PASSED) 
          ) ;
          wait for 0 ns ; 
        end if ; 
        
      when CHECK_BURST | TRY_CHECK_BURST =>
        if (BurstReceiveCount - BurstTransferCount) = 0 and IsTry(Operation) then
          -- Return if no data
          TransRec.BoolFromModel  <= FALSE ; 
          TransRec.DataFromModel  <= (others => '0') ; 
          TransRec.ParamFromModel <= (others => '0') ;  
          wait for 0 ns ; 
        else
          -- Get data
          TransRec.BoolFromModel <= TRUE ;
          if (BurstReceiveCount - BurstTransferCount) = 0 then 
            -- Wait for data
            WaitForToggle(BurstReceiveCount) ;
          end if ; 
          CheckWordCount := TransRec.IntToModel ; 
          FifoWordCount  := 0 ; 
          loop
           -- ReceiveFIFO: (TData & TID & TDest & TUser & TLast) 
           (PopData, PopParam, BurstBoundary) := ReceiveFifo.pop ;
            -- BurstBoundary indication does not contain data for 
            -- this transaction so exit
            exit when BurstBoundary = '1' ;  
            Data  := PopData ; 
            Param := PopParam ; 
            case BurstFifoMode is
              when STREAM_BURST_BYTE_MODE => 
                CheckWord(BurstFifo, Data, DropUndriven) ; 
                FifoWordCount := FifoWordCount + CountBytes(Data, DropUndriven) ;
            
              when STREAM_BURST_WORD_MODE => 
                BurstFifo.Check(Data) ;
                FifoWordCount := FifoWordCount + 1 ;
              
              when STREAM_BURST_WORD_PARAM_MODE =>
                -- Checking done here to differentiate data from user
                (ExpectedData, ExpectedUser) := BurstFifo.Pop ; 
                AffirmIfEqual(BurstFifoID, Data, ExpectedData, "Data") ;
                AffirmIfEqual(BurstFifoID, Param(USER_LEN downto 1), ExpectedUser, "User") ;
--                BurstFifo.Check(Data & Param(USER_LEN downto 1)) ;
                FifoWordCount := FifoWordCount + 1 ;
                              
              when others => 
                Alert(ModelID, "BurstFifoMode: Invalid Mode: " & to_string(BurstFifoMode)) ;
            end case ; 
            exit when Param(0) = '1' ; 
            exit when FifoWordCount >= CheckWordCount ; 
          end loop ; 
          
          Log(ModelID, 
            "Burst Check. " &
            " Operation# " & to_string (DispatcherReceiveCount) &  " " & 
            " Last Data: "     & to_hstring(Data) & param_to_string(Param),
            INFO, TransRec.BoolToModel or IsLogEnabled(ModelID, PASSED) 
          ) ;
          if not (BurstBoundary = '1' or Param(0) = '1') then 
            Log(ModelID, 
              "Burst Check finished without Last or BurstBoundary - normal when next word is burst boundary",
              DEBUG 
            ) ;
          end if ; 
          ExpectedParam  := UpdateOptions(
                      Param      => FromTransaction(TransRec.ParamToModel, ExpectedParam'length),
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
          
          BurstTransferCount      := BurstTransferCount + 1 ; 
          TransRec.IntFromModel   <= FifoWordCount ; 
          TransRec.DataFromModel  <= ToTransaction(Data, TransRec.DataFromModel'length) ; 
          TransRec.ParamFromModel <= ToTransaction(Param, TransRec.ParamFromModel'length) ; 
          
          DispatcherReceiveCount := DispatcherReceiveCount + 1 ; -- Operation or #Words Transfered based?
          wait for 0 ns ; 
        end if ; 
        
      when SET_MODEL_OPTIONS =>
      
        case AxiStreamOptionsType'val(TransRec.Options) is

          when RECEIVE_READY_BEFORE_VALID =>       
            ReceiveReadyBeforeValid <= TransRec.BoolToModel ; 

          when RECEIVE_READY_DELAY_CYCLES =>       
            ReceiveReadyDelayCycles <= TransRec.IntToModel ;
    
          when DROP_UNDRIVEN =>                      
            DropUndriven    := TransRec.BoolToModel ;
            
          when DEFAULT_ID =>                      
            ParamID         <= FromTransaction(TransRec.ParamToModel, ParamID'length) ;
            
          when DEFAULT_DEST => 
            ParamDest       <= FromTransaction(TransRec.ParamToModel, ParamDest'length) ;
            
          when DEFAULT_USER =>
            ParamUser       <= FromTransaction(TransRec.ParamToModel, ParamUser'length) ;
            
          when DEFAULT_LAST =>
            ParamLast       <= TransRec.IntToModel ;
            LastOffsetCount <= ReceiveCount ; 

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

          when DROP_UNDRIVEN =>                      
            TransRec.BoolFromModel <= DropUndriven ;
            
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
    variable Data           : std_logic_vector(TData'length-1 downto 0) ; 
    variable Last           : std_logic ; 
    variable BurstBoundary  : std_logic ; 
    variable LastID         : std_logic_vector(TID'range)   := (TID'range   => '-') ;
    variable LastDest       : std_logic_vector(TDest'range) := (TDest'range => '-') ;
    variable LastLast       : std_logic := '1' ; 
    alias Strb : std_logic_vector(TStrb'length-1 downto 0) is TStrb ; 
    alias Keep : std_logic_vector(TKeep'length-1 downto 0) is TKeep ; 
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
        tpd_Clk_Ready           => tpd_Clk_TReady,
        AlertLogID              => ModelID 
      ) ;         
            
      Data := to_x01(TData) ; 
      Last := to_01(TLast) ; 
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
      -- For first Word in Transfer, Drop leading bytes until TKeep(i) = '1'
      if LastLast = '1' then 
        for i in Keep'reverse_range loop 
          exit when Keep(i) = '1' ; 
          Data(i*8 + 7 downto i*8) := (others => '-') ;
        end loop ; 
      end if ; 
      -- For last Word in Transfer, Drop ending bytes until TKeep(i) = '1' 
      if Last = '1' then 
        for i in Keep'range loop 
          exit when Keep(i) = '1' ; 
          Data(i*8 + 7 downto i*8) := (others => '-') ;
        end loop ; 
      end if ; 

      if (TID /= LastID or TDest /= LastDest) and LastLast /= '1' then
        -- push a burst boundary word, only the Burst Boundary value matters
        ReceiveFifo.push(Data & TID & TDest & TUser & Last & '1') ;
        BurstReceiveCount <= BurstReceiveCount + 1 ; 
        if Last = '1' then
          wait for 0 ns ;  
        end if ; 
      end if ; 
--      BurstBoundary := '1' when (TID /= LastID or TDest /= LastDest) and LastLast /= '1' else '0' ;
      LastID   := TID ; 
      LastDest := TDest ;
      LastLast := Last ;
      -- capture this transaction
      ReceiveFifo.push(Data & TID & TDest & TUser & Last & '0') ;
      if Last = '1' then 
        BurstReceiveCount <= BurstReceiveCount + 1 ; 
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

--
--  File Name:         AxiStreamSlave.vhd
--  Design Unit Name:  AxiStreamSlave
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
--
--
-- Copyright 2108 SynthWorks Design Inc
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;
  
--  use work.Axi4LiteCommonTransactionPkg.all ; 
  use work.AxiStreamTransactionPkg.all ; 
  use work.Axi4CommonPkg.all ; 

entity AxiStreamSlave is
  generic (
    DEFAULT_ID     : std_logic_vector ; 
    DEFAULT_DEST   : std_logic_vector ; 
    DEFAULT_USER   : std_logic_vector ; 

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
    TransRec  : inout AxiStreamTransactionRecType 
  ) ;
end entity AxiStreamSlave ;
architecture SimpleMaster of AxiStreamSlave is

  constant AXI_STREAM_DATA_WIDTH : integer := TData'length ;
  constant AXI_ID_WIDTH : integer := TID'length ;
  constant AXI_DEST_WIDTH : integer := TDest'length ;

  constant MODEL_INSTANCE_NAME : string := 
      PathTail(to_lower(AxiStreamSlave'PATH_NAME)) & " AxiStreamSlave" ;

  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ; 
  
  shared variable ReceiveFifo : osvvm.ScoreboardPkg_slv.ScoreboardPType ; 

  signal ReceiveCount : integer := 0 ;   

  signal ReceiveReadyBeforeValid : boolean := TRUE ; 
  signal ReceiveReadyDelayCycles : integer := 0 ;

--  signal IdSet   : boolean := FALSE ; 
--  signal DestSet : boolean := FALSE ; 
--  signal UserSet : boolean := FALSE ; 
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
    TransRec.AlertLogID     <= ID ; 
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
    variable Operation : TransRec.Operation'subtype ;
    variable NoOpCycles : integer ;

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
          TransRec.ModelBool <= FALSE ; 
          wait for 0 ns ; 
        else
          -- Get data
          TransRec.ModelBool <= TRUE ; 
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
      
      when NO_OP =>
        NoOpCycles := FromTransaction(TransRec.DataToModel) ;
        wait for (NoOpCycles * tperiod_Clk) - 1 ns ;
        wait until Clk = '1' ;

      when GET_ERRORS =>
        -- Report and Get Errors
        print("") ;
        ReportNonZeroAlerts(AlertLogID => ModelID) ;
        TransRec.DataFromModel <= ToTransaction(GetAlertCount(AlertLogID => ModelID), TransRec.DataFromModel'length) ;
        wait until Clk = '1' ;

      when RECEIVE_READY_BEFORE_VALID =>       
        ReceiveReadyBeforeValid <= TransRec.DataToModel(0) = '0' ; 

      when RECEIVE_READY_DELAY_CYCLES =>       
        ReceiveReadyDelayCycles <= FromTransaction(TransRec.DataToModel) ;
        
      when SET_ID =>                      
        ID       <= FromTransaction(TransRec.DataToModel, ID'length) ;
        -- IdSet    <= TRUE ; 
        
      when SET_DEST => 
        Dest     <= FromTransaction(TransRec.DataToModel, Dest'length) ;
        -- DestSet  <= TRUE ; 
        
      when SET_USER =>
        User     <= FromTransaction(TransRec.DataToModel, User'length) ;
        -- UserSet  <= TRUE ; 
        
      -- The End -- Done  
        
      when others =>
        Alert(ModelID, "Unimplemented Transaction", FAILURE) ;
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
    variable ID   :   TID'subtype := (others => '0') ;
    variable Dest : TDest'subtype := (others => '0') ;
    variable User : TUser'subtype := (others => '0') ;
    variable Data : TData'subtype := (others => '1') ;
    variable Strb : TStrb'subtype := (others => '1') ;
    variable Keep : TKeep'subtype := (others => '1') ;
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
        "AXI Slave receive." &
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

--
--  File Name:         AxiStreamTransactionPkg.vhd
--  Design Unit Name:  AxiStreamTransactionPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms used by
--      OSVVM Axi Stream Transaction Based Models (aka: TBM, TLM, VVC)
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    05/2018   2018.05    Initial revision
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
  use ieee.math_real.all ;

library osvvm ;
    context osvvm.OsvvmContext ;

  use work.Axi4CommonPkg.all ; 
    
package AxiStreamTransactionPkg is

  -- Model AXI Lite Operations
  type AxiStreamUnresolvedOperationType is (
    --  bus operations
    SEND,            -- Master
    GET, TRY_GET,    -- Slave
    -- Model Directives
    NO_OP, 
    GET_ERRORS, 
    TRANSMIT_READY_TIME_OUT,
    RECEIVE_READY_BEFORE_VALID,
    RECEIVE_READY_DELAY_CYCLES,
    SET_ID,
    SET_DEST,
    SET_USER,
    THE_END
  ) ;
  type AxiStreamUnresolvedOperationVectorType is array (natural range <>) of AxiStreamUnresolvedOperationType ;
  -- alias resolved_max is maximum[ AxiStreamUnresolvedOperationVectorType return AxiStreamUnresolvedOperationType] ;
  -- Maximum is implicitly defined for any array type in VHDL-2008.   Function resolved_max is a fall back.
  function resolved_max ( s : AxiStreamUnresolvedOperationVectorType) return AxiStreamUnresolvedOperationType ;
  subtype AxiStreamOperationType is resolved_max AxiStreamUnresolvedOperationType ;


  -- Record creates a channel for communicating transactions to the model.
  type AxiStreamTransactionRecType is record
    Rdy                : bit_max ;
    Ack                : bit_max ;
    Operation          : AxiStreamOperationType ;
    DataToModel        : TransactionType ;
    DataFromModel      : TransactionType ;
    DataBytes          : integer_max ;
    AlertLogID         : resolved_max AlertLogIDType ;
    StatusMsgOn        : boolean_max ;
    ModelBool          : boolean_max ; 
  end record AxiStreamTransactionRecType ;

--!TODO add VHDL-2018 Interfaces

  ------------------------------------------------------------
  procedure Send (
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
             iData       : In    std_logic_vector ;
             StatusMsgOn : In    boolean := false
  ) ;

  ------------------------------------------------------------
  procedure Get (
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
    variable oData       : Out   std_logic_vector ;
             StatusMsgOn : In    boolean := false
  ) ;

  ------------------------------------------------------------
  procedure TryGet (
  -- Try to do a Get Transaction
  -- If data is available, get it and return available TRUE.  
  -- Otherwise Return Available FALSE.
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
    variable oData       : Out   std_logic_vector ;
    variable Available   : Out   boolean ;
             StatusMsgOn : In    boolean := false
  ) ;  
  
  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
    constant Option      : In    AxiStreamOperationType ;
    constant OptVal      : In    std_logic_vector
  ) ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
    constant Option      : In    AxiStreamOperationType ;
    constant OptVal      : In    integer
  ) ;

  ------------------------------------------------------------
  procedure NoOp (
  -- Directive:  Do nothing for NoOpCycles number of clocks
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
             NoOpCycles  : In    natural := 1
  ) ;

  ------------------------------------------------------------
  procedure GetErrors (
  -- Error reporting for testbenches that do not use AlertLogPkg
  -- Returns error count.  If an error count /= 0, also print it
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
    variable ErrCnt      : Out   natural
  ) ;


end package AxiStreamTransactionPkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body AxiStreamTransactionPkg is
  
  ------------------------------------------------------------
  function resolved_max ( s : AxiStreamUnresolvedOperationVectorType) return AxiStreamUnresolvedOperationType is
  ------------------------------------------------------------
  begin
    return maximum(s) ;
  end function resolved_max ; 


  ------------------------------------------------------------
  procedure Send (
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
             iData       : In    std_logic_vector ;
             StatusMsgOn : In    boolean := false
  ) is
    variable ByteCount : integer ;
  begin
    ByteCount := iData'length / 8 ;

    -- Parameter Checks
--    AlertIf(TransRec.AlertLogID, iData'length mod 8 /= 0, "Send, Data not on a byte boundary", FAILURE) ;
    -- AlertIf(TransRec.AlertLogID, iData'length > TransRec.AxiDataWidth, "Send, Data length too large", FAILURE) ;

    -- Put values in record
    TransRec.Operation                            <= SEND ;
    TransRec.DataToModel(iData'length-1 downto 0) <= ToTransaction(iData) ;
    TransRec.DataBytes                            <= ByteCount ;
    TransRec.StatusMsgOn                          <= StatusMsgOn ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
  end procedure Send ;
  

  ------------------------------------------------------------
  procedure Get (
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
    variable oData       : Out   std_logic_vector ;
             StatusMsgOn : In    boolean := false
  ) is
    variable ByteCount : integer ;
  begin
    ByteCount := oData'length / 8 ;

    -- Parameter Checks
--    AlertIf(TransRec.AlertLogID, oData'length mod 8 /= 0, "Master Read, Data not on a byte boundary", FAILURE) ;
--    AlertIf(TransRec.AlertLogID, oData'length > TransRec.AxiDataWidth, "Master Read, Data length to large", FAILURE) ;

    -- Put values in record
    TransRec.Operation          <= GET ;
    TransRec.DataBytes          <= ByteCount ;
    TransRec.StatusMsgOn        <= StatusMsgOn ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;

    oData := Reduce(FromTransaction(TransRec.DataFromModel), oData'Length) ;
  end procedure Get ;


  ------------------------------------------------------------
  procedure TryGet (
  -- Try to do a Get Transaction
  -- If data is available, get it and return available TRUE.  
  -- Otherwise Return Available FALSE.
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
    variable oData       : Out   std_logic_vector ;
    variable Available   : Out   boolean ;
             StatusMsgOn : In    boolean := false
  ) is
    variable ByteCount : integer ;
  begin
    ByteCount := oData'length / 8 ;

    -- Parameter Checks
-- Not all AxiStream Compatible interfaces are 32 bits
--    AlertIf(TransRec.AlertLogID, oData'length mod 8 /= 0, "Master Read, Data not on a byte boundary", FAILURE) ;
-- Not in the record currently
    -- AlertIf(TransRec.AlertLogID, oData'length > TransRec.AxiDataWidth, "Master Read, Data length to large", FAILURE) ;

    -- Put values in record
    TransRec.Operation          <= TRY_GET ;
    TransRec.DataBytes          <= ByteCount ;
    TransRec.StatusMsgOn        <= StatusMsgOn ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;

    oData := Reduce(FromTransaction(TransRec.DataFromModel), oData'Length) ;
    Available := TransRec.ModelBool ;
  end procedure TryGet ;  
  

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
    constant Option      : In    AxiStreamOperationType ;
    constant OptVal      : In    std_logic_vector
  )  is
  begin
    TransRec.Operation     <= Option ;
    TransRec.DataToModel(OptVal'left-1 downto 0) <= ToTransaction(OptVal) ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
  end procedure SetModelOptions ;
  
  
  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
    constant Option      : In    AxiStreamOperationType ;
    constant OptVal      : In    integer
  )  is
  begin
    TransRec.Operation     <= Option ;
    TransRec.DataToModel <= ToTransaction(OptVal, TransRec.DataToModel'length) ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
  end procedure SetModelOptions ;
  
  
  ------------------------------------------------------------
  procedure NoOp (
  -- Directive:  Do nothing for NoOpCycles number of clocks
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
             NoOpCycles  : In    natural := 1
  ) is
  begin
    TransRec.Operation     <= NO_OP ;
    TransRec.DataToModel   <= ToTransaction(NoOpCycles, TransRec.DataToModel'length);
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
  end procedure NoOp ;

  
  ------------------------------------------------------------
  procedure GetErrors (
  -- Error reporting for testbenches that do not use AlertLogPkg
  -- Returns error count.  If an error count /= 0, also print it
  ------------------------------------------------------------
    signal   TransRec    : InOut AxiStreamTransactionRecType ;
    variable ErrCnt      : Out   natural
  ) is
  begin
    TransRec.Operation     <= GET_ERRORS ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;

    -- Return Error Count
    ErrCnt := FromTransaction(TransRec.DataFromModel) ;
  end procedure GetErrors ;

end package body AxiStreamTransactionPkg ;
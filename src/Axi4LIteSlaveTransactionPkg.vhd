--
--  File Name:         Axi4LiteSlaveTransactionPkg.vhd
--  Design Unit Name:  Axi4LiteSlaveTransactionPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms used by
--      OSVVM Axi4 Transaction Based Models (aka: TBM, TLM, VVC)
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date       Version    Description
--    09/2017:   2017       Initial revision
--
--
-- Copyright 2017 SynthWorks Design Inc
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
  use ieee.math_real.all ;

library osvvm ;
    context osvvm.OsvvmContext ;

  use work.Axi4CommonPkg.all ; 
--  use work.Axi4LiteCommonTransactionPkg.all ; 

package Axi4LiteSlaveTransactionPkg is

  -- Model AXI Lite Operations
  type Axi4UnresolvedSlaveOperationType is (
    -- Model Directives
    NO_OP, GET_ERRORS, SET_MODEL_OPTIONS,
    --  bus operations
    --                       -- Slave
    --                       ----------------------------
    WRITE,                   -- Blocking (Rx Addr & Data)
    READ,                    -- Blocking (Rx Addr, Tx Data)
    --  Slave Only
    WRITE_ADDRESS,           -- Blocking (Rx Addr)
    WRITE_DATA,              -- Blocking (Rx Data)
    TRY_WRITE,               -- Check for Write(Rx Addr & Data)
    TRY_WRITE_ADDRESS,       -- Non-blocking try & get
    TRY_WRITE_DATA,          -- Non-blocking try & get
    READ_ADDRESS,            -- Blocking (Rx Addr)
    TRY_READ_ADDRESS,        -- Non-blocking try & get
    ASYNC_READ_DATA,         -- Non-blocking (Tx Data)
    THE_END
  ) ;
  type Axi4UnresolvedSlaveOperationVectorType is array (natural range <>) of Axi4UnresolvedSlaveOperationType ;
  alias resolved_max is maximum[ Axi4UnresolvedSlaveOperationVectorType return Axi4UnresolvedSlaveOperationType] ;
  -- Maximum is implicitly defined for any array type in VHDL-2008.   Function resolved_max is a fall back.
  -- function resolved_max ( s : Axi4LiteUnresolvedOperationVectorType) return Axi4LiteUnresolvedSlaveOperationType ;
  subtype Axi4SlaveOperationType is resolved_max Axi4UnresolvedSlaveOperationType ;

  -- AXI Model Options
  type Axi4UnresolvedSlaveOptionsType is (
    --
    -- Slave Ready TimeOut Checks
    WRITE_RESPONSE_READY_TIME_OUT,
    READ_DATA_READY_TIME_OUT,
    --
    -- Slave Ready Before Valid
    WRITE_ADDRESS_READY_BEFORE_VALID,
    WRITE_DATA_READY_BEFORE_VALID,
    READ_ADDRESS_READY_BEFORE_VALID,
    --
    -- Slave Ready Delay Cycles
    WRITE_ADDRESS_READY_DELAY_CYCLES,
    WRITE_DATA_READY_DELAY_CYCLES,
    READ_ADDRESS_READY_DELAY_CYCLES,
    --
    -- Master PROT Settings
    SET_READ_PROT,
    USE_READ_PROT_FROM_MODEL,
    SET_WRITE_PROT,
    USE_WRITE_PROT_FROM_MODEL,
    --
    -- Slave RESP Settings
    SET_READ_RESP,
    USE_READ_RESP_FROM_MODEL,
    SET_WRITE_RESP,
    USE_WRITE_RESP_FROM_MODEL,
    --
    -- The End -- Done
    THE_END
  ) ;
  type Axi4UnresolvedSlaveOptionsVectorType is array (natural range <>) of Axi4UnresolvedSlaveOptionsType ;
  alias resolved_max is maximum[ Axi4UnresolvedSlaveOptionsVectorType return Axi4UnresolvedSlaveOptionsType] ;
  subtype Axi4SlaveOptionsType is resolved_max Axi4UnresolvedSlaveOptionsType ;


  -- Record creates a channel for communicating transactions to the model.
  type Axi4LiteSlaveTransactionRecType is record
    Rdy                : bit_max ;
    Ack                : bit_max ;
    AxiAddrWidth       : integer_max ;
    AxiDataWidth       : integer_max ;
    Operation          : Axi4SlaveOperationType ;
    Options            : Axi4SlaveOptionsType ;
    Prot               : integer_max ;
    Address            : TransactionType ;
    DataToModel        : TransactionType ;
    DataFromModel      : TransactionType ;
    DataBytes          : integer_max ;
    Resp               : Axi4RespEnumType ;
    Strb               : integer_max ;
    AlertLogID         : resolved_max AlertLogIDType ;
    StatusMsgOn        : boolean_max ;
    OptionInt          : integer_max ;
    OptionBool         : boolean_max ;
    ModelBool          : boolean_max ;
  end record Axi4LiteSlaveTransactionRecType ;

--!TODO add VHDL-2018 Interfaces


  ------------------------------------------------------------
  procedure NoOp (
  -- Directive:  Do nothing for NoOpCycles number of clocks
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
             NoOpCycles  : In    natural := 1
  ) ;

  ------------------------------------------------------------
  procedure GetErrors (
  -- Error reporting for testbenches that do not use AlertLogPkg
  -- Returns error count.  If an error count /= 0, also print it
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    variable ErrCnt      : Out   natural
  ) ;


  ------------------------------------------------------------
  procedure SlaveGetWrite (
  -- Fetch the address and data the slave sees for a write
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    variable oAddr       : Out   std_logic_vector ;
    variable oData       : Out   std_logic_vector ;
    constant StatusMsgOn : In    boolean := false
  ) ;

  ------------------------------------------------------------
  procedure SlaveRead (
  -- Fetch the address and data the slave sees for a write
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    variable oAddr       : Out   std_logic_vector ;
    Constant iData       : In    std_logic_vector ;
    constant StatusMsgOn : In    boolean := false
  ) ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    constant Option      : In    Axi4SlaveOptionsType ;
    constant OptVal      : In    boolean
  ) ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    constant Option      : In    Axi4SlaveOptionsType ;
    constant OptVal      : In    integer
  ) ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    constant Option      : In    Axi4SlaveOptionsType ;
    constant OptVal      : In    Axi4RespEnumType
  ) ;

end package Axi4LiteSlaveTransactionPkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body Axi4LiteSlaveTransactionPkg is
  -- Maximum is implicitly defined for any array type in VHDL-2008.   Function resolved_max is a fall back.
  -- function resolved_max ( s : Axi4LiteUnresolvedOperationVectorType) return Axi4LiteUnresolvedSlaveOperationType is
  -- begin
  --   return maximum s ;
  -- end function resolved_max ;
  --
  -- function resolved_max ( s : Axi4UnresolvedRespVectorEnumType) return Axi4UnresolvedRespEnumType ;
  -- begin
  --   return maximum s ;
  -- end function resolved_max ;
  
  
  ------------------------------------------------------------
  procedure NoOp (
  -- Directive:  Do nothing for NoOpCycles number of clocks
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
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
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    variable ErrCnt      : Out   natural
  ) is
  begin
    TransRec.Operation     <= GET_ERRORS ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;

    -- Return Error Count
    ErrCnt := FromTransaction(TransRec.DataFromModel) ;
  end procedure GetErrors ;


  ------------------------------------------------------------
  procedure SlaveGetWrite (
  -- Fetch the address and data the slave sees for a write
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    variable oAddr       : Out   std_logic_vector ;
    variable oData       : Out   std_logic_vector ;
    constant StatusMsgOn : In    boolean := false
  ) is
    variable ByteCount : integer ;
  begin
    ByteCount := oData'length / 8 ;

    -- Parameter Checks
    AlertIf(TransRec.AlertLogID, oAddr'length /= TransRec.AxiAddrWidth, "Slave Get Write, Address length does not match", FAILURE) ;
    AlertIf(TransRec.AlertLogID, oData'length mod 8 /= 0, "Slave Get Write, Data not on a byte boundary", FAILURE) ;
    AlertIf(TransRec.AlertLogID, oData'length > TransRec.AxiDataWidth, "Slave Get Write, Data length to large", FAILURE) ;

    -- Put values in record
    TransRec.Operation        <= WRITE ;
    TransRec.DataBytes        <= ByteCount ;
    TransRec.StatusMsgOn      <= StatusMsgOn ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
    oAddr  := FromTransaction(TransRec.Address) ;
    oData  := Reduce(FromTransaction(TransRec.DataFromModel), oData'length) ;
  end procedure SlaveGetWrite ;

  ------------------------------------------------------------
  procedure SlaveRead (
  -- Fetch the address and data the slave sees for a write
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    variable oAddr       : Out   std_logic_vector ;
    constant iData       : In    std_logic_vector ;
    constant StatusMsgOn : In    boolean := false
  ) is
    variable ByteCount : integer ;
  begin
    ByteCount := iData'length / 8 ;

    -- Parameter Checks
    AlertIf(TransRec.AlertLogID, oAddr'length /= TransRec.AxiAddrWidth, "Slave Read, Address length does not match", FAILURE) ;
    AlertIf(TransRec.AlertLogID, iData'length mod 8 /= 0, "Slave Read, Data not on a byte boundary", FAILURE) ;
    AlertIf(TransRec.AlertLogID, iData'length > TransRec.AxiDataWidth, "Slave Read, Data length to large", FAILURE) ;

    -- Put values in record
    TransRec.Operation        <= READ ;
    TransRec.DataBytes        <= ByteCount ;
    TransRec.DataToModel      <= ToTransaction(Extend(iData, TransRec.AxiDataWidth)) ;
    TransRec.Resp             <= OKAY ;
    TransRec.StatusMsgOn      <= StatusMsgOn ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
    oAddr  := FromTransaction(TransRec.Address) ;
  end procedure SlaveRead ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    constant Option      : In    Axi4SlaveOptionsType ;
    constant OptVal      : In    boolean
  ) is
  begin
    TransRec.Operation     <= SET_MODEL_OPTIONS ;
    TransRec.Options       <= Option ;
    TransRec.OptionBool    <= OptVal ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
  end procedure SetModelOptions ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    constant Option      : In    Axi4SlaveOptionsType ;
    constant OptVal      : In    integer
  ) is
  begin
    TransRec.Operation     <= SET_MODEL_OPTIONS ;
    TransRec.Options       <= Option ;
    TransRec.OptionInt     <= OptVal ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
  end procedure SetModelOptions ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4LiteSlaveTransactionRecType ;
    constant Option      : In    Axi4SlaveOptionsType ;
    constant OptVal      : In    Axi4RespEnumType
  ) is
  begin
    TransRec.Operation     <= SET_MODEL_OPTIONS ;
    TransRec.Options       <= Option ;
    TransRec.Resp          <= OptVal ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
  end procedure SetModelOptions ;

end package body Axi4LiteSlaveTransactionPkg ;
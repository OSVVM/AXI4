--
--  File Name:         Axi4TransactionPkg.vhd
--  Design Unit Name:  Axi4TransactionPkg
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

package Axi4TransactionPkg is 

  -- Model AXI Lite Operations
  type Axi4UnresolvedOperationType is (
    -- Model Directives
    NO_OP, GET_ERRORS, 
    -- basic bus blocking operations
    WRITE, READ, READ_CHECK,
    -- AXI independent operations, non-blocking
    WRITE_ADDRESS, WRITE_DATA, READ_ADDRESS, READ_DATA
  ) ;
  type Axi4UnresolvedOperationVectorType is array (natural range <>) of Axi4UnresolvedOperationType ;   
  alias resolved_max is maximum[ Axi4UnresolvedOperationVectorType return Axi4UnresolvedOperationType] ; 
  -- Maximum is implicitly defined for any array type in VHDL-2008.   Function resolved_max is a fall back.
  -- function resolved_max ( s : Axi4LiteUnresolvedOperationVectorType) return Axi4LiteUnresolvedOperationType ; 
  subtype Axi4OperationType is resolved_max Axi4UnresolvedOperationType ;
  
  --                                     00    01      10      11
  type  Axi4UnresolvedRespEnumType is (OKAY, EXOKAY, SLVERR, DECERR) ;
  type Axi4UnresolvedRespVectorEnumType is array (natural range <>) of Axi4UnresolvedRespEnumType ;   
  alias resolved_max is maximum[ Axi4UnresolvedRespVectorEnumType return Axi4UnresolvedRespEnumType] ; 
  -- Maximum is implicitly defined for any array type in VHDL-2008.   Function resolved_max is a fall back.
  -- function resolved_max ( s : Axi4UnresolvedRespVectorEnumType) return Axi4UnresolvedRespEnumType ; 
  subtype Axi4RespEnumType is resolved_max Axi4UnresolvedRespEnumType ;

  subtype  Axi4RespType is std_logic_vector(1 downto 0) ;
  constant AXI4_RESP_OKAY   : Axi4RespType := "00" ; 
  constant AXI4_RESP_EXOKAY : Axi4RespType := "01" ; -- Not for Lite
  constant AXI4_RESP_SLVERR : Axi4RespType := "10" ; 
  constant AXI4_RESP_DECERR : Axi4RespType := "11" ; 
  constant AXI4_RESP_INIT   : Axi4RespType := "ZZ" ; 

  function from_Axi4RespType (a: Axi4RespType) return Axi4RespEnumType ; 
  function to_Axi4RespType (a: Axi4RespEnumType) return Axi4RespType ; 


  subtype Axi4ProtType is std_logic_vector(2 downto 0) ;
  --  [0] 0 Unprivileged access
  --      1 Privileged access
  --  [1] 0 Secure access
  --      1 Non-secure access
  --  [2] 0 Data access
  --      1 Instruction access
  constant AXI4_PROT_INIT   : Axi4ProtType := "ZZZ" ; 

  -- Conversions to/from transaction values  
  function Extend(A: std_logic_vector; Size : natural) return std_logic_vector ; 
  function Reduce(A: std_logic_vector; Size : natural) return std_logic_vector ; 
  subtype  TransactionType is std_logic_vector_max_c ; 
  function ToTransaction(A : std_logic_vector) return TransactionType ;
  function ToTransaction(A : integer; Size : natural) return TransactionType ;
  function FromTransaction (A: TransactionType) return std_logic_vector ;
  function FromTransaction (A: TransactionType) return integer ;
  function SizeOfTransaction (AxiSize : integer) return integer ;

  -- Record creates a channel for communicating transactions to the model.
  type Axi4TransactionRecType is record 
    Rdy                : bit_max ;  
    Ack                : bit_max ;  
    AxiAddrWidth       : integer_max ; 
    AxiDataWidth       : integer_max ; 
    Operation          : Axi4OperationType ; 
    Prot               : integer_max ;
    Address            : TransactionType ;
    DataToModel        : TransactionType ;
    DataFromModel      : TransactionType ;
    DataBytes          : integer_max ; 
    Resp               : Axi4RespEnumType ; 
    Strb               : integer_max ; 
    AlertLogID         : resolved_max AlertLogIDType ; 
    StatusMsgOn        : boolean_max ; 
  end record Axi4TransactionRecType ;
  
--!TODO add VHDL-2018 Interfaces


  ------------------------------------------------------------
  procedure NoOp (
  -- Directive:  Do nothing for NoOpCycles number of clocks 
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
             NoOpCycles  : In    natural := 1 
  ) ;

  ------------------------------------------------------------
  procedure GetErrors (
  -- Error reporting for testbenches that do not use AlertLogPkg 
  -- Returns error count.  If an error count /= 0, also print it
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
    variable ErrCnt      : Out   natural 
  ) ;

  ------------------------------------------------------------
  procedure MasterWrite (
  -- do CPU Write Cycle 
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
             iAddr       : In    std_logic_vector ;
             iData       : In    std_logic_vector ;
             StatusMsgOn : In    boolean := false
  ) ;

--!TODO          ?Axi4WriteAddress?    Is this separate?
--!TODO          ?Axi4WriteData?       Is this separate?

  ------------------------------------------------------------
  procedure MasterRead (
  -- do CPU Read Cycle and return data
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
             iAddr       : In    std_logic_vector ;
    variable oData       : Out   std_logic_vector ;
             StatusMsgOn : In    boolean := false
  ) ;

--!TODO          Axi4ReadAddress
--!TODO          Axi4ReadData

  ------------------------------------------------------------
  procedure MasterReadCheck (
  -- do CPU Read Cycle and check supplied data
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
             iAddr       : In    std_logic_vector ;
             iData       : In    std_logic_vector ;
             StatusMsgOn : In    boolean := false
  ) ; 

  ------------------------------------------------------------
  procedure MasterReadPoll (
  -- Read location (iAddr) until Data(IndexI) = ValueI
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
             iAddr       : In    std_logic_vector ;
             Index       : In    Integer ;
             BitValue    : In    std_logic ;
             StatusMsgOn : In    boolean := false ;
             WaitTime    : In    natural := 10 
  ) ; 
  
  ------------------------------------------------------------
  procedure SlaveGetWrite (
  -- Fetch the address and data the slave sees for a write 
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
    variable oAddr       : Out   std_logic_vector ;
    variable oData       : Out   std_logic_vector ;
    constant StatusMsgOn : In    boolean := false
  ) ; 
  
  ------------------------------------------------------------
  procedure SlaveRead (
  -- Fetch the address and data the slave sees for a write 
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
    variable oAddr       : Out   std_logic_vector ;
    Constant iData       : In    std_logic_vector ;
    constant StatusMsgOn : In    boolean := false
  ) ;
  
end package Axi4TransactionPkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body Axi4TransactionPkg is 
  -- Maximum is implicitly defined for any array type in VHDL-2008.   Function resolved_max is a fall back.
  -- function resolved_max ( s : Axi4LiteUnresolvedOperationVectorType) return Axi4LiteUnresolvedOperationType is
  -- begin
  --   return maximum s ;
  -- end function resolved_max ;   
  --
  -- function resolved_max ( s : Axi4UnresolvedRespVectorEnumType) return Axi4UnresolvedRespEnumType ; 
  -- begin
  --   return maximum s ;
  -- end function resolved_max ;   
  
  ------------------------------------------------------------
  type TbRespType_indexby_Integer is array (integer range <>) of Axi4RespEnumType;
  constant RESP_TYPE_TB_TABLE : TbRespType_indexby_Integer := (
      0    => OKAY  , 
      1    => EXOKAY, 
      2    => SLVERR,
      3    => DECERR
    ) ;
  function from_Axi4RespType (a: Axi4RespType) return Axi4RespEnumType is
  begin
    return RESP_TYPE_TB_TABLE(to_integer(a)) ; 
  end function from_Axi4RespType ;
  
  ------------------------------------------------------------
  type RespType_indexby_TbRespType is array (Axi4RespEnumType) of Axi4RespType;
  constant TB_TO_RESP_TYPE_TABLE : RespType_indexby_TbRespType := (
      OKAY      => "00", 
      EXOKAY    => "01", 
      SLVERR    => "10",
      DECERR    => "11"
    ) ;
  function to_Axi4RespType (a: Axi4RespEnumType) return Axi4RespType is
  begin
    return TB_TO_RESP_TYPE_TABLE(a) ; -- replace with lookup table
  end function to_Axi4RespType ;
  
  ------------------------------------------------------------
  -- Conversions to/from transaction values  
  --     Extend, Reduce, ToTransaction, FromTransaction
  function Extend(A: std_logic_vector; Size : natural) return std_logic_vector is
    variable extA : std_logic_vector(Size downto 1) := (others => '0') ;
  begin
    extA(A'length downto 1) := A ; 
    return extA ;
  end function Extend ; 
  
  function Reduce(A: std_logic_vector; Size : natural) return std_logic_vector is 
    alias aA : std_logic_vector(A'length-1 downto 0) is A ; 
  begin
    return aA(Size-1 downto 0) ;
  end function Reduce ; 
  
  function ToTransaction(A : std_logic_vector) return TransactionType is
  begin
    return TransactionType(A) ; 
  end function ToTransaction ; 
  
  function ToTransaction(A : integer; Size : natural) return TransactionType is
  begin
    return TransactionType(to_signed(A, Size)) ; 
  end function ToTransaction ; 

  function FromTransaction (A: TransactionType) return std_logic_vector is
  begin
    return std_logic_vector(A) ;
  end function FromTransaction ; 

  function FromTransaction (A: TransactionType) return integer is
  begin
    return to_integer(signed(A)) ;
  end function FromTransaction ; 
  
  function SizeOfTransaction (AxiSize : integer) return integer is
  begin
    return AxiSize ; 
  end function SizeOfTransaction ; 

  ------------------------------------------------------------
  procedure NoOp (
  -- Directive:  Do nothing for NoOpCycles number of clocks 
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
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
    signal   TransRec    : InOut Axi4TransactionRecType ;
    variable ErrCnt      : Out   natural 
  ) is
  begin
    TransRec.Operation     <= GET_ERRORS ;
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
    
    -- Return Error Count
    ErrCnt := FromTransaction(TransRec.DataFromModel) ;
  end procedure GetErrors ; 
  

  ------------------------------------------------------------
  procedure MasterWrite (
  -- do CPU Write Cycle 
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
             iAddr       : In    std_logic_vector ;
             iData       : In    std_logic_vector ;
             StatusMsgOn : In    boolean := false
  ) is
    variable ByteCount : integer ; 
  begin
    ByteCount := iData'length / 8 ;

    -- Parameter Checks
    AlertIf(TransRec.AlertLogID, iAddr'length /= TransRec.AxiAddrWidth, "Master Write, Address length does not match", FAILURE) ;
    AlertIf(TransRec.AlertLogID, iData'length mod 8 /= 0, "Master Write, Data not on a byte boundary", FAILURE) ;
    AlertIf(TransRec.AlertLogID, iData'length > TransRec.AxiDataWidth, "Master Write, Data length to large", FAILURE) ;
    
    -- Put values in record
    TransRec.Operation        <= WRITE ;
    TransRec.Address          <= ToTransaction(iAddr) ;
    TransRec.Prot             <= 0 ;
    TransRec.DataToModel      <= ToTransaction(Extend(iData, TransRec.AxiDataWidth)) ;
    TransRec.DataBytes        <= ByteCount ; 
    TransRec.StatusMsgOn      <= StatusMsgOn ; 
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
  end procedure MasterWrite ; 

--!TODO          ?Axi4WriteAddress?    Is this separate?
--!TODO          ?Axi4WriteData?       Is this separate?

  ------------------------------------------------------------
  procedure MasterRead (
  -- do CPU Read Cycle and return data
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
             iAddr       : In    std_logic_vector ;
    variable oData       : Out   std_logic_vector ;
             StatusMsgOn : In    boolean := false
  ) is
    variable ByteCount : integer ; 
  begin
    ByteCount := oData'length / 8 ;

    -- Parameter Checks
    AlertIf(TransRec.AlertLogID, iAddr'length /= TransRec.AxiAddrWidth, "Master Read, Address length does not match", FAILURE) ;
    AlertIf(TransRec.AlertLogID, oData'length mod 8 /= 0, "Master Read, Data not on a byte boundary", FAILURE) ;
    AlertIf(TransRec.AlertLogID, oData'length > TransRec.AxiDataWidth, "Master Read, Data length to large", FAILURE) ;
    
    -- Put values in record
    TransRec.Operation          <= READ ;
    TransRec.Address            <= ToTransaction(iAddr) ;
    TransRec.DataBytes          <= ByteCount ; 
    TransRec.Prot               <= 0 ;
    TransRec.StatusMsgOn        <= StatusMsgOn ; 
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
    
    oData := Reduce(FromTransaction(TransRec.DataFromModel), oData'Length) ;
  end procedure MasterRead ; 

--!TODO          Axi4LiteReadAddress
--!TODO          Axi4LiteReadData

  ------------------------------------------------------------
  procedure MasterReadCheck (
  -- do CPU Read Cycle and check supplied data
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
             iAddr       : In    std_logic_vector ;
             iData       : In    std_logic_vector ;
             StatusMsgOn : In    boolean := false
  ) is
    variable ByteCount : integer ; 
  begin
    ByteCount := iData'length / 8 ;

    -- Parameter Checks
    AlertIf(TransRec.AlertLogID, iAddr'length /= TransRec.AxiAddrWidth, "Master Read, Address length does not match", FAILURE) ;
    AlertIf(TransRec.AlertLogID, iData'length mod 8 /= 0, "Master Read, Data not on a byte boundary", FAILURE) ;
    AlertIf(TransRec.AlertLogID, iData'length > TransRec.AxiDataWidth, "Master Read, Data length to large", FAILURE) ;
    
    -- Put values in record
    TransRec.Operation        <= READ_CHECK ;
    TransRec.Address          <= ToTransaction(iAddr) ;
--!TODO Make PROT programmable
    TransRec.Prot             <= 0 ;
    TransRec.DataToModel      <= ToTransaction(Extend(iData, TransRec.DataToModel'length)) ;
    TransRec.DataBytes        <= ByteCount ; 
    TransRec.StatusMsgOn      <= StatusMsgOn ; 
    RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
  end procedure MasterReadCheck ; 

  ------------------------------------------------------------
  procedure MasterReadPoll (
  -- Read location (iAddr) until Data(IndexI) = ValueI
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
             iAddr       : In    std_logic_vector ;
             Index       : In    Integer ;
             BitValue    : In    std_logic ;
             StatusMsgOn : In    boolean := false ;
             WaitTime    : In    natural := 10 
  ) is 
    variable iData    : std_logic_vector(TransRec.AxiDataWidth-1 downto 0) ;
  begin
    loop 
      NoOp(TransRec, WaitTime) ;
      MasterRead (TransRec, iAddr, iData) ;
      exit when iData(Index) = BitValue ;
    end loop ;

    Log(TransRec.AlertLogID, "CpuPoll: address" & to_hstring(iAddr) & 
      "  Data: " & to_hstring(FromTransaction(TransRec.DataFromModel)), INFO, StatusMsgOn) ; 
  end procedure MasterReadPoll ;
  
  ------------------------------------------------------------
  procedure SlaveGetWrite (
  -- Fetch the address and data the slave sees for a write 
  ------------------------------------------------------------
    signal   TransRec    : InOut Axi4TransactionRecType ;
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
    signal   TransRec    : InOut Axi4TransactionRecType ;
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
  
  
end package body Axi4TransactionPkg ;
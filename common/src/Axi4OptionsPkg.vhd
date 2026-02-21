--
--  File Name:         Axi4OptionsPkg.vhd
--  Design Unit Name:  Axi4OptionsPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms used by
--      OSVVM Address Bus Transaction Based Models (aka: TBM, TLM, VVC)
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    10/2025   2025.10    Refactored to remove Axi4[Lite]InterfacePkg references
--                         Added Support for Mode Views
--    02/2022   2022.02    Added SetAxi4LiteInterfaceDefault, GetAxi4LiteInterfaceDefault
--    01/2020   2020.02    Refactored from Axi4MasterTransactionPkg.vhd
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2017 - 2025 by SynthWorks Design Inc.
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

library osvvm_common ;
    context osvvm_common.OsvvmCommonContext ;

use work.Axi4InterfaceCommonPkg.all ;

package Axi4OptionsPkg is

  type Axi4UnresolvedOptionsType is (
    -- AXI4 Model Options
    -- Ready timeout
    WRITE_ADDRESS_READY_TIME_OUT,
    WRITE_DATA_READY_TIME_OUT,
    WRITE_RESPONSE_READY_TIME_OUT,      -- S
    READ_ADDRESS_READY_TIME_OUT,
    READ_DATA_READY_TIME_OUT,           -- S

    -- Ready Controls
    WRITE_ADDRESS_READY_BEFORE_VALID,   -- S
    WRITE_DATA_READY_BEFORE_VALID,      -- S
    WRITE_RESPONSE_READY_BEFORE_VALID,
    READ_ADDRESS_READY_BEFORE_VALID,    -- S
    READ_DATA_READY_BEFORE_VALID,

    -- Ready Delays
    WRITE_ADDRESS_READY_DELAY_CYCLES,   -- S
    WRITE_DATA_READY_DELAY_CYCLES,      -- S
    WRITE_RESPONSE_READY_DELAY_CYCLES,
    READ_ADDRESS_READY_DELAY_CYCLES,    -- S
    READ_DATA_READY_DELAY_CYCLES,

    -- Valid Timeouts
    WRITE_RESPONSE_VALID_TIME_OUT,
    READ_DATA_VALID_TIME_OUT,

    -- Valid Delays
    WRITE_ADDRESS_VALID_DELAY_CYCLES,
    WRITE_DATA_VALID_DELAY_CYCLES,
    WRITE_DATA_VALID_BURST_DELAY_CYCLES,
    WRITE_RESPONSE_VALID_DELAY_CYCLES,  -- S
    READ_ADDRESS_VALID_DELAY_CYCLES,
    READ_DATA_VALID_DELAY_CYCLES,       -- S
    READ_DATA_VALID_BURST_DELAY_CYCLES, -- S

    -- Write Data Filtering
    WRITE_DATA_FILTER_UNDRIVEN,
    WRITE_DATA_UNDRIVEN_VALUE,

    -- Marker
    OPTIONS_MARKER,

-- AXI Interface Settings
    -- AXI
--    AWADDR,
    AWPROT,
--    AWVALID,
--    AWREADY,
    -- Axi4 Full
    AWID,
--    AWLEN,
    AWSIZE,
    AWBURST,
    AWLOCK,
    AWCACHE,
    AWQOS,
    AWREGION,
    AWUSER,

    -- Write Data
--    WDATA,
--    WSTRB,
--    WVALID,
--    WREADY,
    -- AXI4 Full
    WLAST,
    WUSER,
    -- AXI3
    WID,

    -- Write Response
    BRESP,
--    BVALID,
--    BREADY,
    -- AXI4 Full
    BID,
    BUSER,

    -- Read Address
--    ARADDR,
    ARPROT,
--    ARVALID,
--    ARREADY,
    -- Axi4 Full
    ARID,
    -- BURSTLength = AxLen+1.  AXI4,
--    ARLEN,
    -- #Bytes in transfer = 2**AxSize
    ARSIZE,
    -- AxBURST = (Fixed, Incr, Wrap, NotDefined)
    ARBURST,
    ARLOCK,
    -- AxCACHE One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
    ARCACHE,
    ARQOS,
    ARREGION,
    ARUSER,

    -- Read DATA
--    RDATA,
    RRESP,
--    RVALID,
--    RREADY,
    -- AXI4 Full
    RID,
    RLAST,
    RUSER,
    --
    -- The End -- Done
    THE_END
  ) ;
  type Axi4UnresolvedOptionsVectorType is array (natural range <>) of Axi4UnresolvedOptionsType ;
  -- alias resolved_max is maximum[ Axi4UnresolvedOptionsVectorType return Axi4UnresolvedOptionsType] ;
  function resolved_max(A : Axi4UnresolvedOptionsVectorType) return Axi4UnresolvedOptionsType ;

  subtype Axi4OptionsType is resolved_max Axi4UnresolvedOptionsType ;

--!  type AxiParamsType is array (Axi4OptionsType range <>) of integer ;
--! Need init Parms for default values - many parms all init with ignore values &
--! call via named association

  --
  --  Abstraction Layer to support SetModelOptions using enumerated values
  --
  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    boolean
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    integer
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic_vector
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    Axi4RespEnumType
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   boolean
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   integer
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic_vector
  ) ;
  
  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   Axi4RespEnumType
  ) ;


  --
  --  Support for revisions prior to 2020.12
  --  This overloading cannot be supported in general as if two VCs
  --  use the same enumerated value for an Option, calls to it will be ambiguous.
  --  Hence, to support VC types, a VC specific Set...Options is required.
  --
  alias SetModelOptions is SetAxi4Options[AddressBusRecType, Axi4OptionsType, boolean];
  alias SetModelOptions is SetAxi4Options[AddressBusRecType, Axi4OptionsType, integer];
  alias SetModelOptions is SetAxi4Options[AddressBusRecType, Axi4OptionsType, std_logic_vector];


  --
  -- Axi4 Verification Component Support Subprograms
  --
  ------------------------------------------------------------
  impure function to_integer (Operation : Axi4OptionsType) return integer ;
  function IsAxiParameter (Operation : Axi4OptionsType) return boolean ;
  function IsAxiInterface (Operation : Axi4OptionsType) return boolean ; 

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    boolean
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    std_logic
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    integer
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    std_logic_vector
  ) ;

  ------------------------------------------------------------
  impure function GetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType 
  ) return boolean ;

  ------------------------------------------------------------
  impure function GetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType 
  ) return std_logic ;

  ------------------------------------------------------------
  impure function GetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType 
  ) return integer ;

  ------------------------------------------------------------
  impure function GetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType 
  ) return std_logic_vector ;
  
  ------------------------------------------------------------
  impure function GetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType ;
    constant Size          : in    natural
  ) return std_logic_vector ;
  
  ------------------------------------------------------------
  procedure InitAxiOptions (
  -----------------------------------------------------------
    constant Params        : in ModelParametersIDType 
  ) ;

  ------------------------------------------------------------
  procedure InitAxiOptions (
  -----------------------------------------------------------
    signal Params        : InOut ModelParametersIDType ;
           Name          : in    string ; 
           ParentID      : in    AlertLogIDType
  ) ;
  
--!! These are Deprecated !!
--!! These are Deprecated !!
--!! These are Deprecated !!
  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    boolean
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    std_logic
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    integer
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    std_logic_vector
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OptVal        : out   boolean
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OptVal        : out   std_logic
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OptVal        : out   integer
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OptVal        : out   std_logic_vector
  ) ;
  --
  -- Remove after updating Axi4Lite VC
  --
--!!  alias SetAxiOption is SetAxi4Parameter[ModelParametersPType, Axi4OptionsType, boolean];
--!!  alias SetAxiOption is SetAxi4Parameter[ModelParametersPType, Axi4OptionsType, integer];
--!!  alias SetAxiOption is SetAxi4Parameter[ModelParametersPType, Axi4OptionsType, std_logic_vector];
--!!  alias GetAxiOption is GetAxi4Parameter[ModelParametersPType, Axi4OptionsType, boolean];
--!!  alias GetAxiOption is GetAxi4Parameter[ModelParametersPType, Axi4OptionsType, integer];
--!!  alias GetAxiOption is GetAxi4Parameter[ModelParametersPType, Axi4OptionsType, std_logic_vector];


end package Axi4OptionsPkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body Axi4OptionsPkg is

  function resolved_max(A : Axi4UnresolvedOptionsVectorType) return Axi4UnresolvedOptionsType is
  begin
    return maximum(A) ;
  end function resolved_max ;

--   function resolved_max ( s : Axi4UnresolvedRespVectorEnumType) return Axi4UnresolvedRespEnumType is
--   begin
--     return maximum(s) ;
--   end function resolved_max ; 

  --
  --  Abstraction Layer to support SetModelOptions using enumerated values
  --
  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    boolean
  ) is
  begin
    SetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), boolean'pos(OptVal)) ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic
  ) is
  begin
    SetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), std_logic'pos(OptVal)) ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    integer
  ) is
  begin
    SetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), OptVal) ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic_vector
  ) is
  begin
    SetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), OptVal) ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    Axi4RespEnumType
  ) is
  begin
    SetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), Axi4RespEnumType'pos(OptVal)) ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   boolean
  ) is
    variable IntOptVal : integer ;
  begin
    GetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), IntOptVal) ;
    OptVal := IntOptVal >= 1 ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic
  ) is
    variable IntOptVal : integer ;
  begin
    GetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), IntOptVal) ;
    OptVal := std_logic'val(IntOptVal) ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   integer
  ) is
  begin
    GetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), OptVal) ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic_vector
  ) is
  begin
    GetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), OptVal) ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view AddressBusTestCtrlView of AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   Axi4RespEnumType
  ) is
    variable IntOptVal : integer ;
  begin
    GetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), IntOptVal) ;
    OptVal := Axi4RespEnumType'val(IntOptVal) ;
  end procedure GetAxi4Options ;

  --
  -- Axi4 Verification Component Support Subprograms
  --
  ------------------------------------------------------------
  impure function to_integer (Operation : Axi4OptionsType) return integer is 
  -----------------------------------------------------------
  begin
    return Axi4OptionsType'POS(Operation) ;
  end function to_integer ;

  ------------------------------------------------------------
  function IsAxiParameter (Operation : Axi4OptionsType) return boolean is 
  -----------------------------------------------------------
  begin
    return (Operation < OPTIONS_MARKER) ;
  end function IsAxiParameter ;

  ------------------------------------------------------------
  function IsAxiInterface (Operation : Axi4OptionsType) return boolean is 
  ------------------------------------------------------------
  begin
    return (Operation > OPTIONS_MARKER) ;
  end function IsAxiInterface ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    boolean
  ) is
  begin
    Set(Params, Axi4OptionsType'POS(Operation), OptVal) ;
  end procedure SetAxi4Parameter ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    std_logic
  ) is
  begin
    Set(Params, Axi4OptionsType'POS(Operation), std_logic'pos(OptVal)) ;
  end procedure SetAxi4Parameter ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    integer
  ) is
  begin
    Set(Params, Axi4OptionsType'POS(Operation), OptVal) ;
  end procedure SetAxi4Parameter ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    std_logic_vector
  ) is
  begin
    Set(Params, Axi4OptionsType'POS(Operation), OptVal) ;
  end procedure SetAxi4Parameter ;

  ------------------------------------------------------------
  impure function GetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType 
  ) return boolean is
  begin
    return Get(Params, Axi4OptionsType'POS(Operation)) ;
  end function GetAxi4Parameter ;

  ------------------------------------------------------------
  impure function GetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType 
  ) return std_logic is
    variable IntOptval : integer ;
  begin
    IntOptVal:= Get(Params, Axi4OptionsType'POS(Operation)) ;
    return std_logic'val(IntOptVal) ;
  end function GetAxi4Parameter ;

  ------------------------------------------------------------
  impure function GetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType 
  ) return integer is
  begin
    return Get(Params, Axi4OptionsType'POS(Operation)) ;
  end function GetAxi4Parameter ;

  ------------------------------------------------------------
  impure function GetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType 
  ) return std_logic_vector is 
  begin
    return Get(Params, Axi4OptionsType'POS(Operation)) ;
  end function GetAxi4Parameter ;
  
  ------------------------------------------------------------
  impure function GetAxi4Parameter (
  -----------------------------------------------------------
    constant Params        : in    ModelParametersIDType ;
    constant Operation     : in    Axi4OptionsType ;
    constant Size          : in    natural
  ) return std_logic_vector is 
  begin
    return Get(Params, Axi4OptionsType'POS(Operation), Size) ;
  end function GetAxi4Parameter ;
  
  ------------------------------------------------------------
  procedure InitAxiOptions (
  -----------------------------------------------------------
    constant Params        : in ModelParametersIDType 
  ) is
  begin
    -- AXI4 Model Options
    -- Ready timeout
    SetAxi4Parameter(Params, WRITE_ADDRESS_READY_TIME_OUT,       25 ) ;
    SetAxi4Parameter(Params, WRITE_DATA_READY_TIME_OUT,          25 ) ;
    SetAxi4Parameter(Params, WRITE_RESPONSE_READY_TIME_OUT,      25 ) ; -- S
    SetAxi4Parameter(Params, READ_ADDRESS_READY_TIME_OUT,        25 ) ;
    SetAxi4Parameter(Params, READ_DATA_READY_TIME_OUT,           25 ) ; -- S

    -- Ready Controls
    SetAxi4Parameter(Params, WRITE_ADDRESS_READY_BEFORE_VALID,   TRUE) ; -- S
    SetAxi4Parameter(Params, WRITE_DATA_READY_BEFORE_VALID,      TRUE) ; -- S
    SetAxi4Parameter(Params, WRITE_RESPONSE_READY_BEFORE_VALID,  TRUE) ;
    SetAxi4Parameter(Params, READ_ADDRESS_READY_BEFORE_VALID,    TRUE) ; -- S
    SetAxi4Parameter(Params, READ_DATA_READY_BEFORE_VALID,       TRUE) ;

    -- Ready Delay
    SetAxi4Parameter(Params, WRITE_ADDRESS_READY_DELAY_CYCLES,   0) ;  -- S
    SetAxi4Parameter(Params, WRITE_DATA_READY_DELAY_CYCLES,      0) ;  -- S
    SetAxi4Parameter(Params, WRITE_RESPONSE_READY_DELAY_CYCLES,  0) ;
    SetAxi4Parameter(Params, READ_ADDRESS_READY_DELAY_CYCLES,    0) ;  -- S
    SetAxi4Parameter(Params, READ_DATA_READY_DELAY_CYCLES,       0) ;

    -- Valid Timeouts
    SetAxi4Parameter(Params, WRITE_RESPONSE_VALID_TIME_OUT,      8192) ;
    SetAxi4Parameter(Params, READ_DATA_VALID_TIME_OUT,           25) ;

    -- Valid Delays
    SetAxi4Parameter(Params, WRITE_ADDRESS_VALID_DELAY_CYCLES,     0) ;
    SetAxi4Parameter(Params, WRITE_DATA_VALID_DELAY_CYCLES,        0) ;
    SetAxi4Parameter(Params, WRITE_DATA_VALID_BURST_DELAY_CYCLES,  0) ;
    SetAxi4Parameter(Params, WRITE_RESPONSE_VALID_DELAY_CYCLES,    0) ;  -- S
    SetAxi4Parameter(Params, READ_ADDRESS_VALID_DELAY_CYCLES,      0) ;
    SetAxi4Parameter(Params, READ_DATA_VALID_DELAY_CYCLES,         0) ;  -- S
    SetAxi4Parameter(Params, READ_DATA_VALID_BURST_DELAY_CYCLES,   0) ;  -- S

    -- Write Data Filtering
    SetAxi4Parameter(Params, WRITE_DATA_FILTER_UNDRIVEN,            TRUE) ;
    SetAxi4Parameter(Params, WRITE_DATA_UNDRIVEN_VALUE,             '0') ;
  end procedure InitAxiOptions ;

  ------------------------------------------------------------
  procedure InitAxiOptions (
  -----------------------------------------------------------
    signal Params        : InOut ModelParametersIDType ;
           Name          : in    string ; 
           ParentID      : in    AlertLogIDType
  ) is
    variable vParams : ModelParametersIDType ; 
  begin
    -- 
    -- Size the Data structure, such that it creates 1 parameter for each option
    vParams := NewID(Name, to_integer(OPTIONS_MARKER), ParentID); 
    Params  <= vParams ; 
    InitAxiOptions(vParams) ; 
    
  end procedure InitAxiOptions ;

-- !! These are deprecated
-- !! These are deprecated
-- !! These are deprecated
  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    boolean
  ) is
  begin
    Params.Set(Axi4OptionsType'POS(Operation), OptVal) ;
  end procedure SetAxi4Parameter ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    std_logic
  ) is
  begin
    Params.Set(Axi4OptionsType'POS(Operation), std_logic'pos(OptVal)) ;
  end procedure SetAxi4Parameter ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    integer
  ) is
  begin
    Params.Set(Axi4OptionsType'POS(Operation), OptVal) ;
  end procedure SetAxi4Parameter ;

  ------------------------------------------------------------
  procedure SetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OptVal        : in    std_logic_vector
  ) is
  begin
    Params.Set(Axi4OptionsType'POS(Operation), OptVal) ;
  end procedure SetAxi4Parameter ;

  ------------------------------------------------------------
  procedure GetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OptVal        : out   boolean
  ) is
  begin
    OptVal:= Params.Get(Axi4OptionsType'POS(Operation)) ;
  end procedure GetAxi4Parameter ;

  ------------------------------------------------------------
  procedure GetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OptVal        : out   std_logic
  ) is
    variable IntOptval : integer ;
  begin
    IntOptVal:= Params.Get(Axi4OptionsType'POS(Operation)) ;
    OptVal := std_logic'val(IntOptVal) ;
  end procedure GetAxi4Parameter ;

  ------------------------------------------------------------
  procedure GetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OptVal        : out   integer
  ) is
  begin
    OptVal:= Params.Get(Axi4OptionsType'POS(Operation)) ;
  end procedure GetAxi4Parameter ;

  ------------------------------------------------------------
  procedure GetAxi4Parameter (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OptVal        : out   std_logic_vector
  ) is
  begin
    OptVal:= Params.Get(Axi4OptionsType'POS(Operation), OptVal'length) ;
  end procedure GetAxi4Parameter ;

  ------------------------------------------------------------
  procedure InitAxiOptions (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType --;
--    signal   AxiBus        : In    Axi4BaseRecType
  ) is
  begin
    -- Size the Data structure, such that it creates 1 parameter for each option
    Params.Init(Axi4OptionsType'POS(OPTIONS_MARKER)) ;

    -- AXI4 Model Options
    -- Ready timeout
    SetAxi4Parameter(Params, WRITE_ADDRESS_READY_TIME_OUT,       25 ) ;
    SetAxi4Parameter(Params, WRITE_DATA_READY_TIME_OUT,          25 ) ;
    SetAxi4Parameter(Params, WRITE_RESPONSE_READY_TIME_OUT,      25 ) ; -- S
    SetAxi4Parameter(Params, READ_ADDRESS_READY_TIME_OUT,        25 ) ;
    SetAxi4Parameter(Params, READ_DATA_READY_TIME_OUT,           25 ) ; -- S

    -- Ready Controls
    SetAxi4Parameter(Params, WRITE_ADDRESS_READY_BEFORE_VALID,   TRUE) ; -- S
    SetAxi4Parameter(Params, WRITE_DATA_READY_BEFORE_VALID,      TRUE) ; -- S
    SetAxi4Parameter(Params, WRITE_RESPONSE_READY_BEFORE_VALID,  TRUE) ;
    SetAxi4Parameter(Params, READ_ADDRESS_READY_BEFORE_VALID,    TRUE) ; -- S
    SetAxi4Parameter(Params, READ_DATA_READY_BEFORE_VALID,       TRUE) ;

    -- Ready Delay
    SetAxi4Parameter(Params, WRITE_ADDRESS_READY_DELAY_CYCLES,   0) ;  -- S
    SetAxi4Parameter(Params, WRITE_DATA_READY_DELAY_CYCLES,      0) ;  -- S
    SetAxi4Parameter(Params, WRITE_RESPONSE_READY_DELAY_CYCLES,  0) ;
    SetAxi4Parameter(Params, READ_ADDRESS_READY_DELAY_CYCLES,    0) ;  -- S
    SetAxi4Parameter(Params, READ_DATA_READY_DELAY_CYCLES,       0) ;

    -- Valid Timeouts
    SetAxi4Parameter(Params, WRITE_RESPONSE_VALID_TIME_OUT,      8192) ;
    SetAxi4Parameter(Params, READ_DATA_VALID_TIME_OUT,           25) ;

    -- Valid Delays
    SetAxi4Parameter(Params, WRITE_ADDRESS_VALID_DELAY_CYCLES,     0) ;
    SetAxi4Parameter(Params, WRITE_DATA_VALID_DELAY_CYCLES,        0) ;
    SetAxi4Parameter(Params, WRITE_DATA_VALID_BURST_DELAY_CYCLES,  0) ;
    SetAxi4Parameter(Params, WRITE_RESPONSE_VALID_DELAY_CYCLES,    0) ;  -- S
    SetAxi4Parameter(Params, READ_ADDRESS_VALID_DELAY_CYCLES,      0) ;
    SetAxi4Parameter(Params, READ_DATA_VALID_DELAY_CYCLES,         0) ;  -- S
    SetAxi4Parameter(Params, READ_DATA_VALID_BURST_DELAY_CYCLES,   0) ;  -- S

    -- Write Data Filtering
    SetAxi4Parameter(Params, WRITE_DATA_FILTER_UNDRIVEN,            TRUE) ;
    SetAxi4Parameter(Params, WRITE_DATA_UNDRIVEN_VALUE,             '0') ;

--    -- AXI Interface Settings
--    -- Set all AXI bus parameters to 0 and Size them to match the corresponding AXI Bus signal.
--    -- Write Address
--    SetAxi4Parameter(Params, AWPROT,    to_slv(0, AxiBus.WriteAddress.Prot'length)) ;
--    SetAxi4Parameter(Params, AWID,      to_slv(0, AxiBus.WriteAddress.ID'length)) ;
--    SetAxi4Parameter(Params, AWSIZE,    to_slv(0, AxiBus.WriteAddress.Size'length)) ;
--    SetAxi4Parameter(Params, AWBURST,   to_slv(0, AxiBus.WriteAddress.Burst'length)) ;
--    SetAxi4Parameter(Params, AWLOCK,    to_slv(0, 1)) ;
--    SetAxi4Parameter(Params, AWCACHE,   to_slv(0, AxiBus.WriteAddress.Cache'length)) ;
--    SetAxi4Parameter(Params, AWQOS,     to_slv(0, AxiBus.WriteAddress.Region'length)) ;
--    SetAxi4Parameter(Params, AWREGION,  to_slv(0, AxiBus.WriteAddress.Size'length)) ;
--    SetAxi4Parameter(Params, AWUSER,    to_slv(0, AxiBus.WriteAddress.User'length)) ;
--    -- Write Data
--    SetAxi4Parameter(Params, WLAST,     to_slv(0, 1)) ;
--    SetAxi4Parameter(Params, WUSER,     to_slv(0, AxiBus.WriteData.User'length)) ;
--    SetAxi4Parameter(Params, WID,       to_slv(0, AxiBus.WriteData.ID'length)) ;
--    -- Write Response
--    SetAxi4Parameter(Params, BRESP,     to_slv(0, AxiBus.WriteResponse.Resp'length)) ;
--    SetAxi4Parameter(Params, BID,       to_slv(0, AxiBus.WriteResponse.ID'length)) ;
--    SetAxi4Parameter(Params, BUSER,     to_slv(0, AxiBus.WriteResponse.User'length)) ;
--    -- Read Address
--    SetAxi4Parameter(Params, ARPROT,    to_slv(0, AxiBus.ReadAddress.Prot'length)) ;
--    SetAxi4Parameter(Params, ARID,      to_slv(0, AxiBus.ReadAddress.ID'length)) ;
--    SetAxi4Parameter(Params, ARSIZE,    to_slv(0, AxiBus.ReadAddress.Size'length)) ;
--    SetAxi4Parameter(Params, ARBURST,   to_slv(0, AxiBus.ReadAddress.Burst'length)) ;
--    SetAxi4Parameter(Params, ARLOCK,    to_slv(0, 1)) ;
--    SetAxi4Parameter(Params, ARCACHE,   to_slv(0, AxiBus.ReadAddress.Cache'length)) ;
--    SetAxi4Parameter(Params, ARQOS,     to_slv(0, AxiBus.ReadAddress.QOS'length)) ;
--    SetAxi4Parameter(Params, ARREGION,  to_slv(0, AxiBus.ReadAddress.Region'length)) ;
--    SetAxi4Parameter(Params, ARUSER,    to_slv(0, AxiBus.ReadAddress.User'length)) ;
--    -- Read Data
--    SetAxi4Parameter(Params, RRESP,     to_slv(0, AxiBus.ReadData.Resp'length)) ;
--    SetAxi4Parameter(Params, RID,       to_slv(0, AxiBus.ReadData.ID'length)) ;
--    SetAxi4Parameter(Params, RLAST,     to_slv(0, 1)) ;
--    SetAxi4Parameter(Params, RUSER,     to_slv(0, AxiBus.ReadData.User'length)) ;
  end procedure InitAxiOptions ;

end package body Axi4OptionsPkg ;
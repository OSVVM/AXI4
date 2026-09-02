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
use work.Axi4SettingsPkg.all ;

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

    CHECK_BID,
    CHECK_RID,

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
    AWLEN,
    AWSIZE,
    AWBURST,
    AWLOCK,
    AWCACHE,
    AWQOS,
    AWREGION,
    AWUSER,

    -- Write Data
    WDATA,
    WSTRB,
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
    ARLEN,
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
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    boolean
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    integer
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic_vector
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    Axi4RespEnumType
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   boolean
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   integer
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic_vector
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
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
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    boolean
  ) is
  begin
    if IsAxiParameter(Option) then
      Set(TransactionRec.Params, Axi4OptionsType'POS(Option), OptVal) ;
    else
      SetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), boolean'pos(OptVal)) ;
    end if ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic
  ) is
  begin
    if IsAxiParameter(Option) then
-- update when params supports std_ulogic
      Set(TransactionRec.Params, Axi4OptionsType'POS(Option), std_ulogic'pos(OptVal)) ;
    else
      SetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), std_ulogic'pos(OptVal)) ;
    end if ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    integer
  ) is
  begin
    if IsAxiParameter(Option) then
      Set(TransactionRec.Params, Axi4OptionsType'POS(Option), OptVal) ;
    else
      SetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), OptVal) ;
    end if ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic_vector
  ) is
  begin
    if IsAxiParameter(Option) then
      Set(TransactionRec.Params, Axi4OptionsType'POS(Option), OptVal) ;
    else
      SetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), OptVal) ;
    end if ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    Axi4RespEnumType
  ) is
  begin
    SetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), Axi4RespEnumType'pos(OptVal)) ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   boolean
  ) is
    variable IntOptVal : integer ;
  begin
    if IsAxiParameter(Option) then
      OptVal := Get(TransactionRec.Params, Axi4OptionsType'POS(Option)) ;
    else
      GetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), IntOptVal) ;
      OptVal := IntOptVal >= 1 ;
    end if ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic
  ) is
    variable IntOptVal : integer ;
  begin
    if IsAxiParameter(Option) then
-- update when params supports std_ulogic
      IntOptVal := Get(TransactionRec.Params, Axi4OptionsType'POS(Option)) ;
    else
      GetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), IntOptVal) ;
    end if ;
    OptVal := std_logic'val(IntOptVal) ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   integer
  ) is
  begin
    if IsAxiParameter(Option) then
      OptVal := Get(TransactionRec.Params, Axi4OptionsType'POS(Option)) ;
    else
      GetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), OptVal) ;
    end if ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic_vector
  ) is
  begin
    if IsAxiParameter(Option) then
      OptVal := Get(TransactionRec.Params, Axi4OptionsType'POS(Option)) ;
    else
      GetModelOptions(TransactionRec, Axi4OptionsType'POS(Option), OptVal) ;
    end if ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
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
    SetAxi4Parameter(Params, WRITE_ADDRESS_READY_TIME_OUT,       AXI4_DEFAULT_WRITE_ADDRESS_READY_TIME_OUT  ) ;
    SetAxi4Parameter(Params, WRITE_DATA_READY_TIME_OUT,          AXI4_DEFAULT_WRITE_DATA_READY_TIME_OUT     ) ;
    SetAxi4Parameter(Params, WRITE_RESPONSE_READY_TIME_OUT,      AXI4_DEFAULT_WRITE_RESPONSE_READY_TIME_OUT ) ; -- S
    SetAxi4Parameter(Params, READ_ADDRESS_READY_TIME_OUT,        AXI4_DEFAULT_READ_ADDRESS_READY_TIME_OUT   ) ;
    SetAxi4Parameter(Params, READ_DATA_READY_TIME_OUT,           AXI4_DEFAULT_READ_DATA_READY_TIME_OUT      ) ; -- S

    -- Ready Controls
    SetAxi4Parameter(Params, WRITE_ADDRESS_READY_BEFORE_VALID,   AXI4_DEFAULT_WRITE_ADDRESS_READY_BEFORE_VALID ) ; -- S
    SetAxi4Parameter(Params, WRITE_DATA_READY_BEFORE_VALID,      AXI4_DEFAULT_WRITE_DATA_READY_BEFORE_VALID    ) ; -- S
    SetAxi4Parameter(Params, WRITE_RESPONSE_READY_BEFORE_VALID,  AXI4_DEFAULT_WRITE_RESPONSE_READY_BEFORE_VALID) ;
    SetAxi4Parameter(Params, READ_ADDRESS_READY_BEFORE_VALID,    AXI4_DEFAULT_READ_ADDRESS_READY_BEFORE_VALID  ) ; -- S
    SetAxi4Parameter(Params, READ_DATA_READY_BEFORE_VALID,       AXI4_DEFAULT_READ_DATA_READY_BEFORE_VALID     ) ;

    -- Ready Delay
    SetAxi4Parameter(Params, WRITE_ADDRESS_READY_DELAY_CYCLES,   AXI4_DEFAULT_WRITE_ADDRESS_READY_DELAY_CYCLES ) ;  -- S
    SetAxi4Parameter(Params, WRITE_DATA_READY_DELAY_CYCLES,      AXI4_DEFAULT_WRITE_DATA_READY_DELAY_CYCLES    ) ;  -- S
    SetAxi4Parameter(Params, WRITE_RESPONSE_READY_DELAY_CYCLES,  AXI4_DEFAULT_WRITE_RESPONSE_READY_DELAY_CYCLES) ;
    SetAxi4Parameter(Params, READ_ADDRESS_READY_DELAY_CYCLES,    AXI4_DEFAULT_READ_ADDRESS_READY_DELAY_CYCLES  ) ;  -- S
    SetAxi4Parameter(Params, READ_DATA_READY_DELAY_CYCLES,       AXI4_DEFAULT_READ_DATA_READY_DELAY_CYCLES     ) ;

    -- Valid Timeouts
    SetAxi4Parameter(Params, WRITE_RESPONSE_VALID_TIME_OUT,      AXI4_DEFAULT_WRITE_RESPONSE_VALID_TIME_OUT) ;
    SetAxi4Parameter(Params, READ_DATA_VALID_TIME_OUT,           AXI4_DEFAULT_READ_DATA_VALID_TIME_OUT     ) ;

    -- Valid Delays
    SetAxi4Parameter(Params, WRITE_ADDRESS_VALID_DELAY_CYCLES,     AXI4_DEFAULT_WRITE_ADDRESS_VALID_DELAY_CYCLES   ) ;
    SetAxi4Parameter(Params, WRITE_DATA_VALID_DELAY_CYCLES,        AXI4_DEFAULT_WRITE_DATA_VALID_DELAY_CYCLES      ) ;
    SetAxi4Parameter(Params, WRITE_DATA_VALID_BURST_DELAY_CYCLES,  AXI4_DEFAULT_WRITE_DATA_VALID_BURST_DELAY_CYCLES) ;
    SetAxi4Parameter(Params, WRITE_RESPONSE_VALID_DELAY_CYCLES,    AXI4_DEFAULT_WRITE_RESPONSE_VALID_DELAY_CYCLES  ) ;  -- S
    SetAxi4Parameter(Params, READ_ADDRESS_VALID_DELAY_CYCLES,      AXI4_DEFAULT_READ_ADDRESS_VALID_DELAY_CYCLES    ) ;
    SetAxi4Parameter(Params, READ_DATA_VALID_DELAY_CYCLES,         AXI4_DEFAULT_READ_DATA_VALID_DELAY_CYCLES       ) ;  -- S
    SetAxi4Parameter(Params, READ_DATA_VALID_BURST_DELAY_CYCLES,   AXI4_DEFAULT_READ_DATA_VALID_BURST_DELAY_CYCLES ) ;  -- S

    -- Write Data Filtering
    SetAxi4Parameter(Params, WRITE_DATA_FILTER_UNDRIVEN,            AXI4_DEFAULT_WRITE_DATA_FILTER_UNDRIVEN) ;
    SetAxi4Parameter(Params, WRITE_DATA_UNDRIVEN_VALUE,             AXI4_DEFAULT_WRITE_DATA_UNDRIVEN_VALUE ) ;

    SetAxi4Parameter(Params, CHECK_BID,                             AXI4_DEFAULT_CHECK_BID) ;
    SetAxi4Parameter(Params, CHECK_RID,                             AXI4_DEFAULT_CHECK_RID) ;
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

end package body Axi4OptionsPkg ;
--
--  File Name:         Axi4OptionsArrayPkg.vhd
--  Design Unit Name:  Axi4OptionsArrayPkg
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
--    10/2025   2025.10    Removed Axi4[Lite]InterfacePkg package references
--                         Added Support for Mode Views
--    11/2022   2022.11    Initial.  Derived from Axi4OptionsPkg
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2022 - 2025 by SynthWorks Design Inc.
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
use work.Axi4OptionsPkg.all ; 

package Axi4OptionsArrayPkg is

  --
  --  Abstraction Layer to support SetModelOptions using enumerated values
  --
  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    boolean
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    integer
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic_vector
  ) ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    Axi4RespEnumType
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   boolean
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   integer
  ) ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic_vector
  ) ;
  
  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   Axi4RespEnumType
  ) ;

end package Axi4OptionsArrayPkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body Axi4OptionsArrayPkg is

  --
  --  Abstraction Layer to support SetModelOptions using enumerated values
  --
  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    boolean
  ) is
  begin
    SetModelOptions(TransactionRec, Index, Axi4OptionsType'POS(Option), boolean'pos(OptVal)) ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic
  ) is
  begin
    SetModelOptions(TransactionRec, Index, Axi4OptionsType'POS(Option), std_logic'pos(OptVal)) ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    integer
  ) is
  begin
    SetModelOptions(TransactionRec, Index, Axi4OptionsType'POS(Option), OptVal) ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    std_logic_vector
  ) is
  begin
    SetModelOptions(TransactionRec, Index, Axi4OptionsType'POS(Option), OptVal) ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure SetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    constant OptVal         : In    Axi4RespEnumType
  ) is
  begin
    SetModelOptions(TransactionRec, Index, Axi4OptionsType'POS(Option), Axi4RespEnumType'pos(OptVal)) ;
  end procedure SetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   boolean
  ) is
    variable IntOptVal : integer ;
  begin
    GetModelOptions(TransactionRec, Index, Axi4OptionsType'POS(Option), IntOptVal) ;
    OptVal := IntOptVal >= 1 ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic
  ) is
    variable IntOptVal : integer ;
  begin
    GetModelOptions(TransactionRec, Index, Axi4OptionsType'POS(Option), IntOptVal) ;
    OptVal := std_logic'val(IntOptVal) ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   integer
  ) is
  begin
    GetModelOptions(TransactionRec, Index, Axi4OptionsType'POS(Option), OptVal) ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   std_logic_vector
  ) is
  begin
    GetModelOptions(TransactionRec, Index, Axi4OptionsType'POS(Option), OptVal) ;
  end procedure GetAxi4Options ;

  ------------------------------------------------------------
  procedure GetAxi4Options (
  ------------------------------------------------------------
    signal   TransactionRec : view (AddressBusTestCtrlView) of AddressBusRecArrayType ;
    constant Index          : In    integer ;
    constant Option         : In    Axi4OptionsType ;
    variable OptVal         : Out   Axi4RespEnumType
  ) is
    variable IntOptVal : integer ;
  begin
    GetModelOptions(TransactionRec, Index, Axi4OptionsType'POS(Option), IntOptVal) ;
    OptVal := Axi4RespEnumType'val(IntOptVal) ;
  end procedure GetAxi4Options ;


end package body Axi4OptionsArrayPkg ;
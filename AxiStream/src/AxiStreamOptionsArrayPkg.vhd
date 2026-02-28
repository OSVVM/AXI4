--
--  File Name:         AxiStreamOptionsArrayPkg.vhd
--  Design Unit Name:  AxiStreamOptionsArrayPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines an abstraction layer to define options settings
--      for AxiStream.
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    11/2022   2022.11    Initial revision.  Derrived from AxiStreamOptionsPkg
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2022 by SynthWorks Design Inc.
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
    
  use work.AxiStreamOptionsPkg.all ; 

package AxiStreamOptionsArrayPkg is


  -- ========================================================
  --  SetAxiStreamOptions / GetAxiStreamOptions
  --  Abstraction layer to SetAxiStreamOptions / GetAxiStreamOptions
  --  from StreamTransactionPkg.
  --  Allows calls to have enumerated values rather than constants.
  --  This way we do not need to manage constant values.
  --  Places std_logic_vector options in ParamToModel since
  --  they can be larger than DataToModel
  -- ========================================================

  ------------------------------------------------------------
  procedure SetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    integer
  ) ;

  ------------------------------------------------------------
  procedure SetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    boolean
  ) ;

  ------------------------------------------------------------
  procedure SetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    std_logic_vector
  ) ;

  ------------------------------------------------------------
  procedure GetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    variable OptVal      : Out   integer
  ) ;

  ------------------------------------------------------------
  procedure GetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    variable OptVal      : Out   boolean
  ) ;

  ------------------------------------------------------------
  procedure GetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    variable OptVal      : Out   std_logic_vector
  ) ;


end package AxiStreamOptionsArrayPkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body AxiStreamOptionsArrayPkg is

  -- ========================================================
  --  SetAxiStreamOptions / GetAxiStreamOptions
  --  For integer uses normal connections
  --  For std_logic_vector, uses ParamToModel/ParamFromModel
  -- ========================================================

  ------------------------------------------------------------
  procedure SetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    integer
  ) is
  begin
    SetModelOptions(TransRec, Index, AxiStreamOptionsType'POS(Option), OptVal) ;
  end procedure SetAxiStreamOptions ;

  ------------------------------------------------------------
  procedure SetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    boolean
  ) is
  begin
    SetModelOptions(TransRec, Index, AxiStreamOptionsType'POS(Option), OptVal) ;
  end procedure SetAxiStreamOptions ;

  ------------------------------------------------------------
  procedure SetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    std_logic_vector
  ) is
  begin
    TransRec(Index).ParamToModel <= ToTransaction(OptVal, TransRec(Index).ParamToModel'length) ;
    SetModelOptions(TransRec, Index, AxiStreamOptionsType'POS(Option)) ;
  end procedure SetAxiStreamOptions ;

  ------------------------------------------------------------
  procedure GetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    variable OptVal      : Out   integer
  ) is
  begin
    GetModelOptions(TransRec, Index, AxiStreamOptionsType'POS(Option), OptVal) ;
  end procedure GetAxiStreamOptions ;

  ------------------------------------------------------------
  procedure GetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    variable OptVal      : Out   boolean
  ) is
  begin
    GetModelOptions(TransRec, Index, AxiStreamOptionsType'POS(Option), OptVal) ;
  end procedure GetAxiStreamOptions ;

  ------------------------------------------------------------
  procedure GetAxiStreamOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecArrayType ;
    constant Index       : In    integer ;
    constant Option      : In    AxiStreamOptionsType ;
    variable OptVal      : Out   std_logic_vector
  ) is
  begin
    GetModelOptions(TransRec, Index, AxiStreamOptionsType'POS(Option)) ;
    OptVal := FromTransaction(TransRec(Index).ParamFromModel, OptVal'length) ;
  end procedure GetAxiStreamOptions ;

end package body AxiStreamOptionsArrayPkg ;
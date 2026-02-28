--
--  File Name:         Axi4InterfaceCommonPkg.vhd
--  Design Unit Name:  Axi4InterfaceCommonPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms to support the Axi4Lite interface to DUT
--      These are currently only intended for testbench models.
--      When VHDL-2018 intefaces gain popular support, these will be changed to support them. 
--          
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    10/2025   2025.10    Refactored and brought Axi4RespEnumType and conversions here
--    03/2022   2022.03    Factored out of Axi4InterfacePkg/Axi4LiteInterfacePkg
--    01/2020   2020.01    Updated license notice
--    09/2017   2017       Initial revision
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
  use ieee.numeric_std_unsigned.all ;
  

package Axi4InterfaceCommonPkg is 
  subtype Axi4ProtType is std_logic_vector(2 downto 0) ;
  --  [0] 0 Unprivileged access
  --      1 Privileged access
  --  [1] 0 Secure access
  --      1 Non-secure access
  --  [2] 0 Data access
  --      1 Instruction access
  constant AXI4_PROT_INIT   : Axi4ProtType := "ZZZ" ;

  -- Note the enum position number must match the interface value
  --                            00    01      10      11
  type     Axi4RespEnumType is (OKAY, EXOKAY, SLVERR, DECERR) ;
  subtype  Axi4RespType is std_logic_vector(1 downto 0) ;

  -- Create Axi4RespType / std_logic_vector constants
  constant AXI4_RESP_OKAY   : Axi4RespType := to_slv(Axi4RespEnumType'pos(OKAY  ), Axi4RespType'length) ;
  constant AXI4_RESP_EXOKAY : Axi4RespType := to_slv(Axi4RespEnumType'pos(EXOKAY), Axi4RespType'length) ; -- Not for Lite
  constant AXI4_RESP_SLVERR : Axi4RespType := to_slv(Axi4RespEnumType'pos(SLVERR), Axi4RespType'length)  ;
  constant AXI4_RESP_DECERR : Axi4RespType := to_slv(Axi4RespEnumType'pos(DECERR), Axi4RespType'length)  ;
  constant AXI4_RESP_INIT   : Axi4RespType := "ZZ" ;

--  type  Axi4UnresolvedRespEnumType is (OKAY, EXOKAY, SLVERR, DECERR) ;
--  type Axi4UnresolvedRespVectorEnumType is array (natural range <>) of Axi4UnresolvedRespEnumType ;
--  -- alias resolved_max is maximum[ Axi4UnresolvedRespVectorEnumType return Axi4UnresolvedRespEnumType] ;
--  -- Maximum is implicitly defined for any array type in VHDL-2008.   Function resolved_max is a fall back.
--  function resolved_max ( s : Axi4UnresolvedRespVectorEnumType) return Axi4UnresolvedRespEnumType ;
--  subtype Axi4RespEnumType is resolved_max Axi4UnresolvedRespEnumType ;

  function to_Axi4RespEnumType (a: Axi4RespType) return Axi4RespEnumType ;
  function to_Axi4RespEnumType (a: integer) return Axi4RespEnumType ;
  function from_Axi4RespEnumType (a: Axi4RespEnumType) return Axi4RespType ;
  function from_Axi4RespEnumType (a: Axi4RespEnumType) return integer ;

  alias to_Axi4RespType is from_Axi4RespEnumType[Axi4RespEnumType return Axi4RespType] ; 
  function from_Axi4RespType (a: Axi4RespType) return Axi4RespEnumType ;

end package Axi4InterfaceCommonPkg ;

package body Axi4InterfaceCommonPkg is 
  ------------------------------------------------------------
  -- in Axi4OptionsPkg
  function to_Axi4RespEnumType (a: Axi4RespType) return Axi4RespEnumType is
  begin
    return Axi4RespEnumType'val(to_integer(a)) ; 
  end function to_Axi4RespEnumType ;

  ------------------------------------------------------------
  -- in Axi4OptionsPkg
  function to_Axi4RespEnumType (a: integer) return Axi4RespEnumType is
  begin
    return Axi4RespEnumType'val(a) ; 
  end function to_Axi4RespEnumType ;

  ------------------------------------------------------------
  -- in VC via alias to_Axi4RespType
  function from_Axi4RespEnumType (a: Axi4RespEnumType) return Axi4RespType is
  begin
    return to_slv(Axi4RespEnumType'pos(a), Axi4RespType'length) ; 
  end function from_Axi4RespEnumType ;

  ------------------------------------------------------------
  -- in Axi4OptionsPkg
  function from_Axi4RespEnumType (a: Axi4RespEnumType) return integer is
  begin
    return Axi4RespEnumType'pos(a) ; 
  end function from_Axi4RespEnumType ;

  ------------------------------------------------------------
  function from_Axi4RespType (a: Axi4RespType) return Axi4RespEnumType is
  begin
    return Axi4RespEnumType'val(to_integer(a)) ;
  end function from_Axi4RespType ;
  

end package body Axi4InterfaceCommonPkg ;


  


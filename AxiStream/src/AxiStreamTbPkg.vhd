--
--  File Name:         AxiStreamTbPkg.vhd
--  Design Unit Name:  AxiStreamTbPkg
--  OSVVM Release:     OSVVM MODELS STANDARD VERSION
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
--    Date      Version    Description
--    2018.05   2018.05    Initial revision released as AxiStreamTransactionPkg
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

  use std.textio.all ;

library OSVVM ; 
  context OSVVM.OsvvmContext ;  

  
package AxiStreamTbPkg is 
  ------------------------------------------------------------
  function UpdateOptions (
  ------------------------------------------------------------
    Param     : std_logic_vector ;
    ParamID   : std_logic_vector ; 
    ParamDest : std_logic_vector ; 
    ParamUser : std_logic_vector ;
    ParamLast : integer ;
    Count     : integer 
  ) return std_logic_vector ;


end AxiStreamTbPkg ;

package body AxiStreamTbPkg is 

  ------------------------------------------------------------
  function UpdateOptions (
  ------------------------------------------------------------
    Param     : std_logic_vector ;
    ParamID   : std_logic_vector ; 
    ParamDest : std_logic_vector ; 
    ParamUser : std_logic_vector ;
    ParamLast : integer ;
    Count     : integer 
  ) return std_logic_vector is
    constant PARAM_LEN : integer := Param'length ; 
    constant ID_LEN    : integer := ParamID'length ; 
    constant DEST_LEN  : integer := ParamDest'length ; 
    constant USER_LEN  : integer := ParamUser'length ; 
    variable ResultParam : std_logic_vector(PARAM_LEN -1 downto 0) ; 
    
    constant ID_RIGHT    : integer := DEST_LEN + USER_LEN + 1 ; 
    constant DEST_RIGHT  : integer := USER_LEN + 1 ;
    constant USER_RIGHT  : integer := 1 ; 
    alias Last  : std_logic is ResultParam(0) ;
  begin    
    ResultParam := Param ;
    
    if ID_LEN > 0 and ResultParam(ID_RIGHT) = '-' then
      ResultParam(PARAM_LEN-1 downto ID_RIGHT) := ParamID ; 
    end if ; 
    
    if DEST_LEN > 0 and ResultParam(DEST_RIGHT) = '-' then 
      ResultParam(ID_RIGHT-1 downto DEST_RIGHT) := ParamDest ; 
    end if ; 
    
    if USER_LEN > 0 and ResultParam(USER_RIGHT) = '-' then 
      ResultParam(DEST_RIGHT-1 downto USER_RIGHT) := ParamUser ; 
    end if ; 
    
    -- Calculate Last.  
    if Last = '-' then  -- use defaults
      if ParamLast <= 1 then 
        Last := '1' when ParamLast = 1 else '0' ; 
      else 
        -- generate last once every ParamLast cycles
        Last := '1' when (Count mod ParamLast) = 0 else '0' ; 
      end if ; 
    end if ; 
    return ResultParam ; 
  end function UpdateOptions ; 
    
end AxiStreamTbPkg ;

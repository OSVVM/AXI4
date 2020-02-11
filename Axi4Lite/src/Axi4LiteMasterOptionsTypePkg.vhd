--
--  File Name:         Axi4LiteMasterOptionsTypePkg.vhd
--  Design Unit Name:  Axi4LiteMasterOptionsTypePkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms used by
--      OSVVM Address Bus Master Transaction Based Models (aka: TBM, TLM, VVC)
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    09/2017   2017       Initial revision
--    01/2020   2020.01    Updated license notice
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2017 - 2020 by SynthWorks Design Inc.  
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

package Axi4LiteMasterOptionsTypePkg is

  -- AXI4 Model Options
  type Axi4UnresolvedMasterOptionsType is (
    --
    -- Master Ready TimeOut Checks
    WRITE_ADDRESS_READY_TIME_OUT,
    WRITE_DATA_READY_TIME_OUT,
    READ_ADDRESS_READY_TIME_OUT,
    -- Master Valid TimeOut Checks
    WRITE_RESPONSE_VALID_TIME_OUT,
    READ_DATA_VALID_TIME_OUT,
    --
    -- Master Ready Before Valid
    WRITE_RESPONSE_READY_BEFORE_VALID,
    READ_DATA_READY_BEFORE_VALID,
    --
    -- Master Ready Delay Cycles
    WRITE_RESPONSE_READY_DELAY_CYCLES,
    READ_DATA_READY_DELAY_CYCLES,
    --
    -- Master PROT Settings
    READ_PROT,
    WRITE_PROT,
    
    -- Master RESP Settings
    WRITE_RESP,
    READ_RESP,

    --
    -- The End -- Done
    THE_END
  ) ;
  type Axi4UnresolvedMasterOptionsVectorType is array (natural range <>) of Axi4UnresolvedMasterOptionsType ;
  -- alias resolved_max is maximum[ Axi4UnresolvedMasterOptionsVectorType return Axi4UnresolvedMasterOptionsType] ;
  function resolved_max(A : Axi4UnresolvedMasterOptionsVectorType) return Axi4UnresolvedMasterOptionsType ;
  subtype Axi4LiteMasterOptionsType is resolved_max Axi4UnresolvedMasterOptionsType ;


end package Axi4LiteMasterOptionsTypePkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body Axi4LiteMasterOptionsTypePkg is

  function resolved_max ( A : Axi4UnresolvedMasterOptionsVectorType) return Axi4UnresolvedMasterOptionsType is
  begin
    return maximum(A) ;
  end function resolved_max ;

end package body Axi4LiteMasterOptionsTypePkg ;
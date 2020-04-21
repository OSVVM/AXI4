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
--    01/2020   2020.02    Refactored from Axi4LiteMasterTransactionPkg.vhd
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
  type Axi4LiteUnresolvedMasterOptionsType is (
    -- Write Address Settings
    WRITE_ADDRESS_READY_TIME_OUT,
    -- AXI
    WRITE_PROT,
    -- AXI4 Full
    WRITE_ADDRESS_ID,
    WRITE_ADDRESS_SIZE,
    WRITE_ADDRESS_BURST,
    WRITE_ADDRESS_LOCK,
    WRITE_ADDRESS_CACHE,
    WRITE_ADDRESS_QOS,
    WRITE_ADDRESS_REGION,
    WRITE_ADDRESS_USER,

    -- Write Data Settings
    WRITE_DATA_READY_TIME_OUT,
    -- AXI
    -- AXI4 Full
    WRITE_DATA_LAST,
    WRITE_DATA_USER,
    -- AXI3
    WRITE_DATA_ID,

    -- Write Response Settings
    WRITE_RESPONSE_VALID_TIME_OUT,
    WRITE_RESPONSE_READY_BEFORE_VALID,
    WRITE_RESPONSE_READY_DELAY_CYCLES,

    -- AXI
    WRITE_RESPONSE_RESP,
    -- AXI4 Full
    WRITE_RESPONSE_ID,
    WRITE_RESPONSE_USER,

    -- Read Address Settings
    READ_ADDRESS_READY_TIME_OUT,
    -- AXI
    READ_PROT,
    -- AXI4 Full
    Read_ADDRESS_ID,
    Read_ADDRESS_SIZE,
    Read_ADDRESS_BURST,
    Read_ADDRESS_LOCK,
    Read_ADDRESS_CACHE,
    Read_ADDRESS_QOS,
    Read_ADDRESS_REGION,
    Read_ADDRESS_USER,

    -- Read Data / Response Settings
    READ_DATA_VALID_TIME_OUT,
    READ_DATA_READY_BEFORE_VALID,
    READ_DATA_READY_DELAY_CYCLES,
    -- AXI
    READ_DATA_RESP,
    -- AXI4 Full
    READ_DATA_ID,
    READ_DATA_LAST,
    READ_DATA_USER,
    --
    -- The End -- Done
    THE_END
  ) ;
  type Axi4LiteUnresolvedMasterOptionsVectorType is array (natural range <>) of Axi4LiteUnresolvedMasterOptionsType ;
  -- alias resolved_max is maximum[ Axi4LiteUnresolvedMasterOptionsVectorType return Axi4LiteUnresolvedMasterOptionsType] ;
  function resolved_max(A : Axi4LiteUnresolvedMasterOptionsVectorType) return Axi4LiteUnresolvedMasterOptionsType ;
  subtype Axi4LiteMasterOptionsType is resolved_max Axi4LiteUnresolvedMasterOptionsType ;


end package Axi4LiteMasterOptionsTypePkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body Axi4LiteMasterOptionsTypePkg is

  function resolved_max ( A : Axi4LiteUnresolvedMasterOptionsVectorType) return Axi4LiteUnresolvedMasterOptionsType is
  begin
    return maximum(A) ;
  end function resolved_max ;

end package body Axi4LiteMasterOptionsTypePkg ;
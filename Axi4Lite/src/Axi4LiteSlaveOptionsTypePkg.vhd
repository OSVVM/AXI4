--
--  File Name:         Axi4LiteSlaveOptionsTypePkg.vhd
--  Design Unit Name:  Axi4LiteSlaveOptionsTypePkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms used by
--      OSVVM Address Bus Slave Transaction Based Models (aka: TBM, TLM, VVC)
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    01/2020   2020.02    Refactored from Axi4LiteSlaveTransactionPkg.vhd
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

package Axi4LiteSlaveOptionsTypePkg is
  -- AXI Model Options
  type Axi4LiteUnresolvedSlaveOptionsType is (
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
    -- Slave PROT Settings
    READ_PROT,
    WRITE_PROT,
    --
    -- Slave RESP Settings
    WRITE_RESP,
    READ_RESP,
    --
    -- The End -- Done
    THE_END
  ) ;
  type Axi4LiteUnresolvedSlaveOptionsVectorType is array (natural range <>) of Axi4LiteUnresolvedSlaveOptionsType ;
--  alias resolved_max is maximum[ Axi4LiteUnresolvedSlaveOptionsVectorType return Axi4LiteUnresolvedSlaveOptionsType] ;
  function resolved_max ( A : Axi4LiteUnresolvedSlaveOptionsVectorType) return Axi4LiteUnresolvedSlaveOptionsType ;

  subtype Axi4LiteSlaveOptionsType is resolved_max Axi4LiteUnresolvedSlaveOptionsType ;


end package Axi4LiteSlaveOptionsTypePkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body Axi4LiteSlaveOptionsTypePkg is

  function resolved_max ( A : Axi4LiteUnresolvedSlaveOptionsVectorType) return Axi4LiteUnresolvedSlaveOptionsType is
  begin
    return maximum(A) ;
  end function resolved_max ;


end package body Axi4LiteSlaveOptionsTypePkg ;
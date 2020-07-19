--
--  File Name:         Axi4LiteVersionCompatibilityPkg.vhd
--  Design Unit Name:  Axi4LiteVersionCompatibilityPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms used to
--      facilitate backward compatibility with AXI4 Models
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    01/2020   2020.02    Refactored from Axi4SlaveTransactionPkg.vhd
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

library osvvm ;
    context osvvm.OsvvmContext ;
    
library osvvm_common ;  
  context osvvm_common.OsvvmCommonContext ;
    
package Axi4VersionCompatibilityPkg is

  -- Translate from Axi4Lite interface names to new name:  AddressBusTransactionRecType
  alias MasterTransactionRecType is AddressBusTransactionRecType ; 
  alias Axi4LiteMasterTransactionRecType is AddressBusTransactionRecType ; 
  
  -- Translate from Axi4Lite interface names to new name:  AddressBusTransactionRecType
  alias Axi4LiteSlaveTransactionRecType is AddressBusTransactionRecType ; 

end package Axi4VersionCompatibilityPkg ;


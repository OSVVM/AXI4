--
--  File Name:         Axi4VersionCompatibilityPkg.vhd
--  Design Unit Name:  Axi4VersionCompatibilityPkg
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

--    use work.Axi4SlaveTransactionPkg.all ;
--    use work.Axi4MasterTransactionPkg.all ;
    
package Axi4VersionCompatibilityPkg is
  -- Temporary alias to allow older types to still work
  alias MasterTransactionRecType is AddressBusMasterTransactionRecType ; 
  alias Axi4MasterTransactionRecType is AddressBusMasterTransactionRecType ; 

  -- Temporary alias to allow older types to still work
  alias Axi4SlaveTransactionRecType is AddressBusSlaveTransactionRecType ; 

end package Axi4VersionCompatibilityPkg ;


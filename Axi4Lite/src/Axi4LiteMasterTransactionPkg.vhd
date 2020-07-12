--
--  File Name:         Axi4LiteMasterTransactionPkg.vhd
--  Design Unit Name:  Axi4LiteMasterTransactionPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          email:  jim@synthworks.com
--
--
--  Description:
--    Instance of AddressBusMasterTransactionGenericPkg for Axi4LiteMasterOptionsType
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    01/2020   2020.02    Refactored old Axi4LiteMasterTransactionPkg to AddressBusMasterTransactionGenericPkg
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2020 by SynthWorks Design Inc.  
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

use work.Axi4LiteMasterOptionsTypePkg.all ;

library OSVVM_Common ;

package Axi4LiteMasterTransactionPkg is new OSVVM_Common.AddressBusMasterTransactionGenericPkg
  generic map (
    ModelOptionsType    => Axi4LiteMasterOptionsType    
  ) ;  

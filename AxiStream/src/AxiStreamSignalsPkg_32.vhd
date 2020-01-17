--
--  File Name:         AxiStreamGenericSignalsPkg.vhd
--  Design Unit Name:  AxiStreamGenericSignalsPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--
--  Description
--      Context Declaration for OSVVM packages
--
--  Developed by/for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:      
--    Date      Version    Description
--    01/2010   2019.01    Initial Revision
--    01/2020   2020.01    Updated license notice
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2019 - 2020 by SynthWorks Design Inc.  
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

library osvvm ;
    context osvvm.OsvvmContext ;

library osvvm_axi4 ;
    context osvvm_axi4.AxiStreamContext ;
    
package AxiStreamSignalsPkg_32 is new work.AxiStreamGenericSignalsPkg
  generic map (
    AXI_DATA_WIDTH   => 32, 
    AXI_BYTE_WIDTH   => 32/8, 
    TID_MAX_WIDTH    => 8,
    TDEST_MAX_WIDTH  => 4,
    TUSER_MAX_WIDTH  => 1 * 32/8
  ) ;  

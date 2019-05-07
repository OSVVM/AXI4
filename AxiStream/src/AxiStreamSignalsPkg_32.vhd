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
--  Latest standard version available at:
--        http://www.SynthWorks.com/downloads
--
--  Revision History:      
--    Date      Version    Description
--    01/2010   2019.01    Initial Revision
--
--
--  Copyright (c) 2019 by SynthWorks Design Inc.  All rights reserved.
--
--  Verbatim copies of this source file may be used and
--  distributed without restriction.
--
--  This source file is free software; you can redistribute it
--  and/or modify it under the terms of the ARTISTIC License
--  as published by The Perl Foundation; either version 2.0 of
--  the License, or (at your option) any later version.
--
--  This source is distributed in the hope that it will be
--  useful, but WITHOUT ANY WARRANTY; without even the implied
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
--  PURPOSE. See the Artistic License for details.
--
--  You should have received a copy of the license with this source.
--  If not download it from,
--     http://www.perlfoundation.org/artistic_license_2_0
--
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

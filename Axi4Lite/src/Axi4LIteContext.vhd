--
--  File Name:         Axi4LiteContext.vhd
--  Design Unit Name:  Axi4LiteContext
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--
--  Description
--      Context Declaration for Axi4Lite packages
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
--    03/2019   2019.03    Initial Revision
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

context Axi4LiteContext is
    library osvvm_axi4 ;  
    
    use osvvm_axi4.Axi4CommonPkg.all ; 
    use osvvm_axi4.Axi4LiteInterfacePkg.all ; 
    
    use osvvm_axi4.Axi4LiteMasterTransactionPkg.all ; 
    use osvvm_axi4.Axi4LiteSlaveTransactionPkg.all ;
    use osvvm_axi4.Axi4LiteMasterComponentPkg.all ; 
    use osvvm_axi4.Axi4LiteSlaveComponentPkg.all ;
    use osvvm_axi4.Axi4LiteMonitorComponentPkg.all ;

end context Axi4LiteContext ; 
--
--  File Name:         Axi4LiteContext.vhd
--  Design Unit Name:  Axi4LiteContext
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--
--  Description
--      Context Declaration for using Axi4 models
--
--  Developed by/for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    03/2019   2019.03    Initial Revision
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

context Axi4LiteContext is
    library osvvm_common ;  
    context osvvm_common.OsvvmCommonContext ;
      
    library osvvm_Axi4 ;

    use osvvm_Axi4.Axi4CommonPkg.all ;
    use osvvm_Axi4.Axi4InterfaceCommonPkg.all ;
    use osvvm_Axi4.Axi4LiteInterfacePkg.all ;

    use osvvm_Axi4.Axi4OptionsPkg.all ; 
    use osvvm_Axi4.Axi4ModelPkg.all ;
    
    use osvvm_Axi4.Axi4LiteComponentPkg.all ;
    
    -- Temporary inclusion of Axi4 things that become deprecated with changes
    use osvvm_Axi4.Axi4VersionCompatibilityPkg.all ;

end context Axi4LiteContext ;
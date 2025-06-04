--
--  File Name:         OsvvmTestCommonPkg.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Locate the directory for the Validated Results
--      Alternately set CHECK_TRANSCRIPT to FALSE and Validated Results is not necessary
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    02/2025   2025.02    Static paths break.  Using VHDL-2019 FILE_PATH
--    10/2020   2020.10    Initial revision
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

library OSVVM ; 
context OSVVM.OsvvmContext ; 
-- use std.env.all ; -- see osvvm/FileLinePathPkg.vhd

package OsvvmTestCommonPkg is
  constant RESULTS_DIR                     : string := "" ;
--  constant PATH_TO_OsvvmTestCommonPkg      : string := "C:/OsvvmLibraries/AXI4/AxiStream/TestCases" ;  -- OSVVM Dev Setting
  constant PATH_TO_OsvvmTestCommonPkg      : string := FILE_PATH ;
  constant AXISTREAM_VALIDATED_RESULTS_DIR : string := PATH_TO_OsvvmTestCommonPkg & "/../ValidatedResults" ;
--  constant AXISTREAM_VALIDATED_RESULTS_DIR : string := std.env.FILE_PATH & "/../ValidatedResults" ; 
--  constant CHECK_TRANSCRIPT                : boolean := TRUE ; -- OSVVM Dev Setting
  constant CHECK_TRANSCRIPT                : boolean := PATH_TO_OsvvmTestCommonPkg'length > 0 ;
end package OsvvmTestCommonPkg ; 

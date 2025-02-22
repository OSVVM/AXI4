#  File Name:         OsvvmTestCommonPkg.pro
#  Revision:          STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        Compile OsvvmTestCommonPkg.vhd  
#
#  Developed for:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Date      Version    Description
#    02/2025   2025.02    Initial
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2025 by SynthWorks Design Inc.  
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#      https://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  

  analyze ../TestCases/OsvvmTestCommonPkg.vhd

#   if {$::osvvm::Support2019FilePath} {
#     analyze ../TestCases/OsvvmTestCommonPkg.vhd
#   } else {
#     # Need for NVC.  NVC has implemented implemented FILE_PATH, however its implementation is incorrect
#     analyze ../TestCases/deprecated/OsvvmTestCommonPkg_NoFilePath.vhd
#   }

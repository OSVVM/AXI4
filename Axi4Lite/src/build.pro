#  File Name:         build.pro
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        Script to compile the Axi4 Lite models  
#
#  Developed for:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Version    Description
#    2025.06    refactored
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
library osvvm_axi4
analyze Axi4LiteComponentPkg.vhd
analyze Axi4LiteComponentVtiPkg.vhd
analyze Axi4LiteInterfacePkg.vhd
analyze Axi4LiteContext.vhd

analyze Axi4LiteManager.vhd
analyze Axi4LiteManagerVti.vhd
analyze Axi4LiteMonitor_dummy.vhd
analyze Axi4LiteSubordinate.vhd
analyze Axi4LiteSubordinateVti.vhd
analyze Axi4LiteMemory.vhd
analyze Axi4LiteMemoryVti.vhd
analyze Axi4LitePassThru.vhd

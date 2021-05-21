#  File Name:         testbench.pro
#  Revision:          STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        Script to run one Axi Stream test  
#
#  Developed for:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Date      Version    Description
#     1/2019   2019.01    Compile Script for OSVVM
#     1/2020   2020.01    Updated Licenses to Apache
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2019 - 2020 by SynthWorks Design Inc.  
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

##
## runs in conjunction with either 
## Testbench/Testbench.pro or TestbenchVTI/TestbenchVTI.pro
## Continuing with library set previously by the above
##
##

## Burst
analyze  TbAxi4_MemoryBurst1.vhd
simulate TbAxi4_MemoryBurst1
analyze  TbAxi4_MemoryBurstAsync1.vhd
simulate TbAxi4_MemoryBurstAsync1
analyze  TbAxi4_MemoryBurstByte1.vhd
simulate TbAxi4_MemoryBurstByte1
analyze  TbAxi4_MemoryBurstSparse1.vhd
simulate TbAxi4_MemoryBurstSparse1

analyze  TbAxi4_ReleaseAcquireMaster1.vhd
simulate TbAxi4_ReleaseAcquireMaster1

analyze  TbAxi4_AxSizeMasterMemory1.vhd
simulate TbAxi4_AxSizeMasterMemory1
analyze  TbAxi4_AxSizeMasterMemory2.vhd
simulate TbAxi4_AxSizeMasterMemory2

analyze  TbAxi4_AxiIfOptionsMasterMemory.vhd
simulate TbAxi4_AxiIfOptionsMasterMemory

analyze  TbAxi4_TransactionApiMasterBurst.vhd
simulate TbAxi4_TransactionApiMasterBurst
analyze  TbAxi4_TransactionApiMemoryBurst.vhd
simulate TbAxi4_TransactionApiMemoryBurst

analyze  TbAxi4_ValidTimingBurstMaster.vhd
simulate TbAxi4_ValidTimingBurstMaster
analyze  TbAxi4_ValidTimingBurstMemory.vhd
simulate TbAxi4_ValidTimingBurstMemory




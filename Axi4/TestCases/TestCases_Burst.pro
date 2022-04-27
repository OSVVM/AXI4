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
RunTest  TbAxi4_MemoryBurst1.vhd
RunTest  TbAxi4_MemoryBurstAsync1.vhd
RunTest  TbAxi4_MemoryBurstByte1.vhd

RunTest  TbAxi4_MemoryReadWriteDemo1.vhd

RunTest  TbAxi4_MemoryBurstPattern1.vhd
RunTest  TbAxi4_MemoryBurstPattern2.vhd
RunTest  TbAxi4_MemoryBurstBytePattern1.vhd
RunTest  TbAxi4_MemoryBurstAsyncPattern1.vhd
RunTest  TbAxi4_MemoryBurstAsyncPattern2.vhd

RunTest  TbAxi4_MemoryBurstSparse1.vhd

RunTest  TbAxi4_ReleaseAcquireManager1.vhd

RunTest  TbAxi4_AxSizeManagerMemory1.vhd
RunTest  TbAxi4_AxSizeManagerMemory2.vhd

RunTest  TbAxi4_AxiIfOptionsManagerMemory.vhd

RunTest  TbAxi4_TransactionApiManagerBurst.vhd
RunTest  TbAxi4_TransactionApiMemoryBurst.vhd

RunTest  TbAxi4_ValidTimingBurstManager.vhd
RunTest  TbAxi4_ValidTimingBurstMemory.vhd




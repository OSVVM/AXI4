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
# Tests for any AXI4 MIT
analyze  TbAxi4_BasicReadWrite.vhd
simulate TbAxi4_BasicReadWrite
analyze  TbAxi4_RandomReadWrite.vhd
simulate TbAxi4_RandomReadWrite
analyze  TbAxi4_RandomReadWriteByte1.vhd
simulate TbAxi4_RandomReadWriteByte1

analyze  TbAxi4_SubordinateReadWrite1.vhd
simulate TbAxi4_SubordinateReadWrite1
analyze  TbAxi4_SubordinateReadWrite2.vhd
simulate TbAxi4_SubordinateReadWrite2
analyze  TbAxi4_SubordinateReadWrite3.vhd
simulate TbAxi4_SubordinateReadWrite3

analyze  TbAxi4_ReadWriteAsync1.vhd
simulate TbAxi4_ReadWriteAsync1
analyze  TbAxi4_ReadWriteAsync2.vhd
simulate TbAxi4_ReadWriteAsync2
analyze  TbAxi4_ReadWriteAsync3.vhd
simulate TbAxi4_ReadWriteAsync3
analyze  TbAxi4_ReadWriteAsync4.vhd
simulate TbAxi4_ReadWriteAsync4

analyze  TbAxi4_SubordinateReadWriteAsync1.vhd
simulate TbAxi4_SubordinateReadWriteAsync1
analyze  TbAxi4_SubordinateReadWriteAsync2.vhd
simulate TbAxi4_SubordinateReadWriteAsync2

analyze  TbAxi4_MultipleDriversManager.vhd
simulate TbAxi4_MultipleDriversManager
analyze  TbAxi4_MultipleDriversSubordinate.vhd
simulate TbAxi4_MultipleDriversSubordinate

analyze  TbAxi4_ReleaseAcquireSubordinate1.vhd
simulate TbAxi4_ReleaseAcquireSubordinate1

analyze  TbAxi4_AlertLogIDManager.vhd
simulate TbAxi4_AlertLogIDManager
analyze  TbAxi4_AlertLogIDSubordinate.vhd
simulate TbAxi4_AlertLogIDSubordinate

analyze  TbAxi4_TransactionApiSubordinate.vhd
simulate TbAxi4_TransactionApiSubordinate

analyze  TbAxi4_ValidTimingManager.vhd
simulate TbAxi4_ValidTimingManager
analyze  TbAxi4_ValidTimingSubordinate.vhd
simulate TbAxi4_ValidTimingSubordinate

analyze  TbAxi4_ReadyTimingSubordinate.vhd
simulate TbAxi4_ReadyTimingSubordinate

analyze  TbAxi4_AxiIfOptionsManagerSubordinate.vhd
simulate TbAxi4_AxiIfOptionsManagerSubordinate

analyze  TbAxi4_TimeOutManager.vhd
simulate TbAxi4_TimeOutManager
analyze  TbAxi4_TimeOutSubordinate.vhd
simulate TbAxi4_TimeOutSubordinate

## Memory
analyze  TbAxi4_MemoryReadWrite1.vhd
simulate TbAxi4_MemoryReadWrite1
analyze  TbAxi4_MemoryReadWrite2.vhd
simulate TbAxi4_MemoryReadWrite2

analyze  TbAxi4_MultipleDriversMemory.vhd
simulate TbAxi4_MultipleDriversMemory

analyze  TbAxi4_ReleaseAcquireMemory1.vhd
simulate TbAxi4_ReleaseAcquireMemory1

analyze  TbAxi4_AlertLogIDMemory.vhd
simulate TbAxi4_AlertLogIDMemory

analyze  TbAxi4_TimeOutMemory.vhd
simulate TbAxi4_TimeOutMemory

analyze  TbAxi4_TransactionApiManager.vhd
simulate TbAxi4_TransactionApiManager
analyze  TbAxi4_TransactionApiMemory.vhd
simulate TbAxi4_TransactionApiMemory

analyze  TbAxi4_ValidTimingMemory.vhd
simulate TbAxi4_ValidTimingMemory

analyze  TbAxi4_ReadyTimingManager.vhd
simulate TbAxi4_ReadyTimingManager

analyze  TbAxi4_ReadyTimingMemory.vhd
simulate TbAxi4_ReadyTimingMemory

analyze  TbAxi4_MemoryAsync.vhd
simulate TbAxi4_MemoryAsync


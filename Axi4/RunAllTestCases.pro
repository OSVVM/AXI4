#  File Name:         RunAllTests.pro
#  Revision:          STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        Script to run all Axi4 tests  
#
#  Developed for:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Date      Version    Description
#     1/2019   2019.01    Compile Script for AXI4
#     1/2020   2020.01    Updated Licenses to Apache
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

analyze ./TestCases/TbAxi4_BasicReadWrite.vhd
analyze ./TestCases/TbAxi4_RandomReadWrite.vhd
analyze ./TestCases/TbAxi4_RandomReadWriteByte1.vhd

analyze ./TestCases/TbAxi4_MemoryReadWrite1.vhd
analyze ./TestCases/TbAxi4_MemoryReadWrite2.vhd
analyze ./TestCases/TbAxi4_MemoryBurst1.vhd
analyze ./TestCases/TbAxi4_MemoryBurstAsync1.vhd
analyze ./TestCases/TbAxi4_MemoryBurstByte1.vhd
analyze ./TestCases/TbAxi4_MemoryBurstSparse1.vhd

analyze ./TestCases/TbAxi4_MultipleDriversManager.vhd
analyze ./TestCases/TbAxi4_MultipleDriversSubordinate.vhd
analyze ./TestCases/TbAxi4_MultipleDriversMemory.vhd

analyze ./TestCases/TbAxi4_ReleaseAcquireManager1.vhd
analyze ./TestCases/TbAxi4_ReleaseAcquireMemory1.vhd
analyze ./TestCases/TbAxi4_ReleaseAcquireSubordinate1.vhd

analyze ./TestCases/TbAxi4_AlertLogIDManager.vhd
analyze ./TestCases/TbAxi4_AlertLogIDSubordinate.vhd
analyze ./TestCases/TbAxi4_AlertLogIDMemory.vhd

analyze ./TestCases/TbAxi4_ReadWriteAsync1.vhd
analyze ./TestCases/TbAxi4_ReadWriteAsync2.vhd
analyze ./TestCases/TbAxi4_ReadWriteAsync3.vhd
analyze ./TestCases/TbAxi4_ReadWriteAsync4.vhd

analyze ./TestCases/TbAxi4_SubordinateReadWrite1.vhd
analyze ./TestCases/TbAxi4_SubordinateReadWrite2.vhd
analyze ./TestCases/TbAxi4_SubordinateReadWrite3.vhd

analyze ./TestCases/TbAxi4_SubordinateReadWriteAsync1.vhd
analyze ./TestCases/TbAxi4_SubordinateReadWriteAsync2.vhd

analyze ./TestCases/TbAxi4_TransactionApiManager.vhd
analyze ./TestCases/TbAxi4_TransactionApiManagerBurst.vhd
analyze ./TestCases/TbAxi4_TransactionApiMemory.vhd
analyze ./TestCases/TbAxi4_TransactionApiMemoryBurst.vhd
analyze ./TestCases/TbAxi4_TransactionApiSubordinate.vhd

analyze ./TestCases/TbAxi4_ValidTimingManager.vhd
analyze ./TestCases/TbAxi4_ValidTimingMemory.vhd
analyze ./TestCases/TbAxi4_ValidTimingSubordinate.vhd
analyze ./TestCases/TbAxi4_ValidTimingBurstManager.vhd
analyze ./TestCases/TbAxi4_ValidTimingBurstMemory.vhd

analyze ./TestCases/TbAxi4_ReadyTimingManager.vhd
analyze ./TestCases/TbAxi4_ReadyTimingSubordinate.vhd
analyze ./TestCases/TbAxi4_ReadyTimingMemory.vhd

analyze ./TestCases/TbAxi4_AxiIfOptionsManagerMemory.vhd
analyze ./TestCases/TbAxi4_AxiIfOptionsManagerSubordinate.vhd

analyze ./TestCases/TbAxi4_AxSizeManagerMemory1.vhd
analyze ./TestCases/TbAxi4_AxSizeManagerMemory2.vhd

analyze ./TestCases/TbAxi4_TimeOutManager.vhd
analyze ./TestCases/TbAxi4_TimeOutSubordinate.vhd
analyze ./TestCases/TbAxi4_TimeOutMemory.vhd

analyze ./TestCases/TbAxi4_MemoryAsync.vhd


simulate TbAxi4_BasicReadWrite
simulate TbAxi4_RandomReadWrite
simulate TbAxi4_RandomReadWriteByte1

simulate TbAxi4_MemoryReadWrite1
simulate TbAxi4_MemoryReadWrite2
simulate TbAxi4_MemoryBurst1
simulate TbAxi4_MemoryBurstAsync1
simulate TbAxi4_MemoryBurstByte1
simulate TbAxi4_MemoryBurstSparse1

simulate TbAxi4_MultipleDriversManager
simulate TbAxi4_MultipleDriversSubordinate
simulate TbAxi4_MultipleDriversMemory

simulate TbAxi4_ReleaseAcquireManager1
simulate TbAxi4_ReleaseAcquireMemory1
simulate TbAxi4_ReleaseAcquireSubordinate1

simulate TbAxi4_AlertLogIDManager
simulate TbAxi4_AlertLogIDSubordinate
simulate TbAxi4_AlertLogIDMemory

simulate TbAxi4_ReadWriteAsync1
simulate TbAxi4_ReadWriteAsync2
simulate TbAxi4_ReadWriteAsync3
simulate TbAxi4_ReadWriteAsync4

simulate TbAxi4_SubordinateReadWrite1
simulate TbAxi4_SubordinateReadWrite2
simulate TbAxi4_SubordinateReadWrite3

simulate TbAxi4_SubordinateReadWriteAsync1
simulate TbAxi4_SubordinateReadWriteAsync2

simulate TbAxi4_TransactionApiManager
simulate TbAxi4_TransactionApiManagerBurst
simulate TbAxi4_TransactionApiMemory
simulate TbAxi4_TransactionApiMemoryBurst
simulate TbAxi4_TransactionApiSubordinate

simulate TbAxi4_ValidTimingManager
simulate TbAxi4_ValidTimingMemory
simulate TbAxi4_ValidTimingSubordinate
simulate TbAxi4_ValidTimingBurstManager
simulate TbAxi4_ValidTimingBurstMemory

simulate TbAxi4_ReadyTimingManager
simulate TbAxi4_ReadyTimingSubordinate
simulate TbAxi4_ReadyTimingMemory

simulate TbAxi4_AxiIfOptionsManagerMemory
simulate TbAxi4_AxiIfOptionsManagerSubordinate

simulate TbAxi4_AxSizeManagerMemory1
simulate TbAxi4_AxSizeManagerMemory2

simulate TbAxi4_TimeOutManager
simulate TbAxi4_TimeOutSubordinate
simulate TbAxi4_TimeOutMemory

simulate TbAxi4_MemoryAsync
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

analyze ./TestCases/TbAxi4_MultipleDriversMaster.vhd
analyze ./TestCases/TbAxi4_MultipleDriversResponder.vhd
analyze ./TestCases/TbAxi4_MultipleDriversMemory.vhd

analyze ./TestCases/TbAxi4_ReleaseAcquireMaster1.vhd
analyze ./TestCases/TbAxi4_ReleaseAcquireMemory1.vhd
analyze ./TestCases/TbAxi4_ReleaseAcquireResponder1.vhd

analyze ./TestCases/TbAxi4_AlertLogIDMaster.vhd
analyze ./TestCases/TbAxi4_AlertLogIDResponder.vhd
analyze ./TestCases/TbAxi4_AlertLogIDMemory.vhd

analyze ./TestCases/TbAxi4_ReadWriteAsync1.vhd
analyze ./TestCases/TbAxi4_ReadWriteAsync2.vhd
analyze ./TestCases/TbAxi4_ReadWriteAsync3.vhd
analyze ./TestCases/TbAxi4_ReadWriteAsync4.vhd

analyze ./TestCases/TbAxi4_ResponderReadWrite1.vhd
analyze ./TestCases/TbAxi4_ResponderReadWrite2.vhd
analyze ./TestCases/TbAxi4_ResponderReadWrite3.vhd

analyze ./TestCases/TbAxi4_ResponderReadWriteAsync1.vhd
analyze ./TestCases/TbAxi4_ResponderReadWriteAsync2.vhd

analyze ./TestCases/TbAxi4_TransactionApiMaster.vhd
analyze ./TestCases/TbAxi4_TransactionApiMasterBurst.vhd
analyze ./TestCases/TbAxi4_TransactionApiMemory.vhd
analyze ./TestCases/TbAxi4_TransactionApiMemoryBurst.vhd
analyze ./TestCases/TbAxi4_TransactionApiResponder.vhd

analyze ./TestCases/TbAxi4_ValidTimingMaster.vhd
analyze ./TestCases/TbAxi4_ValidTimingMemory.vhd
analyze ./TestCases/TbAxi4_ValidTimingResponder.vhd
analyze ./TestCases/TbAxi4_ValidTimingBurstMaster.vhd
analyze ./TestCases/TbAxi4_ValidTimingBurstMemory.vhd

analyze ./TestCases/TbAxi4_ReadyTimingMaster.vhd
analyze ./TestCases/TbAxi4_ReadyTimingResponder.vhd
analyze ./TestCases/TbAxi4_ReadyTimingMemory.vhd

analyze ./TestCases/TbAxi4_AxiIfOptionsMasterMemory.vhd
analyze ./TestCases/TbAxi4_AxiIfOptionsMasterResponder.vhd

analyze ./TestCases/TbAxi4_AxSizeMasterMemory1.vhd
analyze ./TestCases/TbAxi4_AxSizeMasterMemory2.vhd

analyze ./TestCases/TbAxi4_TimeOutMaster.vhd
analyze ./TestCases/TbAxi4_TimeOutResponder.vhd
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

simulate TbAxi4_MultipleDriversMaster
simulate TbAxi4_MultipleDriversResponder
simulate TbAxi4_MultipleDriversMemory

simulate TbAxi4_ReleaseAcquireMaster1
simulate TbAxi4_ReleaseAcquireMemory1
simulate TbAxi4_ReleaseAcquireResponder1

simulate TbAxi4_AlertLogIDMaster
simulate TbAxi4_AlertLogIDResponder
simulate TbAxi4_AlertLogIDMemory

simulate TbAxi4_ReadWriteAsync1
simulate TbAxi4_ReadWriteAsync2
simulate TbAxi4_ReadWriteAsync3
simulate TbAxi4_ReadWriteAsync4

simulate TbAxi4_ResponderReadWrite1
simulate TbAxi4_ResponderReadWrite2
simulate TbAxi4_ResponderReadWrite3

simulate TbAxi4_ResponderReadWriteAsync1
simulate TbAxi4_ResponderReadWriteAsync2

simulate TbAxi4_TransactionApiMaster
simulate TbAxi4_TransactionApiMasterBurst
simulate TbAxi4_TransactionApiMemory
simulate TbAxi4_TransactionApiMemoryBurst
simulate TbAxi4_TransactionApiResponder

simulate TbAxi4_ValidTimingMaster
simulate TbAxi4_ValidTimingMemory
simulate TbAxi4_ValidTimingResponder
simulate TbAxi4_ValidTimingBurstMaster
simulate TbAxi4_ValidTimingBurstMemory

simulate TbAxi4_ReadyTimingMaster
simulate TbAxi4_ReadyTimingResponder
simulate TbAxi4_ReadyTimingMemory

simulate TbAxi4_AxiIfOptionsMasterMemory
simulate TbAxi4_AxiIfOptionsMasterResponder

simulate TbAxi4_AxSizeMasterMemory1
simulate TbAxi4_AxSizeMasterMemory2

simulate TbAxi4_TimeOutMaster
simulate TbAxi4_TimeOutResponder
simulate TbAxi4_TimeOutMemory

simulate TbAxi4_MemoryAsync
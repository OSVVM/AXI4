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

analyze  TbAxi4_ResponderReadWrite1.vhd
simulate TbAxi4_ResponderReadWrite1
analyze  TbAxi4_ResponderReadWrite2.vhd
simulate TbAxi4_ResponderReadWrite2
analyze  TbAxi4_ResponderReadWrite3.vhd
simulate TbAxi4_ResponderReadWrite3

analyze  TbAxi4_ReadWriteAsync1.vhd
simulate TbAxi4_ReadWriteAsync1
analyze  TbAxi4_ReadWriteAsync2.vhd
simulate TbAxi4_ReadWriteAsync2
analyze  TbAxi4_ReadWriteAsync3.vhd
simulate TbAxi4_ReadWriteAsync3
analyze  TbAxi4_ReadWriteAsync4.vhd
simulate TbAxi4_ReadWriteAsync4

analyze  TbAxi4_ResponderReadWriteAsync1.vhd
simulate TbAxi4_ResponderReadWriteAsync1
analyze  TbAxi4_ResponderReadWriteAsync2.vhd
simulate TbAxi4_ResponderReadWriteAsync2

analyze  TbAxi4_MultipleDriversMaster.vhd
simulate TbAxi4_MultipleDriversMaster
analyze  TbAxi4_MultipleDriversResponder.vhd
simulate TbAxi4_MultipleDriversResponder

analyze  TbAxi4_ReleaseAcquireResponder1.vhd
simulate TbAxi4_ReleaseAcquireResponder1

analyze  TbAxi4_AlertLogIDMaster.vhd
simulate TbAxi4_AlertLogIDMaster
analyze  TbAxi4_AlertLogIDResponder.vhd
simulate TbAxi4_AlertLogIDResponder

analyze  TbAxi4_TransactionApiResponder.vhd
simulate TbAxi4_TransactionApiResponder

analyze  TbAxi4_ValidTimingMaster.vhd
simulate TbAxi4_ValidTimingMaster
analyze  TbAxi4_ValidTimingResponder.vhd
simulate TbAxi4_ValidTimingResponder

analyze  TbAxi4_ReadyTimingResponder.vhd
simulate TbAxi4_ReadyTimingResponder

analyze  TbAxi4_AxiIfOptionsMasterResponder.vhd
simulate TbAxi4_AxiIfOptionsMasterResponder

analyze  TbAxi4_TimeOutMaster.vhd
simulate TbAxi4_TimeOutMaster
analyze  TbAxi4_TimeOutResponder.vhd
simulate TbAxi4_TimeOutResponder

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

analyze  TbAxi4_TransactionApiMaster.vhd
simulate TbAxi4_TransactionApiMaster
analyze  TbAxi4_TransactionApiMemory.vhd
simulate TbAxi4_TransactionApiMemory

analyze  TbAxi4_ValidTimingMemory.vhd
simulate TbAxi4_ValidTimingMemory

analyze  TbAxi4_ReadyTimingMaster.vhd
simulate TbAxi4_ReadyTimingMaster

analyze  TbAxi4_ReadyTimingMemory.vhd
simulate TbAxi4_ReadyTimingMemory

analyze  TbAxi4_MemoryAsync.vhd
simulate TbAxi4_MemoryAsync


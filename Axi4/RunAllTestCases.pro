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

analyze ./TestCases/TbAxi4_BasicReadWrite.vhd
analyze ./TestCases/TbAxi4_RandomReadWrite.vhd
analyze ./TestCases/TbAxi4_RandomReadWriteByte.vhd
analyze ./TestCases/TbAxi4_MemoryReadWrite1.vhd
analyze ./TestCases/TbAxi4_MemoryReadWrite2.vhd
analyze ./TestCases/TbAxi4_MemoryBurst1.vhd
analyze ./TestCases/TbAxi4_MemoryBurstByte1.vhd

analyze ./TestCases/TbAxi4_ReadWriteAsync1.vhd
analyze ./TestCases/TbAxi4_ReadWriteAsync2.vhd
analyze ./TestCases/TbAxi4_ReadWriteAsync3.vhd
analyze ./TestCases/TbAxi4_ReadWriteAsync4.vhd

analyze ./TestCases/TbAxi4_MemoryAsync.vhd

analyze ./TestCases/TbAxi4_TimeOutMaster.vhd
analyze ./TestCases/TbAxi4_TimeOutResponder.vhd
analyze ./TestCases/TbAxi4_TimeOutMemory.vhd

analyze ./TestCases/TbAxi4_ReadyTimingMaster.vhd
analyze ./TestCases/TbAxi4_ReadyTimingResponder.vhd
analyze ./TestCases/TbAxi4_ReadyTimingMemory.vhd

analyze ./TestCases/TbAxi4_ValidTimingMaster.vhd
analyze ./TestCases/TbAxi4_ValidTimingMemory.vhd
analyze ./TestCases/TbAxi4_ValidTimingResponder.vhd
analyze ./TestCases/TbAxi4_ValidTimingBurstMaster.vhd
analyze ./TestCases/TbAxi4_ValidTimingBurstMemory.vhd


simulate TbAxi4_BasicReadWrite
simulate TbAxi4_RandomReadWrite    
simulate TbAxi4_RandomReadWriteByte    
simulate TbAxi4_MemoryReadWrite1
simulate TbAxi4_MemoryReadWrite2
simulate TbAxi4_MemoryBurst1
simulate TbAxi4_MemoryBurstByte1

simulate TbAxi4_ReadWriteAsync1    
simulate TbAxi4_ReadWriteAsync2    
simulate TbAxi4_ReadWriteAsync3  
simulate TbAxi4_ReadWriteAsync4  

simulate TbAxi4_MemoryAsync

simulate TbAxi4_TimeOutMaster    
simulate TbAxi4_TimeOutResponder    
simulate TbAxi4_TimeOutMemory    

simulate TbAxi4_ReadyTimingMaster
simulate TbAxi4_ReadyTimingResponder
simulate TbAxi4_ReadyTimingMemory

simulate TbAxi4_ValidTimingMaster
simulate TbAxi4_ValidTimingMemory
simulate TbAxi4_ValidTimingResponder
simulate TbAxi4_ValidTimingBurstMaster    
simulate TbAxi4_ValidTimingBurstMemory    

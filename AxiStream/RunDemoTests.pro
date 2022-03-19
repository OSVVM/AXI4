#  File Name:         RunAllTests.pro
#  Revision:          STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        Script to run all Axi Stream tests  
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

# Run AxiStream Tests
TestSuite AxiStream
library   osvvm_TbAxiStream

include ./testbench

RunTest ./TestCases/TbStream_SendGetDemo1.vhd

# RunTest  ./TestCases/TbStream_SendCheckBurstByte1.vhd
# RunTest  ./TestCases/TbStream_SendGetBurstByte1.vhd

# RunTest  ./TestCases/TbStream_SendGetPacketBurst1.vhd

# RunTest ./TestCases/TbStream_WaitForGet1.vhd
# RunTest ./TestCases/TbStream_WaitForGetAsync1.vhd

# RunTest ./TestCases/TbStream_SendCheckBurstPattern1.vhd
# RunTest ./TestCases/TbStream_SendCheckBurstPattern2.vhd
# RunTest ./TestCases/TbStream_SendCheckBurstBytePattern1.vhd
# RunTest ./TestCases/TbStream_SendCheckBurstAsyncPattern2.vhd
# RunTest ./TestCases/TbStream_SendCheckBurstAsyncPattern1.vhd
# RunTest ./TestCases/TbStream_SendCheckBurstByteAsyncPattern1.vhd
# 
# RunTest ./TestCases/TbStream_AxiSendCheckBurstPattern1.vhd
# RunTest ./TestCases/TbStream_AxiSendCheckBurstPattern2.vhd
# RunTest ./TestCases/TbStream_AxiSendCheckBurstAsyncPattern1.vhd
# RunTest ./TestCases/TbStream_AxiSendCheckBurstAsyncPattern2.vhd

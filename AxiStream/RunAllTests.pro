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
library osvvm_TbAxiStream
analyze ./testbench/TbStream.vhd
analyze ./testbench/TestCtrl_e.vhd

# Tests for any Stream MIT
analyze ./testbench/TbStream_SendGet1.vhd
analyze ./testbench/TbStream_SendGetAsync1.vhd
analyze ./testbench/TbStream_SendGetBurst1.vhd
analyze ./testbench/TbStream_SendGetBurstAsync1.vhd

analyze ./testbench/TbStream_SendGetBurstByte1.vhd
analyze ./testbench/TbStream_SendGetBurstByteAsync1.vhd

analyze ./testbench/TbStream_SendCheckBurst1.vhd
analyze ./testbench/TbStream_SendCheckBurstAsync1.vhd
analyze ./testbench/TbStream_SendCheckBurstByte1.vhd
analyze ./testbench/TbStream_SendCheckBurstByteAsync1.vhd

analyze ./testbench/TbStream_ByteHandling1.vhd
analyze ./testbench/TbStream_ByteHandlingAsync1.vhd
analyze ./testbench/TbStream_ByteHandlingBurst1.vhd
analyze ./testbench/TbStream_ByteHandlingBurstAsync1.vhd

analyze ./testbench/TbStream_ByteHandlingBurstByte1.vhd
analyze ./testbench/TbStream_ByteHandlingBurstByteAsync1.vhd


# Tests for AXI Stream
analyze ./testbench/TbStream_AxiSendGet2.vhd
analyze ./testbench/TbStream_AxiSendGetAsync2.vhd
analyze ./testbench/TbStream_AxiSendGetBurst2.vhd
analyze ./testbench/TbStream_AxiSendGetBurstAsync2.vhd

analyze ./testbench/TbStream_AxiLastParam1.vhd
analyze ./testbench/TbStream_AxiLastParamAsync1.vhd
analyze ./testbench/TbStream_AxiLastOption1.vhd
analyze ./testbench/TbStream_AxiLastOptionAsync1.vhd

analyze ./testbench/TbStream_AxiSetOptions1.vhd
analyze ./testbench/TbStream_AxiSetOptionsAsync1.vhd
analyze ./testbench/TbStream_AxiSetOptionsBurst1.vhd
analyze ./testbench/TbStream_AxiSetOptionsBurstAsync1.vhd

analyze ./testbench/TbStream_AxiTiming1.vhd
analyze ./testbench/TbStream_AxiTiming2.vhd
analyze ./testbench/TbStream_AxiTimingBurst2.vhd

analyze ./testbench/TbStream_AxiSetOptions2.vhd
analyze ./testbench/TbStream_AxiSetOptionsAsync2.vhd
analyze ./testbench/TbStream_AxiSetOptionsBurst2.vhd
analyze ./testbench/TbStream_AxiSetOptionsBurstAsync2.vhd
analyze ./testbench/TbStream_AxiSetOptionsBurstByte2.vhd
analyze ./testbench/TbStream_AxiSetOptionsBurstByteAsync2.vhd

analyze ./testbench/TbStream_AxiSetOptionsBurst3.vhd
analyze ./testbench/TbStream_AxiSetOptionsBurstAsync3.vhd

analyze ./testbench/TbStream_AxiBurstNoLast1.vhd
analyze ./testbench/TbStream_AxiBurstAsyncNoLast1.vhd



simulate TbStream_SendGet1
simulate TbStream_SendGetAsync1
simulate TbStream_SendGetBurst1
simulate TbStream_SendGetBurstAsync1

simulate TbStream_SendGetBurstByte1
simulate TbStream_SendGetBurstByteAsync1

simulate TbStream_SendCheckBurst1
simulate TbStream_SendCheckBurstAsync1
simulate TbStream_SendCheckBurstByte1
simulate TbStream_SendCheckBurstByteAsync1

simulate TbStream_ByteHandling1
simulate TbStream_ByteHandlingAsync1
simulate TbStream_ByteHandlingBurst1
simulate TbStream_ByteHandlingBurstAsync1

simulate TbStream_ByteHandlingBurstByte1
simulate TbStream_ByteHandlingBurstByteAsync1

simulate TbStream_AxiSendGet2
simulate TbStream_AxiSendGetAsync2
simulate TbStream_AxiSendGetBurst2
simulate TbStream_AxiSendGetBurstAsync2

simulate TbStream_AxiLastParam1
simulate TbStream_AxiLastParamAsync1
simulate TbStream_AxiLastOption1
simulate TbStream_AxiLastOptionAsync1

simulate TbStream_AxiSetOptions1
simulate TbStream_AxiSetOptionsAsync1
simulate TbStream_AxiSetOptionsBurst1
simulate TbStream_AxiSetOptionsBurstAsync1

simulate TbStream_AxiTiming1
simulate TbStream_AxiTiming2
simulate TbStream_AxiTimingBurst2

simulate TbStream_AxiSetOptions2
simulate TbStream_AxiSetOptionsAsync2
simulate TbStream_AxiSetOptionsBurst2
simulate TbStream_AxiSetOptionsBurstAsync2
simulate TbStream_AxiSetOptionsBurstByte2
simulate TbStream_AxiSetOptionsBurstByteAsync2

simulate TbStream_AxiSetOptionsBurst3
simulate TbStream_AxiSetOptionsBurstAsync3

simulate TbStream_AxiBurstNoLast1
simulate TbStream_AxiBurstAsyncNoLast1


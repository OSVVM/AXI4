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
#     5/2021   2021.05    Start of Refactoring TestCases
#     1/2020   2020.01    Updated Licenses to Apache
#     1/2019   2019.01    Compile Script for OSVVM
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2019 - 2021 by SynthWorks Design Inc.  
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
## run in conjunction with either 
## Testbench/Testbench.pro or TestbenchVTI/TestbenchVTI.pro
## Continuing with library set previously by the above
##

## =============================================
## MIT Record Checks Single Transfer Tests - only test once for all 
analyze  TbStream_MultipleDriversTransmitter1.vhd
simulate TbStream_MultipleDriversTransmitter1
analyze  TbStream_MultipleDriversReceiver1.vhd
simulate TbStream_MultipleDriversReceiver1


## =============================================
## MIT Checks that apply to all streaming models
## MIT Blocking, Single Transfers
analyze  TbStream_SendGet1.vhd
simulate TbStream_SendGet1
analyze  TbStream_ByteHandling1.vhd
simulate TbStream_ByteHandling1

## MIT Asynchronous, Single Transfers
analyze  TbStream_SendGetAsync1.vhd
simulate TbStream_SendGetAsync1
analyze  TbStream_ByteHandlingAsync1.vhd
simulate TbStream_ByteHandlingAsync1


# ## MIT Blocking Burst Transfers
# analyze  TbStream_SendGetBurst1.vhd
# simulate TbStream_SendGetBurst1
# analyze  TbStream_SendGetBurstByte1.vhd
# simulate TbStream_SendGetBurstByte1
# analyze  TbStream_ByteHandlingBurst1.vhd
# simulate TbStream_ByteHandlingBurst1
# analyze  TbStream_ByteHandlingBurstByte1.vhd
# simulate TbStream_ByteHandlingBurstByte1

# ## MIT Blocking Burst that use BurstFifo also as scoreboard
# analyze  TbStream_SendCheckBurst1.vhd
# simulate TbStream_SendCheckBurst1
# analyze  TbStream_SendCheckBurstByte1.vhd
# simulate TbStream_SendCheckBurstByte1

# ## MIT Asynchronous Burst Transfers
# analyze  TbStream_SendGetBurstAsync1.vhd
# simulate TbStream_SendGetBurstAsync1
# analyze  TbStream_SendGetBurstByteAsync1.vhd
# simulate TbStream_SendGetBurstByteAsync1
# analyze  TbStream_ByteHandlingBurstAsync1.vhd
# simulate TbStream_ByteHandlingBurstAsync1
# analyze  TbStream_ByteHandlingBurstByteAsync1.vhd
# simulate TbStream_ByteHandlingBurstByteAsync1

# ## MIT Asynchronous Burst that use BurstFifo also as scoreboard
# analyze  TbStream_SendCheckBurstAsync1.vhd
# simulate TbStream_SendCheckBurstAsync1
# analyze  TbStream_SendCheckBurstByteAsync1.vhd
# simulate TbStream_SendCheckBurstByteAsync1

# ## =============================================
# ## MIT Record Checks Burst Transfer Tests - only test once for all 
# analyze  TbStream_ReleaseAcquireTransmitter1.vhd
# simulate TbStream_ReleaseAcquireTransmitter1
# analyze  TbStream_ReleaseAcquireReceiver1.vhd
# simulate TbStream_ReleaseAcquireReceiver1


## =============================================
## AxiStream Specific Tests
## AxiStream Blocking, Single Transfers
analyze  TbStream_AxiSendGet2.vhd
simulate TbStream_AxiSendGet2
analyze  TbStream_AxiSetOptions1.vhd
simulate TbStream_AxiSetOptions1
analyze  TbStream_AxiTxValidDelay1.vhd
simulate TbStream_AxiTxValidDelay1
analyze  TbStream_AxiTiming1.vhd
simulate TbStream_AxiTiming1
analyze  TbStream_AxiTiming2.vhd
simulate TbStream_AxiTiming2
analyze  TbStream_AxiSetOptions2.vhd
simulate TbStream_AxiSetOptions2

## AxiStream Asynchronous, Single Transfers
analyze  TbStream_AxiSendGetAsync2.vhd
simulate TbStream_AxiSendGetAsync2
analyze  TbStream_AxiSetOptionsAsync1.vhd
simulate TbStream_AxiSetOptionsAsync1
analyze  TbStream_AxiSetOptionsAsync2.vhd
simulate TbStream_AxiSetOptionsAsync2


# ## AxiStream Blocking Burst Transfers
# analyze  TbStream_AxiSendGetBurst2.vhd
# simulate TbStream_AxiSendGetBurst2
# analyze  TbStream_AxiLastParam1.vhd
# simulate TbStream_AxiLastParam1
# analyze  TbStream_AxiLastOption1.vhd
# simulate TbStream_AxiLastOption1
# analyze  TbStream_AxiSetOptionsBurst1.vhd
# simulate TbStream_AxiSetOptionsBurst1
# analyze  TbStream_AxiTxValidDelayBurst1.vhd
# simulate TbStream_AxiTxValidDelayBurst1
# analyze  TbStream_AxiTimingBurst2.vhd
# simulate TbStream_AxiTimingBurst2
# analyze  TbStream_AxiSetOptionsBurst2.vhd
# simulate TbStream_AxiSetOptionsBurst2
# analyze  TbStream_AxiSetOptionsBurstByte2.vhd
# simulate TbStream_AxiSetOptionsBurstByte2
# analyze  TbStream_AxiSetOptionsBurst3.vhd
# simulate TbStream_AxiSetOptionsBurst3
# analyze  TbStream_AxiBurstNoLast1.vhd
# simulate TbStream_AxiBurstNoLast1

# analyze  TbStream_AxiSetOptionsBurstCheck3.vhd
# simulate TbStream_AxiSetOptionsBurstCheck3


# ## AxiStream Asynchronous Burst Transfers
# analyze  TbStream_AxiSendGetBurstAsync2.vhd
# simulate TbStream_AxiSendGetBurstAsync2
# analyze  TbStream_AxiLastParamAsync1.vhd
# simulate TbStream_AxiLastParamAsync1
# analyze  TbStream_AxiLastOptionAsync1.vhd
# simulate TbStream_AxiLastOptionAsync1
# analyze  TbStream_AxiSetOptionsBurstAsync1.vhd
# simulate TbStream_AxiSetOptionsBurstAsync1
# analyze  TbStream_AxiSetOptionsBurstAsync2.vhd
# simulate TbStream_AxiSetOptionsBurstAsync2
# analyze  TbStream_AxiSetOptionsBurstByteAsync2.vhd
# simulate TbStream_AxiSetOptionsBurstByteAsync2
# analyze  TbStream_AxiSetOptionsBurstAsync3.vhd
# simulate TbStream_AxiSetOptionsBurstAsync3
# analyze  TbStream_AxiBurstAsyncNoLast1.vhd
# simulate TbStream_AxiBurstAsyncNoLast1

# analyze  TbStream_AxiSetOptionsBurstCheckAsync3.vhd
# simulate TbStream_AxiSetOptionsBurstCheckAsync3

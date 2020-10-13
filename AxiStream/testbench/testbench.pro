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
library osvvm_TbAxiStream
analyze TbStream.vhd
analyze TestCtrl_e.vhd

# Tests for any Stream MIT
analyze TbStream_SendGet1.vhd
analyze TbStream_SendGetAsync1.vhd
analyze TbStream_SendGetBurst1.vhd
analyze TbStream_SendGetBurstAsync1.vhd

# Tests for AXI Stream
analyze TbStream_AxiSendGet2.vhd
analyze TbStream_AxiSendGetAsync2.vhd
analyze TbStream_AxiSendGetBurst2.vhd
analyze TbStream_AxiSendGetBurstAsync2.vhd

analyze TbStream_AxiLastParam1.vhd
analyze TbStream_AxiLastParamAsync1.vhd
analyze TbStream_AxiLastOption1.vhd
analyze TbStream_AxiLastOptionAsync1.vhd

# simulate TbStream_SendGet1
# simulate TbStream_SendGetAsync1
# simulate TbStream_SendGetBurst1
# simulate TbStream_SendGetBurstAsync1

# simulate TbStream_AxiSendGet2
# simulate TbStream_AxiSendGetAsync2
# simulate TbStream_AxiSendGetBurst2
# simulate TbStream_AxiSendGetBurstAsync2

# simulate TbStream_AxiLastParam1
# simulate TbStream_AxiLastParamAsync1
# simulate TbStream_AxiLastOption1
simulate TbStream_AxiLastOptionAsync1
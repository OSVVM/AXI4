#  File Name:         TbAxiStream.tcl
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        Brute force tcl file
#        
#        With the next revision, scripting will switch to 
#        OSVVM scripting approach supported by the .pro files
#        and this file will no longer be provided
#
#  Developed for:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Date      Version    Description
#     1/2018   2018.01    Compile Script for OSVVM
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

set AXI4_DIR [pwd]/..
if {$argc > 0} {
  set AXI4_DIR $1
}

# Create Libraries
# vlib osvvm
# vmap osvvm osvvm 
# vlib osvvm_axi4
# vmap osvvm_axi4 osvvm_axi4
# vlib osvvm_TbAxiStream
# vmap osvvm_TbAxiStream osvvm_TbAxiStream

# run the osvvm compile scripts


# AXI4/common
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/common/src/Axi4LiteInterfacePkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/common/src/Axi4CommonPkg.vhd

# AXI4/AxiStream/src
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/AxiStream/src/AxiStreamTransactionPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/AxiStream/src/AxiStreamComponentPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/AxiStream/src/AxiStreamContext.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/AxiStream/src/AxiStreamMaster.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/AxiStream/src/AxiStreamSlave.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/AxiStream/src/AxiStreamGenericSignalsPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/AxiStream/src/AxiStreamSignalsPkg_32.vhd

vcom -2008 -work osvvm_TbAxiStream ${AXI4_DIR}/AxiStream/testbench/TbAxiStream.vhd
vcom -2008 -work osvvm_TbAxiStream ${AXI4_DIR}/AxiStream/testbench/TestCtrl_e.vhd
vcom -2008 -work osvvm_TbAxiStream ${AXI4_DIR}/AxiStream/testbench/TbAxiStream_BasicSendGet.vhd

vsim osvvm_TbAxiStream.TbAxiStream_BasicSendGet
add wave -r /TbAxiStream/*
run 10 ms


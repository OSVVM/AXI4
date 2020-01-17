#  File Name:         TbAxi4Lite.tcl
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
# vlib osvvm_TbAxi4Lite
# vmap osvvm_TbAxi4Lite osvvm_TbAxi4Lite

# run the osvvm compile scripts


# Axi4Lite/../common
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/common/src/Axi4LiteInterfacePkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/common/src/Axi4CommonPkg.vhd

# Axi4Lite/src
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteSlaveTransactionPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteMasterTransactionPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteMasterComponentPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteSlaveComponentPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteMonitorComponentPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteContext.vhd

vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteMaster.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteMonitor_dummy.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteSlave_Transactor.vhd

vcom -2008 -work osvvm_TbAxi4Lite ${AXI4_DIR}/Axi4Lite/testbench/TestCtrl_e.vhd
vcom -2008 -work osvvm_TbAxi4Lite ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite.vhd
vcom -2008 -work osvvm_TbAxi4Lite ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite_BasicReadWrite.vhd
vcom -2008 -work osvvm_TbAxi4Lite ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite_MasterReadWriteAsync1.vhd
vcom -2008 -work osvvm_TbAxi4Lite ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite_MasterReadWriteAsync2.vhd
vcom -2008 -work osvvm_TbAxi4Lite ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite_RandomReadWrite.vhd
vcom -2008 -work osvvm_TbAxi4Lite ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite_RandomReadWriteByte.vhd
vcom -2008 -work osvvm_TbAxi4Lite ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite_TimeOut.vhd
vcom -2008 -work osvvm_TbAxi4Lite ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite_WriteOptions.vhd

vsim osvvm_TbAxi4Lite.TbAxi4Lite_RandomReadWriteByte
add wave -r /TbAxi4Lite/*
run 10 ms


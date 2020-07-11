#  File Name:         TbAxi4.tcl
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
# vlib osvvm_TbAxi4
# vmap osvvm_TbAxi4 osvvm_TbAxi4

# run the osvvm compile scripts


# Axi4/../common
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/common/src/Axi4InterfacePkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/common/src/Axi4CommonPkg.vhd

# Axi4/src
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4/src/Axi4SlaveTransactionPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4/src/Axi4MasterTransactionPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4/src/Axi4MasterComponentPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4/src/Axi4SlaveComponentPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4/src/Axi4MonitorComponentPkg.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4/src/Axi4Context.vhd

vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4/src/Axi4Master.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4/src/Axi4Monitor_dummy.vhd
vcom -2008 -work osvvm_axi4 ${AXI4_DIR}/Axi4/src/Axi4Slave_Transactor.vhd

vcom -2008 -work osvvm_TbAxi4 ${AXI4_DIR}/Axi4/testbench/TestCtrl_e.vhd
vcom -2008 -work osvvm_TbAxi4 ${AXI4_DIR}/Axi4/testbench/TbAxi4.vhd
vcom -2008 -work osvvm_TbAxi4 ${AXI4_DIR}/Axi4/testbench/TbAxi4_BasicReadWrite.vhd
vcom -2008 -work osvvm_TbAxi4 ${AXI4_DIR}/Axi4/testbench/TbAxi4_MasterReadWriteAsync1.vhd
vcom -2008 -work osvvm_TbAxi4 ${AXI4_DIR}/Axi4/testbench/TbAxi4_MasterReadWriteAsync2.vhd
vcom -2008 -work osvvm_TbAxi4 ${AXI4_DIR}/Axi4/testbench/TbAxi4_RandomReadWrite.vhd
vcom -2008 -work osvvm_TbAxi4 ${AXI4_DIR}/Axi4/testbench/TbAxi4_RandomReadWriteByte.vhd
vcom -2008 -work osvvm_TbAxi4 ${AXI4_DIR}/Axi4/testbench/TbAxi4_TimeOut.vhd
vcom -2008 -work osvvm_TbAxi4 ${AXI4_DIR}/Axi4/testbench/TbAxi4_WriteOptions.vhd

vsim osvvm_TbAxi4.TbAxi4_RandomReadWriteByte
add wave -r /TbAxi4/*
run 10 ms


# RunTests.tcl
#  Brute force tcl file
#  With the next revision, scripting will switch to 
#  OSVVM scripting approach supported by the .pro files
#  and this file will no longer be provided
#

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


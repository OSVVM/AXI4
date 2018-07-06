set AXI4_DIR [pwd]/..
if {$argc > 0} {
  set AXI4_DIR $1
}

vcom -2008 ${AXI4_DIR}/common/src/Axi4LiteInterfacePkg.vhd
vcom -2008 ${AXI4_DIR}/common/src/Axi4CommonPkg.vhd
vcom -2008 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteMasterTransactionPkg.vhd
vcom -2008 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteSlaveTransactionPkg.vhd

vcom -2008 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteMaster.vhd
vcom -2008 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteSlave_Transactor.vhd
vcom -2008 ${AXI4_DIR}/Axi4Lite/src/Axi4LiteMonitor_dummy.vhd

vcom -2008 ${AXI4_DIR}/Axi4Lite/testbench/TestCtrl_e.vhd
vcom -2008 ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite.vhd

vcom -2008 ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite_BasicReadWrite.vhd
vcom -2008 ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite_RandomReadWrite.vhd
vcom -2008 ${AXI4_DIR}/Axi4Lite/testbench/TbAxi4Lite_RandomReadWriteByte.vhd

vsim TbAxi4Lite_RandomReadWriteByte
add wave -r /TbAxi4Lite/*
run 1 ms
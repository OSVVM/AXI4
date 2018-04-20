set AXI4_DIR [pwd]/..
if {$argc > 0} {
  set AXI4_DIR $1
}

vcom -2008 ${AXI4_DIR}/src/Axi4CommonPkg.vhd
vcom -2008 ${AXI4_DIR}/src/Axi4TransactionPkg.vhd
vcom -2008 ${AXI4_DIR}/src/Axi4LiteInterfacePkg.vhd

vcom -2008 ${AXI4_DIR}/src/Axi4LiteMaster.vhd
vcom -2008 ${AXI4_DIR}/src/Axi4LiteSlave_Transactor.vhd
vcom -2008 ${AXI4_DIR}/src/Axi4LiteMonitor_dummy.vhd

vcom -2008 ${AXI4_DIR}/TbAxi4Lite/TestCtrl_e.vhd
vcom -2008 ${AXI4_DIR}/TbAxi4Lite/TbAxi4Lite.vhd

vcom -2008 ${AXI4_DIR}/TbAxi4Lite/TbAxi4Lite_BasicReadWrite.vhd
vcom -2008 ${AXI4_DIR}/TbAxi4Lite/TbAxi4Lite_RandomReadWrite.vhd
vcom -2008 ${AXI4_DIR}/TbAxi4Lite/TbAxi4Lite_RandomReadWriteByte.vhd

vsim TbAxi4Lite_RandomReadWriteByte
add wave -r /TbAxi4Lite/*
run 1 ms
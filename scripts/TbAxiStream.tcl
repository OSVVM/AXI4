set AXI4_DIR [pwd]/..
if {$argc > 0} {
  set AXI4_DIR $1
}

vcom -2008 ${AXI4_DIR}/src/Axi4CommonPkg.vhd
vcom -2008 ${AXI4_DIR}/src/AxiStreamTransactionPkg.vhd

vcom -2008 ${AXI4_DIR}/src/AxiStreamMaster.vhd
vcom -2008 ${AXI4_DIR}/src/AxiStreamSlave.vhd

vcom -2008 ${AXI4_DIR}/TbAxiStream/TestCtrl_e.vhd
vcom -2008 ${AXI4_DIR}/TbAxiStream/TbAxiStream.vhd

vcom -2008 ${AXI4_DIR}/TbAxiStream/TbAxiStream_BasicSendGet.vhd

vsim TbAxiStream_BasicSendGet
add wave -r /TbAxiStream/*
run 1 ms
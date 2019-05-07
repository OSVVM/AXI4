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


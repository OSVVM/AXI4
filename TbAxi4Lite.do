vcom -2008 Axi4TransactionPkg.vhd
vcom -2008 Axi4LiteInterfacePkg.vhd
vcom -2008 Axi4CommonPkg.vhd

vcom -2008 Axi4LiteMaster.vhd
vcom -2008 Axi4LiteSlave_Transactor.vhd
vcom -2008 Axi4LiteMonitor_dummy.vhd

vcom -2008 TestCtrl_e.vhd
vcom -2008 TestCtrl_test1.vhd
vcom -2008 TestCtrl_test2.vhd

vcom -2008 TbAxi4Lite.vhd

vsim TbAxi4Lite
add wave -r /TbAxi4Lite/*
run 1 us
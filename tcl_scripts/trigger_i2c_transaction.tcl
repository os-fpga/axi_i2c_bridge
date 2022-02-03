#!/usr/bin/tclsh

create_hw_axi_txn wprescale_c8 [get_hw_axis hw_axi_1] -address 00000000 -data 000000c8 -type write -force
run_hw_axi wprescale_c8
create_hw_axi_txn wctrl_c0 [get_hw_axis hw_axi_1] -address 00000002 -data 000000c0 -type write -force
run_hw_axi wctrl_c0
create_hw_axi_txn wtxr_de [get_hw_axis hw_axi_1] -address 00000003 -data 000000de -type write -force
run_hw_axi wtxr_de
create_hw_axi_txn wcr_90 [get_hw_axis hw_axi_1] -address 00000004 -data 00000090 -type write -force
run_hw_axi wcr_90

#5 

#// Read status register 

create_hw_axi_txn rsr [get_hw_axis hw_axi_1] -address 00000004 -type read 

run_hw_axi rsr 

#// expected: 0x81 

#6 

#// write TXR with address of memeory block 5 

create_hw_axi_txn wtxr_addr_mem_5 [get_hw_axis hw_axi_1] -address 00000003 -data 00000005 -type write 

run_hw_axi wtxr_addr_mem_5 

#7 

#// IACK + WR -> CR 

create_hw_axi_txn wcr_11 [get_hw_axis hw_axi_1] -address 00000004 -data 00000011 -type write 

run_hw_axi wcr_11 

#8 

#// Read status register 

run_hw_axi rsr  

#// expected: 0x81 

#9 

#// Write data for memory of slave 

#// write TXR with 0xab 

create_hw_axi_txn wtxr_ab [get_hw_axis hw_axi_1] -address 00000003 -data 000000ab -type write 

run_hw_axi wtxr_ab 

#10 

#// IACK + WR -> CR 

run_hw_axi wcr_11 

#11 

#// Read status register 

run_hw_axi rsr  

#// expected: 0x81 

#12 

#// write TXR with 0xdf 

create_hw_axi_txn wtxr_df [get_hw_axis hw_axi_1] -address 00000003 -data 000000df -type write 

run_hw_axi wtxr_df 

#13 

#// IACK + WR -> CR 

run_hw_axi wcr_11 

#14 

#// Read status register 

run_hw_axi rsr  

#// expected: 0x81 

#15 

run_hw_axi wtxr_addr_mem_5 

#16 

#// IACK + WR -> CR 

run_hw_axi wcr_11 

#17 

#// Read status register 

run_hw_axi rsr  

#// expected: 0x81 

#18 

#// IACK + RD -> CR 

create_hw_axi_txn wcr_21 [get_hw_axis hw_axi_1] -address 00000004 -data 00000021 -type write 

run_hw_axi wcr_21 

#19 

#// Read RX register 

create_hw_axi_txn rrxr [get_hw_axis hw_axi_1] -address 00000003 -type read 

run_hw_axi rrxr 

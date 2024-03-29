## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project
#create_clock -period 13.468 -name clk [get_ports clk]
#set_input_delay -clock clk 5.387 [all_inputs]
#set_output_delay -clock clk 2.694 [all_outputs]

## Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
#create_clock -period 100.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Switches
set_property PACKAGE_PIN V17 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

#set_property PACKAGE_PIN V16 [get_ports valid_DC]
#set_property IOSTANDARD LVCMOS33 [get_ports valid_DC]

set_property PACKAGE_PIN W16 [get_ports button]
set_property IOSTANDARD LVCMOS33 [get_ports button]
#set_property PACKAGE_PIN W17 [get_ports i_extclk_0]
#set_property IOSTANDARD LVCMOS33 [get_ports i_extclk_0]
#set_property PACKAGE_PIN W15 [get_ports ri]
#set_property IOSTANDARD LVCMOS33 [get_ports ri]
#set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
#set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
#set_property PACKAGE_PIN W13 [get_ports {sw[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
#set_property PACKAGE_PIN V2 [get_ports {sw[8]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
#set_property PACKAGE_PIN T3 [get_ports {sw[9]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
#set_property PACKAGE_PIN T2 [get_ports {sw[10]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
#set_property PACKAGE_PIN R3 [get_ports {sw[11]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
#set_property PACKAGE_PIN W2 [get_ports {sw[12]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
#set_property PACKAGE_PIN U1 [get_ports {sw[13]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
#set_property PACKAGE_PIN T1 [get_ports {sw[14]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]

#set_property PACKAGE_PIN R2 [get_ports button]
#set_property IOSTANDARD LVCMOS33 [get_ports button]


## LEDs[get_hw_axis hw_axi_1]
set_property PACKAGE_PIN U16 [get_ports scl_en]
set_property IOSTANDARD LVCMOS33 [get_ports scl_en]
set_property PACKAGE_PIN E19 [get_ports sda_en]
set_property IOSTANDARD LVCMOS33 [get_ports sda_en]
#set_property PACKAGE_PIN U19 [get_ports {mem_out[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {mem_out[7]}]
#set_property PACKAGE_PIN V19 [get_ports {mem_out[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {mem_out[6]}]
#set_property PACKAGE_PIN W18 [get_ports {mem_out[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {mem_out[5]}]
#set_property PACKAGE_PIN U15 [get_ports {mem_out[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {mem_out[4]}]
#set_property PACKAGE_PIN U14 [get_ports {mem_out[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {mem_out[3]}]
#set_property PACKAGE_PIN V14 [get_ports {mem_out[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {mem_out[2]}]
#set_property PACKAGE_PIN V13 [get_ports {mem_out[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {mem_out[1]}]
#set_property PACKAGE_PIN V3 [get_ports {mem_out[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {mem_out[0]}]
#set_property PACKAGE_PIN W3 [get_ports {led[10]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]
#set_property PACKAGE_PIN U3 [get_ports {led[11]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]
#set_property PACKAGE_PIN P3 [get_ports {led[12]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]
#set_property PACKAGE_PIN N3 [get_ports {led[13]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]
#set_property PACKAGE_PIN P1 [get_ports {led[14]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]
set_property PACKAGE_PIN L1 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]


##7 segment display
#set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
#set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
#set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
#set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
#set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
#set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
#set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

#set_property PACKAGE_PIN V7 [get_ports dp]
#set_property IOSTANDARD LVCMOS33 [get_ports dp]

#set_property PACKAGE_PIN U2 [get_ports {an[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
#set_property PACKAGE_PIN U4 [get_ports {an[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
#set_property PACKAGE_PIN V4 [get_ports {an[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
#set_property PACKAGE_PIN W4 [get_ports {an[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]


##Buttons
#set_property PACKAGE_PIN U18 [get_ports button]
#set_property IOSTANDARD LVCMOS33 [get_ports button]
#set_property PACKAGE_PIN T18 [get_ports btnU]
#set_property IOSTANDARD LVCMOS33 [get_ports btnU]
#set_property PACKAGE_PIN W19 [get_ports btnL]
#set_property IOSTANDARD LVCMOS33 [get_ports btnL]
#set_property PACKAGE_PIN T17 [get_ports btnR]
#set_property IOSTANDARD LVCMOS33 [get_ports btnR]
#set_property PACKAGE_PIN U17 [get_ports btnD]
#set_property IOSTANDARD LVCMOS33 [get_ports btnD]



#Pmod Header JA
#Sch name = JA1
set_property  PACKAGE_PIN J1 [get_ports scl]
set_property IOSTANDARD LVCMOS33 [get_ports scl]
##Sch name = JA2
set_property  PACKAGE_PIN L2 [get_ports sda]
set_property IOSTANDARD LVCMOS33 [get_ports sda]
##Sch name = JA3
#set_property PACKAGE_PIN J2 [get_ports {DC_vec[13]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[13]}]
##Sch name = JA4
#set_property PACKAGE_PIN G2 [get_ports {DC_vec[12]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[12]}]
##Sch name = JA7
#set_property PACKAGE_PIN H1 [get_ports {DC_vec[11]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[11]}]
##Sch name = JA8
#set_property PACKAGE_PIN K2 [get_ports {DC_vec[10]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[10]}]
##Sch name = JA9
#set_property PACKAGE_PIN H2 [get_ports {DC_vec[9]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[9]}]
##Sch name = JA10
#set_property PACKAGE_PIN G3 [get_ports {DC_vec[8]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[8]}]



#Pmod Header JB
#Sch name = JB1
#set_property PACKAGE_PIN A14 [get_ports {DC_vec[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[7]}]
##Sch name = JB2
#set_property PACKAGE_PIN A16 [get_ports {DC_vec[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[6]}]
##Sch name = JB3
#set_property PACKAGE_PIN B15 [get_ports {DC_vec[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[5]}]
##Sch name = JB4
#set_property PACKAGE_PIN B16 [get_ports {DC_vec[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[4]}]
##Sch name = JB7
#set_property PACKAGE_PIN A15 [get_ports {DC_vec[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[3]}]
##Sch name = JB8
#set_property PACKAGE_PIN A17 [get_ports {DC_vec[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[2]}]
##Sch name = JB9
#set_property PACKAGE_PIN C15 [get_ports {DC_vec[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[1]}]
##Sch name = JB10
#set_property PACKAGE_PIN C16 [get_ports {DC_vec[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {DC_vec[0]}]



##Pmod Header JC
##Sch name = JC1
#set_property PACKAGE_PIN K17 [get_ports {JC[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[0]}]
##Sch name = JC2
#set_property PACKAGE_PIN M18 [get_ports {JC[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[1]}]
##Sch name = JC3
#set_property PACKAGE_PIN N17 [get_ports {JC[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[2]}]
##Sch name = JC4
#set_property PACKAGE_PIN P18 [get_ports {JC[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[3]}]
##Sch name = JC7
#set_property PACKAGE_PIN L17 [get_ports {JC[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[4]}]
##Sch name = JC8
#set_property PACKAGE_PIN M19 [get_ports {JC[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[5]}]
##Sch name = JC9
#set_property PACKAGE_PIN P17 [get_ports {JC[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[6]}]
##Sch name = JC10
#set_property PACKAGE_PIN R18 [get_ports {JC[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[7]}]


##Pmod Header JXADC
##Sch name = XA1_P
#set_property PACKAGE_PIN J3 [get_ports {JXADC[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[0]}]
##Sch name = XA2_P
#set_property PACKAGE_PIN L3 [get_ports {JXADC[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[1]}]
##Sch name = XA3_P
#set_property PACKAGE_PIN M2 [get_ports {JXADC[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[2]}]
##Sch name = XA4_P
#set_property PACKAGE_PIN N2 [get_ports {JXADC[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[3]}]
##Sch name = XA1_N
#set_property PACKAGE_PIN K3 [get_ports {JXADC[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[4]}]
##Sch name = XA2_N
#set_property PACKAGE_PIN M3 [get_ports {JXADC[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[5]}]
##Sch name = XA3_N
#set_property PACKAGE_PIN M1 [get_ports {JXADC[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[6]}]
##Sch name = XA4_N
#set_property PACKAGE_PIN N1 [get_ports {JXADC[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[7]}]



##VGA Connector
#set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
#set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
#set_

set_property MARK_DEBUG true [get_nets design_1_i/axi_i2c_slave_combined_0/scl]
set_property MARK_DEBUG true [get_nets design_1_i/axi_i2c_slave_combined_0/sda]
create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 65536 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_IBUF]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 1 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list design_1_i/axi_i2c_slave_combined_0/scl]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list design_1_i/axi_i2c_slave_combined_0/sda]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_IBUF]

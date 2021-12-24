i2c      ?= ../../i2c_core
axi_to_wbbridge ?= ../../axlite2wb
axi_i2c_bridge ?= ..
bench    ?= $(i2c)/bench
axi_rtl_dir  ?= ///home/users/hamza.hassan/projects/axi_apb_bridge/RTL
wave_dir ?= $(i2c)/sim/rtl_sim/i2c_verilog/waves


UVM_HOME ?=   /home/users/eda_tools/synopsys_instl_dir/vcs-mx/O-2018.09-SP1/etc/uvm-1.2
 
UVM_VERBOSITY = UVM_MEDIUM

TEST = simplealu_test

VCS =	vcs -sverilog -full64 -debug_pp -timescale=1ns/1ns -LDFLAGS -Wl,--no-as-needed \
	+acc +vpi \
	+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
	+incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv \
	-cm line+cond+fsm+branch+tgl -cm_dir ./coverage.vdb \
	$(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS

SIMV = ./simv +UVM_VERBOSITY=$(UVM_VERBOSITY) \
	 +UVM_TR_RECORD +UVM_LOG_RECORD \
	+verbose=1 +ntb_random_seed=244 -l vcs.log


x:	comp run

comp:
	$(VCS) +incdir+$(i2c)/rtl/timescale.v 			\
	+incdir $(i2c)/rtl/i2c_master_defines.v 		\
	+incdir $(i2c)/rtl/i2c_master_bit_ctrl.v		\
	+incdir $(i2c)/rtl/i2c_master_byte_ctrl.v		\
	+incdir $(i2c)/rtl/i2c_master_top.v			\
	+incdir $(axi_to_wbbridge)/rtl/axlite2wbsp.sv		\
	+incdir $(axi_to_wbbridge)/rtl/axilwr2wbsp.sv		\
	+incdir $(axi_to_wbbridge)/rtl/axilrd2wbsp.sv		\
	+incdir $(axi_to_wbbridge)/rtl/wbarbiter.sv		\
	+incdir $(axi_rtl_dir)/axi_lite_pkg.sv			\
	+incdir $(axi_rtl_dir)/axi_lite_if.sv			\
	+incdir	$(axi_i2c_bridge)/rtl/axi_i2c_bridge.v          \
	+incdir i2c_slave_model.v				\
	+incdir+. tst_bench_top.sv  
run:
	$(SIMV)

clean:
	rm -rf coverage.vdb csrc DVEfiles inter.vpd simv simv.daidir ucli.key vc_hdrs.h vcs.log .inter.vpd.uvm

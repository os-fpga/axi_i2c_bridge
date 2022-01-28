`include "../../i2c_core/rtl/timescale.v"
`include "../../i2c_core/rtl/i2c_master_defines.v"
`include "../../i2c_core/rtl/i2c_master_bit_ctrl.v"
`include "../../i2c_core/rtl/i2c_master_byte_ctrl.v"
`include "../../i2c_core/rtl/i2c_master_top.v"
`include "../../axlite2wb/rtl/axlite2wbsp.sv"
`include "../../axlite2wb/rtl/axilwr2wbsp.sv"
`include "../../axlite2wb/rtl/axilrd2wbsp.sv"
`include "../../axlite2wb/rtl/wbarbiter.sv"

`include "../../axlite2wb/rtl/wb_width.sv"
`include "../../axlite2wb/rtl/num_ones_for.sv"
`include "../bench/i2c_slave.v"
`include "../rtl/axi_i2c_bridge.v"

module axi_i2c_slave_combined
			     #(
			      parameter C_AXI_DATA_WIDTH	= 32,	// Width of the AXI R&W data
			      parameter C_AXI_ADDR_WIDTH	= 28,	// AXI Address width
			      parameter WB_DATA_WIDTH     = 8,
			      parameter GRANULARITY       = 8, 	// Wishbone data bus granularity. Only 8 bit support is yet available
			      parameter OPT_READONLY  	= 1'b0,
			      parameter OPT_WRITEONLY 	= 1'b0,
			      parameter timeout_cycles    = 10,
			      parameter ARB_SCHEME        = "ALTERNATING",
			      parameter OPT_ZERO_ON_IDLE  = 1'b0
			      )
		(
		clk,	// System clock
		axi_reset_n,
		
		// AXI write address channel signals
		// {{{
		axi_awvalid,
		axi_awready,
		axi_awaddr,
		axi_awprot,
		// }}}
		// AXI write data channel signals
		// {{{
		axi_wvalid,
		axi_wready, 
		axi_wdata,
		axi_wstrb,
		// }}}
		// AXI write response channel signals
		// {{{
		axi_bvalid,
		axi_bready,
		axi_bresp,
		// }}}
		// AXI read address channel signals
		// {{{
		axi_arvalid,
		axi_arready,
		axi_araddr,
		axi_arprot,
		// }}}
		// AXI read data channel signals
		// {{{
		axi_rvalid,
		axi_rready,
		axi_rdata,
		axi_rresp,
		
		//scl , sda , outputs
		scl_o,
		sda_o
		);

input clk;	// System clock
input axi_reset_n;
		
		// AXI write address channel signals
		// {{{
input       axi_awvalid;
output      axi_awready;
input[C_AXI_ADDR_WIDTH-1:0] axi_awaddr;
input[2:0]  axi_awprot;
		// }}}
		// AXI write data channel signals
		// {{{
input	    axi_wvalid;
output	    axi_wready; 
input[C_AXI_DATA_WIDTH-1:0] axi_wdata;
input[3:0]  axi_wstrb;
		// }}}
		// AXI write response channel signals
		// {{{
output	    axi_bvalid;
input	    axi_bready;
output[1:0] axi_bresp;
		// }}}
		// AXI read address channel signals
		// {{{
input       axi_arvalid;
output	    axi_arready;
input[C_AXI_ADDR_WIDTH-1:0] axi_araddr;
input[2:0]  axi_arprot;
		// }}}
		// AXI read data channel signals
		// {{{
output      axi_rvalid;
input       axi_rready;
output[C_AXI_DATA_WIDTH-1:0]axi_rdata;
output[1:0] axi_rresp;

output	    scl_o,sda_o;
	
	wire scl_oen,sda_oen_m;
	wire scl_o_m,sda_o_m;
	
	wire sda_oen_s,sda_o_s;
			
	wire scl;	
	wire sda;
	wire high_impedence_condition;
	
	axi_i2c_bridge axi_i2c_bridge_(
		.clk(clk),	// System clock
		.axi_reset_n(axi_reset_n),
		
		// AXI write address channel signals
		// {{{
		.axi_awvalid(axi_awvalid),
		.axi_awready(axi_awready),
		.axi_awaddr(axi_awaddr),
		.axi_awprot(axi_awprot),
		// }}}
		// AXI write data channel signals
		// {{{
		.axi_wvalid(axi_wvalid),
		.axi_wready(axi_wready), 
		.axi_wdata(axi_wdata),
		.axi_wstrb(axi_wstrb),
		// }}}
		// AXI write response channel signals
		// {{{
		.axi_bvalid(axi_bvalid),
		.axi_bready(axi_bready),
		.axi_bresp (axi_bresp),
		// }}}
		// AXI read address channel signals
		// {{{
		.axi_arvalid(axi_arvalid),
		.axi_arready(axi_arready),
		.axi_araddr(axi_araddr),
		.axi_arprot(axi_arprot),
		// }}}
		// AXI read data channel signals
		// {{{
		.axi_rvalid(axi_rvalid),
		.axi_rready(axi_rready),
		.axi_rdata(axi_rdata),
		.axi_rresp(axi_rresp),
		
		.scl_pad_i(scl),
		.scl_pad_o(scl_o_m),
		.scl_padoen_o(scl_oen_m),
		.sda_pad_i(sda),
		.sda_pad_o(sda_o_m),
		.sda_padoen_o(sda_oen_m)	
	
	
	);
		


	assign scl = scl_oen_m ? 1'b1 : 1'b0;
	
	/*
	om   os
	 0   0   0 
	 0   1   0
	 1   0   0
	 1   1   1
	*/ 
	 
        assign sda = sda_oen_m & sda_oen_s;
        //assign sda = sda0_oen ? 1'b1 : 1'b0;
			
	i2c_slave i2c_slave_ (
		.scl(scl),
		.rst(axi_reset_n),
		.sda_i(sda),
		.sda_o(sda_o_s),
		.sda_oen(sda_oen_s)
	);
        // create i2c lines
        
        /*
	delay m0_scl (scl0_oen ? 1'bz : scl0_o, scl),
	      m0_sda (sda0_oen ? 1'bz : sda0_o, sda);
	*/
	//pullup p1(scl); // pullup scl line
	//pullup p2(sda); // pullup sda line	
	
	/*	
	if(sda_oe_m)
	     sda = 1'b1;
	else if(sda_oe_s)
	     sda = 1'b1;
	else sda = 1'b0;
	*/	
	assign sda_o = sda;
	assign scl_o = scl;
	
		
		
endmodule

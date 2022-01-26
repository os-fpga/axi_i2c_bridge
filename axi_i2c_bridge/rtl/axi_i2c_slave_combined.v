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
	
	wire scl0_oen,sda0_oen;
	wire scl0_o  ,  sda0_o;
			
	wire scl;	
	wire sda;
	
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
		.scl_pad_o(scl0_o),
		.scl_padoen_o(scl0_oen),
		.sda_pad_i(sda),
		.sda_pad_o(sda0_o),
		.sda_padoen_o(sda0_oen)	
	
	
	);
		


	assign scl = scl0_oen ? 1'bz : scl0_o;
        assign sda = sda0_oen ? 1'bz : sda0_o;
        
			
	i2c_slave i2c_slave_ (
		.scl(scl),
		.rst(axi_reset_n),
		.sda(sda)
	);
        // create i2c lines
        
        /*
	delay m0_scl (scl0_oen ? 1'bz : scl0_o, scl),
	      m0_sda (sda0_oen ? 1'bz : sda0_o, sda);
	*/
	pullup p1(scl); // pullup scl line
	pullup p2(sda); // pullup sda line	
		
		
	assign sda_o = sda;
	assign scl_o = scl;
		
		
endmodule

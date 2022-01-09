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

module axi_i2c_bridge 
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
		
		scl_pad_i,       // SCL-line input
		scl_pad_o,       // SCL-line output (always 1'b0)
		scl_padoen_o,    // SCL-line output enable (active low)

// i2c data line
		sda_pad_i,       // SDA-line input
		sda_pad_o,       // SDA-line output (always 1'b0)
		sda_padoen_o
		
);

input clk;	// System clock
input axi_reset_n;
		
		// AXI write address channel signals
		// {{{
input       axi_awvalid;
output      axi_awready;
input[31:0] axi_awaddr;
input[2:0]  axi_awprot;
		// }}}
		// AXI write data channel signals
		// {{{
input	    axi_wvalid;
output	    axi_wready; 
input[31:0] axi_wdata;
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
input[31:0] axi_araddr;
input[2:0]  axi_arprot;
		// }}}
		// AXI read data channel signals
		// {{{
output      axi_rvalid;
input       axi_rready;
output[31:0]axi_rdata;
output[1:0] axi_rresp;

input  scl_pad_i;       // SCL-line input
output scl_pad_o;       // SCL-line output (always 1'b0)
output scl_padoen_o;    // SCL-line output enable (active low)

// i2c data line
input  sda_pad_i;       // SDA-line input
output sda_pad_o;       // SDA-line output (always 1'b0)
output sda_padoen_o;


	reg  clk;
	reg  rstn;

	wire [31:0] adr;
	wire [ 7:0] dat_i, dat_o, dat0_i, dat1_i;
	wire we;
	wire stb;
	wire cyc;
	wire ack;
	wire inta;

	reg [7:0] q, qq;

	wire scl, scl_o, scl_oen;
	wire sda, sda_o, sda_oen;
	
	assign scl = scl_pad_i;
	assign sda = sda_pad_i;
	
	assign scl_pad_o = scl_o;
	assign scl_padoen_o = scl_oen;
	
	assign sda_pad_o = sda_o;       // SDA-line output (always 1'b0)
	assign sda_padoen_o = sda_oen;
	
	wire [3:0]	wb_sel;
	//

	wire wb_bridge_reset ;
	
	axlite2wbsp axit_to_wb_bridge
	
	      (
		// {{{
		.i_clk(clk),	// System clock
		.i_axi_reset_n(axi_reset_n),
		
		// AXI write address channel signals
		// {{{
		.i_axi_awvalid(axi_awvalid),
		.o_axi_awready(axi_awready),
		.i_axi_awaddr(axi_awaddr),
		.i_axi_awprot(axi_arprot),
		// }}}
		// AXI write data channel signals
		// {{{
		.i_axi_wvalid(axi_wvalid),
		.o_axi_wready(axi_wready), 
		.i_axi_wdata(axi_wdata),
		.i_axi_wstrb(axi_wstrb),
		// }}}
		// AXI write response channel signals
		// {{{
		.o_axi_bvalid(axi_bvalid),
		.i_axi_bready(axi_bready),
		.o_axi_bresp(axi_bresp),
		// }}}
		// AXI read address channel signals
		// {{{
		.i_axi_arvalid(axi_arvalid),
		.o_axi_arready(axi_arready),
		.i_axi_araddr(axi_araddr),
		.i_axi_arprot(axi_arprot),
		// }}}
		// AXI read data channel signals
		// {{{
		.o_axi_rvalid(axi_rvalid),
		.i_axi_rready(axi_rready),
		.o_axi_rdata(axi_rdata),
		.o_axi_rresp(axi_rresp),
		// }}}
		// Wishbone signals
		// {{{
		// We'll share the clock and the reset
		.o_reset(),
		.o_wb_cyc(cyc),
		.o_wb_stb(stb),
		.o_wb_we(we),
		.o_wb_addr(adr),
		.o_wb_data(dat_o),
		.o_wb_sel(wb_sel),
		.i_wb_stall(1'b0),
		.i_wb_ack(ack),
		.i_wb_data(dat_i),
		.i_wb_err(1'b0),
		// }}}
		// }}}
		.timeout_reset(wb_bridge_reset)
	);
//

	assign dat_i = dat0_i;

	wire i2c_reset = (!axi_reset_n) ? axi_reset_n : (!wb_bridge_reset) ? wb_bridge_reset : 1'b1 ; 
	// hookup wishbone_i2c_master core
	i2c_master_top i2c_top (

		// wishbone interface
		.wb_clk_i(clk),
		.wb_rst_i(1'b0),
		.arst_i(i2c_reset),
		.wb_adr_i(adr[2:0]),
		.wb_dat_i(dat_o),
		.wb_dat_o(dat0_i),
		.wb_we_i(we),
		.wb_stb_i(stb),
		.wb_cyc_i(cyc),
		.wb_ack_o(ack),
		.wb_inta_o(inta),

		// i2c signals
		.scl_pad_i(scl),
		.scl_pad_o(scl_o),
		.scl_padoen_o(scl_oen),
		.sda_pad_i(sda),
		.sda_pad_o(sda_o),
		.sda_padoen_o(sda_oen)
	);


endmodule
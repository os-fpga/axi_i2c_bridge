////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	axlite2wbsp.v
// {{{
// Project:	WB2AXIPSP: bus bridges and other odds and ends
//
// Purpose:	Take an AXI lite input, and convert it into WB.
//
//	We'll treat AXI as two separate busses: one for writes, another for
//	reads, further, we'll insist that the two channels AXI uses for writes
//	combine into one channel for our purposes.
//
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
// }}}
// Copyright (C) 2016-2021, Gisselquist Technology, LLC
// {{{
// This file is part of the WB2AXIP project.
//
// The WB2AXIP project contains free software and gateware, licensed under the
// Apache License, Version 2.0 (the "License").  You may not use this project,
// or this file, except in compliance with the License.  You may obtain a copy
// of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none

`define CLOG2(x) \
   (x < 2) ? 0 : \
   (x == 2) ? 1 : \
   (x <= 4) ? 2 : \
   (x <= 8) ? 3 : \
   (x <= 16) ? 4 : \
   (x <= 32) ? 5 : \
   (x <= 64) ? 6 : \
   -1
// }}}
module axlite2wbsp #(
		// {{{
		parameter C_AXI_DATA_WIDTH	= 32,// Width of the AXI R&W data
		parameter C_AXI_ADDR_WIDTH	= 28,	// AXI Address width
		parameter WB_DATA_WIDTH     = 8,
		parameter GRANULARITY       = 8, // Wishbone data bus granularity. Only 8 bit support is yet available
		parameter		LGFIFO = 4,
		parameter	[0:0]	OPT_READONLY  = 1'b0,
		parameter	[0:0]	OPT_WRITEONLY = 1'b0,
		parameter timeout_cycles        = 10,
		//localparam		AXILLSB          = $clog2(C_AXI_DATA_WIDTH/8),
		localparam      ADDR_LOWER_LIMIT = `CLOG2(WB_DATA_WIDTH/GRANULARITY)
		// }}}
	) (
		// {{{
		input	wire			i_clk,	// System clock
		input	wire			i_axi_reset_n,

		// AXI write address channel signals
		// {{{
		input	wire			i_axi_awvalid,
		output	wire			o_axi_awready,
		input	wire	[C_AXI_ADDR_WIDTH-1:0]	i_axi_awaddr,
		input	wire	[2:0]		i_axi_awprot,
		// }}}
		// AXI write data channel signals
		// {{{
		input	wire				i_axi_wvalid,
		output	wire				o_axi_wready, 
		input	wire	[C_AXI_DATA_WIDTH-1:0]	i_axi_wdata,
		input	wire	[C_AXI_DATA_WIDTH/8-1:0] i_axi_wstrb,
		// }}}
		// AXI write response channel signals
		// {{{
		output	wire 			o_axi_bvalid,
		input	wire			i_axi_bready,
		output	wire [1:0]		o_axi_bresp,
		// }}}
		// AXI read address channel signals
		// {{{
		input	wire			i_axi_arvalid,
		output	wire			o_axi_arready,
		input	wire	[C_AXI_ADDR_WIDTH-1:0]	i_axi_araddr,
		input	wire	[2:0]		i_axi_arprot,
		// }}}
		// AXI read data channel signals
		// {{{
		output	wire			o_axi_rvalid,
		input	wire			i_axi_rready,
		output	wire [C_AXI_DATA_WIDTH-1:0] o_axi_rdata,
		output	wire [1:0]		o_axi_rresp,
		// }}}
		// Wishbone signals
		// {{{
		// We'll share the clock and the reset
		output	wire			o_reset,
		output	wire			o_wb_cyc,
		output	wire			o_wb_stb,
		output	wire			o_wb_we,
		//ADDR_LOWER_LIMIT
		output	wire [C_AXI_ADDR_WIDTH-ADDR_LOWER_LIMIT-1:0]	o_wb_addr,
		//output	wire [C_AXI_ADDR_WIDTH-AXILLSB-1:0]	o_wb_addr,
		output	wire [WB_DATA_WIDTH-1:0]		    o_wb_data,
		output	wire [WB_DATA_WIDTH/8-1:0]		o_wb_sel,
		input	wire			i_wb_stall,
		input	wire			i_wb_ack,
		input	wire [(WB_DATA_WIDTH-1):0]		i_wb_data,
		input	wire			i_wb_err,
		
		//timeout_reset should be active low logic
		output  wire                    timeout_reset
		// }}}
		// }}}
	);

	// Local definitions
	// {{{
	localparam DW = WB_DATA_WIDTH;
	localparam AW = C_AXI_ADDR_WIDTH-ADDR_LOWER_LIMIT;
	//
	//
	//
	
	wire	[(AW-1):0]			w_wb_addr, r_wb_addr;
	wire	[(DW-1):0]			w_wb_data;
	wire	[(DW/8-1):0]			w_wb_sel, r_wb_sel;
	wire	r_wb_err, r_wb_cyc, r_wb_stb, r_wb_stall, r_wb_ack;
	wire	w_wb_err, w_wb_cyc, w_wb_stb, w_wb_stall, w_wb_ack;

	// verilator lint_off UNUSED
	wire	r_wb_we, w_wb_we;

	//timeout logic
	// timout_counter
	reg 	[7:0] timeout_cnt;
	
	always @(posedge i_clk,negedge i_axi_reset_n)begin
	      if(!i_axi_reset_n)begin
		timeout_cnt <= 0;
	      end
	      else if(o_wb_cyc)begin
		   if(timeout_cnt<timeout_cycles) begin
		      timeout_cnt <= timeout_cnt + 1; 
		   end
		   else begin
		      timeout_cnt <= timeout_cnt;
		   end
	      end
	      else begin
		   timeout_cnt <= 0;
	      end
	      
	
	end
	
	assign timeout_reset = (timeout_cnt != timeout_cycles);
	
	//end timeout logic
	assign	r_wb_we = 1'b0;
	assign	w_wb_we = 1'b1;
	// verilator lint_on  UNUSED

	wire [(WB_DATA_WIDTH-1):0] i_axi_param_wdata;
	wire [(WB_DATA_WIDTH/8-1):0] i_axi_param_wstrb;
	wire [C_AXI_ADDR_WIDTH-ADDR_LOWER_LIMIT-1:0] i_axi_param_awaddr;
	wire [C_AXI_ADDR_WIDTH-ADDR_LOWER_LIMIT-1:0] i_axi_param_araddr;
	wire [(WB_DATA_WIDTH-1):0] o_axi_param_rdata;

	// This combinational logic based module converts AXI data bus width
	// into WB data bus width and adjusts AXI strobe as well.
	wb_width  #(
        .AXI_DATA_WIDTH (C_AXI_DATA_WIDTH),
        .WB_DATA_WIDTH (WB_DATA_WIDTH),
        .AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH),
        .GRANULARITY(GRANULARITY)
        ) width_instance (
        .in_data(i_axi_wdata),
        .in_strb(i_axi_wstrb),
        .out_data(i_axi_param_wdata),
        .out_strb(i_axi_param_wstrb),
        .in_write_addr(i_axi_awaddr),
        .out_write_addr(i_axi_param_awaddr),
        .in_read_addr(i_axi_araddr),
        .out_read_addr(i_axi_param_araddr)
        );

    // Assign o_axi_rdata appropriate o_axi_param_rdata
    generate
        if (C_AXI_DATA_WIDTH == 32)
        begin
            if(WB_DATA_WIDTH == 32) begin
                assign o_axi_rdata = o_axi_param_rdata;
            end
            else if (WB_DATA_WIDTH == 16) begin
                assign o_axi_rdata = {16'h0,o_axi_param_rdata};
            end
            else if (WB_DATA_WIDTH == 8) begin
                assign o_axi_rdata = {24'h0,o_axi_param_rdata};
            end
        end
        else if (C_AXI_DATA_WIDTH == 64)
        begin
            if(WB_DATA_WIDTH == 64) begin
                assign o_axi_rdata = o_axi_param_rdata;
            end
            else if (WB_DATA_WIDTH == 32) begin
                assign o_axi_rdata = {32'h0,o_axi_param_rdata};
            end
            else if (WB_DATA_WIDTH == 16) begin
                assign o_axi_rdata = {48'h0,o_axi_param_rdata};
            end
            else if (WB_DATA_WIDTH == 8) begin
                assign o_axi_rdata = {56'h0,o_axi_param_rdata};
            end
        end
    endgenerate

	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// AXI-lite write channel to WB processing
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//
	generate if (!OPT_READONLY)
	begin : AXI_WR
		// {{{
		axilwr2wbsp #(
			// {{{
			// .F_LGDEPTH(F_LGDEPTH),
			.C_AXI_DATA_WIDTH(WB_DATA_WIDTH),
			.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH), // .AW(AW),
			.LGFIFO(LGFIFO)
			// }}}
		) axi_write_decoder (
			// {{{
			.i_clk(i_clk), .i_axi_reset_n(i_axi_reset_n),
			//
			.i_axi_awvalid(i_axi_awvalid),
			.o_axi_awready(o_axi_awready),
			.i_axi_awaddr( i_axi_param_awaddr),
			.i_axi_awprot( i_axi_awprot),
			//
			.i_axi_wvalid( i_axi_wvalid),
			.o_axi_wready( o_axi_wready),
			.i_axi_wdata(  i_axi_param_wdata),
			.i_axi_wstrb(  i_axi_param_wstrb),
			//
			.o_axi_bvalid(o_axi_bvalid),
			.i_axi_bready(i_axi_bready),
			.o_axi_bresp(o_axi_bresp),
			//
			.o_wb_cyc(  w_wb_cyc),
			.o_wb_stb(  w_wb_stb),
			.o_wb_addr( w_wb_addr),
			.o_wb_data( w_wb_data),
			.o_wb_sel(  w_wb_sel),
			.i_wb_stall(w_wb_stall),
			.i_wb_ack(  w_wb_ack),
			.i_wb_err(  w_wb_err | !timeout_reset)
			// }}}
		);
		// }}}
	end else begin
		// {{{
		assign	w_wb_cyc  = 0;
		assign	w_wb_stb  = 0;
		assign	w_wb_addr = 0;
		assign	w_wb_data = 0;
		assign	w_wb_sel  = 0;
		assign	o_axi_awready = 0;
		assign	o_axi_wready  = 0;
		assign	o_axi_bvalid  = (i_axi_wvalid);
		assign	o_axi_bresp   = 2'b11;
		// }}}
	end endgenerate
	assign	w_wb_we = 1'b1;
	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// AXI-lite read channel to WB processing
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//

	generate if (!OPT_WRITEONLY)
	begin : AXI_RD
		// {{{
		axilrd2wbsp #(
			// {{{
		    .C_AXI_DATA_WIDTH(WB_DATA_WIDTH),
			.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
			.LGFIFO(LGFIFO)
			// }}}
		) axi_read_decoder(
			// {{{
			.i_clk(i_clk), .i_axi_reset_n(i_axi_reset_n),
			//
			.i_axi_arvalid(i_axi_arvalid),
			.o_axi_arready(o_axi_arready),
			.i_axi_araddr( i_axi_param_araddr),
			.i_axi_arprot( i_axi_arprot),
			//
			.o_axi_rvalid(o_axi_rvalid),
			.i_axi_rready(i_axi_rready),
			.o_axi_rdata( o_axi_param_rdata),
			.o_axi_rresp( o_axi_rresp),
			//
			.o_wb_cyc(  r_wb_cyc),
			.o_wb_stb(  r_wb_stb),
			.o_wb_addr( r_wb_addr),
			.o_wb_sel(  r_wb_sel),
			.i_wb_stall(r_wb_stall),
			.i_wb_ack(  r_wb_ack),
			.i_wb_data( i_wb_data),
			.i_wb_err(  r_wb_err | !timeout_reset)
			// }}}
		);
		// }}}
	end else begin
		// {{{
		assign	r_wb_cyc  = 0;
		assign	r_wb_stb  = 0;
		assign	r_wb_addr = 0;
		//
		assign o_axi_arready = 1'b1;
		assign o_axi_rvalid  = (i_axi_arvalid)&&(o_axi_arready);
		assign o_axi_rresp   = (i_axi_arvalid) ? 2'b11 : 2'b00;
		assign o_axi_param_rdata   = 0;
		// }}}
	end endgenerate

	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// The arbiter that pastes the two sides together
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//


	generate if (OPT_READONLY)
	begin : ARB_RD
		// {{{
		assign	o_wb_cyc  = r_wb_cyc;
		assign	o_wb_stb  = r_wb_stb;
		assign	o_wb_we   = 1'b0;
		assign	o_wb_addr = r_wb_addr;
		assign	o_wb_data = 32'h0;
		assign	o_wb_sel  = r_wb_sel;
		assign	r_wb_ack  = i_wb_ack;
		assign	r_wb_stall= i_wb_stall;
		assign	r_wb_ack  = i_wb_ack;
		assign	r_wb_err  = i_wb_err;
		// }}}
	end else if (OPT_WRITEONLY)
	begin : ARB_WR
		// {{{
		assign	o_wb_cyc  = w_wb_cyc;
		assign	o_wb_stb  = w_wb_stb;
		assign	o_wb_we   = 1'b1;
		assign	o_wb_addr = w_wb_addr;
		assign	o_wb_data = w_wb_data;
		assign	o_wb_sel  = w_wb_sel;
		assign	w_wb_ack  = i_wb_ack;
		assign	w_wb_stall= i_wb_stall;
		assign	w_wb_ack  = i_wb_ack;
		assign	w_wb_err  = i_wb_err;
		// }}}
	end else begin : ARB_WB
		// {{{
		wbarbiter #(
			// {{{
			
			.DW(DW), .AW(AW) , .OPT_ZERO_ON_IDLE(1'b1)
			// }}}
		) readorwrite(
			// {{{
			.i_clk(i_clk), .i_reset(!i_axi_reset_n),
			// Channel A - Reads
			// {{{
			.i_a_cyc(r_wb_cyc), .i_a_stb(r_wb_stb),
				.i_a_we(1'b0),
				.i_a_adr(r_wb_addr),
				.i_a_dat(w_wb_data),
				.i_a_sel(r_wb_sel),
				.o_a_stall(r_wb_stall),
				.o_a_ack(r_wb_ack),
				.o_a_err(r_wb_err),
			// }}}
			// Channel B
			// {{{
			.i_b_cyc(w_wb_cyc), .i_b_stb(w_wb_stb),
				.i_b_we(1'b1),
				.i_b_adr(w_wb_addr),
				.i_b_dat(w_wb_data),
				.i_b_sel(w_wb_sel),
				.o_b_stall(w_wb_stall),
				.o_b_ack(w_wb_ack),
				.o_b_err(w_wb_err),
			// }}}
			// Arbitrated outgoing channel
			// {{{
			.o_cyc(o_wb_cyc), .o_stb(o_wb_stb), .o_we(o_wb_we),
				.o_adr(o_wb_addr),
				.o_dat(o_wb_data),
				.o_sel(o_wb_sel),
				.i_stall(i_wb_stall),
				.i_ack(i_wb_ack),
				.i_err(i_wb_err)
			// }}}
		);
		// }}}
	end endgenerate
	// }}}
	assign	o_reset = (i_axi_reset_n == 1'b0);

endmodule
`ifndef	YOSYS
`default_nettype wire
`endif

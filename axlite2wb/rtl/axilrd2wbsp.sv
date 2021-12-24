////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	axilrd2wbsp.v (AXI lite to wishbone slave, read channel)
// {{{
// Project:	WB2AXIPSP: bus bridges and other odds and ends
//
// Purpose:	Bridge an AXI lite read channel pair to a single wishbone read
//		channel.
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
// }}}
module	axilrd2wbsp #(
		// {{{
		parameter C_AXI_DATA_WIDTH	= 32,
		parameter C_AXI_ADDR_WIDTH	= 28,
		parameter AXILLSB		= $clog2(C_AXI_DATA_WIDTH/8),
		localparam	AW		= C_AXI_ADDR_WIDTH-AXILLSB,
		localparam	DW		= C_AXI_DATA_WIDTH,
		parameter LGFIFO                =  3
		// }}}
	) (
		// {{{
		input	wire			i_clk,
		input	wire			i_axi_reset_n,

		// AXI read address channel signals
		// {{{
		input	wire			i_axi_arvalid,
		output	reg			o_axi_arready,
		input	wire	[C_AXI_ADDR_WIDTH-1:0]	i_axi_araddr,
		input	wire	[2:0]		i_axi_arprot,
		// }}}
		// AXI read data channel signals
		// {{{
		output	reg			o_axi_rvalid,
		input	wire			i_axi_rready,
		output	wire [C_AXI_DATA_WIDTH-1:0] o_axi_rdata,
		output	reg [1:0]		o_axi_rresp,
		// }}}
		// Wishbone signals
		// {{{
		// We'll share the clock and the reset
		output	reg				o_wb_cyc,
		output	reg				o_wb_stb,
		output	reg [(AW-1):0]			o_wb_addr,
		output	wire [(DW/8-1):0]		o_wb_sel,
		input	wire				i_wb_stall,
		input	wire				i_wb_ack,
		input	wire [(C_AXI_DATA_WIDTH-1):0]	i_wb_data,
		input	wire				i_wb_err
		// }}}
		// }}}
	);

	// Local declarations
	// {{{
	localparam	AXI_LSBS = $clog2(C_AXI_DATA_WIDTH)-3;

	wire	w_reset;
	assign	w_reset = (!i_axi_reset_n);

	reg			r_stb;
	reg	[AW-1:0]	r_addr;

	localparam		FLEN=(1<<LGFIFO);

	reg	[DW-1:0]	dfifo		[0:(FLEN-1)];
	reg			fifo_full, fifo_empty;

	reg	[LGFIFO:0]	r_first, r_mid, r_last;
	wire	[LGFIFO:0]	next_first, next_last;
	reg			wb_pending;
	reg	[LGFIFO:0]	wb_outstanding;
	wire	[DW-1:0]	read_data;
	reg			err_state;
	reg	[LGFIFO:0]	err_loc;
	// }}}

	// o_wb_cyc, o_wb_stb
	// {{{
	initial	o_wb_cyc = 1'b0;
	initial	o_wb_stb = 1'b0;
	always @(posedge i_clk)
	if ((w_reset)||((o_wb_cyc)&&(i_wb_err))||(err_state))
		o_wb_stb <= 1'b0;
	else if (r_stb || ((i_axi_arvalid)&&(o_axi_arready)))
		o_wb_stb <= 1'b1;
	else if ((o_wb_cyc)&&(!i_wb_stall))
		o_wb_stb <= 1'b0;

	always @(*)
		o_wb_cyc = (wb_pending)||(o_wb_stb);
	// }}}

	// o_wb_addr
	// {{{
	always @(posedge i_clk)
	if (r_stb && !i_wb_stall)
		o_wb_addr <= r_addr;
	else if ((o_axi_arready)&&((!o_wb_stb)||(!i_wb_stall)))
		o_wb_addr <= i_axi_araddr[AW+1:AXI_LSBS];
	// }}}

	// o_wb_sel
	// {{{
	assign	o_wb_sel = {(DW/8){1'b1}};
	// }}}

	// r_stb, r_addr
	// {{{
	// Shadow request
	initial	r_stb = 1'b0;
	always @(posedge i_clk)
	begin
		if ((i_axi_arvalid)&&(o_axi_arready)&&(o_wb_stb)&&(i_wb_stall))
		begin
			r_stb  <= 1'b1;
			r_addr <= i_axi_araddr[AW+1:AXI_LSBS];
		end else if ((!i_wb_stall)||(!o_wb_cyc))
			r_stb <= 1'b0;

		if ((w_reset)||(o_wb_cyc)&&(i_wb_err)||(err_state))
			r_stb <= 1'b0;
	end
	// }}}

	// wb_pending, wb_outstanding
	// {{{
	initial	wb_pending     = 0;
	initial	wb_outstanding = 0;
	always @(posedge i_clk)
	if ((w_reset)||(!o_wb_cyc)||(i_wb_err)||(err_state))
	begin
		wb_pending     <= 1'b0;
		wb_outstanding <= 0;
	end else case({ (o_wb_stb)&&(!i_wb_stall), i_wb_ack })
	2'b01: begin
		wb_outstanding <= wb_outstanding - 1'b1;
		wb_pending <= (wb_outstanding >= 2);
		end
	2'b10: begin
		wb_outstanding <= wb_outstanding + 1'b1;
		wb_pending <= 1'b1;
		end
	default: begin end
	endcase
	// }}}

	assign	next_first = r_first + 1'b1;
	assign	next_last  = r_last + 1'b1;

	// fifo_full, fifo_empty
	// {{{
	initial	fifo_full  = 1'b0;
	initial	fifo_empty = 1'b1;
	always @(posedge i_clk)
	if (w_reset)
	begin
		fifo_full  <= 1'b0;
		fifo_empty <= 1'b1;
	end else case({ (o_axi_rvalid)&&(i_axi_rready),
				(i_axi_arvalid)&&(o_axi_arready) })
	2'b01: begin
		fifo_full  <= (next_first[LGFIFO-1:0] == r_last[LGFIFO-1:0])
					&&(next_first[LGFIFO]!=r_last[LGFIFO]);
		fifo_empty <= 1'b0;
		end
	2'b10: begin
		fifo_full <= 1'b0;
		fifo_empty <= 1'b0;
		end
	default: begin end
	endcase
	// }}}

	// o_axi_arready
	// {{{
	initial	o_axi_arready = 1'b1;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_arready <= 1'b1;
	else if ((o_wb_cyc && i_wb_err) || err_state)
		// On any error, drop the ready flag until it's been flushed
		o_axi_arready <= 1'b0;
	else if ((i_axi_arvalid)&&(o_axi_arready)&&(o_wb_stb)&&(i_wb_stall))
		// On any request where we are already busy, r_stb will get
		// set and we drop arready
		o_axi_arready <= 1'b0;
	else if (!o_axi_arready && o_wb_stb && i_wb_stall)
		// If we've already stalled on o_wb_stb, remain stalled until
		// the bus clears
		o_axi_arready <= 1'b0;
	else if (fifo_full && (!o_axi_rvalid || !i_axi_rready))
		// If the FIFO is full, we must remain not ready until at
		// least one acknowledgment is accepted
		o_axi_arready <= 1'b0;
	else if ( (!o_axi_rvalid || !i_axi_rready)
			&& (i_axi_arvalid && o_axi_arready))
		o_axi_arready  <= (next_first[LGFIFO-1:0] != r_last[LGFIFO-1:0])
					||(next_first[LGFIFO]==r_last[LGFIFO]);
	else
		o_axi_arready <= 1'b1;
	// }}}

	// r_first
	// {{{
	initial	r_first = 0;
	always @(posedge i_clk)
	if (w_reset)
		r_first <= 0;
	else if ((i_axi_arvalid)&&(o_axi_arready))
		r_first <= r_first + 1'b1;
	// }}}

	// r_mid
	// {{{
	initial	r_mid = 0;
	always @(posedge i_clk)
	if (w_reset)
		r_mid <= 0;
	else if ((o_wb_cyc)&&((i_wb_ack)||(i_wb_err)))
		r_mid <= r_mid + 1'b1;
	else if ((err_state)&&(r_mid != r_first))
		r_mid <= r_mid + 1'b1;
	// }}}

	// r_last
	// {{{
	initial	r_last = 0;
	always @(posedge i_clk)
	if (w_reset)
		r_last <= 0;
	else if ((o_axi_rvalid)&&(i_axi_rready))
		r_last <= r_last + 1'b1;
	// }}}

	// Write to dfifo on data return
	// {{{
	always @(posedge i_clk)
	if ((o_wb_cyc)&&((i_wb_ack)||(i_wb_err)))
		dfifo[r_mid[(LGFIFO-1):0]] <= i_wb_data;
	// }}}

	// err_loc -- FIFO address of any error
	// {{{
	always @(posedge i_clk)
	if ((o_wb_cyc)&&(i_wb_err))
		err_loc <= r_mid;
	// }}}

	assign	read_data = dfifo[r_last[LGFIFO-1:0]];
	assign	o_axi_rdata = read_data[DW-1:0];

	// o_axi_rresp
	// {{{
	initial	o_axi_rresp = 2'b00;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_rresp <= 0;
	else if ((!o_axi_rvalid)||(i_axi_rready))
	begin
		if ((!err_state)&&((!o_wb_cyc)||(!i_wb_err)))
			o_axi_rresp <= 2'b00;
		else if ((!err_state)&&(o_wb_cyc)&&(i_wb_err))
		begin
			if (o_axi_rvalid)
				o_axi_rresp <= (r_mid == next_last) ? 2'b10 : 2'b00;
			else
				o_axi_rresp <= (r_mid == r_last) ? 2'b10 : 2'b00;
		end else if (err_state)
		begin
			if (next_last == err_loc)
				o_axi_rresp <= 2'b10;
			else if (o_axi_rresp[1])
				o_axi_rresp <= 2'b11;
		end else
			o_axi_rresp <= 0;
	end
	// }}}

	// err_state
	// {{{
	initial err_state  = 0;
	always @(posedge i_clk)
	if (w_reset)
		err_state <= 0;
	else if (r_first == r_last)
		err_state <= 0;
	else if ((o_wb_cyc)&&(i_wb_err))
		err_state <= 1'b1;
	// }}}

	// o_axi_rvalid
	// {{{
	initial	o_axi_rvalid = 1'b0;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_rvalid <= 0;
	else if ((o_wb_cyc)&&((i_wb_ack)||(i_wb_err)))
		o_axi_rvalid <= 1'b1;
	else if ((o_axi_rvalid)&&(i_axi_rready))
	begin
		if (err_state)
			o_axi_rvalid <= (next_last != r_first);
		else
			o_axi_rvalid <= (next_last != r_mid);
	end
	// }}}

	// Make Verilator happy
	// {{{
	// verilator lint_off UNUSED
	wire	unused;
	assign	unused = &{ 1'b0, i_axi_arprot,
			i_axi_araddr[AXI_LSBS-1:0], fifo_empty };
	// verilator lint_on  UNUSED
	// }}}
// }}}
endmodule
`ifndef	YOSYS
`default_nettype wire
`endif

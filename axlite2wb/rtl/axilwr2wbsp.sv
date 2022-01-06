////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	axilwr2wbsp.v (AXI lite to wishbone slave, read channel)
// {{{
// Project:	WB2AXIPSP: bus bridges and other odds and ends
//
// Purpose:	Bridge an AXI lite write channel triplet to a single wishbone
//		write channel.  A full AXI lite to wishbone bridge will also
//	require the read channel and an arbiter.
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
module	axilwr2wbsp #(
		// {{{
		parameter C_AXI_DATA_WIDTH	= 32,
		parameter C_AXI_ADDR_WIDTH	= 28,
		localparam	AXI_LSBS = $clog2(C_AXI_DATA_WIDTH/8),
		localparam AW			= C_AXI_ADDR_WIDTH-AXI_LSBS,
		parameter LGFIFO                =  3,
		localparam	DW = C_AXI_DATA_WIDTH
		// }}}
	) (
		// {{{
		input	wire			i_clk,
		input	wire			i_axi_reset_n,
		// AXI write address channel signals
		// {{{
		input	wire			i_axi_awvalid,
		output	reg			o_axi_awready,
		input	wire	[AW-1:0]	i_axi_awaddr,
		input	wire	[2:0]		i_axi_awprot,
		// }}}
		// AXI write data channel signals
		// {{{
		input	wire			i_axi_wvalid,
		output	reg			o_axi_wready,
		input	wire	[DW-1:0]	i_axi_wdata,
		input	wire	[DW/8-1:0]	i_axi_wstrb,
		// }}}
		// AXI write response channel signals
		// {{{
		output	reg			o_axi_bvalid,
		input	wire			i_axi_bready,
		output	reg	[1:0]		o_axi_bresp,
		// }}}
		// Wishbone signals
		// {{{
		// We'll share the clock and the reset
		output	reg				o_wb_cyc,
		output	reg				o_wb_stb,
		output	reg	[(AW-1):0]		o_wb_addr,
		output	reg	[(DW-1):0]		o_wb_data,
		output	reg	[(DW/8-1):0]		o_wb_sel,
		input	wire				i_wb_ack,
		input	wire				i_wb_stall,
		input	wire				i_wb_err
		// }}}
	);

	// Local declarations
	// {{{
	wire	w_reset;
	assign	w_reset = (!i_axi_reset_n);

	reg			r_awvalid, r_wvalid;
	reg	[AW-1:0]	r_addr;
	reg	[DW-1:0]	r_data;
	reg	[DW/8-1:0]	r_sel;

	reg			fifo_full, fifo_empty;

	reg	[LGFIFO:0]	r_first, r_mid, r_last;
	wire	[LGFIFO:0]	next_first, next_last;
	reg			wb_pending;
	reg	[LGFIFO:0]	wb_outstanding;

	reg	[LGFIFO:0]	err_loc;
	reg			err_state;

	wire	axi_write_accepted, pending_axi_write;
	// }}}

	assign	pending_axi_write =
		((r_awvalid) || (i_axi_awvalid && o_axi_awready))
		&&((r_wvalid)|| (i_axi_wvalid && o_axi_wready));

	assign	axi_write_accepted =
		(!o_wb_stb || !i_wb_stall) && (!err_state)
			&& (pending_axi_write);

	// o_wb_cyc, o_wb_stb
	// {{{
	initial	o_wb_cyc = 1'b0;
	initial	o_wb_stb = 1'b0;
	always @(posedge i_clk)
	if ((w_reset)||((o_wb_cyc)&&(i_wb_err))||(err_state))
		o_wb_stb <= 1'b0;
	else if (axi_write_accepted)
		o_wb_stb <= 1'b1;
	else if ((o_wb_cyc)&&(!i_wb_stall))
		o_wb_stb <= 1'b0;

	always @(*)
		o_wb_cyc = (wb_pending)||(o_wb_stb);
	// }}}

	// o_wb_addr, o_wb_data, o_wb_sel
	// {{{
	always @(posedge i_clk)
	if ((!o_wb_stb || !i_wb_stall)&&(!o_wb_cyc))
	begin
		if (r_awvalid)
			o_wb_addr <= r_addr;
		else
		//  o_wb_addr <= i_axi_awaddr[AW+1:AXI_LSBS];
		    o_wb_addr <= i_axi_awaddr;

		if (r_wvalid)
		begin
			o_wb_data <= r_data;
			o_wb_sel  <= r_sel;
		end else begin
			o_wb_data <= i_axi_wdata;
			o_wb_sel  <= i_axi_wstrb;
		end
	end
	// }}}

	// r_awvalid, r_addr
	// {{{
	initial	r_awvalid = 1'b0;
	always @(posedge i_clk)
	begin
		if ((i_axi_awvalid)&&(o_axi_awready))
		begin
			r_addr <= i_axi_awaddr;
			r_awvalid <= (!axi_write_accepted);
		end else if (axi_write_accepted)
			r_awvalid <= 1'b0;

		if (w_reset)
			r_awvalid <= 1'b0;
	end
	// }}}

	// r_wvalid
	// {{{
	initial	r_wvalid = 1'b0;
	always @(posedge i_clk)
	begin
		if ((i_axi_wvalid)&&(o_axi_wready))
		begin
			r_data <= i_axi_wdata;
			r_sel  <= i_axi_wstrb;
			r_wvalid <= (!axi_write_accepted);
		end else if (axi_write_accepted)
			r_wvalid <= 1'b0;

		if (w_reset)
			r_wvalid <= 1'b0;
	end
	// }}}

	// o_axi_awready
	// {{{
	initial	o_axi_awready = 1'b1;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_awready <= 1'b1;
	else if ((o_wb_stb && i_wb_stall)
			&&(r_awvalid || (i_axi_awvalid && o_axi_awready)))
		// Once a request has been received while the interface is
		// stalled, we must stall and wait for it to clear
		o_axi_awready <= 1'b0;
	else if (err_state && (r_awvalid || (i_axi_awvalid && o_axi_awready)))
		o_axi_awready <= 1'b0;
	else if ((r_awvalid || (i_axi_awvalid && o_axi_awready))
		&&(!r_wvalid && (!i_axi_wvalid || !o_axi_wready)))
		// If the write address is given without any corresponding
		// write data, immediately stall and wait for the write data
		o_axi_awready <= 1'b0;
	else if (!o_axi_awready && o_wb_stb && i_wb_stall)
		// Once stalled, remain stalled while the WB bus is stalled
		o_axi_awready <= 1'b0;
	else if (fifo_full && (r_awvalid || (!o_axi_bvalid || !i_axi_bready)))
		// Once the FIFO is full, we must remain stalled until at
		// least one acknowledgment has been accepted
		o_axi_awready <= 1'b0;
	else if ((!o_axi_bvalid || !i_axi_bready)
			&& (r_awvalid || (i_axi_awvalid && o_axi_awready)))
		o_axi_awready  <= 1'b1;
	else
		o_axi_awready <= 1'b1;
	// }}}

	// o_axi_wready
	// {{{
	initial	o_axi_wready = 1'b1;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_wready <= 1'b1;
	else if ((o_wb_stb && i_wb_stall)
			&&(r_wvalid || (i_axi_wvalid && o_axi_wready)))
		// Once a request has been received while the interface is
		// stalled, we must stall and wait for it to clear
		o_axi_wready <= 1'b0;
	else if (err_state && (r_wvalid || (i_axi_wvalid && o_axi_wready)))
		o_axi_wready <= 1'b0;
	else if ((r_wvalid || (i_axi_wvalid && o_axi_wready))
		&&(!r_awvalid && (!i_axi_awvalid || !o_axi_awready)))
		// If the write address is given without any corresponding
		// write data, immediately stall and wait for the write data
		o_axi_wready <= 1'b0;
	else if (!o_axi_wready && o_wb_stb && i_wb_stall)
		// Once stalled, remain stalled while the WB bus is stalled
		o_axi_wready <= 1'b0;
	else if (fifo_full && (r_wvalid || (!o_axi_bvalid || !i_axi_bready)))
		// Once the FIFO is full, we must remain stalled until at
		// least one acknowledgment has been accepted
		o_axi_wready <= 1'b0;
	else if ((!o_axi_bvalid || !i_axi_bready)
			&& (i_axi_wvalid && o_axi_wready))
		// If ever the FIFO becomes full, we must immediately drop
		// the o_axi_wready signal
		o_axi_wready  <= 1'b1;
	else
		o_axi_wready <= 1'b1;
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


	// }}}

	// o_axi_bresp
	// {{{
	initial	o_axi_bresp = 2'b00;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_bresp <= 0;
	else if ((!o_axi_bvalid)||(i_axi_bready))
	begin
		if ((!err_state)&&((!o_wb_cyc)||(!i_wb_err)))
			o_axi_bresp <= 2'b00;
		else if ((!err_state)&&(o_wb_cyc)&&(i_wb_err))
		begin
			o_axi_bresp <= 2'b10;
		end else if (err_state)
		begin
			o_axi_bresp <= 2'b10;
		end else
			o_axi_bresp <= 0;
	end
	// }}}

	// err_state
	// {{{
	initial err_state  = 0;
	always @(posedge i_clk)
	if (w_reset)
		err_state <= 0;
	else if ((o_wb_cyc)&&(i_wb_err))
		err_state <= 1'b1;
	else err_state <= 0;	
		
	// }}}

	// o_axi_bvalid
	// {{{
	initial	o_axi_bvalid = 1'b0;
	always @(posedge i_clk)
	if (w_reset)
		o_axi_bvalid <= 0;
	else if ((o_wb_cyc)&&((i_wb_ack)||(i_wb_err)))
		o_axi_bvalid <= 1'b1;
	else if ((o_axi_bvalid)&&(i_axi_bready))
	begin
		o_axi_bvalid <= 1'b0;
	end
	// }}}

	// Make Verilator happy
	// {{{
	// verilator lint_off UNUSED
	wire	unused;
	assign	unused = &{ 1'b0, i_axi_awprot,
				fifo_empty };
	// verilator lint_on  UNUSED
	// }}}
// }}}
endmodule

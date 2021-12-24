/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE rev.B2 compliant I2C Master controller Testbench  ////
////                                                             ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/projects/i2c/    ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: tst_bench_top.v,v 1.8 2006-09-04 09:08:51 rherveille Exp $
//
//  $Date: 2006-09-04 09:08:51 $
//  $Revision: 1.8 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.7  2005/02/27 09:24:18  rherveille
//               Fixed scl, sda delay.
//
//               Revision 1.6  2004/02/28 15:40:42  rherveille
//               *** empty log message ***
//
//               Revision 1.4  2003/12/05 11:04:38  rherveille
//               Added slave address configurability
//
//               Revision 1.3  2002/10/30 18:11:06  rherveille
//               Added timing tests to i2c_model.
//               Updated testbench.
//
//               Revision 1.2  2002/03/17 10:26:38  rherveille
//               Fixed some race conditions in the i2c-slave model.
//               Added debug information.
//               Added headers.
//

//`include "timescale.v"
import uvm_pkg::*;
//`include "/home/users/hamza.hassan/projects/axi_apb_bridge/RTL/axi_lite_pkg.sv"
import axi_lite_pkg::*;
`include "/home/users/hamza.hassan/projects/axi_apb_bridge/RTL/axi_lite_master.sv"


/*
module axi_i2c_package 
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

	wire scl, scl0_o, scl0_oen;
	wire sda, sda0_o, sda0_oen;

	
	wire [3:0]	wb_sel;
	//

		
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
		.i_wb_err(1'b0)
		// }}}
		// }}}
	);
//

	assign dat_i = dat0_i;

	// hookup wishbone_i2c_master core
	i2c_master_top i2c_top (

		// wishbone interface
		.wb_clk_i(clk),
		.wb_rst_i(1'b0),
		.arst_i(axi_reset_n),
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
		.scl_pad_o(scl0_o),
		.scl_padoen_o(scl0_oen),
		.sda_pad_i(sda),
		.sda_pad_o(sda0_o),
		.sda_padoen_o(sda0_oen)
	);


endmodule

*/

module tst_bench_top();

axi_lite_if vif();
axi_lite_if axi_lite_master_vif();


logic areset_n;
logic start_read;
logic start_write;
logic[31:0] write_data= 10;
logic[31:0] read_data ;
logic[31:0] write_read_address = 4;
axi_lite_master axi_lite_master_DUT(
	vif.clk,
	areset_n,
	axi_lite_master_vif.master,
	start_read,
	start_write,
	write_data,
	write_read_address
);
	//
	// wires && regs
	//
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

	wire scl, scl0_o, scl0_oen, scl1_o, scl1_oen;
	wire sda, sda0_o, sda0_oen, sda1_o, sda1_oen;

	parameter PRER_LO = 3'b000;
	parameter PRER_HI = 3'b001;
	parameter CTR     = 3'b010;
	parameter RXR     = 3'b011;
	parameter TXR     = 3'b011;
	parameter CR      = 3'b100;
	parameter SR      = 3'b100;

	parameter TXR_R   = 3'b101; // undocumented / reserved output
	parameter CR_R    = 3'b110; // undocumented / reserved output

	parameter RD      = 1'b1;
	parameter WR      = 1'b0;
	parameter SADR    = 7'b0010_000;
	parameter C_AXI_DATA_WIDTH = 32;
	
	wire [C_AXI_DATA_WIDTH/8-1:0]	wb_sel;
	//
	// Module body
	//

	// generate clock
	always #5 clk = ~clk;
      
	axi_i2c_bridge axi_i2c_bridge_(
		.clk(vif.clk),	// System clock
		.axi_reset_n(areset_n),
		
		// AXI write address channel signals
		// {{{
		.axi_awvalid(axi_lite_master_vif.s_axi_awvalid),
		.axi_awready(axi_lite_master_vif.s_axi_awready),
		.axi_awaddr(axi_lite_master_vif.s_axi_awaddr),
		.axi_awprot(axi_lite_master_vif.s_axi_arprot),
		// }}}
		// AXI write data channel signals
		// {{{
		.axi_wvalid(axi_lite_master_vif.s_axi_wvalid),
		.axi_wready(axi_lite_master_vif.s_axi_wready), 
		.axi_wdata(axi_lite_master_vif.s_axi_wdata),
		.axi_wstrb(axi_lite_master_vif.s_axi_wstrb),
		// }}}
		// AXI write response channel signals
		// {{{
		.axi_bvalid(axi_lite_master_vif.s_axi_bvalid),
		.axi_bready(axi_lite_master_vif.s_axi_bready),
		.axi_bresp(axi_lite_master_vif.s_axi_bresp),
		// }}}
		// AXI read address channel signals
		// {{{
		.axi_arvalid(axi_lite_master_vif.s_axi_arvalid),
		.axi_arready(axi_lite_master_vif.s_axi_arready),
		.axi_araddr(axi_lite_master_vif.s_axi_araddr),
		.axi_arprot(axi_lite_master_vif.s_axi_arprot),
		// }}}
		// AXI read data channel signals
		// {{{
		.axi_rvalid(axi_lite_master_vif.s_axi_rvalid),
		.axi_rready(axi_lite_master_vif.s_axi_rready),
		.axi_rdata(axi_lite_master_vif.s_axi_rdata),
		.axi_rresp(axi_lite_master_vif.s_axi_rresp),
		
		.scl_pad_i(scl),
		.scl_pad_o(scl0_o),
		.scl_padoen_o(scl0_oen),
		.sda_pad_i(sda),
		.sda_pad_o(sda0_o),
		.sda_padoen_o(sda0_oen)	
	
	
	);
	
	
	/*	
	axlite2wbsp axit_to_wb_bridge
	
	      (
		// {{{
		.i_clk(vif.clk),	// System clock
		.i_axi_reset_n(areset_n),
		
		// AXI write address channel signals
		// {{{
		.i_axi_awvalid(axi_lite_master_vif.s_axi_awvalid),
		.o_axi_awready(axi_lite_master_vif.s_axi_awready),
		.i_axi_awaddr(axi_lite_master_vif.s_axi_awaddr),
		.i_axi_awprot(axi_lite_master_vif.s_axi_arprot),
		// }}}
		// AXI write data channel signals
		// {{{
		.i_axi_wvalid(axi_lite_master_vif.s_axi_wvalid),
		.o_axi_wready(axi_lite_master_vif.s_axi_wready), 
		.i_axi_wdata(axi_lite_master_vif.s_axi_wdata),
		.i_axi_wstrb(axi_lite_master_vif.s_axi_wstrb),
		// }}}
		// AXI write response channel signals
		// {{{
		.o_axi_bvalid(axi_lite_master_vif.s_axi_bvalid),
		.i_axi_bready(axi_lite_master_vif.s_axi_bready),
		.o_axi_bresp(axi_lite_master_vif.s_axi_bresp),
		// }}}
		// AXI read address channel signals
		// {{{
		.i_axi_arvalid(axi_lite_master_vif.s_axi_arvalid),
		.o_axi_arready(axi_lite_master_vif.s_axi_arready),
		.i_axi_araddr(axi_lite_master_vif.s_axi_araddr),
		.i_axi_arprot(axi_lite_master_vif.s_axi_arprot),
		// }}}
		// AXI read data channel signals
		// {{{
		.o_axi_rvalid(axi_lite_master_vif.s_axi_rvalid),
		.i_axi_rready(axi_lite_master_vif.s_axi_rready),
		.o_axi_rdata(axi_lite_master_vif.s_axi_rdata),
		.o_axi_rresp(axi_lite_master_vif.s_axi_rresp),
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
		.i_wb_err(1'b0)
		// }}}
		// }}}
	);
//
*/
/*
	wire stb0 = stb & ~adr[3];
	wire stb1 = stb &  adr[3];

	assign dat_i = dat0_i;

	// hookup wishbone_i2c_master core
	i2c_master_top i2c_top (

		// wishbone interface
		.wb_clk_i(vif.clk),
		.wb_rst_i(1'b0),
		.arst_i(areset_n),
		.wb_adr_i(adr[2:0]),
		.wb_dat_i(dat_o),
		.wb_dat_o(dat0_i),
		.wb_we_i(we),
		.wb_stb_i(stb0),
		.wb_cyc_i(cyc),
		.wb_ack_o(ack),
		.wb_inta_o(inta),

		// i2c signals
		.scl_pad_i(scl),
		.scl_pad_o(scl0_o),
		.scl_padoen_o(scl0_oen),
		.sda_pad_i(sda),
		.sda_pad_o(sda0_o),
		.sda_padoen_o(sda0_oen)
	);
	*/
	/*
	i2c_top2 (

		// wishbone interface
		.wb_clk_i(vif.clk),
		.wb_rst_i(1'b0),
		.arst_i(areset_n),
		.wb_adr_i(adr[2:0]),
		.wb_dat_i(dat_o),
		.wb_dat_o(dat1_i),
		.wb_we_i(we),
		.wb_stb_i(stb1),
		.wb_cyc_i(cyc),
		.wb_ack_o(ack),
		.wb_inta_o(inta),

		// i2c signals
		.scl_pad_i(scl),
		.scl_pad_o(scl1_o),
		.scl_padoen_o(scl1_oen),
		.sda_pad_i(sda),
		.sda_pad_o(sda1_o),
		.sda_padoen_o(sda1_oen)
	);
*/

	// hookup i2c slave model
	i2c_slave_model #(SADR) i2c_slave (
		.scl(scl),
		.sda(sda)
	);

        // create i2c lines
	delay m0_scl (scl0_oen ? 1'bz : scl0_o, scl),
	      m0_sda (sda0_oen ? 1'bz : sda0_o, sda);

	pullup p1(scl); // pullup scl line
	pullup p2(sda); // pullup sda line


initial begin
    vif.clk  = 1'b1;
    areset_n = 1'b1;
    start_read  = 0;
    start_write = 0;
    #30;
    areset_n = 1'b0; 
    #30;  
    areset_n = 1'b1; 
    #500000;
   $finish;
 
end

typedef enum logic [3 : 0] {start, write_data_state, write_resp, read_data_state, read_resp, match,finish} test_state;

test_state test_state_ = start;
int repetetions = 0;
int slave_no    = 1;


   always @(posedge vif.clk) begin
	if(test_state_ == start) begin
		test_state_ <= write_data_state;
				
		if(slave_no>=2) slave_no = 1;
		else		slave_no += 1;
		
		
	end
	else if(test_state_ == write_data_state) begin
		test_state_ <= write_resp;
		write(repetetions,4);
		
	end
	else if(test_state_ == write_resp) begin
		if(axi_lite_master_vif.s_axi_bvalid) test_state_ <= read_data_state;
		else test_state_ <= write_resp;
	end
	else if(test_state_ == read_data_state) begin
		test_state_ <= read_resp;  
		read(4);

		
	end
	else if(test_state_ == read_resp) begin
		if(axi_lite_master_vif.s_axi_rvalid)  begin
				test_state_ <= match;
				read_data   = axi_lite_master_vif.s_axi_rdata;
		end
		else test_state_ <= read_resp;
	end
	else if(test_state_ == match) begin
		if(repetetions >= 20)  test_state_ <= finish;
		else begin
			repetetions <= repetetions + 1;
			test_state_ <= start;
			if(read_data != write_data) $display(write_data ," read_data " ,read_data," test fail");
			else 		     $display(" write_data = ",write_data ," read_data = " ,read_data," test pass");
		end
			/*
			test_state_ <= finish;
			$finish;
			*/
		
	end
	else begin
			test_state_ <= finish;
			$finish;
	end
   end


task write(int data, int address);
        start_write = 1;
  	start_read  = 0;
	write_data  = data;
    	write_read_address  = address;
endtask: write 

task read(int address);
        start_write = 0;
  	start_read  = 1;
    	write_read_address    = address;

endtask: read

initial begin 
	$dumpfile("waves.vcd");
	$dumpvars();

end

always begin
    #5 vif.clk = ~vif.clk;
	
end

endmodule

module delay (in, out);
  input  in;
  output out;

  assign out = in;

  specify
    (in => out) = (600,600);
  endspecify
endmodule



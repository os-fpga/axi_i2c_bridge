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
	parameter RXR     = 3'b101;
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
	
	wire sda,scl;

	//
	// Module body
	//

	// generate clock
	always #5 clk = ~clk;
      
	axi_i2c_slave_combined axi_i2c_bridge_combined_(
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
		.sda_o(sda),
		.scl_o(scl)
		
	
	);
	/*
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
	*/
	
	// hookup i2c slave model
	/*
	i2c_slave_model #(SADR) i2c_slave_m (
		.scl(scl),
		.sda(sda)
	);
	
	
	i2c_slave #(SADR) i2c_slave_ (
		.scl(scl),
		.rst(areset_n),
		.sda(sda)
	);
        // create i2c lines
        
        assign scl = scl0_oen ? 1'bz : scl0_o;
        assign sda = sda0_oen ? 1'bz : sda0_o;
        
        
	delay m0_scl (scl0_oen ? 1'bz : scl0_o, scl),
	      m0_sda (sda0_oen ? 1'bz : sda0_o, sda);
	
	
	pullup p1(scl); // pullup scl line
	pullup p2(sda); // pullup sda line
	*/

initial begin
    vif.clk  = 1'b1;
    areset_n = 1'b1;
    start_read  = 0;
    start_write = 0;
    #30;
    areset_n = 1'b0; 
    #30;  
    areset_n = 1'b1; 
    #500;
    release scl;
    /*
    while (scl) #1;
    force scl= 1'b0;
    #100000;
    release scl;
    */
      #5000000000;
   $finish;
 
end

typedef enum logic [3 : 0] {start, write_data_state, write_resp, read_data_state, read_resp, match,finish} test_state;
//write to the transmit register in the core
//write to the command register either read or write
//keep monitoring the status register by doing reads from axi master 
//read the data from receive register
//typedef enum logic [3 : 0] {start_i2c, write_slave_addr_to_txr,write_resp_i2c, write_command, wait_for_ack,finish_i2c} i2c_start_sequence;
//
int state = 0;
int initial_state = 0;

test_state test_state_ = start;
//i2c_start_sequence test_state_i2c = start_i2c;
int repetetions = 0;
int slave_no    = 1;
bit waiting_read_resp = 1'b0;
bit waiting = 1'b0;
bit check_tip = 1'b1;

parameter write_txr_addr = 3;
parameter read_txr_addr  = 5;

parameter write_cr_addr = 4;
parameter read_cr_addr  = 6;

parameter read_sr_addr  = 4;

parameter write_ctr_addr = 2;
parameter read_ctr_addr  = 2;

parameter read_rxr_addr   = 3;

parameter write_pre_scaler_low_addr = 0;

/*
read_addresses
	    3'b000: wb_dat_o <= #1 prer[ 7:0]; same write address 
	    3'b001: wb_dat_o <= #1 prer[15:8]; same write address 
	    
	    3'b010: wb_dat_o <= #1 ctr; same write address 
	    
	    3'b011: wb_dat_o <= #1 rxr; // write is transmit register (txr)
	    
	    3'b100: wb_dat_o <= #1 sr;  // write is command register (cr)
	    
	    3'b101: wb_dat_o <= #1 txr; // write address  = 3'b011
	    
	    3'b110: wb_dat_o <= #1 cr;  write address = 3'b100
	    
	    3'b111: wb_dat_o <= #1 0;   // reserved
*/
/*
write addresses


*/
always @(posedge vif.clk) begin
      i2c_start();
      //test_zero();

end

task write_to_i2c_slave_modified(int addr,int data);
//write to prescaler register to generate scl
//write to control register to enable the i2c core
//write to transmit register the slave address and tranfer direction bit
//write to command register to create the start sequence and write sequence


     if(state == initial_state) 	  blocking_write(write_pre_scaler_low_addr,{8'hc8}); // enabling core by writing to control register
     else if(state == (initial_state+1))  blocking_write(write_ctr_addr,{8'b10000000});
     else if(state == (initial_state+2))  blocking_write(write_txr_addr,{SADR,1'b0});   // writing to transmit register the slave address with write flag
     else if(state == (initial_state+3))  blocking_write(write_cr_addr,{8'b10010000});
     else if(state == (initial_state+4))  blocking_read(read_sr_addr,1,-1);     // read the status register for TIP Flag slave address with write flag
     else if(state == (initial_state+5))  begin
	      if((read_data & {8'b00000010}) == 0) begin
		$display(" Transfered Address to I2C Slave");
		state += 1;
	      end
	      else blocking_read(read_sr_addr,0,-1);  
     end 
     else if(state == (initial_state+6))  blocking_write(write_txr_addr,addr);
     else if(state == (initial_state+7))  blocking_write(write_cr_addr,{8'b00010000});
     else if(state == (initial_state+8))  blocking_read(read_sr_addr,1,-1);     // read the status register for TIP Flag slave address with write flag
     else if(state == (initial_state+9))  begin
	      if((read_data & {8'b00000010}) == 0) begin
		$display(" Transfered Write Address to I2C Slave");
		state += 1;
	      end
	      else blocking_read(read_sr_addr,0,-1);  
     end 
     else if(state == (initial_state+10))  blocking_write(write_txr_addr,data);
     else if(state == (initial_state+11))  blocking_write(write_cr_addr,{8'b00010000});
     else if(state == (initial_state+12))  blocking_read(read_sr_addr,1,-1);     // read the status register for TIP Flag slave address with write flag
     else if(state == (initial_state+13))  begin
	      if((read_data & {8'b00000010}) == 0) begin
		$display(" Transfered Write Data to I2C Slave");
		state += 1;
	      end
	      else blocking_read(read_sr_addr,0,-1);  
     end
     else if(state == (initial_state+14)) begin
     
	  initial_state += 1;
	  state = initial_state;
     end
      
      
endtask: write_to_i2c_slave_modified


task write_to_i2c_slave(int addr,int data);

     if(state == initial_state) 	  blocking_write(write_pre_scaler_low_addr,{8'hc8}); // enabling core by writing to control register
     else if(state == (initial_state+1))  blocking_write(write_ctr_addr,{8'b10000000});
     else if(state == (initial_state+2))  blocking_write(write_txr_addr,{SADR,1'b0});   // writing to transmit register the slave address with write flag
     else if(state == (initial_state+3))  blocking_write(write_cr_addr,{8'b10010000});
     else if(state == (initial_state+4))  blocking_read(read_sr_addr,1,-1);     // read the status register for TIP Flag slave address with write flag
     else if(state == (initial_state+5))  begin
	      if((read_data & {8'b00000010}) == 0) begin
		$display(" Transfered Address to I2C Slave");
		state += 1;
	      end
	      else blocking_read(read_sr_addr,0,-1);  
     end 
     else if(state == (initial_state+6))  blocking_write(write_txr_addr,addr);
     else if(state == (initial_state+7))  blocking_write(write_cr_addr,{8'b00010000});
     else if(state == (initial_state+8))  blocking_read(read_sr_addr,1,-1);     // read the status register for TIP Flag slave address with write flag
     else if(state == (initial_state+9))  begin
	      if((read_data & {8'b00000010}) == 0) begin
		$display(" Transfered Write Address to I2C Slave");
		state += 1;
	      end
	      else blocking_read(read_sr_addr,0,-1);  
     end 
     else if(state == (initial_state+10))  blocking_write(write_txr_addr,data);
     else if(state == (initial_state+11))  blocking_write(write_cr_addr,{8'b00010000});
     else if(state == (initial_state+12))  blocking_read(read_sr_addr,1,-1);     // read the status register for TIP Flag slave address with write flag
     else if(state == (initial_state+13))  begin
	      if((read_data & {8'b00000010}) == 0) begin
		$display(" Transfered Write Data to I2C Slave");
		state += 1;
	      end
	      else blocking_read(read_sr_addr,0,-1);  
     end
     else if(state == (initial_state+14)) begin
     
	  initial_state += 1;
	  state = initial_state;
     end
      
      
endtask: write_to_i2c_slave
  
task read_from_i2c_slave(int addr,int  last_ = 0 );

     if(state == initial_state) 	  blocking_write(write_pre_scaler_low_addr,{8'hc8}); // enabling core by writing to control register
     else if(state == (initial_state+1))  blocking_write(write_ctr_addr,{8'b10000000});
     else if(state == (initial_state+2))  blocking_write(write_txr_addr,{SADR,1'b1});   // writing to transmit register the slave address with write flag
     else if(state == (initial_state+3))  blocking_write(write_cr_addr,{8'b10010001});
     else if(state == (initial_state+4))  blocking_read(read_sr_addr,1,-1);     // read the status register for TIP Flag slave address with write flag
     else if(state == (initial_state+5))  begin
	      if((read_data & {8'b00000001}) == 1) begin
		$display(" Transfered Slave Address to I2C Slave");
		state += 1;
	      end
	      else blocking_read(read_sr_addr,0,-1);  
     end
     else if(state == (initial_state+6))  blocking_write(write_txr_addr,addr);   // writing to transmit register the slave address with write flag
     else if(state == (initial_state+7))  blocking_write(write_cr_addr,{8'b00010001});
     else if(state == (initial_state+8))  blocking_read(read_sr_addr,1,-1);     // read the status register for TIP Flag slave address with write flag
     else if(state == (initial_state+9))  begin
	      if((read_data & {8'b00000001}) == 1) begin
		$display(" Transfered Read Address to I2C Slave");
		state += 1;
	      end
	      else blocking_read(read_sr_addr,0,-1);  
     end
     else if(state == (initial_state+10))  blocking_write(write_cr_addr,{8'b00100001});
     else if(state == (initial_state+11))  blocking_read(read_sr_addr,1,-1);     // read the status register for TIP Flag slave address with write flag
     else if(state == (initial_state+12))  begin
	      if((read_data & {8'b00000001}) == 1) begin
		$display(" Received data from I2C ");
		state += 1;
	      end
	      else blocking_read(read_sr_addr,0,-1);  
     end
     else if(state == (initial_state+13))  blocking_read(read_rxr_addr);
     else if(state == (initial_state+14)) begin
	  //if(last_ == 1) #200000;
	  $display(" Data Received from Addr %d data = %d ",addr,read_data);
	  initial_state += 1;
	  state = initial_state;  
     end
     /*
     //else if(state == (initial_state+6))  blocking_write(write_txr_addr,addr);
     else if(state == (initial_state+6))  blocking_write(write_cr_addr,{8'b00100000});
     else if(state == (initial_state+7))  blocking_read(read_sr_addr,1,-1);     // read the status register for TIP Flag slave address with write flag
     else if(state == (initial_state+8))  begin
	      if((read_data & {8'b00000010}) == 0) begin
		$display(" Received Read Data from I2C Slave");
		state += 1;
	      end
	      else blocking_read(read_sr_addr,0,-1);  
     end 
     */
     /*
     else if(state == (initial_state+9)) begin
     
	  initial_state += 1;
	  state = initial_state;
     end
     */ 
      
endtask: read_from_i2c_slave
  

task i2c_start();
	
	if(initial_state == 0) 	     	     write_to_i2c_slave(0,1);
	else if(initial_state == 1) 	     write_to_i2c_slave(1,2);
	else if(initial_state == 2) 	     write_to_i2c_slave(2,3);
	else if(initial_state == 3) 	     write_to_i2c_slave(3,4);	
	else if(initial_state == 4) 	     write_to_i2c_slave(4,5);
	else if(initial_state == 5) 	     write_to_i2c_slave(5,6);
	else if(initial_state == 6) 	     write_to_i2c_slave(6,7);
	else if(initial_state == 7) 	     write_to_i2c_slave(7,8);
	else if(initial_state == 8) 	     read_from_i2c_slave(0);
	else if(initial_state == 9) 	     read_from_i2c_slave(1);
	else if(initial_state == 10) 	     read_from_i2c_slave(2);
	else if(initial_state == 11) 	     read_from_i2c_slave(3);
	else if(initial_state == 12) 	     read_from_i2c_slave(4);
	else if(initial_state == 13) 	     read_from_i2c_slave(5);
	else if(initial_state == 14) 	     read_from_i2c_slave(6);
	else if(initial_state == 15) 	     read_from_i2c_slave(7);
	else if(initial_state == 16) 	     write_to_i2c_slave(1,4);
	else if(initial_state == 17) 	     write_to_i2c_slave(2,8);
	else if(initial_state == 18) 	     write_to_i2c_slave(3,12);	
	else if(initial_state == 19) 	     read_from_i2c_slave(2);
	else if(initial_state == 20) 	     read_from_i2c_slave(1);
	/*else if(initial_state == 1)  write_to_i2c_slave(1,8'hAD);
	else if(initial_state == 2)  write_to_i2c_slave(0,8'hc8);
	else if(initial_state == 3)  read_from_i2c_slave();
	*/
	else $finish;
	
	
endtask: i2c_start

task blocking_write(int addr,int data,int inc_state = 1);
	if(!waiting) begin
	  write(data,addr); //enable core by writing to  to txr
	  waiting = 1'b1;
	end
	else begin
	  if(axi_lite_master_vif.s_axi_bvalid)begin 
	    waiting = 1'b0;
	    if(inc_state==1) state = state + 1; //checking write response
	  end
	end
	
endtask: blocking_write

task blocking_read(int addr,inc_state = 1, compare = -1);
	if(!waiting) begin
	  read(addr); //enable core by writing to  to txr
	  waiting = 1'b1;
	end
	else begin
	  if(axi_lite_master_vif.s_axi_rvalid)begin
	    read_data   = axi_lite_master_vif.s_axi_rdata;
	    if(compare>=0) begin
	      if(read_data != compare) begin
		  $display(" read_data = ",read_data ," write_data = " ,compare," Read data is not equal to Write data. FAIL");
		  //$finish;
	      end
	      else begin
		  $display(" read_data = ",read_data ," write_data = " ,compare," Read data is equal to Write data. PASS");
		  waiting = 1'b0;
		  if(inc_state == 1) state += 1; //checking write response
		  
	      end
	    end
	    else begin
	      waiting = 1'b0;
	      if(inc_state == 1) state += 1; //checking write response
	    end
	  end
	end

endtask: blocking_read
   
task test_zero();

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
	
	end
	else begin
			test_state_ <= finish;
			$finish;
	end


endtask: test_zero

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



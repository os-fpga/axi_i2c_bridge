module i2c_slave(input scl,rst ,input sda_i,output sda_o, output sda_oen ,output [7:0] mem_out);

reg ld ;
reg dec;
reg start;
reg stop;
reg[2:0] state;
reg[2:0] cnt;
wire [2:0] next_state;
reg[7:0] sr;
reg[7:0] data_capture_reg;
reg[7:0] mem_addr;
reg[7:0] mem_read_reg;
reg[7:0] mem[15:0];
reg read;
reg tc;
reg output_control;

//mem registers
reg [7:0] reg_0;
reg [7:0] reg_1;
reg [7:0] reg_2;
reg [7:0] reg_3;
reg [7:0] reg_4;
reg [7:0] reg_5;
reg [7:0] reg_6;
reg [7:0] reg_7;

assign mem_out = {sr[2:0],state,stop,start};

localparam get_slave_addr    = 3'h0;
localparam slave_addr_ack    = 3'h1;
localparam get_mem_addr      = 3'h2;
localparam slave_memaddr_ack = 3'h3;
localparam get_mem_data      = 3'h4;
localparam slave_memdata_ack = 3'h5;
localparam read_mem_data     = 3'h6;
localparam receive_read_ack  = 3'h7;
		 
wire ack_state = (state == slave_addr_ack) |
		 (state == slave_memaddr_ack) |
		 (state == slave_memdata_ack) |
		 (state == receive_read_ack) ;
  
//detect stop condition
always@(posedge sda_i,negedge scl,negedge rst)begin
  if(!rst) stop <= 1'b0;
  else if(scl) begin
    stop <= 1'b1;
    //$display("Stop_condition_detected from I2C slave by H");
  end
  else begin
	  stop <= 1'b0;
  end
end

//detect start condition
always@(negedge sda_i,negedge rst, negedge scl)begin
  if(!rst) start <= 1'b0;
  else if(scl) begin
    start <= 1'b1;
    //$display("Start_condition_detected from I2C slave by H");
  end
  else begin
	  start <= 1'b0;
  end
end

//load of counter
always@(negedge scl,negedge rst)begin
        if(!rst) ld <=1'b0;
	else if(start) begin	
	      ld  <= 1'b1;
	end
	else if(!(|cnt) & state[0]) begin 				
			ld <= 1'b1;
	end
	else      	ld <= 1'b0;
end

//counter logic
always@(posedge scl)begin
	if(ld)				cnt <= 3'b111;
	else if (|cnt & !stop & !tc) 	cnt <= cnt - 1;
	else 				cnt <= cnt;
end

//transfer completed indication
always@(negedge scl , negedge rst )begin
	if(!rst)	tc  <= 1'b0;
	else if(start)  tc  <= 1'b0;
	else if((state == slave_memdata_ack) | (state == receive_read_ack)) tc <= 1'b1;
end

//output control logic
/*
always@(negedge scl,negedge rst)begin
	if(!rst)       			       output_control <= 1'b1;
	else if ((next_ack_state) | ack_state) output_control <= 1'b0;
	else if ((next_state == read_mem_data) | (state == read_mem_data) )  output_control <= mem_read_reg[7];
	else 			output_control <= 1'b1;
end
*/
//mem_read_reg serial shift logic
always@(negedge scl,negedge rst)begin
	if(!rst)       				mem_read_reg <= 8'b00000000;
	else if (state==  slave_memaddr_ack) 	begin
						if(sr==0)      mem_read_reg <= reg_0;
						else if(sr==1) mem_read_reg <= reg_1;
						else if(sr==2) mem_read_reg <= reg_2;
						else if(sr==3) mem_read_reg <= reg_3;
						else if(sr==4) mem_read_reg <= reg_4;
						else if(sr==5) mem_read_reg <= reg_5;
						else if(sr==6) mem_read_reg <= reg_6;
						else if(sr==7) mem_read_reg <= reg_7;
						//$display("Meme Read From Address %d ",sr);
	end
	else if (state == read_mem_data) 	mem_read_reg <= {mem_read_reg[6:0],1'b0};
end


//state machine
always@(negedge scl,negedge rst)begin
	if(start | !rst)	state <= get_slave_addr;
	else if (!(|cnt)) begin
		case(state)
			get_slave_addr: 	state <= slave_addr_ack;
			slave_addr_ack: 	state <= get_mem_addr;
			get_mem_addr  : 	state <= slave_memaddr_ack;
			slave_memaddr_ack:	
					begin
						if(read) begin
						      state <= read_mem_data;
						      
						end
						else begin
						    state <= get_mem_data;
						    
						end
						mem_addr   <= sr;
					end
			get_mem_data :
					begin 
						state <= slave_memdata_ack;
						if(mem_addr==0) reg_0 <= sr;
						else if(mem_addr==1) reg_1 <= sr;
						else if(mem_addr==2) reg_2 <= sr;
						else if(mem_addr==3) reg_3 <= sr;
						else if(mem_addr==4) reg_4 <= sr;
						else if(mem_addr==5) reg_5 <= sr;
						else if(mem_addr==6) reg_6 <= sr;
						else if(mem_addr==7) reg_7 <= sr;	
					end
			read_mem_data:		state <= receive_read_ack;
			slave_memdata_ack:	state <= get_slave_addr;
			receive_read_ack: 	state <= get_slave_addr;
			default              	state <= get_slave_addr;
		endcase
	end
end

//serial register logic
always@(posedge scl)begin
	if(!ack_state)	sr  <= {sr[6:0],sda_i};
end

//data capture register
always@(posedge scl)begin
	if(ack_state)	data_capture_reg  <= sr;
end

//transfer direction capture
always@(posedge scl,negedge rst)begin
	if(!rst) read <= 1'b0;
	else if(state==slave_addr_ack) read  <= sr[0];
end

/*
//next state logic
assign next_state = 	(state == get_slave_addr)    ? slave_addr_ack    :
			(state == slave_addr_ack)    ? get_mem_addr      :
			(state == get_mem_addr)	     ? slave_memaddr_ack :
			(state == slave_memaddr_ack) ? get_mem_data      :
  			(state == get_mem_data)	     ? slave_memdata_ack : get_slave_addr ;

wire high_impedence; 
*/
wire condition = (state == read_mem_data) & (mem_read_reg[7]);

assign sda_oen  = !(ack_state) & !(state == read_mem_data) |
		 (state == read_mem_data) & (mem_read_reg[7]);
		 
assign sda_o    = 1'b0;
//assign   sda   =  high_impedence_condition ? 1'b1 : 1'b0;
//assign sda = !(ack_state) & !(state == read_mem_data) ? 1'bz : (state == read_mem_data) & (mem_read_reg[7]) ? 1'bz : 1'b0; 
  		
endmodule



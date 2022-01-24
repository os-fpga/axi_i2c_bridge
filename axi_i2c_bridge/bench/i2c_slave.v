module i2c_slave(input wire sda, scl);
reg ld ;
reg dec;
reg start;
reg stop;
reg[2:0] state;
reg[2:0] cnt;
wire [2:0] next_state;
reg[7:0] sr;
reg[7:0] data_capture_reg;
localparam get_slave_addr    = 0;
localparam slave_addr_ack    = 1;
localparam get_mem_addr      = 2;
localparam slave_memaddr_ack = 3;
localparam get_mem_data      = 4;
localparam slave_memdata_ack = 5;

  
//detect start condition
always@(negedge scl, negedge sda ,posedge sda)begin
  if(scl & !sda) begin
    start <= 1'b1;
    stop  <= 1'b0;
    $display("Start_condition_detected from I2C slave by H");
  end
  else if(scl & sda) begin
    start <= 1'b0;
    stop  <= 1'b1;
    $display("Stop_condition_detected from I2C slave by H");
  end 
  else  begin
	  start <= 1'b0;
	  stop  <= 1'b0;
  end
end

//load of counter
always@(negedge scl)begin
	if(start)	ld <= 1'b1;
	else if(!(|cnt) & ((state==slave_addr_ack) | (state==slave_memaddr_ack) | (next_state==slave_addr_ack) | (next_state==slave_memaddr_ack))) begin 				
			ld <= 1'b1;
	end
	else      	ld <= 1'b0;
end

//counter logic
always@(posedge scl)begin
	if(ld)	cnt <= 3'b111;
	else 	cnt <= cnt - 1;
end


//state machine
always@(negedge scl)begin
	if(start)	state <= get_slave_addr;
	else if (!(|cnt)) begin
			if(state == get_slave_addr) 	state <= slave_addr_ack;
			else if(state == slave_addr_ack)state <= get_mem_addr;
			else if(state == get_mem_addr)	state <= slave_memaddr_ack;
			else if(state == slave_memaddr_ack)state <= get_mem_data;
			else if(state == get_mem_data)	state <= slave_memdata_ack;
	end
end

//serial register logic
always@(posedge scl)begin
	if(!state[0])	sr  <= {sr[6:0],sda};
end

//data capture register
always@(posedge scl)begin
	if(state[0])	data_capture_reg  <= sr;
end

//next state logic
assign next_state = 	(state == get_slave_addr)    ? slave_addr_ack    :
			(state == slave_addr_ack)    ? get_mem_addr      :
			(state == get_mem_addr)	     ? slave_memaddr_ack :
			(state == slave_memaddr_ack) ? get_mem_data      :
  			(state == get_mem_data)	     ? slave_memdata_ack : get_slave_addr ;

endmodule



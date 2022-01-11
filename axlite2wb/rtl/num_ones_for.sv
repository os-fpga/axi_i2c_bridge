`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/04/2022 05:04:26 PM
// Design Name: 
// Module Name: num_ones_for
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module num_ones_for 
#(  parameter WIDTH=4,
    localparam COUNTER_SIZE = `CLOG2(WIDTH)
    )(
    input wire [WIDTH-1:0] A,
    output reg [COUNTER_SIZE:0] ones
    );

integer i;

    always@(A)
    begin
        ones = 0;  //initialize count variable.
        for(i=0;i<WIDTH;i=i+1)   //check for all the bits.
            if(A[i] == 1'b1)    //check if the bit is '1'
                ones = ones + 1;    //if its one, increment the count.
    end

endmodule

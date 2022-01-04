`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: RapidSilicon
// Engineer: Arshad Aleem
// 
// Create Date: 12/28/2021 11:38:50 AM
// Design Name: Parameterized Wishbone Data Bus Width feature
// Module Name: wb_width
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



module wb_width #(
    parameter   AXI_DATA_WIDTH =            32,
    parameter   WB_DATA_WIDTH =             8,
    // This design is only supporting 8 bit Granularity yet
    parameter   GRANULARITY   =             8,
    parameter   AXI_ADDR_WIDTH = 28,
    
    
    localparam ADDR_LOWER_LIMIT = $clog2(WB_DATA_WIDTH/GRANULARITY)
    
    )(
    
    input wire  [AXI_DATA_WIDTH-1:0]                  in_data,
    input wire  [AXI_DATA_WIDTH/8-1:0]                in_strb,
    output reg  [WB_DATA_WIDTH-1:0]                   out_data,
    // GRANULARITY = 8
    output reg  [WB_DATA_WIDTH/GRANULARITY-1:0]       out_strb,
    
    input wire  [AXI_ADDR_WIDTH-1:0]                  in_write_addr,
    output reg  [AXI_ADDR_WIDTH-ADDR_LOWER_LIMIT-1:0] out_write_addr,
    
    input wire  [AXI_ADDR_WIDTH-1:0]                  in_read_addr,
    output reg  [AXI_ADDR_WIDTH-ADDR_LOWER_LIMIT-1:0] out_read_addr
    );
    
    always @(in_write_addr,in_read_addr)
    begin
        out_write_addr = in_write_addr[AXI_ADDR_WIDTH-1:ADDR_LOWER_LIMIT];
        
        out_read_addr = in_read_addr[AXI_ADDR_WIDTH-1:ADDR_LOWER_LIMIT];
    end
    
    // 2 x 4 - 1 = 7 cases
    
    generate 
    if (AXI_DATA_WIDTH == 32) begin // 3 muxes: 8,16,24
        
        if (WB_DATA_WIDTH == 8) 
        begin
            reg [2:0] num_ones;
            integer i;
            // GRANULARITY is assumed 8
            // strobe would be 4 bits
            num_ones_for #(  .WIDTH(4)) 
            ones_counter ( .A(in_strb), .ones(num_ones) );
            
            always @(in_data,in_strb) 
            begin
                case(num_ones)
                // Only valid case is where only 1 strobe line is 1
                    3'd1 : 
                        for ( i=0 ; i<AXI_DATA_WIDTH/8 ; i = i+1 )
                        begin
                            if(in_strb[i] == 1) 
                            begin
                            // Assign valid data byte to output data byte;
                                out_data[0+:8] = in_data[i*8+:8];
                            end
                        end
                    default : out_data[0+:8] = in_data[0+:8];
                endcase
                out_strb = in_strb;
            end
        /* Case implementation, which is not scalable:
            always @(*) begin
                case(in_strb)
                    4'b0001 : out_data = in_data[7:0]; 
                    4'b0010 : out_data = in_data[15:8];
                    4'b0100 : out_data = in_data[23:16];
                    4'b1000 : out_data = in_data[31:24];
                    default : out_data = in_data[7:0];
                endcase
                out_strb = 1'b1;
            end
            */
        end
        
//        else if (WB_DATA_WIDTH == 16) begin
//            /* 
//             * Combinational logic required. Blocking statements will be used.
//             */
//            always @(*) begin
//                case(in_strb)
//                   /*
//                    * This part caters the strobe cases where random 2 bytes 
//                    * contain the data. 
//                    */
//                    4'b0001 : begin out_data = {8'h00,in_data[ 7: 0]}; out_strb = 2'b01; end
//                    4'b0010 : begin out_data = {8'h00,in_data[15: 8]}; out_strb = 2'b01; end
//                    4'b0100 : begin out_data = {8'h00,in_data[23:16]}; out_strb = 2'b01; end
//                    4'b1000 : begin out_data = {8'h00,in_data[31:24]}; out_strb = 2'b01; end
                    
//                    /*
//                     * This part caters the strobe cases where random 2 bytes 
//                     * contain the data. 
//                     */
//                    4'b0011 : begin out_data = {in_data[15: 8],in_data[ 7: 0]}; out_strb = 2'b11; end
//                    4'b0101 : begin out_data = {in_data[23:16],in_data[ 7: 0]}; out_strb = 2'b11; end
//                    4'b0110 : begin out_data = {in_data[23:16],in_data[15: 8]}; out_strb = 2'b11; end
//                    4'b1001 : begin out_data = {in_data[31:24],in_data[ 7: 0]}; out_strb = 2'b11; end
//                    4'b1010 : begin out_data = {in_data[31:24],in_data[15: 8]}; out_strb = 2'b11; end
//                    4'b1100 : begin out_data = {in_data[31:24],in_data[23:16]}; out_strb = 2'b11; end
                    
//                    /*
//                     * If any other combination of strobes is sent from
//                     * master, that is faulty for 16 bits Wishbone.
//                     * that's why connect lowest 2 bytes of in_data to out.
//                     */
//                    default : begin out_data = {in_data[15: 8],in_data[ 7: 0]}; out_strb = 2'b11; end
                    
//                endcase
//            end                                         
//        end
        
        /*
         * If data width of both Wishbone and AXI is same, then no alteration is required
         */
        else if (WB_DATA_WIDTH == 32) begin
            always @(in_data,in_strb) begin
                out_data = in_data;
                out_strb = in_strb;
            end
        end
    end
    else if (AXI_DATA_WIDTH == 64) begin // 4 muxes: 8,16,24,32
    
//        if (WB_DATA_WIDTH == 8) begin
//            always @(*) begin
//                case(in_strb)
//                   /*
//                    * This part caters the strobe cases where random 2 bytes 
//                    * contain the data. 
//                    */
//                    8'b00000001 : out_data = in_data[ 7: 0];
//                    8'b00000010 : out_data = in_data[15: 8]; 
//                    8'b00000100 : out_data = in_data[23:16]; 
//                    8'b00001000 : out_data = in_data[31:24];
//                    8'b00010000 : out_data = in_data[39:32];
//                    8'b00100000 : out_data = in_data[47:40];
//                    8'b01000000 : out_data = in_data[55:48];
//                    8'b10000000 : out_data = in_data[63:56];
//                    default     : out_data = in_data[ 7: 0]; 
//                endcase
//                out_strb = 1'b1;
//            end
//        end
//        else if (WB_DATA_WIDTH == 16) begin // 76 LUTs
//            /* 
//             * Combinational logic required. Blocking statements will be used.
//             */
//            always @(*) begin
//                case(in_strb)
//                   /*
//                    * This part caters the strobe cases where random 2 bytes 
//                    * contain the data. 
//                    */
//                    8'b00000001 : begin out_data = {8'h00,in_data[ 7: 0]}; out_strb = 2'b01; end
//                    8'b00000010 : begin out_data = {8'h00,in_data[15: 8]}; out_strb = 2'b01; end
//                    8'b00000100 : begin out_data = {8'h00,in_data[23:16]}; out_strb = 2'b01; end
//                    8'b00001000 : begin out_data = {8'h00,in_data[31:24]}; out_strb = 2'b01; end
//                    8'b00010000 : begin out_data = {8'h00,in_data[39:32]}; out_strb = 2'b01; end
//                    8'b00100000 : begin out_data = {8'h00,in_data[47:40]}; out_strb = 2'b01; end
//                    8'b01000000 : begin out_data = {8'h00,in_data[55:48]}; out_strb = 2'b01; end
//                    8'b10000000 : begin out_data = {8'h00,in_data[63:56]}; out_strb = 2'b01; end
//                    /*
//                     * This part caters the strobe cases where random 2 bytes 
//                     * contain the data. 
//                     * (8C2 = 28) 28 combinations in 8 bits strobe will be having 2 bits as 1
//                     */
//                    8'b00000011 : begin out_data = {in_data[15: 8],in_data[ 7: 0]}; out_strb = 2'b11; end
//                    8'b00000101 : begin out_data = {in_data[23:16],in_data[ 7: 0]}; out_strb = 2'b11; end
//                    8'b00000110 : begin out_data = {in_data[23:16],in_data[15: 8]}; out_strb = 2'b11; end
//                    8'b00001001 : begin out_data = {in_data[31:24],in_data[ 7: 0]}; out_strb = 2'b11; end
//                    8'b00001010 : begin out_data = {in_data[31:24],in_data[15: 8]}; out_strb = 2'b11; end
//                    8'b00001100 : begin out_data = {in_data[31:24],in_data[23:16]}; out_strb = 2'b11; end
//                    8'b00010001 : begin out_data = {in_data[39:32],in_data[ 7: 0]}; out_strb = 2'b11; end
//                    8'b00010010 : begin out_data = {in_data[39:32],in_data[15: 8]}; out_strb = 2'b11; end
//                    8'b00010100 : begin out_data = {in_data[39:32],in_data[23:16]}; out_strb = 2'b11; end
//                    8'b00011000 : begin out_data = {in_data[39:32],in_data[31:24]}; out_strb = 2'b11; end
//                    8'b00100001 : begin out_data = {in_data[47:40],in_data[ 7: 0]}; out_strb = 2'b11; end
//                    8'b00100010 : begin out_data = {in_data[47:40],in_data[15: 8]}; out_strb = 2'b11; end
//                    8'b00100100 : begin out_data = {in_data[47:40],in_data[23:16]}; out_strb = 2'b11; end
//                    8'b00101000 : begin out_data = {in_data[47:40],in_data[31:24]}; out_strb = 2'b11; end
//                    8'b00110000 : begin out_data = {in_data[47:40],in_data[39:32]}; out_strb = 2'b11; end
//                    8'b01000001 : begin out_data = {in_data[55:48],in_data[ 7: 0]}; out_strb = 2'b11; end
//                    8'b01000010 : begin out_data = {in_data[55:48],in_data[15: 8]}; out_strb = 2'b11; end
//                    8'b01000100 : begin out_data = {in_data[55:48],in_data[23:16]}; out_strb = 2'b11; end
//                    8'b01001000 : begin out_data = {in_data[55:48],in_data[31:24]}; out_strb = 2'b11; end
//                    8'b01010000 : begin out_data = {in_data[55:48],in_data[39:32]}; out_strb = 2'b11; end
//                    8'b01100000 : begin out_data = {in_data[55:48],in_data[47:40]}; out_strb = 2'b11; end
//                    8'b10000001 : begin out_data = {in_data[63:56],in_data[ 7: 0]}; out_strb = 2'b11; end
//                    8'b10000010 : begin out_data = {in_data[63:56],in_data[15: 8]}; out_strb = 2'b11; end
//                    8'b10000100 : begin out_data = {in_data[63:56],in_data[23:16]}; out_strb = 2'b11; end
//                    8'b10001000 : begin out_data = {in_data[63:56],in_data[31:24]}; out_strb = 2'b11; end
//                    8'b10010000 : begin out_data = {in_data[63:56],in_data[39:32]}; out_strb = 2'b11; end
//                    8'b10100000 : begin out_data = {in_data[63:56],in_data[47:40]}; out_strb = 2'b11; end
//                    8'b11000000 : begin out_data = {in_data[63:56],in_data[55:48]}; out_strb = 2'b11; end

//                    /*
//                     * If any other combination of strobes is sent from
//                     * master, that is faulty for 16 bits Wishbone.
//                     * that's why connect lowest 2 bytes of in_data to out.
//                     */
//                    default : begin out_data = {in_data[15: 8],in_data[ 7: 0]}; out_strb = 2'b11; end
                    
//                endcase
//            end
//        end
//        else if (WB_DATA_WIDTH == 32) begin //869 LUTs
//            /* 
//             * Combinational logic required. Blocking statements will be used.
//             */
//            always @(*) begin
//                case(in_strb)
//                   /*
//                    * This part caters the strobe cases where random 2 bytes 
//                    * contain the data. 
//                    */
//                    8'b00000001 : begin out_data = {24'h000000,in_data[ 7: 0]}; out_strb = 4'b0001; end
//                    8'b00000010 : begin out_data = {24'h000000,in_data[15: 8]}; out_strb = 4'b0001; end
//                    8'b00000100 : begin out_data = {24'h000000,in_data[23:16]}; out_strb = 4'b0001; end
//                    8'b00001000 : begin out_data = {24'h000000,in_data[31:24]}; out_strb = 4'b0001; end
//                    8'b00010000 : begin out_data = {24'h000000,in_data[39:32]}; out_strb = 4'b0001; end
//                    8'b00100000 : begin out_data = {24'h000000,in_data[47:40]}; out_strb = 4'b0001; end
//                    8'b01000000 : begin out_data = {24'h000000,in_data[55:48]}; out_strb = 4'b0001; end
//                    8'b10000000 : begin out_data = {24'h000000,in_data[63:56]}; out_strb = 4'b0001; end
//                    /*
//                     * This part caters the strobe cases where random 2 bytes 
//                     * contain the data. 
//                     * 8C2 = 28
//                     */
//                    8'b00000011 : begin out_data = {16'h0000,in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b0011; end
//                    8'b00000101 : begin out_data = {16'h0000,in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b0011; end
//                    8'b00000110 : begin out_data = {16'h0000,in_data[23:16],in_data[15: 8]}; out_strb = 4'b0011; end
//                    8'b00001001 : begin out_data = {16'h0000,in_data[31:24],in_data[ 7: 0]}; out_strb = 4'b0011; end
//                    8'b00001010 : begin out_data = {16'h0000,in_data[31:24],in_data[15: 8]}; out_strb = 4'b0011; end
//                    8'b00001100 : begin out_data = {16'h0000,in_data[31:24],in_data[23:16]}; out_strb = 4'b0011; end
//                    8'b00010001 : begin out_data = {16'h0000,in_data[39:32],in_data[ 7: 0]}; out_strb = 4'b0011; end
//                    8'b00010010 : begin out_data = {16'h0000,in_data[39:32],in_data[15: 8]}; out_strb = 4'b0011; end
//                    8'b00010100 : begin out_data = {16'h0000,in_data[39:32],in_data[23:16]}; out_strb = 4'b0011; end
//                    8'b00011000 : begin out_data = {16'h0000,in_data[39:32],in_data[31:24]}; out_strb = 4'b0011; end
//                    8'b00100001 : begin out_data = {16'h0000,in_data[47:40],in_data[ 7: 0]}; out_strb = 4'b0011; end
//                    8'b00100010 : begin out_data = {16'h0000,in_data[47:40],in_data[15: 8]}; out_strb = 4'b0011; end
//                    8'b00100100 : begin out_data = {16'h0000,in_data[47:40],in_data[23:16]}; out_strb = 4'b0011; end
//                    8'b00101000 : begin out_data = {16'h0000,in_data[47:40],in_data[31:24]}; out_strb = 4'b0011; end
//                    8'b00110000 : begin out_data = {16'h0000,in_data[47:40],in_data[39:32]}; out_strb = 4'b0011; end
//                    8'b01000001 : begin out_data = {16'h0000,in_data[55:48],in_data[ 7: 0]}; out_strb = 4'b0011; end
//                    8'b01000010 : begin out_data = {16'h0000,in_data[55:48],in_data[15: 8]}; out_strb = 4'b0011; end
//                    8'b01000100 : begin out_data = {16'h0000,in_data[55:48],in_data[23:16]}; out_strb = 4'b0011; end
//                    8'b01001000 : begin out_data = {16'h0000,in_data[55:48],in_data[31:24]}; out_strb = 4'b0011; end
//                    8'b01010000 : begin out_data = {16'h0000,in_data[55:48],in_data[39:32]}; out_strb = 4'b0011; end
//                    8'b01100000 : begin out_data = {16'h0000,in_data[55:48],in_data[47:40]}; out_strb = 4'b0011; end
//                    8'b10000001 : begin out_data = {16'h0000,in_data[63:56],in_data[ 7: 0]}; out_strb = 4'b0011; end
//                    8'b10000010 : begin out_data = {16'h0000,in_data[63:56],in_data[15: 8]}; out_strb = 4'b0011; end
//                    8'b10000100 : begin out_data = {16'h0000,in_data[63:56],in_data[23:16]}; out_strb = 4'b0011; end
//                    8'b10001000 : begin out_data = {16'h0000,in_data[63:56],in_data[31:24]}; out_strb = 4'b0011; end
//                    8'b10010000 : begin out_data = {16'h0000,in_data[63:56],in_data[39:32]}; out_strb = 4'b0011; end
//                    8'b10100000 : begin out_data = {16'h0000,in_data[63:56],in_data[47:40]}; out_strb = 4'b0011; end
//                    8'b11000000 : begin out_data = {16'h0000,in_data[63:56],in_data[55:48]}; out_strb = 4'b0011; end
                    
//                    /*
//                     * 8C3 = 56
//                     */
                    
//                    8'b00000111 : begin out_data = {8'h00,in_data[23:16],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b00001011 : begin out_data = {8'h00,in_data[31:24],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b00001101 : begin out_data = {8'h00,in_data[31:24],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b00001110 : begin out_data = {8'h00,in_data[31:24],in_data[23:16],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b00010011 : begin out_data = {8'h00,in_data[39:32],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b00010101 : begin out_data = {8'h00,in_data[39:32],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b00010110 : begin out_data = {8'h00,in_data[39:32],in_data[23:16],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b00011001 : begin out_data = {8'h00,in_data[39:32],in_data[31:24],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b00011010 : begin out_data = {8'h00,in_data[39:32],in_data[31:24],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b00011100 : begin out_data = {8'h00,in_data[39:32],in_data[31:24],in_data[23:16]}; out_strb = 4'b0111; end
//                    8'b00100011 : begin out_data = {8'h00,in_data[47:40],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b00100101 : begin out_data = {8'h00,in_data[47:40],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b00100110 : begin out_data = {8'h00,in_data[47:40],in_data[23:16],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b00101001 : begin out_data = {8'h00,in_data[47:40],in_data[31:24],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b00101010 : begin out_data = {8'h00,in_data[47:40],in_data[31:24],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b00101100 : begin out_data = {8'h00,in_data[47:40],in_data[31:24],in_data[23:16]}; out_strb = 4'b0111; end
//                    8'b00110001 : begin out_data = {8'h00,in_data[47:40],in_data[39:32],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b00110010 : begin out_data = {8'h00,in_data[47:40],in_data[39:32],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b00110100 : begin out_data = {8'h00,in_data[47:40],in_data[39:32],in_data[23:16]}; out_strb = 4'b0111; end
//                    8'b00111000 : begin out_data = {8'h00,in_data[47:40],in_data[39:32],in_data[31:24]}; out_strb = 4'b0111; end
//                    8'b01000011 : begin out_data = {8'h00,in_data[55:48],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b01000101 : begin out_data = {8'h00,in_data[55:48],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b01000110 : begin out_data = {8'h00,in_data[55:48],in_data[23:16],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b01001001 : begin out_data = {8'h00,in_data[55:48],in_data[31:24],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b01001010 : begin out_data = {8'h00,in_data[55:48],in_data[31:24],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b01001100 : begin out_data = {8'h00,in_data[55:48],in_data[31:24],in_data[23:16]}; out_strb = 4'b0111; end
//                    8'b01010001 : begin out_data = {8'h00,in_data[55:48],in_data[39:32],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b01010010 : begin out_data = {8'h00,in_data[55:48],in_data[39:32],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b01010100 : begin out_data = {8'h00,in_data[55:48],in_data[39:32],in_data[23:16]}; out_strb = 4'b0111; end
//                    8'b01011000 : begin out_data = {8'h00,in_data[55:48],in_data[39:32],in_data[31:24]}; out_strb = 4'b0111; end
//                    8'b01100001 : begin out_data = {8'h00,in_data[55:48],in_data[47:40],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b01100010 : begin out_data = {8'h00,in_data[55:48],in_data[47:40],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b01100100 : begin out_data = {8'h00,in_data[55:48],in_data[47:40],in_data[23:16]}; out_strb = 4'b0111; end
//                    8'b01101000 : begin out_data = {8'h00,in_data[55:48],in_data[47:40],in_data[31:24]}; out_strb = 4'b0111; end
//                    8'b01110000 : begin out_data = {8'h00,in_data[55:48],in_data[47:40],in_data[39:32]}; out_strb = 4'b0111; end
//                    8'b10000011 : begin out_data = {8'h00,in_data[63:56],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b10000101 : begin out_data = {8'h00,in_data[63:56],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b10000110 : begin out_data = {8'h00,in_data[63:56],in_data[23:16],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b10001001 : begin out_data = {8'h00,in_data[63:56],in_data[31:24],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b10001010 : begin out_data = {8'h00,in_data[63:56],in_data[31:24],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b10001100 : begin out_data = {8'h00,in_data[63:56],in_data[31:24],in_data[23:16]}; out_strb = 4'b0111; end
//                    8'b10010001 : begin out_data = {8'h00,in_data[63:56],in_data[39:32],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b10010010 : begin out_data = {8'h00,in_data[63:56],in_data[39:32],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b10010100 : begin out_data = {8'h00,in_data[63:56],in_data[39:32],in_data[23:16]}; out_strb = 4'b0111; end
//                    8'b10011000 : begin out_data = {8'h00,in_data[63:56],in_data[39:32],in_data[31:24]}; out_strb = 4'b0111; end
//                    8'b10100001 : begin out_data = {8'h00,in_data[63:56],in_data[47:40],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b10100010 : begin out_data = {8'h00,in_data[63:56],in_data[47:40],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b10100100 : begin out_data = {8'h00,in_data[63:56],in_data[47:40],in_data[23:16]}; out_strb = 4'b0111; end
//                    8'b10101000 : begin out_data = {8'h00,in_data[63:56],in_data[47:40],in_data[31:24]}; out_strb = 4'b0111; end
//                    8'b10110000 : begin out_data = {8'h00,in_data[63:56],in_data[47:40],in_data[39:32]}; out_strb = 4'b0111; end
//                    8'b11000001 : begin out_data = {8'h00,in_data[63:56],in_data[55:48],in_data[ 7: 0]}; out_strb = 4'b0111; end
//                    8'b11000010 : begin out_data = {8'h00,in_data[63:56],in_data[55:48],in_data[15: 8]}; out_strb = 4'b0111; end
//                    8'b11000100 : begin out_data = {8'h00,in_data[63:56],in_data[55:48],in_data[23:16]}; out_strb = 4'b0111; end
//                    8'b11001000 : begin out_data = {8'h00,in_data[63:56],in_data[55:48],in_data[31:24]}; out_strb = 4'b0111; end
//                    8'b11010000 : begin out_data = {8'h00,in_data[63:56],in_data[55:48],in_data[39:32]}; out_strb = 4'b0111; end
//                    8'b11100000 : begin out_data = {8'h00,in_data[63:56],in_data[55:48],in_data[47:40]}; out_strb = 4'b0111; end
                    
//                    /*
//                     * 8C4 = 70
//                     */
                     
//                    8'b00001111 : begin out_data = {in_data[31:24],in_data[23:16],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b00010111 : begin out_data = {in_data[39:32],in_data[23:16],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b00011011 : begin out_data = {in_data[39:32],in_data[31:24],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b00011101 : begin out_data = {in_data[39:32],in_data[31:24],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b00011110 : begin out_data = {in_data[39:32],in_data[31:24],in_data[23:16],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b00100111 : begin out_data = {in_data[47:40],in_data[23:16],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b00101011 : begin out_data = {in_data[47:40],in_data[31:24],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b00101101 : begin out_data = {in_data[47:40],in_data[31:24],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b00101110 : begin out_data = {in_data[47:40],in_data[31:24],in_data[23:16],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b00110011 : begin out_data = {in_data[47:40],in_data[39:32],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b00110101 : begin out_data = {in_data[47:40],in_data[39:32],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b00110110 : begin out_data = {in_data[47:40],in_data[39:32],in_data[23:16],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b00111001 : begin out_data = {in_data[47:40],in_data[39:32],in_data[31:24],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b00111010 : begin out_data = {in_data[47:40],in_data[39:32],in_data[31:24],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b00111100 : begin out_data = {in_data[47:40],in_data[39:32],in_data[31:24],in_data[23:16]}; out_strb = 4'b1111; end
//                    8'b01000111 : begin out_data = {in_data[55:48],in_data[23:16],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b01001011 : begin out_data = {in_data[55:48],in_data[31:24],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b01001101 : begin out_data = {in_data[55:48],in_data[31:24],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b01001110 : begin out_data = {in_data[55:48],in_data[31:24],in_data[23:16],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b01010011 : begin out_data = {in_data[55:48],in_data[39:32],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b01010101 : begin out_data = {in_data[55:48],in_data[39:32],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b01010110 : begin out_data = {in_data[55:48],in_data[39:32],in_data[23:16],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b01011001 : begin out_data = {in_data[55:48],in_data[39:32],in_data[31:24],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b01011010 : begin out_data = {in_data[55:48],in_data[39:32],in_data[31:24],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b01011100 : begin out_data = {in_data[55:48],in_data[39:32],in_data[31:24],in_data[23:16]}; out_strb = 4'b1111; end
//                    8'b01100011 : begin out_data = {in_data[55:48],in_data[47:40],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b01100101 : begin out_data = {in_data[55:48],in_data[47:40],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b01100110 : begin out_data = {in_data[55:48],in_data[47:40],in_data[23:16],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b01101001 : begin out_data = {in_data[55:48],in_data[47:40],in_data[31:24],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b01101010 : begin out_data = {in_data[55:48],in_data[47:40],in_data[31:24],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b01101100 : begin out_data = {in_data[55:48],in_data[47:40],in_data[31:24],in_data[23:16]}; out_strb = 4'b1111; end
//                    8'b01110001 : begin out_data = {in_data[55:48],in_data[47:40],in_data[39:32],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b01110010 : begin out_data = {in_data[55:48],in_data[47:40],in_data[39:32],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b01110100 : begin out_data = {in_data[55:48],in_data[47:40],in_data[39:32],in_data[23:16]}; out_strb = 4'b1111; end
//                    8'b01111000 : begin out_data = {in_data[55:48],in_data[47:40],in_data[39:32],in_data[31:24]}; out_strb = 4'b1111; end
//                    8'b10000111 : begin out_data = {in_data[63:56],in_data[23:16],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b10001011 : begin out_data = {in_data[63:56],in_data[31:24],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b10001101 : begin out_data = {in_data[63:56],in_data[31:24],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b10001110 : begin out_data = {in_data[63:56],in_data[31:24],in_data[23:16],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b10010011 : begin out_data = {in_data[63:56],in_data[39:32],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b10010101 : begin out_data = {in_data[63:56],in_data[39:32],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b10010110 : begin out_data = {in_data[63:56],in_data[39:32],in_data[23:16],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b10011001 : begin out_data = {in_data[63:56],in_data[39:32],in_data[31:24],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b10011010 : begin out_data = {in_data[63:56],in_data[39:32],in_data[31:24],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b10011100 : begin out_data = {in_data[63:56],in_data[39:32],in_data[31:24],in_data[23:16]}; out_strb = 4'b1111; end
//                    8'b10100011 : begin out_data = {in_data[63:56],in_data[47:40],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b10100101 : begin out_data = {in_data[63:56],in_data[47:40],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b10100110 : begin out_data = {in_data[63:56],in_data[47:40],in_data[23:16],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b10101001 : begin out_data = {in_data[63:56],in_data[47:40],in_data[31:24],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b10101010 : begin out_data = {in_data[63:56],in_data[47:40],in_data[31:24],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b10101100 : begin out_data = {in_data[63:56],in_data[47:40],in_data[31:24],in_data[23:16]}; out_strb = 4'b1111; end
//                    8'b10110001 : begin out_data = {in_data[63:56],in_data[47:40],in_data[39:32],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b10110010 : begin out_data = {in_data[63:56],in_data[47:40],in_data[39:32],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b10110100 : begin out_data = {in_data[63:56],in_data[47:40],in_data[39:32],in_data[23:16]}; out_strb = 4'b1111; end
//                    8'b10111000 : begin out_data = {in_data[63:56],in_data[47:40],in_data[39:32],in_data[31:24]}; out_strb = 4'b1111; end
//                    8'b11000011 : begin out_data = {in_data[63:56],in_data[55:48],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b11000101 : begin out_data = {in_data[63:56],in_data[55:48],in_data[23:16],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b11000110 : begin out_data = {in_data[63:56],in_data[55:48],in_data[23:16],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b11001001 : begin out_data = {in_data[63:56],in_data[55:48],in_data[31:24],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b11001010 : begin out_data = {in_data[63:56],in_data[55:48],in_data[31:24],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b11001100 : begin out_data = {in_data[63:56],in_data[55:48],in_data[31:24],in_data[23:16]}; out_strb = 4'b1111; end
//                    8'b11010001 : begin out_data = {in_data[63:56],in_data[55:48],in_data[39:32],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b11010010 : begin out_data = {in_data[63:56],in_data[55:48],in_data[39:32],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b11010100 : begin out_data = {in_data[63:56],in_data[55:48],in_data[39:32],in_data[23:16]}; out_strb = 4'b1111; end
//                    8'b11011000 : begin out_data = {in_data[63:56],in_data[55:48],in_data[39:32],in_data[31:24]}; out_strb = 4'b1111; end
//                    8'b11100001 : begin out_data = {in_data[63:56],in_data[55:48],in_data[47:40],in_data[ 7: 0]}; out_strb = 4'b1111; end
//                    8'b11100010 : begin out_data = {in_data[63:56],in_data[55:48],in_data[47:40],in_data[15: 8]}; out_strb = 4'b1111; end
//                    8'b11100100 : begin out_data = {in_data[63:56],in_data[55:48],in_data[47:40],in_data[23:16]}; out_strb = 4'b1111; end
//                    8'b11101000 : begin out_data = {in_data[63:56],in_data[55:48],in_data[47:40],in_data[31:24]}; out_strb = 4'b1111; end
//                    8'b11110000 : begin out_data = {in_data[63:56],in_data[55:48],in_data[47:40],in_data[39:32]}; out_strb = 4'b1111; end
//                    /*
//                     * If any other combination of strobes is sent from
//                     * master, that is faulty for 16 bits Wishbone.
//                     * that's why connect lowest 2 bytes of in_data to out.
//                     */
//                    default : begin out_data = {in_data[31:24],in_data[23:16],in_data[15: 8],in_data[ 7: 0]}; out_strb = 4'b1111; end
                    
//                endcase
//            end
//        end
        if (WB_DATA_WIDTH == 64) begin
            always @(in_data,in_strb) begin
                out_data = in_data;
                out_strb = in_strb;
            end
            
        end
    end
    endgenerate
    
endmodule

module num_ones_for 
#(  parameter WIDTH=4,
    localparam COUNTER_SIZE = $clog2(WIDTH)
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
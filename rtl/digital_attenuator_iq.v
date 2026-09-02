`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/09/01 13:56:44
// Design Name: 
// Module Name: digital_attenuator
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


module digital_attenuator_iq (
    input  wire               clk,
    input  wire               rst_n,

    input  wire signed [15:0] din_i,
    input  wire signed [15:0] din_q,
    input  wire signed [15:0] atten,   // Q1.14: 0x4000 = 1.0 (0 dB), 0x2000 = 0.5 (-6 dB)
    input  wire               din_valid,

    output reg  signed [15:0] dout_i,
    output reg  signed [15:0] dout_q,
    output reg                dout_valid
);

    // 16x16 signed multiply -> full 32-bit products
    wire signed [31:0] prod_i = din_i * atten;
    wire signed [31:0] prod_q = din_q * atten;

    always @(posedge clk) begin
        if (!rst_n) begin
            dout_i     <= 16'sd0;
            dout_q     <= 16'sd0;
            dout_valid <= 1'b0;
        end
        else begin
            // Q1.14: drop the 14 fractional bits (arithmetic shift), keep 16-bit results
            dout_i     <= prod_i >>> 14;
            dout_q     <= prod_q >>> 14;
            dout_valid <= din_valid;
        end
    end

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/09/01 12:56:44
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


module digital_attenuator (
    input  wire               clk,
    input  wire               rst_n,

    input  wire signed [15:0] din,
    input  wire signed [15:0] atten,   // Q1.14: 0x4000 = 1.0 (0 dB), 0x2000 = 0.5 (-6 dB)
    input  wire               din_valid,

    output reg  signed [15:0] dout,
    output reg                dout_valid
);

    // 16x16 signed multiply -> full 32-bit product
    wire signed [31:0] prod = din * atten;

    always @(posedge clk) begin
        if (!rst_n) begin
            dout       <= 16'sd0;
            dout_valid <= 1'b0;
        end
        else begin
            // Q1.14: drop the 14 fractional bits (arithmetic shift), keep 16-bit result
            dout       <= prod >>> 14;
            dout_valid <= din_valid;
        end
    end

endmodule
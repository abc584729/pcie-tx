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
    input  wire        [3:0]  shift,
    input  wire               din_valid,

    output reg  signed [15:0] dout,
    output reg                dout_valid
);

    always @(posedge clk) begin
        if (!rst_n) begin
            dout       <= 16'sd0;
            dout_valid <= 1'b0;
        end
        else begin
            dout       <= din >>> shift;
            dout_valid <= din_valid;
        end
    end

endmodule
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
    input  wire        [3:0]  shift,
    input  wire               din_valid,

    output reg  signed [15:0] dout_i,
    output reg  signed [15:0] dout_q,
    output reg                dout_valid
);

    always @(posedge clk) begin
        if (!rst_n) begin
            dout_i     <= 16'sd0;
            dout_q     <= 16'sd0;
            dout_valid <= 1'b0;
        end
        else begin
            dout_i     <= din_i >>> shift;
            dout_q     <= din_q >>> shift;
            dout_valid <= din_valid;
        end
    end

endmodule
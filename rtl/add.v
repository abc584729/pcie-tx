`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2026/08/29 18:20:00
// Design Name:
// Module Name: add
// Project Name:
// Target Devices:
// Tool Versions:
// Description: channel-wise sum of two 8-lane (8 x 16-bit) I/Q signal pairs.
//              16 + 16 -> 17 bit, LSB discarded -> 16 bit (sum[16:1]).
//              clk/rst_n reserved for interface uniformity, not used.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module add(
    input clk, rst_n,
    input  signed [127:0] i0, q0,
    input  signed [127:0] i1, q1,
    output signed [127:0] iout, qout
);

    genvar k;
    generate
        for (k = 0; k < 8; k = k + 1) begin : g_add
            wire signed [16:0] sum_i = i0[16*k +: 16] + i1[16*k +: 16];
            wire signed [16:0] sum_q = q0[16*k +: 16] + q1[16*k +: 16];
            assign iout[16*k +: 16] = sum_i[16:1];
            assign qout[16*k +: 16] = sum_q[16:1];
        end
    endgenerate

endmodule

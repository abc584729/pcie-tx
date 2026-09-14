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
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module add(
    input clk, rst_n,
    input rate_sel,                 // 0 = 450k / 4.5M rates, 1 = 400k / 6.667M rates
    input  signed [127:0] i0, q0,
    input  signed [127:0] i1, q1,
    output [255:0] iq
);

    // per-lane I/Q sums, kept internal
    wire signed [127:0] iout, qout;

    genvar k;
    generate
        for (k = 0; k < 8; k = k + 1) begin : g_add
            wire signed [16:0] sum_i = $signed(i0[16*k +: 16]) + $signed(i1[16*k +: 16]);
            wire signed [16:0] sum_q = $signed(q0[16*k +: 16]) + $signed(q1[16*k +: 16]);
            assign iout[16*k +: 16] = rate_sel ? sum_i[15:0] : {sum_i[14:0], 1'b0};
            assign qout[16*k +: 16] = rate_sel ? sum_q[15:0] : {sum_q[14:0], 1'b0};
        end
    endgenerate

    // RFDC-style 256-bit IQ bus: {q7, i7, q6, i6, ..., q1, i1, q0, i0}, 16 bit per lane
    assign iq = {qout[127:112], iout[127:112],
                 qout[111:96],  iout[111:96],
                 qout[95:80],   iout[95:80],
                 qout[79:64],   iout[79:64],
                 qout[63:48],   iout[63:48],
                 qout[47:32],   iout[47:32],
                 qout[31:16],   iout[31:16],
                 qout[15:0],    iout[15:0]};

endmodule

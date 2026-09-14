`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2026/09/14 15:10:00
// Design Name:
// Module Name: upsamping_4500k
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


module upsamping_4500k(
        input clk, rst_n,
        input [15:0] din_i,
        input [15:0] din_q,
        input din_valid,
        output [127:0] sig_i,
        output [127:0] sig_q
    );

    wire reset = ~rst_n;

    // 8x zero insertion (40 clk -> 5 clk), I/Q lanes
    wire [15:0] pad_i8, pad_q8;
    wire pad_8_valid;
    zero_interpolator #(.TIME_FACTOR(40), .INTERPOLATION_FACTOR(8)) u_zero_padding_8_i(
        .clk(clk), .rst_n(rst_n),
        .x(din_i), .x_valid(din_valid),
        .y(pad_i8), .y_valid(pad_8_valid)
    );
    zero_interpolator #(.TIME_FACTOR(40), .INTERPOLATION_FACTOR(8)) u_zero_padding_8_q(
        .clk(clk), .rst_n(rst_n),
        .x(din_q), .x_valid(din_valid),
        .y(pad_q8), .y_valid()   // same slot phase as the I lane, left open
    );

    // RCOS shaping (En14), I/Q
    wire [15:0] rcos_i, rcos_q;
    wire rcos_valid;
    rcos_filter_iq u_rcos(
        .clk              (clk),
        .clk_enable       (pad_8_valid),
        .reset            (reset),
        .filter_in_i      (pad_i8),
        .filter_in_q      (pad_q8),
        .filter_out_i     (rcos_i),
        .filter_out_q     (rcos_q),
        .filter_out_valid (rcos_valid)
    );

    // 5x zero insertion (5 clk -> 1 clk), I/Q lanes
    wire [15:0] pad_i5, pad_q5;
    wire pad_5_valid;
    zero_interpolator #(.TIME_FACTOR(5), .INTERPOLATION_FACTOR(5)) u_zero_padding_5_i(
        .clk(clk), .rst_n(rst_n),
        .x(rcos_i), .x_valid(rcos_valid),
        .y(pad_i5), .y_valid(pad_5_valid)
    );
    zero_interpolator #(.TIME_FACTOR(5), .INTERPOLATION_FACTOR(5)) u_zero_padding_5_q(
        .clk(clk), .rst_n(rst_n),
        .x(rcos_q), .x_valid(rcos_valid),
        .y(pad_q5), .y_valid()   // slot every clk, left open
    );

    // 5x anti-imaging (En14), I/Q
    wire [15:0] s_i5, s_q5;
    wire s5_valid;
    anti_imaging_filter_5_iq u_f5(
        .clk              (clk),
        .clk_enable       (pad_5_valid),
        .reset            (reset),
        .filter_in_i      (pad_i5),
        .filter_in_q      (pad_q5),
        .filter_out_i     (s_i5),
        .filter_out_q     (s_q5),
        .filter_out_valid (s5_valid)
    );

    // 8x polyphase parallel anti-imaging -> 8 samples/clk, I/Q
    anti_imaging_filter_8_par_iq u_f8(
        .clk        (clk),
        .clk_enable (s5_valid),
        .reset      (reset),
        .filter_in_i(s_i5),
        .filter_in_q(s_q5),
        .filter_out_i(sig_i),
        .filter_out_q(sig_q),
        .ce_out     ()
    );

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2026/09/14 15:10:00
// Design Name:
// Module Name: upsamping_6667k
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


module upsamping_6667k(
        input clk, rst_n,
        input [15:0] din_i,
        input [15:0] din_q,
        input din_valid,
        output [127:0] sig_i,
        output [127:0] sig_q
    );

    wire reset = ~rst_n;

    // 9x zero insertion: one output every 27/9 = 3 clk, I/Q lanes
    wire [15:0] pad_i9, pad_q9;
    wire pad_9_valid;
    zero_interpolator #(.TIME_FACTOR(27), .INTERPOLATION_FACTOR(9)) u_zero_padding_9_i(
        .clk(clk), .rst_n(rst_n),
        .x(din_i), .x_valid(din_valid),
        .y(pad_i9), .y_valid(pad_9_valid)
    );
    zero_interpolator #(.TIME_FACTOR(27), .INTERPOLATION_FACTOR(9)) u_zero_padding_9_q(
        .clk(clk), .rst_n(rst_n),
        .x(din_q), .x_valid(din_valid),
        .y(pad_q9), .y_valid()   // same slot phase as the I lane, left open
    );

    // RCOS shaping, I/Q -- rcos_400k reused unchanged
    wire [15:0] rcos_i, rcos_q;
    wire rcos_valid;
    rcos_400k u_rcos_i(
        .clk              (clk),
        .clk_enable       (pad_9_valid),
        .reset            (reset),
        .filter_in        (pad_i9),
        .filter_out       (rcos_i),
        .filter_out_valid (rcos_valid)
    );
    rcos_400k u_rcos_q(
        .clk              (clk),
        .clk_enable       (pad_9_valid),
        .reset            (reset),
        .filter_in        (pad_q9),
        .filter_out       (rcos_q),
        .filter_out_valid ()
    );

    // 3x zero insertion: one output every clk, I/Q lanes
    wire [15:0] pad_i3, pad_q3;
    wire pad_3_valid;
    zero_interpolator #(.TIME_FACTOR(3), .INTERPOLATION_FACTOR(3)) u_zero_padding_3_i(
        .clk(clk), .rst_n(rst_n),
        .x(rcos_i), .x_valid(rcos_valid),
        .y(pad_i3), .y_valid(pad_3_valid)
    );
    zero_interpolator #(.TIME_FACTOR(3), .INTERPOLATION_FACTOR(3)) u_zero_padding_3_q(
        .clk(clk), .rst_n(rst_n),
        .x(rcos_q), .x_valid(rcos_valid),
        .y(pad_q3), .y_valid()   // slot every clk, left open
    );

    // 3x anti-imaging, I/Q
    wire [15:0] s_i3, s_q3;
    wire s3_valid;
    anti_imaging_3_6667k u_f3_i(
        .clk              (clk),
        .clk_enable       (pad_3_valid),
        .reset            (reset),
        .filter_in        (pad_i3),
        .filter_out       (s_i3),
        .filter_out_valid (s3_valid)
    );
    anti_imaging_3_6667k u_f3_q(
        .clk              (clk),
        .clk_enable       (pad_3_valid),
        .reset            (reset),
        .filter_in        (pad_q3),
        .filter_out       (s_q3),
        .filter_out_valid ()
    );

    // 8x polyphase parallel anti-imaging -> 8 samples/clk, I/Q
    anti_imaging_8_par_6667k u_f8_i(
        .clk        (clk),
        .clk_enable (s3_valid),
        .reset      (reset),
        .filter_in  (s_i3),
        .filter_out (sig_i),
        .ce_out     ()
    );
    anti_imaging_8_par_6667k u_f8_q(
        .clk        (clk),
        .clk_enable (s3_valid),
        .reset      (reset),
        .filter_in  (s_q3),
        .filter_out (sig_q),
        .ce_out     ()
    );

endmodule

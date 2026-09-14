`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2026/09/14 14:03:44
// Design Name:
// Module Name: upsamping_400k
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


module upsamping_400k(
        input clk, rst_n,
        input [15:0] din,
        input din_valid,
        output [127:0] sig
    );

    wire reset = ~rst_n;

    // 9x zero insert: 450 clk per symbol -> one output every 450/9 = 50 clk
    wire [15:0] pad_9;
    wire  pad_9_valid;
    zero_interpolator #(.TIME_FACTOR(450), .INTERPOLATION_FACTOR(9)) u_zero_padding_9(
        .clk           (clk),
        .rst_n         (rst_n),
        .x             (din),
        .x_valid       (din_valid),
        .y             (pad_9),
        .y_valid       (pad_9_valid)
    );

    wire [15:0] rcos_sig;
    wire rcos_valid;
    rcos_400k u_rcos_filter(
        .clk          (clk),
        .clk_enable   (pad_9_valid),
        .reset        (reset),
        .filter_in    (pad_9),
        .filter_out   (rcos_sig),
        .filter_out_valid (rcos_valid)
    );

    // 5x zero insert: one output every 50/5 = 10 clk
    wire [15:0] pad_5;
    wire  pad_5_valid;
    zero_interpolator #(.TIME_FACTOR(50), .INTERPOLATION_FACTOR(5)) u_zero_padding_5(
        .clk           (clk),
        .rst_n         (rst_n),
        .x             (rcos_sig),
        .x_valid       (rcos_valid),
        .y             (pad_5),
        .y_valid       (pad_5_valid)
    );

    wire [15:0] s5;
    wire s5_valid;
    anti_imaging_5_400k u_f5(
        .clk          (clk),
        .clk_enable   (pad_5_valid),
        .reset        (reset),
        .filter_in    (pad_5),
        .filter_out   (s5),
        .filter_out_valid (s5_valid)
    );

    // 10x zero insert: one output every 10/10 = 1 clk
    wire [15:0] pad_10;
    wire  pad_10_valid;
    zero_interpolator #(.TIME_FACTOR(10), .INTERPOLATION_FACTOR(10)) u_zero_padding_10(
        .clk           (clk),
        .rst_n         (rst_n),
        .x             (s5),
        .x_valid       (s5_valid),
        .y             (pad_10),
        .y_valid       (pad_10_valid)
    );

    wire [15:0] s10;
    wire s10_valid;
    anti_imaging_10_400k u_f10(
        .clk          (clk),
        .clk_enable   (pad_10_valid),
        .reset        (reset),
        .filter_in    (pad_10),
        .filter_out   (s10),
        .filter_out_valid (s10_valid)
    );

    anti_imaging_8_par_400k u_f8(
        .clk          (clk),
        .clk_enable   (s10_valid),
        .reset        (reset),
        .filter_in    (s10),
        .filter_out   (sig),
        .ce_out       ()
    );

endmodule

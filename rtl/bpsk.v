`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/27 14:19:44
// Design Name: 
// Module Name: bpsk
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   BPSK TX chain: symbol RAM -> mapper -> 8x zero-pad -> rcos shaping
//   -> 5x zero-pad -> anti_imaging_filter_5 -> 10x zero-pad
//   -> anti_imaging_filter_10 -> 8-phase parallel anti_imaging_filter_8_par.
//   sig[127:0] = 8 phases x sfix16_En15, valid every clock (ce_out from
//   anti_imaging_filter_8_par is the output-group valid).
//   Note: intermediate data alignment (FIR pipeline latency) is not yet
//   compensated; waveform is a fixed-delay version of the MATLAB chain.
// 
// Dependencies: bpsk_ram, dpram, bpsk_mapper, zero_interpolator,
//   rcos_filter, anti_imaging_filter_5/10, anti_imaging_filter_8_par
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bpsk(
        input clk, rst_n, en,
        output [127:0] sig
    );

    wire reset = ~rst_n;

    wire bit, bit_valid;
    bpsk_ram u_bpsk_ram(
        .clk           (clk),
        .rst_n         (rst_n),
        .w_en          (1'b0),
        .w_addr        (5'd0),
        .w_data        (16'd0),
        .rd_en         (en),
        .rdata         (bit),
        .rdata_valid   (bit_valid)
    );


    wire [15:0] pulse;
    wire  pulse_valid;
    bpsk_mapper u_bpsk_mapper(
        .clk           (clk),
        .rst_n         (rst_n),
        .bit           (bit),
        .bit_valid     (bit_valid),
        .sig           (pulse),
        .sig_valid     (pulse_valid)
    );

    wire [15:0] pad_8;
    wire  pad_8_valid;
    zero_interpolator #(.TIME_FACTOR(400), .INTERPOLATION_FACTOR(8)) u_zero_padding_8(
        .clk           (clk),
        .rst_n         (rst_n),
        .x             (pulse),
        .x_valid       (pulse_valid),
        .y             (pad_8),
        .y_valid       (pad_8_valid)
    );

    wire [15:0] rcos_sig;
    wire rcos_valid;
    rcos_filter u_rcos_filter(
        .clk          (clk),
        .clk_enable   (pad_8_valid),
        .reset        (reset),
        .filter_in    (pad_8),
        .filter_out   (rcos_sig),
        .filter_out_valid (rcos_valid)
    );

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
    anti_imaging_filter_5 u_f5(
        .clk          (clk),
        .clk_enable   (pad_5_valid),
        .reset        (reset),
        .filter_in    (pad_5),
        .filter_out   (s5),
        .filter_out_valid (s5_valid)
    );

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
    anti_imaging_filter_10 u_f10(
        .clk          (clk),
        .clk_enable   (pad_10_valid),
        .reset        (reset),
        .filter_in    (pad_10),
        .filter_out   (s10),
        .filter_out_valid (s10_valid)
    );

    anti_imaging_filter_8_par u_f8(
        .clk          (clk),
        .clk_enable   (s10_valid),
        .reset        (reset),
        .filter_in    (s10),
        .filter_out   (sig),
        .ce_out       ()
    );

endmodule
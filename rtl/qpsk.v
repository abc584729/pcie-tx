`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2026/08/27 14:19:44
// Design Name:
// Module Name: qpsk
// Project Name:
// Target Devices:
// Tool Versions:
// Description: QPSK transmit chain, mirrors bpsk.v with dual I/Q
//              lanes. Symbol rate 4.5 MHz @ 180 MHz clk (symbol
//              period 40 clk, qpsk_ram COUNT_MAX=40). Upsampling
//              8x (zero-ins) -> rcos -> 5x (zero-ins) -> anti-
//              imaging 5 -> anti-imaging 8x polyphase parallel =
//              320 samples per symbol. No 10x stage (QPSK does not
//              use it, matches the Simulink golden 8x5x8).
//
// Dependencies: qpsk_ram, qpsk_mapper, zero_interpolator,
//               rcos_filter_iq, anti_imaging_filter_5_iq,
//               anti_imaging_filter_8_par_iq, dpram
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module qpsk(
    input clk, rst_n, en,
    output [127:0] sig_i,
    output [127:0] sig_q,
    output sig_valid
    );

    wire reset = ~rst_n;

    // 2-bit symbol from RAM (4.5 MHz, one symbol per 40 clk)
    wire [1:0] bits;
    wire bits_valid;
    qpsk_ram u_qpsk_ram(
        .clk         (clk),
        .rst_n       (rst_n),
        .w_en        (1'b0),
        .w_addr      (5'd0),
        .w_data      (16'd0),
        .rd_en       (en),
        .rdata       (bits),
        .rdata_valid (bits_valid)
    );

    // QPSK mapping: 2 bits -> I/Q symbols (En15)
    wire [15:0] pulse_i, pulse_q;
    wire pulse_valid;
    qpsk_mapper u_qpsk_mapper(
        .clk       (clk),
        .rst_n     (rst_n),
        .bit       (bits),
        .bit_valid (bits_valid),
        .sig_valid (pulse_valid),
        .i         (pulse_i),
        .q         (pulse_q)
    );

    // 8x zero insertion (40 clk -> 5 clk), I/Q lanes
    wire [15:0] pad_i8, pad_q8;
    wire pad_8_valid;
    zero_interpolator #(.TIME_FACTOR(40), .INTERPOLATION_FACTOR(8)) u_zero_padding_8_i(
        .clk(clk), .rst_n(rst_n),
        .x(pulse_i), .x_valid(pulse_valid),
        .y(pad_i8), .y_valid(pad_8_valid)
    );
    zero_interpolator #(.TIME_FACTOR(40), .INTERPOLATION_FACTOR(8)) u_zero_padding_8_q(
        .clk(clk), .rst_n(rst_n),
        .x(pulse_q), .x_valid(pulse_valid),
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
        .ce_out     (sig_valid)
    );

endmodule

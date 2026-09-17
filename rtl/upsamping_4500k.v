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
        output [127:0] sig_q,
        output sig_valid      // data valid of the parallel output group
    );

    wire reset = ~rst_n;

    // ------------------------------------------------------------------
    // Data-valid chain (annotation only, the data path is untouched).
    // Window depth per stage = that filter's tap count + 16, which covers its
    // measured impulse-response span (see the per-stage comments below).  The
    // margin is deliberate: a window that is too long only delays the DAC mute,
    // a window that is too short would clip real data.
    // The I and Q lanes get the same clk_enable and the same input data
    // validity, so one common valid per stage covers both.
    // ------------------------------------------------------------------

    // 8x zero insertion (40 clk -> 5 clk), I/Q lanes
    wire [15:0] pad_i8, pad_q8;
    wire pad_8_valid;
    wire d8;
    zero_interpolator #(.TIME_FACTOR(40), .INTERPOLATION_FACTOR(8)) u_zero_padding_8_i(
        .clk(clk), .rst_n(rst_n),
        .x(din_i), .x_valid(din_valid), .x_data_valid(din_valid),
        .y(pad_i8), .y_valid(pad_8_valid), .y_data_valid(d8)
    );
    zero_interpolator #(.TIME_FACTOR(40), .INTERPOLATION_FACTOR(8)) u_zero_padding_8_q(
        .clk(clk), .rst_n(rst_n),
        .x(din_q), .x_valid(din_valid), .x_data_valid(din_valid),
        .y(pad_q8), .y_valid(),  // same slot phase as the I lane, left open
        .y_data_valid()
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

    // rcos_filter_iq: 64 taps; measured impulse-response span 73 clk_enable events
    // (these filters are systolic -- every tap has its own product/under_pipe
    // register -- so the span is longer than the ce_delay/ce_pipe the filter
    // reports for its own output valid).  Window = taps + 16 = 80: a window
    // that is too long only delays the DAC mute, a too-short one clips data.
    localparam V_RCOS_D = 80;
    reg [V_RCOS_D-1:0] v_rcos;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) v_rcos <= 0;
        else if(pad_8_valid) v_rcos <= {v_rcos[V_RCOS_D-2:0], d8};
    end
    wire d_rcos = |v_rcos;

    // 5x zero insertion (5 clk -> 1 clk), I/Q lanes
    wire [15:0] pad_i5, pad_q5;
    wire pad_5_valid;
    wire d5;
    zero_interpolator #(.TIME_FACTOR(5), .INTERPOLATION_FACTOR(5)) u_zero_padding_5_i(
        .clk(clk), .rst_n(rst_n),
        .x(rcos_i), .x_valid(rcos_valid), .x_data_valid(d_rcos),
        .y(pad_i5), .y_valid(pad_5_valid), .y_data_valid(d5)
    );
    zero_interpolator #(.TIME_FACTOR(5), .INTERPOLATION_FACTOR(5)) u_zero_padding_5_q(
        .clk(clk), .rst_n(rst_n),
        .x(rcos_q), .x_valid(rcos_valid), .x_data_valid(d_rcos),
        .y(pad_q5), .y_valid(),  // slot every clk, left open
        .y_data_valid()
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

    // anti_imaging_filter_5_iq: 14 taps; measured impulse-response span 21 clk_enable events
    // (these filters are systolic -- every tap has its own product/under_pipe
    // register -- so the span is longer than the ce_delay/ce_pipe the filter
    // reports for its own output valid).  Window = taps + 16 = 30: a window
    // that is too long only delays the DAC mute, a too-short one clips data.
    localparam V_F5_D = 30;
    reg [V_F5_D-1:0] v_f5;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) v_f5 <= 0;
        else if(pad_5_valid) v_f5 <= {v_f5[V_F5_D-2:0], d5};
    end
    wire d_f5 = |v_f5;

    // 8x polyphase parallel anti-imaging -> 8 samples/clk, I/Q
    anti_imaging_filter_8_par_iq u_f8(
        .clk        (clk),
        .clk_enable (s5_valid),
        .reset      (reset),
        .filter_in_i(s_i5),
        .filter_in_q(s_q5),
        .filter_out_i(sig_i),
        .filter_out_q(sig_q),
        .ce_out     ()          // free-running echo, not a data valid
    );

    // anti_imaging_filter_8_par_iq: 4 taps; measured impulse-response span 6 clk_enable events
    // (these filters are systolic -- every tap has its own product/under_pipe
    // register -- so the span is longer than the ce_delay/ce_pipe the filter
    // reports for its own output valid).  Window = taps + 16 = 20: a window
    // that is too long only delays the DAC mute, a too-short one clips data.
    localparam V_F8_D = 20;
    reg [V_F8_D-1:0] v_f8;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) v_f8 <= 0;
        else if(s5_valid) v_f8 <= {v_f8[V_F8_D-2:0], d_f5};
    end
    assign sig_valid = |v_f8;

endmodule

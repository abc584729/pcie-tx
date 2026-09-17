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
        output [127:0] sig,
        output sig_valid      // data valid of the parallel output group
    );

    wire reset = ~rst_n;

    // ------------------------------------------------------------------
    // Data-valid chain (annotation only, the data path is untouched).
    // Window depth per stage = that filter's tap count + 16, which covers its
    // measured impulse-response span (see the per-stage comments below).  The
    // margin is deliberate: a window that is too long only delays the DAC mute,
    // a window that is too short would clip real data.
    // ------------------------------------------------------------------

    // 9x zero insert: 450 clk per symbol -> one output every 450/9 = 50 clk
    wire [15:0] pad_9;
    wire  pad_9_valid;
    wire  d9;
    zero_interpolator #(.TIME_FACTOR(450), .INTERPOLATION_FACTOR(9)) u_zero_padding_9(
        .clk           (clk),
        .rst_n         (rst_n),
        .x             (din),
        .x_valid       (din_valid),
        .x_data_valid  (din_valid),
        .y             (pad_9),
        .y_valid       (pad_9_valid),
        .y_data_valid  (d9)
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

    // rcos_400k: 72 taps; measured impulse-response span 82 clk_enable events
    // (these filters are systolic -- every tap has its own product/under_pipe
    // register -- so the span is longer than the ce_delay/ce_pipe the filter
    // reports for its own output valid).  Window = taps + 16 = 88: a window
    // that is too long only delays the DAC mute, a too-short one clips data.
    localparam V_RCOS_D = 88;
    reg [V_RCOS_D-1:0] v_rcos;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) v_rcos <= 0;
        else if(pad_9_valid) v_rcos <= {v_rcos[V_RCOS_D-2:0], d9};
    end
    wire d_rcos = |v_rcos;

    // 5x zero insert: one output every 50/5 = 10 clk
    wire [15:0] pad_5;
    wire  pad_5_valid;
    wire  d5;
    zero_interpolator #(.TIME_FACTOR(50), .INTERPOLATION_FACTOR(5)) u_zero_padding_5(
        .clk           (clk),
        .rst_n         (rst_n),
        .x             (rcos_sig),
        .x_valid       (rcos_valid),
        .x_data_valid  (d_rcos),
        .y             (pad_5),
        .y_valid       (pad_5_valid),
        .y_data_valid  (d5)
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

    // anti_imaging_5_400k: 13 taps; measured impulse-response span 21 clk_enable events
    // (these filters are systolic -- every tap has its own product/under_pipe
    // register -- so the span is longer than the ce_delay/ce_pipe the filter
    // reports for its own output valid).  Window = taps + 16 = 29: a window
    // that is too long only delays the DAC mute, a too-short one clips data.
    localparam V_F5_D = 29;
    reg [V_F5_D-1:0] v_f5;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) v_f5 <= 0;
        else if(pad_5_valid) v_f5 <= {v_f5[V_F5_D-2:0], d5};
    end
    wire d_f5 = |v_f5;

    // 10x zero insert: one output every 10/10 = 1 clk
    wire [15:0] pad_10;
    wire  pad_10_valid;
    wire  d10;
    zero_interpolator #(.TIME_FACTOR(10), .INTERPOLATION_FACTOR(10)) u_zero_padding_10(
        .clk           (clk),
        .rst_n         (rst_n),
        .x             (s5),
        .x_valid       (s5_valid),
        .x_data_valid  (d_f5),
        .y             (pad_10),
        .y_valid       (pad_10_valid),
        .y_data_valid  (d10)
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

    // anti_imaging_10_400k: 25 taps; measured impulse-response span 34 clk_enable events
    // (these filters are systolic -- every tap has its own product/under_pipe
    // register -- so the span is longer than the ce_delay/ce_pipe the filter
    // reports for its own output valid).  Window = taps + 16 = 41: a window
    // that is too long only delays the DAC mute, a too-short one clips data.
    localparam V_F10_D = 41;
    reg [V_F10_D-1:0] v_f10;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) v_f10 <= 0;
        else if(pad_10_valid) v_f10 <= {v_f10[V_F10_D-2:0], d10};
    end
    wire d_f10 = |v_f10;

    anti_imaging_8_par_400k u_f8(
        .clk          (clk),
        .clk_enable   (s10_valid),
        .reset        (reset),
        .filter_in    (s10),
        .filter_out   (sig),
        .ce_out       ()          // free-running echo, not a data valid
    );

    // anti_imaging_8_par_400k: 4 taps; measured impulse-response span 6 clk_enable events
    // (these filters are systolic -- every tap has its own product/under_pipe
    // register -- so the span is longer than the ce_delay/ce_pipe the filter
    // reports for its own output valid).  Window = taps + 16 = 20: a window
    // that is too long only delays the DAC mute, a too-short one clips data.
    localparam V_F8_D = 20;
    reg [V_F8_D-1:0] v_f8;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) v_f8 <= 0;
        else if(s10_valid) v_f8 <= {v_f8[V_F8_D-2:0], d_f10};
    end
    assign sig_valid = |v_f8;

endmodule

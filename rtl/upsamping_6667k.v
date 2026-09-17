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

    // 9x zero insertion: one output every 27/9 = 3 clk, I/Q lanes
    wire [15:0] pad_i9, pad_q9;
    wire pad_9_valid;
    wire d9;
    zero_interpolator #(.TIME_FACTOR(27), .INTERPOLATION_FACTOR(9)) u_zero_padding_9_i(
        .clk(clk), .rst_n(rst_n),
        .x(din_i), .x_valid(din_valid), .x_data_valid(din_valid),
        .y(pad_i9), .y_valid(pad_9_valid), .y_data_valid(d9)
    );
    zero_interpolator #(.TIME_FACTOR(27), .INTERPOLATION_FACTOR(9)) u_zero_padding_9_q(
        .clk(clk), .rst_n(rst_n),
        .x(din_q), .x_valid(din_valid), .x_data_valid(din_valid),
        .y(pad_q9), .y_valid(),  // same slot phase as the I lane, left open
        .y_data_valid()
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

    // 3x zero insertion: one output every clk, I/Q lanes
    wire [15:0] pad_i3, pad_q3;
    wire pad_3_valid;
    wire d3;
    zero_interpolator #(.TIME_FACTOR(3), .INTERPOLATION_FACTOR(3)) u_zero_padding_3_i(
        .clk(clk), .rst_n(rst_n),
        .x(rcos_i), .x_valid(rcos_valid), .x_data_valid(d_rcos),
        .y(pad_i3), .y_valid(pad_3_valid), .y_data_valid(d3)
    );
    zero_interpolator #(.TIME_FACTOR(3), .INTERPOLATION_FACTOR(3)) u_zero_padding_3_q(
        .clk(clk), .rst_n(rst_n),
        .x(rcos_q), .x_valid(rcos_valid), .x_data_valid(d_rcos),
        .y(pad_q3), .y_valid(),  // slot every clk, left open
        .y_data_valid()
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

    // anti_imaging_3_6667k: 7 taps; measured impulse-response span 13 clk_enable events
    // (these filters are systolic -- every tap has its own product/under_pipe
    // register -- so the span is longer than the ce_delay/ce_pipe the filter
    // reports for its own output valid).  Window = taps + 16 = 23: a window
    // that is too long only delays the DAC mute, a too-short one clips data.
    localparam V_F3_D = 23;
    reg [V_F3_D-1:0] v_f3;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) v_f3 <= 0;
        else if(pad_3_valid) v_f3 <= {v_f3[V_F3_D-2:0], d3};
    end
    wire d_f3 = |v_f3;

    // 8x polyphase parallel anti-imaging -> 8 samples/clk, I/Q
    anti_imaging_8_par_6667k u_f8_i(
        .clk        (clk),
        .clk_enable (s3_valid),
        .reset      (reset),
        .filter_in  (s_i3),
        .filter_out (sig_i),
        .ce_out     ()          // free-running echo, not a data valid
    );
    anti_imaging_8_par_6667k u_f8_q(
        .clk        (clk),
        .clk_enable (s3_valid),
        .reset      (reset),
        .filter_in  (s_q3),
        .filter_out (sig_q),
        .ce_out     ()
    );

    // anti_imaging_8_par_6667k: 4 taps; measured impulse-response span 6 clk_enable events
    // (these filters are systolic -- every tap has its own product/under_pipe
    // register -- so the span is longer than the ce_delay/ce_pipe the filter
    // reports for its own output valid).  Window = taps + 16 = 20: a window
    // that is too long only delays the DAC mute, a too-short one clips data.
    localparam V_F8_D = 20;
    reg [V_F8_D-1:0] v_f8;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) v_f8 <= 0;
        else if(s3_valid) v_f8 <= {v_f8[V_F8_D-2:0], d_f3};
    end
    assign sig_valid = |v_f8;

endmodule

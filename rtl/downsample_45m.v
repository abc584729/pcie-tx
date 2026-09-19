`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2026/09/19 00:00:00
// Design Name:
// Module Name: downsample_45m
// Project Name:
// Target Devices:
// Tool Versions:
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module downsample_45m(
        input clk, rst_n,
        input [255:0] din_iq,
        input din_valid,
        output [31:0] dout_iq,
        output dout_valid
    );

    wire reset = ~rst_n;

    // ------------------------------------------------------------------
    // 256-bit RFDC IQ bus -> two 128-bit lanes.
    // downsample_8_par wants lane 0 (earliest sample) in the LSBs, which
    // is exactly where i0/q0 already sit in din_iq, so this is a pure
    // re-packing: zero logic, just wire order.
    // ------------------------------------------------------------------
    wire [127:0] din_i = {din_iq[224+:16], din_iq[192+:16], din_iq[160+:16], din_iq[128+:16],
                          din_iq[ 96+:16], din_iq[ 64+:16], din_iq[ 32+:16], din_iq[  0+:16]};
    wire [127:0] din_q = {din_iq[240+:16], din_iq[208+:16], din_iq[176+:16], din_iq[144+:16],
                          din_iq[112+:16], din_iq[ 80+:16], din_iq[ 48+:16], din_iq[ 16+:16]};

    // ------------------------------------------------------------------
    // Stage 1: divide by 8, polyphase, fully parallel.  One output per
    // din_valid, so 8 x 180M = 1.44 GSPS in, 180 MSPS out.
    // ------------------------------------------------------------------
    wire signed [15:0] d8_i, d8_q;
    wire ce8_i;
    downsample_8_par u_d8_i(
        .clk        (clk),
        .clk_enable (din_valid),
        .reset      (reset),
        .filter_in  (din_i),
        .filter_out (d8_i),
        .ce_out     (ce8_i)
    );
    downsample_8_par u_d8_q(
        .clk        (clk),
        .clk_enable (din_valid),
        .reset      (reset),
        .filter_in  (din_q),
        .filter_out (d8_q),
        .ce_out     ()          // same phase as the I lane, left open
    );

    // ------------------------------------------------------------------
    // Stage 2: FIR first, then divide by 4.
    //
    // The MATLAB model is d_8 -> Downsample(8) -> d_4 -> Downsample(4).
    // Therefore d_4 must consume EVERY valid d_8 output.  clk_enable is
    // a global clock enable, not a decimation input: pulsing it 1 in 4
    // would discard three samples before filtering and change the filter
    // response completely.  ce4 below marks which filtered result is kept;
    // it must not gate the d_4 datapath.
    // ------------------------------------------------------------------
    reg [1:0] ce4_cnt;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) ce4_cnt <= 2'd0;
        else if(ce8_i) ce4_cnt <= ce4_cnt + 2'd1;
    end
    wire ce4 = ce8_i & (ce4_cnt == 2'd3);

    wire signed [15:0] d4_i, d4_q;
    downsample_4 u_d4_i(
        .clk        (clk),
        .clk_enable (ce8_i),
        .reset      (reset),
        .filter_in  (d8_i),
        .filter_out (d4_i)
    );
    downsample_4 u_d4_q(
        .clk        (clk),
        .clk_enable (ce8_i),
        .reset      (reset),
        .filter_in  (d8_q),
        .filter_out (d4_q)
    );

    assign dout_iq = {d4_q, d4_i};   // {q, i}

    // ------------------------------------------------------------------
    // Output valid.
    // downsample_4 is 10 clk_enable periods deep (10 register stages:
    // delay_pipeline[0], delay_pipeline_0_under_pipe, product1_pipe,
    // sumpipe1..5, sumpipe6_1, output_register).  Its enable is ce8_i, so
    // the result lands 10 ce8_i pulses after its corresponding input.
    // Delay the 1-in-4 selection pulse through the same enabled stages.
    // ------------------------------------------------------------------
    localparam D4_LAT = 10;
    reg [D4_LAT-1:0] d4_ce_del;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) d4_ce_del <= 0;
        else if(ce8_i) d4_ce_del <= {d4_ce_del[D4_LAT-2:0], ce4};
    end

    // ce8_i keeps the strobe low when the input stream is paused; unlike
    // the old din_valid-clocked delay, this cannot freeze dout_valid high.
    assign dout_valid = ce8_i & d4_ce_del[D4_LAT-1];

endmodule

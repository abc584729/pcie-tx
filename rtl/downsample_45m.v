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
    wire ce8_i, ce8_q;
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
    // Stage 2: divide by 4.  downsample_4 has no ce_out of its own and
    // only advances its delay line when clk_enable is high, so the
    // decimation is done here, by pulsing its enable 1 in 4.
    // The counter counts ce8_i (real divide-by-8 outputs), not din_valid
    // ticks, so the first pulse lands on the 4th output of stage 1 and
    // the phase does not depend on how long stage 1's pipeline takes to
    // fill.  It still stops by itself when the input stream stops.
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
        .clk_enable (ce4),
        .reset      (reset),
        .filter_in  (d8_i),
        .filter_out (d4_i)
    );
    downsample_4 u_d4_q(
        .clk        (clk),
        .clk_enable (ce4),
        .reset      (reset),
        .filter_in  (d8_q),
        .filter_out (d4_q)
    );

    assign dout_iq = {d4_q, d4_i};   // {q, i}

    // ------------------------------------------------------------------
    // Output valid.
    // downsample_4 is 10 clk_enable periods deep (10 register stages:
    // delay_pipeline[0], delay_pipeline_0_under_pipe, product1_pipe,
    // sumpipe1..5, sumpipe6_1, output_register).  Its enable is ce4, so
    // the result lands 10 ce4 pulses = 40 din_valid periods after ce4.
    // Shift ce4 through a 4*D4_LAT deep register clocked by din_valid.
    // The window-OR is the same idea as the upsample chain's data-valid
    // chain: it makes the strobe fall by itself once the input stream
    // stops, instead of holding the last value forever.
    // ------------------------------------------------------------------
    localparam D4_LAT = 10;                 // d_4 latency, in clk_enable periods
    localparam V_D4_D = 4*D4_LAT + 8;       // window = the drain + margin

    // Input-loss flush.  Both valid registers below are clocked by din_valid,
    // so if the ADC stream stops they freeze -- and if d4_ce_del[39] happens
    // to be frozen at 1, dout_valid stays high forever, presenting the last
    // sample over and over.  (The datapath is frozen too, so those strobes
    // are duplicates, not real samples.)  Count idle clks and clear the
    // chain once the input is clearly gone.
    // In hardware din_valid is high every clk, so this only ever trips when
    // the stream really stops.  The 16-clk threshold still tolerates the
    // testbench's 1-in-8 din_valid pacing.
    reg [4:0] idle_cnt;
    wire in_idle = idle_cnt[4];
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) idle_cnt <= 5'd0;
        else if(din_valid) idle_cnt <= 5'd0;
        else if(!idle_cnt[4]) idle_cnt <= idle_cnt + 5'd1;
    end

    reg [4*D4_LAT-1:0] d4_ce_del;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) d4_ce_del <= 0;
        else if(in_idle) d4_ce_del <= 0;
        else if(din_valid) d4_ce_del <= {d4_ce_del[4*D4_LAT-2:0], ce4};
    end

    reg [V_D4_D-1:0] v_d4;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) v_d4 <= 0;
        else if(in_idle) v_d4 <= 0;
        else if(din_valid) v_d4 <= {v_d4[V_D4_D-2:0], 1'b1};
    end
    wire d_d4 = |v_d4;

    assign dout_valid = d4_ce_del[4*D4_LAT-1] & d_d4;

endmodule

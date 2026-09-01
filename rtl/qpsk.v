`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/27 12:56:44
// Design Name: 
// Module Name: qpsk
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

module qpsk(
        input clk, rst_n, en,
        input [15:0] dds_pinc,
        input [127:0] dds_poff,
        input dds_rstn,
        input [3:0] shift,
        input w_en,
        input [4:0] w_addr,
        input [15:0] w_data,
        output [127:0] sig_i, sig_q
    );

    wire reset = ~rst_n;

    // 2-bit symbol from RAM (4.5 MHz, one symbol per 40 clk)
    wire [1:0] bits;
    wire bits_valid;
    qpsk_ram u_qpsk_ram(
        .clk         (clk),
        .rst_n       (rst_n),
        .w_en        (w_en),
        .w_addr      (w_addr),
        .w_data      (w_data),
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

    // Digital attenuation: scale I/Q mapper outputs by 2^-shift
    wire [15:0] pulse_i_atten, pulse_q_atten;
    wire pulse_atten_valid;
    digital_attenuator_iq u_digital_attenuator_iq(
        .clk         (clk),
        .rst_n       (rst_n),
        .din_i       (pulse_i),
        .din_q       (pulse_q),
        .shift       (shift),
        .din_valid   (pulse_valid),
        .dout_i      (pulse_i_atten),
        .dout_q      (pulse_q_atten),
        .dout_valid  (pulse_atten_valid)
    );

    // 8x zero insertion (40 clk -> 5 clk), I/Q lanes
    wire [15:0] pad_i8, pad_q8;
    wire pad_8_valid;
    zero_interpolator #(.TIME_FACTOR(40), .INTERPOLATION_FACTOR(8)) u_zero_padding_8_i(
        .clk(clk), .rst_n(rst_n),
        .x(pulse_i_atten), .x_valid(pulse_atten_valid),
        .y(pad_i8), .y_valid(pad_8_valid)
    );
    zero_interpolator #(.TIME_FACTOR(40), .INTERPOLATION_FACTOR(8)) u_zero_padding_8_q(
        .clk(clk), .rst_n(rst_n),
        .x(pulse_q_atten), .x_valid(pulse_atten_valid),
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
    wire [127:0] sig_i_par, sig_q_par;
    anti_imaging_filter_8_par_iq u_f8(
        .clk        (clk),
        .clk_enable (s5_valid),
        .reset      (reset),
        .filter_in_i(s_i5),
        .filter_in_q(s_q5),
        .filter_out_i(sig_i_par),
        .filter_out_q(sig_q_par),
        .ce_out     (sig_valid)
    );

    wire [127:0] dds_i, dds_q;
    dds_x8 u_dds_x8(
        .clk          (clk),
        .rst_n        (dds_rstn),
        .pinc         (dds_pinc),
        .poff         (dds_poff),
        .dds_i        (dds_i),
        .dds_q        (dds_q)
    );

    wire [15:0] i_0 = sig_i_par[15:0];
    wire [15:0] i_1 = sig_i_par[31:16];
    wire [15:0] i_2 = sig_i_par[47:32];
    wire [15:0] i_3 = sig_i_par[63:48];
    wire [15:0] i_4 = sig_i_par[79:64];
    wire [15:0] i_5 = sig_i_par[95:80];
    wire [15:0] i_6 = sig_i_par[111:96];
    wire [15:0] i_7 = sig_i_par[127:112];

    wire [15:0] q_0 = sig_q_par[15:0];
    wire [15:0] q_1 = sig_q_par[31:16];
    wire [15:0] q_2 = sig_q_par[47:32];
    wire [15:0] q_3 = sig_q_par[63:48];
    wire [15:0] q_4 = sig_q_par[79:64];
    wire [15:0] q_5 = sig_q_par[95:80];
    wire [15:0] q_6 = sig_q_par[111:96];
    wire [15:0] q_7 = sig_q_par[127:112];

    wire [31:0] cmpy_dout_0, cmpy_dout_1, cmpy_dout_2, cmpy_dout_3;
    wire [31:0] cmpy_dout_4, cmpy_dout_5, cmpy_dout_6, cmpy_dout_7;

    cmpy_0 u_cmpy_0(
        .aclk(clk),                                          // input wire aclk
        .aresetn(rst_n),                                     // input wire aresetn
        .s_axis_a_tvalid(1'b1),                              // input wire s_axis_a_tvalid
        .s_axis_a_tdata({q_0, i_0}),                         // input wire [31 : 0] s_axis_a_tdata
        .s_axis_b_tvalid(1'b1),                              // input wire s_axis_b_tvalid
        .s_axis_b_tdata({dds_q[15:0], dds_i[15:0]}),         // input wire [31 : 0] s_axis_b_tdata
        .m_axis_dout_tvalid(),                               // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(cmpy_dout_0)                      // output wire [31 : 0] m_axis_dout_tdata
    );

    cmpy_0 u_cmpy_1(
        .aclk(clk),
        .aresetn(rst_n),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata({q_1, i_1}),
        .s_axis_b_tvalid(1'b1),
        .s_axis_b_tdata({dds_q[31:16], dds_i[31:16]}),
        .m_axis_dout_tvalid(),
        .m_axis_dout_tdata(cmpy_dout_1)
    );

    cmpy_0 u_cmpy_2(
        .aclk(clk),
        .aresetn(rst_n),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata({q_2, i_2}),
        .s_axis_b_tvalid(1'b1),
        .s_axis_b_tdata({dds_q[47:32], dds_i[47:32]}),
        .m_axis_dout_tvalid(),
        .m_axis_dout_tdata(cmpy_dout_2)
    );

    cmpy_0 u_cmpy_3(
        .aclk(clk),
        .aresetn(rst_n),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata({q_3, i_3}),
        .s_axis_b_tvalid(1'b1),
        .s_axis_b_tdata({dds_q[63:48], dds_i[63:48]}),
        .m_axis_dout_tvalid(),
        .m_axis_dout_tdata(cmpy_dout_3)
    );

    cmpy_0 u_cmpy_4(
        .aclk(clk),
        .aresetn(rst_n),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata({q_4, i_4}),
        .s_axis_b_tvalid(1'b1),
        .s_axis_b_tdata({dds_q[79:64], dds_i[79:64]}),
        .m_axis_dout_tvalid(),
        .m_axis_dout_tdata(cmpy_dout_4)
    );

    cmpy_0 u_cmpy_5(
        .aclk(clk),
        .aresetn(rst_n),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata({q_5, i_5}),
        .s_axis_b_tvalid(1'b1),
        .s_axis_b_tdata({dds_q[95:80], dds_i[95:80]}),
        .m_axis_dout_tvalid(),
        .m_axis_dout_tdata(cmpy_dout_5)
    );

    cmpy_0 u_cmpy_6(
        .aclk(clk),
        .aresetn(rst_n),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata({q_6, i_6}),
        .s_axis_b_tvalid(1'b1),
        .s_axis_b_tdata({dds_q[111:96], dds_i[111:96]}),
        .m_axis_dout_tvalid(),
        .m_axis_dout_tdata(cmpy_dout_6)
    );

    cmpy_0 u_cmpy_7(
        .aclk(clk),
        .aresetn(rst_n),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata({q_7, i_7}),
        .s_axis_b_tvalid(1'b1),
        .s_axis_b_tdata({dds_q[127:112], dds_i[127:112]}),
        .m_axis_dout_tvalid(),
        .m_axis_dout_tdata(cmpy_dout_7)
    );

    assign sig_i[15:0]    = cmpy_dout_0[15:0];
    assign sig_q[15:0]    = cmpy_dout_0[31:16];
    assign sig_i[31:16]   = cmpy_dout_1[15:0];
    assign sig_q[31:16]   = cmpy_dout_1[31:16];
    assign sig_i[47:32]   = cmpy_dout_2[15:0];
    assign sig_q[47:32]   = cmpy_dout_2[31:16];
    assign sig_i[63:48]   = cmpy_dout_3[15:0];
    assign sig_q[63:48]   = cmpy_dout_3[31:16];
    assign sig_i[79:64]   = cmpy_dout_4[15:0];
    assign sig_q[79:64]   = cmpy_dout_4[31:16];
    assign sig_i[95:80]   = cmpy_dout_5[15:0];
    assign sig_q[95:80]   = cmpy_dout_5[31:16];
    assign sig_i[111:96]  = cmpy_dout_6[15:0];
    assign sig_q[111:96]  = cmpy_dout_6[31:16];
    assign sig_i[127:112] = cmpy_dout_7[15:0];
    assign sig_q[127:112] = cmpy_dout_7[31:16];

endmodule

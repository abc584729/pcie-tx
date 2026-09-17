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
        input clk, rst_n, ram_en,
        input qpsk_en,
        input rate_sel,              // 0 = 4.5 MHz symbol rate, 1 = 6.667 MHz
        input [31:0] dds_pinc,
        input [255:0] dds_poff,
        input dds_rstn,
        input signed [15:0] atten,   // Q1.14: 0x4000 = 1.0 (0 dB), 0x2000 = 0.5 (-6 dB)
        input w_en,
        input [14:0] w_addr,
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
        .rate_sel    (rate_sel),
        .w_en        (w_en),
        .w_addr      (w_addr),
        .w_data      (w_data),
        .rd_en       (ram_en),
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

    // Digital attenuation: scale I/Q mapper outputs by Q1.14 coefficient (0x4000 = 0 dB)
    wire [15:0] pulse_i_atten, pulse_q_atten;
    wire pulse_atten_valid;
    digital_attenuator_iq u_digital_attenuator_iq(
        .clk         (clk),
        .rst_n       (rst_n),
        .din_i       (pulse_i),
        .din_q       (pulse_q),
        .atten       (atten),
        .din_valid   (pulse_valid),
        .dout_i      (pulse_i_atten),
        .dout_q      (pulse_q_atten),
        .dout_valid  (pulse_atten_valid)
    );

    wire [15:0] din_4500_i = rate_sel ? 16'd0 : pulse_i_atten;
    wire [15:0] din_4500_q = rate_sel ? 16'd0 : pulse_q_atten;
    wire        din_4500_valid = rate_sel ? 1'b0 : pulse_atten_valid;
    wire [15:0] din_6667_i = rate_sel ? pulse_i_atten : 16'd0;
    wire [15:0] din_6667_q = rate_sel ? pulse_q_atten : 16'd0;
    wire        din_6667_valid = rate_sel ? pulse_atten_valid : 1'b0;

    wire [127:0] sig_i_4500, sig_q_4500, sig_i_6667, sig_q_6667;

    upsamping_4500k u_upsamping_4500k(
        .clk         (clk),
        .rst_n       (rst_n),
        .din_i       (din_4500_i),
        .din_q       (din_4500_q),
        .din_valid   (din_4500_valid),
        .sig_i       (sig_i_4500),
        .sig_q       (sig_q_4500)
    );

    upsamping_6667k u_upsamping_6667k(
        .clk         (clk),
        .rst_n       (rst_n),
        .din_i       (din_6667_i),
        .din_q       (din_6667_q),
        .din_valid   (din_6667_valid),
        .sig_i       (sig_i_6667),
        .sig_q       (sig_q_6667)
    );

    wire [127:0] sig_i_par = rate_sel ? sig_i_6667 : sig_i_4500;
    wire [127:0] sig_q_par = rate_sel ? sig_q_6667 : sig_q_4500;

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

    wire [127:0] sig_i_int, sig_q_int;

    assign sig_i_int[15:0]    = cmpy_dout_0[15:0];
    assign sig_q_int[15:0]    = cmpy_dout_0[31:16];
    assign sig_i_int[31:16]   = cmpy_dout_1[15:0];
    assign sig_q_int[31:16]   = cmpy_dout_1[31:16];
    assign sig_i_int[47:32]   = cmpy_dout_2[15:0];
    assign sig_q_int[47:32]   = cmpy_dout_2[31:16];
    assign sig_i_int[63:48]   = cmpy_dout_3[15:0];
    assign sig_q_int[63:48]   = cmpy_dout_3[31:16];
    assign sig_i_int[79:64]   = cmpy_dout_4[15:0];
    assign sig_q_int[79:64]   = cmpy_dout_4[31:16];
    assign sig_i_int[95:80]   = cmpy_dout_5[15:0];
    assign sig_q_int[95:80]   = cmpy_dout_5[31:16];
    assign sig_i_int[111:96]  = cmpy_dout_6[15:0];
    assign sig_q_int[111:96]  = cmpy_dout_6[31:16];
    assign sig_i_int[127:112] = cmpy_dout_7[15:0];
    assign sig_q_int[127:112] = cmpy_dout_7[31:16];

    // Gate outputs by qpsk_en: zero when disabled
    assign sig_i = qpsk_en ? sig_i_int : 128'd0;
    assign sig_q = qpsk_en ? sig_q_int : 128'd0;

endmodule

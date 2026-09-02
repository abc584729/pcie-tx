`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/29 17:43:22
// Design Name: 
// Module Name: tx_top
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


module tx_top(
        input clk, rst_n, ram_en,
        input bpsk_en, qpsk_en,
        input dds_rstn,
        input signed [15:0] atten_bpsk, // Q1.14: 0x4000 = 1.0 (0 dB), 0x2000 = 0.5 (-6 dB)
        input signed [15:0] atten_qpsk,
        input [15:0] dds_pinc_bpsk,
        input [15:0] dds_pinc_qpsk,
        input [127:0] dds_poff_bpsk,
        input [127:0] dds_poff_qpsk,
        input        ram_w_en_bpsk,
        input [4:0]  ram_w_addr_bpsk,
        input [15:0] ram_w_data_bpsk,
        input        ram_w_en_qpsk,
        input [4:0]  ram_w_addr_qpsk,
        input [15:0] ram_w_data_qpsk,
        output [255:0] iq
    );

    wire [127:0] i_0, q_0;
    bpsk u_bpsk(
        .clk           (clk),
        .rst_n         (rst_n),
        .ram_en        (ram_en),
        .bpsk_en       (bpsk_en),
        .dds_pinc      (dds_pinc_bpsk),
        .dds_poff      (dds_poff_bpsk),
        .dds_rstn      (dds_rstn),
        .atten         (atten_bpsk),
        .w_en          (ram_w_en_bpsk),
        .w_addr        (ram_w_addr_bpsk),
        .w_data        (ram_w_data_bpsk),
        .sig_i         (i_0),
        .sig_q         (q_0)
    );

    wire [127:0] i_1, q_1;
    qpsk u_qpsk(
        .clk           (clk),
        .rst_n         (rst_n),
        .ram_en        (ram_en),
        .qpsk_en       (qpsk_en),
        .dds_pinc      (dds_pinc_qpsk),
        .dds_poff      (dds_poff_qpsk),
        .dds_rstn      (dds_rstn),
        .atten         (atten_qpsk),
        .w_en          (ram_w_en_qpsk),
        .w_addr        (ram_w_addr_qpsk),
        .w_data        (ram_w_data_qpsk),
        .sig_i         (i_1),
        .sig_q         (q_1)
    );

    add u_add(
        .clk           (clk),
        .rst_n         (rst_n),
        .i0            (i_0),
        .q0            (q_0),
        .i1            (i_1),
        .q1            (q_1),
        .iq            (iq)
    );
endmodule

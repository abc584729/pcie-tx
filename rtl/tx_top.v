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
        input rate_sel,              // 0 = bpsk 450 kHz / qpsk 4.5 MHz, 1 = bpsk 400 kHz / qpsk 6.667 MHz
        input dds_rstn,
        input signed [15:0] atten_bpsk, // Q1.14: 0x4000 = 1.0 (0 dB), 0x2000 = 0.5 (-6 dB)
        input signed [15:0] atten_qpsk,
        input [31:0] dds_pinc_bpsk,
        input [31:0] dds_pinc_qpsk,
        input [255:0] dds_poff_bpsk,
        input [255:0] dds_poff_qpsk,
        input        ram_w_en_bpsk,
        input [17:0] ram_w_addr_bpsk,
        input [15:0] ram_w_data_bpsk,
        input [22:0] bpsk_sym_num,     // BPSK symbols per turn (0 = whole table if cyclic)
        input        bpsk_single_shot, // 0 = cyclic (repeat each turn), 1 = single burst
        input [9:0]  bpsk_time_sel,    // 1024-symbol timebase position the BPSK read gate opens at
        input        ram_w_en_qpsk,
        input [14:0] ram_w_addr_qpsk,
        input [15:0] ram_w_data_qpsk,
        output [255:0] iq,
        output bpsk_sig_valid,       // BPSK parallel-chain data valid (8 cmpy valids OR'ed)
        output qpsk_sig_valid        // QPSK parallel-chain data valid (8 cmpy valids OR'ed)
    );

    wire [127:0] i_0, q_0;
    bpsk u_bpsk(
        .clk           (clk),
        .rst_n         (rst_n),
        .ram_en        (ram_en),
        .bpsk_en       (bpsk_en),
        .rate_sel      (rate_sel),
        .dds_pinc      (dds_pinc_bpsk),
        .dds_poff      (dds_poff_bpsk),
        .dds_rstn      (dds_rstn),
        .atten         (atten_bpsk),
        .w_en          (ram_w_en_bpsk),
        .w_addr        (ram_w_addr_bpsk),
        .w_data        (ram_w_data_bpsk),
        .sym_num       (bpsk_sym_num),
        .single_shot   (bpsk_single_shot),
        .time_sel      (bpsk_time_sel),
        .sig_i         (i_0),
        .sig_q         (q_0),
        .sig_valid     (bpsk_sig_valid)
    );

    wire [127:0] i_1, q_1;
    qpsk u_qpsk(
        .clk           (clk),
        .rst_n         (rst_n),
        .ram_en        (ram_en),
        .qpsk_en       (qpsk_en),
        .rate_sel      (rate_sel),
        .dds_pinc      (dds_pinc_qpsk),
        .dds_poff      (dds_poff_qpsk),
        .dds_rstn      (dds_rstn),
        .atten         (atten_qpsk),
        .w_en          (ram_w_en_qpsk),
        .w_addr        (ram_w_addr_qpsk),
        .w_data        (ram_w_data_qpsk),
        .sig_i         (i_1),
        .sig_q         (q_1),
        .sig_valid     (qpsk_sig_valid)
    );

    add u_add(
        .clk           (clk),
        .rst_n         (rst_n),
        .rate_sel      (rate_sel),
        .i0            (i_0),
        .q0            (q_0),
        .i1            (i_1),
        .q1            (q_1),
        .iq            (iq)
    );
endmodule

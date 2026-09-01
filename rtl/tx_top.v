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
        input clk, rst_n, tx_en,
        input dds_rstn,
        input [3:0] atten_shift_bpsk, 
        input [3:0] atten_shift_qpsk,
        input [15:0] dds_pinc_bpsk,
        input [15:0] dds_pinc_qpsk,
        input [127:0] dds_poff_bpsk,
        input [127:0] dds_poff_qpsk,
        output [127:0] i, q
    );

    wire [127:0] i_0, q_0;
    bpsk u_bpsk(
        .clk           (clk),
        .rst_n         (rst_n),
        .en            (tx_en),
        .dds_pinc      (dds_pinc_bpsk),
        .dds_poff      (dds_poff_bpsk),
        .dds_rstn      (dds_rstn),
        .sig_i         (i_0),
        .sig_q         (q_0)
    );

    wire [127:0] i_1, q_1;
    qpsk u_qpsk(
        .clk           (clk),
        .rst_n         (rst_n),
        .en            (tx_en),        
        .dds_pinc      (dds_pinc_qpsk),
        .dds_poff      (dds_poff_qpsk),
        .dds_rstn      (dds_rstn),
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
        .iout          (i),
        .qout          (q)
    );
endmodule

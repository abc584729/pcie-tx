`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/28 09:04:44
// Design Name: 
// Module Name: tb_tx
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


module tb_tx(

    );

    reg clk, rst_n, tx_en;
    reg dds_rstn;
    reg [15:0] dds_pinc_bpsk, dds_pinc_qpsk;
    reg [127:0] dds_poff_bpsk, dds_poff_qpsk;
    wire [127:0] i;
    wire [127:0] q;


    integer fp;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        tx_en = 0;
        dds_rstn = 0;
        fp = $fopen("D:/result.csv", "w");
        # 10;
        rst_n = 1;
        dds_pinc_bpsk = 16'h8E39;    // 100mhz: 65536*100/180 = 36409
        dds_pinc_qpsk = 16'h1C72;    // 200mhz: 65536*200/180 = 72818 -> mod 2^16 = 7282
        dds_poff_bpsk = 128'h7C72_6AAB_58E4_471C_3555_238E_11C7_0000;    // lane k: k*36409/8
        dds_poff_qpsk = 128'hF8E4_D555_B1C7_8E39_6AAB_471C_238E_0000;    // lane k: k*72818/8 mod 2^16
        # 10;
        dds_rstn = 1;
        # 10;
        tx_en = 1;
        # 100000;
        $fclose(fp);
        $display("Simulation done, file closed successfully.");
        $stop;
    end

    always @(posedge clk) begin
        if (rst_n) begin
            $fdisplay(fp, "%b", i);
            $fdisplay(fp, "%b", q);
        end
    end

    tx_top dut(
        .clk            (clk),
        .rst_n          (rst_n),
        .tx_en          (tx_en),
        .dds_rstn       (dds_rstn),
        .dds_pinc_bpsk  (dds_pinc_bpsk),
        .dds_pinc_qpsk  (dds_pinc_qpsk),
        .dds_poff_bpsk  (dds_poff_bpsk),
        .dds_poff_qpsk  (dds_poff_qpsk),
        .i              (i),
        .q              (q)
    );

endmodule
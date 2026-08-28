`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/28 09:04:44
// Design Name: 
// Module Name: tb_bpsk
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


module tb_bpsk(

    );

    reg clk, rst_n, en;
    wire [127:0] sig_i;
    wire [127:0] sig_q;

    wire sig_valid;

    integer fp;

    // 时钟
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 初始化
    initial begin
        rst_n = 0;
        en = 0;
        fp = $fopen("D:/result_qpsk.csv", "w");
        # 10;
        rst_n = 1;
        en = 1;
        # 100000;
        $fclose(fp);
        $display("Simulation done, file closed successfully.");
        $stop;
    end

    // 写文件
    always @(posedge clk) begin
        if (rst_n && sig_valid) begin
            $fdisplay(fp, "%b", sig_i);
            $fdisplay(fp, "%b", sig_q);
        end
    end

    qpsk dut(
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .sig_i(sig_i),
        .sig_q(sig_q),
        .sig_valid(sig_valid)
    );

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/27 12:56:44
// Design Name: 
// Module Name: bpsk_ram
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


module bpsk_ram(
    input clk, rst_n,
    input rd_en,             
    input rate_sel,          
    input w_en,                
    input [17:0] w_addr,
    input [15:0] w_data,
    input [22:0] sym_num,      // 单次发要发的符号数 1..4194304，0 = 不发
    input single_shot,         // 0 = 循环发（默认），1 = 发满 sym_num 个就停
    output rdata,             
    output rdata_valid
    );

    // 符号速率: rate_sel = 0 -> 450 kHz, 1 -> 400 kHz
    parameter COUNT_MAX_450K = 9'd400;
    parameter COUNT_MAX_400K = 9'd450;
    wire [8:0] count_max = rate_sel ? COUNT_MAX_400K : COUNT_MAX_450K;

    reg [8:0] count;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) count <= 0;
        else begin
            if(rd_en && count < count_max - 1'b1) count <= count + 1;
            else count <= 0;
        end
    end

    // 读脉冲
    wire flag = rd_en && (count == count_max - 1'b1);

    // 单次发：sym_cnt 数 rdata_valid，done 表示已发满；stop 门控读脉冲。
    // sym_num = 0 视为一个符号都不发；single_shot = 0 时 stop 恒 0，行为与原来一致。
    wire        rdata_valid_int;      // dpram 原始 valid
    reg  [22:0] sym_cnt;              // 已发出的符号数
    reg         done;                 // 已发满（只由 rst_n 清，重发靠上位机复位）
    wire        stop;
    wire        flag_g;               // 门控后的读脉冲

    wire [22:0] sym_last = sym_num - 23'd1;   // 最后一个符号的序号

    assign stop   = single_shot && (done || (sym_num == 23'd0));
    assign flag_g = flag & ~stop;

    // 读指针
    reg [21:0] rptr;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) rptr <= 0;
        else if(flag_g) begin
            if(rptr == 22'd4194303) rptr <= 0;
            else rptr <= rptr + 1;
        end
    end

    // 单次发：数 rdata_valid，计到 sym_num 个就停
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sym_cnt <= 0;
            done    <= 1'b0;
        end
        else if(rdata_valid_int && single_shot) begin
            if(sym_cnt == sym_last) done <= 1'b1;
            else sym_cnt <= sym_cnt + 1'b1;
        end
    end

    //双口ram：262144*16 = 4194304*1
    dpram #(.DEPTH(262144), .WADDR(18), .READ_WIDTH(1), .RADDR(22)) u_dpram(
        .clk           (clk),
        .rst_n         (rst_n),
        .w_en          (w_en),
        .w_addr        (w_addr),
        .w_data        (w_data),
        .r_en          (flag_g),
        .r_addr        (rptr),
        .r_data        (rdata),
        .r_data_valid  (rdata_valid_int)
    );

    assign rdata_valid = rdata_valid_int;

endmodule
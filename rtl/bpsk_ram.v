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
    input [9:0] time_sel,       
    input rate_sel,          
    input w_en,                
    input [17:0] w_addr,
    input [15:0] w_data,
    input [22:0] sym_num,      // 一轮要发的符号数 1..8388607；0 见下面 sym_len
    input single_shot,         // 0 = 循环发（默认），1 = 发满 sym_num 个就停
    output rdata,             
    output rdata_valid,
    output reg busy            // 1 = 正在发射（rd_en 有效且本轮没发完）
    );

    // 符号速率: rate_sel = 0 -> 450 kHz, 1 -> 400 kHz
    parameter COUNT_MAX_450K = 9'd400;
    parameter COUNT_MAX_400K = 9'd450;
    wire [8:0] count_max = rate_sel ? COUNT_MAX_400K : COUNT_MAX_450K;

    reg [8:0] count;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) count <= 0;
        else begin
            if(count < count_max - 1'b1) count <= count + 1;
            else count <= 0;
        end
    end

    // 时基计数 400 * 1024 clk
    reg [9:0] cnt_1024;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) cnt_1024 <= 10'd0;
        else if((count == count_max - 1'b1)) begin
            if(cnt_1024 == 10'd1023) cnt_1024 <= 10'd0;
            else cnt_1024 <= cnt_1024 + 1'b1;
        end
    end
    
    // 读使能：时基计数值走到 time_sel 那一刻开门（窗口只有一拍宽，一圈 1024 个符号才来一次），
    // rd_en 拉低立刻关门，所以 0x702 仍然是"停发"开关。
    // 注意：再拉高时要等时基下一圈转回 time_sel 才重新开门，最多等 1024 个符号。
    reg tx_en;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) tx_en <= 0;
        else if(rd_en && cnt_1024 == time_sel && count == count_max - 1'b1) tx_en <= 1;
        else if(!rd_en) tx_en <= 0;
        else tx_en <= tx_en;
    end
    
    // 读脉冲
    wire flag = tx_en && (count == count_max - 1'b1);

    // 一轮发多少个符号。sym_num = 0 在循环发下当作"一整张表"：上电默认值和
    // "忘了给符号数"的循环发都还是发整表，和加 sym_num 之前一致。单次发那边 0 仍然
    // 是"一个都不发"（寄存器复位就是 0，宁可空发也不要忘了写就发出整表）。
    wire [22:0] sym_len = ((sym_num == 23'd0) && !single_shot) ? 23'd4194304 : sym_num;

    // 单次发/循环发都按 sym_len 数，区别只在数满一轮之后干什么：
    //   single_shot = 1 -> 拉高 done，stop 关掉读脉冲，静默
    //   single_shot = 0 -> 计数和读指针一起归零，从头再数一轮，一直循环
    wire        rdata_valid_int;      // dpram 原始 valid
    reg  [22:0] sym_cnt;              // 本轮已发出的符号数
    reg         done;                 // 已发满（rst_n 或 rd_en 拉低都清）
    wire        stop;
    wire        flag_g;               // 门控后的读脉冲

    wire [22:0] sym_last = sym_len - 23'd1;   // 本轮最后一个符号的序号

    assign stop   = single_shot && (done || (sym_num == 23'd0));
    assign flag_g = flag & ~stop;

    // 发射状态：0x702（rd_en）有效就拉高；stop（单次发 done / sym_num=0）或者 rd_en 拉低就清 0。
    // 只打一拍、不组合输出，没有毛刺；rd_en 拉低同时也会清掉 rptr / sym_cnt / done，
    // 所以这个位落下就等于"这一轮结束了"。
    // 注意它不是"真的有波出"：0x702 拉高之后等时基窗口的那段（最长 1024 个符号）它已经是 1。
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) busy <= 1'b0;
        else       busy <= rd_en & ~stop;
    end

    // 读指针：就是 dpram 的表地址（低 22 位），数满一轮回到 0。
    // 做成 23 位是为了跟 sym_len 同宽：sym_num 超过表长时高位进位被 r_addr 截掉，
    // 自然回卷、整表重复 —— 和加 sym_num 之前"转满一圈回到 0"是同一个行为。
    reg [22:0] rptr;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n || ~rd_en) rptr <= 0;
        else if(flag_g) begin
            if(rptr == sym_last) rptr <= 0;
            else rptr <= rptr + 1'b1;
        end
    end

    // 数 rdata_valid：单次发计满置 done，循环发计满从头再数。
    // rd_en 拉低（上位机写 0x702 = 0 停发）时跟 rptr 一起归零，这样再拉高就是干净地
    // 从第 0 个符号重新发，而不是接着半路继续。
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n || ~rd_en) begin
            sym_cnt <= 0;
            done    <= 1'b0;
        end
        else if(rdata_valid_int) begin
            if(sym_cnt == sym_last) begin
                if(single_shot) done    <= 1'b1;
                else            sym_cnt <= 23'd0;
            end
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
        .r_addr        (rptr[21:0]),
        .r_data        (rdata),
        .r_data_valid  (rdata_valid_int)
    );

    assign rdata_valid = rdata_valid_int;

endmodule
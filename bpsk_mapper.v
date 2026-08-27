`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/27 12:56:44
// Design Name: 
// Module Name: bpsk_mapper
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


module bpsk_mapper(
    input clk, rst_n,
    input bit,
    output reg sig_valid,
    output reg [15:0] sig,
    );
    
    // 符号速率：450khz
    parameter COUNT_MAX = 9'd400;

    reg [8:0] count;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) count <= 0;
        else begin
            if(count < COUNT_MAX-1) count <= count + 1;
            else count <= 0;
        end
    end

    // 有效标志
    reg flag;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) flag <= 0;
        else begin
            if(count == COUNT_MAX-1) flag <= 1;
            else flag <= 0;
        end
    end

    // bpsk映射
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) sig <= 0;
        else begin
            if (flag) begin
                if (bit == 0) sig <= {1'b0,{15{1'b1}}};
                else sig <= {1'b1,{15{1'b0}}};
            end
            else sig <= 0;
        end
    end

    // 有效位输出
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) sig_valid <= 0;
        else sig_valid <= flag;
    end

endmodule
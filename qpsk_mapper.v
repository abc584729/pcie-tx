`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/27 13:13:44
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


module qpsk_mapper(
    input clk, rst_n,
    input [1:0] bit,
    output reg sig_valid,
    output reg [15:0] i,
    output reg [15:0] q,
    );
    
    // 符号速率：4.5Mhz
    parameter COUNT_MAX = 6'd40;

    reg [5:0] count;
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

    // qpsk映射
    reg [15:0] map_i, map_q;
    always @(*) begin
        case(bit) 
            2'b00: begin
                map_i = 16'h7FFF; // +1
                map_q = 16'h7FFF; // +1
            end
            2'b01: begin
                map_i = 16'h8000; // -1
                map_q = 16'h7FFF; // +1
            end
            2'b11: begin
                map_i = 16'h8000; // -1
                map_q = 16'h8000; // -1
            end
            2'b10: begin
                map_i = 16'h7FFF; // +1
                map_q = 16'h8000; // -1
            end
            default: begin
                map_i = 16'h0000;
                map_q = 16'h0000;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            i <= 0;
            q <= 0;
        end
        else begin
            if (flag) begin
                i <= map_i;
                q <= map_q;
            end
            else 
                i <= 0;
                q <= 0;
        end
    end

    // 有效位输出
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) sig_valid <= 0;
        else sig_valid <= flag;
    end

endmodule
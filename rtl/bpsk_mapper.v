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
    input bit, bit_valid,
    output reg sig_valid,
    output reg [15:0] sig
    );

    // bpsk”≥…‰
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) sig <= 0;
        else begin
            if (bit_valid) begin
                if (bit == 0) sig <= {1'b0,{15{1'b1}}};
                else sig <= {1'b1,{15{1'b0}}};
            end
            else sig <= 0;
        end
    end

    // ”––ßŒª
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) sig_valid <= 0;
        else sig_valid <= bit_valid;
    end

endmodule
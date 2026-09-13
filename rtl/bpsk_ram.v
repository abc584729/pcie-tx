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
    input w_en,                
    input [14:0] w_addr,
    input [15:0] w_data,
    output rdata,             
    output rdata_valid
    );

    // ·ûºÅËÙÂÊ: 450 kHz
    parameter COUNT_MAX = 9'd400;

    reg [8:0] count;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) count <= 0;
        else begin
            if(rd_en && count < COUNT_MAX-1) count <= count + 1;
            else count <= 0;
        end
    end

    // ¶ÁÂö³å
    wire flag = rd_en && (count == COUNT_MAX-1);

    // ¶ÁÖ¸Õë
    reg [18:0] rptr;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) rptr <= 0;
        else if(flag) begin
            if(rptr == 19'd524287) rptr <= 0;
            else rptr <= rptr + 1;
        end
    end

    //Ë«¿Úram£º32768*16 = 524288*1
    dpram #(.DEPTH(32768), .WADDR(15), .READ_WIDTH(1), .RADDR(19)) u_dpram(
        .clk           (clk),
        .rst_n         (rst_n),
        .w_en          (w_en),
        .w_addr        (w_addr),
        .w_data        (w_data),
        .r_en          (flag),
        .r_addr        (rptr),
        .r_data        (rdata),
        .r_data_valid  (rdata_valid)
    );

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/27 12:56:44
// Design Name: 
// Module Name: qpsk_ram
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


module qpsk_ram(
    input clk, rst_n,
    input rd_en,             
    input w_en,                
    input [4:0] w_addr,
    input [15:0] w_data,
    output [1:0] rdata,             
    output rdata_valid
    );

    // ·ûºÅËÙÂÊ: 4.50 MHz
    parameter COUNT_MAX = 6'd40;

    reg [5:0] count;
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
    reg [7:0] rptr;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) rptr <= 0;
        else if(flag) begin
            if(rptr == 8'd255) rptr <= 0;
            else rptr <= rptr + 1;
        end
    end

    //Ë«¿Úram : 32*16 = 256*2
    dpram #(.DEPTH(32), .WADDR(5), .READ_WIDTH(2), .RADDR(8)) u_dpram(
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
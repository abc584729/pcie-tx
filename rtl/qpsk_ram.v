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
    input rate_sel,          
    input w_en,                
    input [14:0] w_addr,
    input [15:0] w_data,
    output [1:0] rdata,             
    output rdata_valid
    );

    // ·ûºÅËÙÂÊ: rate_sel = 0 -> 4.5 MHz, 1 -> 6.667 MHz
    parameter COUNT_MAX_4500K = 6'd40;
    parameter COUNT_MAX_6667K = 6'd27;
    wire [5:0] count_max = rate_sel ? COUNT_MAX_6667K : COUNT_MAX_4500K;

    reg [5:0] count;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) count <= 0;
        else begin
            if(rd_en && count < count_max - 1'b1) count <= count + 1;
            else count <= 0;
        end
    end

    // ¶ÁÂö³å
    wire flag = rd_en && (count == count_max - 1'b1);

    // ¶ÁÖ¸Õë
    reg [17:0] rptr;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) rptr <= 0;
        else if(flag) begin
            if(rptr == 18'd262143) rptr <= 0;
            else rptr <= rptr + 1;
        end
    end

    //Ë«¿Úram : 32768*16 = 262144*2
    dpram #(.DEPTH(32768), .WADDR(15), .READ_WIDTH(2), .RADDR(18)) u_dpram(
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
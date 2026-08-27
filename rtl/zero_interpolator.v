`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/27 14:19:44
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


module zero_interpolator#(
        parameter TIME_FACTOR = 400,
        parameter INTERPOLATION_FACTOR = 5
    )(
        input clk, rst_n,
        input [15:0] x,
        input x_valid,
        output reg y_valid,
        output reg [15:0] y
    );

    parameter COUNT_MAX = TIME_FACTOR/INTERPOLATION_FACTOR;

    reg [8:0] count;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) count <= 0;
        else if(count == COUNT_MAX-1) count <= 0;
        else count <= count + 1;
    end
    
wire slot = (count == 0);

    // Latch the input sample on x_valid and emit it at the next slot
    // boundary; zeros at the other slots. Robust to any x_valid phase.
    reg [15:0] xr;
    reg pending;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            y       <= 0;
            xr      <= 0;
            pending <= 0;
        end
        else begin
            if(x_valid) begin
                xr      <= x;
                pending <= 1;
            end
            if(slot) begin
                if(x_valid)      y <= x;
                else if(pending) y <= xr;
                else             y <= 16'd0;
                pending <= 0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) y_valid <= 0;
        else y_valid <= slot;
    end
endmodule
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
        input x_data_valid,          // x carries real data this cycle
        output reg y_valid,
        output reg y_data_valid,     // y carries real data (not an inserted zero)
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

    // y_data_valid is the data-valid twin of the block above: it rides along
    // with the sample exactly like `pending` does, so it lands on the same
    // slot and stays in step with y and y_valid.
    // NOTE: keep this a *separate* signal from y_valid.  y_valid is the
    // free-running per-slot strobe the downstream FIRs use as their
    // clk_enable and nobody is allowed to gate it by data validity -- their
    // pipelines would stall.  y_data_valid is only an annotation.
    reg pending_dv;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            y_data_valid <= 0;
            pending_dv   <= 0;
        end
        else begin
            if(x_valid) pending_dv <= x_data_valid;
            if(slot) begin
                if(x_valid)      y_data_valid <= x_data_valid;
                else if(pending) y_data_valid <= pending_dv;
                else             y_data_valid <= 1'b0;
                pending_dv <= 0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) y_valid <= 0;
        else y_valid <= slot;
    end
endmodule
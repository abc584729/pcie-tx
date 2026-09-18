`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/27
// Design Name: 
// Module Name: dpram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:
//   Asymmetric dual-port RAM: 16-bit write / READ_WIDTH-bit read.
//   Single clock (sync). DEPTH words x 16 bits - the size is set by the
//   instantiation: bpsk_ram uses 262144 x 16 = 4 Mbit (512 KB), qpsk_ram
//   uses 32768 x 16 = 512 Kbit (64 KB).
//   The contents are written entirely through the write port; there is no
//   preload, so the PS must fill the whole table before the reader is
//   enabled (tx_start() does this with TX_REG_RAM_EN held at 0).
//   Read port is bit-addressable, LSB-first:
//   r_addr = word*(16/READ_WIDTH) + group index.
//   Reading and writing the same address on the same clock returns the
//   old value (read-first).
//
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dpram #(
    parameter DEPTH = 32,          // 16-bit word count
    parameter WADDR = 5,           // write address width = clog2(DEPTH)
    parameter READ_WIDTH = 1,      // read port width (1/2/4/8)
    parameter RADDR = 9            // read address width = clog2(DEPTH*16/READ_WIDTH)
)(
    input                 clk,
    input                 rst_n,
    input                 w_en,          // write port: 16 bits / clock
    input  [WADDR-1:0]    w_addr,        // word address 0..DEPTH-1
    input  [15:0]         w_data,
    input                 r_en,          // read port: READ_WIDTH bits / clock
    input  [RADDR-1:0]    r_addr,        // read group address 0..DEPTH*16/READ_WIDTH-1
    output reg [READ_WIDTH-1:0] r_data,        // registered output
    output reg            r_data_valid   // same cycle as r_data
);
    localparam RBITS = clog2(16/READ_WIDTH);   // bits to index a group within a word

    function integer clog2;
        input integer n;
        integer i;
        begin
            i = 0;
            while (n > 1) begin n = n >> 1; i = i + 1; end
            clog2 = i;
        end
    endfunction

    reg [15:0] mem [0:DEPTH-1];

    // write port
    always @(posedge clk) begin
        if (w_en) mem[w_addr] <= w_data;
    end

    // read port: high bits select the word, low RBITS bits select the
    // READ_WIDTH-bit group within the word (LSB-first)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r_data <= {READ_WIDTH{1'b0}};
        else r_data <= mem[r_addr[RADDR-1:RBITS]][r_addr[RBITS-1:0]*READ_WIDTH +: READ_WIDTH];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) r_data_valid <= 1'b0;
        else        r_data_valid <= r_en;
    end

endmodule
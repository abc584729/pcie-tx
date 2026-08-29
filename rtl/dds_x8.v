`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/29 17:42:25
// Design Name: 
// Module Name: dds_x8
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


module dds_x8(
      input clk, rst_n,
      input [15:0] pinc,
      input [127:0] poff,
      output [127:0] dds_i,
      output [127:0] dds_q
    );

    wire [31:0] dout_0, dout_1, dout_2, dout_3;
    wire [31:0] dout_4, dout_5, dout_6, dout_7;

    dds_compiler_0 dds_0(
      .aclk(clk),                                 // input wire aclk
      .aresetn(rst_n),                            // input wire aresetn
      .s_axis_phase_tvalid(1'b1),                 // input wire s_axis_phase_tvalid
      .s_axis_phase_tdata({poff[15:0], pinc}),    // input wire [31 : 0] s_axis_phase_tdata
      .m_axis_data_tvalid(),                      // output wire m_axis_data_tvalid
      .m_axis_data_tdata(dout_0)                  // output wire [31 : 0] m_axis_data_tdata
      );

    dds_compiler_0 dds_1(
      .aclk(clk),
      .aresetn(rst_n),
      .s_axis_phase_tvalid(1'b1),
      .s_axis_phase_tdata({poff[31:16], pinc}),
      .m_axis_data_tvalid(),
      .m_axis_data_tdata(dout_1)
      );

    dds_compiler_0 dds_2(
      .aclk(clk),
      .aresetn(rst_n),
      .s_axis_phase_tvalid(1'b1),
      .s_axis_phase_tdata({poff[47:32], pinc}),
      .m_axis_data_tvalid(),
      .m_axis_data_tdata(dout_2)
      );

    dds_compiler_0 dds_3(
      .aclk(clk),
      .aresetn(rst_n),
      .s_axis_phase_tvalid(1'b1),
      .s_axis_phase_tdata({poff[63:48], pinc}),
      .m_axis_data_tvalid(),
      .m_axis_data_tdata(dout_3)
      );

    dds_compiler_0 dds_4(
      .aclk(clk),
      .aresetn(rst_n),
      .s_axis_phase_tvalid(1'b1),
      .s_axis_phase_tdata({poff[79:64], pinc}),
      .m_axis_data_tvalid(),
      .m_axis_data_tdata(dout_4)
      );

    dds_compiler_0 dds_5(
      .aclk(clk),
      .aresetn(rst_n),
      .s_axis_phase_tvalid(1'b1),
      .s_axis_phase_tdata({poff[95:80], pinc}),
      .m_axis_data_tvalid(),
      .m_axis_data_tdata(dout_5)
      );

    dds_compiler_0 dds_6(
      .aclk(clk),
      .aresetn(rst_n),
      .s_axis_phase_tvalid(1'b1),
      .s_axis_phase_tdata({poff[111:96], pinc}),
      .m_axis_data_tvalid(),
      .m_axis_data_tdata(dout_6)
      );

    dds_compiler_0 dds_7(
      .aclk(clk),
      .aresetn(rst_n),
      .s_axis_phase_tvalid(1'b1),
      .s_axis_phase_tdata({poff[127:112], pinc}),
      .m_axis_data_tvalid(),
      .m_axis_data_tdata(dout_7)
      );

    assign dds_i[15:0]    = dout_0[15:0];
    assign dds_q[15:0]    = dout_0[31:16];
    assign dds_i[31:16]   = dout_1[15:0];
    assign dds_q[31:16]   = dout_1[31:16];
    assign dds_i[47:32]   = dout_2[15:0];
    assign dds_q[47:32]   = dout_2[31:16];
    assign dds_i[63:48]   = dout_3[15:0];
    assign dds_q[63:48]   = dout_3[31:16];
    assign dds_i[79:64]   = dout_4[15:0];
    assign dds_q[79:64]   = dout_4[31:16];
    assign dds_i[95:80]   = dout_5[15:0];
    assign dds_q[95:80]   = dout_5[31:16];
    assign dds_i[111:96]  = dout_6[15:0];
    assign dds_q[111:96]  = dout_6[31:16];
    assign dds_i[127:112] = dout_7[15:0];
    assign dds_q[127:112] = dout_7[31:16];

endmodule

`timescale 1 ns / 1 ns
// -------------------------------------------------------------
// Module: anti_imaging_filter_8_par_iq
//
// I/Q dual-lane wrapper around anti_imaging_filter_8_par. Two
// identical lanes share clk / clk_enable / reset, so their
// pipeline latencies are equal. Ready for QPSK: filter_in_i /
// filter_in_q carry the shaped I and Q branches independently.
//
// Ports match the single-lane module conventions: filter_in_i /
// filter_in_q are sfix16_En15, 1 sample per clock; filter_out_i /
// filter_out_q are 8 x sfix16_En15 (see anti_imaging_filter_8_par.v
// for the bus mapping and timing conventions). ce_out = clk_enable
// & ce_pipe[3]: one pulse per 8-sample output group after the
// 4-clock pipeline fill, aligned with filter_out_i / filter_out_q.
// -------------------------------------------------------------
module anti_imaging_filter_8_par_iq (
  clk,
  clk_enable,
  reset,
  filter_in_i,
  filter_in_q,
  filter_out_i,
  filter_out_q,
  ce_out
);

  input   clk;
  input   clk_enable;
  input   reset;
  input   signed [15:0]  filter_in_i;   // sfix16_En15
  input   signed [15:0]  filter_in_q;   // sfix16_En15
  output  signed [127:0] filter_out_i;  // 8 x sfix16_En15
  output  signed [127:0] filter_out_q;  // 8 x sfix16_En15
  output  ce_out;

  anti_imaging_filter_8_par u_i (
    .clk        (clk),
    .clk_enable (clk_enable),
    .reset      (reset),
    .filter_in  (filter_in_i),
    .filter_out (filter_out_i),
    .ce_out     (ce_out)
  );

  anti_imaging_filter_8_par u_q (
    .clk        (clk),
    .clk_enable (clk_enable),
    .reset      (reset),
    .filter_in  (filter_in_q),
    .filter_out (filter_out_q)
  );

endmodule  // anti_imaging_filter_8_par_iq

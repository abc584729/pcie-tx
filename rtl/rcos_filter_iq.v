`timescale 1 ns / 1 ns
// -------------------------------------------------------------
// Module: rcos_filter_iq
//
// I/Q dual-lane wrapper around rcos_filter. Two identical lanes
// share clk / clk_enable / reset, so their pipeline latencies are
// equal and filter_out_valid of both lanes coincides; the wrapper
// outputs the I lane's valid (the Q lane's valid is identical and
// left unconnected).
//
// Ports: filter_in_i / filter_in_q are sfix16_En15, 1 sample per
// clk_enable event; filter_out_i / filter_out_q are sfix16_En14
// (see rcos_filter.v). filter_out_valid pulses once per clk_enable
// after the 65-event pipeline fill, aligned with filter_out
// (filter_out_valid = clk_enable & ce_delay[64]).
// -------------------------------------------------------------
module rcos_filter_iq (
  clk,
  clk_enable,
  reset,
  filter_in_i,
  filter_in_q,
  filter_out_i,
  filter_out_q,
  filter_out_valid
);

  input   clk;
  input   clk_enable;
  input   reset;
  input   signed [15:0]  filter_in_i;   // sfix16_En15
  input   signed [15:0]  filter_in_q;   // sfix16_En15
  output  signed [15:0]  filter_out_i;  // sfix16_En14
  output  signed [15:0]  filter_out_q;  // sfix16_En14
  output  filter_out_valid;

  wire filter_out_valid_q;  // identical to the I lane, left open

  rcos_filter u_i (
    .clk              (clk),
    .clk_enable       (clk_enable),
    .reset            (reset),
    .filter_in        (filter_in_i),
    .filter_out       (filter_out_i),
    .filter_out_valid (filter_out_valid)
  );

  rcos_filter u_q (
    .clk              (clk),
    .clk_enable       (clk_enable),
    .reset            (reset),
    .filter_in        (filter_in_q),
    .filter_out       (filter_out_q),
    .filter_out_valid (filter_out_valid_q)
  );

endmodule  // rcos_filter_iq

`timescale 1ns/1ps
// rate_sel check for add.v.
//
// Both lanes of each of the 8 channels are loaded with the same test value
// (i1 = 0), so the 17-bit lane sum is just that value, and the two
// truncation schemes can be compared directly:
//   rate_sel = 0 :  {sum[14:0], 1'b0}  = sum[14:0] * 2
//   rate_sel = 1 :  sum[15:0]
// The whole point of the rate_sel=1 scheme is the case sum[15]=1: 32767
// comes out as 65534 (-2) under the old scheme and as 32767 under the new
// one, so that value is checked explicitly.
module tb_add_rate;
  reg clk = 0, rst_n = 0, rate_sel = 0;
  reg  signed [127:0] i0 = 0, q0 = 0, i1 = 0, q1 = 0;
  wire [255:0] iq;

  add u_add (
    .clk(clk), .rst_n(rst_n), .rate_sel(rate_sel),
    .i0(i0), .q0(q0), .i1(i1), .q1(q1), .iq(iq)
  );

  always #5 clk = ~clk;

  // iq is {q7,i7,q6,i6,...,q0,i0}; pull lane k's I and Q back out.
  function signed [15:0] lane_i;
    input integer k;
    input [255:0] v;
    begin
      lane_i = $signed(v[32*k +: 16]);
    end
  endfunction

  function signed [15:0] lane_q;
    input integer k;
    input [255:0] v;
    begin
      lane_q = $signed(v[32*k + 16 +: 16]);
    end
  endfunction

  // reference truncation, same expressions as the RTL
  function [15:0] ref0;
    input signed [16:0] s;
    begin
      ref0 = {s[14:0], 1'b0};
    end
  endfunction

  function [15:0] ref1;
    input signed [16:0] s;
    begin
      ref1 = s[15:0];
    end
  endfunction

  integer t, k, v;
  integer bad0, bad1;
  reg signed [16:0] sum;

  task drive;
    input signed [15:0] val;
    begin
      for (k = 0; k < 8; k = k + 1) begin
        i0[16*k +: 16] = val;
        q0[16*k +: 16] = val;
      end
      i1 = 0; q1 = 0;
    end
  endtask

  initial begin
    rst_n = 0; repeat (4) @(posedge clk); @(negedge clk) rst_n = 1;

    bad0 = 0; bad1 = 0;

    // boundary-ish set: the two extremes, the sign boundaries, and a few
    // values with sum[15]=1 that the old scheme mangles.
    for (t = -8; t < 8; t = t + 1) begin
      case (t)
        0: v = 0;
        1: v = 1;
        2: v = -1;
        3: v = 32767;      // max positive -> old scheme wraps
        4: v = -32768;     // min negative
        5: v = 16384;
        6: v = -16384;
        7: v = 12345;
        default: v = -12345;
      endcase
      sum = v;

      // ---- rate_sel = 0 ----
      rate_sel = 0; drive(v[15:0]);
      @(negedge clk); @(posedge clk); #1;
      for (k = 0; k < 8; k = k + 1) begin
        if (lane_i(k, iq) !== $signed(ref0(sum))) bad0 = bad0 + 1;
        if (lane_q(k, iq) !== $signed(ref0(sum))) bad0 = bad0 + 1;
      end
      if (v == 32767)
        $display("  sum=%0d (0x%04h) rate_sel=0 -> %0d", v, v[15:0], lane_i(0, iq));

      // ---- rate_sel = 1 ----
      rate_sel = 1; drive(v[15:0]);
      @(negedge clk); @(posedge clk); #1;
      for (k = 0; k < 8; k = k + 1) begin
        if (lane_i(k, iq) !== $signed(ref1(sum))) bad1 = bad1 + 1;
        if (lane_q(k, iq) !== $signed(ref1(sum))) bad1 = bad1 + 1;
      end
      if (v == 32767)
        $display("  sum=%0d (0x%04h) rate_sel=1 -> %0d", v, v[15:0], lane_i(0, iq));
    end

    $display("rate_sel=0 mismatches: %0d  (16 lanes x 16 vectors)", bad0);
    $display("rate_sel=1 mismatches: %0d", bad1);
    $display("DONE");
    $finish;
  end
endmodule

`timescale 1ns/1ps
// Bit-exact check of rtl/downsample_45m.v against the MATLAB-generated
// serial cascade matlab/downsampling/hdlsrc/d_8/d_8.v -> .../d_4/d_4.v.
//
// Rate mapping (this is what makes the two comparable):
//   serial   : d_8 consumes 1 input sample per clk_enable and emits 1
//              output per 8 clk_enable events (it time-multiplexes the 8
//              polyphase branches on one clock).  clk_enable ticks EVERY
//              clk, so it eats 1 sample/clk = 1.44 GSPS / 8 and emits
//              1 output per 8 clks.
//   parallel : consumes 8 samples per din_valid, so din_valid ticks once
//              every 8 clks to match -- 1 sample/clk, 1 output per
//              din_valid = 1 output per 8 clks.
// Both then consume one input sample and emit one 180 MSPS output sample
// per clk, and the two output streams line up sample for sample.
//
// The divide-by-4 stage is external in both: the DUT has an internal 1-in-4
// counter on din_valid, the golden gets 1-in-4 counter on d_8's ce_out.
//
// Stimulus: +mode=0 noise (default) / 1 impulse / 2 ramp / 3 chirp,
// matching the {'step','ramp','chirp','noise'} set the MATLAB testbench uses.
// Dumps dut.txt and ser.txt, one "<i> <q>" line per output sample.
module tb_downsample_45m;
  localparam G = 256;              // input groups (8 IQ pairs each)
  localparam N = 8*G;              // input IQ pairs
  localparam T = N + 512;          // clks: 1 sample/clk for the golden, plus drain

  reg clk = 0;
  reg rst_n = 0;

  reg  [255:0] din_iq = 0;
  reg          din_valid = 0;
  wire [31:0]  dout_iq;
  wire         dout_valid;

  // ---- golden: serial d_8 (I/Q) -> d_4 (I/Q) -------------------------
  reg  ce8_en = 0;                 // d_8 clk_enable, every clk
  reg  signed [15:0] g_in_i = 0;
  reg  signed [15:0] g_in_q = 0;
  wire signed [15:0] g8_i, g8_q;
  wire g8_ce;
  wire signed [15:0] g4_i, g4_q;
  wire g4_en;

  reg  [1:0] g_cnt = 0;            // counts d_8 outputs, pulses on the 4th
  assign g4_en = g8_ce & (g_cnt == 2'd3);

  wire reset = ~rst_n;

  reg signed [15:0] si [0:N-1];
  reg signed [15:0] sq [0:N-1];

  localparam SMAX = 8192;          // collected output samples per stream

  reg signed [15:0] di [0:SMAX-1]; // DUT captured outputs
  reg signed [15:0] dq [0:SMAX-1];
  reg signed [15:0] si_o [0:SMAX-1]; // golden captured outputs
  reg signed [15:0] sq_o [0:SMAX-1];

  integer t, k, g, mode, hold;
  integer fdut, fser;
  integer ndut = 0, nser = 0;
  integer mism = 0, ncmp = 0, du = 0, su = 0;

  // strobe periodicity: din_valid pulses between two dout_valid pulses
  integer dv_gap = 0;
  integer gap_bad = 0;
  integer dv_seen = 0;
  integer dv_last_t = 0;         // clk of the last strobe
  integer dv_stuck = 0;          // +hold=1 and dout_valid still high at the end

  downsample_45m u_dut (
    .clk(clk), .rst_n(rst_n),
    .din_iq(din_iq), .din_valid(din_valid),
    .dout_iq(dout_iq), .dout_valid(dout_valid)
  );

  d_8 u_g8_i (
    .clk(clk), .clk_enable(ce8_en), .reset(reset),
    .filter_in(g_in_i), .filter_out(g8_i), .ce_out(g8_ce)
  );
  d_8 u_g8_q (
    .clk(clk), .clk_enable(ce8_en), .reset(reset),
    .filter_in(g_in_q), .filter_out(g8_q), .ce_out()
  );
  d_4 u_g4_i (
    .clk(clk), .clk_enable(g4_en), .reset(reset),
    .filter_in(g8_i), .filter_out(g4_i)
  );
  d_4 u_g4_q (
    .clk(clk), .clk_enable(g4_en), .reset(reset),
    .filter_in(g8_q), .filter_out(g4_q)
  );

  always #5 clk = ~clk;

  always @(posedge clk or posedge reset) begin
    if (reset) g_cnt <= 2'd0;
    else if (g8_ce) g_cnt <= g_cnt + 2'd1;
  end

  initial begin
    if (!$value$plusargs("mode=%d", mode)) mode = 0;
    // +hold=1 stops din_valid after the last stimulus group, so the tail of
    // the run is silence: dout_valid must go low on its own instead of
    // holding the last sample forever.
    if (!$value$plusargs("hold=%d", hold)) hold = 0;

    for (k = 0; k < N; k = k + 1) begin
      case (mode)
        1: begin si[k] = (k == 3) ? 16'sd16384 : 16'sd0;
                 sq[k] = (k == 11) ? -16'sd16384 : 16'sd0; end
        2: begin si[k] = (k * 32) - 32768;
                 sq[k] = 32767 - (k * 32); end
        3: begin si[k] = $rtoi($cos(2.0*3.14159265358979*0.017*k) * 20000.0);
                 sq[k] = $rtoi($sin(2.0*3.14159265358979*0.017*k) * 20000.0); end
        default: begin si[k] = $random; sq[k] = $random; end
      endcase
    end

    fdut = $fopen("dut.txt", "w");
    fser = $fopen("ser.txt", "w");

    din_valid = 0; ce8_en = 0;
    repeat (4) @(posedge clk);
    @(negedge clk) rst_n = 1;

    for (t = 0; t < T; t = t + 1) begin
      @(negedge clk);
      ce8_en  = 1'b1;
      g_in_i  = (t < N) ? si[t] : 16'sd0;
      g_in_q  = (t < N) ? sq[t] : 16'sd0;
      // din_valid ticks every 8 clks for the whole run; group g carries
      // si[8g .. 8g+7], and groups past the stimulus are all zero.  Both
      // sides then keep draining with zeros and finish together.
      din_valid = (t % 8 == 0) && (!hold || (t < N));
      g = t / 8;
      if (t < N) begin
        din_iq = {
          sq[8*g+7], si[8*g+7], sq[8*g+6], si[8*g+6],
          sq[8*g+5], si[8*g+5], sq[8*g+4], si[8*g+4],
          sq[8*g+3], si[8*g+3], sq[8*g+2], si[8*g+2],
          sq[8*g+1], si[8*g+1], sq[8*g+0], si[8*g+0]
        };
      end
      else begin
        din_iq = 256'd0;
      end
      @(posedge clk);
      #1;
      if (din_valid && !dout_valid) dv_gap = dv_gap + 1;
      // & din_valid: the DUT's whole chain is gated by din_valid, so its
      // registers only move on a din_valid clock and dout_valid stays high
      // for the 8 clocks that follow (in hardware din_valid is 1 every clk,
      // so dout_valid is already one clk wide and this is a no-op).
      if (dout_valid && din_valid) begin
        // dout_valid must be strictly 1 in 4 din_valid periods, with no
        // gaps: exactly 3 non-strobe din_valid periods may sit between two
        // strobes, so dv_gap has to read 3 here.
        if (dv_seen > 0 && dv_gap != 3) gap_bad = gap_bad + 1;
        dv_gap    = 0;
        dv_seen   = dv_seen + 1;
        dv_last_t = t;
        // $signed() on each part-select: a plain part-select is unsigned,
        // so a negative lane would otherwise print as 65536+v.
        $fwrite(fdut, "%0d %0d\n", $signed(dout_iq[15:0]), $signed(dout_iq[31:16]));
        if (ndut < SMAX) begin
          di[ndut] = $signed(dout_iq[15:0]);
          dq[ndut] = $signed(dout_iq[31:16]);
        end
        ndut = ndut + 1;
      end
      if (g4_en) begin
        $fwrite(fser, "%0d %0d\n", g4_i, g4_q);
        if (nser < SMAX) begin
          si_o[nser] = g4_i;
          sq_o[nser] = g4_q;
        end
        nser = nser + 1;
      end
    end

    $fclose(fdut);
    $fclose(fser);

    // ---- compare -----------------------------------------------------
    // The golden's d_4 is dumped on every clk_enable, so it also records
    // its 10-enable pipeline fill (all zeros) before the first real sample;
    // the DUT only strobes when its own d_4 has real data, so it has no
    // such prefix.  Skip the leading zeros on both sides, then the two
    // streams must agree sample for sample with no offset at all.
    du = 0; su = 0;
    while (du < ndut && di[du] == 0 && dq[du] == 0) du = du + 1;
    while (su < nser && si_o[su] == 0 && sq_o[su] == 0) su = su + 1;

    ncmp = (ndut - du) < (nser - su) ? (ndut - du) : (nser - su);
    mism = 0;
    for (k = 0; k < ncmp; k = k + 1) begin
      if (di[du+k] !== si_o[su+k] || dq[du+k] !== sq_o[su+k]) begin
        if (mism < 5)
          $display("  MISMATCH #%0d: dut=(%0d,%0d) ser=(%0d,%0d)",
                   k, di[du+k], dq[du+k], si_o[su+k], sq_o[su+k]);
        mism = mism + 1;
      end
    end

    // With +hold=1 the input stream stopped at t=N; the last strobe must be
    // behind us and dout_valid must be sitting low by the end of the run.
    if (hold && (dout_valid !== 1'b0 || dv_seen == 0)) dv_stuck = 1;

    $display("mode=%0d%s  dut=%0d (skipped %0d)  ser=%0d (skipped %0d)  compared=%0d  mismatches=%0d",
             mode, hold ? " hold" : "    ", ndut, du, nser, su, ncmp, mism);
    $display("        dout_valid strobes=%0d  bad spacing=%0d  last strobe at clk %0d of %0d",
             dv_seen, gap_bad, dv_last_t, T);
    if (hold) $display("        after input stop: dout_valid=%b  (must be 0)", dout_valid);
    if (mism == 0 && ncmp > 0 && gap_bad == 0 && dv_stuck == 0) $display("PASS");
    else                                                        $display("FAIL");
    $finish;
  end
endmodule

`timescale 1 ns / 1 ns
// -------------------------------------------------------------
// Testbench: tb_filter8_par_matlab
//
// MATLAB golden-data playback for anti_imaging_filter_8_par.
//
// Stimulus / expected data are extracted from the HDL Coder generated
// testbench (hdlsrc/anti_imaging_filter_8/filter_tb.v) by
// extract_matlab_data.py into:
//   data/filter_in_stim.hex        (3172 input samples)
//   data/filter_out_expected.hex   (25376 = 8*3172 expected outputs)
//
// The generated testbench drives one input sample per 8 clocks and
// compares the serial output stream against filter_out_expected once
// per clock with tolerance |actual - expected| <= 15 LSB. Because the
// parallel filter is bit-exact to the serial one, replaying the same
// stimulus at 1 sample/clock must reproduce that stream (expected[8n+p]
// = phase p+1 output for input sample n), so errors should be 0.
//
// Run from rtl/tb (hex paths are relative):
//   iverilog -g2001 -o <out> ../anti_imaging_filter_8_par.v \
//            tb_filter8_par_matlab.v && vvp <out>
// -------------------------------------------------------------
module tb_filter8_par_matlab;

  localparam N_IN = 3172;

  reg signed [15:0] stim  [0:N_IN-1];
  reg signed [15:0] expct [0:8*N_IN-1];
  initial begin
    $readmemh("data/filter_in_stim.hex", stim);
    $readmemh("data/filter_out_expected.hex", expct);
  end

  // ---------------- clock / control ----------------
  reg clk = 1'b0;
  always #5 clk = ~clk;                    // 10 ns, 180 MHz domain
  reg reset = 1'b1;
  reg clk_enable = 1'b0;

  initial begin
    repeat (4) @(posedge clk);
    #1 reset = 1'b0;
    #1 clk_enable = 1'b1;
  end

  // ---------------- DUT ----------------
  reg signed [15:0] filter_in = 16'sd0;
  wire signed [127:0] filter_out;
  wire ce_out;

  anti_imaging_filter_8_par u_dut (
    .clk        (clk),
    .clk_enable (clk_enable),
    .reset      (reset),
    .filter_in  (filter_in),
    .filter_out (filter_out),
    .ce_out     (ce_out)
  );

  // ---------------- stimulus ----------------
  integer n_in = 0;
  always @(negedge clk) begin
    if (!reset && clk_enable) begin
      filter_in <= (n_in < N_IN) ? stim[n_in] : 16'sd0;
      n_in <= n_in + 1;
    end
  end

  // ---------------- capture & compare ----------------
  integer g = 0;      // output group index (input sample index)
  integer errs = 0;
  integer maxerr = 0;
  integer p;
  reg signed [15:0] got, want;
  integer diff;

  always @(negedge clk) begin
    if (!reset && clk_enable && ce_out && g < N_IN) begin
      for (p = 0; p < 8; p = p + 1) begin
        got = filter_out[16*p +: 16];
        want = expct[8*g + p];
        diff = got - want;
        if (diff < 0) diff = -diff;
        if (diff > maxerr) maxerr = diff;
        if (diff > 15) begin
          errs = errs + 1;
          if (errs <= 20)
            $display("MISMATCH sample %0d phase %0d : got=%h want=%h diff=%0d",
                     g, p, got, want, diff);
        end
      end
      g = g + 1;
      if (g == N_IN) begin
        $display("----------------------------------------------");
        $display("MATLAB playback : samples=%0d outputs=%0d", N_IN, 8*N_IN);
        $display("  errors (>15 LSB) : %0d", errs);
        $display("  max error (LSB)  : %0d", maxerr);
        if (errs == 0)
          $display("************** TEST COMPLETED (PASSED) **************");
        else
          $display("************** TEST COMPLETED (FAILED) **************");
        $finish;
      end
    end
  end

  initial begin // timeout guard
    #1000000;
    $display("TIMEOUT: groups compared=%0d", g);
    $finish;
  end

endmodule // tb_filter8_par_matlab
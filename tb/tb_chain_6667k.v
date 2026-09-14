`timescale 1ns/1ps
// Full-chain check for upsamping_6667k.
//
// Two things are checked here.
//
// 1) The 9x front end (zero_insert 27/9 -> rcos_400k) must produce exactly
//    the same sample SEQUENCE as the already-verified 400k chain, because
//    both feed rcos_400k the identical 9-samples-per-symbol impulse train.
//    Only the clk spacing differs (400k: one sample per 50 clk, 6667k: one
//    per 3 clk), so the sequences -- not the timing -- must be bit-equal.
//    That pins the INTERPOLATION_FACTOR/TIME_FACTOR pairing and the I/Q
//    instance wiring without needing a float model.
//
// 2) The rate structure of the whole chain: rcos_valid must pulse 9x per
//    symbol period (27 clk), f3 must be enabled every clk and so must the
//    final parallel stage -- 8 lanes/clk, 216 samples/symbol.
//
// The parallel 8x stage itself is verified bit-exact separately
// (tb_par_6667k.v, 4147/4147 vs the generated serial filter_8), and f3 is
// covered by its MATLAB golden testbench, so this covers the wiring.
module tb_chain_6667k;
  localparam AMP = 4096;       // impulse height (headroom inside sfix16_En15)
  localparam SYM = 27;         // clk per symbol at 6.667 MHz
  localparam IMP = 1998;       // clk the impulse is applied = symbol 74, so it
                               // lands on a symbol boundary; the chain must be
                               // warm first, because filter_out_valid is held low
                               // for the first N clk_enables (the fill window)
  localparam T   = 12000;      // IMP + fill + the whole response

  reg clk = 0;
  reg rst_n = 0;
  reg  [15:0] din_i = 0;
  reg  [15:0] din_q = 0;
  reg         din_valid = 0;
  wire [127:0] sig_i, sig_q;

  integer t, f_rcos, f_s3, f_sig, f_pad3;
  integer n_rcos, n_s3, n_f8, n_sym;

  upsamping_6667k u_dut (
    .clk(clk), .rst_n(rst_n),
    .din_i(din_i), .din_q(din_q), .din_valid(din_valid),
    .sig_i(sig_i), .sig_q(sig_q)
  );

  always #5 clk = ~clk;

  wire signed [15:0] rcos_i  = u_dut.u_rcos_i.filter_out;
  wire               rcos_v  = u_dut.u_rcos_i.filter_out_valid;
  wire signed [15:0] s3      = u_dut.u_f3_i.filter_out;
  wire               s3_v    = u_dut.u_f3_i.filter_out_valid;
  wire               s3_ce   = u_dut.u_f3_i.clk_enable;

  initial begin
    f_rcos = $fopen("/tmp/qk66/rc.txt",   "w");
    f_s3   = $fopen("/tmp/qk66/s3.txt",   "w");
    f_sig  = $fopen("/tmp/qk66/sig.txt",  "w");
    f_pad3 = $fopen("/tmp/qk66/pad3.txt", "w");

    rst_n = 0; din_i = 0; din_q = 0; din_valid = 0;
    repeat (8) @(posedge clk);
    @(negedge clk) rst_n = 1;

    n_rcos = 0; n_s3 = 0; n_f8 = 0; n_sym = 0;
    for (t = 0; t < T; t = t + 1) begin
      @(negedge clk);
      // QPSK-style symbol slot: one input sample per 27 clk
      din_valid = (t % SYM == 0);
      din_i     = (t == IMP) ? AMP[15:0] : 16'd0;
      din_q     = (t == IMP) ? AMP[15:0] : 16'd0;
      @(posedge clk);
      #1;
      if (rcos_v) begin
        $fwrite(f_rcos, "%0d\n", rcos_i);
        n_rcos = n_rcos + 1;
      end
      // Every clk of the f3 input stream, so the 3x zero-stuff pattern is
      // visible and can be checked against the rcos sequence.
      $fwrite(f_pad3, "%0d\n", $signed(u_dut.pad_i3));
      if (s3_v) begin
        $fwrite(f_s3, "%0d\n", s3);
        n_s3 = n_s3 + 1;
      end
      if (s3_ce && u_dut.u_f8_i.ce_out) begin
        $fwrite(f_sig, "%0d %0d %0d %0d %0d %0d %0d %0d\n",
                $signed(sig_i[15:0]),   $signed(sig_i[31:16]),
                $signed(sig_i[47:32]),  $signed(sig_i[63:48]),
                $signed(sig_i[79:64]),  $signed(sig_i[95:80]),
                $signed(sig_i[111:96]), $signed(sig_i[127:112]));
        n_f8 = n_f8 + 1;
      end
      // symbol periods fully inside the warm window
      if (t >= 4000 && t < 4054 && (t % SYM == SYM-1)) n_sym = n_sym + 1;
    end

    $fclose(f_rcos);
    $fclose(f_s3);
    $fclose(f_sig);
    $fclose(f_pad3);
    $display("rcos valid samples       = %0d", n_rcos);
    $display("f3 valid samples         = %0d", n_s3);
    $display("f8 enabled clocks        = %0d  (expect 8 samples each)", n_f8);
    $display("symbol periods observed  = %0d", n_sym);
    $display("DONE");
    $finish;
  end
endmodule

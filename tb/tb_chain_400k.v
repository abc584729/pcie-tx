`timescale 1ns/1ps
// Full-chain check for upsamping_400k.
//
// Drives a single impulse into the chain and records the s10 stream (the
// input of the final 8x parallel stage) at every clock the f10 stage
// declares valid.  A Python model of {9x zero insert -> rcos_400k ->
// 5x -> f5 -> 10x -> f10} is compared against it, which pins down the
// coefficient order, the per-stage scaling and the 450-clock symbol rate
// in one shot.  The final parallel stage is verified separately
// (tb_par_400k.v), so verifying up to s10 covers the whole chain.
module tb_chain_400k;
  localparam AMP = 4096;          // impulse height (headroom inside sfix16_En15)
  localparam IMP = 5000;          // clk the impulse is applied: the chain must be
                                  // warm first, because filter_out_valid is held low
                                  // for the first N clk_enables (the fill window) and
                                  // an impulse landing there is dropped downstream.
  localparam T   = 14000;         // IMP + fill + the whole 4205-sample response
                                  // (73 enables x 50 clk for rcos_400k) plus the
                                  // full 4205-sample impulse response

  reg clk = 0;
  reg rst_n = 0;
  reg  [15:0] din = 0;
  reg         din_valid = 0;
  wire [127:0] sig;

  integer t, f;
  integer nvalid;

  upsamping_400k u_dut (
    .clk(clk), .rst_n(rst_n), .din(din), .din_valid(din_valid), .sig(sig)
  );

  always #5 clk = ~clk;

  // s10 at the f10 valid positions == exactly what the last stage consumes
  wire s10_valid = u_dut.u_f10.filter_out_valid;
  wire signed [15:0] s10 = u_dut.u_f10.filter_out;

  initial begin
    f = $fopen("chain400k.txt", "w");

    rst_n = 0; din = 0; din_valid = 0;
    repeat (8) @(posedge clk);
    @(negedge clk) rst_n = 1;

    nvalid = 0;
    for (t = 0; t < T; t = t + 1) begin
      @(negedge clk);
      din_valid = (t == IMP);
      din       = (t == IMP) ? AMP[15:0] : 16'd0;
      @(posedge clk);
      #1;
      if (s10_valid) $fwrite(f, "%0d\n", s10);
      // Count valid events over clocks 900..1799 (two symbol periods) so the
      // chain is well past its fill window.
      if (t >= 4000 && t < 4900 && s10_valid) nvalid = nvalid + 1;
    end

    $fclose(f);
    $display("s10 valids in 900 clks (clk 4000..4899) = %0d  (expect 900)", nvalid);
    $display("DONE");
    $finish;
  end
endmodule

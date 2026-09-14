`timescale 1ns/1ps
// Reference dump for the shared 9x front end.
//
// upsamping_400k and upsamping_6667k both start with
//     zero_interpolator(9x) -> rcos_400k
// and both are fed the same 9-samples-per-symbol pattern (one symbol, then
// 8 zeros) -- only the clk spacing differs (450 clk/symbol vs 27).  So the
// rcos output SEQUENCE must be identical between the two chains, and the
// 6667k one (tb_chain_6667k.v -> /tmp/qk66/rc.txt) can be checked against
// this one bit-for-bit.  That validates the TIME_FACTOR/INTERPOLATION_FACTOR
// pairing (450/9 -> 50 vs 27/9 -> 3) and the per-lane rcos instantiation.
module tb_rcos_ref_400k;
  localparam AMP = 4096;
  localparam SYM = 450;        // clk per symbol at 400 kHz
  localparam IMP = 4500;       // symbol 10
  localparam T   = 16000;

  reg clk = 0;
  reg rst_n = 0;
  reg  [15:0] din = 0;
  reg         din_valid = 0;
  wire [127:0] sig;

  integer t, f_rcos;

  upsamping_400k u_dut (
    .clk(clk), .rst_n(rst_n), .din(din), .din_valid(din_valid), .sig(sig)
  );

  always #5 clk = ~clk;

  wire signed [15:0] rcos_s = u_dut.u_rcos_filter.filter_out;
  wire               rcos_v = u_dut.u_rcos_filter.filter_out_valid;

  initial begin
    f_rcos = $fopen("/tmp/qk66/rc400k.txt", "w");

    rst_n = 0; din = 0; din_valid = 0;
    repeat (8) @(posedge clk);
    @(negedge clk) rst_n = 1;

    for (t = 0; t < T; t = t + 1) begin
      @(negedge clk);
      din_valid = (t % SYM == 0);
      din       = (t == IMP) ? AMP[15:0] : 16'd0;
      @(posedge clk);
      #1;
      if (rcos_v) $fwrite(f_rcos, "%0d\n", rcos_s);
    end

    $fclose(f_rcos);
    $display("DONE");
    $finish;
  end
endmodule

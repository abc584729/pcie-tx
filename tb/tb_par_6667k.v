`timescale 1ns/1ps
// Compare the hand-written parallel 8x filter against the MATLAB-generated
// serial one, sample by sample, on the same stimulus.
//
// Rate mapping (this is what makes the two comparable):
//   serial   : consumes 1 input sample per 8 clk_enable events and emits
//              1 output sample per clk_enable (it time-multiplexes the 8
//              phases on one clock).  clk_enable ticks EVERY clk.
//   parallel : consumes 1 input sample per clk_enable and emits all 8
//              lanes per clk_enable.  The parallel form is the serial form
//              with the 8x phase clock folded away, so its clk_enable
//              ticks once every 8 clks to match the serial input rate.
// Both then consume one input sample and emit 8 output samples per 8 clks,
// and the two output streams can be aligned by a constant offset.
module tb_par_6667k;
  localparam N = 512;              // input samples
  localparam T = 8*N + 64;         // clk_enable events (drain tail included)

  reg clk = 0;
  reg reset = 1;
  reg ce_ser_en = 0;
  reg ce_par_en = 0;
  reg  signed [15:0]  sin_ser = 0;
  reg  signed [15:0]  sin_par = 0;
  wire signed [15:0]  dout_ser;
  wire signed [127:0] dout_par;
  wire ce_ser, ce_par;

  reg signed [15:0] sample [0:N-1];

  integer t, j;
  integer fser, fpar;

  anti_imaging_8_6667k u_ser (
    .clk(clk), .clk_enable(ce_ser_en), .reset(reset),
    .filter_in(sin_ser), .filter_out(dout_ser), .ce_out(ce_ser)
  );

  anti_imaging_8_par_6667k u_par (
    .clk(clk), .clk_enable(ce_par_en), .reset(reset),
    .filter_in(sin_par), .filter_out(dout_par), .ce_out(ce_par)
  );

  always #5 clk = ~clk;

  initial begin
    for (j = 0; j < N; j = j + 1) sample[j] = $random;

    fser = $fopen("/tmp/qk66/ser.txt", "w");
    fpar = $fopen("/tmp/qk66/par.txt", "w");

    reset = 1; ce_ser_en = 0; ce_par_en = 0;
    repeat (4) @(posedge clk);
    @(negedge clk) reset = 0;

    for (t = 0; t < T; t = t + 1) begin
      @(negedge clk);
      ce_ser_en = 1'b1;
      ce_par_en = (t % 8 == 0);
      sin_ser   = ((t/8) < N) ? sample[t/8] : 16'sd0;
      sin_par   = sin_ser;
      @(posedge clk);
      #1;
      $fwrite(fser, "%0d\n", dout_ser);
      if (t % 8 == 0)
        // $signed() on each part-select: a plain part-select is unsigned,
        // so negative lanes would otherwise print as 65536+v.
        $fwrite(fpar, "%0d %0d %0d %0d %0d %0d %0d %0d\n",
                $signed(dout_par[15:0]),   $signed(dout_par[31:16]),
                $signed(dout_par[47:32]),  $signed(dout_par[63:48]),
                $signed(dout_par[79:64]),  $signed(dout_par[95:80]),
                $signed(dout_par[111:96]), $signed(dout_par[127:112]));
    end

    $fclose(fser);
    $fclose(fpar);
    $display("DONE");
    $finish;
  end
endmodule

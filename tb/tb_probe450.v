`timescale 1ns/1ps
// Probe every stage of upsamping_450k with a single impulse.
module tb_probe450;
  localparam AMP = 4096;
  localparam T   = 900;

  reg clk = 0;
  reg rst_n = 0;
  reg  [15:0] din = 0;
  reg         din_valid = 0;
  wire [127:0] sig;

  integer t, f;

  upsamping_450k u (
    .clk(clk), .rst_n(rst_n), .din(din), .din_valid(din_valid), .sig(sig)
  );

  always #5 clk = ~clk;

  initial begin
    f = $fopen("probe450.txt", "w");
    rst_n = 0; din = 0; din_valid = 0;
    repeat (8) @(posedge clk);
    @(negedge clk) rst_n = 1;

    for (t = 0; t < T; t = t + 1) begin
      @(negedge clk);
      din_valid = (t == 0);
      din       = (t == 0) ? AMP[15:0] : 16'd0;
      @(posedge clk);
      #1;
      // t  dinv  pad8_v pad8   rcos   rcos_v  pad5   s5     s5_v   pad10  s10
      $fwrite(f, "%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",
              t, din_valid,
              u.u_zero_padding_8.y_valid, $signed(u.u_zero_padding_8.y),
              $signed(u.u_rcos_filter.filter_out), u.u_rcos_filter.filter_out_valid,
              $signed(u.u_zero_padding_5.y),
              $signed(u.u_f5.filter_out), u.u_f5.filter_out_valid,
              $signed(u.u_zero_padding_10.y),
              $signed(u.u_f10.filter_out));
    end
    $fclose(f);
    $display("DONE");
    $finish;
  end
endmodule

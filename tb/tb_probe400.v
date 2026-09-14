`timescale 1ns/1ps
// Locate the X in upsamping_400k by probing every stage plus the
// internals of the first FIR.
module tb_probe400;
  localparam AMP = 4096;
  localparam T   = 6000;

  reg clk = 0;
  reg rst_n = 0;
  reg  [15:0] din = 0;
  reg         din_valid = 0;
  wire [127:0] sig;

  integer t, f;

  upsamping_400k u (
    .clk(clk), .rst_n(rst_n), .din(din), .din_valid(din_valid), .sig(sig)
  );

  always #5 clk = ~clk;

  initial begin
    f = $fopen("probe400.txt", "w");
    rst_n = 0; din = 0; din_valid = 0;
    repeat (8) @(posedge clk);
    @(negedge clk) rst_n = 1;

    for (t = 0; t < T; t = t + 1) begin
      @(negedge clk);
      din_valid = (t == 0);
      din       = (t == 0) ? AMP[15:0] : 16'd0;
      @(posedge clk);
      #1;
      $fwrite(f, "%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",
        t,
        u.u_zero_padding_9.y_valid, $signed(u.u_zero_padding_9.y),
        u.u_rcos_filter.filter_out_valid,
        $signed(u.u_rcos_filter.filter_in),
        $signed(u.u_rcos_filter.delay_pipeline[0]),
        $signed(u.u_rcos_filter.delay_pipeline[1]),
        $signed(u.u_rcos_filter.product2_pipe),
        $signed(u.u_rcos_filter.sum_final),
        $signed(u.u_rcos_filter.output_typeconvert),
        $signed(u.u_rcos_filter.filter_out),
        $signed(u.u_f5.filter_out),
        $signed(u.u_zero_padding_5.y),
        $signed(u.u_f10.filter_out));
    end
    $fclose(f);
    $display("DONE");
    $finish;
  end
endmodule

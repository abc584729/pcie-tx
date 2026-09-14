`timescale 1ns/1ps
// Differential impulse test: same stimulus into upsamping_450k and
// upsamping_400k, dumping the f10 output stream of each.
module tb_chain_cmp;
  localparam AMP = 4096;
  localparam T   = 900;

  reg clk = 0;
  reg rst_n = 0;
  reg  [15:0] din = 0;
  reg         din_valid = 0;
  wire [127:0] sig450, sig400;

  integer t, f1, f2;

  upsamping_450k u450 (
    .clk(clk), .rst_n(rst_n), .din(din), .din_valid(din_valid), .sig(sig450)
  );
  upsamping_400k u400 (
    .clk(clk), .rst_n(rst_n), .din(din), .din_valid(din_valid), .sig(sig400)
  );

  always #5 clk = ~clk;

  initial begin
    f1 = $fopen("c450.txt", "w");
    f2 = $fopen("c400.txt", "w");
    rst_n = 0; din = 0; din_valid = 0;
    repeat (8) @(posedge clk);
    @(negedge clk) rst_n = 1;

    for (t = 0; t < T; t = t + 1) begin
      @(negedge clk);
      din_valid = (t == 0);
      din       = (t == 0) ? AMP[15:0] : 16'd0;
      @(posedge clk);
      #1;
      $fwrite(f1, "%0d\n", $signed(u450.u_f10.filter_out));
      $fwrite(f2, "%0d\n", $signed(u400.u_f10.filter_out));
    end
    $fclose(f1); $fclose(f2);
    $display("DONE");
    $finish;
  end
endmodule

`timescale 1ns/1ps
// Dump each 400k stage at its own valid, warm-chain impulse.
module tb_s3_400k;
  localparam AMP = 4096;
  localparam IMP = 5000;
  localparam T   = 14000;
  reg clk=0, rst_n=0; reg [15:0] din=0; reg din_valid=0;
  wire [127:0] sig;
  integer t, f1, f2;
  upsamping_400k u(.clk(clk),.rst_n(rst_n),.din(din),.din_valid(din_valid),.sig(sig));
  always #5 clk=~clk;
  wire rv = u.u_rcos_filter.filter_out_valid;
  wire f5v= u.u_f5.filter_out_valid;
  initial begin
    f1=$fopen("s_rcos.txt","w"); f2=$fopen("s_s5.txt","w");
    rst_n=0; din=0; din_valid=0;
    repeat(8) @(posedge clk);
    @(negedge clk) rst_n=1;
    for (t=0;t<T;t=t+1) begin
      @(negedge clk);
      din_valid=(t==IMP); din=(t==IMP)?AMP[15:0]:16'd0;
      @(posedge clk); #1;
      if (rv)  $fwrite(f1,"%0d\n", $signed(u.u_rcos_filter.filter_out));
      if (f5v) $fwrite(f2,"%0d\n", $signed(u.u_f5.filter_out));
    end
    $fclose(f1); $fclose(f2);
    $display("DONE"); $finish;
  end
endmodule

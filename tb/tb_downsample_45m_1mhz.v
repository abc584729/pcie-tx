`timescale 1ns/1ps

// Hardware-rate test for downsample_45m:
//   clk          = 180 MHz
//   input bus    = 8 consecutive samples/clk = 1.44 GSPS
//   input tone   = complex 1 MHz, I=cos and Q=sin
//   expected out = one valid sample per 4 clocks = 45 MSPS, still 1 MHz
module tb_downsample_45m_1mhz;
  localparam integer RUN_CLKS = 12000;
  localparam integer SETTLE_OUTPUTS = 128;
  localparam real ADC_FS_HZ = 1440000000.0;
  localparam real OUT_FS_HZ = 45000000.0;
  localparam real TONE_HZ = 1000000.0;
  localparam real PI = 3.14159265358979323846;

  reg clk = 1'b0;
  reg rst_n = 1'b0;
  reg [255:0] din_iq = 256'd0;
  reg din_valid = 1'b0;
  wire [31:0] dout_iq;
  wire dout_valid;

  integer clk_index;
  integer lane;
  integer sample_index;
  integer out_index = 0;
  integer valid_count = 0;
  integer last_valid_clk = -1;
  integer spacing_errors = 0;
  integer prev_i = 0;
  integer now_i;
  integer now_q;
  integer have_prev = 0;
  integer crossing_count = 0;
  integer first_crossing = -1;
  integer last_crossing = -1;
  integer min_i = 32767;
  integer max_i = -32768;
  real phase;
  real measured_hz;
  real frequency_error_hz;

  downsample_45m dut (
    .clk(clk),
    .rst_n(rst_n),
    .din_iq(din_iq),
    .din_valid(din_valid),
    .dout_iq(dout_iq),
    .dout_valid(dout_valid)
  );

  // 180 MHz clock: 5.555... ns period.
  always #2.777777778 clk = ~clk;

  initial begin
    repeat (6) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
    din_valid = 1'b1;

    for (clk_index = 0; clk_index < RUN_CLKS; clk_index = clk_index + 1) begin
      // Lane 0 is the earliest sample.  Each clock carries eight distinct
      // 1.44-GSPS samples, not eight copies of one 180-MSPS sample.
      for (lane = 0; lane < 8; lane = lane + 1) begin
        sample_index = 8*clk_index + lane;
        phase = 2.0*PI*TONE_HZ*sample_index/ADC_FS_HZ;
        din_iq[32*lane +: 16] = $rtoi(12000.0*$cos(phase));
        din_iq[32*lane+16 +: 16] = $rtoi(12000.0*$sin(phase));
      end

      @(posedge clk);
      #0.001;

      if (dout_valid) begin
        if (last_valid_clk >= 0 && clk_index-last_valid_clk != 4)
          spacing_errors = spacing_errors + 1;
        last_valid_clk = clk_index;
        valid_count = valid_count + 1;

        now_i = $signed(dout_iq[15:0]);
        now_q = $signed(dout_iq[31:16]);
        if (out_index >= SETTLE_OUTPUTS) begin
          if (now_i < min_i) min_i = now_i;
          if (now_i > max_i) max_i = now_i;
          if (have_prev && prev_i < 0 && now_i >= 0) begin
            crossing_count = crossing_count + 1;
            if (first_crossing < 0) first_crossing = out_index;
            last_crossing = out_index;
          end
          prev_i = now_i;
          have_prev = 1;
        end
        out_index = out_index + 1;
      end

      @(negedge clk);
    end

    din_valid = 1'b0;
    if (crossing_count > 1)
      measured_hz = OUT_FS_HZ*(crossing_count-1)/(last_crossing-first_crossing);
    else
      measured_hz = 0.0;
    frequency_error_hz = measured_hz-TONE_HZ;
    if (frequency_error_hz < 0.0) frequency_error_hz = -frequency_error_hz;

    $display("input:  1 MHz complex tone, 8 samples/clk, 1.44 GSPS");
    $display("output: valid=%0d, spacing_errors=%0d, I_range=[%0d,%0d]",
             valid_count, spacing_errors, min_i, max_i);
    $display("tone:   crossings=%0d, measured=%0.3f Hz, error=%0.3f Hz",
             crossing_count, measured_hz, frequency_error_hz);

    if (spacing_errors == 0 && valid_count > 1000 &&
        max_i-min_i > 100 && crossing_count > 20 &&
        frequency_error_hz < 5000.0)
      $display("PASS");
    else
      $display("FAIL");
    $finish;
  end
endmodule

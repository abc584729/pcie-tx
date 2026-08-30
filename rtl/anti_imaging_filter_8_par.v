`timescale 1 ns / 1 ns
// -------------------------------------------------------------
// Module: anti_imaging_filter_8_par
//
// 8x polyphase interpolation filter, fully-parallel multi-phase
// implementation. Bit-exact equivalent of the HDL Coder generated
// serial module hdlsrc/anti_imaging_filter_8/anti_imaging_filter_8.v
// (which time-multiplexes 3 multipliers over 8 phases on an 8x clock).
// Equivalence chain: parallel == serial == MATLAB golden reference.
//
// Rates / clock:
//   clk = input sample rate (180 MHz): 1 input sample per clock.
//   Each clock produces 8 output samples on filter_out, i.e. the
//   equivalent output stream runs at 8 x clk = 1.44 GHz.
//   filter_in connects directly to anti_imaging_filter_10.filter_out.
//
// Output bus mapping (time order matches the serial version):
//   filter_out[16*(7-p) +: 16] = phase p+1 output sample (p = 0..7),
//   bits [15:0] carry the latest of the 8 output samples, i.e. lane
//   k = sample slot k (phase p+1 corresponds to time slot 7-p).
//
// Latency: 3 clocks from input sample to output group; ce_out = 1
// marks a valid group (after pipeline fill it is 1 every clock).
//
// Multipliers: 20 per lane (phases 5..8 have tap-3 coefficient 0).
//
// Bit-exactness rules (operation chain mirrors the generated code):
//   coefficients : 24 x sfix16_En15, copied verbatim
//   product      : sfix32_En30 registered, truncated to sfix31_En30
//   accumulator  : sfix35_En30, overflow wraps, no intermediate
//                  rounding (fixed-point exact -> pipeline depth free)
//   rounding     : convergent, expression copied verbatim:
//                  (sum2[30:0] + {sum2[15], {14{~sum2[15]}}})>>>15
//   reset        : asynchronous, active high (FDHC style)
// -------------------------------------------------------------
module anti_imaging_filter_8_par (
  clk,
  clk_enable,
  reset,
  filter_in,
  filter_out,
  ce_out
);

  input   clk;
  input   clk_enable;
  input   reset;
  input   signed [15:0]  filter_in;    // sfix16_En15, 1 sample/clk
  output  signed [127:0] filter_out;   // 8 x sfix16_En15
  output  ce_out;

  // Coefficients: verbatim copy from anti_imaging_filter_8.v
  localparam signed [15:0] coeffphase1_1 = 16'b0000001010010001; //sfix16_En15
  localparam signed [15:0] coeffphase1_2 = 16'b0111011111100000; //sfix16_En15
  localparam signed [15:0] coeffphase1_3 = 16'b0001110000001101; //sfix16_En15
  localparam signed [15:0] coeffphase2_1 = 16'b0000011100100000; //sfix16_En15
  localparam signed [15:0] coeffphase2_2 = 16'b0111111111111111; //sfix16_En15
  localparam signed [15:0] coeffphase2_3 = 16'b0000111101110011; //sfix16_En15
  localparam signed [15:0] coeffphase3_1 = 16'b0000111101110011; //sfix16_En15
  localparam signed [15:0] coeffphase3_2 = 16'b0111111111111111; //sfix16_En15
  localparam signed [15:0] coeffphase3_3 = 16'b0000011100100000; //sfix16_En15
  localparam signed [15:0] coeffphase4_1 = 16'b0001110000001101; //sfix16_En15
  localparam signed [15:0] coeffphase4_2 = 16'b0111011111100000; //sfix16_En15
  localparam signed [15:0] coeffphase4_3 = 16'b0000001010010001; //sfix16_En15
  localparam signed [15:0] coeffphase5_1 = 16'b0010110011010001; //sfix16_En15
  localparam signed [15:0] coeffphase5_2 = 16'b0110100011110111; //sfix16_En15
  localparam signed [15:0] coeffphase5_3 = 16'b0000000000000000; //sfix16_En15
  localparam signed [15:0] coeffphase6_1 = 16'b0100000010101111; //sfix16_En15
  localparam signed [15:0] coeffphase6_2 = 16'b0101010110100000; //sfix16_En15
  localparam signed [15:0] coeffphase6_3 = 16'b0000000000000000; //sfix16_En15
  localparam signed [15:0] coeffphase7_1 = 16'b0101010110100000; //sfix16_En15
  localparam signed [15:0] coeffphase7_2 = 16'b0100000010101111; //sfix16_En15
  localparam signed [15:0] coeffphase7_3 = 16'b0000000000000000; //sfix16_En15
  localparam signed [15:0] coeffphase8_1 = 16'b0110100011110111; //sfix16_En15
  localparam signed [15:0] coeffphase8_2 = 16'b0010110011010001; //sfix16_En15
  localparam signed [15:0] coeffphase8_3 = 16'b0000000000000000; //sfix16_En15

  // Packed coefficient table: index (3*p + t) -> phase p+1, tap t+1.
  // Tap 1 multiplies the newest sample, tap 3 the oldest.
  localparam [383:0] COEF = {
    coeffphase8_3, coeffphase8_2, coeffphase8_1,
    coeffphase7_3, coeffphase7_2, coeffphase7_1,
    coeffphase6_3, coeffphase6_2, coeffphase6_1,
    coeffphase5_3, coeffphase5_2, coeffphase5_1,
    coeffphase4_3, coeffphase4_2, coeffphase4_1,
    coeffphase3_3, coeffphase3_2, coeffphase3_1,
    coeffphase2_3, coeffphase2_2, coeffphase2_1,
    coeffphase1_3, coeffphase1_2, coeffphase1_1
  };

  // Stage A: input shift register (polyphase length 3)
  reg signed [15:0] x0; // newest sample
  reg signed [15:0] x1;
  reg signed [15:0] x2; // oldest sample
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      x0 <= 0;
      x1 <= 0;
      x2 <= 0;
    end
    else if (clk_enable == 1'b1) begin
      x0 <= filter_in;
      x1 <= x0;
      x2 <= x1;
    end
  end

  genvar p;
  generate
    for (p = 0; p < 8; p = p + 1) begin : g_phase
      localparam signed [15:0] C1 = COEF[16*(3*p+0) +: 16];
      localparam signed [15:0] C2 = COEF[16*(3*p+1) +: 16];
      localparam signed [15:0] C3 = COEF[16*(3*p+2) +: 16];

      // Stage B: products, sfix32_En30 registers (truncated to
      // sfix31_En30 downstream, exactly like the generated code)
      reg signed [31:0] prod1; // tap 1: newest sample
      reg signed [31:0] prod2; // tap 2
      wire signed [31:0] prod3; // tap 3: oldest sample
      always @(posedge clk or posedge reset) begin
        if (reset == 1'b1) begin
          prod1 <= 0;
          prod2 <= 0;
        end
        else if (clk_enable == 1'b1) begin
          prod1 <= x0 * C1;
          prod2 <= x1 * C2;
        end
      end
      // Phases 5..8 (p >= 4) have tap-3 coefficient 0: tie off instead
      // of spending a multiplier (0 * x == 0, bit-exact).
      if (p < 4) begin : g_tap3
        reg signed [31:0] prod3_r;
        always @(posedge clk or posedge reset) begin
          if (reset == 1'b1) begin
            prod3_r <= 0;
          end
          else if (clk_enable == 1'b1) begin
            prod3_r <= x2 * C3;
          end
        end
        assign prod3 = prod3_r;
      end
      else begin : g_tap3_zero
        assign prod3 = 32'sd0;
      end

      // Stage C: partial sums, sfix35_En30. Grouping identical to the
      // serial code: sumA = sext35(tap3prod + tap2prod),
      //              sumB = sext35(tap1prod)
      wire signed [30:0] p1w = prod1[30:0];
      wire signed [30:0] p2w = prod2[30:0];
      wire signed [30:0] p3w = prod3[30:0];
      wire signed [31:0] add32 = p3w + p2w;
      reg signed [34:0] sumA;
      reg signed [34:0] sumB;
      always @(posedge clk or posedge reset) begin
        if (reset == 1'b1) begin
          sumA <= 0;
          sumB <= 0;
        end
        else if (clk_enable == 1'b1) begin
          sumA <= $signed({{3{add32[31]}}, add32});
          sumB <= $signed({{4{p1w[30]}}, p1w});
        end
      end

      // Stage D: final sum (wraps to sfix35_En30) + convergent
      // rounding + output register. Rounding expression copied
      // verbatim from the generated code.
      wire signed [35:0] add36 = sumA + sumB;
      wire signed [34:0] sum2 = add36[34:0];
      wire signed [15:0] output_typeconvert = (sum2[30:0] + {sum2[15], {14{~sum2[15]}}})>>>15;
      reg signed [15:0] out_r;
      always @(posedge clk or posedge reset) begin
        if (reset == 1'b1) begin
          out_r <= 0;
        end
        else if (clk_enable == 1'b1) begin
          out_r <= output_typeconvert;
        end
      end

      // lane remap: phase p+1 is time slot (7-p), so pack it into
      // filter_out[16*(7-p) +: 16] to make lane k = sample slot k
      assign filter_out[16*(7-p) +: 16] = out_r;
    end
  endgenerate

  // ce_out: output-group valid, same pipeline depth as the data path
  reg [3:0] ce_pipe;
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      ce_pipe <= 4'b0000;
    end
    else if (clk_enable == 1'b1) begin
      ce_pipe <= {ce_pipe[2:0], 1'b1};
    end
  end
  assign ce_out = clk_enable & ce_pipe[3];

endmodule  // anti_imaging_filter_8_par

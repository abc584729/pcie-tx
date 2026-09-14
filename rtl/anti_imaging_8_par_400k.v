`timescale 1 ns / 1 ns
// -------------------------------------------------------------
// Module: anti_imaging_8_par_400k
//
// 8x polyphase interpolation filter, fully-parallel multi-phase
// implementation for the BPSK 400k chain.  Bit-exact equivalent of the
// HDL Coder generated serial module rtl/anti_imaging_8_400k.v (which
// time-multiplexes 3 multipliers over 8 phases on an 8x clock).
//
// NOTE: this is NOT a rescaled copy of the 450k module
// (anti_imaging_filter_8_par.v).  The 400k design has a narrower adder
// chain: each product is truncated to sfix31_En30, the two partial sums
// are added into sfix33_En30 and truncated (wrapped) back to sfix32_En30
// before rounding.  The 450k version keeps a full sfix35_En30
// accumulator.  The operation chain below mirrors anti_imaging_8_400k.v
// statement by statement.
//
// Rates / clock:
//   clk = input sample rate (180 MHz): 1 input sample per clk_enable.
//   Each clk_enable produces 8 output samples on filter_out, i.e. the
//   equivalent output stream runs at 8 x clk = 1.44 GHz.
//   filter_in connects directly to anti_imaging_10_400k.filter_out.
//
// Output bus mapping (time order matches the serial version):
//   filter_out[16*p +: 16] = phase p+1 output sample (p = 0..7),
//   bits [15:0] carry the earliest of the 8 output samples, i.e. lane
//   k = sample slot k (phase p+1 corresponds to time slot p).
//
// Latency: 3 clk_enable events from input sample to output group;
// ce_out = 1 marks a valid group (after pipeline fill it is 1 every
// clk_enable).
//
// Multipliers: 2 per lane (phases 5, 6, 7, 8 have tap-3 coefficient 0).
//
// Bit-exactness rules (operation chain mirrors the generated code):
//   coefficients : 24 x sfix16_En15, copied verbatim from
//                  anti_imaging_8_400k.v
//   product      : sfix32_En30 registered, truncated to sfix31_En30
//   partial sums : sumvector1[0] = tap3prod + tap2prod (sfix32_En30),
//                  sumvector1[1] = sign-extended tap1prod (sfix32_En30)
//   accumulator  : sfix32_En30 registers, added into sfix33_En30 and
//                  truncated back to sfix32_En30 (overflow wraps)
//   rounding     : convergent, expression copied verbatim:
//                  (sum2[30:0] + {sum2[15], {14{~sum2[15]}}})>>>15
//   reset        : asynchronous, active high (FDHC style)
// -------------------------------------------------------------
module anti_imaging_8_par_400k (
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

  // Coefficients: verbatim copy from anti_imaging_8_400k.v
  localparam signed [15:0] coeffphase1_1 = 16'b0000001010010001; //sfix16_En15
  localparam signed [15:0] coeffphase1_2 = 16'b0111011111011111; //sfix16_En15
  localparam signed [15:0] coeffphase1_3 = 16'b0001110000001010; //sfix16_En15
  localparam signed [15:0] coeffphase2_1 = 16'b0000011100011111; //sfix16_En15
  localparam signed [15:0] coeffphase2_2 = 16'b0111111111111111; //sfix16_En15
  localparam signed [15:0] coeffphase2_3 = 16'b0000111101110001; //sfix16_En15
  localparam signed [15:0] coeffphase3_1 = 16'b0000111101110001; //sfix16_En15
  localparam signed [15:0] coeffphase3_2 = 16'b0111111111111111; //sfix16_En15
  localparam signed [15:0] coeffphase3_3 = 16'b0000011100011111; //sfix16_En15
  localparam signed [15:0] coeffphase4_1 = 16'b0001110000001010; //sfix16_En15
  localparam signed [15:0] coeffphase4_2 = 16'b0111011111011111; //sfix16_En15
  localparam signed [15:0] coeffphase4_3 = 16'b0000001010010001; //sfix16_En15
  localparam signed [15:0] coeffphase5_1 = 16'b0010110011001111; //sfix16_En15
  localparam signed [15:0] coeffphase5_2 = 16'b0110100011110110; //sfix16_En15
  localparam signed [15:0] coeffphase5_3 = 16'b0000000000000000; //sfix16_En15
  localparam signed [15:0] coeffphase6_1 = 16'b0100000010101100; //sfix16_En15
  localparam signed [15:0] coeffphase6_2 = 16'b0101010110011110; //sfix16_En15
  localparam signed [15:0] coeffphase6_3 = 16'b0000000000000000; //sfix16_En15
  localparam signed [15:0] coeffphase7_1 = 16'b0101010110011110; //sfix16_En15
  localparam signed [15:0] coeffphase7_2 = 16'b0100000010101100; //sfix16_En15
  localparam signed [15:0] coeffphase7_3 = 16'b0000000000000000; //sfix16_En15
  localparam signed [15:0] coeffphase8_1 = 16'b0110100011110110; //sfix16_En15
  localparam signed [15:0] coeffphase8_2 = 16'b0010110011001111; //sfix16_En15
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

      // Stage B: products, sfix32_En30 registers
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
      // Phases 5, 6, 7, 8 have tap-3 coefficient 0: tie off instead of
      // spending a multiplier (0 * x == 0, bit-exact).
      if (C3 == 16'sd0) begin : g_tap3_zero
        assign prod3 = 32'sd0;
      end
      else begin : g_tap3
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

      // Stage B': truncate each product to sfix31_En30, exactly like the
      // generated code's `product = product_pipe[30:0]`.
      wire signed [30:0] p1w = prod1[30:0];
      wire signed [30:0] p2w = prod2[30:0];
      wire signed [30:0] p3w = prod3[30:0];

      // Stage C: partial sums, registered sfix32_En30.
      // Grouping identical to the serial code:
      //   sumvector1[0] = tap3prod + tap2prod   (fits in 32 bits)
      //   sumvector1[1] = sext32(tap1prod)
      wire signed [31:0] sumv0 = p3w + p2w;
      wire signed [31:0] sumv1 = {{1{p1w[30]}}, p1w};
      reg signed [31:0] sumA;
      reg signed [31:0] sumB;
      always @(posedge clk or posedge reset) begin
        if (reset == 1'b1) begin
          sumA <= 0;
          sumB <= 0;
        end
        else if (clk_enable == 1'b1) begin
          sumA <= sumv0;
          sumB <= sumv1;
        end
      end

      // Stage D: final add in sfix33_En30, truncated back to sfix32_En30
      // (wrap), convergent rounding, output register.
      wire signed [32:0] add_temp = sumA + sumB;
      wire signed [31:0] sum2 = add_temp[31:0];
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

      // lane remap: phase p+1 is time slot p, so pack it into
      // filter_out[16*p +: 16] to make lane k = sample slot k
      assign filter_out[16*p +: 16] = out_r;
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

endmodule  // anti_imaging_8_par_400k

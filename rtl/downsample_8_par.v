`timescale 1 ns / 1 ns
// -------------------------------------------------------------
// Module: downsample_8_par
//
// Divide-by-8 polyphase decimation filter, fully-parallel. Bit-exact
// equivalent of the HDL Coder generated serial module
//   matlab/downsampling/hdlsrc/d_8/d_8.v
// (which consumes 1 input sample per clk_enable and time-multiplexes
// the phases over 8 clk_enable periods).
//
// Why this file exists: d_8.v takes 1 sample per clk_enable, so eating
// the 1.44 GSPS ADC stream would need a 1.44 GHz clock. The fabric runs
// at 180 MHz with 8 samples per clock (128-bit input), so d_8.v cannot
// be instantiated as-is. Same reason the interpolating side needed
// rtl/anti_imaging_filter_8_par.v. The divide-by-4 stage that follows
// does NOT need this treatment: d_4.v already consumes 1 sample per
// clk_enable, so rtl/downsample_4.v is used as exported.
//
// Rates / clock:
//   clk = 180 MHz fabric. One 128-bit input group (8 samples) per
//   clk_enable, one output sample per clk_enable.
//   clk_enable high every clock  -> 8 x 180M = 1.44 GSPS in,
//                                   180 MSPS out.
//   clk_enable high 1 clock in 8 -> 180 MSPS in, 22.5 MSPS out
//                                   (used by the testbench to line this
//                                    module up with the serial d_8.v).
//
// Transfer function:
//   filter_in[16*k +: 16] = x[8m + k], k = 0..7   (lane 0 = earliest)
//   filter_out            = y[m] = sum_{i=0}^{48} h[i] * x[8m - i]
// i.e. the same decimation the polyphase decomposition expresses as
//   E_p(z) = sum_t h[8t + p] z^-t,   y[m] = sum_p E_p(z) x[8m - p].
// Because all 8 phases are evaluated in the same clock, no phase
// counter, no mux and no phase gating is needed: tap i simply reads
// sample-history slot (7 + i).
//
// Output bus / latency:
//   single sfix16_En10 sample per clk_enable; ce_out marks it.
//   Latency = 5 clk_enable periods, matching ce_pipe[4].
//
// Multipliers: 49 (all 49 coefficients of the 49-tap filter are used;
// d_8.v also spends 49 -- the zero slots i = 49..55 do not exist).
//
// Bit-exactness rules (two things must be copied verbatim):
//   coefficients : 49 x sfix16_En15, copied verbatim from d_8.v
//   product      : sfix32_En30 registered, truncated to sfix31_En30
//                  (product[30:0]) exactly like the generated code
//   accumulator  : sfix36_En30, no intermediate rounding. Every tree
//                  node is exact mod 2^36 and modular addition is
//                  associative, so tree grouping and pipeline depth
//                  are free (same argument as anti_imaging_filter_8_par)
//   rounding     : convergent, expression copied verbatim:
//                  (sum6[35:0] + {sum6[20], {19{~sum6[20]}}})>>>20
//   reset        : asynchronous, active high (FDHC style)
//
// Verified: 272/272 bit-exact against d_8.v standalone (same stimulus,
// outputs aligned with no offset), and 0 mismatches over the whole
// 45 MSPS output stream when run inside rtl/downsample_45m.v against the
// d_8.v -> d_4.v cascade -- see tb/tb_downsample_45m.v, all four
// stimulus modes (noise / impulse / ramp / chirp).
// -------------------------------------------------------------
module downsample_8_par (
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
  input   signed [127:0] filter_in;   // 8 x sfix16_En15, lane 0 = x[8m]
  output  signed [15:0]  filter_out;  // sfix16_En10, 1 sample/clk_enable
  output  ce_out;

  // Coefficients: verbatim copy from d_8.v, re-indexed by h index.
  // The generated code names them coeffphase{p}_{t}; the mapping is
  //   coeffphase{p}_{t} = E_{p-1}[t-1] = h[(p-1) + 8(t-1)]
  // so h[i] below is literally coeffphase{i%8+1}_{i/8+1} of d_8.v.
  localparam signed [15:0] h0  = 16'b0000000010000001; //sfix16_En15  (E_0[0] = coeffphase1_1)
  localparam signed [15:0] h1  = 16'b0000000011101100; //sfix16_En15  (E_1[0] = coeffphase2_1)
  localparam signed [15:0] h2  = 16'b0000000110110110; //sfix16_En15  (E_2[0] = coeffphase3_1)
  localparam signed [15:0] h3  = 16'b0000001011100011; //sfix16_En15  (E_3[0] = coeffphase4_1)
  localparam signed [15:0] h4  = 16'b0000010010001101; //sfix16_En15  (E_4[0] = coeffphase5_1)
  localparam signed [15:0] h5  = 16'b0000011011001101; //sfix16_En15  (E_5[0] = coeffphase6_1)
  localparam signed [15:0] h6  = 16'b0000100110111101; //sfix16_En15  (E_6[0] = coeffphase7_1)
  localparam signed [15:0] h7  = 16'b0000110101110010; //sfix16_En15  (E_7[0] = coeffphase8_1)
  localparam signed [15:0] h8  = 16'b0001000111111111; //sfix16_En15  (E_0[1] = coeffphase1_2)
  localparam signed [15:0] h9  = 16'b0001011101101101; //sfix16_En15  (E_1[1] = coeffphase2_2)
  localparam signed [15:0] h10 = 16'b0001110110111111; //sfix16_En15  (E_2[1] = coeffphase3_2)
  localparam signed [15:0] h11 = 16'b0010010011101101; //sfix16_En15  (E_3[1] = coeffphase4_2)
  localparam signed [15:0] h12 = 16'b0010110011100100; //sfix16_En15  (E_4[1] = coeffphase5_2)
  localparam signed [15:0] h13 = 16'b0011010110000100; //sfix16_En15  (E_5[1] = coeffphase6_2)
  localparam signed [15:0] h14 = 16'b0011111010100100; //sfix16_En15  (E_6[1] = coeffphase7_2)
  localparam signed [15:0] h15 = 16'b0100100000010000; //sfix16_En15  (E_7[1] = coeffphase8_2)
  localparam signed [15:0] h16 = 16'b0101000110001010; //sfix16_En15  (E_0[2] = coeffphase1_3)
  localparam signed [15:0] h17 = 16'b0101101011001110; //sfix16_En15  (E_1[2] = coeffphase2_3)
  localparam signed [15:0] h18 = 16'b0110001110010110; //sfix16_En15  (E_2[2] = coeffphase3_3)
  localparam signed [15:0] h19 = 16'b0110101110011001; //sfix16_En15  (E_3[2] = coeffphase4_3)
  localparam signed [15:0] h20 = 16'b0111001010010101; //sfix16_En15  (E_4[2] = coeffphase5_3)
  localparam signed [15:0] h21 = 16'b0111100001001010; //sfix16_En15  (E_5[2] = coeffphase6_3)
  localparam signed [15:0] h22 = 16'b0111110010000101; //sfix16_En15  (E_6[2] = coeffphase7_3)
  localparam signed [15:0] h23 = 16'b0111111100011111; //sfix16_En15  (E_7[2] = coeffphase8_3)
  localparam signed [15:0] h24 = 16'b0111111111111111; //sfix16_En15  (E_0[3] = coeffphase1_4)
  localparam signed [15:0] h25 = 16'b0111111100011111; //sfix16_En15  (E_1[3] = coeffphase2_4)
  localparam signed [15:0] h26 = 16'b0111110010000101; //sfix16_En15  (E_2[3] = coeffphase3_4)
  localparam signed [15:0] h27 = 16'b0111100001001010; //sfix16_En15  (E_3[3] = coeffphase4_4)
  localparam signed [15:0] h28 = 16'b0111001010010101; //sfix16_En15  (E_4[3] = coeffphase5_4)
  localparam signed [15:0] h29 = 16'b0110101110011001; //sfix16_En15  (E_5[3] = coeffphase6_4)
  localparam signed [15:0] h30 = 16'b0110001110010110; //sfix16_En15  (E_6[3] = coeffphase7_4)
  localparam signed [15:0] h31 = 16'b0101101011001110; //sfix16_En15  (E_7[3] = coeffphase8_4)
  localparam signed [15:0] h32 = 16'b0101000110001010; //sfix16_En15  (E_0[4] = coeffphase1_5)
  localparam signed [15:0] h33 = 16'b0100100000010000; //sfix16_En15  (E_1[4] = coeffphase2_5)
  localparam signed [15:0] h34 = 16'b0011111010100100; //sfix16_En15  (E_2[4] = coeffphase3_5)
  localparam signed [15:0] h35 = 16'b0011010110000100; //sfix16_En15  (E_3[4] = coeffphase4_5)
  localparam signed [15:0] h36 = 16'b0010110011100100; //sfix16_En15  (E_4[4] = coeffphase5_5)
  localparam signed [15:0] h37 = 16'b0010010011101101; //sfix16_En15  (E_5[4] = coeffphase6_5)
  localparam signed [15:0] h38 = 16'b0001110110111111; //sfix16_En15  (E_6[4] = coeffphase7_5)
  localparam signed [15:0] h39 = 16'b0001011101101101; //sfix16_En15  (E_7[4] = coeffphase8_5)
  localparam signed [15:0] h40 = 16'b0001000111111111; //sfix16_En15  (E_0[5] = coeffphase1_6)
  localparam signed [15:0] h41 = 16'b0000110101110010; //sfix16_En15  (E_1[5] = coeffphase2_6)
  localparam signed [15:0] h42 = 16'b0000100110111101; //sfix16_En15  (E_2[5] = coeffphase3_6)
  localparam signed [15:0] h43 = 16'b0000011011001101; //sfix16_En15  (E_3[5] = coeffphase4_6)
  localparam signed [15:0] h44 = 16'b0000010010001101; //sfix16_En15  (E_4[5] = coeffphase5_6)
  localparam signed [15:0] h45 = 16'b0000001011100011; //sfix16_En15  (E_5[5] = coeffphase6_6)
  localparam signed [15:0] h46 = 16'b0000000110110110; //sfix16_En15  (E_6[5] = coeffphase7_6)
  localparam signed [15:0] h47 = 16'b0000000011101100; //sfix16_En15  (E_7[5] = coeffphase8_6)
  localparam signed [15:0] h48 = 16'b0000000010000001; //sfix16_En15  (E_0[6] = coeffphase1_7)

  // Packed coefficient table: COEF[16*i +: 16] = h[i].
  localparam [783:0] COEF = {
    h48,
    h47,
    h46,
    h45,
    h44,
    h43,
    h42,
    h41,
    h40,
    h39,
    h38,
    h37,
    h36,
    h35,
    h34,
    h33,
    h32,
    h31,
    h30,
    h29,
    h28,
    h27,
    h26,
    h25,
    h24,
    h23,
    h22,
    h21,
    h20,
    h19,
    h18,
    h17,
    h16,
    h15,
    h14,
    h13,
    h12,
    h11,
    h10,
    h9 ,
    h8 ,
    h7 ,
    h6 ,
    h5 ,
    h4 ,
    h3 ,
    h2 ,
    h1 ,
    h0 
  };

  // Stage A: sample history, 7 groups = 56 samples deep.
  //   sr[d] = x[8m + 7 - d], d = 0..55, sr[0] = newest, sr[55] = oldest
  //   so sr[7+i] = x[8m - i] for i = 0..48, which is exactly the operand
  //   of tap i in  y[m] = sum_i h[i] * x[8m - i].
  // 7 groups because the 49-tap window spans x[8m] .. x[8m-48], and
  // x[8m-48] lives 6 groups back; 56 = 7 x 8 entries, of which 49 are
  // read (sr[7] .. sr[55]) and 7 are only there to be shifted.
  // Lane order: lane0 = earliest sample of the group, lane7 = newest,
  // so lane7 becomes sr[0] and lane0 becomes sr[7].
  reg signed [15:0] sr [0:55];
  integer k;
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      for (k = 0; k < 56; k = k + 1) sr[k] <= 16'sd0;
    end
    else if (clk_enable == 1'b1) begin
      sr[0] <= filter_in[127:112];  // lane 7, newest
      sr[1] <= filter_in[111: 96];
      sr[2] <= filter_in[ 95: 80];
      sr[3] <= filter_in[ 79: 64];
      sr[4] <= filter_in[ 63: 48];
      sr[5] <= filter_in[ 47: 32];
      sr[6] <= filter_in[ 31: 16];
      sr[7] <= filter_in[ 15:  0];  // lane 0, earliest
      for (k = 8; k < 56; k = k + 1) sr[k] <= sr[k-8];
    end
  end

  // Stage B: products, sfix32_En30 (16x16 signed is exact in 32 bits),
  // truncated to sfix31_En30 in stage C. This mirrors the generated
  // code, where the product pipeline register is sfix32_En30 and the
  // adder inputs are product[30:0].
  reg signed [31:0] prod [0:48];
  integer i;
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      for (i = 0; i < 49; i = i + 1) prod[i] <= 32'sd0;
    end
    else if (clk_enable == 1'b1) begin
      for (i = 0; i < 49; i = i + 1)
        prod[i] <= sr[7+i] * $signed(COEF[16*i +: 16]);
    end
  end

  // Stage C: first adder level of the tree, sfix36_En30.
  // Products are truncated to their low 31 bits (sfix31_En30) and
  // sign-extended to 36 bits first, exactly like add_signext_* /
  // {{4{add_temp[31]}}, add_temp} in the generated code. Two such
  // values always fit in 36 bits, so this level never wraps.
  reg signed [35:0] ps [0:24];
  integer j;
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      for (j = 0; j < 25; j = j + 1) ps[j] <= 36'sd0;
    end
    else if (clk_enable == 1'b1) begin
      for (j = 0; j < 24; j = j + 1)
        ps[j] <= $signed({{5{prod[2*j  ][30]}}, prod[2*j  ][30:0]})
               + $signed({{5{prod[2*j+1][30]}}, prod[2*j+1][30:0]});
      ps[24] <= $signed({{5{prod[48][30]}}, prod[48][30:0]});
    end
  end

  // Stage D: second adder level. From here on every node is a plain
  // sfix36_En30 sum, i.e. exact arithmetic mod 2^36. Modular addition
  // is associative, so the shape of the rest of the tree (and how many
  // registers are pushed into it) cannot change the result.
  reg signed [35:0] ps2 [0:12];
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      for (j = 0; j < 13; j = j + 1) ps2[j] <= 36'sd0;
    end
    else if (clk_enable == 1'b1) begin
      for (j = 0; j < 12; j = j + 1) ps2[j] <= ps[2*j] + ps[2*j+1];
      ps2[12] <= ps[24];
    end
  end

  // Stage E: final reduction of the 13 remaining partial sums, then
  // convergent rounding to sfix16_En10 and the output register.
  wire signed [35:0] t0 = ps2[ 0] + ps2[ 1];
  wire signed [35:0] t1 = ps2[ 2] + ps2[ 3];
  wire signed [35:0] t2 = ps2[ 4] + ps2[ 5];
  wire signed [35:0] t3 = ps2[ 6] + ps2[ 7];
  wire signed [35:0] t4 = ps2[ 8] + ps2[ 9];
  wire signed [35:0] t5 = ps2[10] + ps2[11];
  wire signed [35:0] t6 = ps2[12];
  wire signed [35:0] u0 = t0 + t1;
  wire signed [35:0] u1 = t2 + t3;
  wire signed [35:0] u2 = t4 + t5;
  wire signed [35:0] v0 = u0 + u1;
  wire signed [35:0] v1 = u2 + t6;
  wire signed [35:0] sum6 = v0 + v1;

  // Rounding expression copied verbatim from d_8.v:
  //   assign output_typeconvert = (sum6[35:0] + {sum6[20], {19{~sum6[20]}}})>>>20;
  wire signed [15:0] output_typeconvert = (sum6[35:0] + {sum6[20], {19{~sum6[20]}}})>>>20;
  reg signed [15:0] out_r;
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      out_r <= 16'sd0;
    end
    else if (clk_enable == 1'b1) begin
      out_r <= output_typeconvert;
    end
  end
  assign filter_out = out_r;

  // ce_out: same pipeline depth as the data path (sr, prod, ps, ps2,
  // out_r = 5 register stages, hence ce_pipe[4]).
  reg [4:0] ce_pipe;
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      ce_pipe <= 5'b00000;
    end
    else if (clk_enable == 1'b1) begin
      ce_pipe <= {ce_pipe[3:0], 1'b1};
    end
  end
  assign ce_out = clk_enable & ce_pipe[4];

endmodule  // downsample_8_par

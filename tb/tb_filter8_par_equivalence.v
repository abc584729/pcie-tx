`timescale 1 ns / 1 ns
// -------------------------------------------------------------
// Testbench: tb_filter8_par_equivalence
//
// A/B bit-equivalence: serial anti_imaging_filter_8 (HDL Coder,
// runs on an 8x clock, 1 input sample held for 8 clocks) vs the
// parallel anti_imaging_filter_8_par (1x clock, 1 sample per clock,
// 8 phases per clock). Both are driven with the identical stimulus
// sequence; the serial output stream is grouped into 8-sample groups
// and compared bit-exactly against the parallel 128-bit bus phases.
//
// Alignment: the first stimulus sample is an impulse (0x4000). The
// first non-zero output on each side marks group 0 / phase 1 and the
// two streams are aligned from that marker (impulse-marker auto
// alignment). As an independent golden check, groups 0..2 of both
// DUTs are verified against the impulse response computed directly
// from the 24 coefficients (exercises every coefficient in isolation).
//
// Stimulus: impulse, step, +full scale, -full scale, wrap ramp,
// alternating +/-full scale, 4096 LFSR pseudo-random samples, flush.
//
// Pass criteria:
//   - serial vs parallel: 0 mismatches (bit exact)
//   - both DUTs match the analytic impulse response
//   - ce_out_ser == (counter==7) each cycle; ce_out_par == 1 on
//     every captured group; IQ wrapper outputs equal lane output
// -------------------------------------------------------------
module tb_filter8_par_equivalence;

  localparam N_GROUPS = 4256;
  localparam N_OUT    = 8 * N_GROUPS;

  // ---------------- stimulus ----------------
  reg signed [15:0] stim [0:N_GROUPS-1];
  initial begin : build_stim
    integer i;
    reg [15:0] lfsr;
    stim[0] = 16'sh4000;                       // impulse: alignment marker
    for (i = 1; i < 8;  i = i + 1) stim[i] = 0;
    for (i = 8; i < 24; i = i + 1) stim[i] = 16'sh7FFF;   // step, + full scale
    for (i = 24; i < 40; i = i + 1) stim[i] = 16'sh8000;  // - full scale
    for (i = 0; i < 64; i = i + 1) stim[40+i]  = 16'sh8000 + i * 16'sh0400; // wrap ramp
    for (i = 0; i < 32; i = i + 1) stim[104+i] = (i % 2 == 0) ? 16'sh7FFF : 16'sh8000; // +/- full
    lfsr = 16'hACE1;                           // LFSR pseudo-random
    for (i = 0; i < 4096; i = i + 1) begin
      stim[136+i] = lfsr;
      lfsr = {lfsr[14:0], lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};
    end
    for (i = 4232; i < N_GROUPS; i = i + 1) stim[i] = 0; // flush to zero
  end

  // ---------------- clocks / control ----------------
  reg clk_fast = 1'b0;                          // serial DUT clock (8x)
  always #5 clk_fast = ~clk_fast;

  reg reset = 1'b1;
  reg clk_enable = 1'b0;
  reg [2:0] tb_cnt = 3'd0;                      // mirrors DUT cur_count
  reg clk_slow = 1'b0;                          // parallel DUT clock (1x)

  always @(posedge clk_fast or posedge reset) begin
    if (reset == 1'b1) tb_cnt <= 3'd0;
    else if (clk_enable == 1'b1) tb_cnt <= tb_cnt + 3'd1;
  end

  // clk_slow posedge coincides with the fast posedge at the end of
  // the tb_cnt==7 cycle (the instant the serial DUT captures input),
  // so both DUTs consume input sample n at the same instant.
  always @(posedge clk_fast or posedge reset) begin
    if (reset == 1'b1) clk_slow <= 1'b0;
    else if (clk_enable == 1'b1) begin
      if (tb_cnt == 3'd7) clk_slow <= 1'b1;
      else if (tb_cnt == 3'd3) clk_slow <= 1'b0;
    end
  end

  initial begin
    repeat (4) @(posedge clk_fast);
    #1 reset = 1'b0;
    #1 clk_enable = 1'b1;
  end

  // ---------------- input driving ----------------
  // serial: change at negedge of tb_cnt==0 cycle -> stable during the
  // whole 8-cycle window, captured by the DUT at the tb_cnt==7 edge.
  // parallel: change at negedge of tb_cnt==4 cycle -> stable across
  // the slow-clock posedge at the tb_cnt==7 edge.
  reg signed [15:0] filter_in_ser = 16'sd0;
  reg signed [15:0] filter_in_par = 16'sd0;
  integer n_ser = 0;
  integer n_par = 0;

  always @(negedge clk_fast) begin
    if (!reset && clk_enable) begin
      if (tb_cnt == 3'd0) begin
        filter_in_ser <= (n_ser < N_GROUPS) ? stim[n_ser] : 16'sd0;
        n_ser <= n_ser + 1;
      end
      if (tb_cnt == 3'd4) begin
        filter_in_par <= (n_par < N_GROUPS) ? stim[n_par] : 16'sd0;
        n_par <= n_par + 1;
      end
    end
  end

  // ---------------- DUTs ----------------
  wire signed [15:0]  filter_out_ser;
  wire ce_out_ser;
  anti_imaging_filter_8 u_ser (
    .clk        (clk_fast),
    .clk_enable (clk_enable),
    .reset      (reset),
    .filter_in  (filter_in_ser),
    .filter_out (filter_out_ser),
    .ce_out     (ce_out_ser)
  );

  wire signed [127:0] filter_out_par;
  wire ce_out_par;
  anti_imaging_filter_8_par u_par (
    .clk        (clk_slow),
    .clk_enable (clk_enable),
    .reset      (reset),
    .filter_in  (filter_in_par),
    .filter_out (filter_out_par),
    .ce_out     (ce_out_par)
  );

  wire signed [127:0] filter_out_i, filter_out_q;
  wire ce_out_iq;
  anti_imaging_filter_8_par_iq u_iq (
    .clk        (clk_slow),
    .clk_enable (clk_enable),
    .reset      (reset),
    .filter_in_i (filter_in_par),
    .filter_in_q (filter_in_par),
    .filter_out_i (filter_out_i),
    .filter_out_q (filter_out_q),
    .ce_out      (ce_out_iq)
  );

  // ---------------- capture / alignment ----------------
  reg signed [15:0] ser_mem [0:N_OUT-1];
  reg signed [15:0] par_mem [0:N_OUT-1];
  reg ser_marked = 1'b0;
  reg par_marked = 1'b0;
  integer ser_cnt = 0;
  integer par_g = 0;
  integer ce_err = 0;
  integer k;

  always @(negedge clk_fast) begin
    if (!reset && clk_enable) begin
      // serial ce_out marks the counter==7 cycle
      if (ce_out_ser !== (tb_cnt == 3'd7)) ce_err = ce_err + 1;

      if (!ser_marked) begin
        if (filter_out_ser !== 16'sd0) begin
          ser_marked = 1'b1;
          ser_mem[0] = filter_out_ser;
          ser_cnt = 1;
        end
      end
      else if (ser_cnt < N_OUT) begin
        ser_mem[ser_cnt] = filter_out_ser;
        ser_cnt = ser_cnt + 1;
      end

      // parallel: capture the 128-bit bus once per slow clock
      if (tb_cnt == 3'd5) begin
        if (!par_marked) begin
          if (filter_out_par !== 128'sd0) begin
            par_marked = 1'b1;
            for (k = 0; k < 8; k = k + 1)
              par_mem[k] = filter_out_par[16*k +: 16];
            par_g = 1;
          end
        end
        else if (par_g < N_GROUPS) begin
          for (k = 0; k < 8; k = k + 1)
            par_mem[8*par_g + k] = filter_out_par[16*k +: 16];
          par_g = par_g + 1;
          if (par_g == N_GROUPS) begin
            compare_and_report;
            $finish;
          end
        end
        if (par_marked) begin
          if (ce_out_par !== 1'b1) ce_err = ce_err + 1;
          if (filter_out_i !== filter_out_par) ce_err = ce_err + 1;
          if (filter_out_q !== filter_out_par) ce_err = ce_err + 1;
          if (ce_out_iq !== ce_out_par) ce_err = ce_err + 1;
        end
      end
    end
  end

  // ---------------- analytic impulse-response reference ----------------
  // Coefficients copied from anti_imaging_filter_8.v (cross-check).
  function signed [15:0] coef;
    input integer pi; // phase index 0..7
    input integer ti; // tap index 0..2 (0 = newest sample)
    begin
      case (pi*3 + ti)
         0: coef = 16'b0000001010010001; // coeffphase1_1
         1: coef = 16'b0111011111100000; // coeffphase1_2
         2: coef = 16'b0001110000001101; // coeffphase1_3
         3: coef = 16'b0000011100100000; // coeffphase2_1
         4: coef = 16'b0111111111111111; // coeffphase2_2
         5: coef = 16'b0000111101110011; // coeffphase2_3
         6: coef = 16'b0000111101110011; // coeffphase3_1
         7: coef = 16'b0111111111111111; // coeffphase3_2
         8: coef = 16'b0000011100100000; // coeffphase3_3
         9: coef = 16'b0001110000001101; // coeffphase4_1
        10: coef = 16'b0111011111100000; // coeffphase4_2
        11: coef = 16'b0000001010010001; // coeffphase4_3
        12: coef = 16'b0010110011010001; // coeffphase5_1
        13: coef = 16'b0110100011110111; // coeffphase5_2
        14: coef = 16'b0000000000000000; // coeffphase5_3
        15: coef = 16'b0100000010101111; // coeffphase6_1
        16: coef = 16'b0101010110100000; // coeffphase6_2
        17: coef = 16'b0000000000000000; // coeffphase6_3
        18: coef = 16'b0101010110100000; // coeffphase7_1
        19: coef = 16'b0100000010101111; // coeffphase7_2
        20: coef = 16'b0000000000000000; // coeffphase7_3
        21: coef = 16'b0110100011110111; // coeffphase8_1
        22: coef = 16'b0010110011010001; // coeffphase8_2
        23: coef = 16'b0000000000000000; // coeffphase8_3
      endcase
    end
  endfunction

  // Reference single-tap MAC through the exact serial arithmetic chain.
  function signed [15:0] ref_1tap;
    input signed [15:0] c;
    input signed [15:0] x;
    reg signed [31:0] prod;
    reg signed [34:0] sum2;
    begin
      prod = x * c;
      sum2 = $signed({{4{prod[30]}}, prod[30:0]});
      ref_1tap = (sum2[30:0] + {sum2[15], {14{~sum2[15]}}})>>>15;
    end
  endfunction

  // ---------------- comparison ----------------
  task compare_and_report;
    integer i;
    integer g;
    integer p;
    integer ab_err;
    integer gold_err;
    reg signed [15:0] want;
    begin
      ab_err = 0;
      for (i = 0; i < N_OUT; i = i + 1) begin
        if (ser_mem[i] !== par_mem[i]) begin
          ab_err = ab_err + 1;
          if (ab_err <= 20)
            $display("A/B MISMATCH group %0d phase %0d : ser=%h par=%h",
                     i/8, i%8, ser_mem[i], par_mem[i]);
        end
      end

      gold_err = 0;
      for (g = 0; g < 4; g = g + 1) begin
        for (p = 0; p < 8; p = p + 1) begin
          want = (g < 3) ? ref_1tap(coef(p, g), 16'sh4000) : 16'sd0;
          if (ser_mem[8*g + p] !== want) begin
            gold_err = gold_err + 1;
            if (gold_err <= 20)
              $display("GOLD SER MISMATCH group %0d phase %0d : got=%h want=%h",
                       g, p, ser_mem[8*g + p], want);
          end
          if (par_mem[8*g + p] !== want) begin
            gold_err = gold_err + 1;
            if (gold_err <= 20)
              $display("GOLD PAR MISMATCH group %0d phase %0d : got=%h want=%h",
                       g, p, par_mem[8*g + p], want);
          end
        end
      end

      $display("----------------------------------------------");
      $display("A/B equivalence : groups=%0d outputs=%0d", N_GROUPS, N_OUT);
      $display("  serial captured : %0s, parallel captured : %0s",
               (ser_marked && ser_cnt == N_OUT) ? "OK" : "INCOMPLETE",
               par_marked ? "OK" : "INCOMPLETE");
      $display("  serial-vs-parallel mismatches : %0d", ab_err);
      $display("  analytic-impulse mismatches   : %0d", gold_err);
      $display("  control/ce/wrapper errors     : %0d", ce_err);
      if (ab_err == 0 && gold_err == 0 && ce_err == 0 &&
          ser_marked && par_marked && ser_cnt == N_OUT)
        $display("************** TEST COMPLETED (PASSED) **************");
      else
        $display("************** TEST COMPLETED (FAILED) **************");
    end
  endtask

  initial begin // timeout guard
    #4000000;
    $display("TIMEOUT: ser_cnt=%0d ser_marked=%0d par_g=%0d par_marked=%0d",
             ser_cnt, ser_marked, par_g, par_marked);
    $finish;
  end

endmodule // tb_filter8_par_equivalence
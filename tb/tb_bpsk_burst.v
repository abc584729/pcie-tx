`timescale 1ns/1ps
// Burst (single-shot) mode check for rtl/bpsk_ram.v.
//
// bpsk_ram gains two inputs: `sym_num` (symbols to send) and `single_shot`.
// In single-shot mode it counts rdata_valid and, once sym_num symbols have
// been emitted, deasserts rdata_valid and freezes the read pointer; cyclic
// mode (single_shot = 0, the power-up default) must behave exactly as before.
//
// The DUT is bpsk_ram + dpram only -- bpsk.v cannot be elaborated here
// because the Xilinx cmpy/DDS IP it instantiates is not in the repo.
//
// Cases:
//   A cyclic, sym_num ignored        : period 400 clk, keeps running
//   B single shot, sym_num = 5       : exactly 5 valids, then silence
//   C single shot, sym_num = 1       : exactly 1 valid
//   D single shot, sym_num = 4194304 : full-table count still compares right
//   E single shot, sym_num = 0       : nothing at all is sent
//   F re-arm after B (rst_n pulse)   : exactly 5 again
//   G rate_sel = 1                   : period 450 clk (divider untouched)
module tb_bpsk_burst;

  reg clk = 0;
  reg rst_n = 0;
  reg ram_en = 0;
  reg rate_sel = 0;
  reg single_shot = 0;
  reg [22:0] sym_num = 0;

  wire rdata;
  wire rdata_valid;

  // write port of the table (only the first few words are needed)
  reg         u_wen = 0;
  reg  [17:0] u_waddr = 0;
  reg  [15:0] u_wdata = 0;

  bpsk_ram u_dut (
    .clk         (clk),
    .rst_n       (rst_n),
    .rd_en       (ram_en),
    .rate_sel    (rate_sel),
    .w_en        (u_wen),
    .w_addr      (u_waddr),
    .w_data      (u_wdata),
    .sym_num     (sym_num),
    .single_shot (single_shot),
    .rdata       (rdata),
    .rdata_valid (rdata_valid)
  );

  always #5 clk = ~clk;

  wire        rd_pulse = u_dut.flag_g;    // gated read pulse -> dpram r_en
  wire        raw_pulse = u_dut.flag;      // divider pulse, must keep running
  wire [21:0] rptr     = u_dut.rptr;

  localparam CLK_PER_SYM_450K = 400;
  localparam CLK_PER_SYM_400K = 450;

  integer errors = 0;

  // per-run measurements
  integer v_cnt, p_cnt, t, first_v, last_v, period, rptr_end, rptr_end2;
  integer f_cnt, rptr_err;
  integer exp_period;

  task check;
    input [255:0] name;
    input integer got;
    input integer exp;
    begin
      if (got !== exp) begin
        errors = errors + 1;
        $display("  FAIL %0s: got %0d, expect %0d", name, got, exp);
      end
      else
        $display("  ok   %0s = %0d", name, got);
    end
  endtask

  // Reset, configure, start, count valids / read pulses for `cycles` clocks.
  task run;
    input        ss;
    input [22:0] n;
    input        sel;
    input integer cycles;
    begin
      @(negedge clk);
      ram_en = 0; single_shot = ss; sym_num = n; rate_sel = sel;

      // host re-arm sequence: TX_REG_RESET pulse, then RAM_EN
      @(negedge clk) rst_n = 0;
      repeat (4) @(negedge clk);
      @(negedge clk) rst_n = 1;

      v_cnt = 0; p_cnt = 0; first_v = -1; last_v = -1;
      period = -1; rptr_end = -1; rptr_end2 = -1;
      f_cnt = 0; rptr_err = 0;
      @(negedge clk) ram_en = 1;

      for (t = 0; t < cycles; t = t + 1) begin
        @(posedge clk); #1;
        if (rdata_valid) begin
          v_cnt = v_cnt + 1;
          // the k-th valid carries symbol k-1 and leaves rptr at k
          if (rptr !== v_cnt[21:0]) rptr_err = rptr_err + 1;
          if (first_v < 0) first_v = t;
          else if (period < 0) period = t - first_v;
          last_v = t;
        end
        if (rd_pulse)   p_cnt = p_cnt + 1;
        if (raw_pulse)  f_cnt = f_cnt + 1;
      end

      rptr_end = rptr;
      // rptr must be frozen once the burst is over
      repeat (4 * CLK_PER_SYM_400K) @(posedge clk);
      #1;
      rptr_end2 = rptr;
    end
  endtask

  initial begin
    $dumpfile("tb_bpsk_burst.vcd");
    $dumpvars(0, tb_bpsk_burst);

    // ---- fill the first 32 words (512 symbols) with 16'hAAAA ----
    rst_n = 0;
    repeat (4) @(posedge clk);
    @(negedge clk) rst_n = 1;
    for (t = 0; t < 32; t = t + 1) begin
      @(negedge clk); u_wen = 1; u_waddr = t[17:0]; u_wdata = 16'hAAAA;
      @(posedge clk);
    end
    @(negedge clk); u_wen = 0; u_wdata = 0;

    // ---- A: cyclic (default), sym_num must be ignored ----
    $display("A: cyclic, single_shot=0, sym_num=5");
    run(1'b0, 23'd5, 1'b0, 2500);
    check("valid period", period, CLK_PER_SYM_450K);
    check("valids in 2500 clk", v_cnt, 6);
    check("no early stop", v_cnt > 1, 1);

    // ---- B: single shot, 5 symbols ----
    $display("B: single shot, sym_num=5");
    run(1'b1, 23'd5, 1'b0, 4000);
    check("valids", v_cnt, 5);
    check("read pulses", p_cnt, 5);
    check("first valid at", first_v, CLK_PER_SYM_450K - 1);
    check("last-first", last_v - first_v, 4 * CLK_PER_SYM_450K);
    check("valid period", period, CLK_PER_SYM_450K);
    check("rptr frozen", rptr_end2, rptr_end);
    check("rptr tracks symbol index", rptr_err, 0);
    // the divider must keep running while the output is gated: 4000 clk of
    // period-400 pulses is ~10 raw pulses against only 5 emitted symbols
    check("raw divider pulses (not gated)", f_cnt, 10);

    // ---- C: single shot, 1 symbol ----
    $display("C: single shot, sym_num=1");
    run(1'b1, 23'd1, 1'b0, 4000);
    check("valids", v_cnt, 1);
    check("read pulses", p_cnt, 1);

    // ---- D: single shot, largest count (whole table) ----
    $display("D: single shot, sym_num=4194304 (whole table), short window");
    run(1'b1, 23'd4194304, 1'b0, 2500);
    check("valids in 2500 clk (must not stop early)", v_cnt, 6);

    // ---- E: single shot with sym_num = 0 -> send nothing ----
    $display("E: single shot, sym_num=0");
    run(1'b1, 23'd0, 1'b0, 2500);
    check("valids", v_cnt, 0);
    check("read pulses", p_cnt, 0);

    // ---- F: re-arm the same burst again ----
    $display("F: single shot, sym_num=5, second run");
    run(1'b1, 23'd5, 1'b0, 4000);
    check("valids", v_cnt, 5);
    check("read pulses", p_cnt, 5);

    // ---- G: rate_sel = 1 -> 450 clk / symbol, cyclic ----
    $display("G: cyclic at rate_sel=1");
    run(1'b0, 23'd0, 1'b1, 2500);
    check("valid period", period, CLK_PER_SYM_400K);
    check("valids in 2500 clk", v_cnt, 5);

    // ---- H: single shot at rate_sel = 1, 3 symbols ----
    $display("H: single shot at rate_sel=1, sym_num=3");
    run(1'b1, 23'd3, 1'b1, 4000);
    check("valids", v_cnt, 3);
    check("last-first", last_v - first_v, 2 * CLK_PER_SYM_400K);

    if (errors == 0) $display("ALL CHECKS PASSED");
    else             $display("FAILED CHECKS: %0d", errors);
    $display("DONE");
    $finish;
  end

endmodule

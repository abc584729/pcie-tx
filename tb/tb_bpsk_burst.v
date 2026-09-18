`timescale 1ns/1ps
// Burst (single-shot) mode check for rtl/bpsk_ram.v.
//
// bpsk_ram gains two inputs: `sym_num` (symbols per turn) and `single_shot`.
// Both modes count rdata_valid up to sym_num; they differ only in what happens
// once a turn is done -- single-shot latches `done` and goes silent, cyclic
// resets the count and the read pointer and starts the next turn at symbol 0.
// A cyclic burst is therefore sym_num symbols, a jump back to the top, and
// repeat forever, with the divider and the timebase never pausing.
//
// sym_num = 0 means "the whole table" (4194304) in cyclic mode, so the power-up
// default and a cyclic start with no size still send the full table as before.
// In single-shot it stays "send nothing".
//
// The DUT is bpsk_ram + dpram only -- bpsk.v cannot be elaborated here
// because the Xilinx cmpy/DDS IP it instantiates is not in the repo.
//
// Cases:
//   A cyclic, sym_num = 5            : 5 symbols then wrap, period 400 clk
//   B single shot, sym_num = 5       : exactly 5 valids, then silence
//   C single shot, sym_num = 1       : exactly 1 valid
//   D single shot, sym_num = 4194304 : full-table count still compares right
//   E single shot, sym_num = 0       : nothing at all is sent
//   F re-arm after B (rst_n pulse)   : exactly 5 again
//   G rate_sel = 1                   : period 450 clk (divider untouched)
//   H single shot, 3 symbols, 400k   : 3 valids at 450 clk spacing
//   I cyclic, time_sel = 5           : first symbol at timebase position 6
//   J single shot, 3 symbols, tsel=3 : gate + burst together
//   K rd_en low then high            : stops, then re-arms at the next window
//   L cyclic, sym_num = 7            : laps of 7, not of the whole table
//
// time_sel: the 1024-symbol timebase (bpsk_ram.cnt_1024) drives the read gate.
// The timebase is incremented by the same divider pulse that reads the table,
// so the pulse matching time_sel is spent arming tx_en and emits nothing; the
// first symbol therefore leaves at timebase position time_sel+1.
module tb_bpsk_burst;

  reg clk = 0;
  reg rst_n = 0;
  reg ram_en = 0;
  reg rate_sel = 0;
  reg single_shot = 0;
  reg [22:0] sym_num = 0;
  reg [9:0]  time_sel = 0;

  wire rdata;
  wire rdata_valid;
  wire busy;                    // new: 1 while this turn is being transmitted

  // write port of the table (only the first few words are needed)
  reg         u_wen = 0;
  reg  [17:0] u_waddr = 0;
  reg  [15:0] u_wdata = 0;

  bpsk_ram u_dut (
    .clk         (clk),
    .rst_n       (rst_n),
    .rd_en       (ram_en),
    .time_sel    (time_sel),
    .rate_sel    (rate_sel),
    .w_en        (u_wen),
    .w_addr      (u_waddr),
    .w_data      (u_wdata),
    .sym_num     (sym_num),
    .single_shot (single_shot),
    .rdata       (rdata),
    .rdata_valid (rdata_valid),
    .busy        (busy)
  );

  always #5 clk = ~clk;

  wire        rd_pulse = u_dut.flag_g;    // gated read pulse -> dpram r_en
  // divider pulse, taken straight off the divider: it must keep running whether
  // or not the burst logic is gating reads (`flag` is already tx_en-gated)
  wire        raw_pulse = (u_dut.count == u_dut.count_max - 1'b1);
  wire [22:0] rptr     = u_dut.rptr;

  localparam CLK_PER_SYM_450K = 400;
  localparam CLK_PER_SYM_400K = 450;

  // rdata_valid lands this many clk after ram_en rises, for time_sel = tsel:
  // the pulse at the end of symbol tsel arms tx_en (no read), symbol tsel+1 is
  // the first one read, and the dpram adds one clk of latency.
  function integer first_valid_at;
    input integer tsel;
    input integer per_sym;
    begin
      first_valid_at = per_sym * (tsel + 1) + per_sym - 2;
    end
  endfunction

  integer errors = 0;

  // per-run measurements
  integer v_cnt, p_cnt, t, first_v, last_v, period, rptr_end, rptr_end2;
  integer f_cnt, rptr_err;
  integer b_arm, b_end;                      // busy, one clk after rd_en rises / at the end
  integer exp_period;
  integer k_v, k_gap, k_period, k_prev;      // case K
  integer exp_len;                           // symbols per turn, for this run


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
    input [9:0]  tsel;
    input integer cycles;
    begin
      @(negedge clk);
      ram_en = 0; single_shot = ss; sym_num = n; rate_sel = sel; time_sel = tsel;
      exp_len = ((n == 23'd0) && !ss) ? 4194304 : n;   // must match rtl sym_len


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
        if (t == 0) b_arm = busy;        // one clk after rd_en rose
        if (rdata_valid) begin
          v_cnt = v_cnt + 1;
          // the k-th valid of a turn carries symbol k-1 and leaves rptr at k,
          // so over several turns rptr is k mod exp_len -- it jumps back to 0
          // at every turn boundary
          if (exp_len > 0 && rptr !== (v_cnt % exp_len)) rptr_err = rptr_err + 1;
          if (first_v < 0) first_v = t;
          else if (period < 0) period = t - first_v;
          last_v = t;
        end
        if (rd_pulse)   p_cnt = p_cnt + 1;
        if (raw_pulse)  f_cnt = f_cnt + 1;
      end

      rptr_end = rptr;
      b_end = busy;                    // sampled at the end of the measurement window
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

    // ---- A: cyclic honours sym_num too: 5 symbols, then back to symbol 0 ----
    $display("A: cyclic, single_shot=0, sym_num=5 (laps of 5)");
    run(1'b0, 23'd5, 1'b0, 10'd0, 4500);
    check("valid period", period, CLK_PER_SYM_450K);
    check("valids in 4500 clk (2 laps of 5)", v_cnt, 10);
    check("read pulses", p_cnt, 10);
    check("rptr wraps at sym_num-1", rptr_err, 0);
    check("busy right after rd_en", b_arm, 1);
    check("busy high at end (cyclic)", b_end, 1);

    // ---- B: single shot, 5 symbols ----
    $display("B: single shot, sym_num=5");
    run(1'b1, 23'd5, 1'b0, 10'd0, 4000);
    check("valids", v_cnt, 5);
    check("read pulses", p_cnt, 5);
    check("first valid at", first_v, first_valid_at(0, CLK_PER_SYM_450K));
    check("last-first", last_v - first_v, 4 * CLK_PER_SYM_450K);
    check("valid period", period, CLK_PER_SYM_450K);
    check("rptr frozen", rptr_end2, rptr_end);
    check("rptr tracks symbol index", rptr_err, 0);
    check("busy right after rd_en", b_arm, 1);
    check("busy low once the burst is done", b_end, 0);
    // the divider must keep running while the output is gated: 4000 clk of
    // period-400 pulses is 10 raw pulses against only 5 emitted symbols
    // (the pulse that arms tx_en is in there too -- it just reads nothing)
    check("raw divider pulses (not gated)", f_cnt, 10);

    // ---- C: single shot, 1 symbol ----
    $display("C: single shot, sym_num=1");
    run(1'b1, 23'd1, 1'b0, 10'd0, 4000);
    check("valids", v_cnt, 1);
    check("read pulses", p_cnt, 1);

    // ---- D: single shot, largest count (whole table) ----
    $display("D: single shot, sym_num=4194304 (whole table), short window");
    run(1'b1, 23'd4194304, 1'b0, 10'd0, 2500);
    check("valids in 2500 clk (must not stop early)", v_cnt, 5);

    // ---- E: single shot with sym_num = 0 -> send nothing ----
    $display("E: single shot, sym_num=0");
    run(1'b1, 23'd0, 1'b0, 10'd0, 2500);
    check("valids", v_cnt, 0);
    check("read pulses", p_cnt, 0);
    check("busy low when nothing is sent", b_arm, 0);
    check("busy stays low", b_end, 0);

    // ---- F: re-arm the same burst again ----
    $display("F: single shot, sym_num=5, second run");
    run(1'b1, 23'd5, 1'b0, 10'd0, 4000);
    check("valids", v_cnt, 5);
    check("read pulses", p_cnt, 5);

    // ---- G: rate_sel = 1 -> 450 clk / symbol, cyclic ----
    $display("G: cyclic at rate_sel=1");
    run(1'b0, 23'd0, 1'b1, 10'd0, 2500);
    check("valid period", period, CLK_PER_SYM_400K);
    check("valids in 2500 clk", v_cnt, 4);

    // ---- H: single shot at rate_sel = 1, 3 symbols ----
    $display("H: single shot at rate_sel=1, sym_num=3");
    run(1'b1, 23'd3, 1'b1, 10'd0, 4000);
    check("valids", v_cnt, 3);
    check("last-first", last_v - first_v, 2 * CLK_PER_SYM_400K);

    // ---- I: cyclic, time_sel = 5 -> first symbol at position 6 ----
    $display("I: cyclic, time_sel=5");
    run(1'b0, 23'd0, 1'b0, 10'd5, 4000);
    check("first valid at", first_v, first_valid_at(5, CLK_PER_SYM_450K));
    check("valid period", period, CLK_PER_SYM_450K);
    check("valids in 4000 clk", v_cnt, 4);

    // ---- J: single shot at rate_sel = 1 with time_sel = 3 ----
    $display("J: single shot at rate_sel=1, sym_num=3, time_sel=3");
    run(1'b1, 23'd3, 1'b1, 10'd3, 5000);
    check("first valid at", first_v, first_valid_at(3, CLK_PER_SYM_400K));
    check("valids", v_cnt, 3);
    check("read pulses", p_cnt, 3);
    check("last-first", last_v - first_v, 2 * CLK_PER_SYM_400K);

    // ---- K: RAM_EN (0x702) low must close the gate; raising it again waits
    //         for the next timebase window (up to one 1024-symbol frame) ----
    $display("K: rd_en low stops the TX, rd_en high re-arms at the next window");
    run(1'b0, 23'd0, 1'b0, 10'd0, 2000);        // get a cyclic burst running
    k_v = 0;
    for (t = 0; t < 3000; t = t + 1) begin @(posedge clk); #1; if (rdata_valid) k_v = k_v + 1; end
    check("K running before rd_en=0", k_v > 0, 1);

    @(negedge clk) ram_en = 0;                  // host writes 0x702 = 0
    k_v = 0;
    for (t = 0; t < 3000; t = t + 1) begin @(posedge clk); #1; if (rdata_valid) k_v = k_v + 1; end
    check("K valids while rd_en=0", k_v, 0);
    check("K tx_en closed", u_dut.tx_en, 0);
    check("K busy cleared by rd_en=0", busy, 0);
    // stopping also clears the burst counters, so raising rd_en starts a fresh
    // turn at symbol 0 instead of resuming mid-table
    check("K rptr cleared", rptr, 0);
    check("K sym_cnt cleared", u_dut.sym_cnt, 0);

    @(negedge clk) ram_en = 1;                  // and back to 1
    // busy follows rd_en, not the gate: it is high the very next clk, even though
    // the first symbol waits for the next timebase window
    @(posedge clk); #1;
    check("K busy high right after rd_en=1", busy, 1);
    k_gap = -1; k_v = 0; k_period = -1; k_prev = -1;
    for (t = 0; t < 1026 * CLK_PER_SYM_450K; t = t + 1) begin
      @(posedge clk); #1;
      if (rdata_valid) begin
        if (k_gap < 0) k_gap = t;
        else if (k_period < 0) k_period = t - k_gap;
        k_prev = t;
        k_v = k_v + 1;
      end
    end
    check("K resumed", k_v > 0, 1);
    check("K waited for the window", (k_gap >= CLK_PER_SYM_450K) && (k_gap <= 1027 * CLK_PER_SYM_450K), 1);
    check("K period after resume", k_period, CLK_PER_SYM_450K);

    // ---- L: cyclic with sym_num = 7 -> laps of 7, not of the whole table ----
    $display("L: cyclic, sym_num=7");
    run(1'b0, 23'd7, 1'b0, 10'd0, 4500);
    check("valids in 4500 clk", v_cnt, 10);
    check("rptr wraps at 6", rptr_err, 0);

    if (errors == 0) $display("ALL CHECKS PASSED");
    else             $display("FAILED CHECKS: %0d", errors);
    $display("DONE");
    $finish;
  end

endmodule

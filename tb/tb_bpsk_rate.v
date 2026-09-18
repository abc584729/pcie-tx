`timescale 1ns/1ps
// rate_sel check for bpsk.v.
//
// Checks, in order:
//   1) the RAM read pulse period is 400 clk (450 kHz) when rate_sel=0 and
//      450 clk (400 kHz) when rate_sel=1;
//   2) the attenuator output reaches the SELECTED chain only -- the other
//      chain drains to zero;
//   3) `sig` is driven by the selected chain, bit for bit, and the unselected
//      chain's output is never visible on it.
//
// The RAM is filled with 16'hAAAA so the bit stream alternates and the mapper
// output is a nonzero symbol every read pulse; a constant table would make
// "which chain is live" unobservable.
module tb_bpsk_rate;
  localparam PHASE = 4000;     // clk per rate_sel setting

  reg clk = 0;
  reg rst_n = 0;
  reg ram_en = 0;
  reg bpsk_en = 1;
  reg rate_sel = 0;

  wire [127:0] sig_i, sig_q;

  integer t, i;
  integer last_flag;
  integer period_450k, period_400k;

  // Write port of the table: fill 16'hAAAA over the whole 262144-word table.
  reg         u_wen = 0;
  reg  [17:0] u_waddr = 0;
  reg  [15:0] u_wdata = 0;

  bpsk u_dut (
    .clk         (clk),
    .rst_n       (rst_n),
    .ram_en      (ram_en),
    .bpsk_en     (bpsk_en),
    .rate_sel    (rate_sel),
    .dds_pinc    (16'd0),
    .dds_poff    (128'd0),
    .dds_rstn    (rst_n),
    .atten       (16'h4000),   // 0 dB
    .w_en        (u_wen),
    .w_addr      (u_waddr),
    .w_data      (u_wdata),
    .sym_num     (23'd0),      // cyclic + 0 = the whole table, as before sym_num existed
    .single_shot (1'b0),
    .time_sel    (10'd0),      // cyclic: gate opens with the timebase at 0
    .sig_i       (sig_i),
    .sig_q       (sig_q)
  );

  always #5 clk = ~clk;

  wire         rd_flag = u_dut.u_bpsk_ram.flag;         // one pulse / symbol
  wire [127:0] c450    = u_dut.sig_450;
  wire [127:0] c400    = u_dut.sig_400;
  wire [127:0] sig_sel = u_dut.sig;                     // the muxed chain output,
                                                        // upstream of the DDS cmpy

  integer mism_450, mism_400, nz450, nz400, nzsel;

  // Sample the chain comparison in the back half of each phase, after the
  // deselected chain has had time to drain.
  task sample;
    input sel;
    begin
      if (sel) begin
        if (sig_sel !== c400) mism_400 = mism_400 + 1;
        if (c400 != 128'd0) nz400 = nz400 + 1;
        if (c450 != 128'd0) nz450 = nz450 + 1;
      end
      else begin
        if (sig_sel !== c450) mism_450 = mism_450 + 1;
        if (c450 != 128'd0) nz450 = nz450 + 1;
        if (c400 != 128'd0) nz400 = nz400 + 1;
      end
      if (sig_sel != 128'd0) nzsel = nzsel + 1;
    end
  endtask

  initial begin
    // ---- fill the table ----
    rst_n = 0;
    repeat (4) @(posedge clk);
    @(negedge clk) rst_n = 1;
    for (i = 0; i < 262144; i = i + 1) begin
      @(negedge clk); u_wen = 1; u_waddr = i[17:0]; u_wdata = 16'hAAAA;
      @(posedge clk);
    end
    @(negedge clk); u_wen = 0; u_wdata = 0;

    // ---- phase 1: rate_sel = 0 -> 450 kHz ----
    rate_sel = 0; ram_en = 0;
    last_flag = -1; period_450k = -1;
    mism_450 = 0; mism_400 = 0; nz450 = 0; nz400 = 0; nzsel = 0;
    @(negedge clk) ram_en = 1;
    for (t = 0; t < PHASE; t = t + 1) begin
      @(posedge clk); #1;
      if (rd_flag) begin
        if (last_flag >= 0) period_450k = t - last_flag;
        last_flag = t;
      end
      if (t > PHASE/2) sample(1'b0);
    end
    $display("rate_sel=0: read pulse period = %0d clk (expect 400)", period_450k);
    $display("            sig != sig_450 : %0d clk", mism_450);
    $display("            sig_450 nonzero: %0d clk,  sig_400 nonzero: %0d clk", nz450, nz400);

    // ---- phase 2: rate_sel = 1 -> 400 kHz ----
    rate_sel = 1;
    last_flag = -1; period_400k = -1;
    mism_450 = 0; mism_400 = 0; nz450 = 0; nz400 = 0; nzsel = 0;
    for (t = 0; t < PHASE; t = t + 1) begin
      @(posedge clk); #1;
      if (rd_flag) begin
        if (last_flag >= 0) period_400k = t - last_flag;
        last_flag = t;
      end
      if (t > PHASE/2) sample(1'b1);
    end
    $display("rate_sel=1: read pulse period = %0d clk (expect 450)", period_400k);
    $display("            sig != sig_400 : %0d clk", mism_400);
    $display("            sig_400 nonzero: %0d clk,  sig_450 nonzero: %0d clk", nz400, nz450);
    $display("            sig nonzero    : %0d clk", nzsel);

    $display("DONE");
    $finish;
  end
endmodule

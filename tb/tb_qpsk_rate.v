`timescale 1ns/1ps
// rate_sel check for qpsk.v -- same shape as tb_bpsk_rate.v.
//
// Checks, in order:
//   1) the RAM read pulse period is 40 clk (4.5 MHz) when rate_sel=0 and
//      27 clk (6.667 MHz) when rate_sel=1;
//   2) the attenuator output reaches the SELECTED chain only;
//   3) sig_i_par / sig_q_par are driven by the selected chain, bit for bit.
//
// The RAM is filled with 16'hAAAA so the 2-bit symbol stream is nonzero;
// a zero table would make "which chain is live" unobservable.
module tb_qpsk_rate;
  localparam PHASE = 2000;     // clk per rate_sel setting

  reg clk = 0;
  reg rst_n = 0;
  reg ram_en = 0;
  reg qpsk_en = 1;
  reg rate_sel = 0;

  wire [127:0] sig_i, sig_q;

  integer t, i;
  integer last_flag;
  integer period_4500k, period_6667k;

  // Write port of the table: fill 16'hAAAA over the whole 32768-word table.
  reg         u_wen = 0;
  reg  [14:0] u_waddr = 0;
  reg  [15:0] u_wdata = 0;

  qpsk u_dut (
    .clk      (clk),
    .rst_n    (rst_n),
    .ram_en   (ram_en),
    .qpsk_en  (qpsk_en),
    .rate_sel (rate_sel),
    .dds_pinc (16'd0),
    .dds_poff (128'd0),
    .dds_rstn (rst_n),
    .atten    (16'h4000),      // 0 dB
    .w_en     (u_wen),
    .w_addr   (u_waddr),
    .w_data   (u_wdata),
    .sig_i    (sig_i),
    .sig_q    (sig_q)
  );

  always #5 clk = ~clk;

  wire         rd_flag = u_dut.u_qpsk_ram.flag;         // one pulse / symbol
  wire [127:0] ci4500  = u_dut.sig_i_4500;
  wire [127:0] cq4500  = u_dut.sig_q_4500;
  wire [127:0] ci6667  = u_dut.sig_i_6667;
  wire [127:0] cq6667  = u_dut.sig_q_6667;
  wire [127:0] si_sel  = u_dut.sig_i_par;               // muxed, upstream of the cmpy
  wire [127:0] sq_sel  = u_dut.sig_q_par;

  integer mism, nzsel, nz_other;

  // Sampled in the back half of each phase, after the deselected chain has
  // had time to drain.
  task sample;
    input sel;
    begin
      if (sel) begin
        if (si_sel !== ci6667) mism = mism + 1;
        if (sq_sel !== cq6667) mism = mism + 1;
        if ((ci6667 != 128'd0) || (cq6667 != 128'd0)) nzsel = nzsel + 1;
        if ((ci4500 != 128'd0) || (cq4500 != 128'd0)) nz_other = nz_other + 1;
      end
      else begin
        if (si_sel !== ci4500) mism = mism + 1;
        if (sq_sel !== cq4500) mism = mism + 1;
        if ((ci4500 != 128'd0) || (cq4500 != 128'd0)) nzsel = nzsel + 1;
        if ((ci6667 != 128'd0) || (cq6667 != 128'd0)) nz_other = nz_other + 1;
      end
    end
  endtask

  initial begin
    // ---- fill the table ----
    rst_n = 0;
    repeat (4) @(posedge clk);
    @(negedge clk) rst_n = 1;
    for (i = 0; i < 32768; i = i + 1) begin
      @(negedge clk); u_wen = 1; u_waddr = i[14:0]; u_wdata = 16'hAAAA;
      @(posedge clk);
    end
    @(negedge clk); u_wen = 0; u_wdata = 0;

    // ---- phase 1: rate_sel = 0 -> 4.5 MHz ----
    rate_sel = 0; ram_en = 0;
    last_flag = -1; period_4500k = -1;
    mism = 0; nzsel = 0; nz_other = 0;
    @(negedge clk) ram_en = 1;
    for (t = 0; t < PHASE; t = t + 1) begin
      @(posedge clk); #1;
      if (rd_flag) begin
        if (last_flag >= 0) period_4500k = t - last_flag;
        last_flag = t;
      end
      if (t > PHASE/2) sample(1'b0);
    end
    $display("rate_sel=0: read pulse period = %0d clk (expect 40)", period_4500k);
    $display("            selected output mismatches : %0d", mism);
    $display("            selected chain nonzero     : %0d clk", nzsel);
    $display("            other chain nonzero        : %0d clk", nz_other);

    // ---- phase 2: rate_sel = 1 -> 6.667 MHz ----
    rate_sel = 1;
    last_flag = -1; period_6667k = -1;
    mism = 0; nzsel = 0; nz_other = 0;
    for (t = 0; t < PHASE; t = t + 1) begin
      @(posedge clk); #1;
      if (rd_flag) begin
        if (last_flag >= 0) period_6667k = t - last_flag;
        last_flag = t;
      end
      if (t > PHASE/2) sample(1'b1);
    end
    $display("rate_sel=1: read pulse period = %0d clk (expect 27)", period_6667k);
    $display("            selected output mismatches : %0d", mism);
    $display("            selected chain nonzero     : %0d clk", nzsel);
    $display("            other chain nonzero        : %0d clk", nz_other);

    $display("DONE");
    $finish;
  end
endmodule

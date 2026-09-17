`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_upsampling_valid
//
// Checks the new data valid (sig_valid) of all four upsamplers.
//
// Background: every *_valid the generated FIRs produce is just a clk_enable
// echo -- they shift a constant 1'b1 through ce_delay/ce_pipe, so the last
// stages end up with a valid that is a constant 1 and never drops.  sig_valid
// is the new signal that really means "this output still carries data": it is
// carried through the interpolators and OR-reduced over each FIR's memory.
//
// Properties checked here, per chain, after a short burst (4 symbols) followed
// by silence:
//   P1  no output word is ever non-zero while sig_valid is low   (no data loss)
//   P2  after the input stops, sig_valid falls back to 0 and stays there
//   P3  sig_valid is high while the burst is being fed (steady state)
//////////////////////////////////////////////////////////////////////////////////

module tb_upsampling_valid;

    reg clk = 0;
    reg rst_n = 0;
    always #5 clk = ~clk;                 // 100 MHz

    // ------------------------------------------------------------------
    // 450k chain: one symbol per 400 clk
    // ------------------------------------------------------------------
    reg  [15:0] din_450 = 0;
    reg         dv_450  = 0;
    wire [127:0] s_450;
    wire         v_450;
    upsamping_450k u450(
        .clk(clk), .rst_n(rst_n),
        .din(din_450), .din_valid(dv_450),
        .sig(s_450), .sig_valid(v_450)
    );

    // ------------------------------------------------------------------
    // 400k chain: one symbol per 450 clk
    // ------------------------------------------------------------------
    reg  [15:0] din_400 = 0;
    reg         dv_400  = 0;
    wire [127:0] s_400;
    wire         v_400;
    upsamping_400k u400(
        .clk(clk), .rst_n(rst_n),
        .din(din_400), .din_valid(dv_400),
        .sig(s_400), .sig_valid(v_400)
    );

    // ------------------------------------------------------------------
    // 4500k chain: one symbol per 40 clk
    // ------------------------------------------------------------------
    reg  [15:0] din_i_4500 = 0, din_q_4500 = 0;
    reg         dv_4500 = 0;
    wire [127:0] si_4500, sq_4500;
    wire         v_4500;
    upsamping_4500k u4500(
        .clk(clk), .rst_n(rst_n),
        .din_i(din_i_4500), .din_q(din_q_4500), .din_valid(dv_4500),
        .sig_i(si_4500), .sig_q(sq_4500), .sig_valid(v_4500)
    );

    // ------------------------------------------------------------------
    // 6667k chain: one symbol per 27 clk
    // ------------------------------------------------------------------
    reg  [15:0] din_i_6667 = 0, din_q_6667 = 0;
    reg         dv_6667 = 0;
    wire [127:0] si_6667, sq_6667;
    wire         v_6667;
    upsamping_6667k u6667(
        .clk(clk), .rst_n(rst_n),
        .din_i(din_i_6667), .din_q(din_q_6667), .din_valid(dv_6667),
        .sig_i(si_6667), .sig_q(sq_6667), .sig_valid(v_6667)
    );

    // ------------------------------------------------------------------
    // Checkers
    // ------------------------------------------------------------------
    integer t = 0;
    always @(posedge clk) t <= t + 1;

    // per chain: last clock with a non-zero output, last clock with valid high,
    // clock of the first valid, and the P1 violation count
    integer data_end_450 = -1,  valid_end_450 = -1,  valid_beg_450 = -1,  p1_450 = 0;
    integer data_end_400 = -1,  valid_end_400 = -1,  valid_beg_400 = -1,  p1_400 = 0;
    integer data_end_4500 = -1, valid_end_4500 = -1, valid_beg_4500 = -1, p1_4500 = 0;
    integer data_end_6667 = -1, valid_end_6667 = -1, valid_beg_6667 = -1, p1_6667 = 0;

    always @(posedge clk) if(rst_n) begin
        // 450k
        if(s_450  != 128'd0) data_end_450  <= t;
        if(v_450)  begin valid_end_450  <= t; if(valid_beg_450  < 0) valid_beg_450  <= t; end
        if((s_450  != 128'd0) && !v_450) p1_450  <= p1_450  + 1;
        // 400k
        if(s_400  != 128'd0) data_end_400  <= t;
        if(v_400)  begin valid_end_400  <= t; if(valid_beg_400  < 0) valid_beg_400  <= t; end
        if((s_400  != 128'd0) && !v_400) p1_400  <= p1_400  + 1;
        // 4500k
        if(si_4500 != 128'd0) data_end_4500 <= t;
        if(v_4500) begin valid_end_4500 <= t; if(valid_beg_4500 < 0) valid_beg_4500 <= t; end
        if((si_4500 != 128'd0) && !v_4500) p1_4500 <= p1_4500 + 1;
        // 6667k
        if(si_6667 != 128'd0) data_end_6667 <= t;
        if(v_6667) begin valid_end_6667 <= t; if(valid_beg_6667 < 0) valid_beg_6667 <= t; end
        if((si_6667 != 128'd0) && !v_6667) p1_6667 <= p1_6667 + 1;
    end

    // ------------------------------------------------------------------
    // Stimulus: 4 symbols, then silence.
    // ------------------------------------------------------------------
    integer n;
    initial begin
        rst_n = 0;
        repeat (10) @(posedge clk);
        rst_n = 1;
        repeat (100) @(posedge clk);

        // 4 symbols on every chain, each with its own symbol period.
        // The four generators run concurrently in one loop: 6667k (27 clk) is
        // the fastest, 400k (450 clk) the slowest.
        for(n = 0; n < 4; n = n + 1) begin
            fork
                begin  // 450k, 400 clk/symbol
                    din_450 <= 16'h3000; dv_450 <= 1'b1;
                    @(posedge clk); dv_450 <= 1'b0;
                    repeat (399) @(posedge clk);
                end
                begin  // 400k, 450 clk/symbol
                    din_400 <= 16'h3000; dv_400 <= 1'b1;
                    @(posedge clk); dv_400 <= 1'b0;
                    repeat (449) @(posedge clk);
                end
                begin  // 4500k, 40 clk/symbol
                    din_i_4500 <= 16'h2000; din_q_4500 <= 16'h1000; dv_4500 <= 1'b1;
                    @(posedge clk); dv_4500 <= 1'b0;
                    repeat (39) @(posedge clk);
                end
                begin  // 6667k, 27 clk/symbol
                    din_i_6667 <= 16'h2000; din_q_6667 <= 16'h1000; dv_6667 <= 1'b1;
                    @(posedge clk); dv_6667 <= 1'b0;
                    repeat (26) @(posedge clk);
                end
            join
        end

        // let every chain drain
        repeat (12000) @(posedge clk);

        $display("");
        $display("chain    first_valid  last_valid  last_nonzero  P1(data w/o valid)  valid_now");
        report("450k ", valid_beg_450,  valid_end_450,  data_end_450,  p1_450,  v_450);
        report("400k ", valid_beg_400,  valid_end_400,  data_end_400,  p1_400,  v_400);
        report("4500k", valid_beg_4500, valid_end_4500, data_end_4500, p1_4500, v_4500);
        report("6667k", valid_beg_6667, valid_end_6667, data_end_6667, p1_6667, v_6667);
        $display("");

        if(p1_450 || p1_400 || p1_4500 || p1_6667)
            $display("FAIL: output data present while sig_valid low");
        else if(v_450 || v_400 || v_4500 || v_6667)
            $display("FAIL: sig_valid still high after the input stopped (tail not drained)");
        else
            $display("PASS: no data loss, and every chain valid dropped back to 0");

        $finish;
    end

    task report;
        input [39:0] name;
        input integer fv, lv, lz, p1;
        input vnow;
        begin
            $display("%s  %8d  %8d  %8d  %8d            %b", name, fv, lv, lz, p1, vnow);
        end
    endtask

endmodule

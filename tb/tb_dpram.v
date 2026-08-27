`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_dpram
//
// Self-check for the asymmetric dual-port RAM dpram.v and its wrappers
// bpsk_ram.v / qpsk_ram.v.
//
//   phase 1 : pure read of the 512 preloaded bits (no writes) against a
//             $readmemb mirror of mem/ram.mem
//   phase 2 : write word 0 = 0xA55A, read back its 16 bits
//   phase 3 : read-first: write word 0 = 0x5A5A on the same cycle a bit
//             is read -> must return the old value (0xA55A bit 0)
//   phase 4 : bpsk_ram reads 8 bits, 1 per symbol
//   phase 5 : qpsk_ram reads 4 symbols (8 bits), 2 per symbol
//
// Run from rtl/ so "mem/ram.mem" resolves:
//   iverilog -g2001 -o <out> ../tb/tb_dpram.v dpram.v bpsk_ram.v qpsk_ram.v
//   vvp <out>
//////////////////////////////////////////////////////////////////////////////////
module tb_dpram;

    reg clk = 0;
    always #5 clk = ~clk;

    reg rst_n = 0;

    // mirror of mem/ram.mem
    reg [15:0] exp [0:31];
    initial $readmemb("mem/ram.mem", exp);

    // ================= standalone dpram =================
    reg w_en = 0;
    reg [4:0]  w_addr = 0;
    reg [15:0] w_data = 0;
    reg r_en = 0;
    reg [8:0]  r_addr = 0;
    wire r_data, r_data_valid;

    dpram #(.DEPTH(32), .WADDR(5), .RADDR(9)) u_dpram(
        .clk          (clk),
        .rst_n        (rst_n),
        .w_en         (w_en),
        .w_addr       (w_addr),
        .w_data       (w_data),
        .r_en         (r_en),
        .r_addr       (r_addr),
        .r_data       (r_data),
        .r_data_valid (r_data_valid)
    );

    // ================= dpram with READ_WIDTH=2 =================
    reg r_en2 = 0;
    reg [7:0] r_addr2 = 0;
    wire [1:0] r_data2;
    wire r_data2_valid;

    dpram #(.DEPTH(32), .WADDR(5), .READ_WIDTH(2), .RADDR(8)) u_dpram2(
        .clk          (clk),
        .rst_n        (rst_n),
        .w_en         (1'b0),
        .w_addr       (5'd0),
        .w_data       (16'd0),
        .r_en         (r_en2),
        .r_addr       (r_addr2),
        .r_data       (r_data2),
        .r_data_valid (r_data2_valid)
    );

    // ================= bpsk_ram wrapper =================
    wire bdata, bvalid;
    bpsk_ram u_bpsk(
        .clk(clk), .rst_n(rst_n),
        .rd_en(1'b1),
        .w_en(1'b0), .w_addr(5'd0), .w_data(16'd0),
        .rdata(bdata), .rdata_valid(bvalid)
    );

    // ================= qpsk_ram wrapper =================
    wire [1:0] qdata;
    wire qvalid;
    qpsk_ram u_qpsk(
        .clk(clk), .rst_n(rst_n),
        .rd_en(1'b1),
        .w_en(1'b0), .w_addr(5'd0), .w_data(16'd0),
        .rdata(qdata), .rdata_valid(qvalid)
    );

    // ================= checkers =================
    integer errs = 0;

    integer bcnt = 0, bmism = 0;
    always @(negedge clk) begin
        if (rst_n) begin
            if (bvalid) begin
                if (bdata !== exp[bcnt>>4][bcnt[3:0]]) begin
                    bmism = bmism + 1;
                    if (bmism <= 8)
                        $display("bpsk bit %0d : got=%b want=%b",
                                 bcnt, bdata, exp[bcnt>>4][bcnt[3:0]]);
                end
                bcnt = bcnt + 1;
            end
        end
    end

    integer qcnt = 0, qmism = 0;
    reg [8:0] bidx;
    always @(negedge clk) begin
        if (rst_n) begin
            if (qvalid) begin
                bidx = 2*qcnt;
                if (qdata[0] !== exp[bidx>>4][bidx[3:0]]) begin
                    qmism = qmism + 1;
                    if (qmism <= 8)
                        $display("qpsk sym %0d bit0 : got=%b want=%b",
                                 qcnt, qdata[0], exp[bidx>>4][bidx[3:0]]);
                end
                bidx = 2*qcnt + 1;
                if (qdata[1] !== exp[bidx>>4][bidx[3:0]]) begin
                    qmism = qmism + 1;
                    if (qmism <= 8)
                        $display("qpsk sym %0d bit1 : got=%b want=%b",
                                 qcnt, qdata[1], exp[bidx>>4][bidx[3:0]]);
                end
                qcnt = qcnt + 1;
            end
        end
    end

    // ================= stimulus =================
    integer i;
    reg [15:0] wref;

    initial begin
        repeat (3) @(posedge clk);
        #1 rst_n = 1;

        // ---- phase 1: pure read of all 512 preloaded bits ----
        for (i = 0; i < 512; i = i + 1) begin
            @(negedge clk);
            r_addr = i;
            r_en   = 1'b1;
            @(posedge clk);
            @(negedge clk);
            if (!r_data_valid) begin
                errs = errs + 1;
                if (errs <= 8) $display("ph1 no valid @ bit %0d", i);
            end
            else if (r_data !== exp[i>>4][i[3:0]]) begin
                errs = errs + 1;
                if (errs <= 8)
                    $display("ph1 bit %0d : got=%b want=%b",
                             i, r_data, exp[i>>4][i[3:0]]);
            end
        end
        @(negedge clk);
        r_en = 0;
        $display("phase1 pure-read 512 bits : %0d errors", errs);

        // ---- phase 2: write word 0 = 0xA55A, read back 16 bits ----
        wref = 16'hA55A;
        @(negedge clk);
        w_en = 1'b1; w_addr = 5'd0; w_data = wref;
        @(posedge clk);
        @(negedge clk);
        w_en = 0;
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk);
            r_addr = i;
            r_en   = 1'b1;
            @(posedge clk);
            @(negedge clk);
            if (!r_data_valid) begin
                errs = errs + 1;
                if (errs <= 8) $display("ph2 no valid @ bit %0d", i);
            end
            else if (r_data !== wref[i]) begin
                errs = errs + 1;
                if (errs <= 8)
                    $display("ph2 bit %0d : got=%b want=%b",
                             i, r_data, wref[i]);
            end
        end
        @(negedge clk);
        r_en = 0;
        $display("phase2 write/read word0=A55A : %0d errors", errs);

        // ---- phase 3: read-first (same-cycle write+read) ----
        // word 0 currently holds 0xA55A (from phase 2)
        @(negedge clk);
        w_en = 1'b1; w_addr = 5'd0; w_data = 16'h5A5A;
        r_addr = 9'd0; r_en = 1'b1;
        @(posedge clk);
        @(negedge clk);
        if (!r_data_valid) begin
            errs = errs + 1;
            $display("ph3 no valid");
        end
        else if (r_data !== wref[0]) begin
            errs = errs + 1;
            $display("ph3 read-first fail : got=%b want=%b (old A55A bit0)",
                     r_data, wref[0]);
        end
        @(negedge clk);
        w_en = 0; r_en = 0;
        $display("phase3 read-first : %0d errors", errs);

        // ---- phase 3b: READ_WIDTH=2 pure read of all 256 groups ----
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge clk);
            r_addr2 = i;
            r_en2   = 1'b1;
            @(posedge clk);
            @(negedge clk);
            if (!r_data2_valid) begin
                errs = errs + 1;
                if (errs <= 8) $display("ph3b no valid @ group %0d", i);
            end
            else if (r_data2 !== exp[i>>3][(i[2:0])*2 +: 2]) begin
                errs = errs + 1;
                if (errs <= 8)
                    $display("ph3b group %0d : got=%b want=%b",
                             i, r_data2, exp[i>>3][(i[2:0])*2 +: 2]);
            end
        end
        @(negedge clk);
        r_en2 = 0;
        $display("phase3b READ_WIDTH=2 pure-read 256 groups : %0d errors", errs);

        // ---- wait for wrappers to collect enough symbols ----
        // bpsk: 8 bits = 3200 clocks; qpsk: 4 symbols = 1600 clocks
        @(negedge clk);
        wait (bcnt >= 8 && qcnt >= 4);
        $display("phase4 bpsk_ram : %0d bits, %0d mismatches", bcnt, bmism);
        $display("phase5 qpsk_ram : %0d symbols, %0d mismatches", qcnt, qmism);

        if (errs == 0 && bmism == 0 && qmism == 0 && bcnt >= 8 && qcnt >= 4)
            $display("************** TEST COMPLETED (PASSED) **************");
        else
            $display("************** TEST COMPLETED (FAILED) **************");
        $finish;
    end

    initial begin // timeout guard
        #300000;
        $display("TIMEOUT: errs=%0d bcnt=%0d qcnt=%0d", errs, bcnt, qcnt);
        $finish;
    end

endmodule
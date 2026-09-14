`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/28 09:04:44
// Design Name: 
// Module Name: tb_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_tx(

    );

    reg clk, rst_n, ram_en;
    reg bpsk_en, qpsk_en;
    reg rate_sel;              // 0 = 450 kHz / 4.5 MHz, 1 = 400 kHz / 6.667 MHz
    reg dds_rstn;
    reg [15:0] dds_pinc_bpsk, dds_pinc_qpsk;
    reg [127:0] dds_poff_bpsk, dds_poff_qpsk;
    reg signed [15:0] atten_bpsk, atten_qpsk;   // Q1.14: 0x4000 = 1.0 = 0 dB
    wire [255:0] iq;
    wire [127:0] i;
    wire [127:0] q;


    integer fp;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        ram_en = 0;
        bpsk_en = 1;
        qpsk_en = 1;
        rate_sel = 0;               // keep the original rates for this test
        dds_rstn = 0;
        atten_bpsk = 16'sd16384;    // Q1.14 0x4000 = 1.0 = 0 dB
        atten_qpsk = 16'sd16384;    // Q1.14 0x4000 = 1.0 = 0 dB
        fp = $fopen("D:/result.csv", "w");
        # 10;
        rst_n = 1;
        dds_pinc_bpsk = 16'h8E39;    // 100mhz: 65536*100/180 = 36409
        dds_pinc_qpsk = 16'h1C72;    // 200mhz: 65536*200/180 = 72818 -> mod 2^16 = 7282
        dds_poff_bpsk = 128'h838E_9555_A71C_B8E4_CAAB_DC72_EE39_0000;    // lane k: -k*36409/8 (dds negates streamed poff)
        dds_poff_qpsk = 128'h071C_2AAB_4E39_71C7_9555_B8E4_DC72_0000;    // lane k: -k*72818/8 mod 2^16
        # 10;
        dds_rstn = 1;
        # 10;
        ram_en = 1;
        # 1000000;
        $fclose(fp);
        $display("Simulation done, file closed successfully.");
        $stop;
    end

    always @(posedge clk) begin
        if (rst_n) begin
            $fdisplay(fp, "%b", i);
            $fdisplay(fp, "%b", q);
        end
    end

    tx_top dut(
        .clk            (clk),
        .rst_n          (rst_n),
        .ram_en         (ram_en),
        .bpsk_en        (bpsk_en),
        .qpsk_en        (qpsk_en),
        .rate_sel       (rate_sel),
        .dds_rstn       (dds_rstn),
        .dds_pinc_bpsk  (dds_pinc_bpsk),
        .dds_pinc_qpsk  (dds_pinc_qpsk),
        .dds_poff_bpsk  (dds_poff_bpsk),
        .dds_poff_qpsk  (dds_poff_qpsk),
        .atten_bpsk (atten_bpsk),
        .atten_qpsk (atten_qpsk),
        .iq             (iq)
    );

    // tx_top iq packing is {q7,i7,q6,i6,...,q0,i0}, 16 bit per lane
    assign i = {iq[239:224], iq[207:192], iq[175:160], iq[143:128],
                iq[111:96],  iq[79:64],   iq[47:32],   iq[15:0]};
    assign q = {iq[255:240], iq[223:208], iq[191:176], iq[159:144],
                iq[127:112], iq[95:80],   iq[63:48],   iq[31:16]};

endmodule
`timescale 1ns/1ps

module xad_tb;
    reg        clk;
    reg        rst_n;

    reg        cpu_valid;
    reg        cpu_rw;
    reg [34:0] cpu_addr;
    reg [63:0] cpu_wdata;
    wire [63:0] cpu_rdata;
    wire        cpu_ready;

    reg        alloc_valid;
    reg [7:0]  alloc_pid;
    reg [5:0]  alloc_count;
    reg        alloc_is_reserve;
    wire       alloc_success;

    // Instantiate System Under Test
    xad_hpmi_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .cpu_valid(cpu_valid),
        .cpu_rw(cpu_rw),
        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),
        .cpu_rdata(cpu_rdata),
        .cpu_ready(cpu_ready),
        .alloc_valid(alloc_valid),
        .alloc_pid(alloc_pid),
        .alloc_count(alloc_count),
        .alloc_is_reserve(alloc_is_reserve),
        .alloc_success(alloc_success)
    );

    // 100MHz Clock Generator
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        cpu_valid = 0;
        cpu_rw = 0;
        cpu_addr = 0;
        cpu_wdata = 0;
        alloc_valid = 0;
        alloc_pid = 0;
        alloc_count = 0;
        alloc_is_reserve = 0;

        #20 rst_n = 1;
        #10;

        // Step 1: Allocate 2 subcells for PID 10
        $display("[TB] Requesting 2 Subcells for Process 10...");
        alloc_valid = 1;
        alloc_pid   = 8'd10;
        alloc_count = 6'd2;
        alloc_is_reserve = 0;
        #10 alloc_valid = 0;
        #20;

        // Step 2: Write Data to Subcell 0
        $display("[TB] Writing 0xDEADBEEFCAFECAFE to Physical Address 0x0...");
        cpu_valid = 1;
        cpu_rw    = 1;
        cpu_addr  = 35'h0_0000_0000;
        cpu_wdata = 64'hDEADBEEFCAFECAFE;
        #10 cpu_valid = 0;
        #20;

        // Step 3: Read Data Back from Subcell 0
        $display("[TB] Reading back from Physical Address 0x0...");
        cpu_valid = 1;
        cpu_rw    = 0;
        cpu_addr  = 35'h0_0000_0000;
        #10 cpu_valid = 0;
        #20;

        $display("[TB] Read Data Result: %h", cpu_rdata);
        if (cpu_rdata == 64'hDEADBEEFCAFECAFE)
            $display("[TB] TEST PASSED!");
        else
            $display("[TB] TEST FAILED!");

        $finish;
    end
endmodule
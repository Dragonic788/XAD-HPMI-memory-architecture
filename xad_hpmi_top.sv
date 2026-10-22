module xad_hpmi_top (
    input  wire        clk,
    input  wire        rst_n,

    // Host CPU Access
    input  wire        cpu_valid,
    input  wire        cpu_rw,
    input  wire [34:0] cpu_addr,
    input  wire [63:0] cpu_wdata,
    output wire [63:0] cpu_rdata,
    output wire        cpu_ready,

    // OS Control Interface
    input  wire        alloc_valid,
    input  wire [7:0]  alloc_pid,
    input  wire [5:0]  alloc_count,
    input  wire        alloc_is_reserve,
    output wire        alloc_success
);

    wire [5:0]  subcell_id   = cpu_addr[34:29];
    wire [28:0] local_offset = cpu_addr[28:0];

    wire [1:0]  slt_state;
    wire [7:0]  slt_owner;
    wire [1:0]  slt_target_mc;

    wire        slt_wen;
    wire [5:0]  slt_wid;
    wire [1:0]  slt_wstate;
    wire [7:0]  slt_wowner;
    wire [1:0]  slt_wmc;

    // Subcell Lookup Table
    slt_table slt_inst (
        .clk(clk),
        .rst_n(rst_n),
        .read_subcell_id(subcell_id),
        .out_state(slt_state),
        .out_owner(slt_owner),
        .out_target_mc(slt_target_mc),
        .write_en(slt_wen),
        .write_subcell_id(slt_wid),
        .write_state(slt_wstate),
        .write_owner(slt_wowner),
        .write_target_mc(slt_wmc)
    );

    // Allocation Unit
    xad_allocator alloc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .req_valid(alloc_valid),
        .req_process_id(alloc_pid),
        .req_count(alloc_count),
        .req_is_reserve(alloc_is_reserve),
        .req_success(alloc_success),
        .slt_write_en(slt_wen),
        .slt_write_id(slt_wid),
        .slt_write_state(slt_wstate),
        .slt_write_owner(slt_wowner),
        .slt_write_mc(slt_wmc)
    );

    // Crossbar Switch & Memory Interface
    switch_fabric fabric_inst (
        .clk(clk),
        .rst_n(rst_n),
        .req_valid(cpu_valid && (slt_state == 2'b01)), // Active state check
        .req_rw(cpu_rw),
        .target_mc(slt_target_mc),
        .local_offset(local_offset),
        .write_data(cpu_wdata),
        .read_data(cpu_rdata),
        .ready(cpu_ready)
    );

endmodule
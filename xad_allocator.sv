module xad_allocator #(
    parameter TOTAL_SUBCELLS = 64
)(
    input  wire        clk,
    input  wire        rst_n,

    // Request Interface
    input  wire        req_valid,
    input  wire [7:0]  req_process_id,
    input  wire [5:0]  req_count,
    input  wire        req_is_reserve,
    output reg         req_success,

    // SLT Write Interface
    output reg         slt_write_en,
    output reg  [5:0]  slt_write_id,
    output reg  [1:0]  slt_write_state,
    output reg  [7:0]  slt_write_owner,
    output reg  [1:0]  slt_write_mc
);

    // Internal tracker mirroring SLT state for fast allocation scans
    reg [1:0] subcell_state [0:TOTAL_SUBCELLS-1];

    integer i;
    reg [5:0] free_count;

    always_comb begin
        free_count = 0;
        for (i = 0; i < TOTAL_SUBCELLS; i = i + 1) begin
            
            if (subcell_state[i] == 2'b00) begin
                free_count = free_count + 1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            req_success     <= 1'b0;
            slt_write_en    <= 1'b0;
            for (i = 0; i < TOTAL_SUBCELLS; i = i + 1) begin
                subcell_state[i] <= 2'b00;
            end
        end else begin
            slt_write_en <= 1'b0;
            req_success  <= 1'b0;

            // Auto-reclaim Soft Reserves under high pressure (<10% free)
            if (free_count < 7) begin
                for (i = 0; i < TOTAL_SUBCELLS; i = i + 1) begin
                    if (subcell_state[i] == 2'b10) begin // SOFT_RESERVE
                        subcell_state[i] <= 2'b00;
                    end
                end
            end

            // Allocation Processing
            if (req_valid && (free_count >= req_count)) begin
                reg [5:0] assigned;
                assigned = 0;
                for (i = 0; i < TOTAL_SUBCELLS; i = i + 1) begin
                    if ((subcell_state[i] == 2'b00) && (assigned < req_count)) begin
                        subcell_state[i] <= req_is_reserve ? 2'b10 : 2'b01;
                        slt_write_en    <= 1'b1;
                        slt_write_id    <= i[5:0];
                        slt_write_state <= req_is_reserve ? 2'b10 : 2'b01;
                        slt_write_owner <= req_process_id;
                        slt_write_mc    <= i[1:0];
                        assigned        = assigned + 1;
                    end
                end
                req_success <= 1'b1;
            end
        end
    end
endmodule
module slt_table #(
    parameter TOTAL_SUBCELLS = 64
)(
    input  wire        clk,
    input  wire        rst_n,
    
    // Lookup Port (1-cycle read)
    input  wire [5:0]  read_subcell_id,
    output wire [1:0]  out_state,
    output wire [7:0]  out_owner,
    output wire [1:0]  out_target_mc,

    // Write Port (from Allocator)
    input  wire        write_en,
    input  wire [5:0]  write_subcell_id,
    input  wire [1:0]  write_state,
    input  wire [7:0]  write_owner,
    input  wire [1:0]  write_target_mc
);

    reg [1:0] state [0:TOTAL_SUBCELLS-1];
    reg [7:0] owner [0:TOTAL_SUBCELLS-1];
    reg [1:0] mc    [0:TOTAL_SUBCELLS-1];

    assign out_state     = state[read_subcell_id];
    assign out_owner     = owner[read_subcell_id];
    assign out_target_mc = mc[read_subcell_id];

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < TOTAL_SUBCELLS; i = i + 1) begin
                state[i] <= 2'b00; // FREE
                owner[i] <= 8'h00;
                mc[i]    <= i[1:0]; // Round-robin striping
            end
        end else if (write_en) begin
            state[write_subcell_id] <= write_state;
            owner[write_subcell_id] <= write_owner;
            mc[write_subcell_id]    <= write_target_mc;
        end
    end
endmodule
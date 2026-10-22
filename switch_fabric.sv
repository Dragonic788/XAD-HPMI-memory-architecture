module switch_fabric (
    input  wire        clk,
    input  wire        rst_n,

    // CPU Stream Input
    input  wire        req_valid,
    input  wire        req_rw,        // 0 = Read, 1 = Write
    input  wire [1:0]  target_mc,
    input  wire [28:0] local_offset,
    input  wire [63:0] write_data,
    output reg  [63:0] read_data,
    output reg         ready
);

    // Mock Memory Arrays (Sparse representation for simulator safety)
    reg [63:0] dram_mc0 [0:255];
    reg [63:0] dram_mc1 [0:255];
    reg [63:0] dram_mc2 [0:255];
    reg [63:0] dram_mc3 [0:255];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data <= 64'h0;
            ready     <= 1'b0;
        end else begin
            ready <= 1'b0;
            if (req_valid) begin
                ready <= 1'b1;
                case (target_mc)
                    2'b00: begin
                        if (req_rw) dram_mc0[local_offset[7:0]] <= write_data;
                        else        read_data <= dram_mc0[local_offset[7:0]];
                    end
                    2'b01: begin
                        if (req_rw) dram_mc1[local_offset[7:0]] <= write_data;
                        else        read_data <= dram_mc1[local_offset[7:0]];
                    end
                    2'b10: begin
                        if (req_rw) dram_mc2[local_offset[7:0]] <= write_data;
                        else        read_data <= dram_mc2[local_offset[7:0]];
                    end
                    2'b11: begin
                        if (req_rw) dram_mc3[local_offset[7:0]] <= write_data;
                        else        read_data <= dram_mc3[local_offset[7:0]];
                    end
                endcase
            end
        end
    end
endmodule
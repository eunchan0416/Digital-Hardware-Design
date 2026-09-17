`timescale 1ns / 1ps

module register_file (
    input  logic        clk,
    input  logic        rst,
    input  logic [ 4:0] raddr1,
    input  logic [ 4:0] raddr2,
    input  logic [ 4:0] waddr,
    input  logic [31:0] wdata,
    input  logic        we,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2
);

    logic [31:0] rf [1:31];

    // Synchronous Write (x0 is read-only 0)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 1; i < 32; i++) begin
                rf[i] <= 32'h0000_0000;
            end
        end else if (we && (waddr != 5'd0)) begin
            rf[waddr] <= wdata;
        end
    end

    // [Step 2] Write-First Internal RAW Bypass
    // Same cycle WB write & ID read collision resolution:
    // If waddr == raddr && we == 1, forward wdata directly to rdata!
    // x0 is always hardwired to 0 (raddr != 0 guard).
    assign rdata1 = (raddr1 == 5'd0) ? 32'h0000_0000 :
                    (we && (waddr == raddr1)) ? wdata : rf[raddr1];

    assign rdata2 = (raddr2 == 5'd0) ? 32'h0000_0000 :
                    (we && (waddr == raddr2)) ? wdata : rf[raddr2];

endmodule

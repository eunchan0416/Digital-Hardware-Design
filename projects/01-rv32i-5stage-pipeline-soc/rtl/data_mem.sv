`timescale 1ns / 1ps

module data_mem (
    input  logic        clk,
    input  logic        dwe,
    input  logic [ 3:0] dstrb,
    input  logic [31:0] daddr,
    input  logic [31:0] dwdata,
    output logic [31:0] drdata
);

    // Pure 32-bit Memory Array with Byte-Level Write Strobes
    data_ram U_DMEM (
        .clk     (clk),
        .dwe     (dwe),
        .dstrb   (dstrb),
        .daddr   (daddr),
        .data_in (dwdata),
        .data_out(drdata)
    );

endmodule

module data_ram (
    input  logic        clk,
    input  logic        dwe,
    input  logic [ 3:0] dstrb,
    input  logic [31:0] daddr,
    input  logic [31:0] data_in,
    output logic [31:0] data_out
);
    // 1024 Words (4096 Bytes) Single-Port RAM
    logic [31:0] dmem[0:1023];

    initial begin
        // Initialize memory address 0 with 32'd100 for Load-Use verification
        dmem[0] = 32'd0;
        for (int i = 1; i < 1024; i++) dmem[i] = 32'd0;
    end

    // Standard Byte-Enabled Synchronous Write
    always @(posedge clk) begin
        if (dwe) begin
            if (dstrb[0]) dmem[daddr[11:2]][ 7: 0] <= data_in[ 7: 0];
            if (dstrb[1]) dmem[daddr[11:2]][15: 8] <= data_in[15: 8];
            if (dstrb[2]) dmem[daddr[11:2]][23:16] <= data_in[23:16];
            if (dstrb[3]) dmem[daddr[11:2]][31:24] <= data_in[31:24];
        end
    end

    // Asynchronous Read (Raw 32-bit Word)
    assign data_out = dmem[daddr[11:2]];

endmodule

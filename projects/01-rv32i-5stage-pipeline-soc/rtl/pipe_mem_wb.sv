`timescale 1ns / 1ps
`include "define.vh"

module pipe_mem_wb (
    input  logic        clk,
    input  logic        rst,
    input  logic        flush,
    input  logic        stall,

    // Control Signals Input (from MEM)
    input  logic        i_rf_we,
    input  logic [2:0]  i_rfwd_src,

    // Datapath Signals Input (from MEM)
    input  logic [31:0] i_pc_plus_4,
    input  logic [31:0] i_alu_result,
    input  logic [31:0] i_drdata,
    input  logic [31:0] i_imm,
    input  logic [31:0] i_auipc,
    input  logic [4:0]  i_rd,

    // Control Signals Output (to WB & Forwarding Unit)
    output logic        o_rf_we,
    output logic [2:0]  o_rfwd_src,

    // Datapath Signals Output (to WB)
    output logic [31:0] o_pc_plus_4,
    output logic [31:0] o_alu_result,
    output logic [31:0] o_drdata,
    output logic [31:0] o_imm,
    output logic [31:0] o_auipc,
    output logic [4:0]  o_rd
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            o_rf_we      <= 1'b0;
            o_rfwd_src   <= `WB_ALU;

            o_pc_plus_4  <= 32'h0000_0000;
            o_alu_result <= 32'h0000_0000;
            o_drdata     <= 32'h0000_0000;
            o_imm        <= 32'h0000_0000;
            o_auipc      <= 32'h0000_0000;
            o_rd         <= 5'b00000;
        end else if (flush) begin
            o_rf_we      <= 1'b0;
            o_rfwd_src   <= `WB_ALU;

            o_pc_plus_4  <= 32'h0000_0000;
            o_alu_result <= 32'h0000_0000;
            o_drdata     <= 32'h0000_0000;
            o_imm        <= 32'h0000_0000;
            o_auipc      <= 32'h0000_0000;
            o_rd         <= 5'b00000;
        end else if (!stall) begin
            o_rf_we      <= i_rf_we;
            o_rfwd_src   <= i_rfwd_src;

            o_pc_plus_4  <= i_pc_plus_4;
            o_alu_result <= i_alu_result;
            o_drdata     <= i_drdata;
            o_imm        <= i_imm;
            o_auipc      <= i_auipc;
            o_rd         <= i_rd;
        end
    end

endmodule

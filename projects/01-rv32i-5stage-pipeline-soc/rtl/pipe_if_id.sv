`timescale 1ns / 1ps
`include "define.vh"

module pipe_if_id (
    input  logic        clk,
    input  logic        rst,
    input  logic        flush,
    input  logic        stall,
    input  logic [31:0] i_pc,
    input  logic [31:0] i_pc_plus_4,
    input  logic [31:0] i_instr,
    output logic [31:0] o_pc,
    output logic [31:0] o_pc_plus_4,
    output logic [31:0] o_instr,
    output logic        o_valid
);

    // 1. Instruction & Valid Register (Flush 적용: NOP 세탁)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            o_instr <= `NOP_INSTR;
            o_valid <= 1'b0;
        end else if (flush) begin
            o_instr <= `NOP_INSTR;
            o_valid <= 1'b0;
        end else if (!stall) begin
            o_instr <= i_instr;
            o_valid <= 1'b1;
        end
    end

    // 2. PC Datapath Registers (Flush 제외: Fanout 병목 원천 제거)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            o_pc        <= 32'h0000_0000;
            o_pc_plus_4 <= 32'h0000_0000;
        end else if (!stall) begin
            o_pc        <= i_pc;
            o_pc_plus_4 <= i_pc_plus_4;
        end
    end

endmodule
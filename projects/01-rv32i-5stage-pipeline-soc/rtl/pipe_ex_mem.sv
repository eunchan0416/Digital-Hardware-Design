`timescale 1ns / 1ps
`include "define.vh"

module pipe_ex_mem (
    input  logic        clk,
    input  logic        rst,
    input  logic        flush,
    input  logic        stall,

    // Control Inputs
    input  logic        i_dwe,
    input  logic        i_mem_read,
    input  logic        i_rf_we,
    input  logic [2:0]  i_rfwd_src,

    // Datapath Inputs
    input  logic [31:0] i_pc_plus_4,
    input  logic [31:0] i_alu_result,
    input  logic [31:0] i_rs2_data,
    input  logic [31:0] i_imm,
    input  logic [31:0] i_auipc,
    input  logic [ 4:0] i_rd,
    input  logic [ 2:0] i_funct3,
    input  logic [31:0] i_forward_val,   // [추가]

    // Control Outputs
    output logic        o_dwe,
    output logic        o_mem_read,
    output logic        o_rf_we,
    output logic [2:0]  o_rfwd_src,

    // Datapath Outputs
    output logic [31:0] o_pc_plus_4,
    output logic [31:0] o_alu_result,
    output logic [31:0] o_rs2_data,
    output logic [31:0] o_imm,
    output logic [31:0] o_auipc,
    output logic [ 4:0] o_rd,
    output logic [ 2:0] o_funct3,
    output logic [31:0] o_forward_val    // [추가: EX 포워딩 MUX로 직결]
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            o_dwe         <= 1'b0;
            o_mem_read    <= 1'b0;
            o_rf_we       <= 1'b0;
            o_rfwd_src    <= `WB_ALU;

            o_pc_plus_4   <= 32'h0000_0000;
            o_alu_result  <= 32'h0000_0000;
            o_rs2_data    <= 32'h0000_0000;
            o_imm         <= 32'h0000_0000;
            o_auipc       <= 32'h0000_0000;
            o_rd          <= 5'b00000;
            o_funct3      <= 3'b000;
            o_forward_val <= 32'h0000_0000;
        end else if (flush) begin
            o_dwe         <= 1'b0;
            o_mem_read    <= 1'b0;
            o_rf_we       <= 1'b0;
            o_rfwd_src    <= `WB_ALU;

            o_pc_plus_4   <= 32'h0000_0000;
            o_alu_result  <= 32'h0000_0000;
            o_rs2_data    <= 32'h0000_0000;
            o_imm         <= 32'h0000_0000;
            o_auipc       <= 32'h0000_0000;
            o_rd          <= 5'b00000;
            o_funct3      <= 3'b000;
            o_forward_val <= 32'h0000_0000;
        end else if (!stall) begin
            o_dwe         <= i_dwe;
            o_mem_read    <= i_mem_read;
            o_rf_we       <= i_rf_we;
            o_rfwd_src    <= i_rfwd_src;

            o_pc_plus_4   <= i_pc_plus_4;
            o_alu_result  <= i_alu_result;
            o_rs2_data    <= i_rs2_data;
            o_imm         <= i_imm;
            o_auipc       <= i_auipc;
            o_rd          <= i_rd;
            o_funct3      <= i_funct3;
            o_forward_val <= i_forward_val;
        end
    end

endmodule
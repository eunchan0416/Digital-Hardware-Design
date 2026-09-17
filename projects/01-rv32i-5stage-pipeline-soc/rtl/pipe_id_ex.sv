`timescale 1ns / 1ps
`include "define.vh"

module pipe_id_ex (
    input  logic        clk,
    input  logic        rst,
    input  logic        flush,
    input  logic        stall,

    // Control Signals Input
    input  logic        i_alu_src,
    input  logic [3:0]  i_alu_control,
    input  logic        i_branch,
    input  logic        i_jal,
    input  logic        i_jalr,
    input  logic        i_dwe,
    input  logic        i_mem_read,
    input  logic        i_rf_we,
    input  logic [2:0]  i_rfwd_src,
    input  logic        i_csr_we,
    input  logic [2:0]  i_csr_op,
    input  logic        i_is_mret,

    // Datapath Signals Input
    input  logic [31:0] i_pc,
    input  logic [31:0] i_pc_plus_4,
    input  logic [31:0] i_rs1_data,
    input  logic [31:0] i_rs2_data,
    input  logic [31:0] i_imm,
    input  logic [2:0]  i_funct3,
    input  logic [6:0]  i_funct7,
    input  logic [4:0]  i_rd,
    input  logic [4:0]  i_rs1,
    input  logic [4:0]  i_rs2,

    // Control Signals Output
    output logic        o_alu_src,
    output logic [3:0]  o_alu_control,
    output logic        o_branch,
    output logic        o_jal,
    output logic        o_jalr,
    output logic        o_dwe,
    output logic        o_mem_read,
    output logic        o_rf_we,
    output logic [2:0]  o_rfwd_src,
    output logic        o_csr_we,
    output logic [2:0]  o_csr_op,
    output logic        o_is_mret,

    // Datapath Signals Output
    output logic [31:0] o_pc,
    output logic [31:0] o_pc_plus_4,
    output logic [31:0] o_rs1_data,
    output logic [31:0] o_rs2_data,
    output logic [31:0] o_imm,
    output logic [2:0]  o_funct3,
    output logic [6:0]  o_funct7,
    output logic [4:0]  o_rd,
    output logic [4:0]  o_rs1,
    output logic [4:0]  o_rs2
);

    // 1. Control Path Registers (Flush 시 NOP 버블화)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            o_alu_src     <= 1'b0;
            o_alu_control <= `ADD;
            o_branch      <= 1'b0;
            o_jal         <= 1'b0;
            o_jalr        <= 1'b0;
            o_dwe         <= 1'b0;
            o_mem_read    <= 1'b0;
            o_rf_we       <= 1'b0;
            o_rfwd_src    <= `WB_ALU;
            o_csr_we      <= 1'b0;
            o_csr_op      <= 3'b000;
            o_is_mret     <= 1'b0;
            o_rd          <= 5'b00000;
        end else if (flush) begin
            o_alu_src     <= 1'b0;
            o_alu_control <= `ADD;
            o_branch      <= 1'b0;
            o_jal         <= 1'b0;
            o_jalr        <= 1'b0;
            o_dwe         <= 1'b0;
            o_mem_read    <= 1'b0;
            o_rf_we       <= 1'b0;
            o_rfwd_src    <= `WB_ALU;
            o_csr_we      <= 1'b0;
            o_csr_op      <= 3'b000;
            o_is_mret     <= 1'b0;
            o_rd          <= 5'b00000;
        end else if (!stall) begin
            o_alu_src     <= i_alu_src;
            o_alu_control <= i_alu_control;
            o_branch      <= i_branch;
            o_jal         <= i_jal;
            o_jalr        <= i_jalr;
            o_dwe         <= i_dwe;
            o_mem_read    <= i_mem_read;
            o_rf_we       <= i_rf_we;
            o_rfwd_src    <= i_rfwd_src;
            o_csr_we      <= i_csr_we;
            o_csr_op      <= i_csr_op;
            o_is_mret     <= i_is_mret;
            o_rd          <= i_rd;
        end
    end

    // 2. Datapath Registers (Flush 제외: 직접 래칭)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            o_pc        <= 32'h0000_0000;
            o_pc_plus_4 <= 32'h0000_0000;
            o_rs1_data  <= 32'h0000_0000;
            o_rs2_data  <= 32'h0000_0000;
            o_imm       <= 32'h0000_0000;
            o_funct3    <= 3'b000;
            o_funct7    <= 7'b000_0000;
            o_rs1       <= 5'b00000;
            o_rs2       <= 5'b00000;
        end else if (!stall) begin
            o_pc        <= i_pc;
            o_pc_plus_4 <= i_pc_plus_4;
            o_rs1_data  <= i_rs1_data;
            o_rs2_data  <= i_rs2_data;
            o_imm       <= i_imm;
            o_funct3    <= i_funct3;
            o_funct7    <= i_funct7;
            o_rs1       <= i_rs1;
            o_rs2       <= i_rs2;
        end
    end

endmodule
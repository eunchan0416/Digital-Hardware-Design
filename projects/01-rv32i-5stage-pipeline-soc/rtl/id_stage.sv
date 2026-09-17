`timescale 1ns / 1ps
`include "define.vh"

module id_stage (
    // Inputs from pipe_if_id
    input  logic [31:0] instr,
    input  logic [31:0] pc,
    input  logic [31:0] pc_plus_4,

    // Inputs from Register File (Read Data)
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,

    // Outputs to Register File (Read Address)
    output logic [ 4:0] rf_raddr1,
    output logic [ 4:0] rf_raddr2,

    // Outputs to pipe_id_ex (Control Signals)
    output logic        alu_src,
    output logic [ 3:0] alu_control,
    output logic        branch,
    output logic        jal,
    output logic        jalr,
    output logic        dwe,
    output logic        mem_read,
    output logic        rf_we,
    output logic [ 2:0] rfwd_src,
    output logic        csr_we,
    output logic [ 2:0] csr_op,
    output logic        is_mret,

    // Outputs to pipe_id_ex (Datapath Signals)
    output logic [31:0] o_pc,
    output logic [31:0] o_pc_plus_4,
    output logic [31:0] o_rs1_data,
    output logic [31:0] o_rs2_data,
    output logic [31:0] o_imm,

    // Outputs to pipe_id_ex (Tags & Sub-codes for Forwarding/Hazard/MEM/WB)
    output logic [ 4:0] o_rd,
    output logic [ 4:0] o_rs1,
    output logic [ 4:0] o_rs2,
    output logic [ 2:0] o_funct3,
    output logic [ 6:0] o_funct7
);

    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
    wire [4:0] rd     = instr[11:7];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];

    assign rf_raddr1 = rs1;
    assign rf_raddr2 = rs2;

    assign o_rd     = rd;
    assign o_rs1    = rs1;
    assign o_rs2    = rs2;
    assign o_funct3 = funct3;
    assign o_funct7 = funct7;

    assign o_pc        = pc;
    assign o_pc_plus_4 = pc_plus_4;
    assign o_rs1_data  = rs1_data;
    assign o_rs2_data  = rs2_data;

    // 1. Control Unit
    control_unit U_CONTROL_UNIT (
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7     (funct7),
        .alu_src    (alu_src),
        .alu_control(alu_control),
        .branch     (branch),
        .jal        (jal),
        .jalr       (jalr),
        .dwe        (dwe),
        .mem_read   (mem_read),
        .rf_we      (rf_we),
        .rfwd_src   (rfwd_src),
        .csr_we     (csr_we),
        .csr_op     (csr_op),
        .is_mret    (is_mret)
    );

    // 2. Immediate Extender
    imm_extender U_IMM_EXT (
        .instr(instr),
        .imm  (o_imm)
    );

endmodule

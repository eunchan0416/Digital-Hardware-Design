`timescale 1ns / 1ps
`include "define.vh"

module ex_stage (
    // Inputs from pipe_id_ex (Datapath)
    input  logic [31:0] pc,
    input  logic [31:0] pc_plus_4,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm,
    input  logic [ 2:0] funct3,
    input  logic [ 6:0] funct7,
    input  logic [ 4:0] rd,

    // Inputs from pipe_id_ex (Control)
    input  logic        alu_src,
    input  logic [ 3:0] alu_control,
    input  logic        branch,
    input  logic        jal,
    input  logic        jalr,
    input  logic        dwe,
    input  logic        mem_read,
    input  logic        rf_we,
    input  logic [ 2:0] rfwd_src,

    // Forwarding Inputs
    input  logic [ 1:0] forward_a,
    input  logic [ 1:0] forward_b,
    input  logic [31:0] forward_val_mem, // pipe_ex_mem 직결 레지스터 Q핀
    input  logic [31:0] forward_val_wb,
    input  logic [31:0] csr_rdata,

    // Direct Feedback Outputs
    output logic        ex_take_branch,
    output logic [31:0] ex_pc_target,
    output logic [31:0] ex_rs1_fwd_data,

    // Outputs to pipe_ex_mem (Datapath)
    output logic [31:0] o_alu_result,
    output logic [31:0] o_rs2_data,
    output logic [31:0] o_imm,
    output logic [31:0] o_auipc,
    output logic [31:0] o_pc_plus_4,
    output logic [ 4:0] o_rd,
    output logic [ 2:0] o_funct3,
    output logic [31:0] o_forward_val,   // [타이밍 핵심] MEM 포워딩용 사전 래칭 데이터

    // Outputs to pipe_ex_mem (Control Pass-through)
    output logic        o_dwe,
    output logic        o_mem_read,
    output logic        o_rf_we,
    output logic [ 2:0] o_rfwd_src
);

    // 1. Forwarding MUX for Operand A
    logic [31:0] alu_src1;
    always_comb begin
        case (forward_a)
            2'b00:   alu_src1 = rs1_data;
            2'b10:   alu_src1 = forward_val_mem;
            2'b01:   alu_src1 = forward_val_wb;
            default: alu_src1 = rs1_data;
        endcase
    end

    // 2. Forwarding MUX for Operand B
    logic [31:0] forwarded_rs2;
    always_comb begin
        case (forward_b)
            2'b00:   forwarded_rs2 = rs2_data;
            2'b10:   forwarded_rs2 = forward_val_mem;
            2'b01:   forwarded_rs2 = forward_val_wb;
            default: forwarded_rs2 = rs2_data;
        endcase
    end

    // 3. ALU Operand B MUX
    logic [31:0] alu_src2;
    assign alu_src2 = (alu_src) ? imm : forwarded_rs2;

    // 4. ALU Core
    logic        btaken;
    logic [31:0] alu_result;

    alu U_ALU (
        .a          (alu_src1),
        .b          (alu_src2),
        .alu_control(alu_control),
        .funct3     (funct3),
        .alu_result (alu_result),
        .btaken     (btaken)
    );

    // 5. Branch / Jump Target Address
    logic [31:0] jalr_target;
    logic [31:0] branch_jal_target;

    assign jalr_target       = (alu_src1 + imm) & 32'hFFFF_FFFE;
    assign branch_jal_target = pc + imm;
    assign ex_pc_target      = (jalr) ? jalr_target : branch_jal_target;
    assign ex_take_branch    = (branch & btaken) | jal | jalr;

    // 6. AUIPC Calculation
    assign o_auipc = pc + imm;

    // 7. [타이밍 핵심] MEM 포워딩용 값 사전 계산 MUX
    always_comb begin
        case (rfwd_src)
            `WB_LUI:   o_forward_val = imm;
            `WB_AUIPC: o_forward_val = pc + imm;
            `WB_PC4:   o_forward_val = pc_plus_4;
            `WB_CSR:   o_forward_val = csr_rdata;
            default:   o_forward_val = alu_result;
        endcase
    end

    // 8. Outputs Pack
    assign o_alu_result    = (rfwd_src == `WB_CSR) ? csr_rdata : alu_result;
    assign ex_rs1_fwd_data = alu_src1;
    assign o_rs2_data      = forwarded_rs2;
    assign o_imm           = imm;
    assign o_pc_plus_4     = pc_plus_4;
    assign o_rd            = rd;
    assign o_funct3        = funct3;

    // Control Pass-through
    assign o_dwe           = dwe;
    assign o_mem_read      = mem_read;
    assign o_rf_we         = rf_we;
    assign o_rfwd_src      = rfwd_src;

endmodule
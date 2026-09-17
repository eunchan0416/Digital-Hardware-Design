`timescale 1ns / 1ps
`include "define.vh"

module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    // EX Control Signals
    output logic       alu_src,
    output logic [3:0] alu_control,
    output logic       branch,
    output logic       jal,
    output logic       jalr,
    // MEM Control Signals
    output logic       dwe,
    output logic       mem_read,
    // WB Control Signals
    output logic       rf_we,
    output logic [2:0] rfwd_src,
    // CSR & System Control Signals
    output logic       csr_we,
    output logic [2:0] csr_op,
    output logic       is_mret
);

    always_comb begin
        alu_src     = 1'b0;
        alu_control = `ADD;
        branch      = 1'b0;
        jal         = 1'b0;
        jalr        = 1'b0;
        dwe         = 1'b0;
        mem_read    = 1'b0;
        rf_we       = 1'b0;
        rfwd_src    = `WB_ALU;
        csr_we      = 1'b0;
        csr_op      = 3'b000;
        is_mret     = 1'b0;

        case (opcode)
            `R_TYPE: begin
                alu_src     = 1'b0;
                alu_control = {funct7[5], funct3};
                rf_we       = 1'b1;
                rfwd_src    = `WB_ALU;
            end

            `I_TYPE: begin
                alu_src = 1'b1;
                if (funct3 == 3'b101) begin
                    alu_control = {funct7[5], funct3}; // SRLI, SRAI
                end else if (funct3 == 3'b001) begin
                    alu_control = `SLL;                // SLLI
                end else begin
                    alu_control = {1'b0, funct3};      // ADDI, SLTI, SLTIU, XORI, ORI, ANDI
                end
                rf_we    = 1'b1;
                rfwd_src = `WB_ALU;
            end

            `IL_TYPE: begin // Load Instructions
                alu_src     = 1'b1;
                alu_control = `ADD;
                mem_read    = 1'b1;
                rf_we       = 1'b1;
                rfwd_src    = `WB_MEM;
            end

            `S_TYPE: begin // Store Instructions
                alu_src     = 1'b1;
                alu_control = `ADD;
                dwe         = 1'b1;
                rf_we       = 1'b0;
            end

            `B_TYPE: begin // Branch Instructions
                alu_src     = 1'b0;
                alu_control = {1'b0, funct3};
                branch      = 1'b1;
                rf_we       = 1'b0;
            end

            `UL_TYPE: begin // LUI
                rf_we    = 1'b1;
                rfwd_src = `WB_LUI;
            end

            `UA_TYPE: begin // AUIPC
                rf_we    = 1'b1;
                rfwd_src = `WB_AUIPC;
            end

            `J_TYPE: begin // JAL
                jal      = 1'b1;
                rf_we    = 1'b1;
                rfwd_src = `WB_PC4;
            end

            `JL_TYPE: begin // JALR
                jalr     = 1'b1;
                alu_src  = 1'b1;
                rf_we    = 1'b1;
                rfwd_src = `WB_PC4;
            end

            `SYS_TYPE: begin
                if (funct3 == 3'b000) begin
                    if (funct7 == 7'b0011000) begin // MRET
                        is_mret = 1'b1;
                    end
                end else begin // CSR Instructions (CSRRW, CSRRS, CSRRC, etc.)
                    rf_we    = 1'b1;
                    rfwd_src = `WB_CSR;
                    csr_we   = 1'b1;
                    csr_op   = funct3;
                end
            end

            default: begin
                alu_src     = 1'b0;
                alu_control = `ADD;
                branch      = 1'b0;
                jal         = 1'b0;
                jalr        = 1'b0;
                dwe         = 1'b0;
                mem_read    = 1'b0;
                rf_we       = 1'b0;
                rfwd_src    = `WB_ALU;
            end
        endcase
    end

endmodule

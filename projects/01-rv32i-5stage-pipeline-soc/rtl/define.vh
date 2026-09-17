`timescale 1ns / 1ps
`ifndef DEFINE_VH
`define DEFINE_VH

// ============================================================================
// RV32I Opcode Definitions (instr[6:0])
// ============================================================================
`define R_TYPE      7'b011_0011 // Register-Register Arithmetic/Logic
`define I_TYPE      7'b001_0011 // Immediate Arithmetic/Logic
`define IL_TYPE     7'b000_0011 // Load Instructions (LB, LH, LW, LBU, LHU)
`define S_TYPE      7'b010_0011 // Store Instructions (SB, SH, SW)
`define B_TYPE      7'b110_0011 // Branch Instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
`define UL_TYPE     7'b011_0111 // LUI (Load Upper Immediate)
`define UA_TYPE     7'b001_0111 // AUIPC (Add Upper Immediate to PC)
`define J_TYPE      7'b110_1111 // JAL (Jump and Link)
`define JL_TYPE     7'b110_0111 // JALR (Jump and Link Register)
`define SYS_TYPE    7'b111_0011 // SYSTEM / CSR (Reserved)

// ============================================================================
// ALU Control Signal Mapping (4-bit: {funct7[5], funct3})
// ============================================================================
`define ADD         4'b0_000
`define SUB         4'b1_000 
`define SLL         4'b0_001
`define SLT         4'b0_010
`define SLTU        4'b0_011
`define XOR         4'b0_100 
`define SRL         4'b0_101
`define SRA         4'b1_101
`define OR          4'b0_110 
`define AND         4'b0_111

// ============================================================================
// Branch Condition Mapping (funct3[2:0])
// ============================================================================
`define BEQ         3'b000
`define BNE         3'b001
`define BLT         3'b100
`define BGE         3'b101
`define BLTU        3'b110
`define BGEU        3'b111

// ============================================================================
// Store funct3 Mapping
// ============================================================================
`define SB          3'b000
`define SH          3'b001
`define SW          3'b010

// ============================================================================
// Load funct3 Mapping
// ============================================================================
`define LB          3'b000
`define LH          3'b001
`define LW          3'b010
`define LBU         3'b100
`define LHU         3'b101

// ============================================================================
// Write-Back MUX Select Mapping (3-bit)
// ============================================================================
`define WB_ALU      3'b000 // ALU Result (R-type, I-type)
`define WB_MEM      3'b001 // Data Memory Read Data (Load)
`define WB_LUI      3'b010 // LUI Immediate Data
`define WB_AUIPC    3'b011 // AUIPC (PC + Imm)
`define WB_PC4      3'b100 // JAL / JALR (PC + 4)
`define WB_CSR      3'b101 // CSR Read Data

// ============================================================================
// CSR Address Definitions (12-bit)
// ============================================================================
`define CSR_MSTATUS 12'h300
`define CSR_MIE     12'h304
`define CSR_MTVEC   12'h305
`define CSR_MEPC    12'h341
`define CSR_MCAUSE  12'h342
`define CSR_MIP     12'h344

// ============================================================================
// CSR funct3 Operation Mapping
// ============================================================================
`define CSR_RW      3'b001
`define CSR_RS      3'b010
`define CSR_RC      3'b011
`define CSR_RWI     3'b101
`define CSR_RSI     3'b110
`define CSR_RCI     3'b111

// Special Instructions
`define NOP_INSTR   32'h0000_0013 // addi x0, x0, 0
`define MRET_INSTR  32'h3020_0073 // mret

`endif

`timescale 1ns / 1ps
`include "define.vh"

module wb_stage (
    // Inputs from pipe_mem_wb (Datapath & Control)
    input  logic [ 2:0] rfwd_src,    // WB 5-to-1 MUX 선택 신호
    input  logic [31:0] alu_result,  // 000: ALU 연산 결과
    input  logic [31:0] drdata,      // 001: Data Memory에서 읽은 값
    input  logic [31:0] imm,         // 010: LUI 즉시값
    input  logic [31:0] auipc,       // 011: AUIPC (PC + Imm)
    input  logic [31:0] pc_plus_4,   // 100: JAL/JALR 복귀 주소 (PC + 4)

    // Output to Register File Write Port & Forwarding Unit
    output logic [31:0] wb_wdata     // 최종 선택된 기록 데이터 (포워딩용 전선!)
);

    // 5-to-1 WB Multiplexer (CSR Read Data passes through alu_result bus)
    always_comb begin
        case (rfwd_src)
            `WB_ALU:   wb_wdata = alu_result;
            `WB_MEM:   wb_wdata = drdata;
            `WB_LUI:   wb_wdata = imm;
            `WB_AUIPC: wb_wdata = auipc;
            `WB_PC4:   wb_wdata = pc_plus_4;
            `WB_CSR:   wb_wdata = alu_result; // ALU Result 버스에 실려온 CSR 읽기 데이터
            default:   wb_wdata = alu_result;
        endcase
    end

endmodule

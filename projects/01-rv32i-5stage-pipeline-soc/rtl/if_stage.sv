`timescale 1ns / 1ps
`include "define.vh"

module if_stage (
    input  logic        clk,
    input  logic        rst,
    input  logic        stall,                 // Hazard Unit에서 오는 PC Stall 제어

    // EX Stage 피드백 신호 (분기/점프 직통 연결)
    input  logic [31:0] ex_pc_target,          // 점프 목적지 주소
    input  logic        ex_take_branch,        // 점프 판정 신호 (1: 점프, 0: 순차)

    // CSR / 트랩 확장 예약 포트
    input  logic [31:0] i_mtvec,               // 트랩 핸들러 주소
    input  logic [31:0] i_mepc,                // 트랩 복귀 주소
    input  logic [ 1:0] i_pc_src_sel_override, // MUX 강제 선택 신호 (2'b10: mtvec, 2'b11: mepc)

    // I-Memory 인터페이스 출력
    output logic [31:0] instr_addr,            // I-MEM 주소

    // pipe_if_id 출력
    output logic [31:0] o_pc,                  // 현재 PC
    output logic [31:0] o_pc_plus_4            // PC + 4
);

    logic [31:0] pc_current;
    logic [31:0] pc_next;

    // 1. 기본 PC 배선
    assign o_pc_plus_4 = pc_current + 32'd4;
    assign instr_addr  = pc_current;
    assign o_pc        = pc_current;

    // 2. Fast Path: 클럭 시작 시점에 즉시 준비되는 기본/트랩 PC (ALU 비의존)
    logic [31:0] default_pc;
    always_comb begin
        case (i_pc_src_sel_override)
            2'b10:   default_pc = i_mtvec;
            2'b11:   default_pc = i_mepc;
            default: default_pc = o_pc_plus_4;
        endcase
    end

    // 3. Late Arrival Path: 가장 늦게 도착하는 ex_take_branch를 최종 2-to-1 MUX로 직결
    // (기존 5단 LUT 연쇄를 단 1단 LUT3 MUX로 축소)
    wire branch_taken = ex_take_branch & (i_pc_src_sel_override == 2'b00);
    assign pc_next    = branch_taken ? ex_pc_target : default_pc;

    // 4. 하드웨어 CE 구동을 위한 정제된 Enable 신호
    wire pc_en = (!stall) | branch_taken | (i_pc_src_sel_override != 2'b00);

    pc_reg U_PC_REG (
        .clk    (clk),
        .rst    (rst),
        .en     (pc_en),
        .pc_next(pc_next),
        .pc     (pc_current)
    );

endmodule
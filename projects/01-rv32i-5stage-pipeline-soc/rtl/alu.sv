`timescale 1ns / 1ps
`include "define.vh"

module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [ 3:0] alu_control,
    input  logic [ 2:0] funct3,
    output logic [31:0] alu_result,
    output logic        btaken
);

    // 1. 기본 비교 연산자 단일화 (CARRY4 체인 중복 생성 방지)
    wire is_equal         = (a == b);
    wire is_less_signed   = ($signed(a) < $signed(b));
    wire is_less_unsigned = (a < b);

    // 2. ALU Arithmetic / Logic Operations
    always_comb begin
        case (alu_control)
            `ADD:    alu_result = a + b;
            `SUB:    alu_result = a - b;
            `SLL:    alu_result = a << b[4:0];
            `SLT:    alu_result = is_less_signed   ? 32'd1 : 32'd0;
            `SLTU:   alu_result = is_less_unsigned ? 32'd1 : 32'd0;
            `XOR:    alu_result = a ^ b;
            `SRL:    alu_result = a >> b[4:0];
            `SRA:    alu_result = $signed(a) >>> b[4:0];
            `OR:     alu_result = a | b;
            `AND:    alu_result = a & b;
            default: alu_result = 32'h0000_0000;
        endcase
    end

    // 3. Branch Condition Evaluation: 공통 신호 반전 활용
    always_comb begin
        case (funct3)
            `BEQ:    btaken = is_equal;
            `BNE:    btaken = ~is_equal;
            `BLT:    btaken = is_less_signed;
            `BGE:    btaken = ~is_less_signed;
            `BLTU:   btaken = is_less_unsigned;
            `BGEU:   btaken = ~is_less_unsigned;
            default: btaken = 1'b0;
        endcase
    end

endmodule
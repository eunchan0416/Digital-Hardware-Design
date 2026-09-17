`timescale 1ns / 1ps
`include "define.vh"

module pc_reg #(
    parameter logic [31:0] RESET_PC = 32'h8000_0000
) (
    input  logic        clk,
    input  logic        rst,
    (* direct_enable = "yes" *)
    input  logic        en,          // 하드웨어 FDCE CE 핀 직결 지시자
    input  logic [31:0] pc_next,     // 순수 1단 2-to-1 MUX 결과
    output logic [31:0] pc           // 현재 PC 출력
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= RESET_PC;
        end else if (en) begin
            pc <= pc_next;
        end
    end

endmodule
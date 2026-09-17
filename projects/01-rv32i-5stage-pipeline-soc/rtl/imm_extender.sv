`timescale 1ns / 1ps
`include "define.vh"

module imm_extender (
    input  logic [31:0] instr,
    output logic [31:0] imm
);

    always_comb begin
        case (instr[6:0])
            `I_TYPE, `IL_TYPE, `JL_TYPE, `SYS_TYPE: begin
                imm = {{20{instr[31]}}, instr[31:20]};
            end

            `S_TYPE: begin
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            `B_TYPE: begin
                imm = {
                    {19{instr[31]}},
                    instr[31],
                    instr[7],
                    instr[30:25],
                    instr[11:8],
                    1'b0
                };
            end

            `UL_TYPE, `UA_TYPE: begin
                imm = {instr[31:12], 12'h000};
            end

            `J_TYPE: begin
                imm = {
                    {11{instr[31]}},
                    instr[31],
                    instr[19:12],
                    instr[20],
                    instr[30:21],
                    1'b0
                };
            end

            default: begin
                imm = 32'h0000_0000;
            end
        endcase
    end

endmodule

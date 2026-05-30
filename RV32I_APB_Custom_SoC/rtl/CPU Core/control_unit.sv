// -----------------------------------------------------------------------------
// Module Name : control_unit
// Description : FSM-based Control Unit for Multi-cycle RV32I Core
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "define.vh"

module control_unit (
    input  logic       clk,
    input  logic       rst,
    input  logic [6:0] funct7,
    input  logic [2:0] funct3,
    input  logic [6:0] opcode,
    input  logic       ready,
    
    output logic       pc_en,
    output logic       ir_en,
    output logic       rf_we,
    output logic       dwe,
    output logic       dre,
    output logic       jump,
    output logic [2:0] rfwdsrcsel,
    output logic       alusrcsel,
    output logic [2:0] c2dm_funct3,
    output logic [3:0] alucontrol,
    output logic       branch,
    output logic       jal
);

    typedef enum logic [2:0] {
        FETCH,
        DECODE,
        EXECUTE,
        MEM,
        WB
    } state_e;

    state_e c_st, n_st;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) c_st <= FETCH;
        else     c_st <= n_st;
    end

    always_comb begin
        n_st = c_st;
        case (c_st)
            FETCH:  n_st = DECODE;
            DECODE: n_st = EXECUTE;
            EXECUTE: begin
                case (opcode)
                    `R_TYPE, `I_TYPE, `U_LUI, `U_AUIPC, `JL_TYPE, `J_TYPE, `B_TYPE:
                        n_st = FETCH;
                    `S_TYPE, `IL_TYPE:
                        n_st = MEM;
                    default: 
                        n_st = FETCH;
                endcase
            end
            MEM: begin
                case (opcode)
                    `IL_TYPE: if (ready) n_st = WB;
                    `S_TYPE:  if (ready) n_st = FETCH;
                    default:  n_st = FETCH;
                endcase
            end
            WB: n_st = FETCH;
        endcase
    end

    always_comb begin
        pc_en       = 1'b0;
        ir_en       = 1'b0; 
        jal         = 1'b0;
        jump        = 1'b0;
        branch      = 1'b0;
        rfwdsrcsel  = 3'b0;
        dwe         = 1'b0;
        dre         = 1'b0;
        rf_we       = 1'b0;
        alusrcsel   = 1'b0;
        alucontrol  = 4'b0000;
        c2dm_funct3 = 3'b0;

        case (c_st)
            FETCH: begin
                ir_en = 1'b1; 
            end

            DECODE: begin
            end

            EXECUTE: begin
                case (opcode)
                    `R_TYPE: begin
                        rf_we      = 1'b1;
                        rfwdsrcsel = 3'b000;
                        alusrcsel  = 1'b0;
                        alucontrol = {funct7[5], funct3};
                        pc_en      = 1'b1; 
                    end
                    `I_TYPE: begin
                        rf_we      = 1'b1;
                        rfwdsrcsel = 3'b000;
                        alusrcsel  = 1'b1;
                        if (funct3 == 3'b101) alucontrol = {funct7[5], funct3};
                        else                  alucontrol = {1'b0, funct3};
                        pc_en      = 1'b1;
                    end
                    `B_TYPE: begin
                        branch     = 1'b1;
                        alusrcsel  = 1'b0;
                        alucontrol = {1'b0, funct3};
                        pc_en      = 1'b1;
                    end
                    `S_TYPE, `IL_TYPE: begin
                        alusrcsel  = 1'b1;
                        alucontrol = 4'b0000;  
                    end
                    `JL_TYPE: begin
                        rf_we      = 1'b1;
                        rfwdsrcsel = 3'b100;
                        jal        = 1'b1;
                        alusrcsel  = 1'b1;
                        pc_en      = 1'b1;
                    end
                    `J_TYPE: begin
                        rf_we      = 1'b1;
                        rfwdsrcsel = 3'b100;
                        jump       = 1'b1;
                        pc_en      = 1'b1;
                    end
                    `U_LUI: begin
                        rf_we      = 1'b1;
                        rfwdsrcsel = 3'b010;
                        pc_en      = 1'b1;
                    end
                    `U_AUIPC: begin
                        rf_we      = 1'b1;
                        rfwdsrcsel = 3'b011;  
                        pc_en      = 1'b1;
                    end
                endcase
            end

            MEM: begin
                c2dm_funct3 = funct3;
                dre = 1'b1;
                if (opcode == `S_TYPE) begin
                    dwe = 1'b1;
                    dre = 1'b0; 
                    if (ready) pc_en = 1'b1;
                end
            end

            WB: begin  
                rf_we      = 1'b1;
                rfwdsrcsel = 3'b001;  
                pc_en      = 1'b1;
            end
        endcase
    end
endmodule
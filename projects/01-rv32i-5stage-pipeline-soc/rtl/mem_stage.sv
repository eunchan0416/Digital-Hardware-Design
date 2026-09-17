`timescale 1ns / 1ps
`include "define.vh"

module mem_stage (
    // Inputs from pipe_ex_mem (Datapath)
    input  logic [31:0] alu_result,  // Memory Address
    input  logic [31:0] rs2_data,    // Raw Store Data (Forwarded from EX)
    input  logic [31:0] imm,
    input  logic [31:0] auipc,
    input  logic [31:0] pc_plus_4,
    input  logic [ 4:0] rd,
    input  logic [ 2:0] funct3,      // SB, SH, SW, LB, LH, LW, LBU, LHU

    // Inputs from pipe_ex_mem (Control)
    input  logic        dwe,
    input  logic        mem_read,
    input  logic        rf_we,
    input  logic [ 2:0] rfwd_src,

    // Interface with External Data Memory (Industry Standard Interface)
    output logic [31:0] daddr,       // Byte Address
    output logic [31:0] dwdata,      // Byte-Aligned Store Data
    output logic [ 3:0] dstrb,       // Byte Strobe / Write Enable Mask
    output logic        mem_dwe,     // Master Write Enable
    input  logic [31:0] raw_drdata,  // Raw 32-bit Data read from memory

    // Outputs to pipe_mem_wb (Datapath Pass-through & Formatted Data)
    output logic [31:0] o_pc_plus_4,
    output logic [31:0] o_alu_result,
    output logic [31:0] o_drdata,    // Load Data formatted & sign/zero-extended!
    output logic [31:0] o_imm,
    output logic [31:0] o_auipc,
    output logic [ 4:0] o_rd,

    // Outputs to pipe_mem_wb (Control Pass-through)
    output logic        o_rf_we,
    output logic [ 2:0] o_rfwd_src
);

    // ========================================================================
    // 1. Memory Store Data Alignment & Byte Strobe Generator (LSU Core)
    // ========================================================================
    assign daddr   = alu_result;
    assign mem_dwe = dwe;

    always_comb begin
        dwdata = rs2_data;
        dstrb  = 4'b0000;

        if (dwe) begin
            case (funct3)
                `SW: begin // 32-bit Word Store
                    dwdata = rs2_data;
                    dstrb  = 4'b1111;
                end

                `SH: begin // 16-bit Halfword Store
                    if (alu_result[1] == 1'b1) begin
                        dwdata = {rs2_data[15:0], 16'h0000};
                        dstrb  = 4'b1100;
                    end else begin
                        dwdata = {16'h0000, rs2_data[15:0]};
                        dstrb  = 4'b0011;
                    end
                end

                `SB: begin // 8-bit Byte Store
                    case (alu_result[1:0])
                        2'b00: begin dwdata = {24'h0, rs2_data[7:0]};        dstrb = 4'b0001; end
                        2'b01: begin dwdata = {16'h0, rs2_data[7:0], 8'h0};  dstrb = 4'b0010; end
                        2'b10: begin dwdata = {8'h0,  rs2_data[7:0], 16'h0}; dstrb = 4'b0100; end
                        2'b11: begin dwdata = {rs2_data[7:0], 24'h0};        dstrb = 4'b1000; end
                    endcase
                end

                default: begin
                    dwdata = rs2_data;
                    dstrb  = 4'b1111;
                end
            endcase
        end
    end

    // ========================================================================
    // 2. Memory Load Sign / Zero Extender (LSU Core)
    // ========================================================================
    logic [31:0] formatted_drdata;

    always_comb begin
        case (funct3)
            `LW: begin // 32-bit Word Load
                formatted_drdata = raw_drdata;
            end

            `LH: begin // 16-bit Signed Halfword Load
                if (alu_result[1] == 1'b1) begin
                    formatted_drdata = {{16{raw_drdata[31]}}, raw_drdata[31:16]};
                end else begin
                    formatted_drdata = {{16{raw_drdata[15]}}, raw_drdata[15:0]};
                end
            end

            `LB: begin // 8-bit Signed Byte Load
                case (alu_result[1:0])
                    2'b00: formatted_drdata = {{24{raw_drdata[ 7]}}, raw_drdata[ 7: 0]};
                    2'b01: formatted_drdata = {{24{raw_drdata[15]}}, raw_drdata[15: 8]};
                    2'b10: formatted_drdata = {{24{raw_drdata[23]}}, raw_drdata[23:16]};
                    2'b11: formatted_drdata = {{24{raw_drdata[31]}}, raw_drdata[31:24]};
                endcase
            end

            `LHU: begin // 16-bit Unsigned Halfword Load (Zero-extended)
                if (alu_result[1] == 1'b1) begin
                    formatted_drdata = {16'h0000, raw_drdata[31:16]};
                end else begin
                    formatted_drdata = {16'h0000, raw_drdata[15:0]};
                end
            end

            `LBU: begin // 8-bit Unsigned Byte Load (Zero-extended)
                case (alu_result[1:0])
                    2'b00: formatted_drdata = {24'h000000, raw_drdata[ 7: 0]};
                    2'b01: formatted_drdata = {24'h000000, raw_drdata[15: 8]};
                    2'b10: formatted_drdata = {24'h000000, raw_drdata[23:16]};
                    2'b11: formatted_drdata = {24'h000000, raw_drdata[31:24]};
                endcase
            end

            default: formatted_drdata = raw_drdata;
        endcase
    end

    // ========================================================================
    // 3. Signals Pack for pipe_mem_wb
    // ========================================================================
    assign o_pc_plus_4  = pc_plus_4;
    assign o_alu_result = alu_result;
    assign o_drdata     = formatted_drdata; // Core 내부에서 완벽하게 처리된 Load 데이터!
    assign o_imm        = imm;
    assign o_auipc      = auipc;
    assign o_rd         = rd;

    // Control Pass-through
    assign o_rf_we      = rf_we;
    assign o_rfwd_src   = rfwd_src;

endmodule

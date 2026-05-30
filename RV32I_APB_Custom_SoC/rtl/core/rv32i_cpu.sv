// -----------------------------------------------------------------------------
// Module Name : rv32i_cpu
// Description : 32-bit RISC-V (RV32I) Multi-cycle CPU Core
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "define.vh"

module rv32i_cpu (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instr_data,
    input  logic [31:0] bus_rdata,
    input  logic        bus_ready,
   
    output logic [31:0] instr_addr,
    output logic        bus_wreq,
    output logic        bus_rreq,
    output logic [31:0] bus_addr,
    output logic [ 2:0] c2dm_funct3,
    output logic [31:0] bus_wdata
);

    logic       rf_we, alusrcsel, branch, jal, jump, pc_en, ir_en;
    logic [2:0] rfwdsrcsel;
    logic [3:0] alucontrol;
    logic [31:0] instr_reg;

    // FETCH 상태일 때만 명령어를 래치
    always_ff @(posedge clk or posedge rst) begin
        if (rst) instr_reg <= 32'b0;
        else if (ir_en) instr_reg <= instr_data;
    end

    control_unit U_CONTROL_UNIT (
        .clk        (clk),
        .rst        (rst),
        .funct7     (instr_reg[31:25]),
        .funct3     (instr_reg[14:12]),
        .opcode     (instr_reg[6:0]),
        .pc_en      (pc_en),
        .ir_en      (ir_en),
        .rf_we      (rf_we),
        .dwe        (bus_wreq),
        .dre        (bus_rreq),
        .ready      (bus_ready),
        .jump       (jump),
        .alusrcsel  (alusrcsel),
        .rfwdsrcsel (rfwdsrcsel),
        .alucontrol (alucontrol),
        .c2dm_funct3(c2dm_funct3),
        .branch     (branch),
        .jal        (jal)
    );

    rv32i_datapath U_DATAPATH (
        .clk        (clk),
        .rst        (rst),
        .alusrcsel  (alusrcsel),
        .alucontrol (alucontrol),
        .jump       (jump),
        .pc_en      (pc_en),
        .rf_we      (rf_we),
        .branch     (branch),
        .jal        (jal),
        .rfwdsrcsel (rfwdsrcsel),
        .bus_rdata  (bus_rdata),
        .instr_data (instr_reg),
        .instr_addr (instr_addr),
        .bus_addr   (bus_addr),
        .bus_wdata  (bus_wdata)
    );

endmodule
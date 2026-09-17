`timescale 1ns / 1ps
`include "define.vh"

module rv32i_cpu (
    input  logic        clk,
    input  logic        rst,

    // Instruction Memory Interface
    output logic [31:0] instr_addr,
    input  logic [31:0] instr_data,

    // Data Memory Interface (Industry Standard)
    output logic [31:0] daddr,
    output logic [31:0] dwdata,
    output logic [ 3:0] dstrb,      // Byte Strobe / Write Enable Mask
    output logic        dwe,
    output logic        mem_read,
    input  logic [31:0] drdata,

    // APB MMIO Bus Wait Interface (Reserved / Step 6)
    input  logic        apb_busy,

    // External Interrupt Pin
    input  logic        ext_irq
);

    rv32i_datapath U_DATAPATH (
        .clk        (clk),
        .rst        (rst),
        .instr_addr (instr_addr),
        .instr_data (instr_data),
        .daddr      (daddr),
        .dwdata     (dwdata),
        .dstrb      (dstrb),
        .dwe        (dwe),
        .mem_read   (mem_read),
        .drdata     (drdata),
        .apb_busy   (apb_busy),
        .ext_irq    (ext_irq)
    );

endmodule

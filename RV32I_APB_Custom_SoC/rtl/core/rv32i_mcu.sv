// -----------------------------------------------------------------------------
// Module Name : rv32i_mcu
// Description : Top-level SoC Integration (RV32I Core + APB Bus + IPs)
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module rv32i_mcu (
    input  logic        clk,
    input  logic        rst,
    
    // Board I/O Interface
    inout  logic [15:0] gpio,
    output logic [ 7:0] gpo,
    input  logic [ 7:0] gpi,
    output logic [ 3:0] fnd_digit,
    output logic [ 7:0] fnd_data,
    
    // Serial Communication
    input  logic        uart_rx,
    output logic        uart_tx
);

    // -------------------------------------------------------------------------
    // Internal Interconnect Signals
    // -------------------------------------------------------------------------
    logic [31:0] instr_addr, instr_data;
    logic        bus_ready, bus_wreq, bus_rreq;
    logic [ 2:0] c2dm_funct3;
    logic [31:0] bus_addr, bus_wdata, bus_rdata;

    logic        psel0, psel1, psel2, psel3, psel4, psel5;
    logic        pready0, pready1, pready2, pready3, pready4, pready5;
    logic [31:0] prdata0, prdata1, prdata2, prdata3, prdata4, prdata5;
    logic [31:0] paddr, pwdata;
    logic        penable, pwrite;

    // -------------------------------------------------------------------------
    // Module Instantiations
    // -------------------------------------------------------------------------
    instruction_mem U_INST_MEM (
        .instr_addr (instr_addr),
        .instr_data (instr_data)
    );

    rv32i_cpu U_RV32I (
        .clk         (clk),
        .rst         (rst),
        .instr_data  (instr_data),
        .bus_rdata   (bus_rdata),
        .bus_ready   (bus_ready),
        .instr_addr  (instr_addr),
        .bus_wreq    (bus_wreq),
        .bus_rreq    (bus_rreq),
        .bus_addr    (bus_addr),
        .c2dm_funct3 (c2dm_funct3),
        .bus_wdata   (bus_wdata)
    );

    APB_MASTER U_APB_MASTER (
        .pclk    (clk),
        .preset  (rst),
        .addr    (bus_addr),
        .wdata   (bus_wdata),
        .wreq    (bus_wreq),
        .rreq    (bus_rreq),
        .ready   (bus_ready),
        .rdata   (bus_rdata),
        .paddr   (paddr),
        .pwdata  (pwdata),
        .penable (penable),
        .pwrite  (pwrite),
        .prdata0 (prdata0), .pready0 (pready0),
        .prdata1 (prdata1), .pready1 (pready1),
        .prdata2 (prdata2), .pready2 (pready2),
        .prdata3 (prdata3), .pready3 (pready3),
        .prdata4 (prdata4), .pready4 (pready4),
        .prdata5 (prdata5), .pready5 (pready5),
        .psel0   (psel0),
        .psel1   (psel1),
        .psel2   (psel2),
        .psel3   (psel3),
        .psel4   (psel4),
        .psel5   (psel5)
    );

    BRAM U_BRAM (
        .pclk    (clk),
        .paddr   (paddr),
        .pwdata  (pwdata),
        .penable (penable),
        .pwrite  (pwrite),
        .psel    (psel0),
        .prdata  (prdata0),
        .pready  (pready0)
    );

    APB_GPO U_APB_GPO (
        .pclk    (clk),
        .preset  (rst),
        .paddr   (paddr),
        .pwdata  (pwdata),
        .penable (penable),
        .pwrite  (pwrite),
        .psel    (psel1),
        .pready  (pready1),
        .prdata  (prdata1),
        .gpo_out (gpo)
    );

    APB_GPI U_APB_GPI (
        .pclk    (clk),
        .preset  (rst),
        .paddr   (paddr),
        .pwdata  (pwdata),
        .penable (penable),
        .pwrite  (pwrite),
        .psel    (psel2),
        .pready  (pready2),
        .prdata  (prdata2),
        .gpi     (gpi)
    );

    APB_GPIO U_APB_GPIO (
        .pclk    (clk),
        .preset  (rst),
        .paddr   (paddr),
        .pwdata  (pwdata),
        .penable (penable),
        .pwrite  (pwrite),
        .psel    (psel3),
        .pready  (pready3),
        .prdata  (prdata3),
        .gpio    (gpio)
    );

    APB_FND U_FND(
        .pclk      (clk),
        .preset    (rst),
        .paddr     (paddr),
        .pwdata    (pwdata),
        .pwrite    (pwrite),
        .penable   (penable),
        .psel      (psel4),
        .prdata    (prdata4),
        .pready    (pready4),
        .fnd_digit (fnd_digit),
        .fnd_data  (fnd_data)
    );

    APB_UART U_UART(
        .pclk    (clk),
        .preset  (rst),
        .paddr   (paddr),
        .pwdata  (pwdata),
        .pwrite  (pwrite),
        .penable (penable),
        .psel    (psel5),
        .prdata  (prdata5),
        .pready  (pready5),
        .uart_rx (uart_rx),
        .uart_tx (uart_tx)
    );

endmodule
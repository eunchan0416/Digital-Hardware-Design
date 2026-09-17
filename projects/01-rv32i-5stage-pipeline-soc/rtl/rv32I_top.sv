`timescale 1ns / 1ps
`include "define.vh"

module rv32I_top (
    input  logic        clk,
    input  logic        rst,

    // External Peripherals Interfaces
    inout  wire  [15:0] gpio,
    output logic [ 3:0] fnd_digit,
    output logic [ 7:0] fnd_data,
    input  logic        uart_rx,
    output logic        uart_tx,

    // External Interrupt Pin (e.g. Basys3 Pushbutton btnC)
    input  logic        ext_irq
);

    // ========================================================================
    // Internal Interconnect Signals
    // ========================================================================

    // Instruction Memory Interface
    logic [31:0] instr_addr;
    logic [31:0] instr_data;

    // CPU Data Memory / MMIO Interface
    logic [31:0] daddr;
    logic [31:0] dwdata;
    logic [31:0] drdata;
    logic [ 3:0] dstrb;
    logic        dwe;
    logic        mem_read;
    logic        apb_busy;

    // Direct Data Memory (Parallel RAM) Signals
    logic [31:0] ram_drdata;
    logic        ram_dwe;

    // APB MMIO Bus Signals
    logic        is_mmio;
    logic        apb_wreq;
    logic        apb_rreq;
    logic        apb_ready;
    logic [31:0] apb_rdata;

    // APB Protocol Signals between APB Master & Slaves
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic        penable;
    logic        pwrite;

    // Slave Selects
    logic        psel0; // RAM placeholder (unused on APB)
    logic        psel1; // GPO placeholder (unused)
    logic        psel2; // GPI placeholder (unused)
    logic        psel3; // GPIO
    logic        psel4; // FND
    logic        psel5; // UART

    // Slave Read Data & Ready
    logic [31:0] prdata3, prdata4, prdata5;
    logic        pready3, pready4, pready5;

    // ========================================================================
    // MMIO Address Decoding & Parallel Routing
    // ========================================================================
    // 0x2000_0000 ~ 0x2FFF_FFFF : APB MMIO Peripherals (GPIO, FND, UART)
    // All other addresses       : High-Speed Direct Data RAM (1-Cycle, Zero Stall)
    assign is_mmio = (daddr[31:28] == 4'h2);

    // RAM Write Enable: only active when NOT an MMIO access
    assign ram_dwe = dwe & (!is_mmio);

    // APB Requests: active only when accessing MMIO space
    assign apb_wreq = dwe & is_mmio;
    assign apb_rreq = mem_read & is_mmio;

    // Read Data MUX: choose between APB MMIO read data and Direct RAM read data
    assign drdata = is_mmio ? apb_rdata : ram_drdata;

    // APB Busy / Pipeline Freeze: freeze pipeline while APB MMIO transaction is in flight
    assign apb_busy = (apb_wreq | apb_rreq) & (!apb_ready);

    // ========================================================================
    // Submodule Instantiations
    // ========================================================================

    // 1. Instruction Memory (ROM)
    instruction_mem U_INSTRUCTION_MEM (
        .instr_addr(instr_addr),
        .instr_data(instr_data)
    );

    // 2. RV32I 5-Stage Full Hazard-Handled Processor Core
    rv32i_cpu U_RV32I_CPU (
        .clk       (clk),
        .rst       (rst),
        .instr_addr(instr_addr),
        .instr_data(instr_data),
        .daddr     (daddr),
        .dwdata    (dwdata),
        .dstrb     (dstrb),
        .dwe       (dwe),
        .mem_read  (mem_read),
        .drdata    (drdata),
        .apb_busy  (apb_busy),
        .ext_irq   (ext_irq)
    );

    // 3. Data Memory (Parallel Direct-Mapped Scratchpad RAM, 1-cycle access)
    data_mem U_DATA_MEM (
        .clk   (clk),
        .dwe   (ram_dwe),
        .dstrb (dstrb),
        .daddr (daddr),
        .dwdata(dwdata),
        .drdata(ram_drdata)
    );

    // 4. APB Master Bridge
    APB_MASTER U_APB_MASTER (
        .pclk    (clk),
        .preset  (rst),
        .addr    (daddr),
        .wdata   (dwdata),
        .wreq    (apb_wreq),
        .rreq    (apb_rreq),
        .ready   (apb_ready),
        .rdata   (apb_rdata),

        .paddr   (paddr),
        .pwdata  (pwdata),
        .penable (penable),
        .pwrite  (pwrite),

        // Slave 0 (RAM - unused because RAM is connected in parallel)
        .prdata0 (32'd0),
        .pready0 (1'b1),
        .psel0   (psel0),

        // Slave 1 (GPO - reserved)
        .prdata1 (32'd0),
        .pready1 (1'b1),
        .psel1   (psel1),

        // Slave 2 (GPI - reserved)
        .prdata2 (32'd0),
        .pready2 (1'b1),
        .psel2   (psel2),

        // Slave 3 (GPIO)
        .prdata3 (prdata3),
        .pready3 (pready3),
        .psel3   (psel3),

        // Slave 4 (FND)
        .prdata4 (prdata4),
        .pready4 (pready4),
        .psel4   (psel4),

        // Slave 5 (UART)
        .prdata5 (prdata5),
        .pready5 (pready5),
        .psel5   (psel5)
    );

    // 5. Slave 3: APB GPIO (Base Address: 0x2000_2000)
    APB_GPIO U_APB_GPIO (
        .pclk   (clk),
        .preset (rst),
        .paddr  (paddr),
        .pwdata (pwdata),
        .penable(penable),
        .pwrite (pwrite),
        .psel   (psel3),
        .pready (pready3),
        .prdata (prdata3),
        .gpio   (gpio)
    );

    // 6. Slave 4: APB FND (Base Address: 0x2000_3000)
    APB_FND U_APB_FND (
        .pclk     (clk),
        .preset   (rst),
        .paddr    (paddr),
        .pwdata   (pwdata),
        .pwrite   (pwrite),
        .penable  (penable),
        .psel     (psel4),
        .prdata   (prdata4),
        .pready   (pready4),
        .fnd_digit(fnd_digit),
        .fnd_data (fnd_data)
    );

    // 7. Slave 5: APB UART (Base Address: 0x2000_4000)
    APB_UART U_APB_UART (
        .pclk   (clk),
        .preset (rst),
        .paddr  (paddr),
        .pwdata (pwdata),
        .pwrite (pwrite),
        .penable(penable),
        .psel   (psel5),
        .prdata (prdata5),
        .pready (pready5),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

endmodule

`timescale 1ns / 1ps
`include "define.vh"

module tb_rv32i_apb_mmio;

    logic        clk;
    logic        rst;

    // External Peripherals Interfaces
    wire  [15:0] gpio;
    logic [15:0] gpio_ext_drive;
    logic        gpio_ext_en;

    logic [ 3:0] fnd_digit;
    logic [ 7:0] fnd_data;
    logic        uart_rx;
    logic        uart_tx;

    // Tristate control for external GPIO input stimulation
    assign gpio[15:8] = gpio_ext_en ? gpio_ext_drive[15:8] : 8'bz;
    // Lower 8 bits are driven as output by CPU, leave external undriven
    assign gpio[7:0]  = 8'bz;

    // Clock Generation: 100MHz (10ns Period)
    always #5.0 clk = ~clk;

    // DUT Instantiation
    rv32I_top U_DUT (
        .clk      (clk),
        .rst      (rst),
        .gpio     (gpio),
        .fnd_digit(fnd_digit),
        .fnd_data (fnd_data),
        .uart_rx  (uart_rx),
        .uart_tx  (uart_tx),
        .ext_irq  (1'b0)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_rv32i_apb_mmio);

        clk = 0;
        rst = 1;
        uart_rx = 1'b1;
        gpio_ext_en = 1'b1;
        gpio_ext_drive = 16'hAA00; // External switches driving upper 8 bits as 0xAA

        // Wait 1ns so any asynchronous $readmemh finishes at t=0, then load our APB test program
        #1;

        // 1. Initialize pointers
        U_DUT.U_INSTRUCTION_MEM.rom[0]  = 32'h20002537; // lui  x10, 0x20002 (GPIO: 0x2000_2000)
        U_DUT.U_INSTRUCTION_MEM.rom[1]  = 32'h200035B7; // lui  x11, 0x20003 (FND:  0x2000_3000)
        U_DUT.U_INSTRUCTION_MEM.rom[2]  = 32'h20004637; // lui  x12, 0x20004 (UART: 0x2000_4000)
        U_DUT.U_INSTRUCTION_MEM.rom[3]  = 32'h000006B7; // lui  x13, 0x00000 (RAM:  0x0000_0000)

        // 2. Parallel RAM Test (Direct memory, 1-cycle, zero APB busy)
        U_DUT.U_INSTRUCTION_MEM.rom[4]  = 32'h12300093; // addi x1, x0, 0x123
        U_DUT.U_INSTRUCTION_MEM.rom[5]  = 32'h0416A023; // sw   x1, 0x40(x13)  (RAM[0x40] <= 0x123)
        U_DUT.U_INSTRUCTION_MEM.rom[6]  = 32'h0406A103; // lw   x2, 0x40(x13)  (x2 <= RAM[0x40])

        // 3. APB GPIO MMIO Test
        U_DUT.U_INSTRUCTION_MEM.rom[7]  = 32'h0FF00193; // addi x3, x0, 0x00FF (lower 8 output, upper 8 input)
        U_DUT.U_INSTRUCTION_MEM.rom[8]  = 32'h00352023; // sw   x3, 0x000(x10) (GPIO_CTL <= 0x00FF)
        U_DUT.U_INSTRUCTION_MEM.rom[9]  = 32'h05500213; // addi x4, x0, 0x0055
        U_DUT.U_INSTRUCTION_MEM.rom[10] = 32'h00452223; // sw   x4, 0x004(x10) (GPIO_ODATA <= 0x0055)
        U_DUT.U_INSTRUCTION_MEM.rom[11] = 32'h00852283; // lw   x5, 0x008(x10) (x5 <= GPIO_IDATA)

        // 4. APB FND MMIO Test
        U_DUT.U_INSTRUCTION_MEM.rom[12] = 32'h4D200313; // addi x6, x0, 1234
        U_DUT.U_INSTRUCTION_MEM.rom[13] = 32'h0065A023; // sw   x6, 0x000(x11) (FND_DATA <= 1234)

        // 5. APB UART MMIO Test
        U_DUT.U_INSTRUCTION_MEM.rom[14] = 32'h04100393; // addi x7, x0, 0x41   ('A')
        U_DUT.U_INSTRUCTION_MEM.rom[15] = 32'h00762623; // sw   x7, 0x00C(x12) (UART_TXDATA <= 0x41)
        U_DUT.U_INSTRUCTION_MEM.rom[16] = 32'h00100413; // addi x8, x0, 1
        U_DUT.U_INSTRUCTION_MEM.rom[17] = 32'h00862023; // sw   x8, 0x000(x12) (UART_CTL <= 1: tx_start)

        // 6. Infinite Loop
        U_DUT.U_INSTRUCTION_MEM.rom[18] = 32'h0000006F; // jal  x0, 0 (end loop)
        for (int i = 19; i < 1024; i++) begin
            U_DUT.U_INSTRUCTION_MEM.rom[i] = 32'h00000013; // NOP
        end

        #24; // Wait remainder of reset duration
        @(negedge clk);
        rst = 0;
        $display("==================================================================================================");
        $display("[TB] Reset Deasserted. RV32I 5-STAGE CORE + APB MMIO CO-SIMULATION STARTED.");
        $display("==================================================================================================");
        $display(" Time(ns) | Cycle | PC         | MEM_Addr   | APB_Busy | Ready | PSEL[3:5] | WB_Data    | WB_Rd");
        $display("--------------------------------------------------------------------------------------------------");

        for (int cycle = 0; cycle < 50; cycle++) begin
            @(posedge clk);
            #1;
            $display("%8.1f | %5d | 0x%08h | 0x%08h |    %b     |   %b   |   %b%b%b   | 0x%08h | x%-2d",
                     $time,
                     cycle,
                     U_DUT.U_RV32I_CPU.U_DATAPATH.if_pc,
                     U_DUT.daddr,
                     U_DUT.apb_busy,
                     U_DUT.apb_ready,
                     U_DUT.psel3, U_DUT.psel4, U_DUT.psel5,
                     U_DUT.U_RV32I_CPU.U_DATAPATH.wb_wdata,
                     U_DUT.U_RV32I_CPU.U_DATAPATH.wb_rd);
        end

        #50;
        $display("==================================================================================================");
        $display("[TB_CHECK] VERIFYING FUNCTIONAL RESULTS:");
        $display("--------------------------------------------------------------------------------------------------");

        // 1. Direct RAM Check
        $display("[1] Parallel Data RAM Load x2: 0x%08h (Expected: 0x00000123)", U_DUT.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.rf[2]);
        if (U_DUT.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.rf[2] == 32'h123)
            $display("    --> [PASS] Direct Data RAM 1-Cycle Access Verified!");
        else
            $display("    --> [FAIL] Direct Data RAM Mismatch!");

        // 2. APB GPIO Check
        $display("[2] APB GPIO Pin Output [7:0]: 0x%02h (Expected: 0x55)", gpio[7:0]);
        $display("    APB GPIO Read Data x5:     0x%08h (Expected: 0x0000AAxx)", U_DUT.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.rf[5]);
        if (gpio[7:0] == 8'h55 && U_DUT.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.rf[5][15:8] == 8'hAA)
            $display("    --> [PASS] APB GPIO Write & Readback Verified!");
        else
            $display("    --> [FAIL] APB GPIO Mismatch!");

        // 3. APB FND Check
        $display("[3] APB FND Data Reg: %0d (Expected: 1234)", U_DUT.U_APB_FND.fnd_odata_reg);
        if (U_DUT.U_APB_FND.fnd_odata_reg == 14'd1234)
            $display("    --> [PASS] APB FND Display Register Write Verified!");
        else
            $display("    --> [FAIL] APB FND Register Mismatch!");

        // 4. APB UART Check
        $display("[4] APB UART TX Data Reg: 0x%02h (Expected: 0x41 / 'A')", U_DUT.U_APB_UART.tx_data_reg);
        if (U_DUT.U_APB_UART.tx_data_reg == 8'h41)
            $display("    --> [PASS] APB UART TX Data Register Write Verified!");
        else
            $display("    --> [FAIL] APB UART Register Mismatch!");

        $display("==================================================================================================");
        $finish;
    end

endmodule

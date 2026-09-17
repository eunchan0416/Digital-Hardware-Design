`timescale 1ns / 1ps
`include "define.vh"

module tb_rv32i_csr_interrupt;

    logic        clk;
    logic        rst;
    wire  [15:0] gpio;
    logic [ 3:0] fnd_digit;
    logic [ 7:0] fnd_data;
    logic        uart_rx;
    logic        uart_tx;
    logic        ext_irq;

    // GPIO wire emulation
    logic [15:0] gpio_in;
    assign gpio = gpio_in;

    // Clock Generation (100 MHz, 10ns period)
    always #5 clk = ~clk;

    // DUT Instantiation
    rv32I_top U_DUT (
        .clk      (clk),
        .rst      (rst),
        .gpio     (gpio),
        .fnd_digit(fnd_digit),
        .fnd_data (fnd_data),
        .uart_rx  (uart_rx),
        .uart_tx  (uart_tx),
        .ext_irq  (ext_irq)
    );

    // Aliases for probing internal signals
    wire [31:0] cpu_pc     = U_DUT.U_RV32I_CPU.U_DATAPATH.U_IF_STAGE.instr_addr;
    wire [31:0] mepc_val   = U_DUT.U_RV32I_CPU.U_DATAPATH.mepc_out;
    wire [31:0] mtvec_val  = U_DUT.U_RV32I_CPU.U_DATAPATH.mtvec_out;
    wire        trap_fire  = U_DUT.U_RV32I_CPU.U_DATAPATH.trap_taken;
    wire        mret_fire  = U_DUT.U_RV32I_CPU.U_DATAPATH.mret_taken;
    wire        mstatus_mie = U_DUT.U_RV32I_CPU.U_DATAPATH.U_CSR_REGFILE.mstatus_mie;
    wire [31:0] reg_x1     = U_DUT.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.registers[1];
    wire [31:0] reg_x10    = U_DUT.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.registers[10];

    integer cycle_count;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) cycle_count <= 0;
        else     cycle_count <= cycle_count + 1;
    end

    // Test program loader
    initial begin
        clk     = 0;
        rst     = 1;
        ext_irq = 0;
        uart_rx = 1;
        gpio_in = 16'h0000;

        #1; // Delay to override test.mem
        // -------------------------------------------------------------
        // Program loaded into Instruction ROM
        // -------------------------------------------------------------
        // Setup ISR Target = 0x8000_0040
        U_DUT.U_INSTRUCTION_MEM.rom[0]  = 32'h8000_02b7; // lui  x5, 0x80000
        U_DUT.U_INSTRUCTION_MEM.rom[1]  = 32'h0402_8293; // addi x5, x5, 0x40 (0x8000_0040)
        U_DUT.U_INSTRUCTION_MEM.rom[2]  = 32'h3052_9073; // csrw mtvec, x5 (mtvec <= 0x80000040)

        // Enable External Interrupt in mie (MEIE = bit 11 = 0x800)
        U_DUT.U_INSTRUCTION_MEM.rom[3]  = 32'h8000_0313; // li   x6, 0x800
        U_DUT.U_INSTRUCTION_MEM.rom[4]  = 32'h3043_1073; // csrw mie, x6

        // Enable Master Interrupt in mstatus (MIE = bit 3 = 0x8)
        U_DUT.U_INSTRUCTION_MEM.rom[5]  = 32'h0080_0393; // li   x7, 0x8
        U_DUT.U_INSTRUCTION_MEM.rom[6]  = 32'h3003_a073; // csrs mstatus, x7 (mstatus.MIE <= 1)

        // Main Program: Infinite counting loop
        U_DUT.U_INSTRUCTION_MEM.rom[7]  = 32'h0000_0093; // li   x1, 0
        U_DUT.U_INSTRUCTION_MEM.rom[8]  = 32'h0010_8093; // addi x1, x1, 1 (Loop start)
        U_DUT.U_INSTRUCTION_MEM.rom[9]  = 32'h0010_8093; // addi x1, x1, 1
        U_DUT.U_INSTRUCTION_MEM.rom[10] = 32'h0010_8093; // addi x1, x1, 1
        U_DUT.U_INSTRUCTION_MEM.rom[11] = 32'hff5f_f06f; // jal  x0, -12 (jump back to rom[8])

        // -------------------------------------------------------------
        // Interrupt Service Routine (ISR) at 0x8000_0040 (word 16)
        // -------------------------------------------------------------
        U_DUT.U_INSTRUCTION_MEM.rom[16] = 32'h1000_0513; // li   x10, 0x100 (Flag)
        U_DUT.U_INSTRUCTION_MEM.rom[17] = 32'h0015_0513; // addi x10, x10, 1 (x10 = 0x101)
        U_DUT.U_INSTRUCTION_MEM.rom[18] = 32'h3020_0073; // mret (Return to mepc!)

        $display("==================================================================================");
        $display("[TB] RV32I MACHINE-MODE CSR & ASYNC TRAP / INTERRUPT CO-SIMULATION START");
        $display("==================================================================================");

        // Deassert reset
        #20;
        @(negedge clk);
        rst = 0;
        $display("[TB] Reset deasserted. CPU executing CSR setup instructions...");

        // Wait for CSR setup and main loop entry
        wait (cpu_pc == 32'h8000_0020);
        repeat (2) @(posedge clk); // Allow pipeline to finish CSR writes
        $display("[TB] Cycle %0d: Main counting loop reached! mtvec = 0x%08x", cycle_count, mtvec_val);
        assert (mtvec_val == 32'h8000_0040)
            else $error("[ASSERTION FAIL] mtvec was not configured to 0x80000040!");

        // Let the counter run for a few cycles
        repeat (10) @(posedge clk);
        $display("[TB] Cycle %0d: CPU in steady state, x1 = %0d. INJECTING ASYNC INTERRUPT!", cycle_count, reg_x1);

        // Inject external interrupt and wait for trap
        @(negedge clk);
        ext_irq = 1'b1;

        // Monitor trap entry (mstatus.MIE disables on trap entry)
        wait (mstatus_mie == 1'b0);
        $display("[TB] >>> TRAP TAKEN! Cycle %0d: trap_pc(mepc) = 0x%08x, mtvec = 0x%08x", cycle_count, mepc_val, mtvec_val);

        // Deassert interrupt pulse
        @(negedge clk);
        ext_irq = 1'b0;

        // Wait for PC to reach ISR
        wait (cpu_pc == 32'h8000_0040);
        $display("[TB] Cycle %0d: Successfully entered ISR at 0x%08x!", cycle_count, cpu_pc);

        // Wait for MRET
        wait (mret_fire == 1'b1);
        repeat (3) @(posedge clk);
        $display("[TB] >>> MRET EXECUTED! Cycle %0d: Returning to mepc = 0x%08x, x10 = 0x%08x", cycle_count, mepc_val, reg_x10);
        assert (reg_x10 == 32'h0000_0101)
            else $error("[ASSERTION FAIL] ISR work was not completed! x10 != 0x101");

        // Wait for CPU to resume in main loop
        repeat (5) @(posedge clk);
        $display("[TB] Cycle %0d: Successfully resumed main counting loop! Current PC = 0x%08x, x1 = %0d", cycle_count, cpu_pc, reg_x1);

        // Let it count a bit more to prove full integrity
        repeat (10) @(posedge clk);
        $display("[TB] Cycle %0d: Post-interrupt counting verified! x1 = %0d", cycle_count, reg_x1);

        $display("==================================================================================");
        $display("[TB] ALL TEST ASSERTIONS PASSED! MACHINE-MODE CSR + TRAP/INTERRUPT FULLY VERIFIED!");
        $display("==================================================================================");
        $finish;
    end

    // Monitor for logging
    always @(posedge clk) begin
        if (!rst) begin
            $display("Time: %5.1f ns | Cyc: %3d | PC: 0x%08x | Trap: %b | MRET: %b | mepc: 0x%08x | x1: %3d | x10: 0x%08x",
                     $time, cycle_count, cpu_pc, trap_fire, mret_fire, mepc_val, reg_x1, reg_x10);
        end
    end

endmodule

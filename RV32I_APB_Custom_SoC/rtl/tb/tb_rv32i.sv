`timescale 1ns / 1ps

/**
 * @file    tb_soc.sv
 * @brief   Top-level Hardware/Software Co-simulation Testbench
 * @details Verifies RV32I Core and APB peripherals executing bare-metal C firmware.
 */
module tb_soc ();

    // System Signals
    logic        clk;
    logic        rst;

    // Peripheral Interfaces
    wire  [15:0] gpio; 
    logic [ 7:0] sw_input; 
    logic [ 7:0] gpo;
    logic [ 7:0] gpi;
    logic [ 3:0] fnd_digit;
    logic [ 7:0] fnd_data;
    logic        uart_rx;
    logic        uart_tx;

    // Device Under Test (DUT) Instantiation
    rv32i_mcu dut (.*);

    // Bidirectional GPIO Handling (High-Z for Output pins)
    // GPIO[15:8] : Driven by DUT (LED) -> Testbench sets to 'Z'
    // GPIO[7:0]  : Driven by Testbench (Switch) -> Connect to sw_input
    assign gpio = {8'bzzzz_zzzz, sw_input};

    // Clock Generation (100MHz)
    always #5 clk = ~clk;

    initial begin
        // 1. Initialize Signals
        clk = 0;
        rst = 1;
        sw_input = 8'h00; 
        uart_rx  = 1'b1; // Idle state for UART RX to prevent 'X' propagation

        // 2. Apply Reset
        repeat (5) @(negedge clk);
        rst = 0;

        // 3. User Input Scenario
        // Turn on specific switches (e.g., 0xFF) for C firmware to read
        repeat (10) @(negedge clk);
        sw_input = 8'hA5; // Changed from 0xFF to 0xA5 for clear waveform distinction
        
        // 4. Run HW/SW Co-simulation
        // Delay long enough for sys_init(), GPIO tests, and full UART TX frame
        // (10ms = 1,000,000 clock cycles at 100MHz)
        #10_000_000; 
        
        // 5. End Simulation
        $display("Simulation Finished.");
        $stop;
    end

endmodule
`timescale 1ns / 1ps
`include "define.vh"

// ============================================================================
// Module: rv32I_fpga_top
// Description: Basys3 FPGA Physical Top-Level Wrapper
//              - Directly connects to Basys3 Hardware Pins (XDC Constraints)
//              - Integrated Hardware Pushbutton Debouncer (btnC -> ext_irq)
//              - Interconnects RV32I Core, APB Peripherals (GPIO, FND, UART)
// ============================================================================
module rv32I_fpga_top (
    // 100MHz On-Board Oscillator (Pin W5)
    input  logic        clk,

    // Push Buttons
    input  logic        btnU,       // System Reset (Active-High) (Pin T18)
    input  logic        btnC,       // External Interrupt Trigger (Pin U18)

    // 16-bit GPIO (Connected to 16 LEDs or Header Pins)
    inout  wire  [15:0] gpio,       // Pins U16 ~ L1

    // 4-Digit 7-Segment Display (Active-Low)
    output logic [ 3:0] an,         // Digit Anode Select (Pins W4, V4, U4, U2)
    output logic [ 6:0] seg,        // Cathode Segments a~g (Pins W7 ~ U7)
    output logic        dp,         // Decimal Point (Pin V7)

    // USB-UART Bridge
    input  logic        RsRx,       // PC -> FPGA (Pin B18)
    output logic        RsTx        // FPGA -> PC (Pin A18)
);

    // =========================================================================
    // 1. Hardware Debouncer & Synchronizer for External Interrupt Button (btnC)
    // =========================================================================
    // - 100MHz 시스템 클럭 기반 완전 동기식 설계
    // - 2.5ms * 8샘플 = 20ms 디바운스 필터링 (기계식 접점 채터링 완전 제거)
    // - 버튼 누름 순간 정확히 1클럭 펄스(ext_irq) 출력!
    logic ext_irq_pulse;

    btn_debounce #(
        .CLK_FREQ_HZ   (100_000_000), // 100MHz
        .SAMPLE_CNT_US (2_500),       // 2.5ms tick
        .SHIFT_DEPTH   (8)            // 20ms debounce
    ) U_BTN_DEBOUNCE (
        .clk        (clk),
        .reset      (btnU),
        .i_btn      (btnC),
        .o_btn_pulse(ext_irq_pulse),  // 1-Cycle Pulse to Core ext_irq
        .o_btn_level()
    );

    // =========================================================================
    // 2. Internal FND Signal Wires
    // =========================================================================
    logic [3:0] w_fnd_digit;
    logic [7:0] w_fnd_data;

    // Basys3 7-Segment Pin Mapping (Active-Low):
    // - w_fnd_data[6:0] -> seg[6:0] (a, b, c, d, e, f, g)
    // - w_fnd_data[7]   -> dp (Decimal Point)
    // - w_fnd_digit[3:0]-> an[3:0] (Digit Enablers)
    assign an  = w_fnd_digit;
    assign seg = w_fnd_data[6:0];
    assign dp  = w_fnd_data[7];

    // =========================================================================
    // 3. RV32I Processor Top Instance (Core + APB MMIO Subsystem)
    // =========================================================================
    rv32I_top U_RV32I_SYSTEM (
        .clk      (clk),
        .rst      (btnU),
        .gpio     (gpio),
        .fnd_digit(w_fnd_digit),
        .fnd_data (w_fnd_data),
        .uart_rx  (RsRx),
        .uart_tx  (RsTx),
        .ext_irq  (ext_irq_pulse)     // Debounced Clean Interrupt Signal!
    );

endmodule

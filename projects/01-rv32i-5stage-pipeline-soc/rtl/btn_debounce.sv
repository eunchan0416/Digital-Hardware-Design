`timescale 1ns / 1ps

// ============================================================================
// Module: btn_debounce
// Description: Industrial-Grade Pushbutton Debouncer & One-Shot Edge Detector
//              - 2-Stage Metastability Synchronizer (CDC safe for async inputs)
//              - Fully Synchronous Clock Enable Architecture (No ripple clock!)
//              - Multi-Sample Shift Register for mechanical contact bounce removal
//              - 1-Clock Cycle Clean One-Shot Pulse Generator (Rising Edge)
// ============================================================================
module btn_debounce #(
    parameter CLK_FREQ_HZ   = 100_000_000, // Basys3 100MHz System Clock
    parameter SAMPLE_CNT_US = 2_500,       // 2.5ms sampling tick (250,000 cycles)
    parameter SHIFT_DEPTH   = 8            // 8 samples * 2.5ms = 20ms debounce time
)(
    input  logic clk,
    input  logic reset,
    input  logic i_btn,
    output logic o_btn_pulse, // 1-clock cycle pulse on button press (for ext_irq)
    output logic o_btn_level  // Filtered clean level signal (optional)
);

    // =========================================================================
    // 1. 2-Stage Flip-Flop Synchronizer (Prevent Metastability from Async Button)
    // =========================================================================
    logic sync_0, sync_1;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
        end else begin
            sync_0 <= i_btn;
            sync_1 <= sync_0;
        end
    end

    // =========================================================================
    // 2. Synchronous Sampling Tick Generator (Clock Enable)
    // =========================================================================
    // 100MHz / 250,000 = 400Hz (2.5ms tick)
    localparam integer TICK_COUNT = (CLK_FREQ_HZ / 1_000_000) * SAMPLE_CNT_US;
    logic [$clog2(TICK_COUNT)-1:0] clk_cnt;
    logic tick;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_cnt <= '0;
            tick    <= 1'b0;
        end else begin
            if (clk_cnt == TICK_COUNT - 1) begin
                clk_cnt <= '0;
                tick    <= 1'b1; // 1-cycle enable pulse
            end else begin
                clk_cnt <= clk_cnt + 1;
                tick    <= 1'b0;
            end
        end
    end

    // =========================================================================
    // 3. Multi-Sample Shift Register (Noise Filter)
    // =========================================================================
    // [현업 정석 규칙]: 비동기 리플 클럭(@(posedge tick))을 쓰지 않고,
    // 글로벌 100MHz 클럭에서 tick 신호를 Clock Enable 조건으로 사용!
    logic [SHIFT_DEPTH-1:0] q_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            q_reg <= '0;
        end else if (tick) begin
            q_reg <= {sync_1, q_reg[SHIFT_DEPTH-1:1]};
        end
    end

    // 모든 비트가 1일 때만 버튼 눌림 인정 (20ms 지속 확인)
    logic debounced_level;
    assign debounced_level = &q_reg;
    assign o_btn_level     = debounced_level;

    // =========================================================================
    // 4. One-Shot Rising Edge Detector (1-Clock Cycle Pulse Generation)
    // =========================================================================
    logic prev_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            prev_state <= 1'b0;
        end else begin
            prev_state <= debounced_level;
        end
    end

    // 0 -> 1 상승 에지에서 정확히 1클럭 펄스 출력!
    assign o_btn_pulse = debounced_level & ~prev_state;

endmodule

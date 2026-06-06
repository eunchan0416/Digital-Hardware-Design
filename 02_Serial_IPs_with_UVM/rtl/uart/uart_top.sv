`timescale 1ns / 1ps

module uart_top (
    input        clk,
    input        rst,

    output [7:0] rx_data,
    input        uart_rx,
    output       rx_done,
    
    input        tx_start,
    input  [7:0] tx_data,
    output       uart_tx,
    output       tx_busy,
    output       tx_done
);

    logic w_b_tick;

    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .uart_tx(uart_tx)
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick),
        .rx(uart_rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // [수정됨] boud_tick -> baud_tick
    baud_tick U_baud_tick (
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick)
    );

endmodule
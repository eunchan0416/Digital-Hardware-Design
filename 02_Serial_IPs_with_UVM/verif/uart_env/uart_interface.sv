interface uart_if (input logic clk, input logic rst);

    logic [7:0] rx_data;
    logic uart_rx;
    logic rx_done;
    logic tx_start;
    logic [7:0] tx_data;
    logic uart_tx;
    logic tx_busy;
    logic tx_done;

clocking drv_cb @(posedge clk);
    default input #1ns output #0;

    output uart_rx;
    output tx_start;
    output  tx_data;

endclocking

clocking mon_cb @(posedge clk);
    default input #1ns output #0;

    input uart_rx;
    input tx_start;
    input  tx_data;
    input uart_tx;
    input tx_busy;
    input tx_done;
    input rx_done;
    input rx_data;
endclocking

modport DRV (clocking drv_cb, input clk, input rst);
modport MON (clocking mon_cb, input clk, input rst);
endinterface
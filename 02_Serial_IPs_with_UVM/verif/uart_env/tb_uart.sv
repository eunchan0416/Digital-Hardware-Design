`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uart_interface.sv"
`include "uart_seq_item.sv"
`include "uart_sequence.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"
`include "uart_agent.sv"
`include "uart_scoreboard.sv"
`include "uart_env.sv"
`include "uart_test.sv" 

module tb_uart ();
    logic rst;
    logic clk;

    initial clk = 0;
    always #5 clk = ~clk;

    uart_if u_if (clk, rst);

    
    uart_top dut (
        .clk(clk),
        .rst(rst),
        .rx_data(u_if.rx_data),
        .uart_rx(u_if.uart_rx),
        .rx_done(u_if.rx_done),
        .tx_start(u_if.tx_start),
        .tx_data(u_if.tx_data),
        .uart_tx(u_if.uart_tx),
        .tx_busy(u_if.tx_busy),
        .tx_done(u_if.tx_done)
    );

initial begin
        rst = 0;
        @(posedge clk);
        rst = 1;        
        @(posedge clk);
        rst = 0;
        @(posedge clk);

    end
    initial begin
      
        `uvm_info("tb_uart", "=== Starting the UART UVM Test ===", UVM_LOW)
        uvm_config_db#(virtual uart_if)::set(null,"*","u_if",u_if);
        run_test("uart_base_test");
    end

endmodule
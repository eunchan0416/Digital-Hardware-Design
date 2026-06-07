`timescale 1ns / 1ps


module spi_top (
    input  logic       clk,
    input  logic       reset,
    input  logic       start,
    input  logic [7:0] tx_data_m,
    input  logic [7:0] tx_data_s,
    input  logic       cpol,
    input  logic       cpha,
    input  logic [1:0] cs,
    output logic       busy,
    output logic       done,
    output logic [7:0] rx_data_m,
    output logic [7:0] rx_data_s0,
    output logic [7:0] rx_data_s1,
    output logic [7:0] rx_data_s2,
    output logic [7:0] rx_data_s3
);

    logic sclk;
    logic mosi;

    logic cs_n0;
    logic cs_n1;
    logic cs_n2;
    logic cs_n3;

    wire  miso;

 
    spi_master U_MASTER (
        .clk(clk),
        .reset(reset),
        .cpol(cpol),
        .cpha(cpha),
        .clk_div(8'd4),
        .tx_data(tx_data_m),
        .start(start),
        .rx_data(rx_data_m),
        .done(done),
        .busy(),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso), 
        .cs(cs),
        .cs_n0(cs_n0),
        .cs_n1(cs_n1),
        .cs_n2(cs_n2),
        .cs_n3(cs_n3)
    );

  

    // Mode 0: CPOL=0, CPHA=0
    spi_slave U_SLAVE_0 (
        .clk(clk),
        .reset(reset),
        .sclk(sclk),
        .cs_n(cs_n0),
        .mosi(mosi),
        .miso(miso),  
        .tx_data(tx_data_s),
        .cpol(1'b0),
        .cpha(1'b0),
        .rx_data(rx_data_s0),
        .rx_done()
    );

    // Mode 1: CPOL=0, CPHA=1
    spi_slave U_SLAVE_1 (
        .clk(clk),
        .reset(reset),
        .sclk(sclk),
        .cs_n(cs_n1),
        .mosi(mosi),
        .miso(miso),  
        .tx_data(tx_data_s),
        .cpol(1'b0),
        .cpha(1'b1),
        .rx_data(rx_data_s1),
        .rx_done()
    );

    // Mode 2: CPOL=1, CPHA=0
    spi_slave U_SLAVE_2 (
        .clk(clk),
        .reset(reset),
        .sclk(sclk),
        .cs_n(cs_n2),
        .mosi(mosi),
        .miso(miso),  
        .tx_data(tx_data_s),
        .cpol(1'b1),
        .cpha(1'b0),
        .rx_data(rx_data_s2),
        .rx_done()
    );

    // Mode 3: CPOL=1, CPHA=1
    spi_slave U_SLAVE_3 (
        .clk(clk),
        .reset(reset),
        .sclk(sclk),
        .cs_n(cs_n3),
        .mosi(mosi),
        .miso(miso),  
        .tx_data(tx_data_s),
        .cpol(1'b1),
        .cpha(1'b1),
        .rx_data(rx_data_s3),
        .rx_done()
    );

endmodule

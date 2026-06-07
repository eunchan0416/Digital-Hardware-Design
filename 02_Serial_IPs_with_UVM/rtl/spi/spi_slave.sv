`timescale 1ns / 1ps




module spi_slave (
    input  logic       clk,
    input  logic       sclk,
    input  logic       reset,
    input  logic       cs_n,
    input  logic       mosi,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       rx_done,
    output logic       miso,
    input  logic       cpol,
    input  logic       cpha
);


    logic [2:0] sclk_sync;
    logic [2:0] cs_n_sync;
    logic [1:0] mosi_sync;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cs_n_sync <= 3'b111;
            mosi_sync <= 2'b00;
            sclk_sync <= 3'b000;
        end else begin
            sclk_sync <= {sclk_sync[1:0], sclk};
            cs_n_sync <= {cs_n_sync[1:0], cs_n};
            mosi_sync <= {mosi_sync[0], mosi};
        end
    end


    logic sclk_r_edge, sclk_f_edge;
    assign sclk_r_edge = (sclk_sync[2:1] == 2'b01);
    assign sclk_f_edge = (sclk_sync[2:1] == 2'b10);


    logic sample_edge;
    logic shift_edge;

    always_comb begin
        if (cpha == 0) begin
            // CPHA = 0: first edge Capture(Sample), second edge Shift
            sample_edge = (cpol == 0) ? sclk_r_edge : sclk_f_edge;
            shift_edge  = (cpol == 0) ? sclk_f_edge : sclk_r_edge;
        end else begin
            // CPHA = 1: first edge Shift, second edge  Capture(Sample)
            shift_edge  = (cpol == 0) ? sclk_r_edge : sclk_f_edge;
            sample_edge = (cpol == 0) ? sclk_f_edge : sclk_r_edge;
        end
    end


    logic [7:0] tx_shift_reg;
    logic [7:0] rx_shift_reg;
    logic [2:0] bit_cnt;
    logic       first_shift;


    assign miso = (!cs_n) ? tx_shift_reg[7] : 1'bz;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_shift_reg <= 8'd0;
            tx_shift_reg <= 8'd0;
            bit_cnt      <= 3'd0;
            rx_done      <= 1'b0;
            rx_data      <= 8'd0;
            first_shift  <= 1'b1;
        end else begin
            rx_done <= 1'b0;

            if (!cs_n_sync[1]) begin

                //  (Shift) 
                if (shift_edge) begin
                    if (cpha == 1 && first_shift) begin
                        first_shift <= 1'b0;
                    end else begin
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    end
                end

                //  (Sample) 
                if (sample_edge) begin
                    rx_shift_reg <= {rx_shift_reg[6:0], mosi_sync[1]};
                    bit_cnt      <= bit_cnt + 1;


                    if (bit_cnt == 3'd7) begin
                        rx_data <= {rx_shift_reg[6:0], mosi_sync[1]};
                        rx_done <= 1'b1;
                    end
                end

            end else begin
                bit_cnt <= 3'd0;
                tx_shift_reg <= tx_data;
                first_shift <= 1'b1;
            end
        end
    end
endmodule

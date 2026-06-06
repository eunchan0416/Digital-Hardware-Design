`timescale 1ns / 1ps

module uart_rx (
    input clk,
    input rst,
    input rx,
    input b_tick,
    output [7:0] rx_data,
    output rx_done
);

    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    reg [1:0] c_state, n_state;
    reg [4:0] b_tick_cnt_reg, b_tick_cnt_next;
    reg [2:0] bit_cnt_next, bit_cnt_reg;
    reg done_reg, done_next;

    reg [7:0] buf_reg, buf_next;

    assign rx_done = done_reg;
    assign rx_data = buf_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state        <= 0;
            b_tick_cnt_reg <= 0;
            bit_cnt_reg    <= 0;
            done_reg       <= 0;
            buf_reg        <= 0;
        end else begin
            c_state        <= n_state;
            b_tick_cnt_reg <= b_tick_cnt_next;
            bit_cnt_reg    <= bit_cnt_next;
            done_reg       <= done_next;
            buf_reg        <= buf_next;
        end
    end

    always @(*) begin
        n_state         = c_state;
        b_tick_cnt_next = b_tick_cnt_reg;
        bit_cnt_next    = bit_cnt_reg;
        done_next       = done_reg;
        buf_next        = buf_reg;

        case (c_state)
            IDLE: begin
                done_next       = 0;
                b_tick_cnt_next = 0;
                bit_cnt_next    = 0;
                if (b_tick && (rx == 0)) begin
                    n_state = START;
                    buf_next = 0;
                    b_tick_cnt_next = 0;
                end
            end
            START: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 7) begin
                        n_state = DATA;
                        b_tick_cnt_next = 0;
                    end else b_tick_cnt_next = b_tick_cnt_reg + 1;
                end
            end
            DATA: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 0;
                        buf_next = {rx, buf_reg[7:1]};
                        if (bit_cnt_reg == 7) begin
                            n_state = STOP;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else b_tick_cnt_next = b_tick_cnt_reg + 1;
                end
            end
            STOP: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        n_state = IDLE;
                        done_next = 1;
                        b_tick_cnt_next = 0;
                    end else b_tick_cnt_next = b_tick_cnt_reg + 1;
                end
            end
            default: begin
                done_next       = 0;
                b_tick_cnt_next = 0;
                bit_cnt_next    = 0;
                buf_next        = 0;
            end
        endcase
    end
endmodule
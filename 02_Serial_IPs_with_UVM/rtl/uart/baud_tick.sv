`timescale 1ns / 1ps

// [수정됨] 모듈명 boud_tick -> baud_tick
module baud_tick (
    input      clk,
    input      rst,
    output reg b_tick
);
    parameter BAUDRATE = 9600 * 16;  // speed x16
    parameter F_COUNT = (100_000_000 / BAUDRATE);
    reg [$clog2(F_COUNT)-1:0] counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= 0;
            b_tick  <= 0;
        end else begin
            if (counter == (F_COUNT - 1)) begin
                counter <= 0;
                b_tick  <= 1;
            end else begin
                counter <= counter + 1;
                b_tick  <= 0;
            end
        end
    end

endmodule
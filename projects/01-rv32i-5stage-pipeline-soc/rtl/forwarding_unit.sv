`timescale 1ns / 1ps
`include "define.vh"

module forwarding_unit (
    input  logic [ 4:0] id_ex_rs1,
    input  logic [ 4:0] id_ex_rs2,
    input  logic [ 4:0] ex_mem_rd,
    input  logic        ex_mem_rf_we,
    input  logic [ 4:0] mem_wb_rd,
    input  logic        mem_wb_rf_we,

    output logic [ 1:0] forward_a,
    output logic [ 1:0] forward_b
);

    // Forwarding for rs1
    always_comb begin
        if (ex_mem_rf_we && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_a = 2'b10;
        end else if (mem_wb_rf_we && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1)) begin
            forward_a = 2'b01;
        end else begin
            forward_a = 2'b00;
        end
    end

    // Forwarding for rs2
    always_comb begin
        if (ex_mem_rf_we && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_b = 2'b10;
        end else if (mem_wb_rf_we && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2)) begin
            forward_b = 2'b01;
        end else begin
            forward_b = 2'b00;
        end
    end

endmodule
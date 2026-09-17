`timescale 1ns / 1ps

module instruction_mem (
    input  logic [31:0] instr_addr,
    output logic [31:0] instr_data
);

    logic [31:0] rom[0:1023];

    initial begin
        $readmemh("test.mem", rom);
    end

    assign instr_data = rom[instr_addr[11:2]];

endmodule

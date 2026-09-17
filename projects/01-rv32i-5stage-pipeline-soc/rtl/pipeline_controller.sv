`timescale 1ns / 1ps

module pipeline_controller (
    // Hazard Detection Inputs
    input  logic        id_ex_mem_read,  // EX stage is Load instruction
    input  logic [ 4:0] id_ex_rd,        // EX stage destination register
    input  logic [ 4:0] if_id_rs1,       // ID stage source register 1
    input  logic [ 4:0] if_id_rs2,       // ID stage source register 2
    input  logic        ex_take_branch,  // EX stage branch/jump taken (Flush용)
    input  logic        ex_branch,       // [타이밍 핵심] ID/EX Q핀 직접 직결
    input  logic        ex_jal,          // [타이밍 핵심] ID/EX Q핀 직접 직결
    input  logic        ex_jalr,         // [타이밍 핵심] ID/EX Q핀 직접 직결
    input  logic        apb_busy,        // APB bus busy / wait state

    // Trap & Interrupt Control Inputs
    input  logic        trap_pending,    // Core interrupt pending from CSR
    input  logic        id_valid,        // ID stage instruction validity flag
    input  logic [31:0] if_pc,           // IF stage current PC
    input  logic [31:0] id_pc,           // ID stage current PC
    input  logic        ex_csr_we,       // EX stage is modifying CSR
    input  logic        ex_is_mret,      // EX stage is executing MRET

    // Pipeline Stall Outputs
    output logic        stall_if,
    output logic        stall_id,
    output logic        stall_ex,
    output logic        stall_mem,
    output logic        stall_wb,

    // Pipeline Flush Outputs
    output logic        flush_if_id,
    output logic        flush_id_ex,

    // CSR Trap/Return Control Outputs
    output logic        trap_taken,
    output logic [31:0] trap_pc,
    output logic [31:0] trap_cause,
    output logic        mret_taken,

    // IF Stage PC Source Override
    output logic [ 1:0] pc_src_override
);

    // 1. Data Hazard Detection (Load-Use)
    logic load_use_hazard;
    assign load_use_hazard = id_ex_mem_read &&
                             (id_ex_rd != 5'd0) &&
                             ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2));

    // 2. Trap & Interrupt Arbitration
    // [타이밍 최적화]: 느린 ALU 연산 결과(ex_take_branch) 대신 레지스터 Q핀 제어선 사용
    wire ex_is_control_flow = ex_branch | ex_jal | ex_jalr;
    assign trap_taken  = trap_pending & !ex_is_control_flow & !apb_busy & !ex_csr_we & !ex_is_mret;

    assign trap_pc     = (!id_valid) ? if_pc : id_pc;
    assign trap_cause  = 32'h8000_000B; // Machine External Interrupt Code

    // 3. MRET Execution Arbitration
    assign mret_taken  = ex_is_mret & !apb_busy;

    // 4. IF Stage PC Source Override MUX
    always_comb begin
        if (trap_taken) begin
            pc_src_override = 2'b10; // mtvec
        end else if (mret_taken) begin
            pc_src_override = 2'b11; // mepc
        end else begin
            pc_src_override = 2'b00; // Normal sequential / Branch
        end
    end

    // 5. Stall & Flush Combined Generation
    logic raw_flush_if_id;
    logic raw_flush_id_ex;

    always_comb begin
        stall_if        = 1'b0;
        stall_id        = 1'b0;
        stall_ex        = 1'b0;
        stall_mem       = 1'b0;
        stall_wb        = 1'b0;
        raw_flush_if_id = 1'b0;
        raw_flush_id_ex = 1'b0;

        if (apb_busy) begin
            stall_if  = 1'b1;
            stall_id  = 1'b1;
            stall_ex  = 1'b1;
            stall_mem = 1'b1;
            stall_wb  = 1'b1;
        end else if (ex_take_branch) begin
            raw_flush_if_id = 1'b1;
            raw_flush_id_ex = 1'b1;
        end else if (load_use_hazard) begin
            stall_if        = 1'b1;
            stall_id        = 1'b1;
            raw_flush_id_ex = 1'b1;
        end
    end

    assign flush_if_id = raw_flush_if_id | trap_taken | mret_taken;
    assign flush_id_ex = raw_flush_id_ex | trap_taken | mret_taken;

endmodule
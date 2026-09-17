`timescale 1ns / 1ps

module hazard_detection_unit (
    // Inputs for Load-Use Hazard Detection
    input  logic       id_ex_mem_read,  // EX 단계 명령어가 Load인지 확인
    input  logic [4:0] id_ex_rd,        // EX 단계의 목적지 레지스터 번호
    input  logic [4:0] if_id_rs1,       // ID 단계가 읽으려는 소스 레지스터 1
    input  logic [4:0] if_id_rs2,       // ID 단계가 읽으려는 소스 레지스터 2

    // Input for Control Hazard Detection (Branch/Jump Taken)
    input  logic       ex_take_branch,  // EX 단계에서 분기/점프 확정 (1: Taken)

    // Input for APB MMIO Bus Freeze (Optional / Reserved)
    input  logic       apb_busy,        // 1: APB 버스 대기 중

    // Outputs for Pipeline Register Control
    output logic       stall_if,        // PC Reg 얼림
    output logic       stall_id,        // pipe_if_id 얼림
    output logic       stall_ex,
    output logic       stall_mem,
    output logic       stall_wb,
    output logic       flush_if_id,     // pipe_if_id NOP 세탁 (분기 실패 시)
    output logic       flush_id_ex      // pipe_id_ex NOP 주입 (Load-Use 버블 또는 분기 실패)
);

    logic load_use_hazard;

    // Load-Use Hazard Detection Logic
    // 선행어가 Load이고, 목적지가 x0이 아니며, 후속어의 rs1 또는 rs2와 일치할 때!
    assign load_use_hazard = id_ex_mem_read &&
                             (id_ex_rd != 5'd0) &&
                             ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2));

    always_comb begin
        // 기본값: 정상 전진
        stall_if    = 1'b0;
        stall_id    = 1'b0;
        stall_ex    = 1'b0;
        stall_mem   = 1'b0;
        stall_wb    = 1'b0;
        flush_if_id = 1'b0;
        flush_id_ex = 1'b0;

        // 1. APB 버스 대기 (최우선: 전체 동결)
        if (apb_busy) begin
            stall_if  = 1'b1;
            stall_id  = 1'b1;
            stall_ex  = 1'b1;
            stall_mem = 1'b1;
            stall_wb  = 1'b1;
        end
        // 2. Control Hazard (분기 성공/점프 시: 2-Stage 동기 Flush)
        else if (ex_take_branch) begin
            flush_if_id = 1'b1; // IF/ID의 잘못 들어온 명령어 NOP 세탁
            flush_id_ex = 1'b1; // ID/EX의 잘못 들어온 명령어 NOP 세탁
        end
        // 3. Load-Use Data Hazard (1-Cycle Stall & NOP Bubble 주입)
        else if (load_use_hazard) begin
            stall_if    = 1'b1; // PC 유지 (동결)
            stall_id    = 1'b1; // pipe_if_id 유지 (동결)
            flush_id_ex = 1'b1; // pipe_id_ex에 NOP 버블 주입!
        end
    end

endmodule

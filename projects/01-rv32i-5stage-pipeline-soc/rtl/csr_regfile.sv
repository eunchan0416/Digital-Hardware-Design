`timescale 1ns / 1ps
`include "define.vh"

module csr_regfile (
    input  logic        clk,
    input  logic        rst,

    // CSR Read / Write Interface (from EX Stage)
    input  logic [11:0] csr_addr,
    input  logic [31:0] csr_rs1_data,   // Forwarded rs1 operand data
    input  logic [ 4:0] csr_zimm,       // 5-bit unsigned immediate (instr[19:15])
    input  logic [ 2:0] csr_op,         // funct3: [2]=1 (Imm), [1:0]=01(RW), 10(RS), 11(RC)
    input  logic        csr_we,
    output logic [31:0] csr_rdata,

    // Trap / Interrupt Hardware Interface
    input  logic        trap_taken,     // Asserted for 1 cycle when entering trap
    input  logic [31:0] trap_pc,        // PC to save into mepc
    input  logic [31:0] trap_cause,     // Cause code to save into mcause
    input  logic        mret_taken,     // Asserted for 1 cycle when executing mret

    // External Interrupt Input & Core Status
    input  logic        ext_irq,        // External interrupt request pin
    output logic [31:0] o_mtvec,        // Trap handler base PC
    output logic [31:0] o_mepc,         // Saved exception PC
    output logic        o_trap_pending  // Core interrupt condition met
);

    // =========================================================================
    // Machine-Mode CSR Registers
    // =========================================================================
    // mstatus: [12:11]=MPP(2'b11 for M-mode), [7]=MPIE, [3]=MIE
    logic        mstatus_mie;
    logic        mstatus_mpie;
    logic [ 1:0] mstatus_mpp;

    // mie: [11]=MEIE (Machine External Interrupt Enable)
    logic        mie_meie;

    // mtvec: [31:2]=Base Vector Address, [1:0]=Mode (00: Direct)
    logic [31:0] mtvec_reg;

    // mepc: Exception PC
    logic [31:0] mepc_reg;

    // mcause: [31]=Interrupt, [30:0]=Exception Code
    logic [31:0] mcause_reg;

    // =========================================================================
    // External Interrupt Pending State & Outputs
    // =========================================================================
    // ext_irq는 보드 입력 회로가 만든 1-cycle pulse이다. 파이프라인이 branch,
    // APB wait, CSR/MRET 명령 등으로 즉시 trap을 받을 수 없더라도 이벤트를 잃지
    // 않도록 MEIP를 sticky pending bit로 보존한다.
    logic        meip_pending_reg;

    // mip: [11]=MEIP (Machine External Interrupt Pending, read-only)
    logic [31:0] mip_wire;
    assign mip_wire = {20'd0, meip_pending_reg, 11'd0};

    // Full 32-bit reconstructed registers for Read operations
    // mstatus 비트맵:
    //  - [12:11] MPP  : Machine Previous Privilege (트랩 진입 직전 권한 모드, 2'b11 = M-mode)
    //  - [7]     MPIE : Machine Previous Interrupt Enable (트랩 진입 전 MIE 상태 백업 포스트잇)
    //  - [3]     MIE  : Machine Interrupt Enable (글로벌 인터럽트 메인 스위치: 1=허용, 0=차단)
    logic [31:0] mstatus_wire;
    assign mstatus_wire = {19'd0, mstatus_mpp, 3'd0, mstatus_mpie, 3'd0, mstatus_mie, 3'd0};

    logic [31:0] mie_wire;
    assign mie_wire = {20'd0, mie_meie, 11'd0};

    // Output assignments
    assign o_mtvec = mtvec_reg;
    assign o_mepc  = mepc_reg;

    // Pending 보존과 interrupt enable은 서로 분리한다. MIE/MEIE가 0인 동안에도
    // MEIP는 유지되고, 두 enable이 다시 1이 되면 controller가 trap을 수락한다.
    assign o_trap_pending = meip_pending_reg & mie_meie & mstatus_mie;

    // =========================================================================
    // External Interrupt Event Capture / Acknowledge
    // =========================================================================
    // trap_taken은 pipeline_controller가 실제 trap 진입을 수락한 acknowledge이다.
    // 새 ext_irq와 acknowledge가 같은 cycle에 겹치면 새 이벤트를 보존한다.
    // 단일 bit이므로 처리 전 여러 pulse는 하나의 pending 이벤트로 합쳐진다.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            meip_pending_reg <= 1'b0;
        end else begin
            case ({ext_irq, trap_taken})
                2'b10:   meip_pending_reg <= 1'b1; // 새 이벤트 저장
                2'b01:   meip_pending_reg <= 1'b0; // trap 수락 시 clear
                2'b11:   meip_pending_reg <= 1'b1; // 동시에 온 새 이벤트 보존
                default: meip_pending_reg <= meip_pending_reg;
            endcase
        end
    end

    // =========================================================================
    // CSR Read Multiplexer
    // =========================================================================
    always_comb begin
        case (csr_addr)
            `CSR_MSTATUS: csr_rdata = mstatus_wire;
            `CSR_MIE:     csr_rdata = mie_wire;
            `CSR_MTVEC:   csr_rdata = mtvec_reg;
            `CSR_MEPC:    csr_rdata = mepc_reg;
            `CSR_MCAUSE:  csr_rdata = mcause_reg;
            `CSR_MIP:     csr_rdata = mip_wire;
            default:      csr_rdata = 32'd0;
        endcase
    end

    // =========================================================================
    // Next Write Data Calculation based on CSR Operation
    // =========================================================================
    // 1) zimm(5비트 즉치) vs rs1 데이터 선택 MUX (funct3[2]가 1이면 Immediate)
    logic [31:0] raw_wdata;
    assign raw_wdata = csr_op[2] ? {27'd0, csr_zimm} : csr_rs1_data;

    // 2) 소프트웨어 CSR 명령어 종류에 따른 최종 유효 쓰기 데이터 wdata_eff 계산
    logic [31:0] wdata_eff;
    always_comb begin
        case (csr_op)
            // 1) CSRRW / CSRRWI: 기존 값 무시하고 새로운 값으로 덮어쓰기 (Overwrite)
            `CSR_RW, `CSR_RWI: wdata_eff = raw_wdata;
            
            // 2) CSRRS / CSRRSI: 지정한 비트만 1로 켜기 (Bitwise OR / Set)
            //    예: mstatus의 MIE(비트 3)만 켜고 싶을 때 사용
            `CSR_RS, `CSR_RSI: wdata_eff = csr_rdata | raw_wdata;
            
            // 3) CSRRC / CSRRCI: 지정한 비트만 0으로 끄기 (Bitwise Clear)
            //    예: mstatus의 MIE(비트 3)만 끄고 싶을 때 사용 (반전 마스크와 AND)
            `CSR_RC, `CSR_RCI: wdata_eff = csr_rdata & ~raw_wdata;
            
            default:           wdata_eff = raw_wdata;
        endcase
    end

    // =========================================================================
    // Synchronous CSR State Update (상태 갱신 우선순위 제어)
    // =========================================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mstatus_mie  <= 1'b0;
            mstatus_mpie <= 1'b0;
            mstatus_mpp  <= 2'b11; // Machine mode 기본값
            mie_meie     <= 1'b0;
            mtvec_reg    <= 32'h8000_0040; // Default Reset Vector
            mepc_reg     <= 32'h0000_0000;
            mcause_reg   <= 32'h0000_0000;
        end else begin
            // 1순위: 하드웨어 트랩(인터럽트) 진입 (최우선순위)
            //       - 복귀 PC/원인 기록, MIE 백업 후 중첩 인터럽트 방지 위해 MIE=0 차단
            if (trap_taken) begin
                mepc_reg     <= trap_pc;
                mcause_reg   <= trap_cause;
                mstatus_mpie <= mstatus_mie; // Backup previous MIE
                mstatus_mie  <= 1'b0;        // Disable interrupts during handler
            end
            // 2순위: 하드웨어 MRET 복귀 명령어 실행
            //       - 백업해두었던 MPIE를 꺼내 MIE로 원상 복원하여 인터럽트 재활성화
            else if (mret_taken) begin
                mstatus_mie  <= mstatus_mpie; // Restore MIE
                mstatus_mpie <= 1'b1;         // Default return state
            end
            // 3순위: 소프트웨어(C/어셈블리) CSR 쓰기 명령어 실행 (csrw, csrs, csrc)
            else if (csr_we) begin
                case (csr_addr)
                    `CSR_MSTATUS: begin
                        mstatus_mie  <= wdata_eff[3];      // MIE 비트 갱신
                        mstatus_mpie <= wdata_eff[7];      // MPIE 비트 갱신
                        mstatus_mpp  <= wdata_eff[12:11];  // MPP 비트 갱신
                    end
                    `CSR_MIE: begin
                        mie_meie     <= wdata_eff[11];     // 외부 인터럽트 개별 허용 비트 갱신
                    end
                    `CSR_MTVEC: begin
                        // Direct 모드만 지원하므로 하위 2비트를 2'b00으로 강제 (4바이트 정렬)
                        mtvec_reg    <= {wdata_eff[31:2], 2'b00};
                    end
                    `CSR_MEPC: begin
                        // 복귀 명령어 주소이므로 하위 2비트를 2'b00으로 강제 (4바이트 정렬)
                        mepc_reg     <= {wdata_eff[31:2], 2'b00};
                    end
                    `CSR_MCAUSE: begin
                        mcause_reg   <= wdata_eff;
                    end
                    // MIP.MEIP는 HW pending 상태를 보여주는 Read-Only이므로 SW 쓰기 무시
                    default: ;
                endcase
            end
        end
    end

endmodule

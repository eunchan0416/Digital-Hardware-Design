`timescale 1ns / 1ps
`include "define.vh"

module rv32i_datapath (
    input  logic        clk,
    input  logic        rst,

    // Instruction Memory Interface (IF Stage)
    output logic [31:0] instr_addr,
    input  logic [31:0] instr_data,

    // Data Memory Interface (MEM Stage)
    output logic [31:0] daddr,
    output logic [31:0] dwdata,
    output logic [ 3:0] dstrb,
    output logic        dwe,
    output logic        mem_read,
    input  logic [31:0] drdata,

    // APB MMIO Bus Busy Interface
    input  logic        apb_busy,

    // External Interrupt Pin
    input  logic        ext_irq
);

    // 1. Control Signals
    logic        stall_if, stall_id, stall_ex, stall_mem, stall_wb;
    logic        flush_if_id, flush_id_ex;
    logic        trap_taken, mret_taken;
    logic [31:0] trap_pc, trap_cause;
    logic [ 1:0] pc_src_override;

    // 2. CSR Status
    logic [31:0] mtvec_out, mepc_out;
    logic        trap_pending;
    logic [31:0] csr_rdata_wire;

    // 3. Forwarding Signals
    logic [ 1:0] forward_a, forward_b;
    logic [31:0] ex_forward_val, mem_forward_val;

    // 4. Register File Signals
    logic [ 4:0] rf_raddr1, rf_raddr2;
    logic [31:0] rf_rdata1, rf_rdata2;
    logic [ 4:0] wb_rd;
    logic [31:0] wb_wdata;
    logic        wb_rf_we;

    // 5. IF Stage Signals
    logic [31:0] ex_pc_target;
    logic        ex_take_branch;
    logic [31:0] if_pc, if_pc_plus_4;
    logic [31:0] id_pc, id_pc_plus_4, id_instr;
    logic        id_valid;

    // 6. ID Stage Signals
    logic        id_alu_src, id_branch, id_jal, id_jalr, id_dwe, id_mem_read, id_rf_we;
    logic [ 3:0] id_alu_control;
    logic [ 2:0] id_rfwd_src, id_funct3;
    logic [ 6:0] id_funct7;
    logic [ 4:0] id_rd, id_rs1, id_rs2;
    logic [31:0] id_rs1_data, id_rs2_data, id_imm;
    logic        id_csr_we, id_is_mret;
    logic [ 2:0] id_csr_op;

    // 7. EX Stage Signals
    logic        ex_alu_src, ex_branch, ex_jal, ex_jalr, ex_dwe, ex_mem_read, ex_rf_we;
    logic [ 3:0] ex_alu_control;
    logic [ 2:0] ex_rfwd_src, ex_funct3;
    logic [ 6:0] ex_funct7;
    logic [ 4:0] ex_rd, ex_rs1, ex_rs2;
    logic [31:0] ex_pc, ex_pc_plus_4, ex_rs1_data, ex_rs2_data, ex_imm;
    logic        ex_csr_we, ex_is_mret;
    logic [ 2:0] ex_csr_op;
    logic [31:0] ex_alu_result, ex_rs2_data_out, ex_imm_out, ex_auipc, ex_pc_plus_4_out;
    logic [ 4:0] ex_rd_out;
    logic [ 2:0] ex_funct3_out;
    logic        ex_dwe_out, ex_mem_read_out, ex_rf_we_out;
    logic [ 2:0] ex_rfwd_src_out;
    logic [31:0] ex_rs1_fwd_data_wire;

    // 8. MEM Stage Signals
    logic [ 4:0] mem_rd;
    logic        mem_rf_we_in;
    logic [31:0] mem_alu_result;
    logic [31:0] mem_pc_plus_4, mem_rs2_data, mem_imm, mem_auipc;
    logic [ 2:0] mem_funct3;
    logic        mem_dwe_in, mem_mem_read_in;
    logic [ 2:0] mem_rfwd_src_in;
    logic [31:0] mem_wb_pc_plus_4, mem_wb_alu_result, mem_wb_drdata, mem_wb_imm, mem_wb_auipc;
    logic [ 4:0] mem_wb_rd;
    logic        mem_wb_rf_we;
    logic [ 2:0] mem_wb_rfwd_src;

    // 9. WB Stage Signals
    logic [31:0] final_wb_pc_plus_4, final_wb_alu_result, final_wb_drdata, final_wb_imm, final_wb_auipc;
    logic [ 2:0] final_wb_rfwd_src;

    // Module Instantiations
    pipeline_controller U_PIPELINE_CONTROLLER (
        .id_ex_mem_read (ex_mem_read),
        .id_ex_rd       (ex_rd),
        .if_id_rs1      (id_rs1),
        .if_id_rs2      (id_rs2),
        .ex_take_branch (ex_take_branch),
        .ex_branch      (ex_branch),       // [직결]
        .ex_jal         (ex_jal),          // [직결]
        .ex_jalr        (ex_jalr),         // [직결]
        .apb_busy       (apb_busy),
        .trap_pending   (trap_pending),
        .id_valid       (id_valid),
        .if_pc          (if_pc),
        .id_pc          (id_pc),
        .ex_csr_we      (ex_csr_we),
        .ex_is_mret     (ex_is_mret),
        .stall_if       (stall_if),
        .stall_id       (stall_id),
        .stall_ex       (stall_ex),
        .stall_mem      (stall_mem),
        .stall_wb       (stall_wb),
        .flush_if_id    (flush_if_id),
        .flush_id_ex    (flush_id_ex),
        .trap_taken     (trap_taken),
        .trap_pc        (trap_pc),
        .trap_cause     (trap_cause),
        .mret_taken     (mret_taken),
        .pc_src_override(pc_src_override)
    );

    forwarding_unit U_FORWARDING_UNIT (
        .id_ex_rs1    (ex_rs1),
        .id_ex_rs2    (ex_rs2),
        .ex_mem_rd    (mem_rd),
        .ex_mem_rf_we (mem_rf_we_in),
        .mem_wb_rd    (wb_rd),
        .mem_wb_rf_we (wb_rf_we),
        .forward_a    (forward_a),
        .forward_b    (forward_b)
    );

    csr_regfile U_CSR_REGFILE (
        .clk           (clk),
        .rst           (rst),
        .csr_addr      (ex_imm[11:0]),
        .csr_rs1_data  (ex_rs1_fwd_data_wire),
        .csr_zimm      (ex_rs1),
        .csr_op        (ex_csr_op),
        .csr_we        (ex_csr_we),
        .csr_rdata     (csr_rdata_wire),
        .trap_taken    (trap_taken),
        .trap_pc       (trap_pc),
        .trap_cause    (trap_cause),
        .mret_taken    (mret_taken),
        .ext_irq       (ext_irq),
        .o_mtvec       (mtvec_out),
        .o_mepc        (mepc_out),
        .o_trap_pending(trap_pending)
    );

    register_file U_REG_FILE (
        .clk   (clk),
        .rst   (rst),
        .raddr1(rf_raddr1),
        .raddr2(rf_raddr2),
        .waddr (wb_rd),
        .wdata (wb_wdata),
        .we    (wb_rf_we),
        .rdata1(rf_rdata1),
        .rdata2(rf_rdata2)
    );

    if_stage U_IF_STAGE (
        .clk                   (clk),
        .rst                   (rst),
        .stall                 (stall_if),
        .ex_pc_target          (ex_pc_target),
        .ex_take_branch        (ex_take_branch),
        .i_mtvec               (mtvec_out),
        .i_mepc                (mepc_out),
        .i_pc_src_sel_override (pc_src_override),
        .instr_addr            (instr_addr),
        .o_pc                  (if_pc),
        .o_pc_plus_4           (if_pc_plus_4)
    );

    pipe_if_id U_PIPE_IF_ID (
        .clk        (clk),
        .rst        (rst),
        .flush      (flush_if_id),
        .stall      (stall_id),
        .i_pc       (if_pc),
        .i_pc_plus_4(if_pc_plus_4),
        .i_instr    (instr_data),
        .o_pc       (id_pc),
        .o_pc_plus_4(id_pc_plus_4),
        .o_instr    (id_instr),
        .o_valid    (id_valid)
    );

    id_stage U_ID_STAGE (
        .instr        (id_instr),
        .pc           (id_pc),
        .pc_plus_4    (id_pc_plus_4),
        .rs1_data     (rf_rdata1),
        .rs2_data     (rf_rdata2),
        .rf_raddr1    (rf_raddr1),
        .rf_raddr2    (rf_raddr2),
        .alu_src      (id_alu_src),
        .alu_control  (id_alu_control),
        .branch       (id_branch),
        .jal          (id_jal),
        .jalr         (id_jalr),
        .dwe          (id_dwe),
        .mem_read     (id_mem_read),
        .rf_we        (id_rf_we),
        .rfwd_src     (id_rfwd_src),
        .csr_we       (id_csr_we),
        .csr_op       (id_csr_op),
        .is_mret      (id_is_mret),
        .o_pc         (),
        .o_pc_plus_4  (),
        .o_rs1_data   (id_rs1_data),
        .o_rs2_data   (id_rs2_data),
        .o_imm        (id_imm),
        .o_rd         (id_rd),
        .o_rs1        (id_rs1),
        .o_rs2        (id_rs2),
        .o_funct3     (id_funct3),
        .o_funct7     (id_funct7)
    );

    pipe_id_ex U_PIPE_ID_EX (
        .clk          (clk),
        .rst          (rst),
        .flush        (flush_id_ex),
        .stall        (stall_ex),
        .i_alu_src    (id_alu_src),
        .i_alu_control(id_alu_control),
        .i_branch     (id_branch),
        .i_jal        (id_jal),
        .i_jalr       (id_jalr),
        .i_dwe        (id_dwe),
        .i_mem_read   (id_mem_read),
        .i_rf_we      (id_rf_we),
        .i_rfwd_src   (id_rfwd_src),
        .i_csr_we     (id_csr_we),
        .i_csr_op     (id_csr_op),
        .i_is_mret    (id_is_mret),
        .i_pc         (id_pc),
        .i_pc_plus_4  (id_pc_plus_4),
        .i_rs1_data   (id_rs1_data),
        .i_rs2_data   (id_rs2_data),
        .i_imm        (id_imm),
        .i_funct3     (id_funct3),
        .i_funct7     (id_funct7),
        .i_rd         (id_rd),
        .i_rs1        (id_rs1),
        .i_rs2        (id_rs2),
        .o_alu_src    (ex_alu_src),
        .o_alu_control(ex_alu_control),
        .o_branch     (ex_branch),
        .o_jal        (ex_jal),
        .o_jalr       (ex_jalr),
        .o_dwe        (ex_dwe),
        .o_mem_read   (ex_mem_read),
        .o_rf_we      (ex_rf_we),
        .o_rfwd_src   (ex_rfwd_src),
        .o_csr_we     (ex_csr_we),
        .o_csr_op     (ex_csr_op),
        .o_is_mret    (ex_is_mret),
        .o_pc         (ex_pc),
        .o_pc_plus_4  (ex_pc_plus_4),
        .o_rs1_data   (ex_rs1_data),
        .o_rs2_data   (ex_rs2_data),
        .o_imm        (ex_imm),
        .o_funct3     (ex_funct3),
        .o_funct7     (ex_funct7),
        .o_rd         (ex_rd),
        .o_rs1        (ex_rs1),
        .o_rs2        (ex_rs2)
    );

    ex_stage U_EX_STAGE (
        .pc             (ex_pc),
        .pc_plus_4      (ex_pc_plus_4),
        .rs1_data       (ex_rs1_data),
        .rs2_data       (ex_rs2_data),
        .imm            (ex_imm),
        .funct3         (ex_funct3),
        .funct7         (ex_funct7),
        .rd             (ex_rd),
        .alu_src        (ex_alu_src),
        .alu_control    (ex_alu_control),
        .branch         (ex_branch),
        .jal            (ex_jal),
        .jalr           (ex_jalr),
        .dwe            (ex_dwe),
        .mem_read       (ex_mem_read),
        .rf_we          (ex_rf_we),
        .rfwd_src       (ex_rfwd_src),
        .forward_a      (forward_a),
        .forward_b      (forward_b),
        .forward_val_mem(mem_forward_val), // [초고속] 순수 레지스터 Q핀 직결
        .forward_val_wb (wb_wdata),
        .csr_rdata      (csr_rdata_wire),
        .ex_take_branch (ex_take_branch),
        .ex_pc_target   (ex_pc_target),
        .ex_rs1_fwd_data(ex_rs1_fwd_data_wire),
        .o_alu_result   (ex_alu_result),
        .o_rs2_data     (ex_rs2_data_out),
        .o_imm          (ex_imm_out),
        .o_auipc        (ex_auipc),
        .o_pc_plus_4    (ex_pc_plus_4_out),
        .o_rd           (ex_rd_out),
        .o_funct3       (ex_funct3_out),
        .o_forward_val  (ex_forward_val),  // Pre-calculated forwarding value
        .o_dwe          (ex_dwe_out),
        .o_mem_read     (ex_mem_read_out),
        .o_rf_we        (ex_rf_we_out),
        .o_rfwd_src     (ex_rfwd_src_out)
    );

    pipe_ex_mem U_PIPE_EX_MEM (
        .clk          (clk),
        .rst          (rst),
        .flush        (1'b0),
        .stall        (stall_mem),
        .i_dwe        (ex_dwe_out),
        .i_mem_read   (ex_mem_read_out),
        .i_rf_we      (ex_rf_we_out),
        .i_rfwd_src   (ex_rfwd_src_out),
        .i_pc_plus_4  (ex_pc_plus_4_out),
        .i_alu_result (ex_alu_result),
        .i_rs2_data   (ex_rs2_data_out),
        .i_imm        (ex_imm_out),
        .i_auipc      (ex_auipc),
        .i_rd         (ex_rd_out),
        .i_funct3     (ex_funct3_out),
        .i_forward_val(ex_forward_val),   // Latching
        .o_dwe        (mem_dwe_in),
        .o_mem_read   (mem_mem_read_in),
        .o_rf_we      (mem_rf_we_in),
        .o_rfwd_src   (mem_rfwd_src_in),
        .o_pc_plus_4  (mem_pc_plus_4),
        .o_alu_result (mem_alu_result),
        .o_rs2_data   (mem_rs2_data),
        .o_imm        (mem_imm),
        .o_auipc      (mem_auipc),
        .o_rd         (mem_rd),
        .o_funct3     (mem_funct3),
        .o_forward_val(mem_forward_val)   // Clean output straight to EX
    );

    mem_stage U_MEM_STAGE (
        .alu_result  (mem_alu_result),
        .rs2_data    (mem_rs2_data),
        .imm         (mem_imm),
        .auipc       (mem_auipc),
        .pc_plus_4   (mem_pc_plus_4),
        .rd          (mem_rd),
        .funct3      (mem_funct3),
        .dwe         (mem_dwe_in),
        .mem_read    (mem_mem_read_in),
        .rf_we       (mem_rf_we_in),
        .rfwd_src    (mem_rfwd_src_in),
        .daddr       (daddr),
        .dwdata      (dwdata),
        .dstrb       (dstrb),
        .mem_dwe     (dwe),
        .raw_drdata  (drdata),
        .o_pc_plus_4 (mem_wb_pc_plus_4),
        .o_alu_result(mem_wb_alu_result),
        .o_drdata    (mem_wb_drdata),
        .o_imm       (mem_wb_imm),
        .o_auipc     (mem_wb_auipc),
        .o_rd        (mem_wb_rd),
        .o_rf_we     (mem_wb_rf_we),
        .o_rfwd_src  (mem_wb_rfwd_src)
    );

    assign mem_read = mem_mem_read_in;

    pipe_mem_wb U_PIPE_MEM_WB (
        .clk         (clk),
        .rst         (rst),
        .flush       (1'b0),
        .stall       (stall_wb),
        .i_rf_we     (mem_wb_rf_we),
        .i_rfwd_src  (mem_wb_rfwd_src),
        .i_pc_plus_4 (mem_wb_pc_plus_4),
        .i_alu_result(mem_wb_alu_result),
        .i_drdata    (mem_wb_drdata),
        .i_imm       (mem_wb_imm),
        .i_auipc     (mem_wb_auipc),
        .i_rd        (mem_wb_rd),
        .o_rf_we     (wb_rf_we),
        .o_rfwd_src  (final_wb_rfwd_src),
        .o_pc_plus_4 (final_wb_pc_plus_4),
        .o_alu_result(final_wb_alu_result),
        .o_drdata    (final_wb_drdata),
        .o_imm       (final_wb_imm),
        .o_auipc     (final_wb_auipc),
        .o_rd        (wb_rd)
    );

    wb_stage U_WB_STAGE (
        .rfwd_src    (final_wb_rfwd_src),
        .alu_result  (final_wb_alu_result),
        .drdata      (final_wb_drdata),
        .imm         (final_wb_imm),
        .auipc       (final_wb_auipc),
        .pc_plus_4   (final_wb_pc_plus_4),
        .wb_wdata    (wb_wdata)
    );

endmodule
# RV32I 5-Stage Pipeline SoC

An FPGA-oriented RV32I system that evolves from a baseline CPU into a five-stage pipeline with forwarding, load-use interlocking, APB memory-mapped peripherals, Machine-mode CSR, and external-interrupt control.

**Target:** Digilent Basys3 · Xilinx Artix-7 `xc7a35tcpg236-1` · Vivado 2026.1

## Results

| Routed implementation metric | Result |
| --- | ---: |
| Clock constraint | 100 MHz / 10 ns |
| Setup WNS | **+0.623 ns** |
| Setup TNS | **0.000 ns** |
| Setup endpoints | **0 failing / 9017 total** |
| LUTs / FFs | 2917 / 1990 |
| Estimated on-chip power | 0.114 W |

[Implementation report summary](docs/IMPLEMENTATION_RESULTS.md) · [Timing report](reports/rv32I_fpga_top_timing_summary_routed.rpt) · [Utilization report](reports/rv32I_fpga_top_utilization_placed.rpt) · [Power report](reports/rv32I_fpga_top_power_routed.rpt)

## Architecture

```text
rv32I_fpga_top
├── 100 MHz Basys3 clock and button debounce
├── rv32I_top
│   ├── RV32I five-stage CPU
│   │   ├── IF → ID → EX → MEM → WB
│   │   ├── forwarding unit
│   │   ├── load-use hazard detector
│   │   ├── pipeline / trap controller
│   │   └── Machine-mode CSR register file
│   ├── instruction and data memories
│   └── APB GPIO / UART / FND peripherals
└── GPIO LEDs, seven-segment display, USB-UART
```

See [architecture details](docs/ARCHITECTURE.md).

## Repository layout

```text
.
├── rtl/              # synthesizable SystemVerilog RTL
├── tb/               # CSR/interrupt and APB/MMIO self-checking testbenches
├── firmware/         # assembly/C sources, ROM image, ROM-image generator
├── constraints/      # Basys3 XDC
├── sim/              # file list and simulator Makefile
├── reports/          # Vivado routed timing, utilization, and power reports
└── docs/             # architecture, results, and reproduction notes
```

## Review in five minutes

| Review topic | Start here |
| --- | --- |
| FPGA top and button interrupt path | [`rtl/rv32I_fpga_top.sv`](rtl/rv32I_fpga_top.sv) |
| CPU / APB system integration | [`rtl/rv32I_top.sv`](rtl/rv32I_top.sv) |
| Pipeline datapath | [`rtl/rv32i_datapath.sv`](rtl/rv32i_datapath.sv) |
| Forwarding and load-use interlock | [`rtl/forwarding_unit.sv`](rtl/forwarding_unit.sv) · [`rtl/hazard_detection_unit.sv`](rtl/hazard_detection_unit.sv) |
| Trap, flush, and stall policy | [`rtl/pipeline_controller.sv`](rtl/pipeline_controller.sv) |
| Machine-mode CSR and external pending state | [`rtl/csr_regfile.sv`](rtl/csr_regfile.sv) |
| CSR / interrupt testbench | [`tb/tb_rv32i_csr_interrupt.sv`](tb/tb_rv32i_csr_interrupt.sv) |
| APB peripheral testbench | [`tb/tb_rv32i_apb_mmio.sv`](tb/tb_rv32i_apb_mmio.sv) |
| Bare-metal interrupt program | [`firmware/src/firmware.s`](firmware/src/firmware.s) |
| Basys3 constraints | [`constraints/basys3.xdc`](constraints/basys3.xdc) |

## Run simulation

From this project directory:

```bash
make -f sim/Makefile firmware
make -f sim/Makefile csr_interrupt
make -f sim/Makefile apb_mmio
```

The CSR testbench exercises `mtvec` setup, external interrupt injection, trap entry, handler execution, `mret`, and main-loop resumption. The APB/MMIO testbench exercises RAM, GPIO, FND, and UART register transactions.

Full setup instructions: [docs/REPRODUCING.md](docs/REPRODUCING.md).

## Project evolution

```text
Baseline RV32I
  → pipeline hazard detection + forwarding
  → APB MMIO + pipeline stall handling
  → Machine-mode CSR + external interrupt
  → Basys3 FPGA wrapper + routed implementation
```

## Skills demonstrated

RTL microarchitecture · pipeline control · forwarding · hazard handling · APB integration · memory-mapped peripherals · CSR/interrupt control · firmware-aware verification · FPGA implementation analysis

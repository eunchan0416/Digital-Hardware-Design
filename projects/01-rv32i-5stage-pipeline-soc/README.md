# RV32I 5-Stage Pipeline SoC

An FPGA-oriented RV32I SoC that evolves from a baseline CPU into a five-stage pipeline with data-hazard handling, APB memory-mapped I/O, Machine-mode CSR support, and an external interrupt path.

## Highlights

- **5-stage pipeline:** IF, ID, EX, MEM, and WB stages with explicit pipeline registers
- **Data hazards:** EX/MEM and MEM/WB forwarding plus a load-use interlock
- **Control hazards:** branch/jump redirect and pipeline flush control
- **SoC integration:** APB master with GPIO, UART, and four-digit seven-segment display peripherals
- **Machine-mode control:** CSR file, trap redirect, external interrupt input, and `mret` return
- **FPGA top:** Basys3-facing wrapper with a debounced center-button interrupt input
- **Implementation result:** Vivado 2026.1 routed result at a 100 MHz internal constraint — WNS **+0.623 ns**, TNS **0.000 ns**, and **0 setup failing endpoints**

## Architecture

```text
rv32I_fpga_top
├── button debounce → external interrupt
├── rv32I_top
│   ├── rv32i_cpu
│   │   ├── 5-stage datapath
│   │   ├── forwarding unit
│   │   ├── hazard detection unit
│   │   ├── pipeline controller
│   │   └── CSR register file
│   └── APB subsystem
│       ├── GPIO
│       ├── UART
│       └── FND controller
└── instruction / data memories
```

## Start here

| What to inspect | File |
| --- | --- |
| FPGA wrapper and interrupt-button path | [`rtl/rv32I_fpga_top.sv`](rtl/rv32I_fpga_top.sv) |
| SoC-level CPU/APB integration | [`rtl/rv32I_top.sv`](rtl/rv32I_top.sv) |
| Pipeline datapath and stage registers | [`rtl/rv32i_datapath.sv`](rtl/rv32i_datapath.sv) |
| Data forwarding | [`rtl/forwarding_unit.sv`](rtl/forwarding_unit.sv) |
| Load-use hazard interlock | [`rtl/hazard_detection_unit.sv`](rtl/hazard_detection_unit.sv) |
| Pipeline stall, flush, and trap control | [`rtl/pipeline_controller.sv`](rtl/pipeline_controller.sv) |
| Machine-mode CSR state | [`rtl/csr_regfile.sv`](rtl/csr_regfile.sv) |
| APB transaction and address-decode logic | [`rtl/APB_MASTER.sv`](rtl/APB_MASTER.sv) |

## Implementation note

The reported routed implementation uses `rv32I_fpga_top` as the top-level design under a 100 MHz internal clock constraint. The source snapshot is provided for design review; matching testbench, firmware image, XDC, and automation files will be added as a reproducible release bundle.

## Project evolution

```text
Baseline RV32I
  → hazard detection + forwarding
  → APB peripherals and pipeline stall handling
  → Machine-mode CSR + external interrupt
  → Basys3-facing FPGA wrapper and routed implementation
```

## Skills demonstrated

RTL microarchitecture · pipeline control · hazard resolution · memory-mapped peripheral integration · CSR/interrupt control · FPGA implementation analysis

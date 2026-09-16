# Digital Hardware Design & Verification Portfolio

Portfolio of synthesizable RTL, SoC integration, bare-metal firmware, and SystemVerilog/UVM verification work. Each project states its scope, implementation entry points, verification evidence, and the limits of that evidence.

## Featured work

| Project | Focus | Evidence available | Start here |
| --- | --- | --- | --- |
| **RV32I APB SoC** | RV32I CPU, APB MMIO, UART/GPIO/FND, firmware | RTL, system testbench, firmware images, Basys3 constraints | [project brief](RV32I_APB_Custom_SoC/README.md) |
| **UART with UVM** | UART RTL and transaction-level checking | VCS/UVM 1.2 run log: 10 RX + 10 TX transactions, 0 UVM errors | [project brief](02_Serial_IPs_with_UVM/README.md) |

## What a reviewer can inspect quickly

1. **Architecture and interfaces** — top modules, memory map, protocol-facing RTL, and diagrams live with each project.
2. **Verification intent and evidence** — tests, scoreboards, and retained run artifacts are linked directly rather than summarized as untraceable claims.
3. **Reproducibility boundary** — tool-dependent work identifies the source files and target; an omitted script, report, or hardware capture is called out as a limitation rather than implied as completed work.

## Repository map

```text
Digital-Hardware-Design/
├── RV32I_APB_Custom_SoC/        # Featured RTL/SoC/firmware project
│   ├── rtl/                     # CPU, APB master/slaves, memories, TB, XDC
│   ├── sw/                      # Bare-metal C source and ROM images
│   └── docs/                    # Architecture, FSM, memory-map references
├── 02_Serial_IPs_with_UVM/      # UART RTL + UVM environment; SPI is WIP
│   ├── rtl/
│   ├── verif/
│   ├── sim/
│   └── docs/
└── docs/                        # Cross-project evidence and release policy
```

## Verification-status convention

| Label | Meaning |
| --- | --- |
| **Implemented** | Synthesizable RTL or source is present in this repository. |
| **Simulation evidence retained** | A testbench and/or recorded simulator result is present. |
| **Implementation target defined** | FPGA device or constraints are included; this does not by itself prove board execution. |
| **Planned / WIP** | Intended extension, not a completed capability. |

This convention separates code presence, simulation, FPGA implementation, and physical-board demonstration. See the [evidence register](docs/PORTFOLIO_EVIDENCE.md) before reusing a claim in a resume or application.

## Tools and languages

- Verilog / SystemVerilog, UVM 1.2, C (bare-metal)
- Vivado-oriented RTL and Digilent Basys3 constraints
- Synopsys VCS/Verdi-oriented UVM simulation flow

## Notes for recruiters and collaborators

- The primary artifact is the RV32I APB SoC, not a collection of unrelated source files.
- SPI and I2C entries are intentionally marked as WIP; the verified serial artifact currently documented here is UART.
- The UART is a standalone IP. An APB or AXI4-Lite wrapper is a roadmap item, not a present capability.

## License and reuse

No license is currently declared. Do not assume permission to reuse this code outside review or evaluation until a license is added.

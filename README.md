# Digital Hardware Design & Verification Portfolio

Portfolio of synthesizable RTL, SoC integration, bare-metal firmware, and SystemVerilog/UVM verification work. Each project separates implementation, retained evidence, and known limits.

## Featured work

| Project | Focus | Evidence available | Start here |
| --- | --- | --- | --- |
| **RV32I 5-Stage Pipeline SoC** | Pipeline hazards, APB MMIO, CSR and external interrupt control | Final RTL snapshot; routed 100 MHz internal setup report; test and co-simulation collateral | [project brief](projects/01-rv32i-5stage-pipeline-soc/README.md) |
| **RV32I APB SoC (legacy snapshot)** | Earlier CPU/APB/firmware integration baseline | RTL, system testbench, firmware images, Basys3 constraints | [project brief](RV32I_APB_Custom_SoC/README.md) |
| **UART with UVM** | UART RTL and transaction-level checking | VCS/UVM 1.2 run log: 10 RX + 10 TX transactions, 0 UVM errors | [project brief](02_Serial_IPs_with_UVM/README.md) |

## Reading order

1. Start with the [RV32I 5-Stage Pipeline SoC](projects/01-rv32i-5stage-pipeline-soc/README.md), the primary architecture/implementation case study.
2. Use the [evidence register](docs/PORTFOLIO_EVIDENCE.md) before interpreting a verification, timing, or board claim.
3. Treat the earlier APB SoC as a historical baseline, not the latest version of the pipeline project.

## Verification-status convention

| Label | Meaning |
| --- | --- |
| **Implemented** | Synthesizable RTL or source is retained. |
| **Simulation evidence retained** | A testbench and/or recorded simulator result is retained. |
| **Routed implementation evidence retained** | A named implementation report is retained for a stated top, constraint, and tool context. |
| **Board demonstration retained** | A build identifier plus observable board result is retained. |
| **Planned / WIP** | Intended extension, not a completed capability. |

A positive WNS does not by itself prove CDC closure, I/O timing sign-off, or physical-board operation.

## Repository map

```text
Digital-Hardware-Design/
├── projects/
│   └── 01-rv32i-5stage-pipeline-soc/  # Primary case study and evidence scope
├── RV32I_APB_Custom_SoC/               # Earlier APB baseline
├── 02_Serial_IPs_with_UVM/             # UART RTL + UVM environment
└── docs/                                # Cross-project evidence/release guidance
```

## Tools and languages

- Verilog / SystemVerilog, UVM 1.2, C (bare-metal)
- Vivado-oriented RTL and Digilent Basys3 target conventions
- Synopsys VCS/Verdi-oriented UVM simulation flow

## License and reuse

No license is currently declared. Do not assume permission to reuse this code outside review or evaluation until a license is added.

# RV32I Pipeline SoC — Evidence Summary

| Area | Artifact |
| --- | --- |
| RTL implementation | Five-stage pipeline, hazard/forwarding units, APB subsystem, CSR file, interrupt wrapper |
| FPGA top | `rv32I_fpga_top` for the Basys3-oriented I/O wrapper |
| Routed implementation | Vivado 2026.1, 100 MHz internal constraint, setup WNS +0.623 ns, TNS 0.000 ns, 0 setup failing endpoints |
| Project progression | Baseline → hazard/forwarding → APB stall handling → CSR/external interrupt → FPGA wrapper |

For code review, start at [the project README](../projects/01-rv32i-5stage-pipeline-soc/README.md).

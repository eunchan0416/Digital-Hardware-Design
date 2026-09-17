# Digital Hardware Design & Verification Portfolio

A portfolio of RTL design, SoC integration, firmware-aware hardware development, and SystemVerilog/UVM verification.

## Featured projects

| Project | Focus | Quick review |
| --- | --- | --- |
| **RV32I 5-Stage Pipeline SoC** | Pipeline hazards, APB MMIO, CSR, external interrupt, FPGA implementation | [README](projects/01-rv32i-5stage-pipeline-soc/README.md) · [RTL](projects/01-rv32i-5stage-pipeline-soc/rtl/) |
| **RV32I APB SoC** | Earlier CPU/APB/firmware integration baseline | [README](RV32I_APB_Custom_SoC/README.md) |
| **UART with UVM** | UART RTL and a UVM transaction-level environment | [README](02_Serial_IPs_with_UVM/README.md) |

## Repository map

```text
Digital-Hardware-Design/
├── projects/
│   └── 01-rv32i-5stage-pipeline-soc/
│       ├── rtl/                 # primary RTL snapshot
│       └── README.md            # architecture and implementation notes
├── RV32I_APB_Custom_SoC/        # earlier APB baseline
├── 02_Serial_IPs_with_UVM/      # UART RTL + UVM
└── docs/
```

## Tools

Verilog · SystemVerilog · UVM · C · Vivado · VCS/Verdi · Digilent Basys3

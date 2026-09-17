# Architecture

## Five-stage pipeline

```text
IF → ID → EX → MEM → WB
     │    │    │      └─ register-file writeback
     │    │    └──────── APB / data-memory access
     │    └───────────── ALU, branch, CSR operations
     └────────────────── decode and hazard detection
```

The forwarding unit selects EX/MEM or MEM/WB results for dependent EX-stage operands. The hazard detector inserts an interlock for the load-use case. The pipeline controller centralizes stall, flush, branch/jump, and trap control.

## System integration

```text
rv32I_fpga_top
├── button debounce → external interrupt
├── rv32I_top
│   ├── RV32I CPU
│   ├── instruction/data memories
│   └── APB peripherals: GPIO, UART, FND
└── Basys3 I/O
```

Firmware configures `mtvec`, `mie.MEIE`, and `mstatus.MIE`; trap control redirects the PC to the handler, and `mret` resumes execution from `mepc`.

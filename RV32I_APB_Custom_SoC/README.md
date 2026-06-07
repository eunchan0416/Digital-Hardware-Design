# RV32I Multi-cycle Core with AMBA 3 APB Bus SoC

## 1. Overview
This repository provides the RTL design and HW/SW co-simulation environment for a custom 32-bit RISC-V (RV32I) multi-cycle processor. The core is integrated with an AMBA 3 APB bus interconnect to communicate with memory-mapped peripherals.

## 2. Directory Structure
* `rtl/` : Synthesizable SystemVerilog/Verilog source codes (Core, Bus, Peripherals, Memory) and testbench.
* `sw/` : Bare-metal C source codes and compiled firmware binaries (`.mem`).
* `docs/` : System architecture diagrams, FSM charts, and verification waveforms.

## 3. System Architecture
* **Core:** 5-stage multi-cycle execution unit. Instruction latching is implemented at the Fetch stage to optimize the critical path.
* **Bus:** AMBA 3 APB protocol (1 Master, Multiple Slaves).
* **Peripherals:** UART (Configurable baud rate), GPIO, 7-Segment Controller, BRAM.

```mermaid
graph LR
    subgraph CPU["RV32I Core"]
        PC[Program Counter]
        ALU[ALU]
    end

    subgraph Interconnect["APB Bus Interconnect"]
        Master[APB Master]
        Bridge[APB Bridge]
        Master --> Bridge
    end

    subgraph Peripherals["Peripheral Blocks"]
        BRAM[BRAM 8KB]
        GPO[GPO]
        GPI[GPI]
        GPIO[GPIO]
        FND[FND Controller]
        UART[UART Controller]
    end

    CPU -- Address/Data --> Interconnect
    Bridge -- APB Protocol --> BRAM
    Bridge -- APB Protocol --> GPO
    Bridge -- APB Protocol --> GPI
    Bridge -- APB Protocol --> GPIO
    Bridge -- APB Protocol --> FND
    Bridge -- APB Protocol --> UART

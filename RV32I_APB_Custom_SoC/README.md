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

![System Block Diagram](./docs/soc_block_diagram.png)

## 4. System Memory Map
The APB master address decoder allocates 4KB address spaces for each memory-mapped IP (`addr[31:28]` for main memory, `addr[15:12]` for APB slaves).

| Peripheral | Base Address | Size | Access | Description |
| :--- | :--- | :--- | :--- | :--- |
| RAM | 0x1000_0000 | 4KB | R/W | Instruction and Data Memory |
| APB_GPO | 0x2000_0000 | 4KB | W | General Purpose Output |
| APB_GPI | 0x2000_1000 | 4KB | R | General Purpose Input |
| APB_GPIO | 0x2000_2000 | 4KB | R/W | Bidirectional I/O |
| APB_FND | 0x2000_3000 | 4KB | W | 7-Segment Display Controller |
| APB_UART | 0x2000_4000 | 4KB | R/W | UART TX/RX Data & Status/Control |

## 5. FPGA Implementation (Baseline)
* **Target Device:** Xilinx Artix-7 (xc7a35tcpg236-1) / Digilent Basys3

| Resource | Utilization | Available | Utilization % |
| :--- | :--- | :--- | :--- |
| LUT | [Fill_Here] | 20,800 | - % |
| FF | [Fill_Here] | 41,600 | - % |
| BRAM | [Fill_Here] | 50 | - % |

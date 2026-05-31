# Digital Hardware Design & Verification

This repository maintains source codes for digital logic design (RTL), System-on-Chip (SoC) integration verification, and UVM-based verification environments.

## Projects

Detailed architectural specifications and verification results can be found in the README of each directory.

### 1. [RV32I_APB_Custom_SoC](./RV32I_APB_Custom_SoC)
* **Keywords:** `SystemVerilog`, `RISC-V`, `AMBA 3 APB`, `HW/SW Co-simulation`
* **Description:** Custom SoC design based on a 32-bit RISC-V (RV32I) multi-cycle core and AMBA 3 APB bus interconnect. Includes integration of memory-mapped peripherals (UART, GPIO, etc.) and hardware behavior verification in a bare-metal C firmware environment.

### 2. [02_Serial_IPs_with_UVM](./02_Serial_IPs_with_UVM) *(In Progress)*
* **Keywords:** `SystemVerilog`, `UVM`, `Verification`, `VCS/Verdi`
* **Description:** Implementation of a Universal Verification Methodology (UVM) based testbench architecture (Agent, Scoreboard, Sequence) and coverage closure project for serial communication IP verification.

## Tech Stack
* **Languages/Methodology:** Verilog, SystemVerilog, UVM, C (Bare-metal)
* **EDA Tools:** Xilinx Vivado, Synopsys VCS / Verdi
* **Target Device:** Xilinx Artix-7 (Digilent Basys 3)

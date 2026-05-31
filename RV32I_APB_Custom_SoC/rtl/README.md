
# Hardware Design (RTL)

This directory contains the synthesizable SystemVerilog/Verilog source codes, physical constraints, and the system-level testbench for the RV32I APB Custom SoC.

## 1. Directory Structure

The design files are strictly categorized by their intellectual property (IP) domain to ensure modularity and reusability.

* `src/` : RTL source files.
  * `top/` : Top-level SoC wrapper (`rv32i_mcu.sv`).
  * `core_ip/` : RV32I 5-stage multi-cycle datapath components (ALU, PC, Register File) and Control Unit.
  * `bus_ip/` : AMBA 3 APB interconnect, multiplexer, and address decoder.
  * `peripheral_ip/` : Memory-mapped slave IPs including UART, GPIO, FND, and BRAM.
* `tb/` : System-level testbench (`tb_soc.sv`) designed for HW/SW co-simulation.
* `constraints/` : Physical pin mapping and clock constraints (`Basys3.xdc`) for Xilinx Artix-7 FPGA targeting.

## 2. Module Hierarchy (Top-Down)

The SoC is constructed using a top-down design methodology. The `rv32i_mcu` module integrates the CPU core, bus interconnect, and peripherals.

```text
rv32i_mcu (Top)
 ├── rv32i_core (Master)
 │    ├── Control_unit
 │    ├── ALU & ALU_control
 │    ├── Register_file
 │    └── Datapath Components (PC, MUX, Imm_Gen)
 │
 ├── APB_Bus_Interconnect
 │    ├── addr_decoder
 │    └── APB_MUX
 │
 └── Peripherals (Slaves)
      ├── APB_BRAM (Instruction & Data Memory)
      ├── APB_GPIO
      ├── APB_FND
      └── APB_UART (w/ Baud Rate Generator)

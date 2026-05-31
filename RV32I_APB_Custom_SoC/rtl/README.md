# Hardware Design (RTL)

This directory contains the synthesizable SystemVerilog/Verilog source codes, physical constraints, and the system-level testbench for the RV32I APB Custom SoC.

## 1. Directory Structure

The design files are directly categorized by their intellectual property (IP) domain to ensure modularity and reusability.

* `core/` : RV32I 5-stage multi-cycle datapath components, Control Unit, and the Top-level SoC wrapper (`rv32i_mcu.sv`).
* `bus_ip/` : AMBA 3 APB interconnect (Master) and Memory-mapped slave peripherals (`APB_UART.sv`, `APB_GPIO.sv`, `APB_FND.sv`, etc.).
* `memory/` : Data/Instruction memory modules and APB BRAM wrapper (`APB_SLAVE_RAM.sv`).
* `tb/` : System-level testbench (`tb_rv32i.sv`) designed for HW/SW co-simulation.
* `Basys-3-Master.xdc` : Physical pin mapping and clock constraints for Xilinx Artix-7 (Digilent Basys 3).

## 2. Module Hierarchy (Top-Down)

The SoC is constructed using a top-down design methodology. The `rv32i_mcu` module integrates the CPU core, bus interconnect, and memory-mapped peripherals.

```text
rv32i_mcu.sv (Top)
 ├── rv32i_cpu.sv (Core)
 │    ├── control_unit.sv
 │    └── rv32i_datapath.sv (PC, ALU, Register File, imm_extender.sv)
 │
 ├── APB_MASTER.sv (Bus Interconnect & Address Decoder)
 │
 └── Peripherals & Memory (APB Slaves)
      ├── APB_SLAVE_RAM.sv (in memory/)
      ├── APB_GPIO.sv      (in bus_ip/)
      ├── APB_FND.sv       (in bus_ip/)
      └── APB_UART.sv      (in bus_ip/)

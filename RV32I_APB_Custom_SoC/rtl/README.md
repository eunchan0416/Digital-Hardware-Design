# Hardware Design (RTL)

SystemVerilog/Verilog source codes, physical constraints, and system-level testbench for the RV32I APB Custom SoC.

## 1. Directory Structure

* `core/` : RV32I 5-stage multi-cycle datapath, Control Unit, and Top-level SoC wrapper (`rv32i_mcu.sv`).
* `bus_ip/` : AMBA 3 APB Master interconnect and slave peripherals (`APB_UART.sv`, `APB_GPIO.sv`, `APB_FND.sv`, etc.).
* `memory/` : Data/Instruction memory modules and APB BRAM wrapper (`APB_SLAVE_RAM.sv`).
* `tb/` : System-level testbench (`tb_rv32i.sv`) for HW/SW co-simulation.
* `Basys-3-Master.xdc` : Physical constraints for Xilinx Artix-7.

## 2. Module Hierarchy

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

# Firmware & Test Binaries

Bare-metal C source codes and machine code binaries (`.mem`) for hardware verification of the RV32I-based SoC.

## 1. Directory Structure

* `src/` : Original C source codes for MMIO (Memory-Mapped I/O) control of peripherals (UART, GPIO, etc.).
* `*.mem` : Binary data loaded into the `instruction_mem` during Vivado simulation.

## 2. Build & Simulation Flow

1. **Compilation:** C codes are compiled and optimized (`-O1`) into Assembly using the RISC-V GCC toolchain (`rv32i` target).
2. **Hex Generation:** The assembly is extracted into hexadecimal (`.mem`) format.
3. **Simulation:** The binaries are loaded into the ROM via the `$readmemh` task in the top-level testbench (`tb_rv32i.sv`) for HW/SW co-simulation.

## 3. Test Cases

* **UART Tests (`APB_UART_*.mem`)**
  * Verifies baud rate clock divider configurations.
  * Validates serial data transmission and reception via TX/RX buffers.
* **GPIO Tests (`APB_GPIO_LED.mem`, `APB_GPO_GPI.mem`)**
  * Verifies port direction control (input/output) and data read/write operations.
* **FND Test (`APB_FND.mem`)**
  * Validates 7-Segment display register control logic.
* **System Tests (`riscv_rv32i_rom_data.mem`, `APB_INIT.mem`)**
  * Verifies the RV32I base instruction set execution and system initialization sequence.

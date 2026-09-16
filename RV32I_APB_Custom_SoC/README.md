# RV32I APB SoC

**Focus:** CPU/SoC RTL integration, memory-mapped peripheral design, and bare-metal firmware-driven verification.

This project integrates an RV32I processor with an AMBA 3 APB subsystem and memory-mapped UART, GPIO, FND, and BRAM peripherals. It is the featured design artifact because the CPU, bus, peripherals, firmware images, and system testbench can be inspected as one system.

> **Status:** RTL, firmware images, system testbench, and Basys3 constraints are versioned. This repository does not currently retain a reproducible implementation report or board-run capture, so it does not claim timing closure or physical-board validation.

## Review in five minutes

| Question | Entry point |
| --- | --- |
| What is the SoC top-level hierarchy? | [`rtl/README.md`](rtl/README.md) and [`rtl/core/rv32i_mcu.sv`](rtl/core/rv32i_mcu.sv) |
| How are peripherals addressed? | [memory map](#memory-map) and [`rtl/bus_ip/APB_MASTER.sv`](rtl/bus_ip/APB_MASTER.sv) |
| How is firmware exercised? | [`rtl/tb/tb_rv32i.sv`](rtl/tb/tb_rv32i.sv) and [`sw/README.md`](sw/README.md) |
| Which FPGA is targeted? | [`rtl/Basys-3-Master.xdc`](rtl/Basys-3-Master.xdc) |

## Architecture

```text
rv32i_mcu
├── RV32I CPU and datapath
├── APB master / address decode
├── APB BRAM
├── APB GPIO and GPO/GPI
├── APB FND controller
└── APB UART
```

The system-level testbench drives clock, reset, GPIO switches, and UART pins; the instruction memory loads a selected `.mem` image generated from the firmware flow. This lets the same project be reviewed through both RTL and the software-visible register interface.

## Memory map

| Peripheral | Base address | Size | Access |
| --- | ---: | ---: | --- |
| RAM | `0x1000_0000` | 4 KB | R/W |
| APB GPO | `0x2000_0000` | 4 KB | W |
| APB GPI | `0x2000_1000` | 4 KB | R |
| APB GPIO | `0x2000_2000` | 4 KB | R/W |
| APB FND | `0x2000_3000` | 4 KB | W |
| APB UART | `0x2000_4000` | 4 KB | R/W |

![SoC block diagram](docs/soc_block_diagram.png)

## Source layout

```text
rtl/
├── core/       # CPU, control, datapath, top-level MCU
├── bus_ip/     # APB master and memory-mapped peripherals
├── memory/     # Instruction/data memory and APB RAM
├── tb/          # System-level HW/SW co-simulation testbench
└── Basys-3-Master.xdc
sw/
├── src/        # Bare-metal C source
└── *.mem        # Firmware images loaded by instruction memory
docs/            # Architecture/FSM/waveform reference material
```

## Verification boundary

- **Source inspection:** the project contains a top-level testbench and firmware images for APB UART, GPIO, FND, memory, and initialization paths.
- **Target definition:** the checked-in XDC targets the Digilent Basys3 Artix-7 board.
- **Not represented as complete:** board bring-up, post-route timing, utilization, power, and instruction-compliance coverage. These require a dated build artifact or observable board result before being claimed.

## Reproduction notes

The included sources are Vivado/SystemVerilog-oriented. Before running, select the firmware image to be loaded by the instruction-memory configuration and compile the RTL files with their include paths. The project currently does not provide a checked-in Tcl project script or a simulator command line; adding those is the next reproducibility improvement.

## Next engineering steps

1. Add a scripted simulation command and self-checking end criteria for each firmware image.
2. Version a sanitized Vivado implementation report for one named FPGA top and constraint set.
3. Add a board evidence bundle: build ID, UART capture or display photo, and a short bring-up checklist.

See the repository-wide [evidence register](../docs/PORTFOLIO_EVIDENCE.md) for wording suitable for applications and interviews.

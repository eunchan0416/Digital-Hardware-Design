# Portfolio Evidence Register

This register is the source of truth for claims made in repository READMEs, resumes, and interviews. It distinguishes source inspection from a completed simulation, FPGA implementation, or board demonstration.

## RV32I APB SoC

| Claim | Evidence in this repository | Allowed wording | Do not claim yet |
| --- | --- | --- | --- |
| RV32I CPU integrated with APB MMIO | `rtl/core/`, `rtl/bus_ip/`, memory map and top-level hierarchy | “Implemented an RV32I/APB SoC with UART, GPIO, FND, and BRAM peripherals.” | ISA compliance beyond the tested programs |
| Hardware/software co-simulation setup | `rtl/tb/tb_rv32i.sv`, `sw/*.mem`, `sw/src/gpio_main.c` | “Included a system-level testbench that loads bare-metal firmware images.” | Full regression pass unless a run artifact is added |
| Basys3 target | `rtl/Basys-3-Master.xdc` | “Prepared a Basys3 constraint target.” | Successful board bring-up or timing closure |
| Timing, power, or utilization | No matching implementation report is versioned here | — | Any WNS, power, or resource number |

## UART with UVM

| Claim | Evidence in this repository | Allowed wording | Do not claim yet |
| --- | --- | --- | --- |
| UART implementation | `rtl/uart/` | “Implemented a parameterized 8-N-1 UART with 16× RX oversampling.” | Protocol features not present in the RTL |
| UVM architecture | `verif/uart_env/` | “Built a UVM 1.2 environment with sequencer, driver, monitor, and scoreboard.” | Coverage closure |
| Recorded UVM execution | `sim/uart/sim_result.log` | “A retained VCS log shows 10 RX and 10 TX randomized transactions with 0 reported UVM errors.” | Exhaustive verification or 100% functional coverage |
| APB / AXI4-Lite serial wrapper | UART README identifies it as future work | “Planned MMIO-wrapper extension.” | “AXI4-Lite UART implemented” |

## Evidence maintenance rules

1. Add a claim only when the corresponding source, command, and generated artifact can be reviewed together.
2. Version tool reports and logs by commit or build configuration. Remove machine-specific paths and proprietary content before publication.
3. Label board evidence with board, FPGA part, clock constraint, top module, bitstream/build identifier, and a photo, UART capture, or other observable output.
4. Treat a design plan, an XDC file, or an architecture diagram as intent—not proof of execution.

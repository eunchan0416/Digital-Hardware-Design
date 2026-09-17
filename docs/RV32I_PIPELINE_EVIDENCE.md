## RV32I 5-Stage Pipeline SoC

| Claim | Retained evidence | Allowed wording | Do not claim yet |
| --- | --- | --- | --- |
| Five-stage RV32I pipeline with hazards handled | Final RTL snapshot includes pipeline registers, forwarding unit, hazard detector, controller, and datapath | “Implemented/reviewed a five-stage RV32I pipeline with forwarding and a load-use interlock.” | Full ISA compliance |
| APB-based peripheral integration | System top plus APB master, GPIO, FND, and UART RTL | “Integrated APB memory-mapped peripherals into the SoC.” | Every APB corner case is verified |
| CSR + external interrupt integration | CSR file, pipeline controller, FPGA wrapper, debounce RTL | “Integrated Machine-mode CSR and a debounced external-interrupt path.” | Robust interrupt delivery under all overlaps until regression evidence is published |
| 100 MHz routed implementation | Vivado 2026.1 timing summary for `rv32I_fpga_top`: WNS +0.623 ns, TNS 0, 0 setup failures | “Met the reported 100 MHz internal setup constraint.” | Full timing sign-off or a guaranteed maximum frequency |
| Basys3 mapping | FPGA wrapper naming and board-port mapping | “Prepared a Basys3-facing top level.” | Board demonstration, without a versioned capture/bitstream |
| Spike co-simulation | Automation/test collateral in project records | “Prepared a Spike comparison flow.” | A passing differential-test result, without the captured run output |

**Known implementation limitations:** the retained routed report contains 47 missing I/O-delay warnings; UART RX CDC, reset deassertion, and one-cycle interrupt-event retention remain explicit follow-up verification items.

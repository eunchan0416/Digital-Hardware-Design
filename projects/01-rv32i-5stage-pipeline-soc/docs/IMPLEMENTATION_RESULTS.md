# FPGA Implementation Results

Target: **Digilent Basys3** / **xc7a35tcpg236-1**  
Top: `rv32I_fpga_top` · Tool: **Vivado 2026.1** · State: **Routed**

| Metric | Result |
| --- | ---: |
| Clock constraint | 100.000 MHz / 10.000 ns |
| Setup WNS / TNS | +0.623 ns / 0.000 ns |
| Setup endpoints | 0 failing / 9017 total |
| Hold worst slack | +0.023 ns |
| LUTs | 2917 / 20800 (14.02%) |
| LUTRAM | 512 / 9600 (5.33%) |
| Registers | 1990 / 41600 (4.78%) |
| I/O | 33 / 106 (31.13%) |
| BUFG | 1 / 32 (3.13%) |
| Estimated on-chip power | 0.114 W |

Original generated artifacts:

- [Routed timing summary](../reports/rv32I_fpga_top_timing_summary_routed.rpt)
- [Placed utilization report](../reports/rv32I_fpga_top_utilization_placed.rpt)
- [Routed power report](../reports/rv32I_fpga_top_power_routed.rpt)

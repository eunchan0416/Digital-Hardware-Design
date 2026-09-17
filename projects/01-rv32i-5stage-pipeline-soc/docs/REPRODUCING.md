# Reproducing

## Simulation

Requirements: Python 3 and a SystemVerilog-capable simulator. The included Makefile defaults to Icarus Verilog.

```bash
make -C sim firmware
make -C sim csr_interrupt
make -C sim apb_mmio
```

The CSR/interrupt test checks trap entry, `mtvec`, handler execution, `mret`, and resumed main-loop execution. The APB/MMIO test checks RAM access plus GPIO, FND, and UART register transactions.

## FPGA build

1. Create a Vivado project for `xc7a35tcpg236-1`.
2. Add the RTL listed in `sim/filelist.f`; use `rtl/rv32I_fpga_top.sv` as top.
3. Add `constraints/basys3.xdc`.
4. Run `python3 firmware/build_mem.py` and provide the generated `test.mem` to instruction-memory initialization.
5. Run synthesis and implementation with the 10 ns clock constraint.

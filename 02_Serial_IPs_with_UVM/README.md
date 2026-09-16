# Serial IP Verification: UART with UVM

**Focus:** RTL-to-testbench verification structure for a standalone UART IP.

The reviewed, evidence-backed artifact in this directory is the UART: a synthesizable 8-N-1 RTL implementation with a UVM 1.2 environment. SPI source is present as work in progress; I2C is not presented as implemented.

> **Status:** UART RTL and UVM environment are versioned. A retained VCS log records one UVM execution with 10 randomized RX and 10 randomized TX transactions and zero reported UVM errors. Functional coverage closure, assertions, and a memory-mapped APB/AXI4-Lite wrapper are not yet included.

## Review in five minutes

| Question | Entry point |
| --- | --- |
| What is the UART interface and framing? | [`docs/uart/README.md`](docs/uart/README.md) |
| What is the DUT RTL? | [`rtl/uart/`](rtl/uart/) |
| What is the UVM component structure? | [`verif/uart_env/`](verif/uart_env/) |
| What result is retained? | [`sim/uart/sim_result.log`](sim/uart/sim_result.log) |

## UART scope

| Item | Implemented scope |
| --- | --- |
| Frame | 8 data bits, no parity, one stop bit (8-N-1) |
| RX | 16× oversampling receiver |
| TX / RX control | Separate FSMs |
| Verification | UVM sequence, driver, monitor, agent, environment, scoreboard, and test |
| Bus integration | Not implemented — APB / AXI4-Lite wrapper is future work |

## Verification architecture

```text
uart_base_test
└── uart_env
    ├── uart_agent
    │   ├── sequencer
    │   ├── driver
    │   └── monitor
    └── uart_scoreboard
```

The monitor publishes expected and observed UART traffic to the scoreboard, which compares the transactions. The retained VCS/UVM 1.2 log records ten RX and ten TX randomized transactions, each reported as a scoreboard pass; the final report contains `UVM_ERROR: 0` and `UVM_FATAL: 0`. This is a single saved run, not a coverage-closure statement.

![UVM architecture](docs/images/uvm_base_architecture.jpg)

## Directory map

```text
rtl/uart/        # baud tick, TX, RX, top
verif/uart_env/  # UVM testbench components
sim/uart/        # Makefile and retained VCS result log
docs/uart/       # UART interface/FSM/waveform documentation
rtl/spi/         # Work-in-progress source; no verification claim
```

## Reproduction boundary

`sim/uart/Makefile` and the saved VCS output document the existing flow. A fresh run requires a SystemVerilog simulator and UVM 1.2 installation. The repository does not currently include coverage databases, a CI runner, or an open-source simulator-compatible script; do not infer those results.

## Next engineering steps

1. Correct and complete the UART simulation README/file list, then add a one-command regression entry point.
2. Add SVA for framing, baud-tick, reset, and RX sampling invariants.
3. Add covergroups and publish a dated coverage summary.
4. Wrap the UART with one selected MMIO protocol (APB or AXI4-Lite), document the register map, and verify register transactions separately from serial behavior.

See the repository-wide [evidence register](../docs/PORTFOLIO_EVIDENCE.md) for wording suitable for applications and interviews.

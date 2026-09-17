# RV32I 5-Stage Pipeline SoC

A reviewable FPGA-oriented RV32I system that evolves a baseline core into a 5-stage pipeline with data-hazard handling, APB memory-mapped I/O, Machine-mode CSRs, and one external interrupt source.

> **Portfolio status:** architecture and final RTL snapshot are retained in the project archive; the evidence summarized below comes from the corresponding local and Drive project records. This public repository is being reorganized around that final version. Claims distinguish source presence, simulation intent, routed implementation, and board demonstration.

## Why this project

The goal was not simply to add ISA features. Each extension changed a pipeline-wide control decision:

- forwarding and a load-use interlock resolve data hazards without silently consuming stale operands;
- APB wait handling freezes the pipeline around a memory-mapped transaction;
- CSR and interrupt support introduce trap arbitration, PC redirection, flush rules, and `mret` return behavior;
- the FPGA wrapper turns a debounced Basys3 center-button event into the external interrupt input.

That makes the project a compact example of RTL microarchitecture, SoC integration, verification thinking, and implementation-aware design review.

## Architecture

```text
Basys3 wrapper
├── 100 MHz clock / reset / button debounce
├── RV32I 5-stage pipeline
│   ├── IF → ID → EX → MEM → WB registers
│   ├── forwarding unit
│   ├── load-use hazard detection and stall/flush control
│   ├── branch/jump and trap PC selection
│   └── Machine-mode CSR file
├── APB master and address decode
│   ├── GPIO
│   ├── 4-digit seven-segment display
│   └── UART
└── instruction/data memories
```

## Implemented scope

| Area | Evidence-backed scope |
| --- | --- |
| Pipeline | Five stages with explicit IF/ID, ID/EX, EX/MEM, and MEM/WB state; forwarding and load-use interlock RTL are present in the final snapshot. |
| Control flow | Branch/jump flushing and trap-driven PC redirection are integrated with pipeline control. |
| SoC integration | AMBA APB-style memory-mapped GPIO, FND, and UART peripherals are instantiated in the top-level system. |
| Interrupt path | `btnC` is synchronized/debounced in the FPGA wrapper and passed as a one-cycle external-interrupt request. CSR state includes Machine-mode control/status paths and `mret` handling. |
| Firmware image | Instruction memory expects a `test.mem` image; a firmware build flow exists in the preceding CSR/APB project snapshot. |
| Timing evidence | A retained Vivado 2026.1 routed timing report for `rv32I_fpga_top` under a 100 MHz internal clock constraint reports setup WNS **+0.623 ns**, TNS **0.000 ns**, and **0 setup failing endpoints**. |

## Verification and implementation evidence

| Evidence type | What is supported | Boundary |
| --- | --- | --- |
| RTL review | Pipeline stages, hazard/forwarding logic, APB peripherals, CSR register file, controller, and debounce wrapper | RTL presence is not ISA-compliance proof. |
| Directed/system test collateral | Hazard tests, CSR/interrupt testbench collateral, firmware images, and Spike co-simulation automation exist across the project snapshots | A complete, versioned pass log for every test is not yet included here. |
| Routed timing | 100 MHz internal setup timing: WNS +0.623 ns, TNS 0, 0 failing setup endpoints | The report also records 47 unconstrained I/O-delay warnings; this is not full I/O sign-off. |
| Physical board | A Basys3-targeted wrapper maps clock, buttons, UART, GPIO, and FND ports | No photo, UART capture, or versioned bitstream is published here; physical-board operation is therefore not claimed as independently demonstrated. |

## Timing review: what changed the engineering discussion

The routed report identifies a positive internal setup result, but it does **not** close the project’s verification story. The retained engineering notes explicitly flag:

- 47 missing input/output delay constraints;
- UART RX CDC hardening still required;
- asynchronous reset deassertion risk;
- a one-cycle interrupt event that requires adversarial overlap testing with control-flow and APB-stall conditions.

This is deliberate portfolio material: it shows the difference between a positive WNS and complete hardware sign-off.

## How to review the RTL snapshot

The final source snapshot is organized around these entry points:

```text
rtl/
├── rv32I_fpga_top.sv        # Basys3-facing wrapper
├── rv32I_top.sv             # CPU + APB system integration
├── rv32i_cpu.sv
├── rv32i_datapath.sv
├── forwarding_unit.sv
├── hazard_detection_unit.sv
├── pipeline_controller.sv
├── csr_regfile.sv
├── APB_MASTER.sv
├── APB_GPIO.sv
├── APB_FND.sv
└── APB_UART.sv
```

The final board-folder snapshot does not itself contain a complete XDC, testbench, firmware image, or one-command build script. Those artifacts must be selected from the matching predecessor snapshots and validated together before a reproducible public release is claimed.

## Reproduction plan

A publishable reproduction bundle should contain all of the following in one commit:

1. a pinned RTL file list and named top module;
2. the matching `test.mem` and firmware build command;
3. the Basys3 XDC used for the reported implementation;
4. the exact testbench, simulator command, and sanitized pass log;
5. the Vivado version, implementation command, and sanitized timing report;
6. optional board proof: bitstream/build ID plus UART capture, image, or short video.

Until then, this README is an evidence register and engineering narrative—not a claim that a fresh clone can recreate every reported result.

## Contribution and provenance

This project contains iterative, AI-assisted development material. The portfolio claim should be limited to work the author can explain and defend: architecture decisions, pipeline/control requirements, verification scenarios, evidence review, and implementation trade-offs. Do not describe the entire RTL as solely handwritten until a file-level provenance record is completed.

## Interview-ready summary

> Developed and reviewed an RV32I 5-stage pipeline SoC with forwarding, load-use interlock, APB MMIO, Machine-mode CSR, and external-interrupt control. A Vivado 2026.1 routed implementation of `rv32I_fpga_top` met the 100 MHz internal setup target (WNS +0.623 ns, TNS 0 ns); follow-up work explicitly tracks I/O constraints, CDC, reset release, and interrupt-event retention as separate closure items.

See the repository-wide [evidence register](../../docs/PORTFOLIO_EVIDENCE.md) before reusing any claim in an application.

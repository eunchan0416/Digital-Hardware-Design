
# Documentation

This directory contains the architectural specifications, state machine descriptions, and simulation waveforms for the RV32I APB Custom SoC project.

## 1. System Architecture
The top-level architecture integrates the RV32I multi-cycle core with an AMBA 3 APB bus interface. The memory map and peripheral interconnects are defined based on a 32-bit address space.
* ![System Block Diagram](./block_diagram.png)

## 2. Core Finite State Machine (FSM)
The RV32I CPU operates on a 5-stage multi-cycle FSM (Fetch, Decode, Execute, Memory, Write-back). Instruction latch logic is implemented at the Fetch stage to optimize the critical path and ensure timing stability.
* ![CPU FSM Chart](./cpu_fsm_chart.png)

## 3. Simulation & Verification
RTL verification was performed using Vivado Simulator. The following waveforms validate the APB bus transactions and the functional operations of the integrated peripherals.

### 3.1. UART Transceiver
Verification of baud rate generation and TX/RX data transmission logic. Separated shadow and active registers are implemented to prevent data corruption during baud rate reconfiguration.
* ![UART Simulation Waveform](./uart_sim_waveform.png)

### 3.2. GPIO & LED Control
Verification of memory-mapped I/O access and bidirectional port control logic via the APB bus.
* ![GPIO LED Simulation](./gpio_led_sim.png)

## 4. Project Presentation
For a comprehensive overview of the design methodology, memory map definitions, and hardware-software co-simulation procedures, refer to the attached presentation slide.
* [RV32I_APB_Custom_SoC_Presentation.pptx](./RISC-V_multi-cycle_APB_bus_(2).pptx)

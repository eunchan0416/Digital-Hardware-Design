# Documentation & Verification Results

This directory contains the architectural specifications, state machine descriptions, and simulation waveforms.

## 1. Core Finite State Machine (FSM)
The RV32I CPU operates on a 5-stage multi-cycle FSM.
![CPU FSM Chart](./cpu_fsm_chart.png)

## 2. Simulation & Verification (Waveforms)
RTL verification was performed using Vivado Simulator based on HW/SW co-simulation.

### 2.1. AMBA APB UART Interface Transaction
Verification of baud rate generation and TX/RX data transmission logic over the APB bus.
![UART Simulation Waveform](./uart_sim_waveform.png)

### 2.2. Memory-Mapped GPIO Operation
Verification of memory-mapped I/O access and bidirectional port control logic.
![GPIO LED Simulation](./gpio_led_sim.png)

## 3. Project Presentation
Detailed design methodology and troubleshooting processes are documented in the attached presentation slide.
* [RV32I_APB_Custom_SoC_Presentation.pptx](./RISC-V_multi-cycle_APB_bus_(2).pptx)

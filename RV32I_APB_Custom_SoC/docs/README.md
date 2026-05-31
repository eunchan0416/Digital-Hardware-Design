# Documentation & Verification

This directory contains the architectural FSM specifications and HW/SW co-simulation waveforms.

## 1. Core FSM
5-stage multi-cycle state transition logic for the RV32I CPU.
![CPU FSM Chart](./cpu_fsm_chart.png)

## 2. Simulation Waveforms (Vivado)

### 2.1. AMBA APB UART Interface
APB bus transaction and baud rate generation for UART TX/RX.
![UART Simulation Waveform](./uart_sim_waveform.png)

### 2.2. Memory-Mapped GPIO
Bidirectional port control and memory-mapped I/O read/write access.
![GPIO LED Simulation](./gpio_led_sim.png)

## 3. Reference
Hardware specifications and design details:
* [RV32I_APB_Custom_SoC_Presentation.pptx](./RISC-V_multi-cycle_APB_bus_(2).pptx)

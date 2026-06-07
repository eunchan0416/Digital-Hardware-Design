# 🛠️ Serial IPs with Advanced UVM Verification Suite

This repository features a collection of robust, synthesizable serial communication protocol IPs (UART, SPI, I2C) designed at the Register Transfer Level (RTL) and thoroughly verified using an enterprise-grade **Universal Verification Methodology (UVM) 1.2** framework.

The primary objective of this project is to demonstrate commercial-grade hardware design predictability and a rigorous top-down verification architecture utilizing asynchronous dynamic transaction tracking.

---

## 📡 1. UART (Universal Asynchronous Receiver/Transmitter) IP Core

The custom UART core utilizes an asynchronous data transmission protocol based on a fixed 8-N-1 framing structure, featuring an industrial-grade oversampling receiver to achieve high noise immunity and maximum timing margin accuracy.

### 1.1. Protocol & Framing Architecture
The design strictly adheres to the standard 8-N-1 (8 Data bits, No Parity, 1 Stop bit) frame format. To ensure robust data recovery under noisy line conditions, a 16x baud-rate oversampling engine is implemented, allowing the receiver to sample incoming data bits precisely at their theoretical midpoint (Center-aligned sampling).

![UART Frame Format](./docs/uart/uart_frame_format.png)

### 1.2. Hardware FSM Design
For maximum stability and clock-domain isolation, the transmitter (TX) and receiver (RX) cores are designed as completely independent Moore-type Finite State Machines (FSMs).

* **UART TX Controller FSM**
  Manages parallel-to-serial conversion, sequentially shifting out data bits, injecting the frame boundaries, and safely returning the physical transmission line to the Idle (High) state upon completion.
  ![UART TX FSM](./docs/uart/uart_tx_fsm.png)

* **UART RX Controller FSM**
  Monitors line transitions to detect the falling edge of the Start bit. It counts 16x oversampling clock ticks (`b_tick_cnt`) to locate the center of the Start bit (`b_tick_cnt==7`) for validation, and subsequently samples the remaining payload every 16 ticks.
  ![UART RX FSM](./docs/uart/uart_rx_fsm.png)

### 1.3. UVM Verification Environment
A top-down UVM verification environment has been constructed to comprehensively stress-test the design against randomized transaction sequences and timing constraints.

* **Scoreboard (`uart_scoreboard.sv`):** Implements an asynchronous queue-based predictor model to dynamically capture and compare expected vs. actual data payloads, ensuring absolute data integrity across the lanes.
* **Agent & Components:** Features fully isolated Driver, Monitor, and Sequencer components communicating seamlessly via Transaction-Level Modeling (TLM) analysis ports.

### 1.4. Hardware Timing Verification (Waveform Proof)
The simulation waveform trace below demonstrates successful transmission and reception of an 8-bit payload (`8'h72`, ASCII 'r'). It provides physical proof of the serial bit-shifting sequence, internal register updates, and the precise assertion of the `rx_done` flag.
![UART RX Waveform](./docs/uart/uart_rx_waveform.png)

---

## 📂 2. Repository Directory Structure

The workspace is hierarchically structured to enforce design modularity and support seamless verification component reuse for subsequent IP integrations:

```text
02_Serial_IPs_with_UVM/
├── rtl/                        # Design Under Test (DUT) Sources
│   └── uart/
│       ├── uart_top.sv         # Top wrapper integrating TX, RX, and Baud Generator
│       ├── uart_tx.sv          # Transmitter FSM module
│       ├── uart_rx.sv          # Receiver sampling module
│       └── baud_tick.sv        # 16x Oversampling clock divider
├── verif/                      # UVM Verification IP (VIP) Suite
│   └── uart_env/
│       ├── tb_uart.sv          # Hardware Testbench Top
│       ├── uart_interface.sv   # Virtual interface with clocking blocks
│       ├── uart_scoreboard.sv  # FIFO queue-based data integrity comparator
│       └── ...                 # Driver, Monitor, Agent, Sequences, and Tests
├── sim/                        # Simulation & Build Automation Infrastructure
│   └── uart/
│       ├── Makefile            # Automated VCS compilation and simulation script
│       ├── filelist.f          # Structural file dependency compilation sequence
│       └── logs/
│           └── uart_base_test.log  # Raw execution trace log proving 0-error status
└── docs/                       # Technical Specifications & Documentation Assets
    └── uart/                   # Architecture visual diagrams and waveform traces
        ├── uart_frame_format.png
        ├── uart_tx_fsm.png
        ├── uart_rx_fsm.png
        └── uart_rx_waveform.png

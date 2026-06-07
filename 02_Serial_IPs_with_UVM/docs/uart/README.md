# 📡 UART IP Core Technical Specification & Verification Report

This document provides the exhaustive hardware architectural specifications, interface definitions, finite state machine (FSM) controls, and physical waveform proofs for the custom-designed UART IP Core.

---

## 1. Technical Specifications & Framing Format

The Custom UART core utilizes an asynchronous serial data transmission protocol based on a fixed framing structure. It incorporates an industrial-grade oversampling receiver to achieve high noise immunity and timing margin robustness against potential baud rate drift.

* **Data Width:** 8-bit Serial-to-Parallel and Parallel-to-Serial conversion.
* **Framing Configuration:** 1 Start bit (Low), 8 Data bits (LSB-first), 1 Stop bit (High), No Parity.
* **Oversampling Engine:** 16x baud rate clock generation for stable mid-bit alignment.

![UART Frame Format](./uart_frame_format.png)

---

## 2. IP Core Interface (Port Map)

The top-level module (`uart_top.sv`) exposes the following physical pins for system integration.

| Port Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `clk` | Input | 1 | System clock (e.g., 100MHz) |
| `rst_n` | Input | 1 | Active-low asynchronous reset |
| `rx` | Input | 1 | Asynchronous serial data receive line |
| `tx` | Output | 1 | Asynchronous serial data transmit line |
| `tx_start` | Input | 1 | Trigger pulse to initiate data transmission |
| `tx_data` | Input | 8 | Parallel payload data to be transmitted |
| `rx_done` | Output | 1 | Pulses High for 1 clock cycle when a byte is successfully received |
| `rx_data` | Output | 8 | Received parallel payload data |

---

## 3. Hardware Finite State Machine (FSM) Design

For complete hardware decoupling and timing optimization, the design implements fully independent Moore-type finite state machines for the transmitter and receiver blocks.

### 3.1. UART Transmitter (TX) FSM
The transmitter controller handles the serialization of parallel host data. Upon receiving the `tx_start` signal, it sequentially drives the start bit, shifts out 8 data bits from the internal buffer register, appends the high stop bit, and cleanly drives the line back to the Idle state (`tx=1`).

![UART TX FSM](./uart_tx_fsm.jpg)

### 3.2. UART Receiver (RX) FSM
The receiver core samples the incoming asynchronous line. It continuously polls for a valid Start bit falling edge. Once detected, it utilizes a 16x oversampling counter (`b_tick_cnt`) to wait for 7 ticks (`b_tick_cnt==7`), placing the sampling point precisely at the theoretical center of the symbol window. Subsequent payload bits are sampled exactly every 16 ticks to maintain mid-bit alignment.

![UART RX FSM](./uart_rx_fsm.png)

---

## 4. Hardware Timing Verification (Waveform Proof)

The physical timing and structural correctness of the FSMs are proved via Synopsys simulation waveform analysis. 

The trace log below visualizes the transmission and reception of an 8-bit payload (`8'h72`, which corresponds to the ASCII character 'r'). It explicitly demonstrates the exact bit-shifting intervals, internal register updates matching the LSB-first rule, and the successful execution of the receive cycle bounded by the single-clock assertion of the `rx_done` flag.

![UART RX Waveform](./uart_rx_waveform.png)

---
[⬅ Return to Top-Level Dashboard](../../README.md)

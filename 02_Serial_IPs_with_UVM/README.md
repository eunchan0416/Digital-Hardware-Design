# Serial Communication IPs & UVM Verification Environments

This directory contains the custom RTL design and highly robust UVM (Universal Verification Methodology) environments for standard serial communication protocols (UART, SPI, I2C). 

The primary objective is to demonstrate full-cycle front-end engineering capabilities: from designing synthesizable standard protocol IPs from scratch to achieving 100% functional coverage using queue-based UVM scoreboards and independent agents.

## 1. Verification Target (DUT) Specifications

* **UART Module (Custom IP):**
  * RTL Design: 8-N-1 standard frame, integrated 16x oversampling baud-rate generator, and synchronized data paths.
  * UVM Verification: Standalone (Raw) IP verification utilizing dedicated Driver/Monitor tasks and Queue-based Scoreboards for asynchronous TX/RX streams.
* **SPI & I2C Modules (Custom IP):**
  * RTL Design: Custom cores with optional AXI4-Lite bus interconnect wrappers.
  * UVM Verification: Verified across dual topologies (Standalone Raw IP vs. AXI-integrated system) utilizing multi-agent synchronization (AXI Master VIP + Serial VIP).

## 2. Directory Structure

* `rtl/` : Synthesizable Verilog/SystemVerilog source codes.
  * `uart/` : Custom UART Controller core.
  * `spi/` & `i2c/` : Custom cores and AXI interconnect wrappers.
* `verif/` : UVM verification environments.
  * `vip/` : Reusable Verification IPs (UART, SPI, I2C, AXI Agents).
  * `current_*_env/` : Top-level test suites, virtual sequencers, and self-checking scoreboards.
* `sim/` : Simulation automated Makefiles for Synopsys VCS/Verdi execution.

## 3. UVM Testbench Architecture

The architecture separates expected (Golden) transactions from actual DUT outputs using dedicated Analysis Ports. The centralized Scoreboard utilizes FIFOs (Queues) to dynamically predict, capture, and match asynchronous transactions without data loss.

```text
+-------------------------------------------------------------------------+
|                               UVM Test                                  |
+-------------------------------------------------------------------------+
                                     |
+-------------------------------------------------------------------------+
|                            UVM Environment                              |
|   +-----------------------------------------------------------------+   |
|   |         Self-Checking Scoreboard (Queue-based Matching)         |   |
|   +-----------------------------------------------------------------+   |
|            |                                               |            |
|   +-----------------+                             +-----------------+   |
|   | Input Agent(VIP)|                             | Output Agent(VIP|   |
|   +-----------------+                             +-----------------+   |
+------------|-----------------------------------------------|------------+
             | (Virtual Interface)                           | (Virtual IF)
             v                                               v
+-------------------------------------------------------------------------+
|                                   DUT                                   |
|   +-----------------------------------------------------------------+   |
|   |                   Custom Serial IP Core (RTL)                   |   |
|   +-----------------------------------------------------------------+   |
+-------------------------------------------------------------------------+

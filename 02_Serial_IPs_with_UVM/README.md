# Serial Communication IPs & UVM Verification Environment

This directory contains the RTL design of standard serial communication IPs (UART, SPI, I2C) and their robust verification environments utilizing the Universal Verification Methodology (UVM).

## 1. Overview

The primary goal of this project is to implement fully synthesizable serial controllers and build highly reusable, protocol-specific UVM verification IPs (VIPs) to achieve 100% functional coverage.

* **Protocols Designed:** UART, SPI (Master/Slave), I2C (Master)
* **Verification Methodology:** UVM (Universal Verification Methodology)
* **Key Features:** Self-checking Scoreboard, Constraint Random Stimulus, Functional Coverage Closure

## 2. Directory Structure

* `rtl/` : Synthesizable SystemVerilog source codes for each serial protocol IP.
* `verif/` : UVM verification environment components.
  * `agents/` : Reusable, protocol-specific UVM agents (Driver, Monitor, Sequencer).
  * `uvm_env/` : Top-level environment, Scoreboard, and Virtual Sequencer.
  * `tb/` : Top-level HDL testbench and Virtual Interfaces.
* `sim/` : Simulation run scripts and Makefiles for EDA tool automation.
* `docs/` : Test plans, architecture diagrams, and coverage reports.

## 3. UVM Testbench Architecture

The testbench is constructed with strict modularity. Each serial IP is driven and monitored by its dedicated UVM Agent, which passes transaction items to a centralized Scoreboard for data integrity verification.

![UVM Architecture Diagram](./docs/uvm_architecture.jpg) 
*(Note: Please upload your UVM block diagram image to the docs folder and match the file name here.)*

## 4. Verification Strategy & Metrics

* **Stimulus Generation:** Sequences generate constrained-random transactions covering diverse configurations (e.g., various baud rates, parity errors, clock polarities).
* **Self-Checking Mechanism:** The `serial_scoreboard` compares reference data from the Predictor against the actual collected data from the Monitors.
* **Coverage Closure:** Covergroups are implemented to ensure all FSM states, protocol configurations, and corner cases are hit during simulation.

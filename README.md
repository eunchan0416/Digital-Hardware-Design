# Digital Hardware Design & Verification Portfolio

디지털 논리 회로 설계(RTL) 및 하드웨어/소프트웨어 통합 검증, 그리고 UVM 기반의 환경 구축 역량을 증명하기 위한 프로젝트 모음입니다.

##  IP & Project Catalog

각 디렉토리 링크를 클릭하시면, 해당 프로젝트의 상세 아키텍처 스펙(Datasheet)과 검증 리포트를 확인하실 수 있습니다.

### 1. [RV32I_APB_Custom_SoC](./RV32I_APB_Custom_SoC)
* **Keyword:** `SystemVerilog`, `RISC-V`, `AMBA 3 APB`, `HW/SW Co-simulation`
* **Description:** 32-bit RISC-V (RV32I) Multi-cycle 프로세서 코어를 직접 설계하고, APB Bus를 통해 메모리 맵 기반 주변장치(UART, GPIO 등)를 통합한 Custom SoC 프로젝트입니다. Bare-metal C 펌웨어를 통한 하드웨어 제어 능력을 검증했습니다.

### 2. [02_Serial_IPs_with_UVM](./02_Serial_IPs_with_UVM) *(In Progress)*
* **Keyword:** `SystemVerilog`, `UVM`, `Verification`, `VCS/Verdi`
* **Description:** Universal Verification Methodology(UVM)을 적용하여 시리얼 통신 IP의 Testbench Architecture(Agent, Scoreboard, Sequence)를 구축하고 커버리지(Coverage)를 100% 달성하기 위한 검증 프로젝트입니다.

##  Tech Stack & EDA Tools
* **Design & Verification:** Verilog, SystemVerilog, UVM, C 
* **EDA Tools:** Xilinx Vivado, Synopsys VCS / Verdi
* **Target Board:** Digilent Basys 3 (Xilinx Artix-7)

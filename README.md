# Digital Hardware Design & Verification

본 레포지토리는 디지털 논리 회로 설계(RTL), SoC(System-on-Chip) 통합 검증 및 UVM 기반 검증 환경 소스 코드를 관리하는 저장소입니다.

## Projects

각 디렉토리의 README에서 상세 아키텍처 스펙 및 검증 결과를 확인할 수 있습니다.

### 1. [RV32I_APB_Custom_SoC](./RV32I_APB_Custom_SoC)
* **Keywords:** `SystemVerilog`, `RISC-V`, `AMBA 3 APB`, `HW/SW Co-simulation`
* **Description:** 32-bit RISC-V (RV32I) Multi-cycle 코어 및 AMBA 3 APB 버스 기반의 Custom SoC 설계. 메모리 맵 기반 주변장치(UART, GPIO 등) 통합 및 Bare-metal C 펌웨어 환경에서의 하드웨어 동작 검증 포함.

### 2. [02_Serial_IPs_with_UVM](./02_Serial_IPs_with_UVM) *(In Progress)*
* **Keywords:** `SystemVerilog`, `UVM`, `Verification`, `VCS/Verdi`
* **Description:** 시리얼 통신 IP 검증을 위한 UVM(Universal Verification Methodology) 기반 Testbench Architecture (Agent, Scoreboard, Sequence) 구축 및 커버리지 달성 프로젝트.

## Tech Stack
* **Languages/Methodology:** Verilog, SystemVerilog, UVM, C (Bare-metal)
* **EDA Tools:** Xilinx Vivado, Synopsys VCS / Verdi
* **Target Device:** Xilinx Artix-7 (Digilent Basys 3)

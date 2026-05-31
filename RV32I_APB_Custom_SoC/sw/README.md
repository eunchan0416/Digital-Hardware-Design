# Firmware & Test Binaries

본 디렉토리는 RV32I 기반 SoC의 하드웨어 동작을 검증하기 위한 Bare-metal C 소스 코드와 컴파일된 기계어 바이너리(`.mem`) 파일들을 포함하고 있습니다.

## 1. Directory Structure

* `src/` : 메모리 맵 기반 주변장치(UART, GPIO 등) 제어를 위한 원본 C 소스 코드
* `*.mem` : Vivado 시뮬레이션 시 `instruction_mem`에 로드되는 최종 바이너리 데이터

## 2. Build & Simulation Flow

본 레포지토리에 포함된 바이너리 파일들은 아래의 파이프라인을 거쳐 생성되었으며, RTL 시뮬레이션 환경과 통합되어 동작합니다.

1. **Compilation:** 작성된 C 코드를 RISC-V GCC 툴체인(`rv32i` 타겟)을 통해 Assembly 코드로 변환 및 최적화(`-O1`).
2. **Hex Generation:** 변환된 어셈블리를 하드웨어 시뮬레이터에서 읽을 수 있는 16진수(`.mem`) 데이터로 추출.
3. **Simulation:** 최상위 테스트벤치(`tb_rv32i.sv`)의 `$readmemh` 구문을 통해 ROM에 로드된 후, CPU 코어의 Fetch 과정부터 HW/SW Co-simulation 진행.

## 3. Test Cases

각 모듈의 독립적인 기능 및 APB 버스 트랜잭션 검증을 위해 제공되는 테스트 바이너리 목록입니다.

* **UART Tests (`APB_UART_*.mem`)**
  * 내부 클럭 대비 Baud rate 분주비 설정 검증
  * TX/RX 버퍼를 통한 시리얼 데이터 송수신 동작 확인
* **GPIO Tests (`APB_GPIO_LED.mem`, `APB_GPO_GPI.mem`)**
  * 포트 입출력 방향(Direction) 제어 및 데이터 Read/Write 확인
* **FND Test (`APB_FND.mem`)**
  * 7-Segment 디스플레이 레지스터 제어 로직 검증
* **System Tests (`riscv_rv32i_rom_data.mem`, `APB_INIT.mem`)**
  * RV32I 기본 명령어 처리 및 시스템 초기화 시퀀스 검증

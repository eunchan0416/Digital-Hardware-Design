# Software & Firmware Binary (`sw/`)

이 디렉토리는 RV32I 코어와 APB 주변장치(Peripherals)들을 하드웨어/소프트웨어 통합 환경에서 검증하기 위해 빌드된 기계어 바이너리(.mem) 파일들을 포함하고 있습니다.

##  Description
* C언어 및 Assembly로 작성된 테스트 코드를 RISC-V GCC Toolchain을 이용해 컴파일한 결과물입니다.
* Vivado 시뮬레이션 시 `$readmemh` 시스템 태스크를 통해 `instruction_mem` (ROM) 모듈에 로드되어 CPU 코어가 직접 Fetch 및 Execute를 수행합니다.

##  File Contents
* `APB_UART_TX.mem` / `APB_UART_RX.mem`: UART 송수신 동작 검증용 펌웨어
* `APB_FND.mem` : 7-Segment 디스플레이 제어 및 APB 버스 트랜잭션 검증용
* `APB_GPIO_LED.mem` : GPIO 기반 LED 점멸(Blink) 제어 코드
* `riscv_rv32i_rom_data.mem` : RV32I 기본 명령어 셋(Instruction Set) 기능 검증용 데이터

> Note: 본 바이너리 파일들은 APB Master를 통해 각 Slave IP의 Memory-mapped Register에 Read/Write 트랜잭션을 발생시키며, 이를 통해 시스템 전체의 동작 무결성을 파형(Waveform)으로 검증하였습니다.

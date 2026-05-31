# Software & Firmware Binary

이 디렉토리는 RV32I 코어와 APB 주변장치(Peripherals)들을 하드웨어/소프트웨어 통합 환경에서 검증하기 위해 빌드된 기계어 바이너리(`.mem`) 파일들과 원본 C 코드를 포함하고 있습니다.

## 1. Directory Structure
* `src/` : 메모리 제어(Memory-mapped I/O) 검증용 원본 C 언어 소스 코드 (`gpio_main.c`).
* `*.mem` : 각 Peripheral 동작 검증을 위해 컴파일된 최종 기계어 바이너리 파일들.


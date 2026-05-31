# Software & Firmware Binary

이 디렉토리는 RV32I 코어와 APB 주변장치(Peripherals)들을 하드웨어/소프트웨어 통합 환경에서 검증하기 위해 빌드된 기계어 바이너리(`.mem`) 파일들과 원본 C 코드를 포함하고 있습니다.

## 1. Directory Structure
* `src/` : 메모리 제어(Memory-mapped I/O) 검증용 원본 C 언어 소스 코드 (`gpio_main.c`).
* `*.mem` : 각 Peripheral 동작 검증을 위해 컴파일된 최종 기계어 바이너리 파일들.

## 2. Memory-Mapped I/O Control
하드웨어 제어는 하드코딩을 지양하고, 현업 펌웨어 드라이버(HAL) 표준 구조인 **구조체(Struct) 맵핑과 `volatile` 지시어**를 활용하여 레지스터를 추상화(Abstraction)했습니다.

**[C Code Snippet Example: `src/gpio_main.c`]**
```c
// 구조체를 활용한 APB Peripheral 레지스터 추상화
typedef struct {
    volatile uint32_t ctl;
    volatile uint32_t odata;
    volatile uint32_t idata;
} GPIO_TypeDef;

#define GPIO0 ((GPIO_TypeDef *) 0x20002000UL)

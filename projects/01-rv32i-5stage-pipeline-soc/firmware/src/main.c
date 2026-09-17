/**
 * @file main.c
 * @brief Bare-metal CSR & Pushbutton Interrupt Verification Firmware
 * Target: RV32I 5-Stage Pipelined Processor with Machine-Mode CSR & APB Subsystem
 *
 * Hardware Memory Map:
 *   - Instruction ROM: 0x8000_0000 ~ 0x8000_0FFF (4KB)
 *   - Data RAM:        0x1000_0000 ~ 0x1000_0FFF (4KB)
 *   - Stack Pointer:   0x1000_1000 (Top of Data RAM)
 *   - GPIO Peripheral: 0x2000_2000 (MODER), 0x2000_2004 (ODATA)
 *   - FND Peripheral:  0x2000_3000 (ODATA)
 *
 * Interrupt Operation:
 *   - Pushbutton 'btnC' generates debounced 1-clock external interrupt (ext_irq).
 *   - CPU trap unit saves PC to mepc, sets mstatus.MPIE, and jumps to mtvec.
 *   - ISR toggles counting direction (Up <-> Down) and flashes all 16 LEDs.
 *   - mret restores execution cleanly to mepc.
 */

// Freestanding type definitions (No OS libc/glibc header dependency)
typedef unsigned int       uint32_t;
typedef int                int32_t;
typedef unsigned short     uint16_t;
typedef short              int16_t;
typedef unsigned char      uint8_t;

// Peripheral Memory Mapped IO
#define GPIO_MODER      (*(volatile uint32_t *)0x20002000)
#define GPIO_ODATA      (*(volatile uint32_t *)0x20002004)
#define FND_ODATA       (*(volatile uint32_t *)0x20003000)

// Data RAM Global State
#define COUNT_DIR_REG   (*(volatile int32_t  *)0x10000000) // 1: Up, -1: Down
#define IRQ_COUNT_REG   (*(volatile uint32_t *)0x10000004)

// CSR Manipulation Macros & ISR Declaration
// (Host IntelliSense guard: prevents Mac clang linter from showing errors on RISC-V instructions)
#if defined(__riscv)
  #define WRITE_CSR(reg, val) \
      __asm__ volatile ("csrw " #reg ", %0" :: "r"(val))
  #define SET_CSR(reg, bitmask) \
      __asm__ volatile ("csrs " #reg ", %0" :: "r"(bitmask))
  void isr_button_handler(void) __attribute__((interrupt("machine")));
#else
  #define WRITE_CSR(reg, val)   ((void)(val))
  #define SET_CSR(reg, bitmask) ((void)(bitmask))
  void isr_button_handler(void);
#endif

static void delay(volatile uint32_t count) {
    while (count--) {
        __asm__ volatile ("nop");
    }
}

int main(void) {
    // 1. Initialize Stack & Peripherals
    GPIO_MODER = 0x0000FFFF;  // Set 16 LEDs as outputs
    FND_ODATA  = 0;

    // 2. Initialize Shared State in RAM
    COUNT_DIR_REG = 1;        // Start counting UP
    IRQ_COUNT_REG = 0;

    // 3. Register ISR and Enable Machine-mode Interrupts
    WRITE_CSR(mtvec, (uint32_t)&isr_button_handler); // Register Vector
    SET_CSR(mie, (1 << 11));                         // MEIE = bit 11 (External IRQ Enable)
    SET_CSR(mstatus, (1 << 3));                      // MIE  = bit 3  (Global IRQ Enable)

    int32_t counter = 0;
    uint16_t led_pattern = 0x0001;

    while (1) {
        // Output current counter value to 7-Segment Display
        FND_ODATA = (uint32_t)counter;

        // Output current LED pattern
        GPIO_ODATA = (uint32_t)led_pattern;

        // Circulate LED pattern
        led_pattern = (uint16_t)((led_pattern << 1) | (led_pattern >> 15));

        // Delay for visual observation
        delay(40000);

        // Read counting direction (may be modified asynchronously by ISR!)
        int32_t current_dir = COUNT_DIR_REG;

        if (current_dir > 0) {
            // Counting UP (0 -> 9999)
            counter++;
            if (counter >= 10000) {
                counter = 0;
            }
        } else {
            // Counting DOWN (9999 -> 0)
            if (counter <= 0) {
                counter = 9999;
            } else {
                counter--;
            }
        }
    }

    return 0;
}

/**
 * @brief Machine External Interrupt Service Routine
 */
void isr_button_handler(void) {
    // 1. Flash all LEDs to visually acknowledge interrupt arrival
    GPIO_ODATA = 0x0000FFFF;

    // 2. Toggle counting direction
    COUNT_DIR_REG = -COUNT_DIR_REG;
    IRQ_COUNT_REG++;

    // Small delay to keep LEDs flashed momentarily
    for (volatile int i = 0; i < 500; i++) {
        __asm__ volatile ("nop");
    }

    // Hardware automatically issues mret upon function return
}

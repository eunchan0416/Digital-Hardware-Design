/**
 * @file    main.c
 * @brief   Bare-metal Firmware for RV32I APB Custom SoC
 * @details Implements Hardware Abstraction Layer (HAL) for MMIO control,
 * system initialization, and baseline peripheral verifications.
 */

#include <stdint.h>

/* ===================================================================== */
/* System Status Codes                                                   */
/* ===================================================================== */
#define SYS_ERR (-1)
#define SYS_OK  (0)

/* ===================================================================== */
/* Memory Map (Base Addresses)                                           */
/* ===================================================================== */
#define APB_BRAM_BASE       (0x10000000UL)
#define APB_PERIPH_BASE     (0x20000000UL)

/* Peripheral Base Addresses */
#define APB_GPO_BASE        (APB_PERIPH_BASE + 0x0000UL)
#define APB_GPI_BASE        (APB_PERIPH_BASE + 0x1000UL)
#define APB_GPIO_BASE       (APB_PERIPH_BASE + 0x2000UL)
#define APB_FND_BASE        (APB_PERIPH_BASE + 0x3000UL)
#define APB_UART_BASE       (APB_PERIPH_BASE + 0x4000UL)

/* ===================================================================== */
/* Raw Register Definitions (Legacy/Direct Access)                       */
/* ===================================================================== */
/* BRAM */
#define APB_BRAM_DATA       (*(volatile uint32_t *)APB_BRAM_BASE)

/* GPO */
#define APB_GPO_CTL         (*(volatile uint32_t *)(APB_GPO_BASE + 0x00UL))
#define APB_GPO_ODATA       (*(volatile uint32_t *)(APB_GPO_BASE + 0x04UL))

/* GPI */
#define APB_GPI_CTL         (*(volatile uint32_t *)(APB_GPI_BASE + 0x00UL))
#define APB_GPI_IDATA       (*(volatile uint32_t *)(APB_GPI_BASE + 0x04UL))

/* ===================================================================== */
/* Hardware Abstraction Layer (HAL) - Recommended Approach               */
/* ===================================================================== */
#define _IO volatile

/**
 * @brief GPIO Peripheral Register Structure
 */
typedef struct {
    _IO uint32_t ctl;       /*!< Control Register (Direction) */
    _IO uint32_t odata;     /*!< Output Data Register         */
    _IO uint32_t idata;     /*!< Input Data Register          */
} GPIO_TypeDef;

/* Peripheral Instance Mapping */
#define GPIO0 ((GPIO_TypeDef *) APB_GPIO_BASE)

/* ===================================================================== */
/* Function Prototypes                                                   */
/* ===================================================================== */
void delay_ms(int delay);
int  sys_init(void);
void gpio_init(GPIO_TypeDef *GPIOx, uint32_t control);
void led_write(GPIO_TypeDef *GPIOx, uint32_t wdata);
uint32_t sw_read(GPIO_TypeDef *GPIOx);

/* ===================================================================== */
/* Main Routine                                                          */
/* ===================================================================== */
/**
 * @brief  Main program entry point
 * @return int (Should not return in bare-metal, but standard requires int)
 */
int main(void) {
    int ret = SYS_ERR;
    uint32_t gpio0_val = 0;
    
    /* 1. System Initialization & Self-Test */
    ret = sys_init();
    if (ret != SYS_OK) {
        /* HW Initialization failed. Halt system. */
        while(1) { __asm__("nop"); }
    }

    /* 2. Main Application Loop */
    // int time = 1000;
    // uint32_t blink_flg = 0;

    // Read switch inputs and write to LEDs directly
    gpio0_val = sw_read(GPIO0);
    led_write(GPIO0, gpio0_val);

    /* --- Blink Logic (Commented out for future expansion) --- */
    /*
    while(1) {
        if(!time) {
            time = 1000;
            gpio0_val = sw_read(GPIO0);
            if(!blink_flg) {
                blink_flg = 1;
                led_write(GPIO0, gpio0_val);
            } else {
                blink_flg = 0;
                led_write(GPIO0, ~gpio0_val); // Toggle LEDs
            }
        }
        delay_ms(1);
        time--;
    }
    */

    return 0;
}

/* ===================================================================== */
/* HAL Function Implementations                                          */
/* ===================================================================== */

/**
 * @brief System Hardware Initialization & BRAM Read/Write Test
 * @return int (SYS_OK if successful, SYS_ERR on failure)
 */
int sys_init(void) {
    uint32_t read_val = 0;
    
    /* [1] BRAM R/W Test (Verify Bus Integrity) */
    APB_BRAM_DATA = 0x00000001; 
    read_val = APB_BRAM_DATA;
    
    if(read_val != 0x00000001) {
        // [TODO] UART Print Error Message here
        return SYS_ERR;
    }
    
    /* [2] Peripheral Default State Initialization */
    // GPO
    APB_GPO_CTL   = 0x00000000; 
    APB_GPO_ODATA = 0x00000000; 
    
    // GPI 
    APB_GPI_CTL   = 0x00000000; 
    read_val      = APB_GPI_IDATA; // Dummy read to clear buffer
    
    /* [3] GPIO0 Initialization */
    // GPIO[15:8]: LED output (1), GPIO[7:0]: Switch input (0)
    gpio_init(GPIO0, 0x0000FF00); 

    return SYS_OK;
}

void gpio_init(GPIO_TypeDef *GPIOx, uint32_t control) {
    GPIOx->ctl = control;
}

void led_write(GPIO_TypeDef *GPIOx, uint32_t wdata) {
    GPIOx->odata = wdata;
}

uint32_t sw_read(GPIO_TypeDef *GPIOx) {
    return GPIOx->idata;
}

/**
 * @brief Crude busy-wait delay function
 * @param delay Approximate milliseconds to delay (Assumes specific clock frequency)
 */
void delay_ms(int delay) {
    int i = 0;
    int j = 0;
    
    /* volatile is recommended for busy-wait loops so compiler doesn't optimize it away */
    volatile int k = 0; 
    
    for(i = 0; i < delay; i++) {
        // FIXED BUG: j++ instead of i++ to prevent infinite loop
        for(j = 0; j < (100000 / 3); j++) {
            k = k + 1;
        }
    }
}
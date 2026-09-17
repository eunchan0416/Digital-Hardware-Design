# ==============================================================================
# Firmware for RV32I 5-Stage Pipeline with CSR & Interrupt (hazard_with_csr_interrupt)
# Target: Basys3 FPGA Board / Machine-Mode CSR & Pushbutton Interrupt Verification
#
# Memory Map:
#   - ROM:       0x8000_0000 (Instruction ROM, 4KB)
#   - RAM:       0x1000_0000 (dir: +1 or -1 at 0x1000_0000)
#   - Stack:     0x1000_1000 (Top of RAM, grows down)
#   - GPIO:      0x2000_2000 (MODER), 0x2000_2004 (ODATA)
#   - FND:       0x2000_3000 (ODATA)
#
# Hardware Interrupt Mechanism:
#   - btnC debounced 1-cycle pulse asserts ext_irq into RV32I core.
#   - Hardware traps to mtvec (isr_handler), saves PC to mepc, sets mstatus.MPIE.
#   - ISR inverts counting direction (Up <-> Down), flashes LEDs, executes mret.
# ==============================================================================

    .section .text
    .globl _start

_start:
    # 1. Initialize Stack Pointer (sp = 0x10001000: Top of 4KB Data RAM)
    lui     sp, 0x10001
    addi    sp, sp, 0

    # 2. Register Machine Trap Vector (mtvec <= isr_handler)
    #    Target address is calculated via lui + addi
    lui     t0, 0x80000
    addi    t0, t0, 0x100       # isr_handler will be located at 0x80000100
    csrw    mtvec, t0

    # 3. Enable External Interrupt in mie (MEIE = bit 11 = 0x800)
    addi    t1, zero, 1
    slli    t1, t1, 11          # t1 = 0x800
    csrw    mie, t1

    # 4. Enable Global Interrupt in mstatus (MIE = bit 3 = 0x8)
    addi    t2, zero, 8         # t2 = 0x008
    csrs    mstatus, t2

    # 5. Initialize Shared State in RAM (dir = +1 at 0x10000000)
    lui     t3, 0x10000
    addi    t4, zero, 1
    sw      t4, 0(t3)           # RAM[0] = 1 (Up-count)

    # 6. Initialize GPIO Peripheral (0x20002000: Set 16 LEDs as output)
    lui     a6, 0x20002         # GPIO Base
    lui     t0, 0x10
    addi    t0, t0, -1          # t0 = 0x0000FFFF
    sw      t0, 0(a6)           # GPIO_MODER = 0xFFFF

    # 7. Initialize FND Display (0x20003000: Clear display)
    lui     a7, 0x20003         # FND Base
    sw      zero, 0(a7)         # FND_ODATA = 0

    # 8. Setup Loop Registers
    addi    a1, zero, 0         # counter = 0
    addi    a2, zero, 1         # led_pattern = 1
    lui     t6, 2
    addi    t6, t6, 1808        # t6 = 10000 (0x2710)

main_loop:
    # Display on FND and LEDs
    sw      a1, 0(a7)           # FND_ODATA = counter
    sw      a2, 4(a6)           # GPIO_ODATA = led_pattern

    # Rotate LED pattern (16-bit circular shift)
    slli    a5, a2, 1
    srli    t0, a2, 15
    or      a2, a5, t0
    slli    a2, a2, 16
    srli    a2, a2, 16          # mask to 16 bits

    # Delay loop for human eye observation
    addi    t1, zero, 250
delay_loop1:
    addi    t2, zero, 160
delay_loop2:
    addi    t2, t2, -1
    bne     t2, zero, delay_loop2
    addi    t1, t1, -1
    bne     t1, zero, delay_loop1

    # Check Counting Direction from Data RAM (modified asynchronously by ISR!)
    lui     t3, 0x10000
    lw      t4, 0(t3)           # read dir
    blt     t4, zero, do_count_down

do_count_up:
    addi    a1, a1, 1           # counter++
    bge     a1, t6, reset_to_zero
    jal     zero, main_loop

reset_to_zero:
    addi    a1, zero, 0
    jal     zero, main_loop

do_count_down:
    ble     a1, zero, reset_to_max
    addi    a1, a1, -1          # counter--
    jal     zero, main_loop

reset_to_max:
    addi    a1, t6, -1          # counter = 9999
    jal     zero, main_loop

# ==============================================================================
# Interrupt Service Routine (ISR) - Placed at fixed address 0x80000100
# ==============================================================================
    .org 0x100
isr_handler:
    # Context Save
    addi    sp, sp, -16
    sw      t0, 0(sp)
    sw      t1, 4(sp)
    sw      t2, 8(sp)

    # 1. Toggle counting direction in RAM (dir = -dir)
    lui     t0, 0x10000
    lw      t1, 0(t0)
    sub     t1, zero, t1        # negate direction
    sw      t1, 0(t0)

    # 2. Flash all 16 LEDs to visually confirm hardware interrupt reception
    lui     t0, 0x20002
    lui     t2, 0x10
    addi    t2, t2, -1          # 0x0000FFFF
    sw      t2, 4(t0)

    # Context Restore
    lw      t0, 0(sp)
    lw      t1, 4(sp)
    lw      t2, 8(sp)
    addi    sp, sp, 16

    # Return from machine-mode interrupt
    mret

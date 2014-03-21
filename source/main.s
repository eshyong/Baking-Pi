.section .init
.globl _start
_start:
    b main

.section .text
main:
    /* Moves stack pointer to 0x8000 */
    mov sp, #0x8000

    /* Enables output to LED */
    pin_num .req r0
    pin_fun .req r1
    mov     pin_num, #16
    mov     pin_fun, #1
    bl      set_gpio_fun
    .unreq  pin_num
    .unreq  pin_fun

loop: /* Turn on LED */
    pin_num .req r0
    pin_val .req r1
    mov     pin_num, #16
    mov     pin_val, #0
    bl      set_gpio
    .unreq  pin_num
    .unreq  pin_val

    index   .req r2
    mov     index, #0x3F0000
delay1:
    sub     index, #1
    cmp     index, #0
    bne     delay1
    .unreq  index

    /* Turn off LED */
    pin_num .req r0
    pin_val .req r1
    mov     pin_num, #16
    mov     pin_val, #1
    bl      set_gpio
    .unreq  pin_num
    .unreq  pin_val

    index   .req r2
    mov     index, #0x3F0000
delay2:
    sub     index, #1
    cmp     index, #0
    bne     delay2
    .unreq  index

    b loop

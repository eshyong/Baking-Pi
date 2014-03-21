.globl get_gpio_addr
get_gpio_addr:
    ldr r0, =0x20200000
    mov pc, lr

.globl set_gpio_fun
set_gpio_fun:
/* This expression is equivalent to:
 * if (r0 > 53 || r1 > 7) return;
 */
    cmp   r0, #53
    cmpls r1, #7
    movhi pc, lr /* Returns */

    push  { lr } /* Store the value of link register */
    mov   r2, r0 /* Store value of r0 (so get_gpio_addr doesn't overwrite it) */
    bl    get_gpio_addr /* Call to get_gpio_addr */

fun_loop: /* Function loop */
    cmp   r2, #9
    subhi r2, #10
    addhi r0, #4
    bhi   fun_loop

    add   r2, r2, lsl #1
    lsl   r1, r2
    str   r1, [r0]
    pop   { pc }

.globl set_gpio
set_gpio:
    pin_num   .req r0
    pin_val   .req r1

    cmp       pin_num, #53
    movhi     pc, lr
    push      { lr }
    mov       r2, pin_num
    .unreq    pin_num
    pin_num   .req r2
    bl        get_gpio_addr
    gpio_addr .req r0

    pin_bank  .req r3
    lsr       pin_bank, pin_num, #5
    lsl       pin_bank, #2
    add       gpio_addr, pin_bank
    .unreq    pin_bank

    and       pin_num, #31
    set_bit   .req r3
    mov       set_bit, #1
    lsl       set_bit, pin_num
    .unreq    pin_num

    teq       pin_val, #0
    .unreq    pin_val
    streq     set_bit, [gpio_addr, #40]
    strne     set_bit, [gpio_addr, #28]
    .unreq    set_bit
    .unreq    gpio_addr
    pop       { pc }

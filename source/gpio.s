/* Loads address of GPIO controller into r0 */
.globl get_gpio_addr
get_gpio_addr:
    ldr r0, =0x20200000
    mov pc, lr

/* This function accepts a pin number and function number as input
 * and enables the pin functionality
 */
.globl set_gpio_fun
set_gpio_fun:
/* This expression is equivalent to:
 * if (r0 > 53 || r1 > 7) return;
 */
    cmp   r0, #53 /* Check pin number <= 53 */
    cmpls r1, #7 /* Check function number <= 7 */
    movhi pc, lr /* Returns */

    push  {lr} /* Store the value of link register */
    mov   r2, r0 /* Store value of pin number */
    bl    get_gpio_addr

fun_loop: /* Function loop */
/* GPIO pins are packed into increments of 4 bytes, each of which
 * holds 10 pins, which are further subdivided into 3 bits per pin.
 * So to find pin 16, we must increment the GPIO address by 4 bytes, 
 * and then increment by 6 x 3 bits (18) to get the correct pin number.
 */
    cmp   r2, #9 /* Original pin number */
    subhi r2, #10 /* Decrement by 10 each time, this
                   * will become pin number modulo 10
                   */
    addhi r0, #4 /* Increment by 4 bytes */
    bhi   fun_loop

    add   r2, r2, lsl #1 /* Remainder *= 3 */
    lsl   r1, r2 /* Shift function number by pin number */
    str   r1, [r0] /* Store this into GPIO pin address */
    pop   {pc} /* Pop return value from stack */

.globl set_gpio
set_gpio:
    pin_num   .req r0 /* Pin number */
    pin_val   .req r1 /* Pin value */

    cmp       pin_num, #53 /* if (pin_num > 53) return; */
    movhi     pc, lr
    push      {lr} /* Push link register on the stack */
    mov       r2, pin_num /* Prevent pin number from being overridden */
    .unreq    pin_num
    pin_num   .req r2 /* New register alias */
    bl        get_gpio_addr 
    gpio_addr .req r0

    pin_bank  .req r3
    lsr       pin_bank, pin_num, #5 /* Divide by 32 */
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
    pop       {pc}

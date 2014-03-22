/* Loads r0 with the address of the system timer */
.globl get_timer_addr
get_timer_addr:
    ldr r0, =0x20003000
    mov pc, lr

/* Waits for a period of time, then returns.
 * Takes in a time period to wait, and decrements
 * until time is reached.
 */
.globl wait
wait:
    push         {lr} /* Push link register onto stack */
    mov          r3, r0 /* Move r0 so it doesn't get overridden */
    wait_time    .req r3
    bl           get_timer_addr
    timer_addr   .req r0
    initial_time .req r1
    delta        .req r2
    ldr          initial_time, [timer_addr]

loop:
    ldr delta, [timer_addr]
    sub delta, initial_time
    cmp delta, wait_time
    blo loop

    .unreq timer_addr
    .unreq initial_time
    .unreq delta
    pop {pc}

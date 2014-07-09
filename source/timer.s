.globl get_timer_address
.globl get_time_stamp
.globl wait


get_timer_address:
    ldr     r0, =0x20003000
    mov     pc, lr

get_time_stamp:
    push    {lr}
    bl      get_timer_address
    ldrd    r0, r1, [r0, #4]
    pop     {pc}

wait:
    push    {lr}
    elapsed .req r1
    delay   .req r2
    start   .req r3
    mov     delay, r0
    bl      get_time_stamp
    mov     start, r0

loop:
    bl      get_time_stamp
    sub     elapsed, r0, start
    cmp     elapsed, delay
    bls     loop

    .unreq  elapsed
    .unreq  delay
    .unreq  start
    pop     {pc}

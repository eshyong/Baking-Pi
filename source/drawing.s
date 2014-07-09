.section .data
.align 1
forecolour:
.hword 0xFFFF

.align 2
graphics_addr:
.int 0

.section .text
.globl set_forecolour
set_forecolour:
    # Check that r0 < 256
    cmp r0, #0x10000
    movhs pc, lr

    # Store halfword of r0 into forecolour. This is extended to 32 bits
    # on loads. ?
    ldr r1, =forecolour
    strh r0, [r1]
    mov pc, lr

.globl set_graphics_addr
set_graphics_addr:
    ldr r1, =graphics_addr
    str r0, [r1]
    mov pc, lr

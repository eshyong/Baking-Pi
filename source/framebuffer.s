.section .data
.align 12 
.globl frame_buffer_info
frame_buffer_info:
    .int 1024
    .int 768
    .int 1024
    .int 768
    .int 0 
    .int 16
    .int 0
    .int 0
    .int 0
    .int 0

.section .text
.globl initialize_frame_buffer
initialize_frame_buffer:
    width       .req r0
    height      .req r1
    bit_depth   .req r2
    cmp         width, #4096
    cmpls       height, #4096
    cmpls       bit_depth, #32
    result      .req r0
    movhi       result, #0
    movhi       pc, lr

    fb_info_addr    .req r4
    push            {r4, lr}
    ldr             fb_info_addr, =frame_buffer_info
    str             width, [r4, #0]
    str             height, [r4, #4]
    str             width, [r4, #8]
    str             height, [r4, #12]
    str             bit_depth, [r4, #20]
    .unreq          width
    .unreq          height
    .unreq          bit_depth
    mov             r0, fb_info_addr
    add             r0, #0x40000000
    mov             r1, #1
    bl              mailbox_write
    mov             r0, #1
    bl              mailbox_read
    teq             result, #0
    movne           result, #0
    popne           {r4, pc}
    mov             result, fb_info_addr
    pop             {r4, pc}
    .unreq          result
    .unreq          fb_info_addr

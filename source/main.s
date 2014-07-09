.section .init
.globl _start
_start:
    b main

.section .text
main:
    mov     sp, #0x8000

    mov     r0, #1024
    mov     r1, #768
    mov     r2, #16
    bl      initialize_frame_buffer

    teq     r0, #0
    bne     no_error

    mov     r0, #16
    mov     r1, #1
    bl      set_gpio_function
    mov     r0, #16
    mov     r1, #0
    bl      set_gpio

error:
    b error

no_error:
    fb_info_addr    .req r4
    mov             fb_info_addr, r0

render:
    fb_addr .req r3
    ldr     fb_addr, [fb_info_addr, #32]
    colour  .req r0
    y       .req r1
    mov     y, #768
    draw_row:
        x   .req r2
        mov x, #1024
        draw_pixel:
            strh    colour, [fb_addr]
            add     fb_addr, #2
            sub     x, #1
            teq     x, #0
            bne     draw_pixel
        
        sub     y, #1
        add     colour, #1
        teq     y, #0
        bne     draw_row

    b render

.unreq fb_addr
.unreq fb_info_addr

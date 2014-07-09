# Extern function declarations: these make functions visible to any other assembly
# files.
.globl get_gpio_address
.globl set_gpio_function
.globl set_gpio

# Returns the address of the GPIO controller in r0.
get_gpio_address:
    ldr r0, =0x20200000
    mov pc, lr

# Sets the GPIO function.
set_gpio_function:
    # Make sure inputs are valid: r0 is a pin from 0 to 53, and r1 is an input
    # function from 0 to 7.
    cmp     r0, #53
    cmpls   r1, #7
    movhi   pc, lr

    # Save return address on the stack, and save r0 in r2.
    # r0 contains GPIO controller address at the end of this call.
    push    {lr}
    mov     r2, r0
    bl      get_gpio_address

# We want to get the block of 4 bytes with the correct pin. Pins are grouped
# in 10s, which correspond to 4 bytes on the GPIO controller.
get_pin_loop:
    cmp     r2, #9
    subhi   r2, #10
    addhi   r0, #4
    bhi     get_pin_loop

    # Multiply r2 by 3 (r2 += r2 << 1) to get the position of the pin.
    lsl r3, r2, #1
    add r2, r3
    lsl r1, r2
    str r1, [r0]
    pop {pc}

# A function that sets a value for the GPIO pin.
set_gpio:
    pin_num .req r0
    pin_val .req r1

    # Return from function if pin number is too high.
    cmp         pin_num, #53
    movhi       pc, lr
    push        {lr}
    mov         r2, pin_num
    .unreq      pin_num
    pin_num     .req r2

    # Get gpio address of the pin number.
    bl          get_gpio_address
    gpio_addr   .req r0
    pin_bank    .req r3

    # Divide pin number by 32, then multiply by four. This will
    # give us the pin bank we want.
    lsr         pin_bank, pin_num, #5
    lsl         pin_bank, #2
    add         gpio_addr, pin_bank
    .unreq      pin_bank

    # Get the lower 5 bits of pin_num, then move pin_num into set_bit.
    and         pin_num, #31
    set_bit     .req r3
    mov         set_bit, #1
    lsl         set_bit, pin_num
    .unreq      pin_num

    # Turn off pin if pin_val is 0, otherwise turn it on.
    # Confusingly, this corresponds to turning the LED off when (val=0)
    # and on when (val=1). The bit address corresponds to #40 and #28,
    # for pin off/pin on, respectively.
    teq         pin_val, #0
    .unreq      pin_val
    streq       set_bit, [gpio_addr, #40]
    strne       set_bit, [gpio_addr, #28]
    .unreq      set_bit
    .unreq      gpio_addr
    pop         {pc}

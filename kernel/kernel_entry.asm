bits 64

global kernel_entry
extern kernel_main

section .text

kernel_entry:

    ; Set kernel stack
    mov rsp, 0x90000

    ; Call C kernel
    call kernel_main

.hang:
    cli
    hlt
    jmp .hang
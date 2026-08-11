bits 16
org 0x1000

start:
    mov si, message

print:
    lodsb
    cmp al, 0
    je hang

    mov ah, 0x0E
    mov bh, 0x00
    int 0x10

    jmp print

hang:
    cli
    hlt
    jmp hang

message db 'Stage 2 loaded successfully!', 0
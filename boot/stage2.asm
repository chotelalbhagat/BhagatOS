bits 16
org 0x1000

start:

    ; --------------------------------------------------
    ; 16-bit Real Mode
    ; --------------------------------------------------

    cli

    xor ax, ax
    mov ds, ax
    mov es, ax

    mov si, msg_stage2
    call print16


    ; --------------------------------------------------
    ; Enable A20 Line
    ; --------------------------------------------------

    in al, 0x92
    or al, 00000010b
    out 0x92, al


    ; --------------------------------------------------
    ; Load Global Descriptor Table
    ; --------------------------------------------------

    lgdt [gdt_descriptor]


    ; --------------------------------------------------
    ; Enable Protected Mode
    ; --------------------------------------------------

    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax


    ; --------------------------------------------------
    ; Far jump into 32-bit Protected Mode
    ; --------------------------------------------------

    jmp 0x08:protected_mode


; ======================================================
; 16-bit print function
; ======================================================

print16:

    lodsb

    cmp al, 0
    je .done

    mov ah, 0x0E
    mov bh, 0x00
    int 0x10

    jmp print16

.done:
    ret


; ======================================================
; 32-bit Protected Mode
; ======================================================

bits 32

protected_mode:

    ; Load data segment selector
    mov ax, 0x10

    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set 32-bit stack
    mov esp, 0x90000


    ; Clear screen
    mov edi, 0xB8000
    mov ecx, 80 * 25

    mov ax, 0x0720

.clear_screen:
    mov word [edi], ax
    add edi, 2
    loop .clear_screen


    ; Print message
    mov esi, msg_protected

    mov edi, 0xB8000

.print:

    lodsb

    cmp al, 0
    je .done

    mov ah, 0x07
    mov [edi], ax

    add edi, 2

    jmp .print

.done:

    cli

.hang:
    hlt
    jmp .hang


; ======================================================
; Global Descriptor Table
; ======================================================

bits 16

gdt_start:

    ; --------------------------------------------------
    ; Null descriptor
    ; --------------------------------------------------

    dq 0x0000000000000000


    ; --------------------------------------------------
    ; Code segment
    ; Base = 0
    ; Limit = 4 GB
    ; 32-bit code
    ; --------------------------------------------------

    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00


    ; --------------------------------------------------
    ; Data segment
    ; Base = 0
    ; Limit = 4 GB
    ; --------------------------------------------------

    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00


gdt_end:


gdt_descriptor:

    dw gdt_end - gdt_start - 1
    dd gdt_start


; ======================================================
; Messages
; ======================================================

msg_stage2 db 'Stage 2 loaded successfully!', 0

msg_protected db 'BHAGAT OS - 32-bit Protected Mode OK!', 0
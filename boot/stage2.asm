bits 16
org 0x1000

start:

    cli

    ; --------------------------------------------------
    ; Real Mode
    ; --------------------------------------------------

    xor ax, ax
    mov ds, ax
    mov es, ax

    mov si, msg_stage2
    call print16


    ; --------------------------------------------------
    ; Enable A20
    ; --------------------------------------------------

    in al, 0x92
    or al, 00000010b
    out 0x92, al


    ; --------------------------------------------------
    ; Load GDT
    ; --------------------------------------------------

    lgdt [gdt_descriptor]


    ; --------------------------------------------------
    ; Enter Protected Mode
    ; --------------------------------------------------

    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    jmp 0x08:protected_mode


; ======================================================
; 16-bit printing
; ======================================================

print16:

    lodsb

    cmp al, 0
    je .done

    mov ah, 0x0E
    mov bh, 0
    int 0x10

    jmp print16

.done:
    ret


; ======================================================
; 32-bit Protected Mode
; ======================================================

bits 32

protected_mode:

    cld

    mov ax, 0x10

    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000


    ; --------------------------------------------------
    ; Clear screen
    ; --------------------------------------------------

    mov edi, 0xB8000
    mov ecx, 80 * 25

    mov ax, 0x0720

.clear:

    mov word [edi], ax
    add edi, 2

    loop .clear


    ; --------------------------------------------------
    ; Print Protected Mode message
    ; --------------------------------------------------

    mov esi, msg_protected

    mov edi, 0xB8000

.print_protected:

    lodsb

    cmp al, 0
    je .protected_done

    mov ah, 0x07

    mov [edi], ax

    add edi, 2

    jmp .print_protected


.protected_done:

    ; --------------------------------------------------
    ; Protected Mode test
    ; --------------------------------------------------

    mov edi, 0xB8000

    mov esi, msg_protected_test


.print_test:

    lodsb

    cmp al, 0

    je .test_done

    mov ah, 0x0F

    mov [edi], ax

    add edi, 2

    jmp .print_test


.test_done:

    cli

.hang:

    hlt

    jmp .hang


; ======================================================
; Setup Page Tables
; ======================================================

setup_page_tables:

    ; --------------------------------------------------
    ; PML4
    ; --------------------------------------------------

    mov edi, pml4_table

    xor eax, eax

    mov ecx, 4096 / 4

    rep stosd


    ; --------------------------------------------------
    ; PDPT
    ; --------------------------------------------------

    mov edi, pdpt_table

    xor eax, eax

    mov ecx, 4096 / 4

    rep stosd


    ; --------------------------------------------------
    ; Page Directory
    ; --------------------------------------------------

    mov edi, pd_table

    xor eax, eax

    mov ecx, 4096 / 4

    rep stosd


    ; --------------------------------------------------
    ; PML4[0] → PDPT
    ; --------------------------------------------------

    mov eax, pdpt_table

    or eax, 0x03

    mov [pml4_table], eax


    ; --------------------------------------------------
    ; PDPT[0] → Page Directory
    ; --------------------------------------------------

    mov eax, pd_table

    or eax, 0x03

    mov [pdpt_table], eax


    ; --------------------------------------------------
    ; Map first 2 MB using a 2 MB page
    ; --------------------------------------------------

    mov eax, 0x00000083

    mov [pd_table], eax


    ret


; ======================================================
; 64-bit Long Mode
; ======================================================

bits 64

long_mode:

    ; --------------------------------------------------
    ; Load 64-bit data segments
    ; --------------------------------------------------

    mov ax, 0x20

    mov ds, ax
    mov es, ax
    mov ss, ax


    ; --------------------------------------------------
    ; Set stack
    ; --------------------------------------------------

    mov rsp, 0x90000


    ; --------------------------------------------------
    ; Print message directly to VGA memory
    ; --------------------------------------------------

    mov rdi, 0xB8000

    mov rsi, msg_long_mode


.print64:

    lodsb

    test al, al

    jz .done64

    mov ah, 0x0F

    mov [rdi], ax

    add rdi, 2

    jmp .print64


.done64:

    cli

.hang:

    hlt

    jmp .hang


; ======================================================
; GDT
; ======================================================

bits 16

gdt_start:

    ; Null descriptor

    dq 0


    ; --------------------------------------------------
    ; 32-bit Code
    ; --------------------------------------------------

    dw 0xFFFF
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0


    ; --------------------------------------------------
    ; 32-bit Data
    ; --------------------------------------------------

    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0


    ; --------------------------------------------------
    ; 64-bit Code
    ; --------------------------------------------------

    dw 0
    dw 0
    db 0

    db 10011010b

    db 00100000b

    db 0


    ; --------------------------------------------------
    ; 64-bit Data
    ; --------------------------------------------------

    dw 0
    dw 0
    db 0

    db 10010010b

    db 00000000b

    db 0


gdt_end:


gdt_descriptor:

    dw gdt_end - gdt_start - 1

    dd gdt_start


; ======================================================
; Page Tables
; ======================================================

align 4096

pml4_table:

    times 4096 db 0


pdpt_table:

    times 4096 db 0


pd_table:

    times 4096 db 0


; ======================================================
; Messages
; ======================================================

msg_stage2:

    db 'Stage 2 loaded successfully!', 0


msg_protected:

    db '32-bit Protected Mode OK!', 0


msg_protected_test:

    db 'BHAGAT OS - PROTECTED MODE TEST OK!', 0


msg_long_mode:

    db 'BHAGAT OS - 64-BIT LONG MODE OK!', 0
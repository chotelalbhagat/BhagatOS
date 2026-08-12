bits 16
org 0x7C00

start:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    sti

    ; Save BIOS boot drive
    mov [boot_drive], dl

    ; --------------------------------------------------
    ; Show loading message
    ; --------------------------------------------------

    mov si, loading_message
    call print_string


    ; --------------------------------------------------
    ; Check INT 13h Extensions
    ; --------------------------------------------------

    mov dl, [boot_drive]

    mov ah, 0x41
    mov bx, 0x55AA

    int 0x13

    jc disk_error

    cmp bx, 0xAA55
    jne disk_error


    ; --------------------------------------------------
    ; Load Stage 2 using LBA
    ;
    ; Stage 2 begins at LBA 1
    ; Load 33 sectors
    ;
    ; Destination:
    ; 0000:1000
    ; --------------------------------------------------

    mov si, dap

    mov ah, 0x42
    mov dl, [boot_drive]

    int 0x13

    jc disk_error


    ; --------------------------------------------------
    ; Stage 2 successfully loaded
    ; --------------------------------------------------

    mov si, loaded_message
    call print_string

    jmp 0x0000:0x1000


; ======================================================
; Print string
; ======================================================

print_string:

    lodsb

    cmp al, 0
    je .done

    mov ah, 0x0E
    mov bh, 0x00

    int 0x10

    jmp print_string

.done:

    ret


; ======================================================
; Disk error
; ======================================================

disk_error:

    mov si, error_message
    call print_string

    cli

.hang:

    hlt
    jmp .hang


; ======================================================
; Disk Address Packet
; ======================================================

dap:

    db 0x10             ; Packet size
    db 0x00             ; Reserved

    dw 33               ; Number of sectors

    dw 0x1000           ; Offset

    dw 0x0000           ; Segment

    dq 1                ; Starting LBA


; ======================================================
; Variables
; ======================================================

boot_drive:

    db 0


; ======================================================
; Messages
; ======================================================

loading_message:

    db 'Loading BhagatOS stage 2...', 0

loaded_message:

    db ' Stage 2 loaded successfully!', 0

error_message:

    db ' Disk read error!', 0


; ======================================================
; Boot signature
; ======================================================

times 510-($-$$) db 0

dw 0xAA55
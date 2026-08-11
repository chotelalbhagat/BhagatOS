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

    mov [boot_drive], dl

    mov si, loading_message
    call print_string

    ; Read stage 2 from disk
    mov ah, 0x02
    mov al, 4
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]
    mov bx, 0x1000

    int 0x13

    jc disk_error

    jmp 0x0000:0x1000


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


disk_error:
    mov si, error_message
    call print_string

    cli
    hlt

    jmp $


boot_drive db 0

loading_message db 'Loading BhagatOS stage 2...', 0
error_message   db 'Disk read error!', 0

times 510-($-$$) db 0
dw 0xAA55
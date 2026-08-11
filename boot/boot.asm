bits 16
org 0x7C00

start:

    cli

    ; --------------------------------------------------
    ; Setup segments and stack
    ; --------------------------------------------------

    xor ax, ax

    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7C00

    sti


    ; --------------------------------------------------
    ; Save BIOS boot drive
    ; --------------------------------------------------

    mov [boot_drive], dl


    ; --------------------------------------------------
    ; Display loading message
    ; --------------------------------------------------

    mov si, loading_message

    call print_string


    ; --------------------------------------------------
    ; Prepare disk reading
    ;
    ; Stage 2 size:
    ; 16,472 bytes
    ;
    ; Required:
    ; 33 sectors
    ;
    ; Start:
    ; Cylinder 0
    ; Head 0
    ; Sector 2
    ; --------------------------------------------------

    mov byte [sectors_remaining], 33

    mov byte [current_sector], 2

    mov byte [current_head], 0

    mov byte [current_cylinder], 0

    mov bx, 0x1000


; ======================================================
; Read Stage 2
; ======================================================

read_next_sector:

    ; --------------------------------------------------
    ; BIOS disk read
    ; Read exactly ONE sector
    ; --------------------------------------------------

    mov ah, 0x02

    mov al, 1

    mov ch, [current_cylinder]

    mov cl, [current_sector]

    mov dh, [current_head]

    mov dl, [boot_drive]

    int 0x13

    jc disk_error


    ; --------------------------------------------------
    ; Move memory buffer forward by 512 bytes
    ; --------------------------------------------------

    add bx, 512


    ; --------------------------------------------------
    ; One more sector loaded
    ; --------------------------------------------------

    dec byte [sectors_remaining]

    jz stage2_loaded


    ; --------------------------------------------------
    ; Move to next sector
    ; --------------------------------------------------

    inc byte [current_sector]


    ; --------------------------------------------------
    ; Floppy disk has 18 sectors per track
    ; --------------------------------------------------

    cmp byte [current_sector], 19

    jne read_next_sector


    ; --------------------------------------------------
    ; Move to next head
    ; --------------------------------------------------

    mov byte [current_sector], 1

    inc byte [current_head]


    ; --------------------------------------------------
    ; If both heads used, move to next cylinder
    ; --------------------------------------------------

    cmp byte [current_head], 2

    jne read_next_sector


    mov byte [current_head], 0

    inc byte [current_cylinder]

    jmp read_next_sector


; ======================================================
; Stage 2 loaded
; ======================================================

stage2_loaded:

    ; Jump to Stage 2
    jmp 0x0000:0x1000


; ======================================================
; Print string using BIOS
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
; Variables
; ======================================================

boot_drive:

    db 0


sectors_remaining:

    db 0


current_sector:

    db 0


current_head:

    db 0


current_cylinder:

    db 0


; ======================================================
; Messages
; ======================================================

loading_message:

    db 'Loading BhagatOS stage 2...', 0


loaded_message:

    db 'STAGE 2 LOADED!', 0


error_message:

    db 'Disk read error!', 0


; ======================================================
; Boot sector signature
; ======================================================

times 510-($-$$) db 0

dw 0xAA55
bits 16
org 0x8000       ; Memory Location 0x8000 for MyName Game Logic

start:
    ; Initialize registers (optional, for testing purposes)
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00   ; Set up stack pointer

    ; Dummy code: Infinite loop
dummy_loop:
    nop             ; No operation (placeholder instruction)
    jmp dummy_loop  ; Infinite loop to keep the CPU busy

    ; End of dummy code

times 510-($-$$) db 0  ; Fill remaining space with zeros

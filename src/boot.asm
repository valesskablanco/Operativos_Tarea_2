bits 16                 ; 16-bit mode (real mode)
org 0x7c00              ; Origin point for the boot loader (Memory location 0x7c00)
%define SECTOR_AMOUNT 0x4  ; Define the number of sectors to read

jmp start               ; Jump to the start label

start:
; Initializing segment registers and stack pointer
cli                     ; Clear interrupts (disable them temporarily)
xor ax, ax              ; Zero out AX register
mov ds, ax              ; Set Data Segment (DS) to 0x0000
mov ss, ax              ; Set Stack Segment (SS) to 0x0000
mov es, ax              ; Set Extra Segment (ES) to 0x0000
mov fs, ax              ; Set FS segment to 0x0000
mov gs, ax              ; Set GS segment to 0x0000
mov sp, 0x6ef0          ; Set Stack Pointer (SP) to 0x6ef0 (somewhere safe in memory)
sti                     ; Enable interrupts

; Print welcome message
call print_welcome_message  ; Call subroutine to print the welcome message

; Wait for a key press before proceeding
call wait_for_key_press     ; Call subroutine to wait for a key press

; Reset the disk system
mov ah, 0                ; Function 0 of INT 0x13 (Reset Disk System)
int 0x13                 ; Call BIOS Disk Service to reset the disk system

; Read SECTOR_AMOUNT sectors from the hard drive into memory
mov bx, 0x8000           ; Set BX to 0x8000, the memory address where the sectors will be loaded
mov al, SECTOR_AMOUNT    ; AL holds the number of sectors to read (SECTOR_AMOUNT)
mov ch, 0                ; Cylinder number (high byte, CH) = 0
mov dh, 0                ; Head number (DH) = 0
mov cl, 2                ; Sector number (CL) = 2 (sector numbers start at 1)
mov ah, 2                ; Function 2 of INT 0x13 (Read Sectors From Drive)
int 0x13                 ; Call BIOS Disk Service to read sectors
jmp 0x8000               ; Jump to the loaded code at memory address 0x8000

; Print welcome message subroutine
print_welcome_message:
mov si, welcome_msg      ; Load the address of the welcome message into Source Index (SI)
call print_string        ; Call subroutine to print the string pointed to by SI
ret                      ; Return from subroutine to caller

; Waiting for a key press subroutine
wait_for_key_press:
xor ax, ax               ; Clear AX register (set to 0)
int 0x16                 ; BIOS interrupt to wait for a key press
ret                      ; Return from subroutine to caller

; Printing string subroutine
print_string:
mov ah, 0x0E             ; BIOS teletype function (print character) in AH
.print_next:
lodsb                    ; Load next byte from [SI] into AL, SI is automatically incremented
cmp al, 0                ; Compare AL with 0 (end of string indicator)
je .done                 ; If AL is 0, jump to done (end of string)
int 0x10                 ; BIOS interrupt to print the character in AL
jmp .print_next          ; Loop to print the next character
.done:
ret                      ; Return from subroutine to caller

; Data: Welcome message
welcome_msg db 'Welcome to My Name! Press any key to start the game!', 0  ; Define a string and terminate it with 0

; Padding and Boot Signature
times 510-($-$$) db 0   ; Fill the rest of the 512-byte boot sector with zeros
db 0x55                 ; Boot signature byte 1
db 0xaa                 ; Boot signature byte 2 (0xAA55 indicates a valid boot sector)

bits 16
org 0x7c00 ; Memory Location 0x7c00 for Boot Loader
%define SECTOR_AMOUNT 0x4
jmp start

start:
; Initializing registers
cli
xor ax, ax
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax
mov sp, 0x6ef0

; Display welcome message
call print_welcome_message

; Read from hard drive and write to RAM
mov ah, 0x02         ; BIOS read sectors function
mov al, SECTOR_AMOUNT ; Number of sectors to read
mov ch, 0            ; Cylinder number
mov dh, 0            ; Head number
mov cl, 2            ; Starting sector number (usually starts at 2 for MBR)
mov bx, 0x8000       ; ES:BX points to the memory address where data is to be loaded
mov es, bx
xor bx, bx           ; Clear BX
int 0x13             ; Call BIOS interrupt to read sectors

; Jump to loaded code at 0x8000
jmp 0x8000

; Print welcome message subroutine
print_welcome_message:
mov si, welcome_msg  ; Load the address of the message into SI
call print_string    ; Call print_string to display the message
ret                  ; Return to the caller

; Printing functionality
print_string:
mov ah, 0x0E         ; BIOS teletype function (print character)
.print_next:
lodsb                ; Load the next byte at [SI] into AL
cmp al, 0            ; Check if we've reached the end of the string
je .done             ; If so, jump to .done
int 0x10             ; BIOS interrupt to print character in AL
jmp .print_next      ; Loop to print the next character
.done:
ret                  ; Return to the caller

welcome_msg db 'Welcome to My Name!', 0

; Padding and Signature
times 510-($-$$) db 0 ; Fill remaining space with zeros
db 0x55
db 0xaa ; Magic number (boot loader identifier)
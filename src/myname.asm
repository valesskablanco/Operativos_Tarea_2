bits 16
org 0x8000       ; Memory Location 0x8000 for MyName Game Logic
jmp start;

%define WHITE 15 ; white color for pixels
%define BLACK 0
%define START_X 100 ; starting x position
%define START_Y 100 ; starting y position
%define LETTER_WIDTH 3
%define DEGREES 4

start:
    cli ; clr all interrumpts
    push 0xA000 ; video memory graphics segment
    pop es ; extra segments from stack pop them
    xor di, di ; set register to 0
    xor ax, ax ; set register to 0
    mov ax, 0x13 ; 320x200 resolution 4 colors mode
    int 0x10 ; video interrumpt


start_loop:
    call start_message

    mov si, 0 ; Init mirror register counter
    mov bx, 0 ; Init degrees register counter

    mov ah, 0      ; Set up for keyboard input
    int 16h        ; BIOS interrupt for keyboard input

    cmp ah, 1Ch    ; Enter key
    je print_game

    jmp start_loop

print_game:
    call clear_screen

    jmp write_names_by_key

game_loop:

    mov ah, 01h    ; Check for keystroke
    int 16h        ; BIOS interrupt to check for keystroke

    jz game_loop      ; Jump if no key is available

    mov ah, 0      ; Set up for keyboard input
    int 16h        ; BIOS interrupt for keyboard input
    
    cmp ah, 01h    ; ESC key
    je finish_game

    cmp ah, 48h    ; Up arrow key
    je mirror_up
    
    cmp ah, 50h    ; Down arrow key
    je mirror_down
    
    cmp ah, 4Bh    ; Left arrow key
    je rotate_left
    
    cmp ah, 4Dh    ; Right arrow key
    je rotate_right

    ; If no arrow key was pressed, go back to start of the loop
    jmp game_loop


rotate_left:
    mov si, 0
    add bx, 1     ; Add 90 degrees when left arrow is pressed
    cmp bx, DEGREES
    jl skip_reset  ; Skip reset if under 360 degrees
    sub bx, DEGREES  ; Reset rotation if over 360

    jmp skip_reset

rotate_right:
    mov si, 0
    sub bx, 1     ; Subtract 90 degrees when right arrow is pressed
    cmp bx, 0
    jge skip_reset ; Skip reset if degrees >= 0
    add bx, DEGREES   ; Reset to 360 if negative

    jmp skip_reset

mirror_up:
    mov si, 1
    mov bx, 0
    jmp skip_reset

mirror_down:
    mov si, 1
    mov bx, 1  
    jmp skip_reset

skip_reset:
    call clearkeyboardbuffer
    jmp print_game

write_names_by_key:

    cmp si, 0
    je write_names_by_rotation      ; Plot with rotation
    
    cmp si, 1
    je write_names_by_mirroring     ; Plot with mirroring

write_names_by_rotation:

    cmp bx, 0
    je write_names_0      ; Plot with 0-degree rotation
    
    cmp bx, 1
    je write_names_90     ; Plot with 90-degree rotation

    cmp bx, 2
    je write_names_180     ; Plot with 180-degree rotation

    cmp bx, 3
    je write_names_270     ; Plot with 270-degree rotation

write_names_by_mirroring:
    cmp bx, 0
    je write_names_up      ; Plot with mirroring up
    
    cmp bx, 1
    je write_names_down     ; Plot with mirroring down


write_names_0:
    mov ah, 0xc ; write pixel
    mov al, WHITE ; color WHITE
    mov bh, 0x00 ; let page to 0
    mov cx, START_X ; x position
    mov dx, START_Y ; y position

    call plot_V_0

    jmp game_loop

write_names_90:
    mov ah, 0xc ; write pixel
    mov al, WHITE ; color WHITE
    mov bh, 0x00 ; let page to 0
    mov cx, START_X ; x position
    mov dx, START_Y ; y position

    call plot_V_90

    jmp game_loop

write_names_180:
    mov ah, 0xc ; write pixel
    mov al, WHITE ; color WHITE
    mov bh, 0x00 ; let page to 0
    mov cx, START_X ; x position
    mov dx, START_Y ; y position

    call plot_V_180

    jmp game_loop

write_names_270:
    mov ah, 0xc ; write pixel
    mov al, WHITE ; color WHITE
    mov bh, 0x00 ; let page to 0
    mov cx, START_X ; x position
    mov dx, START_Y ; y position

    call plot_V_270

    jmp game_loop

write_names_up:
    mov ah, 0xc ; write pixel
    mov al, WHITE ; color WHITE
    mov bh, 0x00 ; let page to 0
    mov cx, START_X ; x position
    mov dx, START_Y ; y position

    call plot_A

    jmp game_loop

write_names_down:    
    mov ah, 0xc ; write pixel
    mov al, WHITE ; color WHITE
    mov bh, 0x00 ; let page to 0
    mov cx, START_X ; x position
    mov dx, START_Y ; y position

    call plot_L

    jmp game_loop


plot_V_0:
    ; Plotting points for 'V'
    call plot_pixel
    inc cx
    inc dx
    call plot_pixel
    inc cx
    inc dx
    call plot_pixel
    inc cx
    inc dx
    call plot_pixel
    inc cx
    inc dx
    call plot_pixel
    inc cx
    dec dx
    call plot_pixel
    inc cx
    dec dx
    call plot_pixel 
    inc cx
    dec dx
    call plot_pixel 
    inc cx
    dec dx
    call plot_pixel 
    ret

plot_V_90:
    ; Plotting points for 'V'
    call plot_pixel
    inc cx
    dec dx
    call plot_pixel
    inc cx
    dec dx
    call plot_pixel
    inc cx
    dec dx
    call plot_pixel
    inc cx
    dec dx
    call plot_pixel
    dec cx
    dec dx
    call plot_pixel
    dec cx
    dec dx
    call plot_pixel 
    dec cx
    dec dx
    call plot_pixel 
    dec cx
    dec dx
    call plot_pixel 
    ret

plot_V_180:
    ; Plotting points for 'V'
    call plot_pixel
    dec cx
    dec dx
    call plot_pixel
    dec cx
    dec dx
    call plot_pixel
    dec cx
    dec dx
    call plot_pixel
    dec cx
    dec dx
    call plot_pixel
    dec cx
    inc dx
    call plot_pixel
    dec cx
    inc dx
    call plot_pixel 
    dec cx
    inc dx
    call plot_pixel 
    dec cx
    inc dx
    call plot_pixel 
    ret

plot_V_270:
    ; Plotting points for 'V'
    call plot_pixel
    dec cx
    inc dx
    call plot_pixel
    dec cx
    inc dx
    call plot_pixel
    dec cx
    inc dx
    call plot_pixel
    dec cx
    inc dx
    call plot_pixel
    inc cx
    inc dx
    call plot_pixel
    inc cx
    inc dx
    call plot_pixel 
    inc cx
    inc dx
    call plot_pixel 
    inc cx
    inc dx
    call plot_pixel 
    ret

plot_A:
    ; Plotting points for 'A'
    add dx, 4
    call plot_pixel 
    inc cx
    dec dx
    call plot_pixel  
    inc cx
    dec dx
    call plot_pixel
    inc cx
    call plot_pixel  
    inc cx
    call plot_pixel  
    inc cx
    call plot_pixel  
    sub cx, 2
    dec dx
    call plot_pixel  
    inc cx
    dec dx
    call plot_pixel  
    inc cx
    inc dx
    call plot_pixel 
    inc cx
    inc dx
    call plot_pixel 
    inc cx
    inc dx
    call plot_pixel 
    inc cx
    inc dx
    call plot_pixel 
    ret

plot_L:
    call plot_pixel
    inc dx
    call plot_pixel
    inc dx
    call plot_pixel
    inc dx
    call plot_pixel
    inc dx
    call plot_pixel
    inc cx
    call plot_pixel
    inc cx
    call plot_pixel
    inc cx
    call plot_pixel
    inc cx
    call plot_pixel
    ret

plot_pixel:
    int 0x10 ; video interrupt
    ret

clearkeyboardbuffer:
    mov ah,0ch
    mov al,0
    int 21h
    ret

start_message:
    mov ah, 0x2       ; BIOS.SetCursorPosition
    mov bh, 0         ; page 0
    mov dh, 11 
    mov dl, 14 
    int 0x10

write_message:
    mov bl, WHITE
    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al,'S'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'T'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'A'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'R'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'T'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al,' '    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'G'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'A'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'M'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'E'    ; Point SI to the start of the string
    int 0x10


    mov ah, 0x2       ; BIOS.SetCursorPosition
    mov bh, 0         ; page 0
    add dh, 2
    int 0x10

    mov bl, WHITE
    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'P'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'R'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'E'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'S'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'S'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, ' '    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'E'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'N'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'T'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'E'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'R'    ; Point SI to the start of the string
    int 0x10

    ret

clear_screen:
    ; clear screen
    mov ah, 0x6
    mov al, 0x0
    mov bh, BLACK
    mov cx, 0x0000  ; Upper left corner (0,0)
    mov dx, 0x184F  ; Lower right corner (79,24)
    int 0x10

    ret

finish_game:
    ; clear screen
    mov ah, 0x6
    mov al, 0x0
    mov bh, BLACK
    mov cx, 0x0000  ; Upper left corner (0,0)
    mov dx, 0x184F  ; Lower right corner (79,24)
    int 0x10

    ; initialize typing
    mov ah, 0x2       ; BIOS.SetCursorPosition
    mov bh, 0         ; page 0
    mov dh, 11 
    mov dl, 14 
    int 0x10

    mov bl, WHITE
    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al,'G'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'A'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'M'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'E'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, ' '    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'O'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'V'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'E'    ; Point SI to the start of the string
    int 0x10

    mov ah, 0x0E       ; BIOS.Teletype (in AH)
    mov bh, 0
    mov al, 'R'    ; Point SI to the start of the string
    int 0x10
bits 16
org 0x8000       ; Memory Location 0x8000 for MyName Game Logic
jmp start;

%define WHITE 15 ; white color for pixels
%define BLACK 0
%define START_X 100 ; starting x position
%define START_Y 100 ; starting y position
%define LETTER_WIDTH 3
%define DEGREES 360

start:
    mov bx, 0 ; Init degrees register

    cli ; clr all interrumpts
    push 0xA000 ; video memory graphics segment
    pop es ; extra segments from stack pop them
    xor di, di ; set register to 0
    xor ax, ax ; set register to 0
    mov ax, 0x05 ; 320x200 resolution 4 colors mode
    int 0x10 ; video interrumpt


start_loop:
    call start_message

    mov ah, 0      ; Set up for keyboard input
    int 16h        ; BIOS interrupt for keyboard input

    cmp ah, 1Ch    ; Enter key
    je init_write_names

    jmp start_loop

init_write_names:
    ; clear screen
    mov ah, 0x6
    mov al, 0x0
    mov bh, BLACK
    mov dl, 39
    mov dh, 24
    int 0x10
    
    ; writing names in random position for the first time
    mov ah, 0xc ; write pixel
    mov al, WHITE ; color WHITE
    mov bh, 0x00 ; let page to 0
    mov cx, START_X ; x position
    mov dx, START_Y ; y position

    call plot_V_90 ; TODO: write complete names

    jmp game_loop

game_loop:
    ; Check for keyboard input without waiting
    mov ah, 1      ; Function 1: check if a key is pressed
    int 16h        ; Call BIOS keyboard interrupt
    jz game_loop  ; If no key is pressed, continue loop
    
    ; If a key is pressed, read it
    mov ah, 0      ; Function 0: read key and get scan code in AH
    int 16h        ; Call BIOS keyboard interrupt
    
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
    add bx, 90     ; Add 90 degrees when left arrow is pressed
    cmp bx, DEGREES
    jl skip_reset  ; Skip reset if under 360 degrees
    sub bx, DEGREES  ; Reset rotation if over 360

    jmp skip_reset

rotate_right:
    sub bx, 90     ; Subtract 90 degrees when right arrow is pressed
    cmp bx, 0
    jge skip_reset ; Skip reset if degrees >= 0
    add bx, DEGREES   ; Reset to 360 if negative

    jmp skip_reset

mirror_up:
    jmp finish_game

mirror_down:
    jmp finish_game

skip_reset:
    call write_names_by_rotation
    jmp game_loop


write_names_by_rotation:
    ; clear screen
    mov ah, 0x6
    mov al, 0x0
    mov bh, BLACK
    mov dl, 39
    mov dh, 24
    int 0x10

    mov ah, 0xc ; write pixel
    mov al, WHITE ; color WHITE
    mov bh, 0x00 ; let page to 0
    mov cx, START_X ; x position
    mov dx, START_Y ; y position

    ; TODO: change these for the corresponding rotated write_names
    cmp bx, 0
    je plot_V_0      ; Plot V with 0-degree rotation
    
    cmp bx, 90
    je plot_V_90     ; Plot V with 90-degree rotation

    cmp bx, 180
    je plot_V_180     ; Plot V with 180-degree rotation

    cmp bx, 270
    je plot_V_270     ; Plot V with 270-degree rotation

    ret


write_names:
    mov ah, 0xc ; write pixel
    mov al, WHITE ; color WHITE
    mov bh, 0x00 ; let page to 0
    mov cx, START_X ; x position
    mov dx, START_Y ; y position

    call plot_V_0

    ; Move to next letter position
    add cx, LETTER_WIDTH
    mov dx, START_Y
    call plot_A

    ; Move to next letter position
    add cx, LETTER_WIDTH
    mov dx, START_Y
    call plot_L

    ; Move to next letter position
    add cx, LETTER_WIDTH
    mov dx, START_Y
    ;call plot_E

    jmp finish_game

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
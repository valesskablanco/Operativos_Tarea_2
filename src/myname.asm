bits 16
org 0x8000       ; Memory Location 0x8000 for MyName Game Logic
jmp start;

%define WHITE 15 ; white color for pixels
%define BLACK 0
%define DEGREES 4
%define MIRROR_MAX 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INITIALIZING GAME
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
    cli                 ; clr all interrumpts
    push 0xA000         ; video memory graphics segment
    pop es              ; extra segments from stack pop them
    xor di, di          ; set register to 0
    xor ax, ax          ; set register to 0
    mov ax, 0x13        ; 320x200 resolution 256 colors mode
    int 0x10            ; video interrumpt

start_loop:
    call start_message

    mov si, 0           ; Init flag mirror/rotation
    mov bx, 0           ; Init degrees register counter

    mov ah, 0           ; Set up for keyboard input
    int 16h             ; BIOS interrupt for keyboard input

    cmp ah, 1Ch         ; Enter key
    je print_game

    jmp start_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GAME LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_game:
    call clear_screen

    jmp write_names_by_key

game_loop:

    mov ah, 01h         ; Check for keystroke
    int 16h             ; BIOS interrupt to check for keystroke

    jz game_loop        ; Jump if no key is available

    mov ah, 0           ; Set up for keyboard input
    int 16h             ; BIOS interrupt for keyboard input

    cmp ah, 13h         ; R key (reset)
    je start
    
    cmp ah, 01h         ; ESC key (finish game)
    je finish_game

    cmp ah, 48h         ; Up arrow key
    je mirror_up
    
    cmp ah, 50h         ; Down arrow key
    je mirror_down
    
    cmp ah, 4Bh         ; Left arrow key
    je rotate_left
    
    cmp ah, 4Dh         ; Right arrow key
    je rotate_right

    ; If no arrow key was pressed, go back to start of the loop
    jmp game_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INTERRUPT ROUTINES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rotate_left:
    mov si, 0
    add bx, 1           ; Add 90 degrees when left arrow is pressed
    cmp bx, DEGREES
    jl skip_reset       ; Skip reset if under 360 degrees
    sub bx, DEGREES     ; Reset rotation if over 360

    jmp skip_reset

rotate_right:
    mov si, 0           ; activate rotation
    sub bx, 1           ; Subtract 90 degrees when right arrow is pressed
    cmp bx, 0
    jge skip_reset      ; Skip reset if degrees >= 0
    add bx, DEGREES     ; Reset to 360 if negative

    jmp skip_reset

mirror_up:
    mov si, 1           ; activate mirroring
    add bx, 1
    cmp bx, MIRROR_MAX
    jl skip_reset
    sub bx, 1

    jmp skip_reset

mirror_down:
    mov si, 1
    sub bx, 1 
    cmp bx, 0
    jge skip_reset
    add bx, 1
    jmp skip_reset

skip_reset:
    call clearkeyboardbuffer
    jmp print_game

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINTING LOGIC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

write_names_by_key:

    cmp si, 0
    je write_names_by_rotation      ; Plot with rotation
    
    cmp si, 1
    je write_names_by_mirroring     ; Plot with mirroring

write_names_by_rotation:

    cmp bx, 0
    je write_names_0        ; Plot with 0-degree rotation
    
    cmp bx, 1
    je write_names_90       ; Plot with 90-degree rotation

    cmp bx, 2
    je write_names_180      ; Plot with 180-degree rotation

    cmp bx, 3
    je write_names_270          ; Plot with 270-degree rotation

write_names_by_mirroring:
    cmp bx, 0
    je write_names_down        ; Plot with mirroring up
    
    cmp bx, 1
    je write_names_0            ; Plot with mirroring down

    cmp bx, 2
    je write_names_down           ; Plot with mirroring down


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINTING NAMES ROUTINES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

write_names_0:
    call randomPosition

    call plot_VALE_0
    call plot_FELIPE_0

    jmp game_loop

write_names_90:
    call randomPosition

    call plot_VALE_90
    call plot_FELIPE_90

    jmp game_loop

write_names_180:
    call randomPosition

    call plot_VALE_180
    call plot_FELIPE_180

    jmp game_loop

write_names_270:
    call randomPosition

    call plot_VALE_270
    call plot_FELIPE_270

    jmp game_loop

write_names_down:    
    call randomPosition

    call plot_VALE_DOWN
    call plot_FELIPE_DOWN

    jmp game_loop

randomPosition:

    ; Generar valor aleatorio para START_X (entre 60 y 300)
    mov ah, 0x00             ; función para obtener la hora del BIOS
    int 0x1A                 ; llamada a la interrupción para obtener la hora
    mov bp, dx               ; usa parte de la hora como base aleatoria
    and bp, 199              ; limita el valor aleatorio de START_X a 0-199
    add bp, 60               ; ajusta el valor para estar entre 60 y 259

    ; Generar valor aleatorio para START_Y (entre 60 y 200)
    mov ah, 0x00             ; función para obtener nuevamente la hora del BIOS
    int 0x1A                 ; llamada a la interrupción para obtener la hora
    mov si, dx               ; usa otra parte de la hora como base aleatoria
    and si, 79              ; limita el valor aleatorio de START_Y a 0-79
    add si, 60               ; ajusta el valor para estar entre 60 y 139

    ret

initalPosition:
    mov cx, bp 
    mov dx, si
    ret

nextChar_0:
    add bp, 6
    ret

nextChar_90:
    sub si, 6
    ret

nextChar_180:
    sub bp, 6
    ret

nextChar_270:
    add si, 6
    ret

plot_VALE_0:
    call plot_V_0

    call nextChar_0
    call plot_A_0

    call nextChar_0
    call plot_L_0

    call nextChar_0
    call plot_E_0

    ret

plot_FELIPE_0:
    call nextChar_0
    call plot_F_0

    call nextChar_0
    call plot_E_0

    call nextChar_0
    call plot_L_0

    call nextChar_0
    call plot_I_0

    call nextChar_0
    call plot_P_0

    call nextChar_0
    call plot_E_0

    ret

plot_VALE_90:
    call plot_V_90

    call nextChar_90
    call plot_A_90

    call nextChar_90
    call plot_L_90

    call nextChar_90
    call plot_E_90

    ret

plot_FELIPE_90:
    call nextChar_90
    call plot_F_90

    call nextChar_90
    call plot_E_90

    call nextChar_90
    call plot_L_90

    call nextChar_90
    call plot_I_90

    call nextChar_90
    call plot_P_90

    call nextChar_90
    call plot_E_90

    ret

plot_VALE_180:
    call plot_V_180

    call nextChar_180
    call plot_A_180

    call nextChar_180
    call plot_L_180

    call nextChar_180
    call plot_E_180

    ret

plot_FELIPE_180:
    call nextChar_180
    call plot_F_180

    call nextChar_180
    call plot_E_180

    call nextChar_180
    call plot_L_180

    call nextChar_180
    call plot_I_180

    call nextChar_180
    call plot_P_180

    call nextChar_180
    call plot_E_180

    ret

plot_VALE_270:
    call plot_V_270

    call nextChar_270
    call plot_A_270

    call nextChar_270
    call plot_L_270

    call nextChar_270
    call plot_E_270

    ret

plot_FELIPE_270:
    call nextChar_270
    call plot_F_270

    call nextChar_270
    call plot_E_270

    call nextChar_270
    call plot_L_270

    call nextChar_270
    call plot_I_270

    call nextChar_270
    call plot_P_270

    call nextChar_270
    call plot_E_270

    ret

plot_VALE_DOWN:
    call plot_V_DOWN

    call nextChar_0
    call plot_A_DOWN

    call nextChar_0
    call plot_L_DOWN

    call nextChar_0
    call plot_E_DOWN

    ret

plot_FELIPE_DOWN:
    call nextChar_0
    call plot_F_DOWN

    call nextChar_0
    call plot_E_DOWN

    call nextChar_0
    call plot_L_DOWN

    call nextChar_0
    call plot_I_DOWN

    call nextChar_0
    call plot_P_DOWN

    call nextChar_0
    call plot_E_DOWN

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINTING LETTERS ROUTINES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_V_0:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_6

    ret

plot_A_0:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_4

    call initalPosition
    call plot_line_5

    ret

plot_L_0:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_6

    ret

plot_E_0:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_4

    call initalPosition
    call plot_line_5

    call initalPosition
    call plot_line_6

    ret

plot_F_0:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_4

    call initalPosition
    call plot_line_5

    ret

plot_I_0:
    call initalPosition
    call plot_line_2

    call initalPosition
    call plot_line_4

    call initalPosition
    call plot_line_6

    ret

plot_P_0:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_circule_1

    ret

plot_V_90:
    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_4

    call initalPosition
    call plot_line_6

    ret

plot_A_90:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_2

    call initalPosition
    call plot_line_4

    call initalPosition
    call plot_line_6

    ret

plot_L_90:
    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_6

    ret

plot_E_90:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_2

    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_6

    ret

plot_F_90:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_2

    call initalPosition
    call plot_line_6

    ret

plot_I_90:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_5

    ret

plot_P_90:
    call initalPosition
    call plot_line_6

    call initalPosition
    call plot_circule_3

    ret

plot_V_180:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_4

    ret

plot_A_180:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_5

    call initalPosition
    call plot_line_6

    ret

plot_L_180:
    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_4

    ret

plot_E_180:
    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_4

    call initalPosition
    call plot_line_5

    call initalPosition
    call plot_line_6

    ret

plot_F_180:
    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_5

    call initalPosition
    call plot_line_6

    ret

plot_I_180:
    call plot_I_0
    ret

plot_P_180:
    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_circule_2

    ret

plot_V_270:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_4

    call initalPosition
    call plot_line_6

    ret

plot_A_270:
    call initalPosition
    call plot_line_2

    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_4

    call initalPosition
    call plot_line_6

    ret

plot_L_270:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_4

    ret

plot_E_270:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_2

    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_4

    ret

plot_F_270:
    call initalPosition
    call plot_line_2

    call initalPosition
    call plot_line_3

    call initalPosition
    call plot_line_4

    ret

plot_I_270:
    call plot_I_90

    ret

plot_P_270:
    call initalPosition
    call plot_line_4

    call initalPosition
    call plot_circule_4

    ret

plot_V_DOWN:
    call plot_V_180

    ret

plot_A_DOWN:
    call plot_A_180

    ret

plot_L_DOWN:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_4

    ret

plot_E_DOWN:
    call plot_E_0

    ret

plot_F_DOWN:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_line_5

    call initalPosition
    call plot_line_6

    ret

plot_I_DOWN:
    call plot_I_0

    ret

plot_P_DOWN:
    call initalPosition
    call plot_line_1

    call initalPosition
    call plot_circule_2

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINTING LINES ROUTINES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_line_1:
    call plot_pixel
    inc dx
    call plot_pixel
    inc dx
    call plot_pixel
    inc dx
    call plot_pixel
    inc dx
    call plot_pixel
    ret

plot_line_2:
    add cx, 2
    call plot_line_1
    ret

plot_line_3:
    add cx, 4
    call plot_line_1
    ret

plot_line_4:
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

plot_line_5:
    add dx, 2
    call plot_line_4
    ret

plot_line_6:
    add dx, 4
    call plot_line_4
    ret

plot_circule_1:
    call plot_pixel
    inc cx
    call plot_pixel
    inc cx
    call plot_pixel
    inc cx
    call plot_pixel
    inc cx
    call plot_pixel
    inc dx
    call plot_pixel
    inc dx
    call plot_pixel
    dec cx
    call plot_pixel
    dec cx
    call plot_pixel
    dec cx
    call plot_pixel
    dec cx
    call plot_pixel
    dec dx
    call plot_pixel
    ret

plot_circule_2:
    add dx, 2
    call plot_circule_1
    ret

plot_circule_3:
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
    dec dx
    call plot_pixel
    dec dx
    call plot_pixel
    dec dx
    call plot_pixel
    dec dx
    call plot_pixel
    dec cx
    call plot_pixel
    ret

plot_circule_4:
    add cx, 2
    call plot_circule_3
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AUXILIAR PROCEDURES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_pixel:
    mov ah, 0xc ; write pixel
    mov al, WHITE ; color WHITE
    mov bh, 0x00 ; let page to 0
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FINISH GAME ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
bits 16
org 0x8000       ; Memory Location 0x8000 for MyName Game Logic
jmp start;

%define WHITE 15 ; white color for pixels
%define START_X 10 ; starting x position
%define START_Y 10 ; starting y position
%define LETTER_WIDTH 3

start:
    cli ; clr all interrumpts
    push 0xA000 ; video memory graphics segment
    pop es ; extra segments from stack pop them
    xor di, di ; set register to 0
    xor ax, ax ; set register to 0
    mov ax, 0x05 ; 320x200 resolution 4 colors mode
    int 0x10 ; video interrumpt

    jmp write_names


write_names:
    mov ah, 0xc ; write pixel
    mov al, WHITE ; color WHITE
    mov bh, 0x00 ; let page to 0
    mov cx, START_X ; x position
    mov dx, START_Y ; y position

    call plot_V

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

    jmp finish

plot_V:
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

finish:
    xor ax, ax
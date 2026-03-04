[BITS 32]
[ORG 0x10000]

VGA_MEM      equ 0xA0000
FS_BASE      equ 0x40000
TEXT_BUFFER  equ 0x50000
CANVAS_BASE  equ 0x60000 

STATE_DESKTOP  equ 0
STATE_NOTEPAD  equ 1
STATE_PAINT    equ 2
STATE_TERMINAL equ 3

section .text
_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov byte [current_state], STATE_DESKTOP
    
    call clear_screen
    call draw_taskbar

main_loop:
    call check_input
    call render_active_app
    
    ; Delay simples
    mov ecx, 0x1FFFF
    loop $
    jmp main_loop

render_active_app:
    mov al, [current_state]
    cmp al, STATE_DESKTOP
    je draw_desktop
    cmp al, STATE_NOTEPAD
    je draw_notepad
    cmp al, STATE_PAINT
    je draw_paint
    cmp al, STATE_TERMINAL
    je draw_terminal
    ret


draw_desktop:
    mov edi, VGA_MEM
    mov eax, 0x02020202 
    mov ecx, 14000 
    rep stosd
    ret

draw_notepad:
    mov edi, VGA_MEM + (20 * 320) + 20
    mov al, 0x0F 
    mov edx, 140 
.loop_y:
    mov ecx, 280 
    rep stosb
    add edi, 320 - 280
    dec edx
    jnz .loop_y
    ret

draw_paint:
    mov edi, VGA_MEM + (10 * 320) + 290
    mov al, 0x04
    mov ecx, 10 * 320
    rep stosb 
    ret

draw_terminal:
    mov edi, VGA_MEM
    xor eax, eax
    mov ecx, 15000
    rep stosd
    ret


check_input:
    in al, 0x64
    test al, 1
    jz .done
    in al, 0x60
    
    cmp al, 0x3B ; F1 -> Desktop
    je .set_desktop
    cmp al, 0x3C ; F2 -> Notepad
    je .set_notepad
    cmp al, 0x3D ; F3 -> Paint
    je .set_paint
    cmp al, 0x3E ; F4 -> Terminal
    je .set_terminal
    ret

.set_desktop:  mov byte [current_state], STATE_DESKTOP  | ret
.set_notepad:  mov byte [current_state], STATE_NOTEPAD  | ret
.set_paint:    mov byte [current_state], STATE_PAINT    | ret
.set_terminal: mov byte [current_state], STATE_TERMINAL | ret
.done:         ret

draw_taskbar:
    mov edi, VGA_MEM + (185 * 320)
    mov al, 0x08 ; Cinza escuro
    mov ecx, 15 * 320
    rep stosb
    ret

section .data
    current_state db 0
    lince_title   db 'LINCE OS ', 0
    msg_power     db 'MODO ECONOMIA: OFF', 0 
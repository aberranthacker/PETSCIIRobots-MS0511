    jmp @disable_cursor_lut(r1)

.disable_bottom:
    add #8*8, r0
.disable_middle:
    add #8*8, r0
.disable_top:
    bicb #CURSOR_TOGGLE, (r0)  ; disable cursor
    bis #COLOR_REGS_SEL, (r0)+ ; colors regs sel
    mov 8(r0), (r0)+           ; restore colors
    mov 8(r0), (r0)+
    add #8*8+2, r0
    bicb #CURSOR_TOGGLE, (r0)  ; disable cursor

    jmp @enable_cursor_lut(r1)

.cursor_pos:      .word 0
.cursor_pos_prev: .word 0

.disable_cursor_lut:
    .word .disable_top
    .word .disable_top
    .word .disable_top
    .word .disable_middle
    .word .disable_top
    .word .disable_top
    .word .disable_top
    .word .disable_middle

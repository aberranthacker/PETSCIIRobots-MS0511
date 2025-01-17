; Render text buffer to the screen
.macro _drawChar
        clr r0
        bisb (r1)+, r0
        cmpb r0, (r2)
        bne drawChar.draw\@
            inc r2
            inc r5
            inc r5
            br drawChar.skip\@

    drawChar.draw\@:
        movb r0, (r2)+

        asl r0
        mov PET_FONT_LUT(r0), r0

        .rept 8
            mov (r0)+, (r5)
            add r3, r5
        .endr
        sub #LINE_WIDTHB * 8 - 2, r5
    drawChar.skip\@:
.endm

.equiv DRAW_CHAR_REPS, 2 ; 2 is max number, `sob` will be out of range otherwise

drawBuffer:
    .ifdef COLOR_TILES
        tstb @#CCH1OS
        bpl .-4
        movb #TRUE, @#CCH1OD
    .else
        mov #TEXT_BUFFER, r1
        mov #TEXT_BUFFER_PREV, r2
        mov #FB, r5
        mov #25, LINES_COUNT
        mov #LINE_WIDTHB, r3
        mov #LINE_WIDTHW / DRAW_CHAR_REPS, r4

        drawBuffer.loop:
                .rept DRAW_CHAR_REPS
                    _drawChar
                .endr
            sob r4, drawBuffer.loop

            add #LINE_WIDTHB * 7, r5
           .equiv LINES_COUNT, .+2
            dec #25
            bze 1237$

            mov #LINE_WIDTHW / DRAW_CHAR_REPS, r4
        jmp drawBuffer.loop
    .endif
1237$: return

.ifndef COLOR_TILES
    PET_FONT: .incbin "build/c64tileset.gfx"
    PET_FONT_LUT:
        current_char = 0
        .rept 256
           .word PET_FONT + current_char * 16
            current_char = current_char + 1
        .endr
.endif

Channel1In_IntHandler: ;--------------------------------------------------------
    push @#PBPADR, R0, R1, R2, R3, R4, R5

.ifdef COLOR_TILES
;-------------------------------------------------------------------------------
    rept_count = 10
    mov #PBPADR, r5
    mov #PBP12D, r4
    mov #PPU_TEXT_BUFFER, r3
    mov #1000 / rept_count, r1

    mov #CPU_TEXT_BUFFER, (r5)
    10$:
        .rept rept_count
            mov (r4), (r3)+
            inc (r5)
        .endr
    sob r1, 10$
;-------------------------------------------------------------------------------
; Render text buffer to the screen
    .macro _drawChar
            mov (r1)+, r0
            cmp r0, (r2)
            bne drawChar.draw\@
                inc r2
                inc r2
                inc (r5)
                br drawChar.skip\@

            drawChar.draw\@:
                mov r0, (r2)+
                mov r0, @#DOTS_COLOR_REG
                clrb r0
                swab r0
                asl r0
                mov PET_FONT_LUT(r0), r0

               .rept 7
                mov (r0)+, (r4)
                add r3, (r5)
               .endr
                mov (r0), (r4)
                sub #SCREEN_WIDTH * 7 - 1, (r5)
            drawChar.skip\@:
    .endm
;-------------------------------------------------------------------------------
    drawBuffer:
        mov #PPU_TEXT_BUFFER, r1
        mov #TEXT_BUFFER_PREV, r2
        mov #PBPADR, r5
        mov #FB/2, (r5)
        mov #DOTS_OCTET_REG, r4
        mov #25, LINES_COUNT
        mov #SCREEN_WIDTH, r3

        drawBuffer.loop:
            .rept 40
                 _drawChar
            .endr

            add #SCREEN_WIDTH * 7, (r5)
           .equiv LINES_COUNT, .+2
            dec #25
            bze ch1.draw_buffer_done
        jmp drawBuffer.loop

        ch1.draw_buffer_done:
;-------------------------------------------------------------------------------
.endif
    pop R5, R4, R3, R2, R1, R0, @#PBPADR
    tstb @#PCH1ID
    rti
;-------------------------------------------------------------------------------
.ifdef COLOR_TILES
    PET_FONT:    .incbin "build/c64tileset.gfx"

    PPU_TEXT_BUFFER: .ds.b 2000
    TEXT_BUFFER_PREV: .ds.b 2000

    PET_FONT_LUT:
        current_char = 0
        .rept 256
           .word PET_FONT + current_char * 16
            current_char = current_char + 1
        .endr
.endif

    .even

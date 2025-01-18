drawMapWindow:
    call mapPreCalculate
    clr redraw_window
  ; render map and attributes all at once
    mov MAP_WINDOW_Y, r4
    swab r4 ; swab clears the carry flag as a bonus
    ror r4
  ; r4 = MAP_WINDOW_Y * 128 + MAP_WINDOW_X
    add MAP_WINDOW_X, r4
    add #MAP, r4

    mov #TEXT_BUFFER, r5
    mov #MAP_PRECALC, r3
    mov #VIEWPORT_TILE_HGT, dwm_row_counter

    dmw.rowsLoop: ; DM01:
        mov #VIEWPORT_TILE_WDT, r1
        dmw.columnsLoop: ; DM02:
            clr r0
            bisb (r4)+, r0
            call plotTile

            clr r0
            bisb (r3)+, r0
            _call NZ, plotTransparentTile

            .ifdef COLOR_TILES
                add #6, r5
            .else
                add #3, r5
            .endif
        sob r1, dmw.columnsLoop

        add #MAP_WIDTH - VIEWPORT_TILE_WDT, r4
    .ifdef COLOR_TILES
        add #(SCREEN_WIDTH*3-(VIEWPORT_TILE_WDT*3))*2, r5
    .else
        add #SCREEN_WIDTH*3-(VIEWPORT_TILE_WDT*3), r5
    .endif
   .equiv dwm_row_counter, .+2
    dec #VIEWPORT_TILE_HGT
    bnz dmw.rowsLoop

    jmp drawBuffer  ;  call:return

; This routine checks all units from 0 to 31 and figures out if it should be displayed
; on screen, and then grabs that unit's tile and stores it in the MAP_PRECALC array
; so that when the window is drawn, it does not have to search for units during the
; draw, speeding up the display routine.
mapPreCalculate:
  ; clear old buffer
    mov #MAP_PRECALC, r5
    mov #MAP_PRECALC_SIZE / 2 + 1, r1
    10$:
       clr (r5)+
    sob r1, 10$

    clr r3
  ; skip the check for unit zero, always draw it.
    br mpc.skip_check

    mpc.check_unit_loop:
      ; check that unit exists
        tstb UNIT_TYPE(r3)
        bze mpc.check_next_unit
          ; check horizontal position
            cmpb UNIT_LOC_X(r3), MAP_WINDOW_X
            blo mpc.check_next_unit
                mov MAP_WINDOW_X, r0
                add #VIEWPORT_TILE_WDT-1, r0
                cmpb UNIT_LOC_X(r3), r0
                bhi mpc.check_next_unit
                  ; now check vertical
                    cmpb UNIT_LOC_Y(r3), MAP_WINDOW_Y
                    blo mpc.check_next_unit
                        mov MAP_WINDOW_Y, r0
                        add #VIEWPORT_TILE_HGT-1, r0
                        cmpb UNIT_LOC_Y(r3), r0
                        bhi mpc.check_next_unit

      ; Unit found in map window, now add that unit's
      ; tile to the precalc map.
        mpc.skip_check:
            clr r4
            _movb UNIT_LOC_Y(r3), r4
            sub MAP_WINDOW_Y, r4

            clr r0
            _movb UNIT_LOC_X(r3), r0
            sub MAP_WINDOW_X, r0

            clr r5
            _movb PRECALC_ROWS(r4), r5

            add r5, r0
            mov r0, r4

            clr r0
            bisb UNIT_TILE(r3), r0

            cmpb r0, #TILE_BOMB   ; is it a bomb
            beq PREC6
            cmpb r0, #TILE_MAGNET ; is it a magnet
            beq PREC6

        PREC4:
            movb r0, MAP_PRECALC(r4)

    mpc.check_next_unit:
  ; continue search
    inc r3
    cmp r3, #32 ; units count
    blo mpc.check_unit_loop
return

    PREC6:
      ; What to do in case of bomb or magnet that should
      ; go underneath the unit or robot.
        tstb MAP_PRECALC(r4)
        bnz mpc.check_next_unit
            movb UNIT_TILE(r3), r0
            br PREC4

PRECALC_ROWS:
    yoff = 0
    .rept VIEWPORT_TILE_HGT
        .byte yoff
        yoff = yoff + VIEWPORT_TILE_WDT
    .endr
    .even

.ifdef COLOR_TILES
    TILES_LUT:
        offset = 0
        .rept 256
            .word TILE_DATA + offset * 18
            offset = offset + 1
        .endr
.endif

; input: r0 - tile number
;        r5 - TEXT_BUFFER pointer
; corrupts: r0, r1, r2
plotTile:
    .ifdef COLOR_TILES
        push r5
            asl r0
            mov TILES_LUT(r0), r0

            mov (r0)+, (r5)+
            mov (r0)+, (r5)+
            mov (r0)+, (r5)
            add #SCREEN_WIDTH*2 - 4, r5
            mov (r0)+, (r5)+
            mov (r0)+, (r5)+
            mov (r0)+, (r5)
            add #SCREEN_WIDTH*2 - 4, r5
            mov (r0)+, (r5)+
            mov (r0)+, (r5)+
            mov (r0), (r5)
        pop r5
    .else
        push r5
            add #TILE_DATA_TL, r0
            mov #256, r2
          ; Draw the top 3 characters
            movb (r0), (r5)+
            add r2, r0

            movb (r0), (r5)+
            add r2, r0

            movb (r0), (r5)
            add r2, r0
          ; Draw the middle 3 characters
            add #SCREEN_WIDTH-2, r5
            movb (r0), (r5)+
            add r2, r0

            movb (r0), (r5)+
            add r2, r0

            movb (r0), (r5)
            add r2, r0
          ; Draw the bottom 3 characters
            add #SCREEN_WIDTH-2, r5
            movb (r0), (r5)+
            add r2, r0

            movb (r0), (r5)+
            add r2, r0

            movb (r0), (r5)
        pop r5
    .endif
return

plotTransparentTile:
    .ifdef COLOR_TILES
        push r5
            mov #0x3A, r2 ; "transparent" tile idx
            asl r0
            mov TILES_LUT(r0), r0
            inc r0 ; LSB stores color, MSB tile idx

            cmpb (r0), r2
            beq 10$ ; do not draw transparent tile
                mov (r0), (r5)
            10$:
            inc r0
            inc r0
            inc r5
            inc r5
            cmpb (r0), r2
            beq 20$
                mov (r0), (r5)
            20$:
            inc r0
            inc r0
            inc r5
            inc r5
            cmpb (r0), r2
            beq 30$
                mov (r0), (r5)
            30$:
            inc r0
            inc r0
            add #SCREEN_WIDTH*2 - 4, r5

            cmpb (r0), r2
            beq 40$
                mov (r0), (r5)
            40$:
            inc r0
            inc r0
            inc r5
            inc r5
            cmpb (r0), r2
            beq 50$
                mov (r0), (r5)
            50$:
            inc r0
            inc r0
            inc r5
            inc r5
            cmpb (r0), r2
            beq 60$
                mov (r0), (r5)
            60$:
            inc r0
            inc r0
            add #SCREEN_WIDTH*2 - 4, r5

            cmpb (r0), r2
            beq 70$
                mov (r0), (r5)
            70$:
            inc r0
            inc r0
            inc r5
            inc r5
            cmpb (r0), r2
            beq 80$
                mov (r0), (r5)
            80$:
            inc r0
            inc r0
            inc r5
            inc r5
            cmpb (r0), r2
            beq 90$
                mov (r0), (r5)
            90$:
        pop r5
    .else
        push r5
            add #TILE_DATA_TL, r0
            mov #256, r2
          ; Draw the top 3 characters
            cmpb (r0), #0x3A
            beq 10$
                movb (r0), (r5)
            10$:
            add r2, r0
            inc r5

            cmpb (r0), #0x3A
            beq 20$
                movb (r0), (r5)
            20$:
            add r2, r0
            inc r5

            cmpb (r0), #0x3A
            beq 30$
                movb (r0), (r5)
            30$:
            add r2, r0
          ; Draw the middle 3 characters
            add #SCREEN_WIDTH-2, r5

            cmpb (r0), #0x3A
            beq 40$
                movb (r0), (r5)
            40$:
            add r2, r0
            inc r5

            cmpb (r0), #0x3A
            beq 50$
                movb (r0), (r5)
            50$:
            add r2, r0
            inc r5

            cmpb (r0), #0x3A
            beq 60$
                movb (r0), (r5)
            60$:
            add r2, r0
          ; Draw the bottom 3 characters
            add #SCREEN_WIDTH-2, r5

            cmpb (r0), #0x3A
            beq 70$
                movb (r0), (r5)
            70$:
            add r2, r0
            inc r5

            cmpb (r0), #0x3A
            beq 80$
                 movb (r0), (r5)
            80$:
            add r2, r0
            inc r5

            cmpb (r0), #0x3A
            beq 90$
                movb (r0), (r5)
            90$:
        pop r5
    .endif
return


SYSRQ:
    push r0, r1
        call updateGameClock
        call animateTiles
       .equiv BGTIMER1, .+4
        mov #TRUE, #0

       .equiv BGTIMER2, .+2
        tst #0
        bze 10$
            dec BGTIMER2
        10$: ; SYSRQ1:
       .equiv KEYTIMER, .+2
        tst #0
        bze 20$
            dec KEYTIMER
        20$: ; SYSRQ2:
       .equiv BORDER_FLASH, .+2
        tst #0
        bze 30$
            dec BORDER_FLASH
        30$: ; SYSRQ3:

;      .equiv cursor_counter, .+2
;       inc #-1

;       mov cursor_counter, r0
;       asl r0
;       asl r0
;       swab r0
;       bic #0xFFF0, r0
;       .equiv sound_played, .+2
;       cmp r0, #-1
;       beq 40$
;           mov r0, sound_played
;           call ssy_sound_play
;       40$:
    pop r1, r0
rti

updateGameClock:
   .equiv CLOCK_ACTIVE, .+2
    tst #0
    bze 1237$

   .equiv CYCLES, .+2
    inc #0
    cmp CYCLES, #50 ; 60 for ntsc or 50 for pal
    bne 1237$

    clr CYCLES
   .equiv SECONDS, .+2
    inc #0
    cmp SECONDS, #60
    bne 1237$

    clr SECONDS
   .equiv MINUTES, .+2
    inc #0
    cmp MINUTES, #60
    bne 1237$

    clr MINUTES
    clr SECONDS
   .equiv HOURS, .+2
    inc #0
1237$: return

animateTiles:
   .equiv ANIMATE, .+2
    tst #0
    bnz AW00
        return
    AW00:

   .equiv WATER_TIMER, .+2
    inc #0
    cmp WATER_TIMER, #20
    beq 10$
        return
    10$:

    clr WATER_TIMER
  ; water tiles
   .ifdef COLOR_TILES
        movb TILE_DATA + 204*18 + BR_OFFSET, r1
        movb TILE_DATA + 204*18 + MM_OFFSET, r0
        movb r0, TILE_DATA + 204*18 + BR_OFFSET
        movb r0, TILE_DATA + 221*18 + BR_OFFSET
        movb TILE_DATA + 204*18 + TL_OFFSET, TILE_DATA + 204*18 + MM_OFFSET
        movb r1, TILE_DATA + 204*18 + TL_OFFSET

        movb TILE_DATA + 204*18 + BL_OFFSET, r1
        movb TILE_DATA + 204*18 + MR_OFFSET, r0
        movb r0, TILE_DATA + 204*18 + BL_OFFSET
        movb r0, TILE_DATA + 221*18 + BL_OFFSET
        movb TILE_DATA + 204*18 + TM_OFFSET, TILE_DATA + 204*18 + MR_OFFSET
        movb r1, TILE_DATA + 204*18 + TM_OFFSET
        movb r1, TILE_DATA + 221*18 + TM_OFFSET

        movb TILE_DATA + 204*18 + BM_OFFSET, r1
        movb TILE_DATA + 204*18 + ML_OFFSET, r0
        movb r0, TILE_DATA + 221*18 + BM_OFFSET
        movb r0, TILE_DATA + 221*18 + BM_OFFSET
        movb TILE_DATA + 204*18 + TR_OFFSET, TILE_DATA + 204*18 + ML_OFFSET
        movb r1, TILE_DATA + 204*18 + TR_OFFSET
        movb r1, TILE_DATA + 221*18 + TR_OFFSET
   .else
        movb TILE_DATA_BR+204, r1
        movb TILE_DATA_MM+204, r0
        movb r0, TILE_DATA_BR+204
        movb r0, TILE_DATA_BR+221
        movb TILE_DATA_TL+204, TILE_DATA_MM+204
        movb r1, TILE_DATA_TL+204

        movb TILE_DATA_BL+204, r1
        movb TILE_DATA_MR+204, r0
        movb r0, TILE_DATA_BL+204
        movb r0, TILE_DATA_BL+221
        movb TILE_DATA_TM+204, TILE_DATA_MR+204
        movb r1, TILE_DATA_TM+204
        movb r1, TILE_DATA_TM+221

        movb TILE_DATA_BM+204, r1
        movb TILE_DATA_ML+204, r0
        movb r0, TILE_DATA_BM+221
        movb r0, TILE_DATA_BM+221
        movb TILE_DATA_TR+204, TILE_DATA_ML+204
        movb r1, TILE_DATA_TR+204
        movb r1, TILE_DATA_TR+221
   .endif

  ; trash compactor
   .ifdef COLOR_TILES
        movb TILE_DATA + 148*18 + TR_OFFSET-1, r1
        movb TILE_DATA + 148*18 + TM_OFFSET-1, TILE_DATA + 148*18 + TR_OFFSET-1
        movb TILE_DATA + 148*18 + TL_OFFSET-1, TILE_DATA + 148*18 + TM_OFFSET-1
        movb r1, TILE_DATA + 148*18 + TL_OFFSET-1

        movb TILE_DATA + 148*18 + MR_OFFSET-1, r1
        movb TILE_DATA + 148*18 + MM_OFFSET-1, TILE_DATA + 148*18 + MR_OFFSET-1
        movb TILE_DATA + 148*18 + ML_OFFSET-1, TILE_DATA + 148*18 + MM_OFFSET-1
        movb r1, TILE_DATA + 148*18 + ML_OFFSET-1

        movb TILE_DATA + 148*18 + BR_OFFSET-1, r1
        movb TILE_DATA + 148*18 + BM_OFFSET-1, TILE_DATA + 148*18 + BR_OFFSET-1
        movb TILE_DATA + 148*18 + BL_OFFSET-1, TILE_DATA + 148*18 + BM_OFFSET-1
        movb r1, TILE_DATA + 148*18 + BL_OFFSET-1
   .else
        movb TILE_DATA_TR+148, r1
        movb TILE_DATA_TM+148, TILE_DATA_TR+148
        movb TILE_DATA_TL+148, TILE_DATA_TM+148

        movb r1, TILE_DATA_TL+148
        movb TILE_DATA_MR+148, r1
        movb TILE_DATA_MM+148, TILE_DATA_MR+148
        movb TILE_DATA_ML+148, TILE_DATA_MM+148

        movb r1, TILE_DATA_ML+148
        movb TILE_DATA_BR+148, r1
        movb TILE_DATA_BM+148, TILE_DATA_BR+148
        movb TILE_DATA_BL+148, TILE_DATA_BM+148

        movb r1, TILE_DATA_BL+148
   .endif

  ; Now do HVAC fan
   .equiv HVAC_STATE, .+2
    tst #0
    bze HVAC1
      .ifdef COLOR_TILES
        mov #0xCD, r0
        movb r0, TILE_DATA + 196*18 + MM_OFFSET
        movb r0, TILE_DATA + 201*18 + TL_OFFSET
        mov #0xCE, r0
        movb r0, TILE_DATA + 197*18 + ML_OFFSET
        movb r0, TILE_DATA + 200*18 + TM_OFFSET
        mov #0xA0, r0
        movb r0, TILE_DATA + 196*18 + MR_OFFSET
        movb r0, TILE_DATA + 196*18 + BM_OFFSET
        movb r0, TILE_DATA + 197*18 + BL_OFFSET
        movb r0, TILE_DATA + 200*18 + TR_OFFSET

        clr HVAC_STATE
        br HVAC2
    HVAC1:
        mov #0xA0, r0
        movb r0, TILE_DATA + 196*18 + MM_OFFSET
        movb r0, TILE_DATA + 201*18 + TL_OFFSET
        movb r0, TILE_DATA + 197*18 + ML_OFFSET
        movb r0, TILE_DATA + 200*18 + TM_OFFSET
        mov #0xC2, r0
        movb r0, TILE_DATA + 196*18 + MR_OFFSET
        movb r0, TILE_DATA + 200*18 + TR_OFFSET
        mov #0xC0, r0
        movb r0, TILE_DATA + 196*18 + BM_OFFSET
        movb r0, TILE_DATA + 197*18 + BL_OFFSET
      .else
        mov #0xCD, r0
        movb r0, TILE_DATA_MM+196
        movb r0, TILE_DATA_TL+201
        mov #0xCE, r0
        movb r0, TILE_DATA_ML+197
        movb r0, TILE_DATA_TM+200
        mov #0xA0, r0
        movb r0, TILE_DATA_MR+196
        movb r0, TILE_DATA_BM+196
        movb r0, TILE_DATA_BL+197
        movb r0, TILE_DATA_TR+200

        clr HVAC_STATE
        br HVAC2
    HVAC1:
        mov #0xA0, r0
        movb r0, TILE_DATA_MM+196
        movb r0, TILE_DATA_TL+201
        movb r0, TILE_DATA_ML+197
        movb r0, TILE_DATA_TM+200
        mov #0xC2, r0
        movb r0, TILE_DATA_MR+196
        movb r0, TILE_DATA_TR+200
        mov #0xC0, r0
        movb r0, TILE_DATA_BM+196
        movb r0, TILE_DATA_BL+197
      .endif

        mov #1, HVAC_STATE
    HVAC2:

  ; now do cinema screen tiles
  ; FIRST COPY OLD LETTERS TO THE LEFT.
    .ifdef COLOR_TILES
        movb TILE_DATA + 20*18 + MR_OFFSET, TILE_DATA + 20*18 + MM_OFFSET ; 2 -> 1
        movb TILE_DATA + 21*18 + ML_OFFSET, TILE_DATA + 20*18 + MR_OFFSET ; 3 -> 2
        movb TILE_DATA + 21*18 + MM_OFFSET, TILE_DATA + 21*18 + ML_OFFSET ; 4 -> 3
        movb TILE_DATA + 21*18 + MR_OFFSET, TILE_DATA + 21*18 + MM_OFFSET ; 5 -> 4
        movb TILE_DATA + 22*18 + ML_OFFSET, TILE_DATA + 21*18 + MR_OFFSET ; 6 -> 5
    .else
        movb TILE_DATA_MR+20, TILE_DATA_MM+20 ; 2 -> 1
        movb TILE_DATA_ML+21, TILE_DATA_MR+20 ; 3 -> 2
        movb TILE_DATA_MM+21, TILE_DATA_ML+21 ; 4 -> 3
        movb TILE_DATA_MR+21, TILE_DATA_MM+21 ; 5 -> 4
        movb TILE_DATA_ML+22, TILE_DATA_MR+21 ; 6 -> 5
    .endif
  ; now insert new character.
   .equiv CINEMA_STATE, .+2
    mov #0, r1                         ;     ld a, (CINEMA_STATE)
                                       ;     ld e, a
                                       ;     ld d, 0
    movb CINEMA_MESSAGE(r1), r0        ;     LDA_HL_X CINEMA_MESSAGE
    call petChar                       ;     call pet_char
    .ifdef COLOR_TILES
        movb r0, TILE_DATA + 22*18 + ML_OFFSET ; new char -> 6
    .else
        movb r0, TILE_DATA_ML+22 ; new char -> 6    ;     STA TILE_DATA_ML+22 ;#6
    .endif
                                       ;     ld hl, CINEMA_STATE
    inc r1                             ;     inc (hl)
    mov r1, CINEMA_STATE               ;     ld a, (hl)
    cmp r1, #197                       ;     cp 197
    bne CINE2                          ;     jr nz, CINE2
        clr CINEMA_STATE               ;     ld (hl), 0

  ; Now animate light on server computers
    CINE2:
    .ifdef COLOR_TILES
        movb TILE_DATA + 143*18 + MR_OFFSET, r0
    .else
        movb TILE_DATA_MR+143, r0
    .endif
    cmpb r0, #0xD7
    bne CINE3
        mov #0xD1, r0
        br CINE4
    CINE3:
        mov #0xD7, r0
    CINE4:
        .ifdef COLOR_TILES
            movb r0, TILE_DATA + 143*18 + MR_OFFSET
        .else
            movb r0, TILE_DATA_MR+143
        .endif

    mov #TRUE, redraw_window
return

CINEMA_MESSAGE:
    .ascii "COMING SOON: SPACE BALLS 2 - THE SEARCH FOR MORE MONEY, "
    .ascii "ATTACK OF THE PAPERCLIPS: CLIPPY'S REVENGE, "
    .ascii "IT CAME FROM PLANET EARTH, "
    .ascii "ROCKY 5000, ALL MY CIRCUITS THE MOVIE, "
    .ascii "CONAN THE LIBRARIAN, AND MORE! "
    .even

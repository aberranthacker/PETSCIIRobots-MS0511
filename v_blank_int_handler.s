
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

  ; trash compactor
    movb TILE_DATA_TR+148, r1               ; LDA TILE_DATA_TR+148
                                            ; STA WATER_TEMP1
    movb TILE_DATA_TM+148, TILE_DATA_TR+148 ; LDA TILE_DATA_TM+148
                                            ; STA TILE_DATA_TR+148
    movb TILE_DATA_TL+148, TILE_DATA_TM+148 ; LDA TILE_DATA_TL+148
                                            ; STA TILE_DATA_TM+148
                                            ; LDA WATER_TEMP1
    movb r1, TILE_DATA_TL+148               ; STA TILE_DATA_TL+148
                                            ;
    movb TILE_DATA_MR+148, r1               ; LDA TILE_DATA_MR+148
                                            ; STA WATER_TEMP1
    movb TILE_DATA_MM+148, TILE_DATA_MR+148 ; LDA TILE_DATA_MM+148
                                            ; STA TILE_DATA_MR+148
    movb TILE_DATA_ML+148, TILE_DATA_MM+148 ; LDA TILE_DATA_ML+148
                                            ; STA TILE_DATA_MM+148
                                            ; LDA WATER_TEMP1
    movb r1, TILE_DATA_ML+148               ; STA TILE_DATA_ML+148
                                            ;
    movb TILE_DATA_BR+148, r1               ; LDA TILE_DATA_BR+148
                                            ; STA WATER_TEMP1
    movb TILE_DATA_BM+148, TILE_DATA_BR+148 ; LDA TILE_DATA_BM+148
                                            ; STA TILE_DATA_BR+148
    movb TILE_DATA_BL+148, TILE_DATA_BM+148 ; LDA TILE_DATA_BL+148
                                            ; STA TILE_DATA_BM+148
                                            ; LDA WATER_TEMP1
    movb r1, TILE_DATA_BL+148               ; STA TILE_DATA_BL+148

  ; Now do HVAC fan
   .equiv HVAC_STATE, .+2
    tst #0
    bze HVAC1
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

        mov #1, HVAC_STATE
    HVAC2:
  ; now do cinema screen tiles
  ; FIRST COPY OLD LETTERS TO THE LEFT.
    movb TILE_DATA_MR+20, TILE_DATA_MM+20 ; 2 -> 1
    movb TILE_DATA_ML+21, TILE_DATA_MR+20 ; 3 -> 2
    movb TILE_DATA_MM+21, TILE_DATA_ML+21 ; 4 -> 3
    movb TILE_DATA_MR+21, TILE_DATA_MM+21 ; 5 -> 4
    movb TILE_DATA_ML+22, TILE_DATA_MR+21 ; 6 -> 5
  ; now insert new character.
   .equiv CINEMA_STATE, .+2
    mov #0, r1                         ;     ld a, (CINEMA_STATE)
                                       ;     ld e, a
                                       ;     ld d, 0
    movb CINEMA_MESSAGE(r1), r0        ;     LDA_HL_X CINEMA_MESSAGE
    call petChar                       ;     call pet_char
    movb r0, TILE_DATA_ML+22 ; -> 6    ;     STA TILE_DATA_ML+22 ;#6
                                       ;     ld hl, CINEMA_STATE
    inc r1                             ;     inc (hl)
    mov r1, CINEMA_STATE               ;     ld a, (hl)
    cmp r1, #197                       ;     cp 197
    bne CINE2                          ;     jr nz, CINE2
        clr CINEMA_STATE               ;     ld (hl), 0
                                       ;
    CINE2: ; Now animate light on server computers
    movb TILE_DATA_MR+143, r0          ;     LDA TILE_DATA_MR+143
    cmpb r0, #0xD7                     ;     cp #D7
    bne CINE3                          ;     jr nz, CINE3
        mov #0xD1, r0                  ;     ld a, #D1
        br CINE4                       ;     jr CINE4
    CINE3:
        mov #0xD7, r0                  ;     ld a, #D7
    CINE4:
        movb r0, TILE_DATA_MR+143      ;     STA TILE_DATA_MR+143
                                       ;             ld a, 1
    mov #TRUE, redraw_window           ;             ld (REDRAW_WINDOW), a
return                                 ;             ret
                                       ;
CINEMA_MESSAGE:
    .ascii "COMING SOON: SPACE BALLS 2 - THE SEARCH FOR MORE MONEY, "
    .ascii "ATTACK OF THE PAPERCLIPS: CLIPPY'S REVENGE, "
    .ascii "IT CAME FROM PLANET EARTH, "
    .ascii "ROCKY 5000, ALL MY CIRCUITS THE MOVIE, "
    .ascii "CONAN THE LIBRARIAN, AND MORE! "
    .even

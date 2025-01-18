       .list

       .title "PETSCII Robots bootstrap"

       .include "hwdefs.s"
       .include "macros.s"
       .include "defs.s"
       .include "constants.s"

       .global title.bin
       .global level_a
       .global level_b
       .global level_c
       .global level_d
       .global level_e
       .global level_f
       .global level_g
       .global level_h
       .global level_i
       .global level_j
       .global level_k
       .global level_l
       .global level_m
       .global level_n
       .global level_o
       .global start

       .global TEXT_BUFFER

       .global puts
       .global DIFFICULTY
       .global unZX0

       .=MAIN_START

start:
    _unZX0 INTRO_TEXT, TEXT_BUFFER
    call drawBuffer

  ; Main game loop starts here
    mov #SYSRQ, @#0100
    mtps #PR0

    call initGame ; reset vars and load map file
    call setDiffLevel
    call animatePlayer
    call calculateAndRedraw
    call displayWeapon
    call displayKeys
    call displayPlayerHealth

    call drawMapWindow

    clr DISABLE_CONTROLS    ; ld (DISABLE_CONTROLS), a
                            ; ld a, TRUE
    mov #1, UNIT_TYPE       ; ld (UNIT_TYPE), a
    mov #TRUE, ANIMATE      ; ld (ANIMATE), a

    call setInitialTimers
    call printIntroMessage
                            ; ld a, 30
    mov #30, KEYTIMER       ; ld (KEYTIMER), a

                            ; call PLAY_SOUND_QUEUE_CLEAR

    mainGameLoop:
            ; call PLAY_SOUND_QUEUE_PLAY      ;play delayed sound effects
        wait                    ; halt
                                ; call PET_SCREEN_SHAKE
        call backgroundTasks    ; call BACKGROUND_TASKS

                                ; ld a, (UNIT_TYPE)
        cmpb UNIT_TYPE, #1      ; cp 1 ; Is player unit alive?
        ; bne gameOver          ; jp nz, GAME_OVER

        tst DISABLE_CONTROLS    ; ld a, (DISABLE_CONTROLS)
                                ; and a
        bnz mainGameLoop        ; jr nz, MAIN_GAME_LOOP

                                ; ld a, (reset_step)
       .equiv reset_step, .+2
        tst #0                  ; and a
        bze checkKbd            ; jr z, CHECK_KBD
        br checkKbd
                                ; dec a
        dec reset_step          ; ld (reset_step), a
        bnz checkKbd            ; jr nz, CHECK_KBD
                                ; ld a, 7
        mov #7, alternate_steps ; ld (alternate_steps), a

    checkKbd:
                                ; call GETIN
        tst KEYBOARD_SCANNER    ; and a
        bze mainGameLoop        ; jr z, mainGameLoop

                                ; ld hl, reset_step
        mov #20, reset_step     ; ld (hl), 20

        tst KEYTIMER
        bnz mainGameLoop
        mov #6, KEYTIMER        ; ld hl, KEYTIMER
                                ; ld (hl), 5

                                ; ld hl, TECLADO ; redefined keys
        mov KEYBOARD_SCANNER, r0
    checkKbdUp:
        bit #KEYMAP_UP, r0
        bze checkKbdDown
            clr r3 ; player unit number is 0
            mov #MOVE_WALK, MOVE_TYPE
            call requestWalkUp
            jmp afterMove
    checkKbdDown:
        bit #KEYMAP_DOWN, r0
        bze checkKbdLeft
            clr r3 ; player unit number is 0
            mov #MOVE_WALK, MOVE_TYPE
            call requestWalkDown
            jmp afterMove
    checkKbdLeft:
        bit #KEYMAP_LEFT, r0
        bze checkKbdRight
            clr r3 ; player unit number is 0
            mov #MOVE_WALK, MOVE_TYPE
            call requestWalkLeft
            jmp afterMove
    checkKbdRight:
        bit #KEYMAP_RIGHT, r0
        bze checkKbdFireUp
            clr r3 ; player unit number is 0
            mov #MOVE_WALK, MOVE_TYPE
            call requestWalkRight
            jmp afterMove
    checkKbdFireUp:
        bit #KEYMAP_FIRE_UP, r0
        bze checkKbdFireDown
            bic #KEYMAP_FIRE_UP, KEYBOARD_SCANNER
            call fireUp
            jmp mainGameLoop
    checkKbdFireDown:
        bit #KEYMAP_FIRE_DOWN, r0
        bze checkKbdFireLeft
            bic #KEYMAP_FIRE_DOWN, KEYBOARD_SCANNER
            call fireDown
            jmp mainGameLoop
    checkKbdFireLeft:
        bit #KEYMAP_FIRE_LEFT, r0
        bze checkKbdFireRight
            bic #KEYMAP_FIRE_LEFT, KEYBOARD_SCANNER
            call fireLeft
            jmp mainGameLoop
    checkKbdFireRight:
        bit #KEYMAP_FIRE_RIGHT, r0
        bze checkKbdCycleWeapons
            bic #KEYMAP_FIRE_RIGHT, KEYBOARD_SCANNER
            call fireRight
            jmp mainGameLoop
    checkKbdCycleWeapons:

            jmp mainGameLoop


petChar: ; 65..90
    cmp r0, #'A
    blo 1237$
        cmp r0, #'Z
        bhi 1237$
            sub #64, r0
1237$: return

displayLoadMessage2:
   .ifdef COLOR_TILES
        mov #TEXT_BUFFER + 6 + 10 * SCREEN_WIDTH * 2, r4
   .else
        mov #TEXT_BUFFER + 3 + 10 * SCREEN_WIDTH, r4
   .endif
    mov #LOAD_MSG2, r5
    mov #9, r1

    DLM1:
        movb (r5)+, r0
        call petChar
        .ifdef COLOR_TILES
            movb #7, (r4)+
        .endif
        movb r0, (r4)+
    sob r1, DLM1

    .ifdef COLOR_TILES
        add #6, r4
    .else
        add #3, r4
    .endif

    mov #MAP_NAMES_RIGHT, r5
    call calcMapName
  ; Print map name
    mov #16, r1
    DLM2:
        movb (r5)+, r0
        call petChar
        .ifdef COLOR_TILES
            movb #7, (r4)+
        .endif
        movb r0, (r4)+
    sob r1, DLM2
    call drawBuffer
return

calcMapName:
    push r5
    mov SELECTED_MAP, r5
    dec r5
    mul #16, r5
    add (sp)+, r5
return

animatePlayer:
    cmpb UNIT_TILE, #TILE_PLAYER_B
    bne 10$
        movb #TILE_PLAYER_A, UNIT_TILE
        return
    10$:
        movb #TILE_PLAYER_B, UNIT_TILE
return

calculateAndRedraw:
    clr r0
    bisb UNIT_LOC_X, r0        ; no index needed since it's player unit
    sub #VIEWPORT_TILE_WDT / 2, r0
    mov r0, MAP_WINDOW_X

    clr r0
    bisb UNIT_LOC_Y, r0        ; no index needed since it's player unit
    sub #VIEWPORT_TILE_HGT / 2, r0
    mov r0, MAP_WINDOW_Y

    mov #TRUE, redraw_window
return

displayPlayerHealth:
    movb UNIT_HEALTH, r2
    asr r2
    clr r1
    .ifdef COLOR_TILES
        mov #TEXT_BUFFER+OFFS_PLAYER_HEALTH*2, r5
    .else
        mov #TEXT_BUFFER+OFFS_PLAYER_HEALTH, r5
    .endif
    10$:
        cmpb r1, r2
        beq 20$

        .ifdef COLOR_TILES
            mov #0x6607, (r5)+
        .else
            movb #0x66, (r5)+
        .endif
        inc r1
    br 10$
20$:
    bitb #1, UNIT_HEALTH
    bze 30$
        .ifdef COLOR_TILES
            mov #0x5C07, (r5)+
        .else
            movb #0x5C, (r5)+
        .endif
        inc r1
    30$:
        cmpb r1, #6
        beq 1237$

        .ifdef COLOR_TILES
            mov #0x2007, (r5)+
        .else
            movb #0x20, (r5)+
        .endif
        inc r1
    br 30$
1237$: return

fillLdir:
    push r1
        10$:
           movb r0, (r5)+
        sob r1, 10$
    pop r1
return

; Print 3 digit number
; In: r1 = number, r5 = text buffer address
displayDecimalNumber: ; TODO: replace with optimized one
    mov #'0, r2
    clr r0       ; r0: MSW, r1: LSW
    div #100, r0 ; quotient -> r0, remainder -> r1
    add r2, r0
    .ifdef COLOR_TILES
        movb #7, (r5)+
    .endif
    movb r0, (r5)+
    clr r0
    div #10, r0
    add r2, r0
    .ifdef COLOR_TILES
        movb #7, (r5)+
    .endif
    movb r0, (r5)+
    add r2, r1
    .ifdef COLOR_TILES
        movb #7, (r5)+
    .endif
    movb r1, (r5)+
return

displayKeys:
  ; clear keys area
   .ifdef COLOR_TILES
        mov #0x2007, r0
        mov #TEXT_BUFFER+OFFS_DISPLAY_KEYS*2, r5
        10$:
            mov #6, r1
            20$:
               mov r0, (r5)+
            sob r1, 20$
            add #(SCREEN_WIDTH-6)*2, r5
   .else
        mov #' , r0
        mov #TEXT_BUFFER+OFFS_DISPLAY_KEYS, r5
        10$:
            mov #6, r1
            20$:
               movb r0, (r5)+
            sob r1, 20$
            add #SCREEN_WIDTH-6, r5
   .endif
    inc pc ; INC PC + BR repeat two times
    br 10$

   .equiv KEYS, .+2
    mov #0, r0
    bit r0, #KEY_TYPE_SPADE
    bze DKS1
        .ifdef COLOR_TILES
            mov #0x6305, TEXT_BUFFER+OFFS_DISPLAY_KEY1*2
            mov #0x4D05, TEXT_BUFFER+(OFFS_DISPLAY_KEY1+1)*2
            mov #0x4105, TEXT_BUFFER+(OFFS_DISPLAY_KEY1+SCREEN_WIDTH)*2
            mov #0x6705, TEXT_BUFFER+(OFFS_DISPLAY_KEY1+SCREEN_WIDTH+1)*2
        .else
            movb #0x63, TEXT_BUFFER+OFFS_DISPLAY_KEY1
            movb #0x4D, TEXT_BUFFER+OFFS_DISPLAY_KEY1+1
            movb #0x41, TEXT_BUFFER+OFFS_DISPLAY_KEY1+SCREEN_WIDTH
            movb #0x67, TEXT_BUFFER+OFFS_DISPLAY_KEY1+SCREEN_WIDTH+1
        .endif
    DKS1:

    bit r0, KEY_TYPE_HEART
    bze DKS2
        .ifdef COLOR_TILES
            mov #0x6302, TEXT_BUFFER+OFFS_DISPLAY_KEY2*2
            mov #0x4D02, TEXT_BUFFER+(OFFS_DISPLAY_KEY2+1)*2
            mov #0x5302, TEXT_BUFFER+(OFFS_DISPLAY_KEY2+SCREEN_WIDTH)*2
            mov #0x6702, TEXT_BUFFER+(OFFS_DISPLAY_KEY2+SCREEN_WIDTH+1)*2
        .else
            movb #0x63, TEXT_BUFFER+OFFS_DISPLAY_KEY2
            movb #0x4D, TEXT_BUFFER+OFFS_DISPLAY_KEY2+1
            movb #0x53, TEXT_BUFFER+OFFS_DISPLAY_KEY2+SCREEN_WIDTH
            movb #0x67, TEXT_BUFFER+OFFS_DISPLAY_KEY2+SCREEN_WIDTH+1
        .endif
    DKS2:

    bit r0, #KEY_TYPE_STAR
    bze DKS3
        .ifdef COLOR_TILES
            mov #0x6306, TEXT_BUFFER+OFFS_DISPLAY_KEY3*2
            mov #0x4D06, TEXT_BUFFER+(OFFS_DISPLAY_KEY3+1)*2
            mov #0x2A06, TEXT_BUFFER+(OFFS_DISPLAY_KEY3+SCREEN_WIDTH)*2
            mov #0x6706, TEXT_BUFFER+(OFFS_DISPLAY_KEY3+SCREEN_WIDTH+1)*2
        .else
            movb #0x63, TEXT_BUFFER+OFFS_DISPLAY_KEY3
            movb #0x4D, TEXT_BUFFER+OFFS_DISPLAY_KEY3+1
            movb #0x2A, TEXT_BUFFER+OFFS_DISPLAY_KEY3+SCREEN_WIDTH
            movb #0x67, TEXT_BUFFER+OFFS_DISPLAY_KEY3+SCREEN_WIDTH+1
        .endif
    DKS3:
return

setInitialTimers:
    mov #47, r0
    10$:
        movb r0, UNIT_TIMER_A(r0)
        clrb UNIT_TIMER_B(r0)
    sob r0, 10$
    mov #TRUE, CLOCK_ACTIVE
return

; in: r3 = unit number
requestWalkUp:
    movb UNIT_LOC_Y(r3), r2
    cmpb r2, #3
    beq moveNotAllowed
        dec r2

        movb UNIT_LOC_X(r3), r1
        call getTileFromMap ; stores tile idx into r0
        bitb MOVE_TYPE, TILE_ATTRIB(r0)
        bze moveNotAllowed
            call checkForUnit
            bpl moveNotAllowed ; unit on the way
                decb UNIT_LOC_Y(r3)
                mov #TRUE, r0
                return

; in: r3 = unit number
requestWalkDown:
    movb UNIT_LOC_Y(r3), r2
    cmpb r2, #62
    bhis moveNotAllowed
        inc r2

        movb UNIT_LOC_X(r3), r1
        call getTileFromMap ; stores tile idx into r0
        bitb MOVE_TYPE, TILE_ATTRIB(r0)
        bze moveNotAllowed
            call checkForUnit
            bpl moveNotAllowed ; unit on the way
                incb UNIT_LOC_Y(r3)
                mov #TRUE, r0
return

   ; Located in between requestWalkXxxxx to be reached by branch instructions
    moveNotAllowed:
        clr r0
    return

; in: r3 = unit number
requestWalkLeft:
    movb UNIT_LOC_X(r3), r1
    cmpb r0, #5
    beq moveNotAllowed
        dec r1
        movb UNIT_LOC_Y(r3), r2
        call getTileFromMap ; stores tile idx into r0
        bitb MOVE_TYPE, TILE_ATTRIB(r0)
        bze moveNotAllowed
            call checkForUnit
            bpl moveNotAllowed ; unit on the way
                decb UNIT_LOC_X(r3)
                mov #TRUE, r0
                return

; in: r3 = unit number
requestWalkRight:
    movb UNIT_LOC_X(r3), r1
    cmpb r1, #122
    beq moveNotAllowed
        inc r1

        movb UNIT_LOC_Y(r3), r2
        call getTileFromMap ; stores tile idx into r0
        bitb MOVE_TYPE, TILE_ATTRIB(r0)
        bze moveNotAllowed
            call checkForUnit
            bpl moveNotAllowed ; unit on the way
                incb UNIT_LOC_X(r3)
                mov #TRUE, r0
                return

afterMove:
                              ; ;ld a, (MOVE_RESULT)
     tstb r0                  ; or a
     bze AM01                 ; jr z, AM01
     call animatePlayer       ; call ANIMATE_PLAYER
     call calculateAndRedraw  ; call CALCULATE_AND_REDRAW

    .equiv alternate_steps, .+2 ; alternate_steps=$+1
     inc #0                             ; ld a,0
                                        ; inc a
     bic #0xFFF8, alternate_steps       ; and 7
                                        ; ld (alternate_steps),a
            ; ld c,SND_STEP_L
            ; ;or a
            ; jr z,play_step_sound
            ; ld c,SND_STEP_R
            ; cp 4
            ; jr z,play_step_sound
            ; ld c,0
    play_step_sound:
            ; ld a,c
            ; or a
            ; call nz,PLAY_SOUND

    AM01:
    .equiv KEY_FAST, .+2
                             ; ld a, (KEY_FAST)
    tstb #0                  ; and a
    bnz KEYR3                ; jr nz, KEYR3
                             ; ;ld a, 13
                             ; ;ld (KEYTIMER), a
                             ; ld hl, KEY_FAST
        inc KEY_FAST         ; inc (hl)
KEYR4: jmp mainGameLoop      ; jp MAIN_GAME_LOOP

KEYR3:
                             ; ;ld a, 6
                             ; ;ld (KEYTIMER), a
jmp mainGameLoop            ; jp MAIN_GAME_LOOP

; This routine checks a specific place on the map specified
; in MAP_X and MAP_Y to see if there is a unit present at that spot.
; If so, the unit# will be stored in UNIT_FIND otherwise 255 will be stored.
;  in: r1 = X
;      r2 = Y
;      r3 - can't be corrupted
; out: r4 = unit idx
checkForUnit:
    mov #28, r0
    clr r4
    mov #UNIT_TYPE, r5
    cfu.unitsLoop:
        tstb (r5)+
        bnz cfu.compareCoordinates
    cfu.nextUnit:
        inc r4
    sob r0, cfu.unitsLoop

    mov #-1, r4
return

    cfu.compareCoordinates:
        cmpb UNIT_LOC_X(r4), r1
        bne cfu.nextUnit

        cmpb UNIT_LOC_Y(r4), r2
        bne cfu.nextUnit

        tst r4
    return

; This routine will return the tile for a specific X/Y on the map.
; You must first define MAP_X and MAP_Y.
; The result is stored in TILE.

; in: r1 = X
;     r2 = Y
; out: r0 = tile idx
;      r5 = tile addres on map
getTileFromMap:
    mov r2, r5
    swab r5 ; swab clears the carry flag as a bonus
    ror r5
    bisb r1, r5
  ; r5 = Y * 128 + X
    add #MAP, r5
    clr r0
    bisb (r5), r0
return

fireUp:
    tst SELECTED_WEAPON
    bze 1237$
        cmp SELECTED_WEAPON, #ID_PISTOL
        bne fireUpPlasma
          ; Fire up pistol
            tst AMMO_PISTOL
            bze 1237$
                call fireSearchSlot
                bnz 1237$
                    mov #DATA_FIRE_UP_PISTOL, r1
                    jmp afterFire
1237$: return

fireDown:
    tst SELECTED_WEAPON
    bze 1237$
        cmp SELECTED_WEAPON, #ID_PISTOL
        bne fireDownPlasma
          ; Fire down pistol
            tst AMMO_PISTOL
            bze 1237$
                call fireSearchSlot
                bnz 1237$
                    mov #DATA_FIRE_DOWN_PISTOL, r1
                    jmp afterFire
1237$: return

fireLeft:
    tst SELECTED_WEAPON
    bze 1237$
        cmp SELECTED_WEAPON, #ID_PISTOL
        bne fireLeftPlasma
          ; Fire left pistol
            tst AMMO_PISTOL
            bze 1237$
                call fireSearchSlot
                bnz 1237$
                    mov #DATA_FIRE_LEFT_PISTOL, r1
                    jmp afterFire
1237$: return

fireRight:
    tst SELECTED_WEAPON
    bze 1237$
        cmp SELECTED_WEAPON, #ID_PISTOL
        bne fireRightPlasma
          ; Fire right pistol
            tst AMMO_PISTOL
            bze 1237$
                call fireSearchSlot
                bnz 1237$
                    mov #DATA_FIRE_RIGHT_PISTOL, r1
                    jmp afterFire
1237$: return

fireUpPlasma:
return
fireDownPlasma:
return
fireLeftPlasma:
return
fireRightPlasma:
return

fireSearchSlot:
    mov #28, r3
    mov #UNIT_TYPE+28, r5
    10$:
        tstb (r5)
        bze 1237$ ; slot found, return Z flag
            inc r5
            inc r3
            cmp r3, #32
            bne 10$
        clz ; slot not found, flip Z to NZ
1237$: return


afterFire:
    movb (r1)+, UNIT_TYPE(r3)
    movb (r1)+, UNIT_TILE(r3)
    movb (r1)+, UNIT_A(r3)
    movb (r1), UNIT_B(r3)
    movb (r1), PLASMA_ACT
    clrb UNIT_TIMER_A(r3)
    movb UNIT_LOC_X, UNIT_LOC_X(r3)
    movb UNIT_LOC_Y, UNIT_LOC_Y(r3)
    mov r3, UNIT
    cmp SELECTED_WEAPON, #ID_PLASMA_GUN
    beq af.plasma_selected
          ; mov #SND_PISTOL, r0
          ; call playSound
            dec AMMO_PISTOL
            jmp displayWeapon
    af.plasma_selected:
          ; mov #SND_PLASMAGUN, r0
          ; call playSound
            dec AMMO_PLASMA
            jmp displayWeapon

; Fire type data blocks
; AI routine ID, tile number, travel distance, weapon type
DATA_FIRE_UP_PISTOL:    .byte 12, 244, 10/2, 0
DATA_FIRE_UP_PLASMA:    .byte 12, 240, 10/2, 1
DATA_FIRE_DOWN_PISTOL:  .byte 13, 244, 10/2, 0
DATA_FIRE_DOWN_PLASMA:  .byte 13, 240, 10/2, 1
DATA_FIRE_LEFT_PISTOL:  .byte 14, 245, 10/2, 0
DATA_FIRE_LEFT_PLASMA:  .byte 14, 241, 10/2, 1
DATA_FIRE_RIGHT_PISTOL: .byte 15, 245, 10/2, 0
DATA_FIRE_RIGHT_PLASMA: .byte 15, 241, 10/2, 1


    .include "init_game.s"
    .include "background_tasks.s"
    .include "display_weapon.s"
    .include "draw_buffer.s"
    .include "draw_map_window.s"
    .include "print_info.s"
    .include "v_blank_int_handler.s"
    .include "vars.s"
    .include "unzx0.s"

LOAD_MSG2:       .ascii "LOADING: "
MAP_NAMES_RIGHT: .ascii "01- RESEARCH LAB"
                 .ascii "02- HEADQUARTERS"
                 .ascii "03-  THE VILLAGE"
                 .ascii "04-  THE ISLANDS"
                 .ascii "05-     DOWNTOWN"
                 .ascii "06-PI UNIVERSITY"
                 .ascii "07- MORE ISLANDS"
                 .ascii "08-  ROBOT HOTEL"
                 .ascii "09-  FOREST MOON"
                 .ascii "10-  DEATH TOWER"
                 .ascii "11-  RIVER DEATH"
                 .ascii "12-       BUNKER"
                 .ascii "13- CASTLE ROBOT"
                 .ascii "14-ROCKET CENTER"
                 .ascii "15-      PILANDS"

INTRO_TEXT:  .incbin "build/intro_text.zx0"
SCR_TEXT: .ifdef COLOR_TILES
              .incbin "build/color_scr_text.zx0"
          .else
              .incbin "build/scr_text.zx0"
          .endif
SCR_ENDGAME: .incbin "build/scr_endgame.zx0"

    .even

DIFFICULTY: .word 1

FILES_DATA:
    title.bin:
        .word TITLE_START
        .word 0
        .word 0
MAPS:
    .irpc idx,abcdefghijklmno
        level_\idx:
            .word LEVEL_MAP
            .word 0
            .word 0
    .endr

TILESET:
    .ifdef COLOR_TILES
        .incbin "build/color_tileset.uknc"
         .equiv DESTRUCT_PATH, TILESET             ; Destruct path array (256 bytes)
         .equiv TILE_ATTRIB,   DESTRUCT_PATH + 256 ; Tile attrib array (256 bytes)
         .equiv TILE_DATA, TILE_ATTRIB + 256
         .equiv TL_OFFSET,  1 ; tile character top-left
         .equiv TM_OFFSET,  3 ; tile character top-middle
         .equiv TR_OFFSET,  5 ; tile character top-right
         .equiv ML_OFFSET,  7 ; tile character middle-left
         .equiv MM_OFFSET,  9 ; tile character middle-middle
         .equiv MR_OFFSET, 11 ; tile character middle-right
         .equiv BL_OFFSET, 13 ; tile character bottom-left
         .equiv BM_OFFSET, 15 ; tile character bottom-middle
         .equiv BR_OFFSET, 17 ; tile character bottom-right
    .else
        .incbin "resources/c64/tileset.c64"
        .equiv DESTRUCT_PATH, TILESET             ; Destruct path array (256 bytes)
        .equiv TILE_ATTRIB,   DESTRUCT_PATH + 256 ; Tile attrib array (256 bytes)
        .equiv TILE_DATA_TL,  TILE_ATTRIB  + 256  ; Tile character top-left (256 bytes)
        .equiv TILE_DATA_TM,  TILE_DATA_TL + 256  ; Tile character top-middle (256 bytes)
        .equiv TILE_DATA_TR,  TILE_DATA_TM + 256  ; Tile character top-right (256 bytes)
        .equiv TILE_DATA_ML,  TILE_DATA_TR + 256  ; Tile character middle-left (256 bytes)
        .equiv TILE_DATA_MM,  TILE_DATA_ML + 256  ; Tile character middle-middle (256 bytes)
        .equiv TILE_DATA_MR,  TILE_DATA_MM + 256  ; Tile character middle-right (256 bytes)
        .equiv TILE_DATA_BL,  TILE_DATA_MR + 256  ; Tile character bottom-left (256 bytes)
        .equiv TILE_DATA_BM,  TILE_DATA_BL + 256  ; Tile character bottom-middle (256 bytes)
        .equiv TILE_DATA_BR,  TILE_DATA_BM + 256  ; Tile character bottom-right (256 bytes)
    .endif

    .equiv TEXT_BUFFER, . ; text buffer (shadow screen), 1000 bytes (40x25)
    .equiv TEXT_BUFFER_PREV, TEXT_BUFFER + 1000

    .ifdef DEBUG
        .=TEXT_BUFFER_PREV + 1000
    .endif

end:

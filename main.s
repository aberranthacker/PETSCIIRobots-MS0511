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
    call initGame
    call setDiffLevel
    call animatePlayer
    call calculateAndRedraw
    call drawMapWindow
    call displayPlayerHealth
    call displayKeys
    call displayWeapon

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

        mov #5, KEYTIMER        ; ld hl, KEYTIMER
                                ; ld (hl), 5

                                ; ld hl, TECLADO ; redefined keys
    checkKbdUp:
        bit #KEYMAP_UP, KEYBOARD_SCANNER
        bze checkKbdDown
        ;:bpt
            clr r3 ; player unit number is 0
            mov #MOVE_WALK, MOVE_TYPE
            call requestWalkUp
            jmp afterMove
    checkKbdDown:
        bit #KEYMAP_DOWN, KEYBOARD_SCANNER
        bze checkKbdLeft
            clr r3 ; player unit number is 0
            mov #MOVE_WALK, MOVE_TYPE
            call requestWalkDown
            jmp afterMove
    checkKbdLeft:
        bit #KEYMAP_LEFT, KEYBOARD_SCANNER
        bze checkKbdRight
            clr r3 ; player unit number is 0
            mov #MOVE_WALK, MOVE_TYPE
            call requestWalkLeft
            jmp afterMove
    checkKbdRight:
        bit #KEYMAP_RIGHT, KEYBOARD_SCANNER
        bze checkKbdFireUp
            clr r3 ; player unit number is 0
            mov #MOVE_WALK, MOVE_TYPE
            call requestWalkRight
            jmp afterMove
    checkKbdFireUp:
            ; inc hl
            ; cp (hl)
            ; jr nz, checkKbdFireDown
            ; call FIRE_UP
            ; call CLEAR_KEY_BUFFER
    jmp mainGameLoop


petChar: ; 65..90
    cmp r0, #'A
    blo 1237$
        cmp r0, #'Z
        bhi 1237$
            sub #64, r0
1237$: return

displayLoadMessage2:
    mov #TEXT_BUFFER + 3+10 * SCREEN_WIDTH, r4
    mov #LOAD_MSG2, r5
    mov #9, r1

    DLM1:
        ; wait
        movb (r5)+, r0
        call petChar
        movb r0, (r4)+

        ; cmpb r0, #32 ; space char
        ; beq DLM1.skip
        ;     push r0, r1, r2, r3, r4, r5
        ;         call drawBuffer
        ;     pop r5, r4, r3, r2, r1, r0
        ; DLM1.skip:
    sob r1, DLM1

    add #6, r4

    mov #MAP_NAMES_RIGHT, r5
    call calcMapName
    add #3, r5 ; Skip digits and dash symbol
  ; Print map name
    mov #16-3, r1
    DLM2:
        movb (r5)+, r0
        call petChar
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
    mov #TEXT_BUFFER+OFFS_PLAYER_HEALTH, r5
    10$:
        cmpb r1, r2
        beq 20$

        movb #0x66, (r5)+
        inc r1
    br 10$
20$:
    bitb #1, UNIT_HEALTH
    bze 30$
        movb #0x5C, (r5)+
        inc r1
    30$:
        cmpb r1, #6
        beq 1237$

        movb #0x20, (r5)+
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
    movb r0, (r5)+
    clr r0
    div #10, r0
    add r2, r0
    movb r0, (r5)+
    add r2, r1
    movb r1, (r5)+
return

displayKeys:
    mov #' , r0
    mov #TEXT_BUFFER+OFFS_DISPLAY_KEYS, r5
    10$:
        mov #6, r1
        20$:
           movb r0, (r5)+
        sob r1, 20$
        add #SCREEN_WIDTH-6, r5
    inc pc ; INC PC + BR repeat two times
    br 10$

   .equiv KEYS, .+2
    mov #0, r0
    bit r0, #KEY_TYPE_SPADE
    bze DKS1
        movb #0x63, TEXT_BUFFER+OFFS_DISPLAY_KEY1
        movb #0x4D, TEXT_BUFFER+OFFS_DISPLAY_KEY1+1
        movb #0x41, TEXT_BUFFER+OFFS_DISPLAY_KEY1+SCREEN_WIDTH
        movb #0x67, TEXT_BUFFER+OFFS_DISPLAY_KEY1+SCREEN_WIDTH+1
    DKS1:

    bit r0, KEY_TYPE_HEART
    bze DKS2
        movb #0x63, TEXT_BUFFER+OFFS_DISPLAY_KEY2
        movb #0x4D, TEXT_BUFFER+OFFS_DISPLAY_KEY2+1
        movb #0x53, TEXT_BUFFER+OFFS_DISPLAY_KEY2+SCREEN_WIDTH
        movb #0x67, TEXT_BUFFER+OFFS_DISPLAY_KEY2+SCREEN_WIDTH+1
    DKS2:

    bit r0, #KEY_TYPE_STAR
    bze DKS3
        movb #0x63, TEXT_BUFFER+OFFS_DISPLAY_KEY3
        movb #0x4D, TEXT_BUFFER+OFFS_DISPLAY_KEY3+1
        movb #0x2A, TEXT_BUFFER+OFFS_DISPLAY_KEY3+SCREEN_WIDTH
        movb #0x67, TEXT_BUFFER+OFFS_DISPLAY_KEY3+SCREEN_WIDTH+1
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
    movb UNIT_LOC_Y(r3), r0
    cmpb r0, #3
    beq moveNotAllowed

    mov r0, MAP_Y
    dec MAP_Y

    movb UNIT_LOC_X(r3), MAP_X
    call getTileFromMap
  ; r0 now contains tile idx
    bitb MOVE_TYPE, TILE_ATTRIB(r0)
    bze moveNotAllowed

    call checkForUnit
    bpl moveNotAllowed ; unit on the way

    decb UNIT_LOC_Y(r3)
    mov #TRUE, r0
return

; in: r3 = unit number
requestWalkDown:
    movb UNIT_LOC_Y(r3), r0
    cmpb r0, #62
    bhis moveNotAllowed

    mov r0, MAP_Y
    inc MAP_Y

    movb UNIT_LOC_X(r3), MAP_X
    call getTileFromMap
  ; r0 now contains tile idx
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
    movb UNIT_LOC_X(r3), r0
    cmpb r0, #5
    beq moveNotAllowed

    mov r0, MAP_X
    dec MAP_X

    movb UNIT_LOC_Y(r3), MAP_Y
    call getTileFromMap
  ; r0 now contains tile idx
    bitb MOVE_TYPE, TILE_ATTRIB(r0)
    bze moveNotAllowed

    call checkForUnit
    bpl moveNotAllowed ; unit on the way

    decb UNIT_LOC_X(r3)
    mov #TRUE, r0
return

; in: r3 = unit number
requestWalkRight:
    movb UNIT_LOC_X(r3), r0
    cmpb r0, #122
    beq moveNotAllowed

    mov r0, MAP_X
    inc MAP_X

    movb UNIT_LOC_Y(r3), MAP_Y
    call getTileFromMap
  ; r0 now contains tile idx
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
checkForUnit:
    mov #28, r1
    clr r4
    mov #UNIT_TYPE, r5
    cfu.unitsLoop:
        tstb (r5)+
        bnz cfu.compareCoordinates
    cfu.nextUnit:
        inc r4
    sob r1, cfu.unitsLoop

    mov #-1, UNIT_FIND
return

    cfu.compareCoordinates:
        cmpb UNIT_LOC_X(r4), MAP_X
        bne cfu.nextUnit

        cmpb UNIT_LOC_Y(r4), MAP_Y
        bne cfu.nextUnit

        mov r4, UNIT_FIND
    return

; This routine will return the tile for a specific X/Y on the map.
; You must first define MAP_X and MAP_Y.
; The result is stored in TILE.
getTileFromMap: ; TODO: use registers to provide MAP_Y, MAP_X, and return TILE and MAP_ADDR
    mov MAP_Y, r1
    swab r1
    asr r1
    bisb MAP_X, r1
  ; r1 = MAP_Y * 128 + MAP_X
    add #MAP, r1
    mov r1, MAP_ADDR
    clr r0
    bisb (r1), r0
    mov r0, TILE
return

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
                 .even

    .include "init_game.s"
    .include "background_tasks.s"
    .include "display_weapon.s"
    .include "draw_buffer.s"
    .include "draw_map_window.s"
    .include "print_info.s"
    .include "v_blank_int_handler.s"
    .include "vars.s"
    .include "unzx0.s"

PET_FONT:    .incbin "build/c64tileset.gfx"
INTRO_TEXT:  .incbin "build/intro_text.zx0"
SCR_TEXT:    .incbin "build/scr_text.zx0"
SCR_ENDGAME: .incbin "build/scr_endgame.zx0"
    .even

DIFFICULTY: .word 1

PET_FONT_LUT:
    current_char = 0
    .rept 256
       .word PET_FONT + current_char * 16
        current_char = current_char + 1
    .endr

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

TILESET: .incbin "resources/c64/tileset.c64"
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

    .equiv TEXT_BUFFER, . ; text buffer (shadow screen), 1000 bytes (40x25)
    .equiv TEXT_BUFFER_PREV, TEXT_BUFFER + 1000

    .ifdef DEBUG
        .=TEXT_BUFFER_PREV + 1000
    .endif

end:

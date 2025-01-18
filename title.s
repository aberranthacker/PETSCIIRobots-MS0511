       .list

       .title "PETSCII Robots title screen"

       .include "hwdefs.s"
       .include "macros.s"
       .include "defs.s"

       .global start

       .=TITLE_START

start:
    mtps #PR0
    call showTitle

    call drawFace

    titleLoop: ; {{{
        mov KEYBOARD_SCANNER, r5
        asr r5
        bcs 10$
            .equiv UP_ALREADY_PRESSED, .+2
            clr #0
            br 20$
        10$:
        call upPressed
        20$:

        asr r5
        bcs 30$
            .equiv DOWN_ALREADY_PRESSED, .+2
            clr #0
            br 40$
        30$:
        call downPressed
        40$:

        asr r5
        bcs 50$
            .equiv LEFT_ALREADY_PRESSED, .+2
            clr #0
            br 60$
        50$:
        call leftPressed
        60$:

        asr r5
        bcs 70$
            .equiv RIGHT_ALREADY_PRESSED, .+2
            clr #0
            br 80$
        70$:
        call rightPressed
        80$:

        asr r5
        bcs 90$
            .equiv RETURN_ALREADY_PRESSED, .+2
            clr #0
            br 100$
        90$:
        call returnPressed
        100$:

        asr r5
        bcs 110$
            .equiv KEYPAD_RETURN_ALREADY_PRESSED, .+2
            clr #0
            br 120$
        110$:
        call keypadReturnPressed
        120$:
    jmp titleLoop ; }}}

upPressed:
    tst UP_ALREADY_PRESSED
    bnz 1237$
        com UP_ALREADY_PRESSED
1237$: return

downPressed:
    tst DOWN_ALREADY_PRESSED
    bnz 1237$
        com DOWN_ALREADY_PRESSED
1237$: return

leftPressed:
    tst LEFT_ALREADY_PRESSED
    bnz 1237$
        com LEFT_ALREADY_PRESSED
1237$: return

rightPressed:
    tst RIGHT_ALREADY_PRESSED
    bnz 1237$
        com RIGHT_ALREADY_PRESSED
1237$: return

returnPressed:
    tst RETURN_ALREADY_PRESSED
    bnz 1237$
        com RETURN_ALREADY_PRESSED
        call nextDifficulty
1237$: return

keypadReturnPressed:
    tst KEYPAD_RETURN_ALREADY_PRESSED
    bnz 1237$
        com KEYPAD_RETURN_ALREADY_PRESSED
        call nextDifficulty
1237$: return

showTitle:
    _ppu_enqueue PPU.SetPalette, Black_palette
    _unZX0 TITLE_GFX, FB

    _ppu_enqueue PPU.SetPalette, Blue_palette
    call wait100ms
    _ppu_enqueue PPU.SetPalette, Dark_palette
    call wait100ms
    _ppu_enqueue PPU.SetPalette, Base_palette

    return

wait100ms:
    mov #5, r0
    10$:
        wait
    sob r0, 10$
    return

nextDifficulty:
    ; inc DIFFICULTY
    ; cmp DIFFICULTY, #2
    ; blos drawFace
    ;     clr DIFFICULTY

drawFace:
   .equiv FACE_WIDTHB, 8
   .equiv FACE_HEIGHT, 26
   .equiv FACE_SIZEB, FACE_WIDTHB * FACE_HEIGHT
   .equiv FACE_OFFSET, 28*2 + 74*LINE_WIDTHB

    ; mov DIFFICULTY, r5
    mul #FACE_SIZEB, r5
    add #FACES, r5
    mov #LINE_WIDTHB - FACE_WIDTHB, r0

    mov #FB + FACE_OFFSET, r4
    mov #FACE_HEIGHT, r1
    10$:
        bic #0xF0F0, (r4)+
        add #4, r4
        bic #0x0F0F, (r4)+
        add r0, r4
    sob r1, 10$

    mov #FB + FACE_OFFSET, r4
    mov #FACE_HEIGHT, r1
    20$:
        bis (r5)+, (r4)+
        mov (r5)+, (r4)+
        mov (r5)+, (r4)+
        bis (r5)+, (r4)+
        add r0, r4
    sob r1, 20$

    return

TITLE_GFX: .incbin "build/title.gfx.zx0"
           .even
FACES:     .incbin "build/faces.gfx"

StartGameStr:  .asciz "START GAME"
SelectMapStr:  .asciz "SELECT MAP"
DifficultyStr: .asciz "DIFFICULTY"
ControlsStr:   .asciz "CONTROLS"

MAP_NAMES:
    .asciz "01-RESEARCH LAB "
    .asciz "02-HEADQUARTERS "
    .asciz "03-THE VILLAGE  "
    .asciz "04-THE ISLANDS  "
    .asciz "05-DOWNTOWN     "
    .asciz "06-PI UNIVERSITY"
    .asciz "07-MORE ISLANDS "
    .asciz "08-ROBOT HOTEL  "
    .asciz "09-FOREST MOON  "
    .asciz "10-DEATH TOWER  "
    .asciz "11-RIVER DEATH  "
    .asciz "12-BUNKER       "
    .asciz "13-CASTLE ROBOT "
    .asciz "14-ROCKET CENTER"
    .asciz "15-PILANDS      "

    .even
Base_palette: ;-----------------------------------------------------------------
        .if AUX_SCREEN_LINES_COUNT != 0
    .byte      0, setOffscreenColors
    .word         BLACK | BLUE  << 4 | BLACK << 8 | BLACK << 12
    .word         BLACK | BLACK << 4 | BLACK << 8 | BLACK << 12
        .endif
    .word      0, setCursorScalePalette|cursorGraphic, LINE_SCALE<<4|RGB
    .byte      1, setColors, Black, Cyan, brCyan, White
    .word untilEndOfScreen
;-------------------------------------------------------------------------------
Dark_palette: ;-----------------------------------------------------------------
    .word      0, setCursorScalePalette|cursorGraphic, LINE_SCALE<<4|RGB
    .byte      1, setColors, Black, Blue, Cyan, Gray
    .word untilEndOfScreen
;-------------------------------------------------------------------------------
Blue_palette: ;-----------------------------------------------------------------
    .word      0, setCursorScalePalette|cursorGraphic, LINE_SCALE<<4|RGB
    .byte      1, setColors, Black, Black, Blue, Blue
    .word untilEndOfScreen
;-------------------------------------------------------------------------------
Black_palette: ;----------------------------------------------------------------
    .word      0, setCursorScalePalette|cursorGraphic, LINE_SCALE<<4|RGB
    .byte      1, setColors, Black, Black, Black, Black
    .word untilEndOfScreen
;-------------------------------------------------------------------------------

end:

printIntroMessage:
    mov #INTRO_MESSAGE, r5

;       in: r5 = message addr
; corrupts: r0, r1, r4, r5
printInfo:
    call scrollInfo
    .ifdef COLOR_TILES
        mov #TEXT_BUFFER + OFFS_PRINT_INFO*2, r4
    .else
        mov #TEXT_BUFFER + OFFS_PRINT_INFO, r4
    .endif
    PI01:
        movb (r5)+, r0
        bze 1237$
        bmi PI02

        call petChar
        .ifdef COLOR_TILES
            movb #3, (r4)+
        .endif
        movb r0, (r4)+
    br PI01

    PI02:
        .ifdef COLOR_TILES
            mov #TEXT_BUFFER + OFFS_PRINT_INFO*2, r4
        .else
            mov #TEXT_BUFFER + OFFS_PRINT_INFO, r4
        .endif
        call scrollInfo
    br PI01
1237$: return

scrollInfo:
    push r5
    push r4
        .ifdef COLOR_TILES
            mov #TEXT_BUFFER + (OFFS_PRINT_INFO - SCREEN_WIDTH)*2, r5
            mov #TEXT_BUFFER + (OFFS_PRINT_INFO - SCREEN_WIDTH*2)*2, r4
            mov #32, r1
        .else
            mov #TEXT_BUFFER + OFFS_PRINT_INFO - SCREEN_WIDTH, r5
            mov #TEXT_BUFFER + OFFS_PRINT_INFO - SCREEN_WIDTH*2, r4
            mov #32/2, r1
        .endif
        10$:
            mov (r5)+, (r4)+
        sob r1, 10$;

        .ifdef COLOR_TILES
            mov #TEXT_BUFFER + OFFS_PRINT_INFO*2, r5
            mov #TEXT_BUFFER + (OFFS_PRINT_INFO - SCREEN_WIDTH)*2, r4
            mov #32, r1
        .else
            mov #TEXT_BUFFER + OFFS_PRINT_INFO*2, r5
            mov #TEXT_BUFFER + OFFS_PRINT_INFO - SCREEN_WIDTH, r4
            mov #32/2, r1
        .endif
        20$:
            mov (r5)+, (r4)+
        sob r1, 20$;

        .ifdef COLOR_TILES
            mov #TEXT_BUFFER + OFFS_PRINT_INFO*2, r5
            mov #32, r1
            mov #0x2007, r0
        .else
            mov #TEXT_BUFFER + OFFS_PRINT_INFO, r5
            mov #32/2, r1
            mov #0x2020, r0
        .endif
        30$:
            mov r0, (r5)+
        sob r1, 30$
        call drawBuffer
    pop r4
    pop r5
return

INTRO_MESSAGE:  .ascii "WELCOME TO PETSCII ROBOTS!\xFF"
                .ascii "BY DAVID MURRAY 2021\xFF"
                .asciz "UKNC PORT BY OLEG TSYMBALYUK"
MSG_BLOCKED:    .asciz "BLOCKED!"
MSG_EMPUSED:    .ascii "EMP ACTIVATED!\xFF"
                .asciz "NEARBY ROBOTS REBOOTING."
MSG_CANTMOVE:   .asciz "CAN'T MOVE THAT!"
MSG_SEARCHING:  .asciz "SEARCHING"
MSG_NOTFOUND:   .asciz "NOTHING FOUND HERE."
MSG_FOUNDKEY:   .asciz "YOU FOUND A KEY CARD!"
MSG_FOUNDGUN:   .asciz "YOU FOUND A PISTOL!"
MSG_FOUNDEMP:   .asciz "YOU FOUND AN EMP DEVICE!"
MSG_FOUNDBOMB:  .asciz "YOU FOUND A TIMEBOMB!"
MSG_FOUNDPLAS:  .asciz "YOU FOUND A PLASMA GUN!"
MSG_FOUNDMED:   .asciz "YOU FOUND A MEDKIT!"
MSG_FOUNDMAG:   .asciz "YOU FOUND A MAGNET!"
MSG_MUCHBET:    .asciz "AHHH, MUCH BETTER!"
MSG_TERMINATED: .asciz "YOU'RE TERMINATED!"
MSG_TRANS1:     .ascii "TRANSPORTER WON'T ACTIVATE\xFF"
                .asciz "UNTIL ALL ROBOTS DESTROYED"
MSG_ELEVATOR:   .ascii "[ ELEVATOR PANEL ]  DOWN\xFF"
                .asciz "[  SELECT LEVEL  ]  OPENS"
MSG_LEVELS:     .asciz "[                ]  DOOR"
MSG_PAUSED:     .ascii "EXIT GAME (Y/N)?\xFF"
                .asciz "TOGGLE SOUND (S)"
;MSG_MUSICON    db "music on."
;MSG_MUSICOFF   db "music off.",0

GAMEOVER1:      .byte 0x70,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x6E
GAMEOVER2:      .byte 0x5D,0x07,0x01,0x0D,0x05,0x20,0x0F,0x16,0x05,0x12,0x5D
GAMEOVER3:      .byte 0x6D,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x7D

                .even

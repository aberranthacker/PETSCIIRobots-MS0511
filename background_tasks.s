backgroundTasks:
   .equiv redraw_window, .+2
    tst #0
    bze unitAI

    tst BGTIMER1
    bze unitAI

    clr redraw_window
    call drawMapWindow

unitAI:
  ; Now check to see if it is time to run background tasks
    tst BGTIMER1
    bnz AI000
        return

    AI000:
        clr BGTIMER1 ; reset background timer
        clr UNIT

    aiLoop:
      ; ALL AI routines must JMP back to here at the end.
       .equiv UNIT, .+2    ; Current unit being processed
        inc #0
        mov UNIT, r3
        cmp r3, #64 ; end of units
        bne AI001
            return  ; return control to main program

        AI001:
        tstb UNIT_TYPE(r3) ; Does unit exist?
        bze aiLoop

        AI002:
      ; Unit found to exist, now check it's timer.
      ; unit code won't run until timer hits zero.
        tstb UNIT_TIMER_A(r3)
        bze AI003
            decb UNIT_TIMER_A(r3)
            br aiLoop

        AI003:
      ; Unit exists and timer has triggered
      ; The unit type determines which AI routine is run.
        movb UNIT_TYPE(r3), r0
        cmpb r0, #24 ; max different unit types in chart
        bhi aiLoop   ; abort if greater

        asl r0
        jmp @AI_ROUTINES_LUT(r0)

AI_ROUTINES_LUT:
       .word aiLoop; DUMMY_ROUTINE       ; UNIT TYPE 00  ; non-existent unit
       .word aiLoop; DUMMY_ROUTINE       ; UNIT TYPE 01  ; player unit - can't use
       .word leftRightDroid              ; UNIT TYPE 02
       .word upDownDroid                 ; UNIT TYPE 03
       .word aiLoop ; hoverAttack        ; UNIT TYPE 04
       .word aiLoop ; waterDroid         ; UNIT TYPE 05
       .word aiLoop ; timeBomb           ; UNIT TYPE 06
       .word aiLoop ; transporterPad     ; UNIT TYPE 07
       .word aiLoop ; deadRobot          ; UNIT TYPE 08
       .word aiLoop ; evilbot            ; UNIT TYPE 09
       .word aiDoor                      ; UNIT TYPE 10
       .word aiLoop ; smallExplosion     ; UNIT TYPE 11
       .word aiLoop ; pistolFireUp       ; UNIT TYPE 12
       .word aiLoop ; pistolFireDown     ; UNIT TYPE 13
       .word aiLoop ; pistolFireLeft     ; UNIT TYPE 14
       .word aiLoop ; pistolFireRight    ; UNIT TYPE 15
       .word trashCompactor              ; UNIT TYPE 16
       .word aiLoop ; upDownRollerbot    ; UNIT TYPE 17
       .word aiLoop ; leftRightRollerbot ; UNIT TYPE 18
       .word aiLoop ; elevator           ; UNIT TYPE 19
       .word aiLoop ; magnet             ; UNIT TYPE 20
       .word aiLoop ; magnetizedRobot    ; UNIT TYPE 21
       .word aiLoop ; waterRaftLr        ; UNIT TYPE 22
       .word aiLoop ; dematerialize      ; UNIT TYPE 23

ailpCheckForWindowRedraw:
    call checkForWindowRedraw
    jmp aiLoop

; in: r3 = unit number
checkForWindowRedraw:
  ; Check horizontal position
    cmpb UNIT_LOC_X(r3), MAP_WINDOW_X
    blo 1237$

    mov MAP_WINDOW_X, r1
    add #VIEWPORT_TILE_WDT, r1

    cmpb UNIT_LOC_X(r3), r1
    bhis 1237$

  ; Now check vertical
    cmpb UNIT_LOC_Y(r3), MAP_WINDOW_Y
    blo 1237$

    mov MAP_WINDOW_Y, r1
    add #VIEWPORT_TILE_HGT, r1

    cmpb UNIT_LOC_Y(r3), r1
    bhis 1237$

    mov #TRUE, redraw_window
1237$: return


; In this AI routine, the droid simply goes LEFT until it hits an object,
; and then reverses direction and does the same, bouncing back and forth.
; in: r3 = unit number
leftRightDroid:
    call hoverbotAnimate
    movb #HOVERBOT_MOVE_SPD, UNIT_TIMER_A(r3)
    tstb UNIT_A(r3) ; directrion: 0=LEFT, 1=RIGHT
    bnz LRD01

    mov #MOVE_HOVER, MOVE_TYPE
    call requestWalkLeft
    bnz LRD02
        mov UNIT, r3
        movb #1, UNIT_A(r3) ; change direction
        jmp ailpCheckForWindowRedraw

    LRD01:
    mov #MOVE_HOVER, MOVE_TYPE
    call requestWalkRight
    bnz LRD02
        clrb UNIT_A(r3)

    LRD02:
    jmp ailpCheckForWindowRedraw

; In this AI routine, the droid simply goes UP until it hits an object,
; and then reverses direction and does the same, bouncing back and forth.
; in: r3 = unit number
upDownDroid:
    call hoverbotAnimate
    movb #HOVERBOT_MOVE_SPD, UNIT_TIMER_A(r3)
    tstb UNIT_A(r3) ; directrion: 0=UP, 1=DOWN
    bnz UDD01

    mov #MOVE_HOVER, MOVE_TYPE
    call requestWalkUp
    bnz UDD02
        movb #1, UNIT_A(r3) ; change direction
        jmp ailpCheckForWindowRedraw

    UDD01:
    mov #MOVE_HOVER, MOVE_TYPE
    call requestWalkDown
    bnz UDD02
        clrb UNIT_A(r3)

    UDD02:
    jmp ailpCheckForWindowRedraw

; in: r3 = unit number
hoverbotAnimate:
    tstb UNIT_TIMER_B(r3)    ; timer reached 0?
    bze 10$                  ; yes, alter tile
        decb UNIT_TIMER_B(r3) ; no, decrease counter
        return

    10$:
    movb #HOVERBOT_ANIM_SPEED, UNIT_TIMER_B(r3) ; RESET ANIMATE TIMER
    cmpb UNIT_TILE(r3), #TILE_HOVERBOT_A
    bne 20$
        movb #TILE_HOVERBOT_B, UNIT_TILE(r3)
        return

    20$:
    movb #TILE_HOVERBOT_A, UNIT_TILE(r3)
    return

; This routine handles automatic sliding doors.
; UNIT_B register means:
; 0=opening-A 1=opening-B 2=OPEN 3=closing-A 4=closing-B 5-CLOSED
;
; in: r3 = unit number
aiDoor:
    movb UNIT_B(r3), r1
    cmp r1, #5 ; make sure number is in bounds
    bhi 10$
        asl r1
        jmp @AI_DOOR_LUT(r1)
    10$:
    jmp aiLoop ;-SHOULD NEVER NEED TO HAPPEN

AI_DOOR_LUT:
    .word doorOpenA
    .word doorOpenB
    .word doorOpenFull
    .word doorCloseA
    .word doorCloseB
    .word doorCloseFull

; in: r3 = unit number
doorOpenA:
    tstb UNIT_A(r3)
    bnz DOA1

  ; HORIZONTAL DOOR
    mov #0x58, DOORPIECE1 ; 88
    mov #0x59, DOORPIECE2 ; 89
    mov #0x56, DOORPIECE3 ; 86
    call drawHorizontalDoor
    br DOA2

    DOA1:
  ; VERTICAL DOOR
    mov #0x46, DOORPIECE1 ; 70
    mov #0x4A, DOORPIECE2 ; 74
    mov #0x4E, DOORPIECE3 ; 78
    call drawVerticalDoor

    DOA2:
    movb #1, UNIT_B(r3)
    movb #DOOR_SPEED, UNIT_TIMER_A(r3)
    jmp ailpCheckForWindowRedraw

; in: r3 = unit number
doorOpenB:
    tstb UNIT_A(r3)
    bnz DOB1
      ; HORIZONTAL DOOR
        mov #0x11, DOORPIECE1 ; 17
        mov #0x09, DOORPIECE2 ;  9
        mov #0x5B, DOORPIECE3 ; 91
        call drawHorizontalDoor
        br DOB2
    DOB1:
      ; VERTICAL DOOR
        mov #0x1B, DOORPIECE1 ; 27
        mov #0x09, DOORPIECE2 ;  9
        mov #0x0F, DOORPIECE3 ; 15
        call drawVerticalDoor
    DOB2:
    movb #2, UNIT_B(r3)
    movb #OPENED_DOOR_DELAY, UNIT_TIMER_A(r3)
    jmp ailpCheckForWindowRedraw

; in: r3 = unit number
doorOpenFull:
    call doorCheckProximity
    bze DOF1
        movb #OPENED_DOOR_DELAY, UNIT_TIMER_B(r3) ; door is open, reset timer
        jmp aiLoop
    DOF1:
  ; if nobody near door, lets close it.
  ; check for object in the way first.
    movb UNIT_LOC_X(r3), MAP_X
    movb UNIT_LOC_Y(r3), MAP_Y
    call getTileFromMap
    cmpb r0, #TILE_FLOOR
    beq DOFB
      ; something in the way, abort
        movb #BLOCKED_DOOR_DELAY, UNIT_TIMER_A(r3)
        jmp aiLoop
    DOFB:
    ; mov #SND_DOOR, r0 ld a, SND_DOOR
    ; call playSound
    tstb UNIT_A(r3)
    bnz DOF2
      ; horizontal door
        mov #0x58, DOORPIECE1 ; 88
        mov #0x59, DOORPIECE2 ; 89
        mov #0x56, DOORPIECE3 ; 86
        call drawHorizontalDoor
        br DOF3
    DOF2:
      ; vertical door
        mov #0x46, DOORPIECE1 ; 70
        mov #0x4A, DOORPIECE2 ; 74
        mov #0x4E, DOORPIECE3 ; 78
        call drawVerticalDoor
    DOF3:
    movb #3, UNIT_B(r3)
    movb #DOOR_SPEED, UNIT_TIMER_A(r3)
    jmp ailpCheckForWindowRedraw

; in: r3 = unit number
doorCloseA:
    cmpb UNIT_A(r3), #1
    beq DCA2
      ; HORIZONTAL DOOR
        mov #0x54, DOORPIECE1 ; 84
        mov #0x55, DOORPIECE2 ; 85
        mov #0x56, DOORPIECE3 ; 86
        call drawHorizontalDoor
        br DCA3
    DCA2:
      ; VERTICAL DOOR
        mov #0x45, DOORPIECE1 ; 69
        mov #0x49, DOORPIECE2 ; 73
        mov #0x4D, DOORPIECE3 ; 77
        call drawVerticalDoor
    DCA3:
    movb #4, UNIT_B(r3)
    movb #DOOR_SPEED, UNIT_TIMER_A(r3)
    jmp ailpCheckForWindowRedraw

; in: r3 = unit number
doorCloseB:
    tstb UNIT_A(r3)
    bnz DCB2
      ; horizontal door
        mov #0x50, DOORPIECE1 ; 80
        mov #0x51, DOORPIECE2 ; 81
        mov #0x52, DOORPIECE3 ; 82
        call drawHorizontalDoor
        br DCB3
    DCB2:
      ; vertical door
        mov #0x44, DOORPIECE1 ; 68
        mov #0x48, DOORPIECE2 ; 72
        mov #0x4C, DOORPIECE3 ; 76
        call drawVerticalDoor
    DCB3:
    movb #5, UNIT_B(r3)
    movb #DOOR_SPEED, UNIT_TIMER_A(r3)
    jmp ailpCheckForWindowRedraw

; in: r3 = unit number
doorCloseFull:
    call doorCheckProximity
    bnz dcf.player_at_the_door

    dcf.exit:
        movb #CLOSED_DOOR_DELAY, UNIT_TIMER_A(r3) ; door is closed, reset timer
        jmp aiLoop

    dcf.player_at_the_door:
      ; if player near door, lets open it.
      ; first check if locked
        movb UNIT_C(r3), r0 ; lock status
        bze dcf.open_the_door   ; unlocked
            decb r0 ; cmpb r0, #1          ; spade key lock?
            bnz dcf.check_heart_key_lock
                bitb #KEY_TYPE_SPADE, KEYS ; does player have the key?
                bnz dcf.open_the_door
                br dcf.exit
            dcf.check_heart_key_lock:
                decb r0 ; cmpb r0, #2          ; heart key lock?
                bnz dcf.check_star_key_lock
                    bitb #KEY_TYPE_HEART, KEYS ; does player have the key?
                    bnz dcf.open_the_door
                    br dcf.exit
                dcf.check_star_key_lock:
                    decb r0 ; cmpb r0, #3          ; star key lock?
                    bnz dcf.exit                   ; SHOULD NEVER HAPPEN
                        bitb #KEY_TYPE_STAR, KEYS  ; does player have the key?
                        bnz dcf.open_the_door
                        br dcf.exit
        dcf.open_the_door:
            ; mov #SND_DOOR, r0
            ; call playSound
            tstb UNIT_A(r3)
            bnz 10$
              ; horizontal door
                mov #0x54, DOORPIECE1 ; 84
                mov #0x55, DOORPIECE2 ; 85
                mov #0x56, DOORPIECE3 ; 86
                call drawHorizontalDoor
                br 20$
            10$:
              ; vertical door
                mov #0x45, DOORPIECE1 ; 69
                mov #0x49, DOORPIECE2 ; 73
                mov #0x4D, DOORPIECE3 ; 77
                call drawVerticalDoor
            20$:
            clrb UNIT_B(r3)
            movb #DOOR_SPEED, UNIT_TIMER_A(r3)
            jmp ailpCheckForWindowRedraw

;  in: r0 = tile
;      r1 = X
;      r2 = Y
; out: r2 = tile map addr
plotTileToMap:
    swab r2
    asr r2
    add r1, r2
    add #MAP, r2

    movb r0, (r2)
return

;       in: r3 = door unit number
; corrupts: r0, r5
drawVerticalDoor:
    _movb UNIT_LOC_X(r3), r1
    _movb UNIT_LOC_Y(r3),r2
    dec r2

    movb DOORPIECE1, r0
    call plotTileToMap

    add #MAP_WIDTH, r2
    movb DOORPIECE2, (r2)

    add #MAP_WIDTH, r2
    movb DOORPIECE3, (r2)
return

;       in: r3 = door unit number
; corrupts: r0, r5
drawHorizontalDoor:
    _movb UNIT_LOC_X(r3), r1
    dec r1
    _movb UNIT_LOC_Y(r3), r2

    mov DOORPIECE1, r0
    call plotTileToMap

    inc r2
    movb DOORPIECE2, (r2)+

    movb DOORPIECE3, (r2)
return

DOORPIECE1: .word 0
DOORPIECE2: .word 0
DOORPIECE3: .word 0

;       in: r3 = door unit number
; corrupts: r0
doorCheckProximity:
  ; First check horizontal proximity to door
    _movb UNIT_LOC_X(r3), r0 ; door unit
    _movb UNIT_LOC_X, r1     ; player unit
    sub r1, r0
    bpl PRD2
        neg r0 ; convert two's comp back to positive
    PRD2:
    cmp r0, #1 ; check if same horizontal tile or next to it
    blos PRD3
        sez ; player not detected
        return

    PRD3:
  ; Now check vertical proximity
    _movb UNIT_LOC_Y(r3), r0 ; door unit
    _movb UNIT_LOC_Y, r1     ; player unit
    sub r1, r0
    bpl PRD5
        neg r0 ; convert two's comp back to positive
    PRD5:
    cmp r0, #1 ; check if same vertical tile or next to it
    blos PRD6
        sez ; player not detected
        return

    PRD6:
    clz ; player detected
return


; in: r3 = trash compactor unit number
trashCompactor:
    movb UNIT_A(r3), r0
    bze tcOpenState
        dec r0           ; cmp r0, #1 ; mid-closing state
        bze tcMidClosing
            dec r0           ; cmp r0, #2 ; closed state
            _jmp ZE, tcClosedState
                dec r0           ; cmp r0, #3 ; mid-opening state
                _jmp ZE, tcMidOpening
                    jmp aiLoop       ; should never get here.

tcOpenState:
    movb UNIT_LOC_X(r3), MAP_X
    movb UNIT_LOC_Y(r3), MAP_Y
    call getTileFromMap

    cmp r0, #TILE_TRASH_ZONE ; Usual tile for trash compactor danger zone
    bne TRS15

    inc MAP_ADDR
    cmpb @MAP_ADDR, #TILE_TRASH_ZONE ; Usual tile for trash compactor danger zone
    bne TRS15
        movb #20, UNIT_TIMER_A(r3)
      ; now check for units in the compactor
        movb UNIT_LOC_X(r3), MAP_X
        movb UNIT_LOC_Y(r3), MAP_Y
        call checkForUnit
        _jmp CC, aiLoop ; Nothing found, do nothing.
    TRS15:
  ; Object has been detected in TC, start closing.
    mov #0x92, TCPIECE1 ; 146
    mov #0x93, TCPIECE2 ; 147
    mov #0x96, TCPIECE3 ; 150
    mov #0x97, TCPIECE4 ; 151
    call drawTrashCompactor

    incb UNIT_A(r3)
    movb #COMPACTOR_2ND_DELAY, UNIT_TIMER_A(r3)
    ; mov #SND_TRASH_CLOSE, r0
    ; call playSound
jmp aiLoop


tcMidClosing:
    mov #0x98, TCPIECE1 ; 152
    mov #0x99, TCPIECE2 ; 153
    mov #0x9C, TCPIECE3 ; 156
    mov #0x9D, TCPIECE4 ; 157
    call drawTrashCompactor

    incb UNIT_A(r3)
    movb #COMPACTOR_3RD_DELAY, UNIT_TIMER_A(r3)

  ; Now check for any live units in the compactor
    movb UNIT_LOC_X(r3), MAP_X
    movb UNIT_LOC_Y(r3), MAP_Y
    call checkForUnit
    bpl tcmc.killUnit
        inc MAP_X ; check second tile
        call checkForUnit
        _jmp MI, aiLoop

    tcmc.killUnit:
  ; Found unit in compactor, kill it.
    mov #MSG_TERMINATED, r5
    call printInfo

    ; mov #SND_EXPLOSION, r0 ; EXPLOSION sound
    ; call playSound
    mov UNIT_FIND, r0
    clrb UNIT_TYPE(r0)
    clrb UNIT_HEALTH(r0)

    mov #28, r1 ; start of weapons
    TCMC2:
        tstb UNIT_TYPE(r0)
        bze TCMC3

        inc r1
    cmp r1, #32
    bne TCMC2
    jmp ailpCheckForWindowRedraw

    TCMC3:
    movb #11, UNIT_TYPE(r1)   ; SMALL EXPLOSION
    movb #248, UNIT_TILE(r1)  ; first tile for explosion
    movb UNIT_LOC_X(r3), UNIT_LOC_X(r1)
    movb UNIT_LOC_Y(r3), UNIT_LOC_Y(r1)

    tstb UNIT_FIND ; is it the player?
    bnz TCMC4
        call displayPlayerHealth
        ; mov #SND_PLAYER_DOWN, r0
        ; call PLAY_SOUND
        mov #10, BORDER_FLASH

    TCMC4:
        jmp ailpCheckForWindowRedraw

tcClosedState:
    mov #0x92, TCPIECE1 ; 146
    mov #0x93, TCPIECE2 ; 147
    mov #0x96, TCPIECE3 ; 150
    mov #0x97, TCPIECE4 ; 151
    call drawTrashCompactor

    incb UNIT_A(r3)
    movb #COMPACTOR_2ND_DELAY, UNIT_TIMER_A(r3)
    jmp aiLoop

tcMidOpening:
    mov #0x90, TCPIECE1 ; 144
    mov #0x91, TCPIECE2 ; 145
    mov #0x94, TCPIECE3 ; 148
    mov #0x94, TCPIECE4 ; 148
    call drawTrashCompactor

    clrb UNIT_A(r3)
    movb #COMPACTOR_COOLDOWN, UNIT_TIMER_A(r3)

    ; mov #SND_TRASH_OPEN, r0
    ; call playSound
    jmp aiLoop

drawTrashCompactor:
    _movb UNIT_LOC_X(r3), r1
    _movb UNIT_LOC_Y(r3), r2
    dec r2 ; start one tile above
    mov TCPIECE1, r0
    call plotTileToMap

    inc r2
    movb TCPIECE2, (r2)

    add #MAP_WIDTH - 1, r2
    movb TCPIECE3, (r2)+

    movb TCPIECE4, (r2)

    jmp checkForWindowRedraw ; call:return

TCPIECE1: .word 0
TCPIECE2: .word 0
TCPIECE3: .word 0
TCPIECE4: .word 0

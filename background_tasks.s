; NOTES ---------------------------------------------------------------------{{{
; NOTES ABOUT UNIT TYPES
; ----------------------
; 000=no unit (does not exist)
; 001=player unit
; 002=hoverbot left-to-right
; 003=hoverbot up-down
; 004=hoverbot attack mode
; 005=hoverbot chase player
; 006=
; 007=transporter
; 008=
; 009=evilbot chase player
; 010=door
; 011=small explosion
; 012=pistol fire up
; 013=pistol fire down
; 014=pistol fire left
; 015=pistol fire right
; 016=trash compactor
; 017=
; 018=
; 019=
; 020=

; NOTES ABOUT UNIT NUMBERING SCHEME
; ---------------------------------
;     0 = player unit
;  1-27 = enemy robots (28 units max)
; 28-31 = weapons fire
; 32-47 = doors and other units that don't have sprites (16 units max)
; 48-63 = hidden objects to be found (16 units max)

; NOTES ABOUT DOORS.
; -------------------
; A - 0=horitzonal 1=vertical
; B - 0=opening-A 1=opening-B 2=OPEN / 3=closing-A 4=closing-B 5-CLOSED
; C - 0=unlocked / 1=locked spade 2=locked heart 3=locked star
; D - 0=automatic / 0=manual

; HIDDEN OBJECTS
; --------------
; UNIT_TYPE: 128 = key UNIT_A: 0=SPADE 1=HEART 2=STAR
; UNIT_TYPE: 129 = time bomb
; UNIT_TYPE: 130 = EMP
; UNIT_TYPE: 131 = pistol
; UNIT_TYPE: 132 = charged plasma gun
; UNIT_TYPE: 133 = medkit
; UNIT_TYPE: 134 = magnet

; NOTES ABOUT TRANSPORTER
; ----------------------
; UNIT_A: 0=always active   1=only active when all robots are dead
; UNIT_B: 0=completes level 1=send to coordinates
; UNIT_C: X-coordinate
; UNIT_D: Y-coordinate

; Sound Effects
; ----------------------
;  0 explosion
;  1 small explosion
;  2 medkit
;  3 emp
;  4 haywire
;  5 evilbot
;  6 move
;  7 electric shock
;  8 plasma gun
;  9 fire pistol
; 10 item found
; 11 error
; 12 change weapons
; 13 change items
; 14 door
; 15 menu beep
; 16 walk
; 17 sfx (short beep)
; 18 sfx
;
;----------------------------------------------------------------------------}}}

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
    bnz run_background_tasks
        return

    run_background_tasks:
        clr BGTIMER1 ; reset background timer
        clr UNIT

    aiLoop:
      ; ALL AI routines must JMP back to here at the end.
       .equiv UNIT, .+2    ; Current unit being processed
        inc #0
        mov UNIT, r3
        cmp r3, #64 ; end of units
        bne check_if_unit_exists
            return  ; return control to main program

        check_if_unit_exists:
            tstb UNIT_TYPE(r3) ; Does unit exist?
            bze aiLoop
              ; Unit found to exist, now check it's timer.
              ; unit code won't run until timer hits zero.
                tstb UNIT_TIMER_A(r3)
                bze timer_has_triggered
                    decb UNIT_TIMER_A(r3)
                    br aiLoop
                timer_has_triggered:
                  ; Unit exists and timer has triggered
                  ; The unit type determines which AI routine is run.
                    movb UNIT_TYPE(r3), r0
                    cmpb r0, #24 ; max different unit types in chart
                    bhi aiLoop   ; abort if greater
                        asl r0
                        jmp @AI_ROUTINES_LUT(r0)

AI_ROUTINES_LUT:
       .word aiLoop; DUMMY_ROUTINE    ; UNIT_TYPE 00 ; non-existent unit
       .word aiLoop; DUMMY_ROUTINE    ; UNIT_TYPE 01 ; player unit - can't use
       .word leftRightDroid           ; UNIT_TYPE 02
       .word upDownDroid              ; UNIT_TYPE 03
       .word hoverAttack              ; UNIT_TYPE 04
       .word waterDroid               ; UNIT_TYPE 05
       .word aiLoop ; timeBomb        ; UNIT_TYPE 06
       .word aiLoop ; transporterPad  ; UNIT_TYPE 07
       .word deadRobot                ; UNIT_TYPE 08
       .word evilbot                  ; UNIT_TYPE 09
       .word aiDoor                   ; UNIT_TYPE 10
       .word smallExplosion           ; UNIT_TYPE 11
       .word pistolFireUp             ; UNIT_TYPE 12
       .word pistolFireDown           ; UNIT_TYPE 13
       .word pistolFireLeft           ; UNIT_TYPE 14
       .word pistolFireRight          ; UNIT_TYPE 15
       .word trashCompactor           ; UNIT_TYPE 16
       .word upDownRollerbot          ; UNIT_TYPE 17
       .word leftRightRollerbot       ; UNIT_TYPE 18
       .word aiLoop ; elevator        ; UNIT_TYPE 19
       .word aiLoop ; magnet          ; UNIT_TYPE 20
       .word aiLoop ; magnetizedRobot ; UNIT_TYPE 21
       .word aiLoop ; waterRaftLr     ; UNIT_TYPE 22
       .word aiLoop ; dematerialize   ; UNIT_TYPE 23

deadRobot:
    clrb UNIT_TYPE(r3)
    jmp aiLoop

    .include "background_tasks/evilbot.s"
    .include "background_tasks/hoverbot_processed.s"
    .include "background_tasks/water_droid.s"

; This routine handles automatic sliding doors.
; UNIT_B register means:
;        0 = opening-A
;        1 = opening-B
;        2 = OPEN
;        3 = closing-A
;        4 = closing-B
;        5 - CLOSED
;
; in: r3 = unit number
aiDoor: ;--------------------------------------------------------------------{{{
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
    jsr r5, drawHorizontalDoor
    .byte 0x58, 0x59, 0x56 ; 88, 89, 86 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
    .even
    br DOA2

    DOA1:
  ; VERTICAL DOOR
    jsr r5, drawVerticalDoor
    .byte 0x46, 0x4A, 0x4E ; 70, 74, 78 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
    .even

    DOA2:
    movb #1, UNIT_B(r3)
    movb #DOOR_SPEED, UNIT_TIMER_A(r3)
    jmp ailpCheckForWindowRedraw

; in: r3 = unit number
doorOpenB:
    tstb UNIT_A(r3)
    bnz DOB1
      ; HORIZONTAL DOOR
        jsr r5, drawHorizontalDoor
        .byte 0x11, 0x09, 0x5B ; 17, 9, 91 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
        .even
        br DOB2
    DOB1:
      ; VERTICAL DOOR
        jsr r5, drawVerticalDoor
        .byte 0x1B, 0x09, 0x0F ; 27, 9, 15 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
        .even
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
    movb UNIT_LOC_X(r3), r1
    movb UNIT_LOC_Y(r3), r2
    call getTileFromMap

    cmpb r0, #TILE_FLOOR
    beq DOFB
      ; something in the way, abort
        movb #BLOCKED_DOOR_DELAY, UNIT_TIMER_A(r3)
        jmp aiLoop
    DOFB:
        mov #DOOR, r0
        call playSound
        tstb UNIT_A(r3)
        bnz DOF2
          ; horizontal door
            jsr r5, drawHorizontalDoor
            .byte 0x58, 0x59, 0x56 ; 88, 89, 86 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
            .even
            br DOF3
        DOF2:
          ; vertical door
            jsr r5, drawVerticalDoor
            .byte 0x46, 0x4A, 0x4E ; 70, 74, 78 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
            .even
        DOF3:
            movb #3, UNIT_B(r3)
            movb #DOOR_SPEED, UNIT_TIMER_A(r3)
            jmp ailpCheckForWindowRedraw

; in: r3 = unit number
doorCloseA:
    cmpb UNIT_A(r3), #1
    beq DCA2
      ; horizontal door
        jsr r5, drawHorizontalDoor
        .byte 0x54, 0x55, 0x56 ; 84, 85, 86 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
        .even
        br DCA3
    DCA2:
      ; vertical door
        jsr r5, drawVerticalDoor
        .byte 0x45, 0x49, 0x4D ; 69, 73, 77 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
        .even
    DCA3:
    movb #4, UNIT_B(r3)
    movb #DOOR_SPEED, UNIT_TIMER_A(r3)
    jmp ailpCheckForWindowRedraw

; in: r3 = unit number
doorCloseB:
    tstb UNIT_A(r3)
    bnz DCB2
      ; horizontal door
        jsr r5, drawHorizontalDoor
        .byte 0x50, 0x51, 0x52 ; 80, 81, 82 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
        .even
        br DCB3
    DCB2:
      ; vertical door
        jsr r5, drawVerticalDoor
        .byte 0x44, 0x48, 0x4C ; 68, 72, 76 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
        .even
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
        bze open_the_door   ; unlocked
            decb r0 ; cmpb r0, #1          ; spade key lock?
            bnz check_heart_key_lock
                bitb #KEY_TYPE_SPADE, KEYS ; does player have the key?
                bnz open_the_door
                br dcf.exit
            check_heart_key_lock:
                decb r0 ; cmpb r0, #2          ; heart key lock?
                bnz check_star_key_lock
                    bitb #KEY_TYPE_HEART, KEYS ; does player have the key?
                    bnz open_the_door
                    br dcf.exit
                check_star_key_lock:
                    decb r0 ; cmpb r0, #3          ; star key lock?
                    bnz dcf.exit                   ; SHOULD NEVER HAPPEN
                        bitb #KEY_TYPE_STAR, KEYS  ; does player have the key?
                        bnz open_the_door
                        br dcf.exit
        open_the_door:
            mov #DOOR, r0
            call playSound
            tstb UNIT_A(r3)
            bnz 10$
              ; horizontal door
                jsr r5, drawHorizontalDoor
                .byte 0x54, 0x55, 0x56 ; 84, 85, 86 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
                .even
                br 20$
            10$:
              ; vertical door
                jsr r5, drawVerticalDoor
                .byte 0x45, 0x49, 0x4D ; 69, 73, 77 ; DOORPIECE1, DOORPIECE2, DOORPIECE3
                .even
            20$:
            clrb UNIT_B(r3)
            movb #DOOR_SPEED, UNIT_TIMER_A(r3)
            jmp ailpCheckForWindowRedraw


;       in: r3 = door unit number
; corrupts: r0, r1, r2
drawVerticalDoor:
    _movb UNIT_LOC_X(r3), r1
    _movb UNIT_LOC_Y(r3), r2
    dec r2

    movb (r5)+, r0
    call plotTileToMap

    add #MAP_WIDTH, r2
    movb (r5)+, (r2)

    add #MAP_WIDTH, r2
    movb (r5)+, (r2)
    inc r5 ; adjust for .even
rts r5

;       in: r3 = door unit number
; corrupts: r0, r1, r2
drawHorizontalDoor:
    _movb UNIT_LOC_X(r3), r1
    dec r1
    _movb UNIT_LOC_Y(r3), r2

    movb (r5)+, r0
    call plotTileToMap

    inc r2
    movb (r5)+, (r2)+

    movb (r5)+, (r2)
    inc r5 ; adjust for .even
rts r5

;       in: r3 = door unit number
; corrupts: r0
doorCheckProximity:
  ; First check horizontal proximity to door
    _movb UNIT_LOC_X(r3), r0 ; door unit
    _movb UNIT_LOC_X, r1     ; player unit
    sub r1, r0
    bpl horizontal_door_distance_positive
        neg r0 ; convert two's comp back to positive
    horizontal_door_distance_positive:
        cmp r0, #1 ; check if same horizontal tile or next to it
        blos PRD3
            sez ; player not detected
            return

        PRD3:
          ; Now check vertical proximity
            _movb UNIT_LOC_Y(r3), r0 ; door unit
            _movb UNIT_LOC_Y, r1     ; player unit
            sub r1, r0
            bpl vertical_door_distance_positive
                neg r0 ; convert two's comp back to positive
            vertical_door_distance_positive:
                cmp r0, #1 ; check if same vertical tile or next to it
                blos 10$
                    sez ; player not detected
                    return

                10$:
                    clz ; player detected
                    return
;----------------------------------------------------------------------------}}}

; in: r3 = trash compactor unit number
trashCompactor: ;------------------------------------------------------------{{{
    movb UNIT_A(r3), r0
    bze tcOpenState
        dec r0                   ; cmp r0, #1 ; mid-closing state
        bze tcMidClosing
            dec r0               ; cmp r0, #2 ; closed state
            _jmp ZE, tcClosedState
                dec r0           ; cmp r0, #3 ; mid-opening state
                _jmp ZE, tcMidOpening
                    jmp aiLoop       ; should never get here.

tcOpenState:
    _movb UNIT_LOC_X(r3), r1
    _movb UNIT_LOC_Y(r3), r2
    call getTileFromMap

    cmpb r0, #TILE_TRASH_ZONE ; Usual tile for trash compactor danger zone
    bne close_the_trash_compactor
        cmpb 1(r5), #TILE_TRASH_ZONE ; Usual tile for trash compactor danger zone
        bne close_the_trash_compactor
            movb #20, UNIT_TIMER_A(r3)
          ; now check for units in the compactor
            call checkForUnit
            bpl close_the_trash_compactor
                jmp aiLoop ; Nothing found, do nothing.
    close_the_trash_compactor:
      ; Object has been detected in TC, start closing.
        jsr r5, drawTrashCompactor
       .byte 0x92, 0x93, 0x96, 0x97 ; 146, 147, 150, 151 ; TCPIECE1, TCPIECE2, TCPIECE3, TCPIECE4

        incb UNIT_A(r3)
        movb #COMPACTOR_2ND_DELAY, UNIT_TIMER_A(r3)
        mov #DOOR, r0
        call playSound
jmp aiLoop


tcMidClosing:
    jsr r5, drawTrashCompactor
   .byte 0x98, 0x99, 0x9C, 0x9D ; 152, 153, 156, 157 ; TCPIECE1, TCPIECE2, TCPIECE3, TCPIECE4

    incb UNIT_A(r3)
    movb #COMPACTOR_3RD_DELAY, UNIT_TIMER_A(r3)

  ; Now check for any live units in the compactor
    movb UNIT_LOC_X(r3), r1 ; MAP_X
    movb UNIT_LOC_Y(r3), r2 ; MAP_Y
    call checkForUnit
    bpl tcmc.killUnit
        inc r1 ; MAP_X ; check second tile
        call checkForUnit
        _jmp MI, aiLoop

    tcmc.killUnit:
  ; Found unit in compactor, kill it.
    push r4 ; store unit idx for later
        mov #MSG_TERMINATED, r5
        call printInfo

        mov #EXPLOSION, r0
        call playSound
        ; mov UNIT_FIND, r0
    pop r4 ; restore unit idx
    clrb UNIT_TYPE(r4)
    clrb UNIT_HEALTH(r4)

    mov #28, r1 ; start of weapons
    TCMC2:
        tstb UNIT_TYPE(r4)
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

    tstb r4 ; UNIT_FIND ; is it the player?
    bnz TCMC4
        call displayPlayerHealth
        ; mov #SND_PLAYER_DOWN, r0
        ; call PLAY_SOUND
        mov #10, BORDER_FLASH

    TCMC4:
        jmp ailpCheckForWindowRedraw

tcClosedState:
    jsr r5, drawTrashCompactor
   .byte 0x92, 0x93, 0x96, 0x97 ; 146, 147, 150, 151 ; TCPIECE1, TCPIECE2, TCPIECE3, TCPIECE4

    incb UNIT_A(r3)
    movb #COMPACTOR_2ND_DELAY, UNIT_TIMER_A(r3)
    jmp aiLoop

tcMidOpening:
    jsr r5, drawTrashCompactor
   .byte 0x90, 0x91, 0x94, 0x94 ; 144, 145, 148, 148 ; TCPIECE1, TCPIECE2, TCPIECE3, TCPIECE4

    clrb UNIT_A(r3)
    movb #COMPACTOR_COOLDOWN, UNIT_TIMER_A(r3)

    mov #DOOR, r0
    call playSound
    jmp aiLoop

drawTrashCompactor:
    _movb UNIT_LOC_X(r3), r1
    _movb UNIT_LOC_Y(r3), r2
    dec r2 ; start one tile above
    movb (r5)+, r0
    call plotTileToMap

    inc r2
    movb (r5)+, (r2)

    add #MAP_WIDTH - 1, r2
    movb (r5)+, (r2)+

    movb (r5)+, (r2)

    call checkForWindowRedraw
rts r5
;----------------------------------------------------------------------------}}}

upDownRollerbot: ;-----------------------------------------------------------{{{
    movb #ROLLERBOT_MOVE_SPD, UNIT_TIMER_A(r3)
    call rollerbotAnimate

    tstb UNIT_A(r3) ; check direction 0=UP 1=DOWN
    bnz UDR01
        mov #MOVE_WALK, MOVE_TYPE
        call requestWalkUp
        bnz UDR02 ; unit in the way
            movb #1, UNIT_A(r3) ; change direction
            call rollerbotFireDetect
            jmp ailpCheckForWindowRedraw
    UDR01:
        mov #MOVE_WALK, MOVE_TYPE
        call requestWalkDown
        bnz UDR02 ; unit in the way
            clrb UNIT_A(r3) ; change direction
        UDR02:
            call rollerbotFireDetect
            jmp ailpCheckForWindowRedraw
;----------------------------------------------------------------------------}}}

leftRightRollerbot: ;--------------------------------------------------------{{{
    movb #ROLLERBOT_MOVE_SPD, UNIT_TIMER_A(r3)
    call rollerbotAnimate

    tstb UNIT_A(r3) ; check direction 0=LEFT 1=RIGHT
    bnz LRR01
        mov #MOVE_WALK, MOVE_TYPE
        call requestWalkLeft
        bnz LRR02 ; unit in the way
            movb #1, UNIT_A(r3) ; change direction
            call rollerbotFireDetect
            jmp ailpCheckForWindowRedraw
    LRR01:
        mov #MOVE_WALK, MOVE_TYPE
        call requestWalkRight
        bnz LRR02 ; unit in the way
            clrb UNIT_A(r3) ; change direction
        LRR02:
            call rollerbotFireDetect
            jmp ailpCheckForWindowRedraw
;----------------------------------------------------------------------------}}}

rollerbotFireDetect: ;-------------------------------------------------------{{{
    movb UNIT_LOC_X(r3), RBAF_X
    movb UNIT_LOC_Y(r3), RBAF_Y
  ; See if we're lined up vertically
    cmpb UNIT_LOC_Y, UNIT_LOC_Y(r3)
    beq rollerbot_fire_lr
      ; See if we're lined up horizontally
        cmpb UNIT_LOC_X(r3), UNIT_LOC_X
        beq rollerbot_fire_ud
            return

    rollerbot_fire_lr: ;-----------------------------------------------------{{{
        movb UNIT_LOC_X(r3), r0
        cmpb r0, UNIT_LOC_X
        blo rollerbot_fire_right
          ; fire left
            ; check to see if distance is less than 5
            sub #5, r0
            cmpb UNIT_LOC_X, r0
            bhis 10$
                return ; the distance is more than 5
            10$:
                mov #28, r2
                20$:
                    tstb UNIT_TYPE(r2)
                    bze RFL2

                    inc r2
                    cmp r2, #32
                bne 20$
                    return

            RFL2:
                movb #AI_PISTOL_LEFT, UNIT_TYPE(r2) ; pistol fire left AI
                mov #TILE_PISTOL_HORZ, r0 ; tile for horizontal weapons fire
                br rollerbot_after_fire

        rollerbot_fire_right:
            ; Check to see if distance is less than 5
            add #5, r0
            cmpb UNIT_LOC_X, r0
            blos 10$
                return ; the distance is more than 5
            10$:
                mov #28, r2
                20$:
                    tstb UNIT_TYPE(r2)
                    bze RFR2

                    inc r2
                    cmp r2, #32
                bne 20$
                    return

            RFR2:
                movb #AI_PISTOL_RIGHT, UNIT_TYPE(r2) ; pistol fire right AI
                mov #TILE_PISTOL_HORZ, r0            ; tile for horizontal weapons fire
                br rollerbot_after_fire
    ;------------------------------------------------------------------------}}}

    rollerbot_fire_ud: ;-----------------------------------------------------{{{
        movb UNIT_LOC_Y(r3), r0
        cmpb r0, UNIT_LOC_Y
        blo rollerbot_fire_down
          ; fire up
            ; check to see if distance is less than 4
            sub #4, r0
            cmpb UNIT_LOC_Y, r0
            blos rfu.player_in_range
                return ; the distance is more than 4
            rfu.player_in_range:
                mov #28, r2
                20$:
                    tstb UNIT_TYPE(r2)
                    bze 30$

                    inc r2
                    cmp r2, #32
                bne 20$
                    return
            30$:
                movb #AI_PISTOL_UP, UNIT_TYPE(r2) ; pistol fire left AI
                mov #TILE_PISTOL_VERT, r0 ; tile for horizontal weapons fire
                br rollerbot_after_fire

        rollerbot_fire_down:
            ; check to see if distance is less than 4
            add #4, r0
            cmpb UNIT_LOC_Y, r0
            blos rfd.player_in_range
                return ; the distance is more than 4
            rfd.player_in_range:
                mov #28, r2
                20$:
                    tstb UNIT_TYPE(r2)
                    bze 30$

                    inc r2
                    cmp r2, #32
                bne 20$
                    return
            30$:
                movb #AI_PISTOL_DOWN, UNIT_TYPE(r2) ; pistol fire left AI
                mov #TILE_PISTOL_VERT, r0 ; tile for horizontal weapons fire
                br rollerbot_after_fire
        ;--------------------------------------------------------------------}}}

                rollerbot_after_fire: ;--------------------------------------{{{
                    movb r0, UNIT_TILE(r2)
                    movb #5, UNIT_A(r2)    ; travel distance.
                    clrb UNIT_B(r2)        ; weapon-type = pistol
                    clrb UNIT_TIMER_A(r2)

                   .equiv RBAF_X, .+2
                    movb #0, UNIT_LOC_X(r2)

                   .equiv RBAF_Y, .+2
                    movb #0, UNIT_LOC_Y(r2)

                    mov #FIRE_PISTOL, r0
                    jmp playSound          ;call:return
                return
                ;------------------------------------------------------------}}}
;----------------------------------------------------------------------------}}}
rollerbotAnimate: ;----------------------------------------------------------{{{
    tstb UNIT_TIMER_B(r3)
    bze 10$
        decb UNIT_TIMER_B(r3)
        return
    10$:
        movb #ROLLERBOT_ANIM_SPEED, UNIT_TIMER_B(r3) ; reset animate timer

        cmpb UNIT_TILE(r3), #TILE_ROLLERBOT_A
        bne 20$
            movb #TILE_ROLLERBOT_B, UNIT_TILE(r3) ; rollerbot tile
            jmp checkForWindowRedraw  ;call:return
        20$:
            movb #TILE_ROLLERBOT_A, UNIT_TILE(r3) ; rollerbot tile
            jmp checkForWindowRedraw  ;call:return
;----------------------------------------------------------------------------}}}


pistolFireUp:
  ; Check if it has reached limits.
    tstb UNIT_A(r3)
    bnz 10$
      ; if it has reached max range, then it vanishes.
        call deactivateWeapon
        jmp ailpCheckForWindowRedraw
    10$:
        decb UNIT_LOC_Y(r3) ; move it up one.
        br pistolAiCommon

pistolFireDown:
  ; Check if it has reached limits.
    tstb UNIT_A(r3)
    bnz 10$
      ; if it has reached max range, then it vanishes.
        call deactivateWeapon
        jmp ailpCheckForWindowRedraw
    10$:
        incb UNIT_LOC_Y(r3) ; move it down one.
        br pistolAiCommon

pistolFireLeft:
  ; Check if it has reached limits.
    tstb UNIT_A(r3)
    bnz 10$
      ; if it has reached max range, then it vanishes.
        call deactivateWeapon
        jmp ailpCheckForWindowRedraw
    10$:
        decb UNIT_LOC_X(r3) ; move it down one.
        br pistolAiCommon

pistolFireRight:
  ; Check if it has reached limits.
    tstb UNIT_A(r3)
    bnz 10$
      ; if it has reached max range, then it vanishes.
        call deactivateWeapon
        jmp ailpCheckForWindowRedraw
    10$:
        incb UNIT_LOC_X(r3) ; move it down one.
        br pistolAiCommon

deactivateWeapon:
    clrb UNIT_TYPE(r3)
    cmpb UNIT_B(r3), #1
    bnz 1237$
        clrb UNIT_B(r3)
        clr PLASMA_ACT
1237$: return

pistolAiCommon:
    tstb UNIT_B(r3) ; is it pistol or plasma?
    bnz plasmaAiCommon
        decb UNIT_A(r3) ; reduce range by one
      ; Now check what map object it is on.
        movb UNIT_LOC_X(r3), r1
        movb UNIT_LOC_Y(r3), r2
        call getTileFromMap
        cmpb r0, #TILE_CANNISTER ; explosive cannister
        bne .not_explosive_canister ; uses A further
          ; hit an explosive cannister
            movb #TILE_BLOWN_CANNISTER, (r5)    ; Blown cannister
            movb #AI_BOMB, UNIT_TYPE(r3)        ; bomb AI
            movb #TILE_CANNISTER, UNIT_TILE(r3) ; Cannister tile
            movb #5, UNIT_TIMER_A(r3)           ; How long until exposion?
            clrb UNIT_A(r3)
            jmp aiLoop

        .not_explosive_canister:
            bitb TILE_ATTRIB(r0), #0b00010000 ; can see through tile?
            bnz bullet_passable_tile
               ;mov #SND_WALL_HIT, r0
               ;call playSound
              ; Hit object that can't pass through, convert to explosion
                movb #11, UNIT_TYPE(r3)  ; small explosion
                movb #248, UNIT_TILE(r3) ; first tile for explosion
                jmp ailpCheckForWindowRedraw
            bullet_passable_tile:
              ; check if it encountered a robot/human
                call checkForUnit ; returns unit ID in r4, or -1 if unit wasn't encountered
                bpl hit_unit
                    jmp ailpCheckForWindowRedraw ; no unit encountered
                hit_unit:
                  ; struck a robot/human
                    movb #AI_SMALL_EXPLOSION, UNIT_TYPE(r3) ; small explosion
                    movb #248, UNIT_TILE(r3)                ; first tile for explosion
                    mov #1, r0 ; set damage for pistol
                    call inflictDamage
                    call alterAi
                    jmp ailpCheckForWindowRedraw

plasmaAiCommon:
jmp aiLoop

; This routine checks to see if the robot being shot is a hoverbot,
; if so it will alter it's AI to attack mode.
; in: r4 = hit unit ID
alterAi:
    cmp r4, #AI_DROID_LEFT_RIGHT  ; hoverbot left/right
    beq switch_to_attack_mode
        cmp r4, #AI_DROID_UP_DOWN ; hoverbot UP/DOWN
        beq switch_to_attack_mode
            return

    switch_to_attack_mode:
        movb #AI_HOVER_ATTACK, UNIT_TYPE(r3) ; Attack AI
        return

; This routine will inflict damage on whatever is defined in R4 in the amount set in R0.
; If the damage is more than the health of that unit, it will delete the unit.
; in: r4 = hit unit ID
;     r0 = damage amount
inflictDamage: ;-------------------------------------------------------------{{{
    tst r4
    bze inflict_damage_to_the_player
      ; inflict damage to a unit
        movb UNIT_HEALTH(r4), r5
        sub r0, r5
        blos unit_killed
            ; mov #SND_ROBOT_HIT
            ; jmp playSoundD ; call:return
            return
        unit_killed:
            clrb UNIT_HEALTH(r4)
            cmpb UNIT_TYPE(r4), #AI_DEAD_ROBOT ; is it a dead robot already?
            beq unit_already_dead
                movb #DEAD_ROBOT_TIMEOUT, UNIT_TIMER_A
                movb #TILE_DEAD_ROBOT, UNIT_TILE(r4) ; dead robot tile
                ; mov #SND_ROBOT_DOWN
                ; jmp playSoundD ; call:return
                return
            unit_already_dead:
                ; mov #SND_WALL_HIT
                ; jmp playSoundD ; call:return
                return

    inflict_damage_to_the_player:
        tstb UNIT_HEALTH
        bnz 10$
            return ; don't hurt killed player
        10$:
            push r0
                call createPlayerExplosion
                call calculateAndRedraw
                call drawMapWindow
                call drawBuffer
            pop r0

            tstb UNIT_HEALTH
            bze 20$
                ; mov #SND_ELECTRIC, r0
                br 30$
            20$:
                ; mov #SND_PLAYER_DOWN, r0
            30$:
                ; call playSound

                movb UNIT_HEALTH, r4
                sub r0, r4
                blos player_down
                    movb r4, UNIT_HEALTH
                    mov #10, BORDER_FLASH
                    jmp displayPlayerHealth ; call:return
                player_down:
                    clrb UNIT_HEALTH
                    clrb UNIT_TYPE
                    ; mov #SND_PLAYER_DOWN, r0
                    ; call playSound
                    call displayPlayerHealth
                    jmp drawBuffer ; call:return

    createPlayerExplosion:
        mov #28, r4
        10$:
            tstb UNIT_TYPE(r4)
            bze 20$
                inc r4
                cmp r4, #32 ; max unit for weaponsfire
        bne 10$
            return

        20$:
            movb #AI_SMALL_EXPLOSION, UNIT_TYPE(r4) ; Small explosion AI type
            movb #248, UNIT_TILE(r4)                ; first tile for explosion
            movb #1, UNIT_TIMER_A(r4)
            movb UNIT_LOC_X, UNIT_LOC_X(r4)
            movb UNIT_LOC_Y, UNIT_LOC_Y(r4)
            return
;----------------------------------------------------------------------------}}}

smallExplosion:
    clrb UNIT_TIMER_A(r3)
    incb UNIT_TILE(r3)
    cmpb UNIT_TILE(r3), #251 ; last tile for explosion
    bhi 10$
        jmp ailpCheckForWindowRedraw
    10$:
        clrb UNIT_TYPE(r3)
        jmp ailpCheckForWindowRedraw

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

; in: r0 = tile idx
;     r1 = X
;     r2 = Y
; out: r2 = calculated map addr
; corrupts: r2
plotTileToMap:
    swab r2 ; swab clears the carry flag as a bonus
    ror r2
    add r1, r2
    add #MAP, r2

    movb r0, (r2)
return

isPlayerInMeleeAttackRange:
robotAttackRange:
  ; First check horizontal proximity to player
    _movb UNIT_LOC_X(r3), r0 ; robot unit
    _movb UNIT_LOC_X, r1     ; player unit
    sub r1, r0
    bpl 10$
        neg r0 ; convert negative difference to positive
    10$:
        cmp r0, #1 ; check if same horizontal tile or next to it
        blos RAR3
            sez    ; player out of the attack range
            return
        RAR3:
          ; Now check vertical proximity
            _movb UNIT_LOC_Y(r3), r0 ; robot unit
            _movb UNIT_LOC_Y, r1     ; player unit
            sub r1, r0
            bpl RAR5
                neg r0
            RAR5:
                cmp r0, #1 ; check if same vertical tile or next to it
                blos RAR6
                    sez    ; player out of the attack range
                    return
                RAR6:
                    clz    ; player in melee attacing range
                    return

; In this AI routine, the droid simply goes LEFT until it hits an object,
; and then reverses direction and does the same, bouncing back and forth.
; in: r3 = unit number
leftRightDroid:
    call hoverbotAnimate
    movb #HOVERBOT_MOVE_SPD, UNIT_TIMER_A(r3)
    tstb UNIT_A(r3) ; directrion: 0=LEFT, 1=RIGHT
    bnz .switch_to_left
        mov #MOVE_HOVER, MOVE_TYPE
        call requestWalkLeft
        bnz .blocked_by_unit
            mov UNIT, r3
            movb #1, UNIT_A(r3) ; change direction
            jmp ailpCheckForWindowRedraw
    .switch_to_left:
        mov #MOVE_HOVER, MOVE_TYPE
        call requestWalkRight
        bnz .blocked_by_unit
            clrb UNIT_A(r3)     ; change direction
    .blocked_by_unit:
        jmp ailpCheckForWindowRedraw

; In this AI routine, the droid simply goes UP until it hits an object,
; and then reverses direction and does the same, bouncing back and forth.
; in: r3 = unit number
upDownDroid:
    call hoverbotAnimate
    movb #HOVERBOT_MOVE_SPD, UNIT_TIMER_A(r3)
    tstb UNIT_A(r3) ; directrion: 0=UP, 1=DOWN
    bnz .switch_to_down
        mov #MOVE_HOVER, MOVE_TYPE
        call requestWalkUp
        bnz .blocked_by_unit
            movb #1, UNIT_A(r3) ; change direction
            jmp ailpCheckForWindowRedraw
    .switch_to_down:
        mov #MOVE_HOVER, MOVE_TYPE
        call requestWalkDown
        bnz .blocked_by_unit
            clrb UNIT_A(r3)     ; change direction

    .blocked_by_unit:
        jmp ailpCheckForWindowRedraw

hoverAttack:
    clrb UNIT_TIMER_B(r3)
    call hoverbotAnimate

    movb #HOVERBOT_ATTACK_SPD, UNIT_TIMER_A(r3)
    mov #MOVE_HOVER, MOVE_TYPE

  ; check for horizontal movement
    cmpb UNIT_LOC_X(r3), UNIT_LOC_X
    beq .check_for_vertical_movement
        blo .walk_right
            call requestWalkLeft
            br .check_for_vertical_movement
        .walk_right:
            call requestWalkRight

    .check_for_vertical_movement:
        cmpb UNIT_LOC_Y(r3), UNIT_LOC_Y
        beq .check_for_attack
            blo .walk_down
                call requestWalkUp
                br .check_for_attack
            .walk_down:
                call requestWalkDown

        .check_for_attack:
            call isPlayerInMeleeAttackRange
          ; zero flag clear - robot next to player, zero flag set - not
            bze .skip_attack
                mov #SHOCK, r0
                call playSound

                mov #1, r0                 ; amount of damage it will inflict
                clr r4                     ; unit to inflict damage on.
                call inflictDamage
                movb #30, UNIT_TIMER_A(r3) ; rate of attack on player.

          ; add some code here to create explosion
            .skip_attack:
                jmp ailpCheckForWindowRedraw

; in: r3 = unit number
hoverbotAnimate:
    tstb UNIT_TIMER_B(r3)     ; timer reached 0?
    bze 10$                   ; yes, alter tile
        decb UNIT_TIMER_B(r3) ; no, decrease the counter
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

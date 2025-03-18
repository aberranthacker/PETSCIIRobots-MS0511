evilbot:
    movb #EVILBOT_ANIM_SPD, UNIT_TIMER_A(r3)
  ; first animate evilbot
    clr r0
    bisb UNIT_TILE(r3), r0
    cmp r0, #TILE_EVILBOT_A
    beq eb.inc_tile
        cmp r0, #TILE_EVILBOT_B
        beq eb.inc_tile
            cmp r0, #TILE_EVILBOT_C
            beq eb.inc_tile
                movb #TILE_EVILBOT_A, UNIT_TILE(r3)
                br figure_out_movement

    eb.inc_tile:
        incb UNIT_TILE(r3)

    figure_out_movement:
        tstb UNIT_TIMER_B(r3)
        bze 10$
            decb UNIT_TIMER_B(r3)
            jmp ailpCheckForWindowRedraw
        10$:
           movb #1, UNIT_TIMER_B(r3) ; Reset timer B
           mov #MOVE_WALK, MOVE_TYPE

         ; check for horizontal movement
           cmpb UNIT_LOC_X(r3), UNIT_LOC_X
           beq eb.check_for_vertical_movement
               blo eb.walk_right
                   call requestWalkLeft
                   br eb.check_for_vertical_movement
               eb.walk_right:
                   call requestWalkRight

           eb.check_for_vertical_movement:
               cmpb UNIT_LOC_Y(r3), UNIT_LOC_Y
               beq eb.check_for_attack
                   blo eb.walk_down
                       call requestWalkUp
                       br eb.check_for_attack
                   eb.walk_down:
                       call requestWalkDown

               eb.check_for_attack:
                   call isPlayerInMeleeAttackRange
                 ; zero flag clear - robot next to player, zero flag set - not
                   bze eb.skip_attack
                       mov #SHOCK, r0
                       call playSound

                       mov #5, r0                 ; amount of damage it will inflict
                       clr r4                     ; unit to inflict damage on.
                       call inflictDamage
                       movb #15, UNIT_TIMER_A(r3) ; rate of attack on player.
                   eb.skip_attack:
                       jmp ailpCheckForWindowRedraw

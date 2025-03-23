waterDroid:
  ; first rotate the tiles
    incb UNIT_TILE(r3)
    cmpb UNIT_TILE(r3), #TILE_WATERDROID_END
    bne 10$
        movb #TILE_WATERDROID_BEGIN, UNIT_TILE(r3)
    10$:
        tstb UNIT_A(r3)
        bnz 20$
            jmp ailpCheckForWindowRedraw

        20$:
          ; kill unit after countdown reaches zero.
            cmpb UNIT_TYPE(r3), #AI_DEAD_ROBOT
            movb #0xFF, UNIT_TIMER_A(r3)
            movb #TILE_DEAD_ROBOT, UNIT_TILE(r3)
            jmp ailpCheckForWindowRedraw

initGame:
    clr SCREEN_SHAKE
    call resetKeysAmmo
    call displayGameScreen
    call displayLoadMessage2
    jmp loadMap ; loadMap finishes with return

resetKeysAmmo:
    movb #0b111, KEYS ; clr KEYS
    mov #329, AMMO_PISTOL
    ; clr AMMO_PISTOL
    ; mov #512, AMMO_PLASMA
    clr AMMO_PLASMA
    clr INV_BOMBS
    clr INV_EMP
    clr INV_MEDKIT
    clr INV_MAGNET
    clr SELECTED_WEAPON
    clr SELECTED_ITEM
    clr MAGNET_ACT
    clr PLASMA_ACT
    clr BIG_EXP_ACT
    clr CYCLES
    clr SECONDS
    clr MINUTES
    clr HOURS
    return

displayGameScreen:
    mov #SCR_TEXT, r0
    mov #TEXT_BUFFER, r1
    jmp unZX0 ; unZX0 finishes with return

loadMap:
   .equiv SELECTED_MAP, .+2
    mov #1, r1
    dec r1
    mul #6, r1
    mov #MAPS, r0
    add r1, r0
    call loadDiskFile
    return


setDiffLevel:
   .equiv DIFF_LEVEL, .+2
    mov #1, r0
    bze setDiffEasy

    cmp r0, #2
    beq setDiffHard

  ; normal difficulty - do nothing
return

setDiffEasy:
  ; Find all hidden items and double the quantity.
    mov #UNIT_TYPE + 48, r4
    mov #UNIT_A + 48, r5
    mov #64 - 48, r1
    10$:
        clr r0
        bisb (r4)+, r0
        bze 20$
        cmpb r0, #ID_HIDDEN_KEY ; KEY
        beq 20$
            aslb (r5)           ; double item quantity
        20$:
        inc r5
    sob r1, 10$
return

setDiffHard:
  ; Find all hoverbots and change AI
    mov #UNIT_TYPE, r5
    mov #28, r1
    10$:
        cmpb (r5), #2     ; hoverbot left/right
        beq 20$
        cmpb (r5), #3     ; hoverbot up/down
        beq 20$
            movb #4, (r5) ; hoverbot attack mode
        20$:
        inc r5
    sob r1, 10$
return

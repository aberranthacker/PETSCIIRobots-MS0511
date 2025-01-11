displayWeapon:
    call preselectWeapon
    mov SELECTED_WEAPON, r0
    bnz DSWP01
        return
    DSWP01:
    cmp r0, #ID_PISTOL
    bne DSWP03
        tst AMMO_PISTOL
        bnz displayPistol

        clr SELECTED_WEAPON
        br displayWeapon
    DSWP03:
    cmp r0, #ID_PLASMA_GUN
    bne DSWP05
        tst AMMO_PLASMA
        bnz displayPlasmaGun

        clr SELECTED_WEAPON
        br displayWeapon
    DSWP05:
    clr SELECTED_WEAPON
    br displayWeapon

; This routine checks to see if currently selected
; weapon is zero.  And if it is, then it checks inventories
; of other weapons to decide which item to automatically
; select for the user.
preselectWeapon:
   .equiv SELECTED_WEAPON, .+2
    tst #0
    bze PRSW01
        return
    PRSW01:

    tst AMMO_PISTOL
    bze PRSW02
        mov #ID_PISTOL, SELECTED_WEAPON
        return
    PRSW02:

    tst AMMO_PLASMA
    bze PRSW04
        mov #ID_PLASMA_GUN, SELECTED_WEAPON
        return
    PRSW04:
  ; Nothing found in inventory at this point, so set
  ; selected-item to zero.
    clr SELECTED_WEAPON
    br displayBlankWeapon ; call:return

displayPlasmaGun:
    mov #WEAPON1A, r4
    call displayIconWeapon
    mov AMMO_PLASMA, r1
    br displayWeaponAmount

displayPistol:
    mov #PISTOL1A, r4
    call displayIconWeapon
    mov AMMO_PISTOL, r1

displayWeaponAmount:
    mov #TEXT_BUFFER+OFFS_DISPLAY_WEAPON+(SCREEN_WIDTH*4)+3, r5
    jmp displayDecimalNumber

displayBlankWeapon:
    mov #EMPTYA, r4
    br displayIconWeapon ; call:return

displayIconItem:
    mov #TRUE, redraw_window

    mov #TEXT_BUFFER+OFFS_DISPLAY_ITEM, r5
    br displayIcon

displayIconWeapon:
    mov #TEXT_BUFFER+OFFS_DISPLAY_WEAPON, r5

displayIcon:
    mov #4, r1
    10$:
        mov (r4)+, (r5)+
        mov (r4)+, (r5)+
        mov (r4)+, (r5)+
        add #SCREEN_WIDTH-6, r5
    sob r1, 10$

    mov #0x2020, r0
    mov r0, (r5)+
    mov r0, (r5)+
    mov r0, (r5)+
return

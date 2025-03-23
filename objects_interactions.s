; This routine is invoked when the user requests search
; an object such as a crate, chair, or plant.
searchObject:
    call userSelectObject

            ; ld a, TRUE
            ; ld (REDRAW_WINDOW), a
CHS1:
            ; ; first check of object is searchable
            ; call CALC_COORDINATES
            ; call GET_TILE_FROM_MAP
            ; ld e, a
            ; ld d, 0
            ; ld hl, TILE_ATTRIB
            ; add hl, de
            ; ld a, (hl)
            ; and %01000000
            ; jr nz, CHS2
            ; xor a
            ; ld (CURSOR_ON), a
            ; jr CHS3
CHS2:
            ; ; Is the tile a crate?
            ; ld a, (TILE)
            ; cp TILE_BIG_CRATE
            ; jr z, CHS2B
            ; cp TILE_SMALL_CRATE
            ; jr z, CHS2B
            ; cp TILE_PI_CRATE
            ; jr z, CHS2B

            ; jr CHS2C
CHS2B:
            ; ld e, a
            ; ld d, 0
            ; ld hl, DESTRUCT_PATH
            ; add hl, de
            ; ld a, (hl)
            ; ld (TILE), a
            ; call PLOT_TILE_TO_MAP
CHS2C:
            ; ; Now check if there is an object there.
            ; xor a
            ; ld (SEARCHBAR), a
            ; ld hl, MSG_SEARCHING
            ; call PRINT_INFO
SOBJ1:
            ; ld a, SEARCH_PERIOD_DELAY   ; delay time between search periods
            ; ld (BGTIMER2), a
            ; ld a, TRUE
            ; ld (REDRAW_WINDOW), a
SOBJ2:
            ; call PLAY_SOUND_QUEUE_PLAY      ;play delayed sound effects
            ; call PET_SCREEN_SHAKE
            ; call BACKGROUND_TASKS
            ; ld a, (BGTIMER2)
            ; and a
            ; jr nz, SOBJ2

            ; ld a,SND_SEARCHING
            ; call PLAY_SOUND

            ; ld a, (SEARCHBAR)
            ; ld e, a
            ; ld d, 0
            ; ld hl, TEXT_BUFFER+SCREEN_WIDTH*23+9
            ; add hl, de
            ; ld (hl), 46 ; Period
            ; inc a
            ; ld (SEARCHBAR), a
            ; cp 8
            ; jr nz, SOBJ1
            ; xor a
            ; ld (CURSOR_ON), a
            ; call DRAW_MAP_WINDOW
            ; call CALC_COORDINATES
            ; call CHECK_FOR_HIDDEN_UNIT
            ; ld a, (UNIT_FIND)
            ; cp #ff
            ; jr nz, SOBJ5
CHS3:
            ; ld hl, MSG_NOTFOUND
            ; call PRINT_INFO
            ; ld a,SND_ERROR
            ; jp PLAY_SOUND       ;call:ret
            return

SOBJ5:
            ; ld a, (UNIT_FIND)
            ; ld e, a
            ; ld d, 0
            ; ld hl, UNIT_TYPE
            ; add hl, de
            ; ld a, (hl)
            ; ld (TEMP_A), a  ; store object type
            ; ld hl, UNIT_A
            ; add hl, de
            ; ld a, (hl)
            ; ld (TEMP_B), a  ; store secondary info

            ; ; Delete item once found
            ; ld hl, UNIT_TYPE
            ; add hl, de
            ; ld (hl), ID_NULL

            ; ld a, (TEMP_A)
            ; cp ID_HIDDEN_KEY
            ; jr nz, SOBJ15

            ; ; Key found
SOBJ10:
            ; ld a, (TEMP_B)
            ; and a
            ; jr nz, SOBJK1
            ; ld a, (KEYS)
            ; or KEY_TYPE_SPADE
            ; ld (KEYS), a
            ; jr SOBJ12
SOBJK1:
            ; cp 1
            ; jr nz, SOBJK2
            ; ld a, (KEYS)
            ; or KEY_TYPE_HEART
            ; ld (KEYS), a
            ; jr SOBJ12
SOBJK2:
            ; ld a, (KEYS)
            ; or KEY_TYPE_STAR
            ; ld (KEYS), a
SOBJ12:
            ; ld hl, MSG_FOUNDKEY
            ; jr found_something
SOBJ15:
            ; cp ID_HIDDEN_BOMB
            ; jr nz, SOBJ17
            ; ld a, (TEMP_B)
            ; ld hl, INV_BOMBS
            ; add a, (hl)
            ; ld (hl), a
            ; ld hl, MSG_FOUNDBOMB
            ; jr found_something
SOBJ17:
            ; cp ID_HIDDEN_EMP
            ; jr nz, SOBJ20
            ; ld a, (TEMP_B)
            ; ld hl, INV_EMP
            ; add a, (hl)
            ; ld (hl), a
            ; ld hl, MSG_FOUNDEMP
            ; jr found_something
SOBJ20:
            ; cp ID_HIDDEN_PISTOL
            ; jr nz, SOBJ21
            ; ld a, (TEMP_B)
            ; ld hl, AMMO_PISTOL
            ; add a, (hl)
            ; jr nc, SOBJ2A
            ; ld a, #ff
SOBJ2A:
            ; ld (hl), a
            ; ld hl, MSG_FOUNDGUN
            ; jr found_something
SOBJ21:
            ; cp ID_HIDDEN_PLASMA
            ; jr nz, SOBJ22
            ; ld a, (TEMP_B)
            ; ld hl, AMMO_PLASMA
            ; add a, (hl)
            ; ld (hl), a
            ; ld hl, MSG_FOUNDPLAS
            ; jr found_something
SOBJ22:
            ; cp ID_HIDDEN_MEDKIT
            ; jr nz, SOBJ23
            ; ld a, (TEMP_B)
            ; ld hl, INV_MEDKIT
            ; add a, (hl)
            ; ld (hl), a
            ; ld hl, MSG_FOUNDMED
            ; jr found_something
SOBJ23:
            ; cp ID_HIDDEN_MAGNET
            ; ret nz
            ; ld a, (TEMP_B)
            ; ld hl, INV_MAGNET
            ; add a, (hl)
            ; ld (hl), a
            ; ld hl, MSG_FOUNDMAG
            ; ;jr found_something

found_something:
            ; call PRINT_INFO
            ; call DISPLAY_KEYS
            ; call DISPLAY_WEAPON
            ; call DISPLAY_ITEM
            ; call draw_buffer
    mov #ITEM_FOUND, r0        ; ld a, SND_ITEM_FOUND
    call playSound             ; jp PLAY_SOUND       ;call:ret


; This routine is called by routines such as the move, search, or use commands.
; It displays a cursor and allows the user to pick a direction of an object.
userSelectObject:
    mov #BEEP, r0
    call playSound

            ; ld a, VIEWPORT_TILE_WDT/2
            ; ld (CURSOR_X), a
            ; ld a, VIEWPORT_TILE_HGT/2
            ; ld (CURSOR_Y), a
            ; ld a, TRUE
            ; ld (CURSOR_ON), a
            ; call REVERSE_TILE

            ; ; First ask user which object to move
SEL_OBJ01:
            ; call PLAY_SOUND_QUEUE_PLAY      ;play delayed sound effects
            ; call PET_SCREEN_SHAKE
            ; call BACKGROUND_TASKS
            ; ld a, (UNIT_TYPE)
            ; and a   ; Did player die wile moving something?
            ; jr nz, SEL_OBJ_CONT
            ; xor a
            ; ld (CURSOR_ON), a
            ; ret
SEL_OBJ_CONT:
            ; call draw_buffer
            ; call GETIN

            ; ld hl, TECLADO
            ; ; check key up
            ; cp (hl)
            ; jr nz, SEL_OBJ_DOWN
            ; ld hl, CURSOR_Y
            ; dec (hl)
            ; jr SEL_END
SEL_OBJ_DOWN:
            ; inc hl
            ; cp (hl)
            ; jr nz, SEL_OBJ_LEFT
            ; ld hl, CURSOR_Y
            ; inc (hl)
            ; jr SEL_END
SEL_OBJ_LEFT:
            ; inc hl
            ; cp (hl)
            ; jr nz, SEL_OBJ_RIGHT
            ; ld hl, CURSOR_X
            ; dec (hl)
            ; jr SEL_END
SEL_OBJ_RIGHT:
            ; inc hl
            ; cp (hl)
            ; jr nz, SEL_OBJ01
            ; ld hl, CURSOR_X
            ; inc (hl)
SEL_END:
            ; ld a, SND_USER_ACTION
            ; jp PLAY_SOUND ; call:ret
    return

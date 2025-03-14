CHEATCODE: .ascii "TROUBLEMAKINGS"
           .even

WATER_TEMP1: .ds 1
FLASH_STATE: .ds 1
MENUY:       .ds 1

UNIT_TIMER_A: .ds.b 64 ; Primary timer for units (64 bytes)
UNIT_TIMER_B: .ds.b 64 ; Secondary timer for units (64 bytes)
UNIT_TILE:    .ds.b 32 ; Current tile assigned to unit (32 bytes)
EXP_BUFFER:   .ds.b 16 ; Explosion Buffer (16 bytes)
MAP_PRECALC:  .ds.b MAP_PRECALC_SIZE ; Stores pre-calculated objects for map window (originally 77 bytes)
              .even

                                       ; ANIMATE         ds 1
                                       ;
                                       ; RANDOM          ds 1
                                       ; TILE_ADDR       ds 2
AMMO_PISTOL:   .ds 1
AMMO_PLASMA:   .ds 1
INV_BOMBS:     .ds 1
INV_EMP:       .ds 1
INV_MEDKIT:    .ds 1
INV_MAGNET:    .ds 1
SELECTED_ITEM: .ds 1
                                       ; SELECT_TIMEOUT      ds 1
MAGNET_ACT:   .ds 1
PLASMA_ACT:   .ds 1
BIG_EXP_ACT:  .ds 1
SCREEN_SHAKE: .ds 1
LOADED_MAP:   .word 1
                                       ; CONTROL         ds 1
                                       ; BGTIMER1        ds 1
                                       ; BGTIMER2        ds 1
                                       ; KEYTIMER        ds 1 ; Used for repeat of movement
                                       ; KEY_FAST        ds 1
                                       ; CLOCK_ACTIVE    ds 1
MAP_WINDOW_X: .ds 1 ; Top left location of what is displayed in map window
MAP_WINDOW_Y: .ds 1 ; Top left location of what is displayed in map window
MAP_X: .ds 1 ; Current X location on map
MAP_Y: .ds 1 ; Current Y location on map
                                       ; ;TEMP_X         ds 1 ; Temporarily used for loops
                                       ; ;TEMP_Y         ds 1 ; Temporarily used for loops
                                       ; PRECALC_COUNT   ds 1 ; part of screen draw routine
MOVE_TYPE: .ds 1 ; %00000001=WALK %00000010=HOVER
TILE: .ds 1      ; The tile number to be plotted

CURSOR_ON:    .ds 1 ; Is cursor active or not? 1=yes 0=no
CURSOR_X:     .ds 1 ; For on-screen cursor
CURSOR_Y:     .ds 1 ; For on-screen cursor
                                       ; ;MOVE_RESULT    ds 1 ; 1=Move request success, 0=fail.
; UNIT_FIND: .ds 1 ; 255=no unit present.
                                       ; SEARCHBAR       ds 1
                                       ; TEMP_A          ds 1 ; used within some routines
                                       ; TEMP_B          ds 1 ; used within some routines
                                       ; MOVTEMP_O       ds 1 ; origin tile
                                       ; MOVTEMP_D       ds 1 ; destination tile
                                       ; MOVTEMP_X       ds 1 ; x-coordinate
                                       ; MOVTEMP_Y       ds 1 ; y-coordinate
                                       ; MOVTEMP_U       ds 1 ; unit number (255=none)
                                       ; MOVTEMP_UX      ds 1
                                       ; MOVTEMP_UY      ds 1
MAP_ADDR: .ds 1
                                       ; ELEVATOR_MAX_FLOOR  ds 1
                                       ; ELEVATOR_CURRENT_FLOOR  ds 1
DISABLE_CONTROLS: .ds 1

; -----------------------------------------------------------------------------
;           VARIABLES
; -----------------------------------------------------------------------------
;PLASMA Gun
    .ifdef COLOR_TILES
WEAPON1A: .word 0x2C06,0x2000,0x2000,0x2000,0x2000,0x2C06
WEAPON1B: .word 0xE202,0xF902,0xEF04,0xE406,0x6606,0x6606
WEAPON1C: .word 0x2000,0x2000,0x2000,0x2000,0x5F03,0xDF03
WEAPON1D: .word 0x2000,0x2000,0x2000,0x2000,0x2000,0x2000
    .else
WEAPON1A: .byte 0x2C,0x20,0x20,0x20,0x20,0x2C
WEAPON1B: .byte 0xE2,0xF9,0xEF,0xE4,0x66,0x66
WEAPON1C: .byte 0x20,0x20,0x5C,0x20,0x5F,0xDF
WEAPON1D: .byte 0x20,0x20,0x7E,0x20,0x20,0x20
    .endif

    .ifdef COLOR_TILES
PISTOL1A: .word 0x2007,0x2007,0x2007,0x2007,0x2C07,0x2007
PISTOL1B: .word 0x2007,0xE207,0xEF07,0xE407,0x6607,0x2007
PISTOL1C: .word 0x2007,0x2007,0x2007,0x5F07,0xDF07,0x2007
PISTOL1D: .word 0x2007,0x2007,0x2007,0x2007,0x2007,0x2007
    .else
PISTOL1A: .byte 0x20,0x20,0x20,0x20,0x2C,0x20
PISTOL1B: .byte 0x20,0xE2,0xEF,0xE4,0x66,0x20
PISTOL1C: .byte 0x20,0x20,0x20,0x5F,0xDF,0x20
PISTOL1D: .byte 0x20,0x20,0x20,0x20,0x20,0x20
    .endif

;Time Bomb  (PET / C64)
TBOMB1A: .byte 0x20,0x20,0x20,0x55,0x2A,0x20
TBOMB1B: .byte 0x20,0x20,0x55,0x66,0x49,0x20
TBOMB1C: .byte 0x20,0x20,0x42,0x20,0x48,0x20
TBOMB1D: .byte 0x20,0x20,0x4A,0x46,0x4B,0x20

;EMP (PET / C64)
EMP1A:   .byte 0x20,0x55,0x43,0x43,0x49,0x20
EMP1B:   .byte 0x66,0xDF,0x55,0x49,0xE9,0x66
EMP1C:   .byte 0x66,0x69,0x4A,0x4B,0x5F,0x66
EMP1D:   .byte 0x20,0x4A,0x46,0x46,0x4B,0x20

;Magnet (PET / C64)
MAG1A:   .byte 0x4D,0x70,0x6E,0x70,0x6E,0x4E
MAG1B:   .byte 0x20,0x42,0x42,0x48,0x48,0x20
MAG1C:   .byte 0x63,0x42,0x4A,0x4B,0x48,0x63
MAG1D:   .byte 0x4E,0x4A,0x46,0x46,0x4B,0x4D

;Medkit (PET / C64)
MED1A:   .byte 0x20,0x55,0x43,0x43,0x49,0x20
MED1B:   .byte 0x20,0xA0,0xA0,0xA0,0xA0,0x20
MED1C:   .byte 0x20,0xA0,0xEB,0xF3,0xA0,0x20
MED1D:   .byte 0x20,0xE4,0xE4,0xE4,0xE4,0x20

;Empty Icon
EMPTYA:  .byte 0x20,0x20,0x20,0x20,0x20,0x20
         .byte 0x20,0x20,0x20,0x20,0x20,0x20
         .byte 0x20,0x20,0x20,0x20,0x20,0x20
         .byte 0x20,0x20,0x20,0x20,0x20,0x20

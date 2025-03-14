; ---------------------------------------------------------------------------- ;
;                            PETSCII ROBOTS CONST                              ;
; ---------------------------------------------------------------------------- ;
.equiv TRUE,  1
.equiv FALSE, 0

.equiv SCREEN_WIDTH, LINE_WIDTHW

.equiv MOVE_WALK,  0b00000001
.equiv MOVE_HOVER, 0b00000010

    ; We've detected some of the hardcode in the
    ; original sources and added constants.

    ; Timers and delays
    ; Original values designed for 60 Hz machine
; -----------------------------------------
    ; 3x3 constants
.equiv HOVERBOT_MOVE_SPD,       8 ; original value is 10
.equiv HOVERBOT_ATTACK_SPD,     6 ; original value is 7
.equiv HOVERBOT_ANIM_SPEED,     2 ; original value is 3
.equiv DOOR_SPEED,              4 ; original value is 5
.equiv ROLLERBOT_MOVE_SPD,      6 ; original value is 7
.equiv ROLLERBOT_ANIM_SPEED,    2 ; original value is 3
.equiv MAGNET_EFFECT_DURATION, 48 ; original value is 60
.equiv TIMER_BOMB,             80 ; original value is 100
.equiv DEAD_ROBOT_TIMEOUT,    204 ; original value is 255
.equiv SEARCH_PERIOD_DELAY,    15 ; original value is 18
.equiv KBD_DELAY,              15 ; original value is 20
.equiv BLOCKED_DOOR_DELAY,     28 ; original value is 35
.equiv CLOSED_DOOR_DELAY,      16 ; original value is 20
.equiv BLOCKED_ELEVATOR_DELAY, 28 ; original value is 35
.equiv CLOSED_ELEVATOR_DELAY,  16 ; original value is 20
.equiv RAFT_SPEED,              5 ; original value is 6
.equiv RAFT_WAIT_TIME,         80 ; original value is 100
.equiv OPENED_DOOR_DELAY,      30 ; original value is 30
.equiv EVILBOT_ANIM_SPD,        4 ; original value is 5
.equiv COMPACTOR_1ST_DELAY,    16 ; original value is 20
.equiv COMPACTOR_2ND_DELAY,     8 ; original value is 10
.equiv COMPACTOR_3RD_DELAY,    40 ; original value is 50
.equiv COMPACTOR_COOLDOWN,      8 ; original value is 10
.equiv BOMB_ANIM_DELAY,         9 ; original value is 12
.equiv CHAIN_EXPLODE_DELAY,     8 ; original value is 10

    ; AI id
.equiv AI_DROID_LEFT_RIGHT, 2
.equiv AI_DROID_UP_DOWN,    3
.equiv AI_HOVER_ATTACK,     4
.equiv AI_WATERDROID,       5
.equiv AI_BOMB,             6
.equiv AI_TRANSPORTER,      7
.equiv AI_DEAD_ROBOT,       8
; No need to define evilbot AI,
; this is defined directly in the map file and not redefined during the game.
; Skip, 9
; Ditto for doors, Skip, 10
.equiv AI_SMALL_EXPLOSION, 11
.equiv AI_PISTOL_UP,       12
.equiv AI_PISTOL_DOWN,     13
.equiv AI_PISTOL_LEFT,     14
.equiv AI_PISTOL_RIGHT,    15
; Skip, 16-18
.equiv AI_ELEVATOR,        19
.equiv AI_MAGNET,          20
.equiv AI_CRAZY_ROBOT,     21
; Skip, 22
.equiv AI_DEMATERIALIZE,   23

    ; Items
.equiv ID_NULL,   0
.equiv ID_BOMB,   1
.equiv ID_EMP,    2
.equiv ID_MEDKIT, 3
.equiv ID_MAGNET, 4
.equiv EOF_ITEMS, 5

    ; Weapons
.equiv ID_PISTOL, 1
.equiv ID_PLASMA_GUN, 2

    ; Tiles
.equiv TILE_FLOOR,           0x09
.equiv TILE_BIG_CRATE,       0x29
.equiv TILE_SMALL_CRATE,     0x2D
.equiv TILE_PLAYER_A,        0x60
.equiv TILE_PLAYER_B,        0x61
.equiv TILE_HOVERBOT_A,      0x62
.equiv TILE_HOVERBOT_B,      0x63
.equiv TILE_EVILBOT_A,       0x64
.equiv TILE_EVILBOT_B,       0x65
.equiv TILE_EVILBOT_C,       0x66
.equiv TILE_DEAD_PLAYER,     0x6F
.equiv TILE_DEAD_ROBOT,      0x73
.equiv TILE_BOMB,            0x82
.equiv TILE_CANNISTER,       0x83
.equiv TILE_BLOWN_CANNISTER, 0x87
.equiv TILE_MAGNET,          0x86
.equiv TILE_WATERDROID_BEGIN,0x8C
.equiv TILE_WATERDROID_END,  0x8F
.equiv TILE_TRASH_ZONE,      0x94
.equiv TILE_DEMATERIALIZE,   0xA0
.equiv TILE_ROLLERBOT_A,     0xA4
.equiv TILE_ROLLERBOT_B,     0xA5
.equiv TILE_PI_CRATE,        0xC7
.equiv TILE_WATER,           0xCC
.equiv TILE_RAFT,            0xF2
.equiv TILE_PISTOL_VERT,     0xF4
.equiv TILE_PISTOL_HORZ,     0xF5
.equiv TILE_EXPLOSION,       0xF6

    ; Objects
.equiv KEY_TYPE_SPADE,   0b001
.equiv KEY_TYPE_HEART,   0b010
.equiv KEY_TYPE_STAR,    0b100
.equiv ID_HIDDEN_KEY,    128
.equiv ID_HIDDEN_BOMB,   129
.equiv ID_HIDDEN_EMP,    130
.equiv ID_HIDDEN_PISTOL, 131
.equiv ID_HIDDEN_PLASMA, 132
.equiv ID_HIDDEN_MEDKIT, 133
.equiv ID_HIDDEN_MAGNET, 134

    ; Sounds
;;SND_EXPLOSION, 0
;;SND_SMALL_EXPLOSION, 1
;;SND_USE_MEDKIT, 2
;;SND_USE_EMP, 3
;;SND_HAYWIRE, 4
;;SND_EVILBOT, 5
;;SND_MOVE_OBJECT, 6
;;SND_ELECTRIC, 7   ; This is player hit actually
;;SND_PLASMAGUN, 8
;;SND_PISTOL, 9
;;SND_ITEM_FOUND, 10
;;SND_ERROR, 11
;;SND_CHANGE_WEAPON, 12
;;SND_CHANGE_ITEM, 13
;;SND_DOOR, 14  ; Used for any doors opening/closing (we're muted closing)
;;SND_MENU_CURSOR, 15
;;SND_USER_ACTION, 16
;;SND_ELEVATOR, 17  ; This is when the elevator does up/down
;;SND_MENU_SELECT, 18
;;SND_STEP_L, 19
;;SND_STEP_R, 20
;;SND_WALL_HIT, 21
;;SND_ROBOT_HIT, 22
;;SND_ROBOT_DOWN, 23
;;SND_PLAYER_DOWN, 24
;;SND_ROBOT_GUN, 25
;;SND_TRASH_OPEN, 26
;;SND_TRASH_CLOSE, 27
;;SND_SEARCHING, 28
;;SND_TELEPORTING, 29
;;SND_TELEPORTED, 30
;;SND_TITLE_MUSIC, 31
;;SND_WIN_MUSIC, 32
;;SND_LOSE_MUSIC, 33

    ; Misc
.equiv MAP_WIDTH, 128
.equiv MAP_HEIGHT, 64
.equiv MAP_UNITS_COUNT, 64
.equiv MAPS_TOTAL, 15

    ; Game data structures
    ; Still 6502 style
.equiv MAP_BEGIN,   LEVEL_MAP
            ; Start of map ==>
.equiv UNIT_TYPE,    MAP_BEGIN
.equiv UNIT_LOC_X,   UNIT_TYPE    + MAP_UNITS_COUNT
.equiv UNIT_LOC_Y,   UNIT_LOC_X   + MAP_UNITS_COUNT
.equiv UNIT_A,       UNIT_LOC_Y   + MAP_UNITS_COUNT
.equiv UNIT_B,       UNIT_A       + MAP_UNITS_COUNT
.equiv UNIT_C,       UNIT_B       + MAP_UNITS_COUNT
.equiv UNIT_D,       UNIT_C       + MAP_UNITS_COUNT
.equiv UNIT_HEALTH,  UNIT_D       + MAP_UNITS_COUNT
.equiv UNUSED_SPACE, UNIT_HEALTH  + MAP_UNITS_COUNT
.equiv MAP,          UNUSED_SPACE + MAP_UNITS_COUNT * 4 ; 256 bytes of unsused space
            ; <== end of map.
.equiv MAP_END,     MAP + (MAP_WIDTH * MAP_HEIGHT) ; 8192 bytes

; -----------------------------------------------------------------------------
;           SCREEN RELATED CONSTANTS AND ARRAYS
;           X+Y*SCREEN_WIDTH
; -----------------------------------------------------------------------------

.equiv OFFS_MAINMENU_CONTROLS, 1+5*SCREEN_WIDTH
.equiv OFFS_MAINMENU_EYEBROW_LEFT,  15+5*SCREEN_WIDTH
.equiv OFFS_MAINMENU_EYEBROW_RIGHT, 19+5*SCREEN_WIDTH
.equiv OFFS_MAINMENU_MAPNUMBER, 7+8*SCREEN_WIDTH
.equiv OFFS_MAINMENU_MAPNAME,   0+9*SCREEN_WIDTH
.equiv OFFS_REDEFINE_CONTROLS, 17+7*SCREEN_WIDTH
.equiv OFFS_REDEFINE_DONE, 5+22*SCREEN_WIDTH
.equiv OFFS_DISPLAY_WEAPON, 34+1*SCREEN_WIDTH ; 26+1
.equiv OFFS_DISPLAY_ITEM, 26+8*SCREEN_WIDTH
.equiv OFFS_DISPLAY_KEYS, 34+15*SCREEN_WIDTH  ; 26+15
.equiv OFFS_DISPLAY_KEY1, OFFS_DISPLAY_KEYS
.equiv OFFS_DISPLAY_KEY2, OFFS_DISPLAY_KEY1+2
.equiv OFFS_DISPLAY_KEY3, OFFS_DISPLAY_KEY2+2
.equiv OFFS_PLAYER_HEALTH, 34+23*SCREEN_WIDTH ; 26+22
.equiv OFFS_DISPLAY_OUCH, 27+18*SCREEN_WIDTH
.equiv OFFS_GAMEOVER_STR1, 8+9*SCREEN_WIDTH
.equiv OFFS_GAMEOVER_STR2, 8+10*SCREEN_WIDTH
.equiv OFFS_GAMEOVER_STR3, 8+11*SCREEN_WIDTH
.equiv OFFS_PRINT_INFO, 0+24*SCREEN_WIDTH ; 0+23
.equiv OFFS_RESULTS_MAPNAME, 17+7*SCREEN_WIDTH
.equiv OFFS_RESULTS_TIME,    21+9*SCREEN_WIDTH
.equiv OFFS_RESULTS_ROBOTS,  27+11*SCREEN_WIDTH
.equiv OFFS_RESULTS_SECRETS, 27+13*SCREEN_WIDTH
.equiv OFFS_RESULTS_DIFFICULTY, 24+15*SCREEN_WIDTH
.equiv OFFS_ELEVATOR_BUTTONS, 6+(23*SCREEN_WIDTH)
.equiv OFFS_WINLOSE_MSG, 12+3*SCREEN_WIDTH
.equiv OFFS_BUILD_STR, 26

.equiv VIEWPORT_TILE_WDT, 11 ; Viewport width in 3x3 tiles
.equiv VIEWPORT_TILE_HGT,  7 ; Viewport height in 3x3 tiles

.equiv MAP_PRECALC_SIZE, VIEWPORT_TILE_WDT * VIEWPORT_TILE_HGT

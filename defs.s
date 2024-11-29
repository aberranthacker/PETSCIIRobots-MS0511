;===============================================================================
;--- Note that the PRESENCE of those variables is tested, NOT their values. ----
.equiv DEBUG, 1
;.equiv WORD_LINE_NUMBERS, 1
;.equiv INCLUDE_AKG_PLAYER, 1
.ifdef INCLUDE_AKG_PLAYER
    .equiv DETECT_ABERRANT_SOUND_MODULE, 1
.endif
;.equiv DOUBLED_LINES, 1
;===============================================================================
.equiv PPU.LoadDiskFile,      0*2
.equiv PPU.SetPalette,        1*2
.equiv PPU.ClearScreen,       2*2
.equiv PPU.test_timer,        3*2
.equiv PPU.ssy_music_play,    4*2

.equiv PPU.LastJMPTableIndex, 4*2

.equiv PPU.SET_FB0_VISIBLE, 0
.equiv PPU.SET_FB1_VISIBLE, 1
;-------------------------------------------------------------------------------
.equiv ExtMemSizeBytes, 7168
;-------------------------------------------------------------------------------
.equiv MAIN_SCREEN_LINES_COUNT, 200
    .ifdef DOUBLED_LINES
.equiv AUX_SCREEN_LINES_COUNT, 288 - MAIN_SCREEN_LINES_COUNT * 2
    .else
.equiv AUX_SCREEN_LINES_COUNT, 288 - MAIN_SCREEN_LINES_COUNT
    .endif
.equiv LINE_SCALE, 1
.equiv LINE_WIDTHB, 640 / (LINE_SCALE * 2) / 8 * 2
.equiv LINE_WIDTHW, LINE_WIDTHB / 2
.equiv FB_SIZEB, MAIN_SCREEN_LINES_COUNT * LINE_WIDTHB
.equiv FB_SIZEW, MAIN_SCREEN_LINES_COUNT * LINE_WIDTHW
; CPU memory map ---------------------------------------------------------------
.equiv INTERRUPT_HANDLER_STUB, 0  ; installed by bootsector
.equiv SAVED_SP, 2                ; place to store SP if needed
.equiv PPUCommandArg, 052 ; 38 0x26 command for PPU argument
.equiv CPU_PPUCommandArg, PPUCommandArg/2
.equiv KeyboardScanner, 054
.equiv PPU_KeyboardScanner, KeyboardScanner/2

.equiv FB0, 0600 ; 0384 0x0180
.equiv FB_GAP, FB0 + LINE_WIDTHB * MAIN_SCREEN_LINES_COUNT
.equiv FB1, FB_GAP+384

.equiv INITIAL_SP, 0160000
.equiv PPU_MODULE_LOADING_ADDR, FB1
.equiv LOADER_START, FB1
; 0160000 57344 0xE000 end of RAM ----------------------------------------------

.equiv PPU_UserRamSize, 0054104 ; 22596 0x5844
.equiv PPU_UserRamSizeWords, PPU_UserRamSize/2 ; 0026042 11298 0x2C22

; PPU memory map ---------------------------------------------------------------
.equiv PPU_UserRamStart, 0023666 ; 10166 0x27B6
.equiv PPU_UserRamEnd,   0077772 ; 32762 0x7FFA
.equiv PPU_UserProcessMetadataAddr, PPU_UserRamEnd
;-end of PPU memory map---------------------------------------------------------

; VRAM memory map --------------------------------------------------------------
.equiv SLTAB, 0140000 ; 32768 0x8000 # bank 0
.equiv AUX_SCREEN_ADDR, 0160000 ; 49152 0xC000 # banks 0, 1 and 2
;-end of VRAM memory map--------------------------------------------------------

.equiv setCursorScalePalette, 0
.equiv cursorGraphic, 0x10 ; 020 dummy parameter
.equiv scale640, 0x00
.equiv scale320, 0x10
.equiv scale160, 0x20
.equiv scale80,  0x30
    .ifdef RGBpalette
.equiv rgb, 0b000
.equiv rgB, 0b001
.equiv rGb, 0b010
.equiv rGB, 0b011
.equiv Rgb, 0b100
.equiv RgB, 0b101
.equiv RGb, 0b110
.equiv RGB, 0b111
    .else
.equiv rgb, 0b000
.equiv rgB, 0b001
.equiv rGb, 0b100
.equiv rGB, 0b101
.equiv Rgb, 0b010
.equiv RgB, 0b011
.equiv RGb, 0b110
.equiv RGB, 0b111
    .endif
;-------------------------------------------------------------------------------
.equiv setColors, 1
    .ifdef RGBpalette
.equiv BLACK,   0b000 ; 0x0
.equiv BLUE,    0b001 ; 0x1
.equiv GREEN,   0b010 ; 0x2
.equiv CYAN,    0b011 ; 0x3
.equiv RED,     0b100 ; 0x4
.equiv MAGENTA, 0b101 ; 0x5
.equiv YELLOW,  0b110 ; 0x6
.equiv GRAY,    0b111 ; 0x7
    .else
.equiv BLACK,   0b000 ; 0x0
.equiv BLUE,    0b001 ; 0x1
.equiv RED,     0b010 ; 0x2
.equiv MAGENTA, 0b011 ; 0x3
.equiv GREEN,   0b100 ; 0x4
.equiv CYAN,    0b101 ; 0x5
.equiv YELLOW,  0b110 ; 0x6
.equiv GRAY,    0b111 ; 0x7
    .endif
.equiv BR_BLUE,    010 | BLUE    ; 0x9
.equiv BR_RED,     010 | RED     ; 0xC
.equiv BR_MAGENTA, 010 | MAGENTA ; 0xD
.equiv BR_GREEN,   010 | GREEN   ; 0xA
.equiv BR_CYAN,    010 | CYAN    ; 0xB
.equiv BR_YELLOW,  010 | YELLOW  ; 0xE
.equiv WHITE,      010 | GRAY    ; 0xF

.equiv Black,     BLACK      << 4 | BLACK
.equiv Blue,      BLUE       << 4 | BLUE
.equiv Green,     GREEN      << 4 | GREEN
.equiv Cyan,      CYAN       << 4 | CYAN
.equiv Red,       RED        << 4 | RED
.equiv Magenta,   MAGENTA    << 4 | MAGENTA
.equiv Yellow,    YELLOW     << 4 | YELLOW
.equiv Gray,      GRAY       << 4 | GRAY
.equiv brBlue,    BR_BLUE    << 4 | BR_BLUE
.equiv brGreen,   BR_GREEN   << 4 | BR_GREEN
.equiv brCyan,    BR_CYAN    << 4 | BR_CYAN
.equiv brRed,     BR_RED     << 4 | BR_RED
.equiv brMagenta, BR_MAGENTA << 4 | BR_MAGENTA
.equiv brYellow,  BR_YELLOW  << 4 | BR_YELLOW
.equiv White,     WHITE      << 4 | WHITE

.equiv setOffscreenColors, 2

.equiv untilLine, -1
.ifdef DOUBLED_LINES
    .equiv untilEndOfScreen, MAIN_SCREEN_LINES_COUNT * 2 + 1
    .equiv endOfScreen, MAIN_SCREEN_LINES_COUNT * 2 + 1
.else
    .equiv untilEndOfScreen, MAIN_SCREEN_LINES_COUNT + 1
    .equiv endOfScreen, MAIN_SCREEN_LINES_COUNT + 1
.endif
;-------------------------------------------------------------------------------
.equiv RTI_OPCODE, 000002
.equiv NOP_OPCODE, 000240
.equiv INC_R0_OPCODE, 0005200
.equiv DECB_R3_OPCODE, 0105303
.equiv MOVB_R3_R3_OPCODE, 0110303

; Player_driver uses ROLB to check which keys were pressed.
; So if you change keymap here, modify player_driver code as well.
.equiv KEYMAP_PAUSE, 0x80
.equiv KEYMAP_F2,    0x40
.equiv KEYMAP_F1,    0x20
.equiv KEYMAP_LEFT,  0x10
.equiv KEYMAP_RIGHT, 0x08
.equiv KEYMAP_UP,    0x04
.equiv KEYMAP_DOWN,  0x02
.equiv KEYMAP_F3,    0x01
.equiv KEYMAP_ANY_FIRE, 0b01100001

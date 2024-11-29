       .list

       .title "PETSCII Robots bootstrap"

       .include "hwdefs.s"
       .include "macros.s"
       .include "defs.s"

       .global start

       .=LOADER_START

start:
        _ppu_enqueue PPU.test_timer
        br .
        mtps #PR0
        call ShowTitle
        wait


ShowTitle:
        _ppu_enqueue PPU.SetPalette, Black_palette

        mov #TitleGfx,r0
        mov #FB0,r1
        call UnZX0

        _ppu_enqueue PPU.SetPalette, Blue_palette
        mov #5,r0
        10$:
            wait
        sob r0,10$
        _ppu_enqueue PPU.SetPalette, Dark_palette
        mov #5,r0
        20$:
            wait
        sob r0,20$
        _ppu_enqueue PPU.SetPalette, Loader_palette
return

TitleGfx:
        .incbin "build/title.gfx.zx0"
        .incbin "build/faces.gfx"

        .even
Loader_palette: ;---------------------------------------------------------------
        .if AUX_SCREEN_LINES_COUNT != 0
    .byte      0, setOffscreenColors
    .word         BLACK | BLUE  << 4 | BLACK << 8 | BLACK << 12
    .word         BLACK | BLACK << 4 | BLACK << 8 | BLACK << 12
        .endif
    .word      0, setCursorScalePalette|cursorGraphic, LINE_SCALE<<4|RGB
    .byte      1, setColors, Black, Cyan, brCyan, White
    .word untilEndOfScreen
;-------------------------------------------------------------------------------
Dark_palette: ;-----------------------------------------------------------------
    .word      0, setCursorScalePalette|cursorGraphic, LINE_SCALE<<4|RGB
    .byte      1, setColors, Black, Blue, Cyan, Gray
    .word untilEndOfScreen
;-------------------------------------------------------------------------------
Blue_palette: ;-----------------------------------------------------------------
    .word      0, setCursorScalePalette|cursorGraphic, LINE_SCALE<<4|RGB
    .byte      1, setColors, Black, Black, Blue, Blue
    .word untilEndOfScreen
;-------------------------------------------------------------------------------
Black_palette: ;----------------------------------------------------------------
    .word      0, setCursorScalePalette|cursorGraphic, LINE_SCALE<<4|RGB
    .byte      1, setColors, Black, Black, Black, Black
    .word untilEndOfScreen
;-------------------------------------------------------------------------------

end:

KeyboardIntHadler: ;------------------------------------------------------------
; key codes #-----------------------------------------------------{{{
; | oct | hex|  key    | note     | oct | hex|  key  |  note     |
; |-----+----+---------+----------+-----+----+-------+-----------|
; |   5 | 05 | ,       | numpad   | 106 | 46 | АЛФ   | 🌐Language|
; |   6 | 06 | АР2     | Esc      | 107 | 47 | ФИКС  | Lock      |
; |   7 | 07 | ; / +   |          | 110 | 48 | Ч / ^ |           |
; |  10 | 08 | К1 / К6 | F1 / F6  | 111 | 49 | С / S |           |
; |  11 | 09 | К2 / К7 | F2 / F7  | 112 | 4A | М / M |           |
; |  12 | 0A | КЗ / К8 | F3 / F8  | 113 | 4B | SPACE |           |
; |  13 | 0B | 4 / ¤   |          | 114 | 4C | Т / T |           |
; |  14 | 0C | К4 / К9 | F4 / F9  | 115 | 4D | Ь / X |           |
; |  15 | 0D | К5 / К10| F5 / F10 | 116 | 4E | ←     |           |
; |  16 | 0E | 7 / '   |          | 117 | 4F | , / < |           |
; |  17 | 0F | 8 / (   |          | 125 | 55 | 7     | numpad    |
; |  25 | 15 | -       | numPad   | 126 | 56 | 0     | numpad    |
; |  26 | 16 | ТАБ     | Tab      | 127 | 57 | 1     | numpad    |
; |  27 | 17 | Й / J   |          | 130 | 58 | 4     | numpad    |
; |  30 | 18 | 1 / !   |          | 131 | 59 | +     | numpad    |
; |  31 | 19 | 2 / "   |          | 132 | 5A | <=|   | Backspace |
; |  32 | 1A | 3 / #   |          | 133 | 5B | →     |           |
; |  33 | 1B | Е / E   |          | 134 | 5C | ↓     |           |
; |  34 | 1C | 5 / %   |          | 135 | 5D | . / > |           |
; |  35 | 1D | 6 / &   |          | 136 | 5E | Э / \ |           |
; |  36 | 1E | Ш / [   |          | 137 | 5F | Ж / V |           |
; |  37 | 1F | Щ / ]   |          | 145 | 65 | 8     | numpad    |
; |  46 | 26 | УПР     | Ctrl     | 146 | 66 | .     | numpad    |
; |  47 | 27 | Ф / F   |          | 147 | 67 | 2     | numpad    |
; |  50 | 28 | Ц / C   |          | 150 | 68 | 5     | numpad    |
; |  51 | 29 | У / U   |          | 151 | 69 | ИСП   | Exec      |
; |  52 | 2A | К / K   |          | 152 | 6A | УСТ   | Set       |
; |  53 | 2B | П / P   |          | 153 | 6B | ↵     | Return    |
; |  54 | 2C | H / N   |          | 154 | 6C | ↑     |           |
; |  55 | 2D | Г / G   |          | 155 | 6D | : / * |           |
; |  56 | 2E | Л / L   |          | 156 | 6E | Х / H |           |
; |  57 | 2F | Д / D   |          | 157 | 6F | З / Z |           |
; |  66 | 36 | ГРАФ    | Graph    | 165 | 75 | 9     | numpad    |
; |  67 | 37 | Я / Q   |          | 166 | 76 | ВВОД  | Enter     |
; |  70 | 38 | Ы / Y   |          | 167 | 77 | 3     | numpad    |
; |  71 | 39 | В / W   |          | 170 | 78 | 7     | numpad    |
; |  72 | 3A | А / A   |          | 171 | 79 | СБРОС | Reset     |
; |  73 | 3B | И / I   |          | 172 | 7A | ПОМ   | Help      |
; |  74 | 3C | Р / R   |          | 173 | 7B | / / ? |           |
; |  75 | 3D | О / O   |          | 174 | 7C | Ъ / } |           |
; |  76 | 3E | Б / B   |          | 175 | 7D | - / = |           |
; |  77 | 3F | Ю / @   |          | 176 | 7E | О / } |           |
; | 105 | 45 | ⇕ HP    | Shift    | 177 | 7F | 9 / ) |           |
;-----------------------------------------------------------------}}}
        PUSH R0, R1, @#PBPADR

        MOV  #PPU_KeyboardScanner, @#PBPADR

        MOVB @#KBDATA, R0
        BMI  key_released$

    key_pressed$: ;------------------
        MOV  #KeyPressesScanCodes, R1
        CMPB R0, (R1)+
        BEQ  fire_right_pressed$
        CMPB R0, (R1)+
        BEQ  fire_left_pressed$
        CMPB R0, (R1)+
        BEQ  down_pressed$
        CMPB R0, (R1)+
        BEQ  up_pressed$
        CMPB R0, (R1)+
        BEQ  right_pressed$
        CMPB R0, (R1)+
        BEQ  left_pressed$
        CMPB R0, (R1)+
        BEQ  fire_smartbomb_pressed$
        CMPB R0, (R1)+
        BEQ  pause_pressed$

        BR   1237$
    ;--------------------------------
    KeyPressesScanCodes:
        FireRight: .byte 070  ; Y
        FireLeft:  .byte 047  ; F
        MoveDown:  .byte 0134 ; Down
        MoveUp:    .byte 0154 ; Up
        MoveRight: .byte 0133 ; Right
        MoveLeft:  .byte 0116 ; Left
        SmartBomb: .byte 046  ; УПР
        Pause:     .byte 015  ; К5

    key_released$: ;-----------------
        CMPB R0, #0210  ; Y
        BEQ  fire_right_released$

        CMPB R0, #0207  ; F
        BEQ  fire_left_released$

        CMPB R0, #0214 ; Up? or Down?
        BNE  not_up_down$

        BITB #KEYMAP_DOWN, @#PBP12D
        BZE  up_released$
        BR   down_released$

    not_up_down$:
        CMPB R0, #0213 ; Right
        BEQ  right_released$

        CMPB R0, #0216 ; Left
        BEQ  left_released$

        CMPB R0, #0206  ; УПР
        BEQ  fire_smartbomb_released$

        CMPB R0, #0215  ; К5
        BEQ  pause_released$

        BR   1237$
    ;--------------------------------
    fire_smartbomb_pressed$: ;-------
        MOV  #KEYMAP_F3, R0
        BR   set_bit$
    down_pressed$:
        MOV  #KEYMAP_DOWN, R0
        BR   set_bit$
    up_pressed$:
        MOV  #KEYMAP_UP, R0
        BR   set_bit$
    right_pressed$:
        MOV  #KEYMAP_RIGHT, R0
        BR   set_bit$
    left_pressed$:
        MOV  #KEYMAP_LEFT, R0
        BR   set_bit$
    fire_right_pressed$:
        MOV  #KEYMAP_F1, R0
        BR   set_bit$
    fire_left_pressed$:
        MOV  #KEYMAP_F2, R0
        BR   set_bit$
    pause_pressed$:
        MOV  #KEYMAP_PAUSE, R0
        BR   set_bit$
    ;--------------------------------
    fire_smartbomb_released$: ;------
        MOV  #KEYMAP_F3, R0
        BR   clear_bit$
    down_released$:
        MOV  #KEYMAP_DOWN, R0
        BR   clear_bit$
    up_released$:
        MOV  #KEYMAP_UP, R0
        BR   clear_bit$
    right_released$:
        MOV  #KEYMAP_RIGHT, R0
        BR   clear_bit$
    left_released$:
        MOV  #KEYMAP_LEFT, R0
        BR   clear_bit$
    fire_right_released$:
        MOV  #KEYMAP_F1, R0
        BR   clear_bit$
    fire_left_released$:
        MOV  #KEYMAP_F2, R0
        BR   clear_bit$
    pause_released$:
        MOV  #KEYMAP_PAUSE, R0
        BR   clear_bit$
    ;--------------------------------
    set_bit$:
        BIS  R0, @#PBP12D
        BR   1237$
    clear_bit$:
        BIC  R0, @#PBP12D

1237$:
        POP @#PBPADR, R1, R0
        RTI
;-------------------------------------------------------------------------------

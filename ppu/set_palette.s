SetPalette:
        PUSH @#PASWCR
        MOV  #0x040, @#PASWCR
        MOV  #PBPADR, R4

        CLC
        ROR  R0
        MOV  R0, (R4) ; palette address
      ; R0 - first parameter word
      ; R1 - second parameter word
      ; R2 - display/color parameters flag
      ; R3 - current line
      ; R4 - next line where parameters change
      ; R5 - pointer to a word that we'll modify
    .ifdef WORD_LINE_NUMBERS
        MOV  @#PBP12D, @#SetPalette_NextLineNum  ; get line number
    .else
        MOVB @#PBP1DT, @#SetPalette_NextLineNum  ; get line number
    .endif
        PUSH (R4)
SetPalette_NextRecord:
        MOV  @#SetPalette_NextLineNum,R3 ; R3 = previous iteration's next line
        MOV  R3, R5 ; prepare to calculate address of SLTAB section to modify
        ASH  #3, R5 ; calculate offset by multiplying by 8 (by shifting R5 left by 3 bits)
       .equiv SetPalette.MainScreenLinesTable, .+2
        ADD  #0, R5 ; and add address of SLTAB section we modify

        POP  (R4)
    .ifdef WORD_LINE_NUMBERS
        INC  (R4)
        MOV  @#PBP12D, R2 ; get display/color parameters flag
    .else
        MOVB @#PBP2DT, R2 ; get display/color parameters flag
    .endif
        BMI  SetPalette_Finalize ; negative value - terminator

        INC  (R4)
        MOV  @#PBP12D, R0 ; get first data word
        INC  (R4)
        MOV  @#PBP12D, R1 ; get second data word
        INC  (R4)
    .ifdef WORD_LINE_NUMBERS
        MOV  @#PBP12D, @#SetPalette_NextLineNum ; get next line idx
    .else
        MOVB @#PBP1DT, @#SetPalette_NextLineNum ; get next line idx
    .endif

        PUSH (R4)

        CMP R2,#2
    .if AUX_SCREEN_LINES_COUNT != 0
        BEQ SetPalette_OffscreenColors
    .else
        BEQ SetPalette_NextRecord
    .endif
    set_params$:
        TSTB R2
        BNZ SetPalette_SetColorRegisters ; 1 - set colors

SetPalette_SetControlRegisters:
        MOV  R5,(R4)
        BICB #0b100,@#PBP0DT ; 0 - set data
        INC  R5
        INC  R5

        BR   SetPalette_SetDataRegisters

SetPalette_SetColorRegisters:
        MOV  R5,(R4)
        BISB #0b100,@#PBP0DT ; 0 - set data
        INC  R5
        INC  R5

SetPalette_SetDataRegisters:
        MOV  R0,(R5)+
        MOV  R1,(R5)+
        INC  R5
        INC  R5           ; skip third word (screen line address)

        INC  R3           ; increase current line idx
       .equiv SetPalette_NextLineNum, .+2
        CMP  R3,#0        ; compare current line idx with next line idx
        BLO  set_params$  ; branch if lower

        CMP  @#SetPalette_NextLineNum, #endOfScreen
        BNE  SetPalette_NextRecord
        BR   SetPalette_POP_R4_and_Finalize

    .if AUX_SCREEN_LINES_COUNT != 0
SetPalette_OffscreenColors:
       .equiv SetPalette.TopAreaColors, .+2
        MOV  #0,R2
        MOV  R0,(R2)+
        MOV  R1,(R2)
       .equiv SetPalette.BottomAreaColors, .+2
        MOV  #0,R2
        MOV  R0,(R2)+
        MOV  R1,(R2)
        BR   SetPalette_NextRecord
    .endif

SetPalette_POP_R4_and_Finalize:
        POP  R4 ; remove a value from the stack
SetPalette_Finalize:
        POP  @#PASWCR

        RETURN

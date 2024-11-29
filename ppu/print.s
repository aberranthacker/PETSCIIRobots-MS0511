Print: ;---------------------------------------------------------------------{{{
       .equiv LineWidth, 40
       .equiv TextLinesCount, 25
       .equiv CharHeight, 8
       .equiv CharLineSize, LineWidth * CharHeight
       .equiv FbStart, FB1 >> 1
       .equiv BPDataReg, DTSOCT

        MOV  #10<<1,@#DTSCOL ; foreground color
        MOV  #LineWidth,R2
        MOV  #StrBuffer,R3
        MOV  #PBP12D,R4
        MOV  #PBPADR,R5
        MOV  #0b001,@#PBPMSK ; disable writes to bitplane 0

        CLC
        ROR  R0
        MOV  R0,(R5)  ; load address of a string into address register

LoadNext2Bytes:
        MOV  (R4),R0  ; load 2 bytes from CPU RAM
        MOV  R0,(R3)+ ; store them into buffer
        TSTB R0       ; test least significant byte
        BZE  3#       ; end of text
        BMI  2#       ; end of string

        SWAB R0       ; swap bytes to test most significant one
        BZE  3#       ; end of text
        BMI  2#       ; end of string

        INC  (R5)     ; next address
        BR   LoadNext2Bytes

2$:     INC  (R5)
        MOV  (R5),@#NextStringAddr

3$:     MOV  @#CurrentLine,R1 ; prepare to calculate relative char address
        MUL  #CharLineSize,R1 ; calculate relative address of the line
        ADD  @#CurrentChar,R1 ; calculate relative address of the char
        ADD  #FbStart,R1      ; calculate absolute address of the next char

        MOV  #StrBuffer,R3
        MOV  #BPDataReg,R4
NextChar:
        MOV  R1,(R5)      ; load address of the next char into address register
        MOVB (R3)+,R0     ; load character code from string buffer
        TSTB R0           ;
        BZE  DonePrinting ; end of text
        BMI  NextString   ; end of string
        CMPB #'\n, R0     ; new line?
        BEQ  NewLine      ;

        ASH  #3,R0        ; shift left by 3(multiply by 8)
        ADD  #Font,R0     ; calculate char bitmap address

       .rept 8
        MOVB (R0)+,(R4) ;
        ADD  R2,(R5)    ; advance the address register to the next line
       .endr

        INC  R1
       .equiv CurrentChar, .+2
        INC  #0
        CMP  @#CurrentChar,R2 ; end of screen line? (R2 == 40)
        BNE  NextChar         ; no, print another character
NewLine:
        CLR  @#CurrentChar
       .equiv CurrentLine, .+2
        INC  #0
        CMP  @#CurrentLine,#TextLinesCount ; next line out of screen?
        BNE  Recalculate   ; no, recalculate screen address
        CLR  @#CurrentLine ; yes, print from the beginning

Recalculate:
        MOV  @#CurrentLine,R1 ;
        MUL  #CharLineSize,R1 ; calculate relative line address
        ADD  @#CurrentChar,R1 ; calculate relative char dst address
        ADD  #FbStart,R1      ; calculate screen address of the next char
        MOV  R1,(R5)          ; load screen address of the next char to address register
        BR   NextChar

NextString:
        MOV  #StrBuffer,R3
       .equiv NextStringAddr, .+2
        MOV  #0,(R5)
        MOV  #PBP12D,R4
        MOV  (R4),R0
        MOVB R0,@#CurrentChar
        SWAB R0
        MOVB R0,@#CurrentLine
        INC  (R5)
        BR   LoadNext2Bytes

DonePrinting:
        RETURN

;----------------------------------------------------------------------------}}}

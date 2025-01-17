Print: ;---------------------------------------------------------------------{{{
       .equiv LineWidth, 40
       .equiv TextLinesCount, 25
       .equiv CharHeight, 8
       .equiv CharLineSize, LineWidth * CharHeight
       .equiv FbStart, FB >> 1
       .equiv BPDataReg, DTSOCT

        mov #10<<1,@#DTSCOL ; foreground color
        mov #LineWidth,r2
        mov #StrBuffer,r3
        mov #PBP12D,r4
        mov #PBPADR,r5
        mov #0b001,@#PBPMSK ; disable writes to bitplane 0

        clc
        ror r0
        mov r0,(r5)  ; load address of a string into address register

LoadNext2Bytes:
        mov  (r4),r0  ; load 2 bytes from CPU RAM
        mov  r0,(r3)+ ; store them into buffer
        tstb r0       ; test least significant byte
        bze  3#       ; end of text
        bmi  2#       ; end of string

        swab r0       ; swap bytes to test most significant one
        bze  3#       ; end of text
        bmi  2#       ; end of string

        inc  (r5)     ; next address
        br   LoadNext2Bytes

2$:     inc  (r5)
        mov  (r5),NextStringAddr

3$:     mov  CurrentLine,r1   ; prepare to calculate relative char address
        mul  #CharLineSize,r1 ; calculate relative address of the line
        add  CurrentChar,r1   ; calculate relative address of the char
        add  #FbStart,r1      ; calculate absolute address of the next char

        mov  #StrBuffer,r3
        mov  #BPDataReg,r4
NextChar:
        mov  r1,(r5)      ; load address of the next char into address register
        movb (r3)+,r0     ; load character code from string buffer
        tstb r0           ;
        bze  DonePrinting ; end of text
        bmi  NextString   ; end of string
        cmpb #'\n, r0     ; new line?
        beq  NewLine      ;

        ash  #3,r0        ; shift left by 3(multiply by 8)
        add  #Font,r0     ; calculate char bitmap address

       .rept 8
        movb (r0)+,(r4) ;
        add  r2,(r5)    ; advance the address register to the next line
       .endr

        inc  r1
       .equiv CurrentChar, .+2
        inc  #0
        cmp  CurrentChar,r2 ; end of screen line? (r2 == 40)
        bne  NextChar       ; no, print another character
NewLine:
        clr  CurrentChar
       .equiv CurrentLine, .+2
        inc  #0
        cmp  CurrentLine,#TextLinesCount ; next line out of screen?
        bne  Recalculate   ; no, recalculate screen address
        clr  CurrentLine   ; yes, print from the beginning

Recalculate:
        mov  CurrentLine,r1 ;
        mul  #CharLineSize,r1 ; calculate relative line address
        add  CurrentChar,r1   ; calculate relative char dst address
        add  #FbStart,r1      ; calculate screen address of the next char
        mov  r1,(r5)          ; load screen address of the next char to address register
        br   NextChar

NextString:
        mov #StrBuffer,r3
       .equiv NextStringAddr, .+2
        mov #0,(r5)
        mov #PBP12D,r4
        mov (r4),r0
        movb r0,CurrentChar
        swab r0
        movb r0,CurrentLine
        inc (r5)
        br LoadNext2Bytes

DonePrinting:
        return

;----------------------------------------------------------------------------}}}

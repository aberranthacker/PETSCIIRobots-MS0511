Puts: ;---------------------------------------------------------------------{{{
       .equiv LineWidth, 40
       .equiv TextLinesCount, 25
       .equiv CharHeight, 8
       .equiv CharLineSize, LineWidth * CharHeight
       .equiv FbStart, FB0 >> 1
       .equiv BPDataReg, DTSOCT

        mov #10<<1,@#DTSCOL ; foreground color
        mov #0b001,@#PBPMSK ; disable writes to bitplane 0
        mov #LineWidth, r2
        mov #WakingUpStr, r3
        mov #BPDataReg, r4
        mov #PBPADR, r5
        mov #FbStart + 9 + 94*LineWidth, (r5)
NextChar:
        movb (r3)+, r1   ; load character code from string buffer
        tstb r1          ;
        bze DonePrinting ; end of string

        mul #11, r1
        add #ROM_FONT, r1 ; calculate char bitmap address

       .rept 11
        ; mov #11,r0
        ; 10$:
            movb (r1)+, (r4)  ;
            add r2, (r5)      ; advance the address register to the next line
        ; sob r0,10$
       .endr

        sub #40*11 - 1, (r5)
        br NextChar

DonePrinting:
        return

;----------------------------------------------------------------------------}}}

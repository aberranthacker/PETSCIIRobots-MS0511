Puts: ;---------------------------------------------------------------------{{{
        mov #6, @#DTSCOL ; foreground color
        mov #40, r2
        mov #WAKING_UP_STR, r3
        mov #DTSOCT, r4
        mov #PBPADR, r5
        mov #FB/2 + 9 + 94*40, (r5)
NextChar:
        movb (r3)+, r1   ; load character code from string buffer
        tstb r1          ;
        bze DonePrinting ; end of string

        mul #11, r1
        add #ROM_FONT, r1 ; calculate char bitmap address

       .rept 11
            movb (r1)+, (r4)  ;
            add r2, (r5)      ; advance the address register to the next line
       .endr

        sub #40*11 - 1, (r5)
        br NextChar

DonePrinting:
        return
;----------------------------------------------------------------------------}}}

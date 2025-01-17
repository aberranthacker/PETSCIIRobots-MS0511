trap4Handler:
    mov #0x3420, TRAP_STR+4
    br handleTrap
trap10Handler:
    mov #0x3031, TRAP_STR+4
    br handleTrap
trap24Handler:
    mov #0x3432, TRAP_STR+4
    br handleTrap

    handleTrap:
        push @#PBPADR, r5, r4, r3, r2, r1, r0
            mov 14(sp), r3
            call toOctalString

            mov #TRAP_STR, r0
            call printDiagnostic
        pop r0, r1, r2, r3, r4, r5, @#PBPADR
    br .
rti

printDiagnostic: ;------------------------------------------------------------{{{
    mov #2, @#DTSCOL ; foreground color
    mov #40, r2
    mov #DTSOCT, r4
    mov #PBPADR, r5
    mov #AUX_SCREEN_ADDR, (r5)

    pd.chars_loop:
        movb (r0)+, r1   ; load character code from string buffer
        tstb r1          ;
        bze pd.exit ; end of string

        mul #11, r1
        add #ROM_FONT, r1 ; calculate char bitmap address

       .rept 11
            movb (r1)+, (r4)  ;
            add r2, (r5)      ; advance the address register to the next line
       .endr

        sub #40*11 - 1, (r5)
    br pd.chars_loop

pd.exit:
return

; in: r3 = value to convert
toOctalString:
    mov #PRINTABLE_NUMBER+7, r0
    mov #7, r1

    10$:
        clr r2      ; R2 - most, R3 - least significant word
        div #8, r2  ; quotient -> R2 , remainder -> R3
        add #'0, r3 ; add ASCII code for "0" to the remainder
        movb r3, -(r0)
        mov r2, r3
    sob r1, 10$
return

TRAP_STR:      .ascii "TRAPxx at: "
PRINTABLE_NUMBER: .asciz "0177777"

        .even
;----------------------------------------------------------------------------}}}

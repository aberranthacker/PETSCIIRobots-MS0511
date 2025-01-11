keyboardIntHadler: ;------------------------------------------------------------
    push r0, r1, r2, @#PBPADR
        mov  #PPU_KeyboardScanner, @#PBPADR
        movb @#KBDATA, r0
        bmi handle_keyrelease

      ; handle keypress
        mov #1, r2
        mov #KeyPressesScancodes, r1

        10$:
            cmpb r0, (r1)+
            beq set_bit

            asl r2
        bnz 10$

        set_bit:
            bis r2, @#PBP12D

    pop @#PBPADR, r2, r1, r0
    rti
    ;--------------------------------
    handle_keyrelease:
        mov #1, r2
        clr BITS_TO_RESET
        mov #KeyReleasesScancodes, r1

        10$:
            cmpb r0, (r1)+
            bne 20$
                bis r2, BITS_TO_RESET
            20$:
            asl r2
        bnz 10$

       .equiv BITS_TO_RESET, .+2
        bic #0, @#PBP12D

    pop @#PBPADR, r2, r1, r0
    rti
;-------------------------------------------------------------------------------
KeyPressesScancodes:
     0$: .byte UP_PRESSED
     1$: .byte DOWN_PRESSED
     2$: .byte LEFT_PRESSED
     3$: .byte RIGHT_PRESSED
     4$: .byte RETURN_PRESSED
     5$: .byte KEYPAD_RETURN_PRESSED
     6$: .byte W_PRESSED
     7$: .byte S_PRESSED
     8$: .byte A_PRESSED
     9$: .byte D_PRESSED
    10$: .byte Q_PRESSED
    11$: .byte E_PRESSED
    12$: .byte 0
    13$: .byte 0
    14$: .byte 0
    15$: .byte 0

KeyReleasesScancodes:
     0$: .byte UP_RELEASED
     1$: .byte DOWN_RELEASED
     2$: .byte LEFT_RELEASED
     3$: .byte RIGHT_RELEASED
     4$: .byte RETURN_RELEASED
     5$: .byte KEYPAD_RETURN_RELEASED
     6$: .byte W_RELEASED
     7$: .byte S_RELEASED
     8$: .byte A_RELEASED
     9$: .byte D_RELEASED
    10$: .byte Q_RELEASED
    11$: .byte E_RELEASED
    12$: .byte 0
    13$: .byte 0
    14$: .byte 0
    15$: .byte 0

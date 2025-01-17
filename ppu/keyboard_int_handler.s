keyboardIntHadler: ;------------------------------------------------------------
    push r0, r1, r2, @#PBPADR
        mov  #PPU_KeyboardScanner, @#PBPADR
        movb @#KBDATA, r0
        bmi handle_keyrelease

      ; handle keypress
        mov #1, r2
        mov #KEY_PRESSES_SCANCODES, r1

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
    ; The keypress scancode is 7 bits long.
    ; The keyrelease scancode consists of the 4 lower bits of the corresponding keypress scancode.
    ; This means that a keyrelease scancode can potentially match multiple pressed keys.
    ; To handle this, we check all keyrelease scancodes to ensure accurate matching.
    handle_keyrelease:
        mov #1, r2
        clr BITS_TO_CLEAR
        mov #KEY_RELEASES_SCANCODES, r1

        10$:
            cmpb r0, (r1)+
            bne 20$
                bis r2, BITS_TO_CLEAR
            20$:
            asl r2
        bnz 10$

       .equiv BITS_TO_CLEAR, .+2
        bic #0, @#PBP12D

    pop @#PBPADR, r2, r1, r0
    rti
;-------------------------------------------------------------------------------
KEY_PRESSES_SCANCODES:
     0$: .byte UP_PRESSED
     1$: .byte DOWN_PRESSED
     2$: .byte LEFT_PRESSED
     3$: .byte RIGHT_PRESSED
     4$: .byte RETURN_PRESSED
     5$: .byte KEYPAD_RETURN_PRESSED
     6$: .byte C_PRESSED
     7$: .byte Y_PRESSED
     8$: .byte F_PRESSED
     9$: .byte W_PRESSED
    10$: .byte J_PRESSED
    11$: .byte U_PRESSED
    12$: .byte 0
    13$: .byte 0
    14$: .byte 0
    15$: .byte 0

KEY_RELEASES_SCANCODES:
     0$: .byte UP_RELEASED
     1$: .byte DOWN_RELEASED
     2$: .byte LEFT_RELEASED
     3$: .byte RIGHT_RELEASED
     4$: .byte RETURN_RELEASED
     5$: .byte KEYPAD_RETURN_RELEASED
     6$: .byte C_RELEASED ; fire up
     7$: .byte Y_RELEASED ; fire down
     8$: .byte F_RELEASED ; fire left
     9$: .byte W_RELEASED ; fire right
    10$: .byte J_RELEASED ; cycle weapons
    11$: .byte U_RELEASED ; cycle items
    12$: .byte 0 ; search
    13$: .byte 0 ; use
    14$: .byte 0 ; exit
    15$: .byte 0

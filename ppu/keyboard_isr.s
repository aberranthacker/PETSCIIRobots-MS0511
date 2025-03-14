keyboardIntHadler: ;------------------------------------------------------------
    push r0, r1, r2, @#PBPADR
        mov  #KEYBOARD_SCANNER / 2, @#PBPADR
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
     0$: .byte UP_PRESSED    ; walk up
     1$: .byte DOWN_PRESSED  ; walk down
     2$: .byte LEFT_PRESSED  ; walk left
     3$: .byte RIGHT_PRESSED ; walk right
     4$: .byte C_PRESSED     ; fire up
     5$: .byte Y_PRESSED     ; fire down
     6$: .byte F_PRESSED     ; fire left
     7$: .byte W_PRESSED     ; fire right
     8$: .byte A_PRESSED     ; search
     9$: .byte J_PRESSED
    10$: .byte U_PRESSED
    11$: .byte 0
    12$: .byte 0
    13$: .byte 0
    14$: .byte 0
    15$: .byte RETURN_PRESSED

KEY_RELEASES_SCANCODES:
     0$: .byte UP_RELEASED
     1$: .byte DOWN_RELEASED
     2$: .byte LEFT_RELEASED
     3$: .byte RIGHT_RELEASED
     4$: .byte C_RELEASED
     5$: .byte Y_RELEASED
     6$: .byte F_RELEASED
     7$: .byte W_RELEASED
     8$: .byte A_RELEASED
     9$: .byte J_RELEASED ; cycle weapons
    10$: .byte U_RELEASED ; cycle items
    11$: .byte 0 ; search
    12$: .byte 0 ; use
    13$: .byte 0 ; exit
    14$: .byte 0
    15$: .byte RETURN_RELEASED

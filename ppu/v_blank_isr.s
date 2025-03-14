vblankIntHandler: ;-------------------------------------------------------------
    push @#PBPADR, r5, r4, r3, r2, r1, r0

    .ifdef DEBUG
       ;CALL @#PrintDebugInfo
    .endif

        mtps #PR7
       .equiv MusicPlayerAddr, .+2
        call @#subroutineStub
        mtps #PR0

       .equiv cursor_counter, .+2
        inc #-1

jmp vih.finalize

        mov cursor_counter, r1
        bit #1, r1
        _jmp nz, vih.skip
            .equiv MAIN_SCREEN_FIRST_REC, .+2
            mov #0, r0
            sub #6, r0
            add #8*72, r0 ; next record addr

            cmp r1, #4
            blos vih.left_right_shift
                cmp r1, #8
                blos vih.ud_shift_prep
                    cmp r1, #12
                    blos vih.rl_shift_prep
                        cmp r1, #16
                        blos vih.du_shift_prep
                            mov #-1, cursor_counter
                            sub #16, r1
                            br vih.left_right_shift
                vih.ud_shift_prep:
                    cmp r1, #8
                    bne 10$
                        add #8*9, r0
                    10$:
                    bicb #CURSOR_TOGGLE, (r0)
                    bis #COLOR_REGS_SEL, (r0)+
                    mov  8(r0), (r0)+
                    mov 10(r0), (r0)
                    add #8*8+4, r0
                    ; bicb #CURSOR_TOGGLE, (r0) ; turn off the cursor
                    sub #8, r0
                    br vih.ud_shift
                vih.rl_shift_prep:
                    add #8*16, r0
                    br vih.rl_shift
                vih.du_shift_prep:
                    cmp r1, #12
                    bne 10$
                        add #8*8, r0
                    10$:
                        add #8*8, r0
                        bis #COLOR_REGS_SEL, (r0)+
                        mov  8(r0), (r0)+
                        mov 10(r0), (r0)
                        sub #8*8, r0
                        br vih.du_shift
        vih.left_right_shift:
            bisb #CURSOR_TOGGLE, (r0)  ; turn on the cursor
            bic #COLOR_REGS_SEL, (r0)+

            add #30, r1
            swab r1
            bis #TEXT_CURSOR | GRAY, r1
            mov r1, (r0)+
            mov #HRES_320 | RGB, (r0)

            add #8*8+4, r0
            bisb #CURSOR_TOGGLE, (r0) ; turn off the cursor
            br vih.skip
        vih.ud_shift:
          ; бит выключения предыдущего курсора, становится битом включения
            bic #COLOR_REGS_SEL, (r0)+

            mov #34, r1
            swab r1
            bis #TEXT_CURSOR | GRAY, r1
            mov r1, (r0)+
            mov #HRES_320 | RGB, (r0)

            add #8*8+4, r0
            bisb #CURSOR_TOGGLE, (r0) ; turn off the cursor
            br vih.skip
        vih.rl_shift:
            sub #10, r1
            neg r1
            add #32, r1
            movb r1, 1(r0)
            br vih.skip
        vih.du_shift:
        vih.skip:
        nop
        nop

    vih.finalize:
        pop r0, r1, r2, r3, r4, r5, @#PBPADR

    vblankIntHandler.minimal:
      ; small piece of firware code to stop floppy disk drive
        tst @#07130 ; is floppy disk drive timer active?
        bze 1271$   ; no, do nothing
        dec @#07130 ; decrease timer counter
        bnz 1271$   ; do nothing, unless the counter reached 0
        call @07132 ; stop floppy disk drive

1271$:  rti
;-------------------------------------------------------------------------------
WORD1: .ds 1
WORD2: .ds 1

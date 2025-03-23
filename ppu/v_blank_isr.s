vBlankISR: ;-------------------------------------------------------------
    push @#PBPADR, r5, r4, r3, r2, r1, r0

    .ifdef DEBUG
       ;CALL @#PrintDebugInfo
    .endif
        call ppu_timer_isr
        jmp  vih.skip

       .equiv cursor_counter, .+2
        inc #-1

        mov cursor_counter, r1
        bit #1, r1
        _jmp nz, vih.skip
            ; SLTAB_REC:
            ;     .CTRL_DATA0
            ;     .CTRL_DATA1
            ;     .LINE_ADDR
            ;     .NEXT_REC ; bit 0 switches cursor state
           .equiv MAIN_SCREEN_FIRST_REC, .+2
            mov #0, r0
            add #72*8 - 2, r0 ; next record addr
          ; 1 2 3
          ; 8   4
          ; 7 6 5
          ; reset
          ; new coordinate?
            phase_reset_lut:
            phase_set_lut:

            cmp r1, #4
            blos .left_right_shift
                cmp r1, #8
                blos vih.ud_shift_prep
                    cmp r1, #12
                    blos vih.rl_shift_prep
                        cmp r1, #14
                        blos vih.du_shift
                            add #8*8, r0
                            bicb #CURSOR_TOGGLE, (r0)
                            bis #COLOR_REGS_SEL, (r0)+
                            mov 8(r0), (r0)+          ; restore colors
                            mov 8(r0), (r0)+
                            add #8*8+2, r0
                            bicb #CURSOR_TOGGLE, (r0)
                            sub #17*8, r0

                            clr cursor_counter
                            clr r1
                            br .left_right_shift
                vih.ud_shift_prep:
                    cmp r1, #8
                    bne 10$
                        add #8*8, r0
                    10$:
                    bicb #CURSOR_TOGGLE, (r0)  ; turn off the cursor
                    bis #COLOR_REGS_SEL, (r0)+ ; colors regs sel
                    mov 8(r0), (r0)+          ; restore colors
                    mov 8(r0), (r0)+
                    add #8*8+2, r0
                    bicb #CURSOR_TOGGLE, (r0) ; turn off the cursor
                    sub #8, r0
                    br vih.ud_shift
                vih.rl_shift_prep:
                    add #16*8+2, r0
                    br vih.rl_shift
            .left_right_shift: ; 0, 2, 4
              ; r0 points to NEXT_REC
                bisb #CURSOR_TOGGLE, (r0)  ; turn on the cursor
                bic #COLOR_REGS_SEL, (r0)+ ; cursor/palette/scale regs sel
              ; r0 points to CTRL_DATA0
                add #30, r1 ; calculate horizontal pos (r1 = 0, 2, and 4)
                swab r1     ; bits 8-14 define cursor pos
                bis #TEXT_CURSOR | GRAY, r1
                mov r1, (r0)+
              ; r0 points to CTRL_DATA1
                mov #HRES_320 | RGB, (r0)+
              ; r0 points to LINE_ADDR
                add #8*8+2, r0
              ; r0 points to NEXT_REC of the last line of the cursor
                bisb #CURSOR_TOGGLE, (r0) ; turn off the cursor
                br vih.skip
            vih.ud_shift: ; 6, 8
                bisb #CURSOR_TOGGLE, (r0)  ; turn on the cursor
                bic #COLOR_REGS_SEL, (r0)+ ; cursor/palette/scale regs sel

                mov #34, r1
                swab r1
                bis #TEXT_CURSOR | GRAY, r1
                mov r1, (r0)+
                mov #HRES_320 | RGB, (r0)+

                add #8*8+2, r0
                bisb #CURSOR_TOGGLE, (r0) ; turn off the cursor
                br vih.skip
            vih.rl_shift: ; 10, 12
                sub #10, r1
                neg r1
                add #32, r1
                movb r1, 1(r0)
                br vih.skip
            vih.du_shift: ; 14
                add #16*8, r0
                bicb #CURSOR_TOGGLE, (r0)
                bis #COLOR_REGS_SEL, (r0)+
                mov 8(r0), (r0)+          ; restore colors
                mov 8(r0), (r0)+
                add #8*8+2, r0
                bicb #CURSOR_TOGGLE, (r0) ; turn off the cursor

                sub #17*8, r0
                bisb #CURSOR_TOGGLE, (r0)  ; turn on the cursor
                bic #COLOR_REGS_SEL, (r0)+ ; cursor/palette/scale regs sel

                mov #30, r1
                swab r1
                bis #TEXT_CURSOR | GRAY, r1
                mov r1, (r0)+
                mov #HRES_320 | RGB, (r0)+

                add #8*8+2, r0
                bisb #CURSOR_TOGGLE, (r0) ; turn off the cursor
            vih.skip:
            nop
            nop

    vih.finalize:
        pop r0, r1, r2, r3, r4, r5, @#PBPADR

    vBlankISR.minimal:
      ; small piece of firware code to stop floppy disk drive
        tst @#07130 ; is floppy disk drive timer active?
        bze 1271$   ; no, do nothing
        dec @#07130 ; decrease timer counter
        bnz 1271$   ; do nothing, unless the counter reached 0
        call @07132 ; stop floppy disk drive

1271$:  rti
;-------------------------------------------------------------------------------

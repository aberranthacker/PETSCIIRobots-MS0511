ssy_opl2_init:
ssy_opl2_shut:                            ; void ssy_opl2_shut(){ ---------{{{
    mov #0x01,r4                           ;
    mov #0x20,r5
    call ssy_opl2_write                   ;     ssy_opl2_write(0x01, 0x20);

    clr r5
    mov #2,r4                              ;     for (i = 2; i < 0x20; i++){
    10$:
        call ssy_opl2_write               ;         ssy_opl2_write(i, 0);
        inc r4
    cmp r4,#0x20
    blo 10$                                ;     }
  ; r4 = 0x20
    mov #255,r5
    20$:                                   ;     for (i = 0x20; i < 0xA0; i++){
        call ssy_opl2_write               ;         ssy_opl2_write(i, 255);
        inc r4
    cmp r4,#0xA0
    blo 20$                                ;     }
  ; r4 = 0xA0
    clr r5
    30$:                                   ;     for (i = 0xA0; i < 0xF6; i++){
        call ssy_opl2_write               ;         ssy_opl2_write(i, 0);
        inc r4
    cmp r4,#0xF6
    blo 30$                                ;     }

    mov #0xE0,r5
    clr r1
    40$:                                   ;     for (i = 0; i < 9; i++){
      ; Quick attack, longest decay
        movb SSY_OPL2_OPERATOR_ORDER(r1), r2
        mov r2,r4
        add #0x60,r4
        call ssy_opl2_write               ;         ssy_opl2_write(0x60 + SSY_OPL2_OPERATOR_ORDER[i], 0xE0);
      ; The same for operator 1 and 2
        mov  r2, r4
        add #0x63,r4
        call ssy_opl2_write               ;         ssy_opl2_write(0x63 + SSY_OPL2_OPERATOR_ORDER[i], 0xE0);
      ; Max sustain, quick release
        mov  r2,r4
        add #0x80,r4
        call ssy_opl2_write               ;         ssy_opl2_write(0x80 + SSY_OPL2_OPERATOR_ORDER[i], 0x0E);
      ; These setting remain unchanged
        mov  r2,r4
        add #0x83,r4
        call ssy_opl2_write               ;         ssy_opl2_write(0x83 + SSY_OPL2_OPERATOR_ORDER[i], 0x0E);

        inc r1
        cmp r1, #CH_MAX
    blo 40$                                ;     }
return ; ssy_opl2_shut                    ; } ------------------------------}}}


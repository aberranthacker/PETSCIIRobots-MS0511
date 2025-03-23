.equiv CH_MAX, 9

ppu_timer_isr:
    mov #PADDR_REG, r5
    mov #PBP12_DATA_REG, r4

    mov #OPL2_PROCS_TO_EXECUTE / 2, (r5)
    mov (r4), r0
    bze check_if_sound_enabled
        clr (r4)

        asr r0
        bcc .+6
            call ssy_init
        asr r0
        bcc .+6
            call ssy_sound_play
        asr r0
        bcc .+6
            call ssy_music_stop
        asr r0
        bcc .+6
            call ssy_music_play

    check_if_sound_enabled:
       .equiv SOUND_ENABLED, .+2 ; ssy_init sets this flag
        tst #0
        bze 1237$

        mov #CPU_OPL2_VARS_TO_COPY, (r5)
        mov #OPL2_VARS_TO_COPY_SIZEDW, r1 ; 128 bytes; 64 words; 32 dwords
        mov #OPL2_VARS_TO_COPY, r3
        10$:
            mov (r4), (r3)+
            inc (r5)
            mov (r4), (r3)+
            inc (r5)
        sob r1, 10$

        mov #1, @#PCH1_OUT_DATA ; trigger CPUs ssy_timer_isr

        call ssy_opl2_update
1237$: return

ssy_init:
    mov #OPL2_CHANNELS_PREV_VARS_SIZEW, r1
    mov #OPL2_CHANNELS_PREV_VARS, r2
    10$:
        clr (r2)+
    sob r1, 10$
    call ssy_opl2_init

    mov #TRUE, SOUND_ENABLED
return

.include "audio/ssy_opl2_init.s"

ssy_sound_play:
    movb #0xFF, VOLPREV
    mov #0xFFFF, PITCH_PREV
return

ssy_music_stop:
    mov #1, R1 ; first music channel
    mov #8, R2 ; number of music channels
    mov #0xFF, R5
  ; Set all music channels volume to 0 to mute the music without stopping sound effects
    10$:
        movb #0x55, VOLPREV(R1)
      ; Added to actually turn off the volume
        mov SSY_OPL2_OPERATOR_ORDER(R1), R4
        add #0x43, R4
        call ssy_opl2_write
        inc R1
    sob R2, 10$

    mov #10, R1
    mov #8*10, R2 ; number of instrument regs for all 8 channels
    clr R5
    20$:
        mov SSY_OPL2_INSTRUMENT_REGS(R1), R4
        call ssy_opl2_write
        inc R1
    sob R2, 20$
return

ssy_music_play:
    mov #1, r1    ; current channel (music channels start from 1)
    mov #INSTRUMENT_REGS_PER_CHANNEL, r3 ; current channel 10th of bytes offset
                                         ; (offset within OPL_REGS and OPL_PREV)
    10$:
        mov r1, r0
        asl r0
        clr PITCH_PREV(r0)
        movb #0xFF, VOLPREV(r1) ; force volume update
        clr r4
        20$:
            mov r3, r0
            add r4, r0
            clrb OPL_PREV(r0)
        inc r4
        cmp r4, #INSTRUMENT_REGS_PER_CHANNEL
        blo 20$
    add #INSTRUMENT_REGS_PER_CHANNEL, r3
    inc r1
    cmp r1, #CH_MAX
    blo 10$
return

ssy_opl2_update: ;-----------------------------------------------------------{{{
   .equiv OPL2_REGC, .+2
    mov #STUB_REGISTER, r5

  ; Check which channels and how many channels needs to be updated depending
  ; on the assigned devices
    clr r1 ; byte index ; channel = 0
    clr r2 ; word index                                   ; channel_max = CH_MAX;
    clr r3 ; tens of bytes index
    ssy_opl2_update_next_channel:                         ; for (; channel < channel_max; channel++){
        tstb KEYOFF(r1)                                   ;    if (KEYOFF[channel] != 0){
        bze update_volume_if_it_has_changed
            clrb KEYOFF(r1)                               ;        KEYOFF[channel] = 0;
            mov #0xB0, r4
            add r1, r4                                    ;        ssy_opl2_write(0xB0 + channel, 0);

           .ifdef INPLACE_OPL2_WRITE
                movb r4, (r5)
                nop ; скорее всего лишняя задержка
                clr (r5)
           .else
                clr r5
                call ssy_opl2_write
           .endif

        update_volume_if_it_has_changed:
            cmpb VOLOPL(r1), VOLPREV(r1)                  ;    if (VOLOPL[channel] != VOLPREV[channel]){
            beq 10$
                movb VOLOPL(r1), VOLPREV(r1)              ;        VOLPREV[channel] = VOLOPL[channel];
                movb SSY_OPL2_OPERATOR_ORDER(r1), r4      ;        ssy_opl2_write(0x43 + SSY_OPL2_OPERATOR_ORDER[channel], VOLOPL[channel]);
                add #0x43, r4

               .ifdef INPLACE_OPL2_WRITE
                    movb r4, (r5)       ; select register
                    movb VOLOPL(r1), r4
                    mov r4, (r5)        ; write
               .else
                    movb VOLOPL(r1), r5
                    call ssy_opl2_write
               .endif
            10$:
        ; Loop through registers and only update them if they have changed
            clr r0
            loop_through_registers:                       ;    for (i = 0; i < 10; i++){
               .ifdef INPLACE_OPL2_WRITE
                    mov r0, r4
                    add r3, r4
                    cmpb OPL_REGS(r4), OPL_PREV(r4)
                    beq 20$
                        movb OPL_REGS(r4), OPL_PREV(r4)
                        movb SSY_OPL2_INSTRUMENT_REGS(r4), (r5) ; select register
                        movb OPL_REGS(r4), r4
                        mov r4, (r5)                            ; write
               .else
                    mov r0, r5
                    add r3, r5
                    cmpb OPL_REGS(r5), OPL_PREV(r5)           ;        if (OPL_REGS[channel][i] != OPL_PREV[channel][i]){
                    beq 20$
                        movb OPL_REGS(r5), OPL_PREV(r5)       ;            OPL_PREV[channel][i] = OPL_REGS[channel][i];
                        movb SSY_OPL2_INSTRUMENT_REGS(r5), r4 ;            ssy_opl2_write(SSY_OPL2_INSTRUMENT_REGS[channel][i], OPL_REGS[channel][i]);
                        movb OPL_REGS(r5), r5
                        call ssy_opl2_write
               .endif
                20$:
            inc r0
            cmp r0, #INSTRUMENT_REGS_PER_CHANNEL
            blo loop_through_registers

        ; Send pitch if it has changed
            cmp PITCH(r2), PITCH_PREV(r2)                  ;    if (PITCH[channel] != PITCH_PREV[channel]){
            beq 30$
                mov PITCH(r2), PITCH_PREV(r2)              ;        PITCH_PREV[channel] = PITCH[channel];
              ; Set pitch lsb
                mov #0xA0, r4                              ;        ssy_opl2_write(0xA0 + channel, PITCH[channel]);
                add r1, r4

               .ifdef INPLACE_OPL2_WRITE
                    movb r4, (r5)       ; select register
                    mov PITCH(r2), (r5) ; write
               .else
                    mov PITCH(r2), r5
                    call ssy_opl2_write
               .endif

              ; Set pitch msb and key on, pitch change always does key on
                mov #0xB0, r4                              ;        ssy_opl2_write(0xB0 + channel, PITCH[channel] >> 8);
                add r1, r4
                swab PITCH(r2)

               .ifdef INPLACE_OPL2_WRITE
                    movb r4, (r5)        ; select register
                    mov PITCH(r2), (r5)  ; write
                    swab PITCH(r2)
               .else
                    swab r5
                    call ssy_opl2_write
               .endif

            30$:
        add #INSTRUMENT_REGS_PER_CHANNEL, r3
        inc r2
        inc r2
        inc r1
        cmp r1, #CH_MAX
    blo ssy_opl2_update_next_channel

return ;---------------------------------------------------------------------}}}

ssy_opl2_write: ;-----------------------------------------------------------{{{
  ; After writing to the register port, you must wait 12 cycles
  ; (3.4 μs at 3.58 MHz) before sending the data.
  ; After writing the data, 84 cycles (23.5 μs at 3.58MHz) must elapse before
  ; any other sound card operation may be performed.
  ; `nop` takes at least 16 external cycles (2.56 μs)
  ;
  ; r4 = regnum, r5 = regval
  ;:bpt
   .equiv OPL2_REGA, .+2
    movb r4, @#STUB_REGISTER
    nop
   .equiv OPL2_REGB, .+2
    mov r5, @#STUB_REGISTER
   .rept 5
       nop
   .endr
return ;----------------------------------------------------------------------}}}

.include "audio/vars.s"
nop
nop

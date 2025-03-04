
ssy_init:
  ; Clear some vars
    mov #1, SOUND_ENABLED
    mov #1, SSY_CHANNELS
  ; Clear data and force OPL registers update
    mov #music_channels_vars_sizew, r0
    mov #music_channels_vars, r1
    10$:
        clr (r1)+
    sob r0, 10$

    call ssy_adlib_init
return ; ssy_init

ssy_adlib_init:
ssy_adlib_shut:                            ; void ssy_adlib_shut(){
    mov #0x01,r4                           ;
    mov #0x20,r5
    call ssy_adlib_write                   ;     ssy_adlib_write(0x01, 0x20);

    clr r5
    mov #2,r4                              ;     for (i = 2; i < 0x20; i++){
    10$:
        call ssy_adlib_write               ;         ssy_adlib_write(i, 0);
        inc r4
    cmp r4,#0x20
    blo 10$                                ;     }
  ; r4 = 0x20
    mov #255,r5
    20$:                                   ;     for (i = 0x20; i < 0xA0; i++){
        call ssy_adlib_write               ;         ssy_adlib_write(i, 255);
        inc r4
    cmp r4,#0xA0
    blo 20$                                ;     }
  ; r4 = 0xA0
    clr r5
    30$:                                   ;     for (i = 0xA0; i < 0xF6; i++){
        call ssy_adlib_write               ;         ssy_adlib_write(i, 0);
        inc r4
    cmp r4,#0xF6
    blo 30$                                ;     }

    mov #0xE0,r5
    clr r0
    40$:                                   ;     for (i = 0; i < 9; i++){
      ; Quick attack, longest decay
        movb SSY_OPL2_OPERATOR_ORDER(r0), r1
        mov r1,r4
        add #0x60,r4
        call ssy_adlib_write               ;         ssy_adlib_write(0x60 + SSY_OPL2_OPERATOR_ORDER[i], 0xE0);
      ; The same for operator 1 and 2
        mov  r1, r4
        add #0x63,r4
        call ssy_adlib_write               ;         ssy_adlib_write(0x63 + SSY_OPL2_OPERATOR_ORDER[i], 0xE0);
      ; Max sustain, quick release
        mov  r1,r4
        add #0x80,r4
        call ssy_adlib_write               ;         ssy_adlib_write(0x80 + SSY_OPL2_OPERATOR_ORDER[i], 0x0E);
      ; These setting remain unchanged
        mov  r1,r4
        add #0x83,r4
        call ssy_adlib_write               ;         ssy_adlib_write(0x83 + SSY_OPL2_OPERATOR_ORDER[i], 0x0E);

        inc r0
        cmp r0,#9
    blo 40$                                ;     }
return ; ssy_adlib_shut                    ; }

ssy_music_stop:
return

; in: r0 - sfx number
ssy_sound_play:
    bic #0xFFE0, r0 ; just in case I guess
    tst SOUND_TIMER ; Check if sound finished playing
    bze 10$
      ; The current playing sound's priority level.
      ; This resets to 0 when the sound is finished playing.
       .equiv SOUND_PRIORITY, .+2
        cmpb #0, SOUND_PLAY_PRIORITY(r0)
        blo 10$
            return
    10$:

    movb SOUND_PLAY_TIMER(r0), SOUND_TIMER
    movb SOUND_PLAY_PRIORITY(r0), SOUND_PRIORITY
    clrb WAIT
    clrb VOLOPL
    movb #0xFF, VOLPREV
    mov #0xFFFF, PITCH_1
    clr PITCH_2
    movb #0xFF, KEYOFF

    asl r0
    mov SOUNDFX+2(r0), r0
    add #SOUNDFX, r0
    mov r0, PTR
return

ssy_music_play:
    call ssy_music_stop
    tst #MUSIC ; check if music is loaded
    bze 1237$

  ; Clear all music channel vars
    mov #1, r1    ; current channel byte offset (music channels start from 1)
    mov #2, r2    ; current channel word offset
    mov #INSTRUMENT_REGS_PER_CHANNEL, r3 ; current channel 10th of bytes offset
                                         ; (offset within OPL_REGS and OPL_PREV)
    10$:
        clr RET(r2)
        clr PTR(r2)
        clr LOOP(r2)
        clr REFPREV(r2)

        clr PITCH_1(r2)
        clr PITCH_2(r2)

        clrb WAIT(r1)
        clrb VOLPREV(r1)
        clrb KEYOFF(r1)
        clrb VOLOPL(r1)
        clr r4
        20$:
            mov r3, r0
            add r4, r0
            clrb OPL_REGS(r0)
            clrb OPL_PREV(r0)
        inc r4
        cmp r4, #INSTRUMENT_REGS_PER_CHANNEL
        blo 20$

    add #INSTRUMENT_REGS_PER_CHANNEL, r3
    inc r2
    inc r2
    inc r1
    cmp r1, #CH_MAX
    blo 10$

    mov #MUSIC, r5
    mov r5, SSY_MUSIC

  ; Read number of channels from music data
    movb 1(r5), r0
    inc r0                 ; add SFX channel to channels count
    mov r0, SSY_CHANNELS  ; store channels count

  ; Set up music channels
    dec r0                 ; subtract SFX channel from channels count
    mov #1, r1             ; channel, byte offset, skip SFX channel 0
    mov #2, r2             ; channel, word offset, skip SFX channel 0
    30$:
        mov r2, r3
        add r5, r3
        mov (r3),r3        ; read channel offset
        add r5, r3         ; calculate channel pointer
        mov r3, PTR(r2)
        mov r3, LOOP(r2)
        movb #0xFF, VOLPREV(r1) ; force volume update
        inc r1
        inc r2
        inc r2
    sob r0, 30$

1237$:  return

;-------------------------------------------------------------------------------
; sound system update
; call it from timer ISR, at 72.8 HZ rate (8253 divider 16384, 1193180/16384=72.8)
ssy_timer_isr:
       .equiv SOUND_ENABLED, .+2
        tstb #0
        bnz process_channels
        return

    process_channels:
        clr r1 ; channel, byte offset
        clr r2 ; channel, word offset
        clr r3 ; channel, instrument registers offset

    process_channel:
        tstb WAIT(r1)
        bze no_wait

        decb WAIT(r1)
        bze no_wait

        jmp next_channel

    no_wait:
      ; Update channel if channel data pointer is not zero
        tst PTR(r2)
        bnz update_channel_loop
        jmp next_channel

    update_channel_loop:
        clr r0
        bisb @PTR(r2), r0                  ; data = *(PTR[channel]);
      ; Advance channel data pointer
        inc PTR(r2)                        ; PTR[channel]++;

        ; Check if the data is a wait value
            cmpb r0, #0xC0                     ; if (data < 0xC0)
            bhis check_if_data_is_volume_value
              ; Set channel wait value
                movb r0, WAIT(r1)              ;     WAIT[channel] = data;
                jmp next_channel               ;     break

        check_if_data_is_volume_value:
            cmpb r0, #0xD0                     ; else if (data < 0xD0)
            bhis check_if_data_pitch_1_lsb
              ; Set channel volume             ;     VOLUME[channel] = (data & 0x0F);
                br update_channel_loop

        check_if_data_pitch_1_lsb:
            cmpb r0, #0xD0                     ; else if (data = 0xD0)
            bne check_if_data_pitch_1_msb
              ; Set Pitch 1 LSB
                                               ;     PITCH_1[channel] &= 0xFF00;
                movb @PTR(r2), PITCH_1(r2)     ;     PITCH_1[channel] |= *(PTR[channel]);
                inc PTR(r2)                    ;     PTR[channel]++;
                jmp next_channel               ;     break

        check_if_data_pitch_1_msb:
            cmpb r0, #0xD1                     ; else if (data == 0xD1)
            bne check_if_data_pitch_1_word
              ; Set Pitch 1 MSB                ;     VOLUME[channel] = data;
                                               ;     PITCH_1[channel] &= 0x00FF;
                movb @PTR(r2), PITCH_1+1(r2)   ;     PITCH_1[channel] |= (*(PTR[channel]) << 8);
                inc PTR(r2)                    ;     PTR[channel]++;
                jmp next_channel               ;     break

        check_if_data_pitch_1_word:
            cmpb r0, #0xD2                     ; else if (data == 0xD2)
            bne check_if_data_reference_short_pointer
              ; Set Pitch 1 Word               ;     VOLUME[channel] = data;
                movb @PTR(r2), PITCH_1(r2)     ;     PITCH_1[channel] = (*(PTR[channel] + 1) << 8) | *(PTR[channel]);
                movb @PTR+1(r2), PITCH_1+1(r2)
                add #2, PTR(r2)                ;     PTR[channel] += 2;
                jmp next_channel               ;     break

        check_if_data_reference_short_pointer:
            cmpb r0, #0xD3                     ; else if (data == 0xD3)
            bne check_if_data_pitch_2_lsb
              ; Read reference short pointer
                clrb r0
                bisb @PTR(r2), r0              ;     data = *(PTR[channel]);
                inc PTR(r2)                    ;     PTR[channel]++;
                mov PTR(r2), RET(r2)           ;     RET[channel] = PTR[channel];
                inc r0
                inc r0
                sub r0, PTR(r2)                ;     PTR[channel] -= (2 + data);
                mov PTR(r2), REFPREV(r2)       ;     REFPREV[channel] = PTR[channel];
                br update_channel_loop

        check_if_data_pitch_2_lsb:
            cmpb r0, #0xD4                     ; else if (data == 0xD4)
            bne check_if_data_pitch_2_msb
              ; Set Pitch 2 LSB
                                               ;     PITCH_2[channel] &= 0xFF00;
                movb @PTR(r2), PITCH_2(r2)     ;     PITCH_2[channel] |= *(PTR[channel]);
              ; Force pitch update and opl2 keyon
                mov PITCH_2(r2), PITCH_1(r2)   ;     PITCH_1[channel] = ~PITCH_2[channel];
                com PITCH_1(r2)
                inc PTR(r2)                    ;     PTR[channel]++;
                jmp next_channel               ;     break

        check_if_data_pitch_2_msb:
            cmpb r0, #0xD5                     ; else if (data == 0xD5)
            bne check_if_data_pitch_2_word
              ; Set Pitch 2 MSB
                                               ;     PITCH_2[channel] &= 0xFF00;
                movb @PTR(r2), PITCH_2+1(r2)   ;     PITCH_2[channel] |= *(PTR[channel]);
              ; Force pitch update and opl2 keyon
                mov PITCH_2(r2), PITCH_1(r2)   ;     PITCH_1[channel] = ~PITCH_2[channel];
                com PITCH_1(r2)                ;
                inc PTR(r2)                    ;     PTR[channel]++;
                br next_channel                ;     break

        check_if_data_pitch_2_word:
            cmpb r0, #0xD6                     ; else if (data == 0xD6)
            bne check_if_data_reference_repeat
              ; Set Pitch 2 Word
                movb @PTR(r2), PITCH_2(r2)     ;     PITCH_2[channel] = (*(PTR[channel] + 1) << 8) | *(PTR[channel]);
                movb @PTR+1(r2), PITCH_2+1(r2)
              ; Force pitch update and opl2 keyon
                mov PITCH_2(r2), PITCH_1(r2)   ;     PITCH_1[channel] = ~PITCH_2[channel];
                com PITCH_1(r2)                ;
                add #2, PTR(r2)                ;     PTR[channel] += 2;
                br next_channel                ;     break

        check_if_data_reference_repeat:
            cmpb r0, #0xD7                     ; else if (data == 0xD7)
            bne check_if_tandy_mode
              ; Read reference repeat
                mov PTR(r2), RET(r2)           ;     RET[channel] = PTR[channel];
                mov REFPREV(r2), PTR(r2)       ;     PTR[channel] = REFPREV[channel];
                br update_channel_loop

        check_if_tandy_mode:
            cmpb r0, #0xD8                      ; else if (data == 0xD8)
            bne check_if_byte_to_write_to_virtual_CPL_register_array
              ; Set Tandy mode
              ; movb @PTR(r2), @#SSY_TANDY_MODE ;     SSY_TANDY_MODE = *(PTR[channel]);
                inc PTR(r2)                     ;     PTR[channel]++;
                jmp update_channel_loop

        check_if_byte_to_write_to_virtual_CPL_register_array:
            cmpb r0, #0xE3                     ; else if (data < 0xE3)
            bhis check_if_opl_volume_byte
              ; Write byte to virtual CPL register array
                sub #0xD9, r0                  ; OPL_REGS[channel][data - 0xD9] = *(PTR[channel]);
                add r3, r0
                movb @PTR(r2), OPL_REGS(r0)
                inc PTR(r2)                    ;     PTR[channel]++;
                jmp update_channel_loop

        check_if_opl_volume_byte:
            cmpb r0, #0xE3                     ; else if (data == 0xE3)
            bne check_if_keyoff_to_a_non_zero_value
              ; Get volume byte
                movb @PTR(r2), VOLOPL(r1)      ;     VOLOPL[channel] = *(PTR[channel]);
                inc PTR(r2)                    ;     PTR[channel]++;
                jmp update_channel_loop

        check_if_keyoff_to_a_non_zero_value:
            cmpb r0, #0xE4                     ; else if (data == 0xE4)
            bne check_if_return_from_reference_pointer
              ; Set keyoff to a non-zero value
                movb r0, KEYOFF(r1)            ;     KEYOFF[channel] = data
                jmp update_channel_loop

        check_if_return_from_reference_pointer:
            cmpb r0, #0xFC                         ; else if (data == 0xFC)
            bne check_if_long_reference_call
              ; Return from reference pointer
                tstb r1                            ;     if (channel == 0)
                bnz return_from_reference_pointer
                  ; Stop the channel
                    clr PTR(r2)                    ;         PTR[channel] = 0;
                  ; Reset channel priority for sound effects
                    br next_channel                ;        break;

                return_from_reference_pointer:
                tst RET(r2)                        ;     if (RET[channel] != 0){
                bze check_if_long_reference_call
                    mov RET(r2), PTR(r2)           ;         PTR[channel] = RET[channel];
                    clr RET(r2)                    ;         RET[channel] = 0;
                    jmp update_channel_loop

        check_if_long_reference_call:
            cmpb r0, #0xFD                     ; else if (data == 0xFD)
            bne check_if_start_loop
              ; Call long reference
                mov PTR(r2), RET(r2)           ;     RET[channel] = PTR[channel] + 2;
                add #2, RET(r2)
                clr r0                         ;     PTR[channel] = SSY_MUSIC + ((*(PTR[channel] + 1) << 8) | *(PTR[channel]));
                bisb @PTR+1(r2), r0
                swab r0
                bisb @PTR(r2), r0
               .equiv SSY_MUSIC, .+2 ; Pointer to start of current music being played
                add #0, r0
                mov r0, PTR(r2)
                mov PTR(r2), REFPREV(r2)       ;     REFPREV[channel] = PTR[channel];
                jmp update_channel_loop

        check_if_start_loop:
            cmpb r0, #0xFE                     ; else if (data == 0xFE)
            bne check_if_take_loop
              ; Start loop
                mov PTR(r2), LOOP(r2)          ;     LOOP[channel] = PTR[channel];
                jmp update_channel_loop

        check_if_take_loop:
            cmpb r0, #0xFF                     ; else if (data == 0xFF)
            bne 10$
              ; Take loop
                mov LOOP(r2), PTR(r2)          ;     PTR[channel] = LOOP[channel];
            10$:
                jmp update_channel_loop

    next_channel:
        inc r1
        inc r2
        inc r2
        add #INSTRUMENT_REGS_PER_CHANNEL, r3
        cmpb r1, SSY_CHANNELS
        bhis adlib_update
        jmp process_channel

    adlib_update:
        tstb SSY_CHANNELS
        bze 1237$

        call ssy_adlib_update
      ; Update timer for sound being played
        tstb SOUND_TIMER
        bze 1237$

       .equiv SOUND_TIMER, .+2 ; The countdown timer for the current sound being played,
        dec #0                 ; before it can be interrupted by a lower priority sound
        bnz 1237$

1237$:  return ; ssy_timer_isr

ssy_adlib_update:
  ; Check which channels and how many channels needs to be updated depending
  ; on the assigned devices
    clr r1 ; byte index ; channel = 0
    clr r2 ; word index                                   ; channel_max = CH_MAX;
    clr r3 ; tens of bytes index
    ssy_adlib_update_next_channel:                        ; for (; channel < channel_max; channel++){
        tstb KEYOFF(r1)                                   ;    if (KEYOFF[channel] != 0){
        bze update_volume_if_it_has_changed
            clrb KEYOFF(r1)                               ;        KEYOFF[channel] = 0;
            mov r1, r4                                    ;        ssy_adlib_write(0xB0 + channel, 0);
            add #0xB0, r4
            clr r5
            call ssy_adlib_write

        update_volume_if_it_has_changed:
            cmpb VOLOPL(r1), VOLPREV(r1)                  ;    if (VOLOPL[channel] != VOLPREV[channel]){
            beq 10$
                movb VOLOPL(r1), VOLPREV(r1)              ;        VOLPREV[channel] = VOLOPL[channel];
                movb SSY_OPL2_OPERATOR_ORDER(r1), r4      ;        ssy_adlib_write(0x43 + SSY_OPL2_OPERATOR_ORDER[channel], VOLOPL[channel]);
                add #0x43, r4
                movb VOLOPL(r1), r5
                call ssy_adlib_write
            10$:
        ; Loop through registers and only update them if they have changed
            clr r0
            loop_through_registers:                       ;    for (i = 0; i < 10; i++){
                mov r0, r5
                add r3, r5
                cmpb OPL_REGS(r5), OPL_PREV(r5)           ;        if (OPL_REGS[channel][i] != OPL_PREV[channel][i]){
                beq 20$
                    movb OPL_REGS(r5), OPL_PREV(r5)       ;            OPL_PREV[channel][i] = OPL_REGS[channel][i];
                    movb SSY_OPL2_INSTRUMENT_REGS(r5), r4 ;            ssy_adlib_write(SSY_OPL2_INSTRUMENT_REGS[channel][i], OPL_REGS[channel][i]);
                    movb OPL_REGS(r5), r5
                    call ssy_adlib_write
                20$:
            inc r0
            cmp r0, #INSTRUMENT_REGS_PER_CHANNEL
            blo loop_through_registers

        ; Send pitch if it has changed
            cmp PITCH_2(r2), PITCH_1(r2)                  ;    if (PITCH_2[channel] != PITCH_1[channel]){
            beq 30$
                mov PITCH_2(r2), PITCH_1(r2)              ;        PITCH_1[channel] = PITCH_2[channel];
              ; Set pitch lsb
                mov #0xA0, r4                             ;        ssy_adlib_write(0xA0 + channel, PITCH_2[channel]);
                add r1, r4
                movb PITCH_2(r2), r5
                call ssy_adlib_write
              ; Set pitch msb and key on, pitch change always does key on
                mov #0xB0, r4                             ;        ssy_adlib_write(0xB0 + channel, PITCH_2[channel] >> 8);
                add r1, r4
                swab r5
                movb PITCH_2+1(r2), r5
                call ssy_adlib_write
            30$:
        add #INSTRUMENT_REGS_PER_CHANNEL, r3
        inc r2
        inc r2
        inc r1
        cmp r1, #CH_MAX
    blo ssy_adlib_update_next_channel

return

ssy_adlib_write:
  ; After writing to the register port, you must wait 12 cycles
  ; (3.4 μs at 3.58 MHz) before sending the data.
  ; After writing the data, 84 cycles (23.5 μs at 3.58MHz) must elapse before
  ; any other sound card operation may be performed.
  ; `nop` takes at least 16 external cycles (2.56 μs)
  ;
  ; r4 = regnum, r5 = regval
    movb r4, @#ASM_OPL2
    .rept 1
        nop
    .endr
    mov  r5, @#ASM_OPL2
    .rept 5
        nop
    .endr
return

.equiv ASM_OPL2, OPL2
; .equiv ASM_OPL2, STUB_REGISTER
.equiv CH_MAX, 9
.equiv music_channels_vars_size, music_channels_vars_to_zero_end - music_channels_vars
.equiv music_channels_vars_sizew, music_channels_vars_size / 2

; arrays of pointers to a byte in the sound data
music_channels_vars:
    RET:     .ds.w CH_MAX ; Return pointer from a block reference
    PTR:     .ds.w CH_MAX ; Current pointer
    LOOP:    .ds.w CH_MAX ; Loop pointer
    REFPREV: .ds.w CH_MAX ; Previous reference pointer

    PITCH_1: .ds.w CH_MAX ; Pitch for speaker, previous pitch for adlib
    PITCH_2: .ds.w CH_MAX ; Pitch for tandy and adlib

    WAIT:    .ds.b CH_MAX ;
    VOLPREV: .ds.b CH_MAX ; Previous volume value to track down the changes
    KEYOFF:  .ds.b CH_MAX ; Op12 keyoff flag
    VOLOPL:  .ds.b CH_MAX ; Op12 specific volume (more bits and extra data)

   .equiv INSTRUMENT_REGS_PER_CHANNEL, 10
    OPL_REGS: .ds.b CH_MAX * INSTRUMENT_REGS_PER_CHANNEL
    OPL_PREV: .ds.b CH_MAX * INSTRUMENT_REGS_PER_CHANNEL
music_channels_vars_to_zero_end:

SSY_CHANNELS: .word 0 ; Number of active data streams

SSY_OPL2_OPERATOR_ORDER:
    ;        0     1     2     4     4     5     6     7     8
    .byte 0x00, 0x01, 0x02, 0x08, 0x09, 0x0A, 0x10, 0x11, 0x12

SSY_OPL2_INSTRUMENT_REGS:
    ;        0     1     2     4     4     5     6     7     8     9
    .byte 0xC0, 0x20, 0x40, 0x60, 0x80, 0xE0, 0x63, 0x83, 0x23, 0xE3 ; channel 0
    .byte 0xC1, 0x21, 0x41, 0x61, 0x81, 0xE1, 0x64, 0x84, 0x24, 0xE4 ; channel 1
    .byte 0xC2, 0x22, 0x42, 0x62, 0x82, 0xE2, 0x65, 0x85, 0x25, 0xE5 ; channel 2
    .byte 0xC3, 0x28, 0x48, 0x68, 0x88, 0xE8, 0x6B, 0x8B, 0x2B, 0xEB ; channel 3
    .byte 0xC4, 0x29, 0x49, 0x69, 0x89, 0xE9, 0x6C, 0x8C, 0x2C, 0xEC ; channel 4
    .byte 0xC5, 0x2A, 0x4A, 0x6A, 0x8A, 0xEA, 0x6D, 0x8D, 0x2D, 0xED ; channel 5
    .byte 0xC6, 0x30, 0x50, 0x70, 0x90, 0xF0, 0x73, 0x93, 0x33, 0xF3 ; channel 6
    .byte 0xC7, 0x31, 0x51, 0x71, 0x91, 0xF1, 0x74, 0x94, 0x34, 0xF4 ; channel 7
    .byte 0xC8, 0x32, 0x52, 0x72, 0x92, 0xF2, 0x75, 0x95, 0x35, 0xF5 ; channel 8

SOUND_PLAY_PRIORITY:
    .byte  0 ;  0 - BEEP
    .byte  2 ;  1 - CYCLE_ITEM
    .byte  2 ;  2 - CYCLE_WEAPON
    .byte  1 ;  3 - DOOR
    .byte  5 ;  4 - FIRE_PISTOL
    .byte  1 ;  5 - BEEP2
    .byte 11 ;  6 - USE_EMP
    .byte  3 ;  7 - ERROR
    .byte  4 ;  8 - ITEM_FOUND
    .byte  9 ;  9 - USE_MAGNET
    .byte 10 ; 10 - USE_MAGNET2
    .byte 12 ; 11 - USE_MEDKIT
    .byte  7 ; 12 - MOVE_OBJECT
    .byte  6 ; 13 - FIRE_PLASMA
    .byte  8 ; 14 - SHOCK
    .byte 13 ; 15 - EXPLOSION
    .byte 13 ; 16 - EXPLOSION2

SOUND_PLAY_TIMER:
    .byte  5 ;  0 - BEEP
    .byte 10 ;  1 - CYCLE_ITEM
    .byte 10 ;  2 - CYCLE_WEAPON
    .byte 30 ;  3 - DOOR
    .byte  5 ;  4 - FIRE_PISTOL
    .byte  5 ;  5 - BEEP2
    .byte 20 ;  6 - USE_EMP
    .byte 20 ;  7 - ERROR
    .byte 20 ;  8 - ITEM_FOUND
    .byte 50 ;  9 - USE_MAGNET
    .byte 50 ; 10 - USE_MAGNET2
    .byte 15 ; 11 - USE_MEDKIT
    .byte  5 ; 12 - MOVE_OBJECT
    .byte 10 ; 13 - FIRE_PLASMA
    .byte 20 ; 14 - SHOCK
    .byte 30 ; 15 - EXPLOSION
    .byte 40 ; 16 - EXPLOSION2

    .even

MUSIC:
    ; .incbin "sound/Metal Heads.adl"
    .incbin "sound/All Clear!.adl"
    ; .incbin "sound/End of the Line.adl"
SOUNDFX:
    .incbin "sound/soundfx.adl"
    .even

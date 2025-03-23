.equiv CH_MAX, 9
.equiv SSY_INIT,  0b0001
.equiv SSY_OPL2_SHUT,  0b0001
.equiv SSY_SOUND_PLAY, 0b0010
.equiv SSY_MUSIC_STOP, 0b0100
.equiv SSY_MUSIC_PLAY, 0b1000
.equiv playSound, ssy_sound_play

; Sound FX
.equiv BEEP,          0
.equiv CYCLE_ITEM,    1
.equiv CYCLE_WEAPON,  2
.equiv DOOR,          3
.equiv FIRE_PISTOL,   4
.equiv BEEP2,         5
.equiv USE_EMP,       6
.equiv ERROR,         7
.equiv ITEM_FOUND,    8
.equiv USE_MAGNET,    9
.equiv USE_MAGNET2,  10
.equiv USE_MEDKIT,   11
.equiv MOVE_OBJECT,  12
.equiv FIRE_PLASMA,  13
.equiv SHOCK,        14
.equiv EXPLOSION,    15
.equiv EXPLOSION2,   16

ssy_init:
  ; Clear some vars
    mov #1, SOUND_ENABLED
    mov #1, SSY_CHANNELS
  ; Clear data and force OPL registers update
    mov #OPL2_CHANNELS_VARS_SIZEW, r0
    mov #OPL2_CHANNELS_VARS, r1
    10$:
        clr (r1)+
    sob r0, 10$

    .ifdef SPLIT_OPL2_PLAYER
        bis #SSY_INIT, OPL2_PROCS_TO_EXECUTE
    .else
        call ssy_opl2_init
    .endif
return ; ssy_init

.ifndef SPLIT_OPL2_PLAYER
    .include "audio/ssy_opl2_init.s"
.endif

ssy_sound_play: ;--------------------------------------------------------------------------------{{{
  ; in: r0 - sfx number

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
    clr PITCH
    movb #0xFF, KEYOFF
    .ifdef SPLIT_OPL2_PLAYER
        bis #SSY_SOUND_PLAY, OPL2_PROCS_TO_EXECUTE
    .else
        movb #0xFF, VOLPREV
        mov #0xFFFF, PITCH_PREV
    .endif

    asl r0
    mov SOUNDFX+2(r0), r0
    add #SOUNDFX, r0
    mov r0, PTR
return ;-----------------------------------------------------------------------------------------}}}

ssy_music_stop: ;--------------------------------------------------------------------------------{{{
    mov #1, R1
    mov #10, R2
    mov R1, SSY_CHANNELS ; SSY_CHANNELS = 1;
  ; Set all music channels volume to 0 to mute the music without stopping sound effects
    10$:                                              ; for (channel = 1; channel < CH_MAX; channel++){
                                                      ;         VOLUME[channel] = 0;
        movb #0xFF, VOLOPL(R1)                        ;         VOLOPL[channel] = 0xFF;

       .ifndef SPLIT_OPL2_PLAYER
            movb #0x55, VOLPREV(R1)                   ;         VOLPREV[channel] = 0x55;
          ; Added to actually turn off the volume
                                                      ;         if (SSY_DEVICE_MUS == DEVICE_ADLIB){
            mov SSY_OPL2_OPERATOR_ORDER(R1), R4       ;                 ssy_adlib_write(0x43 + SSY_OPL2_OPERATOR_ORDER[channel], VOLOPL[channel]);
            add #0x43, R4
            mov #0xFF, R5
            call ssy_opl2_write
            mov #10, R3
            mov R2, R4
            clr R5
            20$:
                                                      ;                 for (i2 = 0; i2 < 10; i2++){
                mov SSY_OPL2_INSTRUMENT_REGS(R2), R4  ;                         ssy_adlib_write(SSY_OPL2_INSTRUMENT_REGS[channel][i2], 0);
                call ssy_opl2_write
                inc R2
            sob R3, 20$
            add #10, R2
       .endif

    inc R1
    cmp R1, #CH_MAX
    blo 10$

    .ifdef SPLIT_OPL2_PLAYER
        bis #SSY_MUSIC_STOP, OPL2_PROCS_TO_EXECUTE
    .endif
return ;-----------------------------------------------------------------------------------------}}}

ssy_music_play:
    call ssy_music_stop
    tst #MUSIC ; check if music is loaded
    bze 1237$

    .ifdef SPLIT_OPL2_PLAYER
        mov #SSY_MUSIC_PLAY, OPL2_PROCS_TO_EXECUTE
    .endif
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

       .ifndef SPLIT_OPL2_PLAYER
            clr PITCH_PREV(r2)
       .endif
        clr PITCH(r2)

        clrb WAIT(r1)
       .ifndef SPLIT_OPL2_PLAYER
            clrb VOLPREV(r1)
       .endif
        clrb KEYOFF(r1)
        clrb VOLOPL(r1)
        clr r4
        20$:
            mov r3, r0
            add r4, r0
            clrb OPL_REGS(r0)
           .ifndef SPLIT_OPL2_PLAYER
                clrb OPL_PREV(r0)
           .endif
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
    inc r0                ; add SFX channel to channels count
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
       .ifndef SPLIT_OPL2_PLAYER
        movb #0xFF, VOLPREV(r1) ; force volume update
       .endif
        inc r1
        inc r2
        inc r2
    sob r0, 30$
1237$: return ;----------------------------------------------------------------------------------}}}

;-------------------------------------------------------------------------------
; sound system update
; call it from timer ISR, at 72.8 HZ rate (8253 divider 16384, 1193180/16384=72.8)
ssy_timer_isr:
       .equiv SOUND_ENABLED, .+2 ; ssy_init sets this flag
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
                                               ;     PITCH_PREV[channel] &= 0xFF00;
                movb @PTR(r2), PITCH_PREV(r2)     ;     PITCH_PREV[channel] |= *(PTR[channel]);
                inc PTR(r2)                    ;     PTR[channel]++;
                jmp next_channel               ;     break

        check_if_data_pitch_1_msb:
            cmpb r0, #0xD1                     ; else if (data == 0xD1)
            bne check_if_data_pitch_1_word
              ; Set Pitch 1 MSB                ;     VOLUME[channel] = data;
                                               ;     PITCH_PREV[channel] &= 0x00FF;
                movb @PTR(r2), PITCH_PREV+1(r2)   ;     PITCH_PREV[channel] |= (*(PTR[channel]) << 8);
                inc PTR(r2)                    ;     PTR[channel]++;
                jmp next_channel               ;     break

        check_if_data_pitch_1_word:
            cmpb r0, #0xD2                     ; else if (data == 0xD2)
            bne check_if_data_reference_short_pointer
              ; Set Pitch 1 Word               ;     VOLUME[channel] = data;
                movb @PTR(r2), PITCH_PREV(r2)     ;     PITCH_PREV[channel] = (*(PTR[channel] + 1) << 8) | *(PTR[channel]);
                movb @PTR+1(r2), PITCH_PREV+1(r2)
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
                                               ;     PITCH[channel] &= 0xFF00;
                movb @PTR(r2), PITCH(r2)     ;     PITCH[channel] |= *(PTR[channel]);
              ; Force pitch update and opl2 keyon
                mov PITCH(r2), PITCH_PREV(r2)   ;     PITCH_PREV[channel] = ~PITCH[channel];
                com PITCH_PREV(r2)
                inc PTR(r2)                    ;     PTR[channel]++;
                jmp next_channel               ;     break

        check_if_data_pitch_2_msb:
            cmpb r0, #0xD5                     ; else if (data == 0xD5)
            bne check_if_data_pitch_2_word
              ; Set Pitch 2 MSB
                                               ;     PITCH[channel] &= 0xFF00;
                movb @PTR(r2), PITCH+1(r2)   ;     PITCH[channel] |= *(PTR[channel]);
              ; Force pitch update and opl2 keyon
                mov PITCH(r2), PITCH_PREV(r2)   ;     PITCH_PREV[channel] = ~PITCH[channel];
                com PITCH_PREV(r2)                ;
                inc PTR(r2)                    ;     PTR[channel]++;
                br next_channel                ;     break

        check_if_data_pitch_2_word:
            cmpb r0, #0xD6                     ; else if (data == 0xD6)
            bne check_if_data_reference_repeat
              ; Set Pitch 2 Word
                movb @PTR(r2), PITCH(r2)     ;     PITCH[channel] = (*(PTR[channel] + 1) << 8) | *(PTR[channel]);
                movb @PTR+1(r2), PITCH+1(r2)
              ; Force pitch update and opl2 keyon
                mov PITCH(r2), PITCH_PREV(r2)   ;     PITCH_PREV[channel] = ~PITCH[channel];
                com PITCH_PREV(r2)                ;
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
       .equiv SSY_CHANNELS, .+2 ; Number of active data streams
        cmpb r1, #1
        beq opl2_update
        jmp process_channel

    opl2_update:
        tstb SSY_CHANNELS
        bze 1237$

       .ifndef SPLIT_OPL2_PLAYER
        call ssy_opl2_update
       .endif
      ; Update timer for sound being played
        tstb SOUND_TIMER
        bze 1237$

       .equiv SOUND_TIMER, .+2 ; The countdown timer for the current sound being played,
        dec #0                 ; before it can be interrupted by a lower priority sound
        bnz 1237$

1237$:  return ; ssy_timer_isr

readByte:
    mov PTR(r2), r0
    tst r1
    bnz hi_mem_data
        clc
        ror r0
        mov r0, @#PADDR_REG
        bcs 10$
            clr r0
            bisb @#PBP1_DATA_REG, r0
            return
        10$:
            clr r0
            bisb @#PBP2_DATA_REG, r0
            return
    hi_mem_data:
        sec
        ror r0
        mov r0, @#PADDR_REG
        bcs 10$
            clr r0
            bisb @#PBP1_DATA_REG, r0
            return
        10$:
            clr r0
            bisb @#PBP2_DATA_REG, r0
            return

    .include "audio/vars.s"

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

SOUNDFX:
    .incbin "sound/soundfx.adl"
    .even

MUSIC:
    ; .incbin "sound/Metal Heads.adl"
    .incbin "sound/All Clear!.adl"
    .even

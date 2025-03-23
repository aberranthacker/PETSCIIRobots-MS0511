.ifdef SPLIT_OPL2_PLAYER
    .equiv OPL2_CHANNELS_VARS_SIZE, OPL2_CHANNELS_VARS_END - OPL2_CHANNELS_VARS
    .equiv OPL2_CHANNELS_VARS_SIZEW, OPL2_CHANNELS_VARS_SIZE / 2

    .equiv OPL2_VARS_TO_COPY_SIZE, OPL2_CHANNELS_VARS_END - OPL2_VARS_TO_COPY ; 128 bytes
    .equiv OPL2_VARS_TO_COPY_SIZEW, OPL2_VARS_TO_COPY_SIZE / 2
    .equiv OPL2_VARS_TO_COPY_SIZEDW, OPL2_VARS_TO_COPY_SIZE / 4

    .equiv OPL2_CHANNELS_PREV_VARS_SIZE, OPL2_CHANNELS_PREV_VARS_END - OPL2_CHANNELS_PREV_VARS
    .equiv OPL2_CHANNELS_PREV_VARS_SIZEW, OPL2_CHANNELS_PREV_VARS_SIZE / 2
.else
    .equiv OPL2_CHANNELS_VARS_SIZE, OPL2_CHANNELS_PREV_VARS_END - OPL2_CHANNELS_VARS
    .equiv OPL2_CHANNELS_VARS_SIZEW, OPL2_CHANNELS_VARS_SIZE / 2
.endif

    .equiv INSTRUMENT_REGS_PER_CHANNEL, 10

; arrays of pointers to a byte in the sound data
OPL2_CHANNELS_VARS:

    WAIT:    .ds.b CH_MAX ;
   .even
    RET:     .ds.w CH_MAX ; Return pointer from a block reference
    PTR:     .ds.w CH_MAX ; Current pointer
    LOOP:    .ds.w CH_MAX ; Loop pointer
    REFPREV: .ds.w CH_MAX ; Previous reference pointer

OPL2_VARS_TO_COPY:
    KEYOFF:   .ds.b CH_MAX ; OPL2 keyoff flag
    VOLOPL:   .ds.b CH_MAX ; OPL2 specific volume (more bits and extra data)
    OPL_REGS: .ds.b CH_MAX * INSTRUMENT_REGS_PER_CHANNEL
    PITCH:    .ds.w CH_MAX   ; Pitch for tandy and adlib
    .ds.w 1 ; just to make size of the section divisable by 4 (128 bytes)
OPL2_CHANNELS_VARS_END:

OPL2_CHANNELS_PREV_VARS:
    VOLPREV:    .ds.b CH_MAX ; Previous volume value to track down the changes
   .even
    OPL_PREV:   .ds.b CH_MAX * INSTRUMENT_REGS_PER_CHANNEL ; 90
    PITCH_PREV: .ds.w CH_MAX ; Pitch for speaker, previous pitch for OPL2
OPL2_CHANNELS_PREV_VARS_END:

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

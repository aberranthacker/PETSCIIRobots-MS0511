
        mov #OPL2, R5
    10$:
      ; Set up a basic sine wave tone on Channel 1
        movb #0x20, (r5); // Select register 0x20 (Modulator's multiple for Channel 1)
        nop
        nop
        mov  #0x01, (r5); // Set multiple = 1 (simple sine wave)
        .rept 10
            nop
        .endr

        movb #0x40, (r5); // Select register 0x40 (Modulator's level for Channel 1)
        nop
        nop
        mov  #0x10, (r5); // Set volume level
        .rept 10
            nop
        .endr

        movb #0x60, (r5); // Select register 0x60 (Modulator's attack/decay for Channel 1)
        nop
        nop
        mov  #0xF0, (r5); // Set attack = max, decay = min
        .rept 10
            nop
        .endr

        movb #0x80, (r5); // Select register 0x80 (Modulator's sustain/release for Channel 1)
        nop
        nop
        mov  #0x77, (r5); // Set sustain = medium, release = medium
        .rept 10
            nop
        .endr

        movb #0xA0, (r5); // Select frequency low byte for Channel 1
        nop
        nop
        mov  #0x40, (r5); // Set low byte of frequency
        .rept 10
            nop
        .endr

        movb #0xB0, (r5); // Select frequency high byte for Channel 1
        nop
        nop
        mov  #0x31, (r5); // Set high byte of frequency and key-on
        .rept 10
            nop
        .endr

    jmp 10$


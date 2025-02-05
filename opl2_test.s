;  Many people have asked me, upon reading this document, what the proper
;  register values should be to make a simple sound.  Well, here they are.
;
;  First, clear out all of the registers by setting all of them to zero.
;  This is the quick-and-dirty method of resetting the sound card, but it
;  works.  Note that if you wish to use different waveforms, you must then
;  turn on bit 5 of register 1.  (This reset need be done only once, at the
;  start of the program, and optionally when the program exits, just to
;  make sure that your program doesn't leave any notes on when it exits.)
;
;  Now, set the following registers to the indicated value:
;
;    REGISTER     VALUE     DESCRIPTION
;       20          01      Set the modulator's multiple to 1
;       40          10      Set the modulator's level to about 40 dB
;       60          F0      Modulator attack:  quick;   decay:   long
;       80          77      Modulator sustain: medium;  release: medium
;       A0          98      Set voice frequency's LSB (it'll be a D#)
;       23          01      Set the carrier's multiple to 1
;       43          00      Set the carrier to maximum volume (about 47 dB)
;       63          F0      Carrier attack:  quick;   decay:   long
;       83          77      Carrier sustain: medium;  release: medium
;       B0          31      Turn the voice on; set the octave and freq MSB
;
;  To turn the voice off, set register B0h to 11h (or, in fact, any value
;  which leaves bit 5 clear).  It's generally preferable, of course, to
;  induce a delay before doing so.
    mov #OPL2, R5

    opl2_test_loop:
        mov #0x20, r0
        mov #0x01, r1
        call oplWr

        mov #0x40, r0
        mov #0x10, r1
        call oplWr

        mov #0x60, r0
        mov #0xF0, r1

        mov #0x80, r0
        mov #0x77, r1
        call oplWr

        mov #0xA0, r0
        mov #0x98, r1
        call oplWr

        mov #0x23, r0
        mov #0x01, r1
        call oplWr

        mov #0x43, r0
        mov #0x00, r1
        call oplWr

        mov #0x63, r0
        mov #0xF0, r1
        call oplWr

        mov #0x83, r0
        mov #0x77, r1
        call oplWr

        mov #0xB0, r0
        mov #0x31, r1
        call oplWr
    jmp opl2_test_loop
        br opl2_test_exit

oplWr:
  ; After writing to the register port, you must wait 12 cycles
  ; (3.4 μs at 3.58 MHz) before sending the data.
  ; After writing the data, 84 (23.5 μs at 3.58MHz) cycles must elapse before
  ; any other sound card operation may be performed.
  ; `nop` takes 16 external cycles min (2.56 μs)
    movb r0, (r5)
    nop
    mov r1, (r5)
   .rept 5
        nop
   .endr
return

opl2_test_exit:

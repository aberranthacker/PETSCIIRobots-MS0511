vblankIntHandler: ;-------------------------------------------------------------
        push @#PBPADR, r5, r4, r3, r2, r1, r0

    .ifdef DEBUG
       ;CALL @#PrintDebugInfo
    .endif

       .equiv MusicPlayerAddr, .+2
        call @#subroutineStub

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

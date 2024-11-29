VblankIntHandler: ;-------------------------------------------------------------
        PUSH @#PBPADR, R5, R4, R3, R2, R1, R0

    .ifdef DEBUG
       ;CALL @#PrintDebugInfo
    .endif

       .equiv MusicPlayerAddr, .+2
        CALL @#SubroutineStub

VblankIntHandler_Finalize:
        POP R0, R1, R2, R3, R4, R5, @#PBPADR

VblankIntHandler.Minimal:
      ; small piece of firware code to stop floppy disk drive
        TST  @#07130 ; is floppy disk drive timer active?
        BZE  1271$   ; no, do nothing
        DEC  @#07130 ; decrease timer counter
        BNZ  1271$   ; do nothing, unless the counter reached 0
        CALL @07132  ; stop floppy disk drive

1271$:  RTI
;-------------------------------------------------------------------------------

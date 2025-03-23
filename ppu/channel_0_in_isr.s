channel0InISR: ;--------------------------------------------------------
        PUSH @#PBPADR, R5

        MOV  @#CommandsQueue_CurrentPosition, R5
    .ifdef DebugMode
        CMP  R5, #CommandsQueue_Top
        BLOS CommandsQueue_Full
    .endif
        MOV  #CPU_PPUCommandArg, @#PBPADR
        MOV  @#PBP12D, -(R5)
        MOV  @#PCH0ID, -(R5)
       .equiv CommandsQueue_CurrentPosition, .+2
        MOV  R5, #CommandsQueue_Bottom

        POP R5, @#PBPADR
        RTI

CommandsQueue_Full:
        BR   .
        NOP
;-------------------------------------------------------------------------------

Channel1In_IntHandler: ;--------------------------------------------------------
        PUSH @#PBPADR, R0, R1, R2, R3, R4, R5

        TSTB @#PCH1ID
        BZE  ShowFB0
        BR   ShowFB1
ShowFB0: ;----------------------------------------------------------------------
        MOV  #0x20, R0
        MOV  #8, R1 ; length of the screenlines table record
        MOV  #200/8, R2
        MOV  #PBP0DT, R4
        MOV  #PBPADR, R5
        .equiv MainScreenFirstRecAddr, .+2
        MOV  #0, (R5)
        INC  (R5)

100$: .rept 1*8
        BICB R0, (R4)
        ADD  R1, (R5)
      .endr
        SOB  R2, 100$

        BR   Channel1In_IntHandler_Finalize
;-------------------------------------------------------------------------------
ShowFB1: ;----------------------------------------------------------------------
        MOV  #0x20, R0
        MOV  #8, R1
        MOV  #200/8, R2
        MOV  #PBP0DT, R4
        MOV  #PBPADR, R5
        MOV  @#MainScreenFirstRecAddr, (R5)
        INC  (R5)

100$: .rept 1*8
        BISB R0, (R4)
        ADD  R1, (R5)
      .endr
        SOB  R2, 100$

        BR   Channel1In_IntHandler_Finalize
;-------------------------------------------------------------------------------
Channel1In_IntHandler_Finalize:
        POP R5, R4, R3, R2, R1, R0, @#PBPADR

        RTI
;-------------------------------------------------------------------------------

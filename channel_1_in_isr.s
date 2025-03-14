Channel1InIsr: ;--------------------------------------------------------
    mtps #PR7
    push @#CADDR_REG, R0, R1, R2, R3, R4, R5
        call ssy_timer_isr
    pop R5, R4, R3, R2, R1, R0, @#CADDR_REG
    tstb @#CCH1_IN_DATA
    mtps #PR0
    nop
    nop
    rti

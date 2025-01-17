                .list

                .title "robots PPU module"

                .global start ; make the entry point available to the linker
                .global PPU_ModuleSize
                .global PPU_ModuleSizeWords

                .include "macros.s"
                .include "hwdefs.s"
                .include "defs.s"
                .include "constants.s"

                .equiv PPU_ModuleSize, (end - start)
                .equiv PPU_ModuleSizeWords, PPU_ModuleSize/2

                .=PPU_UserRamStart
start:
        MTPS #PR7
        MOV #0100000, SP
        mov #PPU_INTERRUPT_VECTORS, r0
        10$:
            mov #interruptHandlerStub, (r0)+
            tst (r0)
        bnz 10$
      ; Setting up PPU address space control register:
      ;                        5432109876543210
      ; Its default value is 0b0000001100000001

      ; bit 0: if clear, disables ROM chip in the range 0100000..0117777
      ;        which allows to enable RW access to RAM in that range
      ;        when bit 4 is also set
      ; bits 1-3: used to select ROM cartridge banks
      ; bit 4: replaces ROM in the range 0100000..0117777 with RAM (see bit 0)
      ; bit 5: enables write-only access to RAM in the range 0120000..0137777
      ; bit 6: enables write-only access to RAM in the range 0140000..0157777
      ; bit 7: enables write-only access to RAM in the range 0160000..0176777
      ; bit 8: enables PPU Vblank interrupt when clear, disables when set
      ; bit 9: enables CPU Vblank interrupt when clear, disables when set
      ;
      ; WARNING: since there is no way to disable ROM chips in the range
      ; 0120000..0176777, write-only access to the RAM is the only option.
      ; **However**, the UKNCBL emulator allows to reading from the RAM as well!
      ; **Beware** this is **not** how the real hardware behaves!
;-------------------------------------------------------------------------------
    .if AUX_SCREEN_LINES_COUNT != 0
        CALL clearAuxScreen
    .endif
        .ifdef COLOR_TILES
            call clearScreen
        .else
            mov #1, @#BITPLANES_MASK_REG
        .endif
        .include "ppu/sltab_init.s"
        mov #0x001, @#PASWCR
;-------------------------------------------------------------------------------
        MOV #SLTAB, @#0272 ; use our SLTAB

        call Puts

        MOV #vblankIntHandler, @#0100

        MOV #keyboardIntHadler,@#KBINT
      ; Установим адрес таблицы раскладки клавиатуры на таблицу режима ГРАФ
      ; Хак, переводящий раскладку в эмуляторе UKNCBTL c qwerty на jcuken
        mov #07774, @#07214

        MOV #PCH0II, R0
        MOV #Channel0In_IntHandler, (R0)+
        MOV #0200, (R0)
      ; read from the channel, just in case
        TST @#PCH0ID

        MOV #PCH1II, R0
        MOV #Channel1In_IntHandler, (R0)+
        MOV #0200, (R0)
        BIS #Ch1StateInInt, @#PCHSIS ; enable channel 1 input interrupt
      ; read from the channel, just in case
        TST @#PCH1ID

    .ifdef DETECT_ABERRANT_SOUND_MODULE
        .equiv ScanRangeWords, 3
        mov #PSG0+ScanRangeWords * 2, r1
        push @#4
            mov #Trap4, @#4
          ; Aberrant Sound Module uses addresses range 0177360-0177377
          ; 16 addresses in total
            mov #ScanRangeWords, r0
            TestNextSoundBoardAddress:
                tst -(r1)
            sob r0, TestNextSoundBoardAddress
          ; R1 now contains 0177360, address of PSG0
            mov #PSG1, r2

            tst @#Trap4Detected
            bze aberrant_sound_module_present
                mov #STUB_REGISTER, r1
                mov r1, r2
            aberrant_sound_module_present:
                clr @#Trap4Detected
                .ifdef INCLUDE_AKG_PLAYER
                .endif
        pop @#4
    .endif
        mov #trap4Handler, @#04
        mov #trap10Handler, @#010
        mov #trap24Handler, @#024

        MOV @#023166, rseed1 ; set cursor presence counter value as random seed

        MTPS #PR0

      ; inform loader that PPU is ready to receive commands
        MOV #CPU_PPUCommandArg, @#PBPADR
        CLR @#PBP12D

;-------------------------------------------------------------------------------
Queue_Loop:
        MOV @#CommandsQueue_CurrentPosition, R5
        CMP R5, #CommandsQueue_Bottom
        BEQ Queue_Loop

        MTPS #PR7
        MOV (R5)+, R1
        MOV (R5)+, R0
        MOV R5, @#CommandsQueue_CurrentPosition
        MTPS #PR0
    .ifdef DEBUG
        CMP R1, #PPU.LastJMPTableIndex
        BHI .
    .endif
        CALL @CommandsVectors(R1)
        BR Queue_Loop
;-------------------------------------------------------------------------------
CommandsVectors:
        .word loadDiskFile
        .word setPalette            ; PPU.SetPalette
        .word clearScreen           ; PPU.ClearScreen
        .word ssy_music_play
        .word test_timer
;-------------------------------------------------------------------------------
clearAuxScreen: ;------------------------------------------------------------{{{
    .if AUX_SCREEN_LINES_COUNT != 0
        MOV #AUX_SCREEN_LINES_COUNT * (4/LINE_SCALE), R1
        MOV #DTSOCT,R4
        MOV #PBPADR,R5
        MOV #AUX_SCREEN_ADDR,(R5)
        CLR @#BP01BC ; background color, pixels 0-3
        CLR @#BP12BC ; background color, pixels 4-7
        push @#BITPLANES_MASK_REG
            CLR @#PBPMSK ; write to all bit-planes

            100$:
               .rept 10
                CLR (R4)
                INC (R5)
               .endr
            SOB R1,100$

        pop @#BITPLANES_MASK_REG
        RETURN
    .endif
;----------------------------------------------------------------------------}}}
clearScreen: ;---------------------------------------------------------------{{{
        rept_count = 10

        mov #MAIN_SCREEN_LINES_COUNT * LINE_WIDTHW / rept_count, r1
        mov #DTSOCT, r4
        mov #PBPADR, r5
        mov #FB / 2, (r5)
        clr @#BP01BC ; background color, pixels 0-3
        clr @#BP12BC ; background color, pixels 4-7

        100$:
           .rept rept_count
                clr (R4)
                inc (R5)
           .endr
        sob r1,100$

        return
;----------------------------------------------------------------------------}}}
    .ifdef INCLUDE_AKG_PLAYER ;----------------------------------------------{{{
    .endif ;-----------------------------------------------------------------}}}
loadDiskFile: ; -------------------------------------------------------------{{{
        mov #vblankIntHandler.minimal, @#0100
      ; in: r0 = address of params struct in CPU memory
        clc
        ror r0 ; prepare the address to be loaded into address register 0177010
        mov r0, @#023200 ; store params struct address for firmware subroutine
      ; firmware subroutine that handles floppy drive
      ; it call programmable timer subroutine which uses value at 07050
        call @#0131176

        wait_while_loading:
            tstb @#023334 ; check operation status code (params struct copy)
        bmi wait_while_loading

        mov #vblankIntHandler, @#0100
1237$:  return
;----------------------------------------------------------------------------}}}
test_timer: ; ---------------------------------------------------------------{{{
        mov #3434, @#TMRBUF
        mov #timer_sub, @#TMRINT
        ;      76543210
        mov #0b01000011, @#TMRST
    return


timer_sub:
        push @#PBPADR, r0, r1, r2, r3, r4, r5
        call ssy_timer_isr
        pop r5, r4, r3, r2, r1, r0, @#PBPADR
    rti
;----------------------------------------------------------------------------}}}
; Generates a 16-bit pseudorandom number using LSFR
; output: R0 - next pseudorandom number
RandomWord:
        .equiv rseed1, .+2
        MOV #0, R0     ; load the current seed value into R0
        ASL R0         ; double the value in R0
        BHI 10$        ; branch if neither a carry nor a zero flags are set
        ADD #39, R0
    10$:
        MOV R0, rseed1 ; store the new seed value back to rseed1
        .equiv rseed2, .+2
        ADD #0x9820, R0; add the secondary seed value to R0
        MOV R0, rseed2 ; store the result back to rseed2

subroutineStub:
    return
interruptHandlerStub:
    br .
    nop
    nop
PPU_INTERRUPT_VECTORS:
    .word 04, 010, 014, 020, 024, 030, 034, 0100
    .word 0300, 0304, 0310, 0314, 0320, 0324, 0330, 0334, 0340
    .word 0 ; terminator

        .include "ppu/channel_0_in_int_handler.s"
        .include "ppu/channel_1_in_int_handler.s"
        .include "ppu/errors_handler.s"
        .include "ppu/keyboard_int_handler.s"
        .include "ppu/set_palette.s"
        .include "ppu/trap_4_int_handler.s"
        .include "ppu/vblank_int_handler.s"
        .include "ppu/puts.s"
        .include "audio.s"

        .even

CommandsQueue_Top:
        .ds 2*16
CommandsQueue_Bottom:

WAKING_UP_STR:
        .asciz "Waking up the robots..."
        .even

end:
        .nolist

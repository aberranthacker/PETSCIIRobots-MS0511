                .list

                .title "robots PPU module"

                .global start ; make the entry point available to the linker
                .global PPU_ModuleSize
                .global PPU_ModuleSizeWords

                .include "macros.s"
                .include "hwdefs.s"
                .include "defs.s"

                .equiv PPU_ModuleSize, (end - start)
                .equiv PPU_ModuleSizeWords, PPU_ModuleSize/2

                .=PPU_UserRamStart
start:
        MTPS #PR7
        MOV #0100000, SP

      ; Setting up PPU address space control register:
      ;                        5432109876543210
      ; Its default value is 0b0000001100000001

      ; bit 0: if clear, disables ROM chip in the range 0100000..0117777
      ;       which allows to enable RW access to RAM in that range
      ;       when bit 4 is also set
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
        MOV #0x0F0, @#PASWCR
    .if AUX_SCREEN_LINES_COUNT != 0
        CALL ClearAuxScreen
    .endif
        .include "ppu/sltab_init.s"
        MOV #0x001, @#PASWCR
;-------------------------------------------------------------------------------
        MOV #SLTAB, @#0272 ; use our SLTAB

        call Puts

        MTPS #PR0

        MOV #KeyboardIntHadler,@#KBINT
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
        MOV #PSG0+ScanRangeWords * 2, R1
        MOV #Trap4, @#4
      ; Aberrant Sound Module uses addresses range 0177360-0177377
      ; 16 addresses in total
        MOV #ScanRangeWords, R0
        TestNextSoundBoardAddress:
            TST -(R1)
        SOB R0, TestNextSoundBoardAddress
      ; R1 now contains 0177360, address of PSG0
        MOV #PSG1, R2

        TST @#Trap4Detected
        BZE AberrantSoundModulePresent

        MOV #PSG_STUB, R1
        MOV R1, R2

    AberrantSoundModulePresent:
        CLR @#Trap4Detected
        .ifdef INCLUDE_AKG_PLAYER
        .endif
        MOV #0173362, @#4 ; restore back Trap 4 handler
    .endif

        MOV @#023166, rseed1 ; set cursor presence counter value as random seed

        call ssy_init
        call ssy_music_play

        MOV #VblankIntHandler, @#0100

      ; inform loader that PPU is ready to receive commands
        MOV #CPU_PPUCommandArg, @#PBPADR
        CLR @#PBP12D

        MOV #CommandsQueue_CurrentPosition, R4
        MTPS #PR0
;-------------------------------------------------------------------------------
Queue_Loop:
        MOV (R4), R5
        CMP R5, #CommandsQueue_Bottom
        BEQ Queue_Loop

        MTPS #PR7
        MOV (R5)+, R1
        MOV (R5)+, R0
        MOV R5, (R4)
        MTPS #PR0
    .ifdef DEBUG
        CMP R1, #PPU.LastJMPTableIndex
        BHI .
    .endif
        CALL @CommandsVectors(R1)
        MOV #CommandsQueue_CurrentPosition, R4
        BR Queue_Loop
;-------------------------------------------------------------------------------
CommandsVectors:
        .word LoadDiskFile
        .word SetPalette            ; PPU.SetPalette
        .word ClearScreen           ; PPU.ClearScreen
        .word test_timer
        .word ssy_music_play
;-------------------------------------------------------------------------------
ClearAuxScreen: ;------------------------------------------------------------{{{
    .if AUX_SCREEN_LINES_COUNT != 0
        MOV #AUX_SCREEN_LINES_COUNT * (4/LINE_SCALE), R1
        MOV #DTSOCT,R4
        MOV #PBPADR,R5
        MOV #AUX_SCREEN_ADDR,(R5)
        CLR @#PBPMSK ; write to all bit-planes
        CLR @#BP01BC ; background color, pixels 0-3
        CLR @#BP12BC ; background color, pixels 4-7

        100$:
           .rept 10
            CLR (R4)
            INC (R5)
           .endr
        SOB R1,100$

        RETURN
    .endif
;----------------------------------------------------------------------------}}}
ClearScreen: ;---------------------------------------------------------------{{{
        MOV #MAIN_SCREEN_LINES_COUNT * (4/LINE_SCALE), R1
        MOV #DTSOCT,R4
        MOV #PBPADR,R5
        MOV #FB0/2,(R5)
        CLR @#PBPMSK ; write to all bit-planes
        CLR @#BP01BC ; background color, pixels 0-3
        CLR @#BP12BC ; background color, pixels 4-7

        100$:
           .rept 10
            CLR (R4)
            INC (R5)
           .endr
        SOB R1,100$

        RETURN
;----------------------------------------------------------------------------}}}
    .ifdef INCLUDE_AKG_PLAYER ;----------------------------------------------{{{
    .endif ;-----------------------------------------------------------------}}}
LoadDiskFile: ; -------------------------------------------------------------{{{
        MOV #VblankIntHandler.Minimal, @#0100

        MOV R0, @#023200 ; set ParamsStruct address for firmware proc to use
        CALL @#0125030   ; firmware proc that handles channel 2
        WaitWhileLoading:
          ; check operation status code (ParamsStruct was copied here)
            TSTB @#023334
        BMI WaitWhileLoading

        MOV #VblankIntHandler, @#0100
        RETURN
;----------------------------------------------------------------------------}}}
test_timer: ; -------------------------------------------------------------{{{
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

SubroutineStub:
        RETURN

        .include "ppu/channel_0_in_int_handler.s"
        .include "ppu/channel_1_in_int_handler.s"
        .include "ppu/keyboard_int_handler.s"
        .include "ppu/set_palette.s"
        .include "ppu/trap_4_int_handler.s"
        .include "ppu/vblank_int_handler.s"
        .include "ppu/puts.s"
        .include "audio.s"

        ; .incbin "resources/petfont.gfx"
        .even

    .ifdef INCLUDE_AKG_PLAYER
        .include "akg_player.s"
        .include "player_sound_effects.s"
    .endif

CommandsQueue_Top:
        .ds 2*16
CommandsQueue_Bottom:

WakingUpStr:
        .asciz "Waking up the robots..."
        .even

end:
        .nolist

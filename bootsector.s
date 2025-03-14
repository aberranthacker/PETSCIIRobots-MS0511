                .nolist
                .title "robots bootsector"

                .include "hwdefs.s"
                .include "macros.s"
                .include "defs.s"

                .global loadDiskFile
                .global PS.Status
                .global PS.Command
                .global PS.DeviceType
                .global PS.DeviceNumber
                .global PS.AddressOnDevice
                .global PS.CPU_RAM_Address
                .global PS.WordsCount

                .global main.bin

        .=0
 0$:    nop     ; Bootable disk marker, will be replaced with RTI down below
 2$:    br 76$  ; SAVED_SP: place to store SP if needed, defined in defs.s
 4$:    .word 0 ;  4: Bus time out & other errors int vector
 6$:    .word 0 ;
10$:    .word 0 ;  8: Illegal & reserved instruction int vector
12$:    .word 0 ;
14$:    .word 0 ; 12: BPT instruction int vector
16$:    .word 0 ;
20$:    .word 0 ; 16: IOT instruction int vector
22$:    .word 0 ;
24$:    .word 0 ; 20: Power fail (ACLO) int vector
26$:    .word 0 ;
30$:    .word 0 ; 24: EMT instruction int vector
32$:    .word 0 ;
34$:    .word 0 ; 28: TRAP instruction int vector
36$:    .word 0 ;
        .=040   ; 32
ParamsStruct:
40$: PS.Status:          .byte -1       ; operation status code
41$: PS.Command:         .byte 010      ; read data from disk
42$: PS.DeviceType:      .byte 02       ; double sided disk
43$: PS.DeviceNumber:    .byte (0<<7)|0 ; bit 7: side(0-bottom, 1-top) ∨ drive number(0-3)
44$: PS.AddressOnDevice: .byte 0, 2     ; track 0(0-79), sector 2(1-10)
46$: PS.CPU_RAM_Address: .word PPU_MODULE_LOADING_ADDR
50$: PS.WordsCount:      .word PPU_ModuleSizeWords ; number of words to transfer
        .=052   ;
52$:    .word -1; 42: PPUCommandArg
54$:    .word 0 ; 44: KeyboardScanner
56$:    .word 0 ; 46:
60$:    .word 0 ; 48: TTY (channel 0) out int vector
62$:    .word 0 ; 50:
64$:    .word 0 ; 52: TTY (channel 0) in int vector
66$:    .word 0 ; 54:

        .=076   ; 62
76$:    br initialLoader
100$:   .word INTERRUPT_HANDLER_STUB ; Vblank int vector
102$:   .word 0200
;-------------------------------------------------------------------------------
        .=0104  ; 68
      ; in: r0 - params struct address
      ; corruppts: r0, r1
loadDiskFile:
        mov (r0)+, PS.CPU_RAM_Address
        mov (r0)+, PS.WordsCount
        mov (r0), r1 ; starting block number
      ; calculate track number
        clr r0       ; r0: MSW, r1: LSW
        div #20, r0  ; quotient -> r0, remainder -> r1
        movb r0, PS.AddressOnDevice     ; track number (0-79)
      ; then sector number
        clr r0
        div #10, r0
        inc r1
        movb r1, PS.AddressOnDevice + 1 ; sector (1-10)
      ; quotient contains head number (0-bottom, 1-top)
      ; bit 7 of the PS.DeviceNumber defines head number
        rolb PS.DeviceNumber ; push out bit 7, old head number
        rorb r0              ; push out bit 0, new head number
        rorb PS.DeviceNumber ; push in bit 7, new head number

        movb #-1, PS.Status
        _ppu_enqueue_ensure PPU.loadDiskFile, ParamsStruct

        10$:
            tstb PS.Status
        bmi 10$

        return
;-------------------------------------------------------------------------------
; The code below will be used only once to load, install, and execute PPU module,
; as well as to load and execute loader.
; It can be overridden safely after that.
initialLoader: ; 0216 140 0x8E
      ; r0 - contains a drive number
      ; r1 - contains CSR
        movb r0, PS.DeviceNumber
        mov #0160000, sp
        mov #RTI_OPCODE, @#0
      ; Print title string -----------------------------------------------------
        mov #TitleStr, r0
        10$:
            movb (r0)+, r1
            bze loadPPUModule
            20$:
                tstb @#TTY_OUT_STATE
            bpl 20$
            mov r1, @#TTY_OUT_DATA
        br 10$

loadPPUModule:
        call channel2Send
        30$:
            tstb PS.Status  ; check loading status
        bmi 30$

      ; Allocate PPU RAM, copy PPU module, and execute it ----------------------
        mov #PPUModule_PS, ParamsAddr + 4
        call channel2Send               ; => Send request to PPU
                                        ; PS.A1: now contains address of allocated area
        mov #PPU_MODULE_LOADING_ADDR, PPUModule_PS.A2 ; Arg 2: addr of mem block in CPUs RAM
        mov #PPU_ModuleSizeWords, PPUModule_PS.A3     ; Arg 3: size of mem block, words
        movb #020, PPUModule_PS.Request ; 020 - Mem copy CPU -> PPU
        call channel2Send               ; => Send request to PPU
        movb #030, PPUModule_PS.Request ; 030 - Execute programm
        call channel2Send               ; => Send request to PPU
      ;------------------------------------------------------------------------;
      ; PPU will clear the value when it finishes initialization               ;
        WaitUntilPPUInitializes:
            tst PPUCommandArg
        bnz WaitUntilPPUInitializes
      ;-------------------------------------------------------------------------
        mov #main.bin, r0
        call loadDiskFile
        jmp MAIN_START
;-------------------------------------------------------------------------------
channel2Send:
        mov #ParamsAddr, r0 ; r0 - pointer to channel's init sequence array
        mov #8, r1          ; r1 - size of the array, 8 bytes
        10$:
            movb (r0)+, @#CCH2OD ; Send a byte to the channel 2
            20$:
                tstb @#CCH2OS
            bpl 20$              ; Wait until the channel is ready
        sob r1,10$               ; Next byte
        return
;-------------------------------------------------------------------------------
ParamsAddr: .byte  0, 0, 0, 0xFF ; init sequence
            .word  ParamsStruct
            .byte  0xFF, 0xFF    ; two termination bytes

PPUModule_PS:
    PPUModule_PS.Reply:   .byte -1  ; operation status code
    PPUModule_PS.Request: .byte 1   ; 01 - allocate memory
                                    ; 02 - free memory
                                    ; 010 - mem copy PPU -> CPU
                                    ; 020 - mem copy CPU -> PPU
                                    ; 030 - execute
    PPUModule_PS.Type:    .byte 032 ; device type - PPU RAM
    PPUModule_PS.No:      .byte 0   ; device number
    PPUModule_PS.A1:      .word 0   ; Argument 1
    PPUModule_PS.A2:      .word PPU_UserRamSizeWords ; Argument 2
    PPUModule_PS.A3:      .word 0   ; Argument 3
;-------------------------------------------------------------------------------
main.bin:
        .word MAIN_START
        .word 0
        .word 0
;-------------------------------------------------------------------------------
TitleStr: .asciz "\"Attack of the PETSCII Robots\" is loading..."

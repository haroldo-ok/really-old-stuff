;==============================================================
; Boot section
;==============================================================
.bank 0 slot 0
.org $0000
.section "Boot section" force
    di              ; disable interrupts
    im 1            ; Interrupt mode 1
    jp main         ; jump to main program
.ends

;==============================================================
; VBL Handler
;==============================================================
.org $0038
.section "VBL handler" force
	jp VBLHandlerImpl
.ends

.section "VBL handler implementation" free
VBLHandlerImpl:
	push af
	push hl
	push de
	push bc
;	SAM_PUSH_SLOT_1
;/	SAM_PUSH_SLOT_2
	
;	call UpdateSprites
;	call ReadJoypads
;	call PSGMOD_Play

	; Finalization of current interrupt
    in a,($bf)		; Read VDP status to acknowledge interrupt.

;	SAM_POP_SLOT_2
;	SAM_POP_SLOT_1
	pop bc
	pop de
	pop hl
	pop af
	
    ei
    reti
.ends

;==============================================================
; Pause button handler
;==============================================================
.org $0066
.section "Pause button handler" force
    ; Do nothing
    retn
.ends

;==============================================================
; Main program
;==============================================================
.section "Main program" free
main:
    ld sp, $dff0

    call DefaultInitialiseVDP
    call ClearVRAM

    ; Load palette
    ld hl,PaletteData               ; data
    ld b,PaletteDataEnd-PaletteData ; size
    ld c,$00                        ; index to load at
    call LoadPalette

    ; Load sprite palette
    ld hl,PaletteData               ; data
    ld b,PaletteDataEnd-PaletteData ; size
    ld c,$10                        ; index to load at
    call LoadPalette

    ; Load font
    ld hl,0                         ; tile index to load at
    ld ix,BBC_Micro_font            ; data
    ld bc,96                        ; number of tiles
    ld d,1                          ; bits per pixel
    call LoadTiles

    ; Main screen turn on!
    ld a,%11100100
;          |||| |`- Zoomed sprites -> 16x16 pixels
;          |||| `-- Doubled sprites -> 2 tiles per sprite, 8x16
;          |||`---- 30 row/240 line mode
;          ||`----- 28 row/224 line mode
;          |`------ VBlank interrupts
;          `------- Enable display
    out ($bf),a
    ld a,$81
    out ($bf),a
    
    ; Initializes variables
    ld de, ZXBASIC_USER_DATA
    ld hl, ZXBASIC_USER_DATA_VALUES
    ld bc, ZXBASIC_USER_DATA_VALUES_END - ZXBASIC_USER_DATA_VALUES
    ldir

    ei
	

	; Starts main ZX Basic Program
	call zb__START_PROGRAM
    
    ; Infinite loop to stop program
    Loop:
         jp Loop
.ends

;==============================================================
; Default palette
;==============================================================
.section "Default palette" FREE
    PaletteData:
    .db $00,$3f ; Black, White
    PaletteDataEnd:
.ends

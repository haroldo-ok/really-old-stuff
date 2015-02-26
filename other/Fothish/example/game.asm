;==============================================================
; WLA-DX banking setup
;==============================================================
.memorymap
	defaultslot     0
	; rom area
	slotsize        $4000
	slot            0       $0000
	slot            1       $4000
	slot            2       $8000
	; ram area
	slotsize        $2000
	slot            3       $C000
	slot            4       $E000
.endme

.rombankmap
	bankstotal 4
	banksize $4000
	banks 4
.endro

.DEFINE DATA_STACK_TOP	$DFF0
.DEFINE CODE_STACK_TOP	$DEF0

;==============================================================
; SDSC tag and SMS rom header
;==============================================================
.sdsctag 0.02,"S.A.M. - Simple Adventure Maker","Version 0.02 - Multi-script and sound support","Haroldo O. Pinheiro"

;==============================================================
; S.A.M. Includes
;==============================================================
.include "..\lib\Useful functions.inc"
.include "..\lib\SAM_Interpreter.asm"
.include "..\lib\math.asm"
.include "..\lib\joypad.asm"
.include "..\lib\sam_jumptable.asm"
.include "..\lib\sam_instructions.asm"
.include "..\lib\sprite.asm"
.include "..\lib\resource.asm"
.include "..\lib\Phantasy Star decompressors.inc"

.section "PSGMOD Code" FREE
	.include "..\lib\psgmod.inc"
	.include "..\lib\psgmod.asm"
.ends

.section "Data" FREE
    PaletteData:
    .db $00,$3f ; Black, White
    PaletteDataEnd:

	FontData:
	  .include "..\lib\BBC Micro font.inc"
.ends

.include "Script.list.txt.inc"
.include "Music.list.txt.inc"

.ramsection "FORTH Variables" slot 3
	Code_SP	dw
.ends

.slot 0
.include "Images.txt.inc"

.macro FORTH_FETCH_BC
	ld a, (bc)
	ld l, a
	inc bc
	ld a, (bc)
	ld h, a
	inc bc
.endm

.macro FORTH_PUSH_CSP
	ld hl, (Code_SP)
	dec hl
	ld (hl), c
	dec hl
	ld (hl), b
	ld (Code_SP), hl
.endm

.macro FORTH_POP_CSP
	ld hl, (Code_SP)
	ld b, (hl)
	inc hl
	ld c, (hl)
	inc hl
	ld (Code_SP), hl
.endm

.macro FORTH_DO_LIST
	call Forth_DoList
.endm

.SECTION "Main whatever" FREE

Forth_DoList:	; Presumes you arrived here through a call
	FORTH_PUSH_CSP
	pop bc	; Again, presumes you arrived here through a call
	
	; Falls through to Forth_NextStep

Forth_NextStep:
	FORTH_FETCH_BC
	jp (hl)
	
Forth_Exit:
	FORTH_POP_CSP
	jp Forth_NextStep

Word_Zero:
	ld hl, 0
	push hl
	jp Forth_NextStep

Word_DoNumber:
	FORTH_FETCH_BC
	push hl
	jp Forth_NextStep

Word_Jump:
	FORTH_FETCH_BC
	ld b, h
	ld c, l
	jp Forth_NextStep

Word_Display_Image:
	SAM_POP_DATA_HL			; HL receives image number
	push bc
	call SAM_DisplayImage	
	pop bc
	jp Forth_NextStep

Word_Infinite_Loop:	
	halt
	jp Word_Infinite_Loop

Forth_Main:
	ld sp, DATA_STACK_TOP
	ld hl, CODE_STACK_TOP
	ld (Code_SP), hl
	jp Forth_Code
	
Forth_Code:
	FORTH_DO_LIST
	.dw Forth_Code_1, Word_Infinite_Loop

Forth_Code_1:
	FORTH_DO_LIST
	.dw Word_Jump, Forth_Code_1_Branch, Word_DoNumber, 0, Word_Display_Image, Forth_Exit
Forth_Code_1_Branch:
	.dw Word_DoNumber, 1, Word_Display_Image, Forth_Exit

.ENDS

.SLOT 2
.section "PSGMOD Vibrato" SUPERFREE
PSGMOD_VIBRATO_TABLES:
  .incbin "..\lib\psgmod.vib"
.ends

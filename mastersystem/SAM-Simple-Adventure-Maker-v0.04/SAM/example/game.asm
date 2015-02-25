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

.slot 0
.include "Images.txt.inc"

.SLOT 2
.section "PSGMOD Vibrato" SUPERFREE
PSGMOD_VIBRATO_TABLES:
  .incbin "..\lib\psgmod.vib"
.ends

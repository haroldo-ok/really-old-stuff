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
.sdsctag 0.01,"ZX Basic - SMS","Version 0.01 - First release","Haroldo O. Pinheiro"


.include "../lib/wla/boot.inc"


;==============================================================
; Includes
;==============================================================
.include "../lib/wla/Useful functions.inc"
.include "../lib/wla/BBC Micro font.inc"
.include "../lib/wla/sprite.inc"
.include "test.wla.inc"

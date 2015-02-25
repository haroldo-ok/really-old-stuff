.section "Open Resource Routine" free
;===========================================================
; Opens a stream for reading
; hl	: Resource number
; de	: Resource table base address (must be on bank 0)
; b		: Slot number
; Return:
; hl	: Resource pointer
; bc	: Resource size
;===========================================================
SAM_Resource_Open:
;===========================================================
	push ix

		; Calculates the base address
		add hl, hl
		ex de, hl
		add hl, de
		add hl, de
		add hl, de
		
		; Makes IX point to the base address
		push hl
		pop ix
		
		; Calculates address of the bankswitching port
	    ld h, $FF
	    ld a, b
	    add a, $FD
	    ld l, a				    

		; Selects the correct bank
	    ld a, (ix + SAM_Resource.bank)
	    ld (hl), a
		
		; Gets base address
	    ld a, (ix + SAM_Resource.address)
		ld l, a
	    ld a, (ix + SAM_Resource.address + 1)
		and $3F							; Clears top two bits
		ld h, a
		
		; Calculates Z80 address taking into consideration the desired slot
	    ld a, b
	    rrca
	    rrca				; Equivalent to A = B << 6
	    or h				
	    ld h, a				; HL = (addr & 0x3FFF) | (B << 14)
	
		; Gets resource size
	    ld c, (ix + SAM_Resource.res_size)
	    ld b, (ix + SAM_Resource.res_size + 1)
	
	pop ix
	ret
.ends
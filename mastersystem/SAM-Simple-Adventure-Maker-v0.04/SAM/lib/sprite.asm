.RAMSECTION "Sprite Data" SLOT 3
hw_sprites_y	dsb		64
hw_sprites_xc	dsw		64
.ENDS

.SECTION "Sprite Update Routine" FREE
UpdateSprites:
    ;==============================================================
    ; Sets the sprites' positions/attributes
    ;==============================================================
	;vdp set addr (Y table)
	xor	a
	out	($bf), a
	ld	a, $7f
	out	($bf), a
	
	; Outputs Y table
	ld	hl, hw_sprites_y
	ld	bc, $40BE	; 64 bytes to $be
	otir			; Output table

	;vdp set addr (X/Tile table)
	ld	a, $80
	out	($bf), a
	ld	a, $7f
	out	($bf), a
	
	; Outputs XA table
	ld	hl, hw_sprites_xc
	ld	bc, $80BE	; 128 bytes to $be
	otir			; Output table
    ret
.ENDS
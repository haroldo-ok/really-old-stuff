.ramsection "Joypad Variables" slot 3
	joypad_1	db
	joypad_2	db
.ends

.section "Read both joypads" free
ReadJoypads:
    ; Joypad reading
    in a, ($DD)
    ld h, a
    in a, ($DC)
    ld l, a

    ; Joypad 1
    cpl
    and $7F
    ld (joypad_1), a
    
    ; Joypad 2
    add hl, hl
    add hl, hl		; Shifts top two bits from l (U/D Joypad 2) to h.
    ld a, h
    cpl
    and $7F
    ld (joypad_2), a

	ret
.ends
	
	
.section "Wait for button press" free
WaitForButton:
--
	ld a, (joypad_1)
	and $30			; Only considers the fire buttons
	jr z, --
	
---
	ld a, (joypad_1)
	or a
	jr nz, ---
	
	ret

.ends

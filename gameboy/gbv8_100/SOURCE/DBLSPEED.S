;-----------------------------------------------------------------------------

  .include	"../../lib/global.s"

.area _CODE

;-----------------------------------------------------------------------------
; Retrieves the current speed
;-----------------------------------------------------------------------------

_CurrentSpeed::
	ldh	a, (0x4D)
	rlca			;bit7->bit0
	and	a, #1
	ld	e, a		;return
ret

;-----------------------------------------------------------------------------
; Switches between normal and double speed
;-----------------------------------------------------------------------------

_SwitchSpeed::
	di

	ld	hl, #0xFFFF
	ld	a, (hl)		;save EI
	push af
	xor a, a
	ld	(hl), a		;clear EI
	ld	(0xFFF0), a	;clear IF

	ld	a, #0x30
	ld	(0x00), a	;P1

	ld	a, #1
	ldh (0x4D), a	;KEY1
	stop
	nop

	pop	af
	ld	(hl), a		;restore EI

	ei
ret

;-----------------------------------------------------------------------------

  .globl .int_0x40
  .globl .int_0x48

_remove_irqs::
  ld	hl, #.int_0x40
  xor	a, a
  ld	(hl+), a
  ld	(hl+), a
  ld	(hl+), a
  ld	(hl), a
  ld	hl, #.int_0x48
  ld	(hl+), a
  ld	(hl+), a
  ld	(hl+), a
  ld	(hl), a
  ret

;----------------------------------------------------------------------------;

_wait_vbl_done2::
  ldh	a, (.ly)
  cp	a, #144
  jr	nz, _wait_vbl_done2
  ret
  
;----------------------------------------------------------------------------;

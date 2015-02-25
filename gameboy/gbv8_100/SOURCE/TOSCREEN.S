	.include "..\..\lib\global.s"
	.area _BSS
	.globl	_txl_video
_txl_video:
	.ds	2

	.area _CODE
	.globl _toscreen_64_32
_toscreen_64_32::
	ld	de, #_chip8_display
	ld	hl, #0x9000
	ld	c, 	#16

.char_col:
	push bc
	push de
	ld	b,	#32

.char_row:
	ld	c,	#0x00

	ld	a,	(de)				; Primeiro pixel
	or	a
	jr	z,	1$
	ld	a,	c
	or	a,	#0xC0
	ld	c,	a
1$:
	inc	de

	ld	a,	(de)				; Segundo pixel
	or	a
	jr	z,	2$
	ld	a,	c
	or	a,	#0x30
	ld	c,	a
2$:
	inc	de

	ld	a,	(de)				; Terceiro pixel
	or	a
	jr	z,	3$
	ld	a,	c
	or	a,	#0x0C
	ld	c,	a
3$:
	inc	de

	ld	a,	(de)				; Quarto pixel
	or	a
	jr	z,	4$
	ld	a,	c
	or	a,	#0x03
	ld	c,	a
4$:
	inc	de

10$:
	ldh	a,	(.STAT)				; Checa se j  pode escrever no v¡deo
	bit	1,a
	jr	nz,	10$

	ld	a,	c
	ld	(hl+), 	a				; Plota os pixels
	ld	(hl+), 	a
	ld	(hl+),	a
	ld	(hl+),	a

	ld	a,	e					; Pula para a linha de baixo
	add	a,	#60
	jr	nc,	5$
	inc	d
5$:
	ld	e,	a

	dec	b						; Checa se j  desenhou todas as linhas
	ld	a, b
	or	a
	jr	nz,	.char_row

	pop	de
	ld	a,	e					; Atualiza DE
	add	a,	#4
	jr	nc, 20$
	inc	d
20$:
	ld	e,	a

	pop bc
	dec	c						; Checa se j  desenhou todas as colunas
	ld	a,	c
	or	a
	jr	nz,	.char_col
	ret

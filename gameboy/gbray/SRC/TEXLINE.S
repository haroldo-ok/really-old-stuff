	.area _BSS
	.globl	_txl_video
_txl_video:
	.ds	2
	.globl	_txl_scale
_txl_scale:
	.ds	1
	.globl	_txl_tex
_txl_tex:
	.ds	2
	.globl	_txl_mask
_txl_mask:
	.ds	1
	.area _DATA
	.globl _scale_table
	.include "texdata.inc"

	.area _CODE
	.globl	_texline
_texline::
	LD	A, (_txl_tex+1)
	LD	B, A		; B cont‚m a textura

	XOR A
	LD	D, A
	LD	A, (_txl_scale)
	ADD A
	JR	NC, 1$
	INC D
1$: LD	E, A		; DE ser  usado como auxiliar no c lculo da posi‡Æo na tabela

	LD	HL, #_scale_table
	ADD	HL, DE
	ADD	HL, DE
	ADD	HL, DE		; Calcula a posi‡Æo da entrada na tebela
	LD	D, (HL)		; D cont‚m o passo atual
	INC HL

	LD	C, (HL)		; C cont‚m, temporariamente, o valor do Shift da textura
2$:	LD	A, C
	OR	A
	JR	Z, 3$
	CALL _shift_texture ; Desloca os bits da textura para a esquerda
	DEC	C
	JR	2$
3$: INC HL

	LD	C, (HL)		; C cont‚m a altura da coluna a ser desenhada
	INC HL

	LD	E, (HL)		; E cont‚m o valor do incremento de passo
	PUSH DE
	INC HL

	LD	E, (HL)
	INC HL
	LD	D, (HL)		; DE cont‚m, temporariamente, o offset inicial da mem¢ria
	LD	HL, #_txl_video
	LD	A, (HL+)
	LD	H, (HL)
	LD	L, A
	ADD HL, DE		; HL agora aponta para o endere‡o inicial

	POP DE			; DE cont‚m passo atual e incremento de passo

4$:	LD	A, C
	OR	A
	JR	Z, 5$

	LD	A, D
	ADD	E
	LD	D, A		; Atualiza o valor do passo
	JR	NC, 6$		; Houve carry?
	CALL _shift_texture ; Se houve, desloca a textura
6$:

	LD	A, D
	ADD	E
	LD	D, A		; Atualiza o valor do passo
	JR	NC, 8$		; Houve carry?
	CALL _shift_texture ; Se houve, desloca a textura
8$:

	LD	A, B
	ADD	A
	JR	NC, 7$		; Bit 7 = 0?
	LD	A, (_txl_mask)		; Se Bit 7 = 1, plota o pixel
	OR	(HL)
	LD	(HL), A
7$:	INC	HL
	INC HL 			; Pr¢ximo endere‡o

	DEC C
	JR	4$
5$:
	ret

	.globl	_cleantexline
_cleantexline::
	PUSH HL
	LD	HL, #_txl_video
	LD	A, (HL+)
	LD	H, (HL)
	LD	L, A
	LD	C, #<128
	LD	A, (_txl_mask)
	CPL				; Cria uma m scara inversa
	LD	B, A

1$:	LD	A, (HL)
	AND	B
	LD	(HL+), A
	INC	HL
	DEC	C
	LD	A, C
	OR	A
	JR	NZ, 1$
	POP HL

	RET

_shift_texture:
	LD	A, (_txl_tex)
	ADD	A
	LD	(_txl_tex), A
	LD	A, (_txl_tex+1)
	ADC	A
	LD	(_txl_tex+1), A
	LD	B, A
	RET

	.globl	_texline_maskout
_texline_maskout::
	LD	A, (_txl_tex+1)
	LD	B, A		; B cont‚m a textura

	XOR A
	LD	D, A
	LD	A, (_txl_scale)
	ADD A
	JR	NC, 1$
	INC D
1$: LD	E, A		; DE ser  usado como auxiliar no c lculo da posi‡Æo na tabela

	LD	HL, #_scale_table
	ADD	HL, DE
	ADD	HL, DE
	ADD	HL, DE		; Calcula a posi‡Æo da entrada na tebela
	LD	D, (HL)		; D cont‚m o passo atual
	INC HL

	LD	C, (HL)		; C cont‚m, temporariamente, o valor do Shift da textura
2$:	LD	A, C
	OR	A
	JR	Z, 3$
	CALL _shift_texture ; Desloca os bits da textura para a esquerda
	DEC	C
	JR	2$
3$: INC HL

	LD	C, (HL)		; C cont‚m a altura da coluna a ser desenhada
	INC HL

	LD	E, (HL)		; E cont‚m o valor do incremento de passo
	PUSH DE
	INC HL

	LD	E, (HL)
	INC HL
	LD	D, (HL)		; DE cont‚m, temporariamente, o offset inicial da mem¢ria
	LD	HL, #_txl_video
	LD	A, (HL+)
	LD	H, (HL)
	LD	L, A
	ADD HL, DE		; HL agora aponta para o endere‡o inicial

	POP DE			; DE cont‚m passo atual e incremento de passo

4$:	LD	A, C
	OR	A
	JR	Z, 5$

	LD	A, D
	ADD	E
	LD	D, A		; Atualiza o valor do passo
	JR	NC, 6$		; Houve carry?
	CALL _shift_texture ; Se houve, desloca a textura
6$:

	LD	A, D
	ADD	E
	LD	D, A		; Atualiza o valor do passo
	JR	NC, 8$		; Houve carry?
	CALL _shift_texture ; Se houve, desloca a textura
8$:

	LD	A, B
	ADD	A
	JR	NC, 7$		; Bit 7 = 0?
	LD	A, (_txl_mask)		; Se Bit 7 = 1, limpa o pixel
	CPL						; Inverte a m scara
	AND	(HL)
	LD	(HL), A
7$:	INC	HL
	INC HL 			; Pr¢ximo endere‡o

	DEC C
	JR	4$
5$:
	ret


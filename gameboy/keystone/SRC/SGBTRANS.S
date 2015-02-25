	.area   _CODE

_sgb_transfer::
	LDA	HL,3(SP)	; Skip return address and registers
	LD	B,(HL)		; BC = rgb_data
	DEC	HL
	LD	C,(HL)
	PUSH BC
	POP  HL

	LD	A,(HL)		; Top of command data
	AND	#0x03
	RET	Z
	LD	B,A		; Number of translated packet
	LD	C,#0x00		; Lower part of #FF00
1$:
	PUSH	BC
	XOR	A		; Start to write
	LDH	(C),A
	LD	A,#0x30
	LDH	(C),A
	LD	B,#0x10		; Set counter to transfer 16 byte
2$:	LD	E,#0x08		; Set counter to transfer 8 bit
	LD	A,(HL+)
	LD	D,A

3$:
	BIT	0,D
	LD	A,#0x10		; P14 = high, P15 = low  (output "1")
	JR	NZ,4$
	LD	A,#0x20		; P14 = low,  P15 = high (output "0")
4$:
	LDH	(C),A
	LD	A,#0x30		; P14 = high, P15 = high
	LDH	(C),A
	RR	D		; Shift 1 bit to right
	DEC	E
	JR	NZ,3$

	DEC	B
	JR	NZ,2$
	LD	A,#0x20		; 129th bit "0" output
	LDH	(C),A
	LD	A,#0x30
	LDH	(C),A

	POP	BC
	DEC	B
	RET	Z
	CALL	.wait4		; Software wait for about 4 frames
	JR	1$

.wait4:
	LD	DE,#7000
.1$:
	NOP			; 1 +
	NOP			; 1 +
	NOP			; 1 +
	DEC	DE		; 2 +
	LD	A,D		; 1 +
	OR	E		; 1 +
	JR	NZ,.1$		; 3 = 10 cycles
	RET

	.area   _CODE

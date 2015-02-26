.section "S.A.M. Instructions" free

;================================================
SAM_INS_QUOTATION_MARK:		; '"' Write string to char buffer
;================================================
QuotationMarkLoop:
	SAM_FETCH_BYTE
	cp '"'					; End of string?
	jr z, QuotationMarkLoopEnd
	
	cp '\'
	jr nz, QuotationMarkLoop_NormalChar
	
QuotationMarkLoop_SpecialChar:
	SAM_FETCH_BYTE
	
	cp '#'
	jr nz, ++
	
	; Outputs a number taken from the top of the stack
	SAM_POP_DATA_HL
	call SAM_NumberToBuffer
	jr QuotationMarkLoop
	
++	cp 'n'
	jr nz, +++
	
	; Outputs a linefeed
	ld a, 10
	call SAM_NumberToBuffer
	jr QuotationMarkLoop

+++	cp '\'
	jr nz, ++++

	; Outputs a backslash
	call SAM_NumberToBuffer
	jr QuotationMarkLoop

++++
	jr QuotationMarkLoop

QuotationMarkLoop_NormalChar:
	call SAM_CharToBuffer

	jr QuotationMarkLoop
	
QuotationMarkLoopEnd:
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_LEFT_BRACKET:		; '['
;================================================
	; Checks top of the stack
	SAM_POP_DATA_HL
	ld a, h
	or l
	jp nz, LeftBracket_End

	; If top of the stack is zero, jumps to matching ']'
	exx
	
	ld c, 1
	
LeftBracketLoop:
	inc hl
	ld a, (hl)
	
	cp '['
	jr nz, LeftBracketLoop_notLB
	
	inc c
	jr LeftBracketLoop
	
LeftBracketLoop_notLB:
	cp ']'
	jr nz, LeftBracketLoop
	
	dec c
	ld a, c
	or a
	jr nz, LeftBracketLoop

	inc hl
	
	exx

LeftBracket_End:
	SAM_NEXT_INSTRUCTION
	
	
;================================================
SAM_INS_RIGHT_BRACKET:		; ']'
;================================================
	; Checks top of the stack
	SAM_POP_DATA_HL
	ld a, h
	or l
	jp z, RightBracket_End

	; If top of the stack is not zero, jumps to matching '['
	exx
	
	ld c, 1
	dec hl
	
RightBracketLoop:
	dec hl
	ld a, (hl)
	
	cp ']'
	jr nz, RightBracketLoop_notRB
	
	inc c
	jr RightBracketLoop
	
RightBracketLoop_notRB:
	cp '['
	jr nz, RightBracketLoop
	
	dec c
	ld a, c
	or a
	jr nz, RightBracketLoop

	inc hl
	
	exx
	
RightBracket_End:
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_DIGIT_0:		; '0'
SAM_INS_DIGIT_1:		; '1'
SAM_INS_DIGIT_2:		; '2'
SAM_INS_DIGIT_3:		; '3'
SAM_INS_DIGIT_4:		; '4'
SAM_INS_DIGIT_5:		; '5'
SAM_INS_DIGIT_6:		; '6'
SAM_INS_DIGIT_7:		; '7'
SAM_INS_DIGIT_8:		; '8'
SAM_INS_DIGIT_9:		; '9'
;================================================
	exx
	;  Sets lower bit of C' (meaning: there's a number on the buffer)
	ld a, c
	or $01
	ld c, a
	
	ld a, e
	exx
	
	ld l, a 			; L= E'
	
	exx
	ld a, d
	exx
	ld h, a				; H = D'  (therefore, HL = DE')

	push bc
	ld de, 10
	call Multiply		; HL *= 10
	pop bc

	ld a, c				; A receives last instruction
	add a, -'0'
	ld d, 0
	ld e, a				; DE = digit
	
	add hl, de
	
	ld a, l
	exx
	ld e, a				; E' = L
	exx
	
	ld a, h
	exx
	ld d, a				; D' = H
	exx
	
	; At this point, we have: HL' = HL' * 10 + digit
		
	SAM_NEXT_INSTRUCTION


;================================================
SAM_INS_PLUS_SIGN:		; '+' Sum
;================================================
	SAM_POP_DATA_DE
	SAM_POP_DATA_HL
	add hl, de
	SAM_PUSH_HL_DATA
	SAM_NEXT_INSTRUCTION

;================================================
SAM_INS_HYPHEN:			; '-' Subtraction
;================================================
	SAM_POP_DATA_DE
	SAM_POP_DATA_HL
    xor a		; Just to clear the carry flag
    sbc hl, de
	SAM_PUSH_HL_DATA
	SAM_NEXT_INSTRUCTION

;================================================
SAM_INS_ASTERISK:		; '*' Multiplication
;================================================
	SAM_POP_DATA_DE
	SAM_POP_DATA_HL
	call Multiply
	SAM_PUSH_HL_DATA
	SAM_NEXT_INSTRUCTION

;================================================
SAM_INS_SLASH:			; '/' Division
;================================================
	SAM_POP_DATA_HL
	SAM_POP_DATA_DE		; Note  that they're popped on reverse order
	call Divide
	SAM_PUSH_HL_DATA
	SAM_NEXT_INSTRUCTION
	
;================================================
SAM_INS_BACKSLASH:		; '\' Modulus
;================================================
	SAM_POP_DATA_HL
	SAM_POP_DATA_DE		; Note  that they're popped on reverse order
	call Divide
	SAM_PUSH_DE_DATA
	SAM_NEXT_INSTRUCTION


;================================================
SAM_INS_EQUALS:		; '=' Equals
;================================================
	SAM_POP_DATA_DE
	SAM_POP_DATA_HL
	
	ld a, d
	cp h
	jr nz, Equals_Not
	
	ld a, e
	cp l
	jr nz, Equals_Not
	
Equals_Do:
	ld hl, $FFFF
	jr Equals_Done

Equals_Not:
	ld hl, 0

Equals_Done:
	SAM_PUSH_HL_DATA
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_LESS_THAN:		; '<' Less than
;================================================
	SAM_POP_DATA_HL
	SAM_POP_DATA_DE
    
    call SAM_CP_DE_HL
    call SAM_Set_Carry_HL ; If carry is set, HL > DE
    
    SAM_PUSH_HL_DATA
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_GREATER_THAN:		; '>' More than
;================================================
	SAM_POP_DATA_DE
	SAM_POP_DATA_HL
    
    call SAM_CP_DE_HL
    call SAM_Set_Carry_HL ; If carry is set, HL > DE
    
    SAM_PUSH_HL_DATA
	SAM_NEXT_INSTRUCTION


;================================================
SAM_INS_SPACE:		; ' '
;================================================
	; Don't do anything
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_UPPERCASE_A:		; 'A'
SAM_INS_UPPERCASE_B:		; 'B'
SAM_INS_UPPERCASE_C:		; 'C'
SAM_INS_UPPERCASE_D:		; 'D'
SAM_INS_UPPERCASE_E:		; 'E'
SAM_INS_UPPERCASE_F:		; 'F'
SAM_INS_UPPERCASE_G:		; 'G'
SAM_INS_UPPERCASE_H:		; 'H'
SAM_INS_UPPERCASE_I:		; 'I'
SAM_INS_UPPERCASE_J:		; 'J'
SAM_INS_UPPERCASE_K:		; 'K'
SAM_INS_UPPERCASE_L:		; 'L'
SAM_INS_UPPERCASE_M:		; 'M'
SAM_INS_UPPERCASE_N:		; 'N'
SAM_INS_UPPERCASE_O:		; 'O'
SAM_INS_UPPERCASE_P:		; 'P'
SAM_INS_UPPERCASE_Q:		; 'Q'
SAM_INS_UPPERCASE_R:		; 'R'
SAM_INS_UPPERCASE_S:		; 'S'
SAM_INS_UPPERCASE_T:		; 'T'
SAM_INS_UPPERCASE_U:		; 'U'
SAM_INS_UPPERCASE_V:		; 'V'
SAM_INS_UPPERCASE_W:		; 'W'
SAM_INS_UPPERCASE_X:		; 'X'
SAM_INS_UPPERCASE_Y:		; 'Y'
SAM_INS_UPPERCASE_Z:		; 'Z'
;================================================
	ld a, c
	add a, -'A'
	
	SAM_PUSH_A_DATA

	SAM_NEXT_INSTRUCTION


;================================================
SAM_INS_PERIOD:		; '.' Set variable
;================================================
	SAM_POP_DATA_HL			; HL receives address
	SAM_POP_DATA_DE			; DE receives data
	call SAM_Set_DE_into_HL
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_COLON:		; ':' Get variable
;================================================
	SAM_POP_DATA_HL			; HL receives address
	call SAM_Get_DE_from_HL
	SAM_PUSH_DE_DATA		; Push value into stack
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_TILDE:		; '~'	Line comment
;================================================
TildeLoop:
	SAM_FETCH_BYTE
	cp 10					; Line feed?
	jr z, TildeLoopEnd
	cp 13					; Carriage return?
	jr z, TildeLoopEnd
	
	jr TildeLoop
	
TildeLoopEnd:
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_QUESTION_MARK:		; '?' Menu from string buffer
;================================================
	call SAM_DisplayMenu
	SAM_PUSH_HL_DATA
	SAM_NEXT_INSTRUCTION


;================================================
SAM_INS_EXCLAMATION_POINT:	; '!' Outputs contents from string buffer
;================================================
	call SAM_DisplayBuffer
	SAM_NEXT_INSTRUCTION


;================================================
SAM_INS_LOWERCASE_I:		; 'i' Displays an image
;================================================
	SAM_POP_DATA_HL			; HL receives image number
	call SAM_DisplayImage
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_LOWERCASE_M:		; 'm' Plays a music
;================================================
	SAM_POP_DATA_HL			; HL receives music number
	call SAM_PlayMusic
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_LOWERCASE_J:		; 'j' Jump to program
;================================================
	SAM_POP_DATA_HL			; HL receives program number
	jp SAM_Exec
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_LOWERCASE_C:		; 'c' Call subroutine
;================================================
	SAM_POP_DATA_HL			; HL receives program number
	jp SAM_Call
	SAM_NEXT_INSTRUCTION

	
;================================================
SAM_INS_DOLLAR_SIGN:		; '$' Returns from subroutine
;================================================
	SAM_RETURN


SAM_INS_NUMBER_SIGN:		; '#'
SAM_INS_PERCENT_SIGN:		; '%'
SAM_INS_AMPERSAND:		; '&'
SAM_INS_APOSTROPHE:		; '''
SAM_INS_LEFT_PARENTHESIS:		; '('
SAM_INS_RIGHT_PARENTHESIS:		; ')'
SAM_INS_COMMA:		; ','
SAM_INS_SEMICOLON:		; ';'
SAM_INS_COMMERCIAL_AT:		; '@'
SAM_INS_CIRCUMFLEX:		; '^'
SAM_INS_UNDERLINE:		; '_'
SAM_INS_GRAVE_ACCENT:		; '`'
SAM_INS_LOWERCASE_A:		; 'a'
SAM_INS_LOWERCASE_B:		; 'b'
SAM_INS_LOWERCASE_D:		; 'd'
SAM_INS_LOWERCASE_E:		; 'e'
SAM_INS_LOWERCASE_F:		; 'f'
SAM_INS_LOWERCASE_G:		; 'g'
SAM_INS_LOWERCASE_H:		; 'h'
SAM_INS_LOWERCASE_K:		; 'k'
SAM_INS_LOWERCASE_L:		; 'l'
SAM_INS_LOWERCASE_N:		; 'n'
SAM_INS_LOWERCASE_O:		; 'o'
SAM_INS_LOWERCASE_P:		; 'p'
SAM_INS_LOWERCASE_Q:		; 'q'
SAM_INS_LOWERCASE_R:		; 'r'
SAM_INS_LOWERCASE_S:		; 's'
SAM_INS_LOWERCASE_T:		; 't'
SAM_INS_LOWERCASE_U:		; 'u'
SAM_INS_LOWERCASE_V:		; 'v'
SAM_INS_LOWERCASE_W:		; 'w'
SAM_INS_LOWERCASE_X:		; 'x'
SAM_INS_LOWERCASE_Y:		; 'y'
SAM_INS_LOWERCASE_Z:		; 'z'
SAM_INS_LEFT_BRACE:		; '{'
SAM_INS_PIPE:		; '|'
SAM_INS_RIGHT_BRACE:		; '}'
	SAM_NEXT_INSTRUCTION

.ends ; S.A.M. Instructions
;==============================================================
; WLA-DX banking setup
;==============================================================
;.memorymap
;	defaultslot     0
	; rom area
;	slotsize        $4000
;	slot            0       $0000
;	slot            1       $4000
;	slot            2       $8000
	; ram area
;	slotsize        $2000
;	slot            3       $C000
;	slot            4       $E000
;.endme

;.rombankmap
;	bankstotal 2
;	banksize $4000
;	banks 2
;.endro

.struct SAM_Proc_Info
	data_stack		dsw		32
	local_vars		dsw		26
.endst

.struct SAM_String_Buffer
	buffer		ds		512
	top			dw
.endst

.struct SAM_Resource
	slot		db
	bank		db
	address		dw
	res_size	dw
.endst

.struct SAM_Picture_Header
	tileset		dw
	map			dw
	palette		dw
.endst

.ramsection "Variables" slot 3
	SAM_Processes		instanceof	SAM_Proc_Info
	SAM_Buffer			instanceof	SAM_String_Buffer
.ends

.DEFINE PSGMOD_START_ADDRESS     $DC00
.DEFINE PSGMOD_SUPPORT_GG_STEREO 0
.DEFINE PSGMOD_PSG_PORT          $7F

.macro SAM_PUSH_SLOT_1
	ld a, ($FFFE)			; Load bank # at slot 1
	ld d, 0
	ld e, a
	push de					; Pushes bank #
.endm

.macro SAM_POP_SLOT_1
	pop de					; Pops bank #
	ld a, e
	ld ($FFFE), a			; Restores bank #
.endm

.macro SAM_PUSH_SLOT_2
	ld a, ($FFFF)			; Load bank # at slot 2
	ld d, 0
	ld e, a
	push de					; Pushes bank #
.endm

.macro SAM_POP_SLOT_2
	pop de					; Pops bank #
	ld a, e
	ld ($FFFF), a			; Restores bank #
.endm

;==============================================================
; Boot section
;==============================================================
.bank 0 slot 0
.org $0000
.section "Boot section" force
    di              ; disable interrupts
    im 1            ; Interrupt mode 1
    jp main         ; jump to main program
.ends

;==============================================================
; VBL Handler
;==============================================================
.org $0038
.section "VBL handler" force
	jp VBLHandlerImpl
.ends

.section "VBL handler implementation" free
VBLHandlerImpl:
	push af
	push hl
	push de
	push bc
	SAM_PUSH_SLOT_1
	SAM_PUSH_SLOT_2
	
;	call UpdateSprites
	call ReadJoypads
	call PSGMOD_Play

	; Finalization of current interrupt
    in a,($bf)		; Read VDP status to acknowledge interrupt.

	SAM_POP_SLOT_2
	SAM_POP_SLOT_1
	pop bc
	pop de
	pop hl
	pop af
	
    ei
    reti
.ends

;==============================================================
; Pause button handler
;==============================================================
.org $0066
.section "Pause button handler" force
    ; Do nothing
    retn
.ends

;==============================================================
; Main program
;==============================================================
.section "Main program" free
main:
    ld sp, $dff0

    call DefaultInitialiseVDP
    call ClearVRAM

    ; Load palette
    ld hl,PaletteData               ; data
    ld b,PaletteDataEnd-PaletteData ; size
    ld c,$00                        ; index to load at
    call LoadPalette

    ; Load sprite palette
    ld hl,PaletteData               ; data
    ld b,PaletteDataEnd-PaletteData ; size
    ld c,$10                        ; index to load at
    call LoadPalette

    ; Load font
    ld hl,0                         ; tile index to load at
    ld ix,FontData                  ; data
    ld bc,96                        ; number of tiles
    ld d,1                          ; bits per pixel
    call LoadTiles

    ; Main screen turn on!
    ld a,%11100100
;          |||| |`- Zoomed sprites -> 16x16 pixels
;          |||| `-- Doubled sprites -> 2 tiles per sprite, 8x16
;          |||`---- 30 row/240 line mode
;          ||`----- 28 row/224 line mode
;          |`------ VBlank interrupts
;          `------- Enable display
    out ($bf),a
    ld a,$81
    out ($bf),a

	ei
	
	
	jp Forth_Main
	

	; Starts main S.A.M. Program
	call SAM_Start
    
    ; Infinite loop to stop program
    Loop:
         jp Loop
		 
.macro SAM_NEXT_INSTRUCTION
	jp SAM_Fetch
.endm
		 
.macro SAM_FETCH_BYTE
	exx
	ld a, (hl)
	inc hl
	exx
.endm

.macro SAM_PUSH_HL_DATA
	call SAM_Push_HL_Data
.endm

.macro SAM_PUSH_DE_DATA
	call SAM_Push_DE_Data
.endm

.macro SAM_PUSH_A_DATA
	call SAM_Push_A_Data
.endm

.macro SAM_POP_DATA_HL
	pop hl
;	call SAM_Pop_Data_HL
.endm

.macro SAM_POP_DATA_DE
	pop de
;	call SAM_Pop_Data_DE
.endm

.macro SAM_RETURN
	jp SAM_Fetch_End
.endm

;================================================
SAM_Push_HL_Data:
;================================================
	ld a, l
	ld (ix+0), a
	inc ix
	ld a, h
	ld (ix+0), a
	inc ix
	ret

;================================================
SAM_Push_DE_Data:
;================================================
	ld (ix+0), e
	inc ix
	ld (ix+0), d
	inc ix
	ret

;================================================
SAM_Push_A_Data:
;================================================
	ld (ix+0), a
	inc ix
	xor a
	ld (ix+0), a
	inc ix
	ret

;================================================
SAM_Pop_Data_HL:
;================================================
	dec ix
	ld a, (ix+0)
	ld h, a
	dec ix
	ld a, (ix+0)
	ld l, a
	ret

;================================================
SAM_Pop_Data_DE:
;================================================
	dec ix
	ld d, (ix+0)
	dec ix
	ld e, (ix+0)
	ret
	
;================================================
SAM_CP_DE_HL:
;================================================
; Compares de with hl
; Taken from Z88DK
; signed compare of DE and HL
;   carry is sign of difference 
;          [set => DE < HL]
;   zero is zero/non-zero
;================================================
	ld	a, h
	add	a, $80
	ld	b,a
	ld	a,d
	add	a, $80
	cp	b
	jp	nz, +
	ld	a, e
	cp	l
+	
	ret

;================================================
SAM_Set_Carry_HL:
;================================================
; HL = (Carry flag ? 1 : 0)
;================================================
    jr nc, +		; If carry is not set, HL > DE is false
    
    ld hl, $FFFF	; Else, HL > DE
    jr ++
    
+   ld hl, 0

++  
	ret

;================================================
SAM_Map_HL_MEM:
;================================================
	ld bc, SAM_Processes.local_vars
	add hl, bc
	ret

;================================================
SAM_Set_DE_into_HL:
;================================================
	call SAM_Map_HL_MEM
	ld (hl), e
	inc hl
	ld (hl), d
	ret
	
;================================================
SAM_Get_DE_from_HL:
;================================================
	call SAM_Map_HL_MEM
	ld e, (hl)
	inc hl
	ld d, (hl)
	ret
	
;================================================
SAM_Dereference_HL:
;================================================
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ret

	
;================================================
SAM_CheckNumber:
;================================================
	; Checks if there's a number on the buffer
	exx
	ld a, c
	exx
	
	and $01		; If there's a number on the buffer, the lowest bit of C' will be set
	jr z, SAM_CheckNumber_NothingToDo
	
	ld a, c
	;  Checks if the instruction character is not a number 
	cp '9'+1
	jr nc, SAM_CheckNumber_DoIt ; More than '9'?
	cp '0'
	jr c, SAM_CheckNumber_DoIt ; Less than '0'?

	jr SAM_CheckNumber_NothingToDo
	
SAM_CheckNumber_DoIt:
	exx
	
	; Okay, push the number in DE'
	ld (ix+0), e
	inc ix
	ld (ix+0), d
	inc ix
	ld de, 0
	
	; Clears the flag in C'
	ld a, c
	and $FE		; Clears the lowest bit (meaning: no number on the buffer)
	ld c, a
	
	exx

SAM_CheckNumber_NothingToDo:
	ret
	
	
;================================================
SAM_CharToBuffer:
;================================================
	ld c, a				; Saves A

	;  Gets pointer to the end of the buffer
	ld hl, SAM_Buffer.top
	call SAM_Dereference_HL
	
	; Outputs to buffer
	ld a, c
	ld (hl), a
	
	; Increments pointer and saves it to memory
	inc hl
	ld e, l
	ld d, h
	ld hl, SAM_Buffer.top
	ld (hl), e
	inc hl
	ld (hl), d

	ret
	
	
;================================================
SAM_NumberToBuffer:
;================================================
	ld de, 0
	push de
	
SAM_NumberToBuffer_Loop:
	; First, splits the digits
	ex de, hl			; Dividend in DE
	ld hl, 10
	call Divide			;  Quotient in HL, remainder in DE
	
	ex de, hl			; Now, remainder in HL, quotient in DE
	ld bc, '0'
	add hl, bc
	push hl				; Push digit
	
	ex de, hl			; Quotient in HL

	ld a, h
	or l
	jr nz, SAM_NumberToBuffer_Loop
	
	; Now, outputs the digits
	pop hl				; First digit
SAM_NumberToBuffer_DigitLoop:
	ld a, l
	call SAM_CharToBuffer
	
	pop hl				; Next digit
	ld a, h
	or l
	jr nz, SAM_NumberToBuffer_DigitLoop

	ret
	

;================================================
SAM_ClearTextArea:
;================================================
	; Points to the start of the text box
    ld hl,TextArea_NameTableAddress
    call VRAMToHL
	
	ld bc, 32*6*2
	xor a
	
SAM_ClearTextArea_Loop:
	xor a
    out ($be),a
    out ($be),a

	dec bc
	ld a, b
	or c
	jr nz, SAM_ClearTextArea_Loop
	
	ret


;================================================
SAM_DisplayBuffer:
;================================================
	;  Gets pointer to the end of the buffer
	ld hl, SAM_Buffer.top
	call SAM_Dereference_HL

	; Places a string terminator at the end of the buffer
	xor a
	ld (hl), a
	
	;  Gets pointer to the beginning of the buffer
	ld hl, SAM_Buffer.buffer
	
	; Outputs the buffer contents
SAM_DisplayBuffer_Loop:
	push hl

		call SAM_ClearTextArea

		; Points to the start of the text box
	    ld hl,TextArea_NameTableAddress
	    call VRAMToHL
	
	pop hl
	
	ld b, TextArea_Height
SAM_DisplayBuffer_AreaLoop:
	; Skips left column
    xor a
    out ($be),a
    out ($be),a
	
	ld c, TextArea_Width
SAM_DisplayBuffer_LineLoop:
	ld a, (hl)
	inc hl
	or a
	jr z, SAM_DisplayBuffer_Loop_End	; Ends loop if char is ASCII 0
	
	cp ' '
	jr z, SAM_DisplayBuffer_Char_Display	; Space. No special treatment.

	; Checks for line feed
	cp 10								; Line feed
	jr z, SAM_DisplayBuffer_Char_Is_LF
	cp 13								; Carriage return
	jr z, SAM_DisplayBuffer_Char_Is_CR
	jr SAM_DisplayBuffer_Char_Not_LF
	
SAM_DisplayBuffer_Char_Is_CR:
	inc hl								; Skips a char (assumes it's LF (CRLF))
SAM_DisplayBuffer_Char_Is_LF:
	; Does the line break by filling the remainder of the line with blanks
	call SAM_DisplayBuffer_LF_Loop
	jr SAM_DisplayBuffer_EOL
	
SAM_DisplayBuffer_Char_Not_LF:

	; Your usual, everyday, printable char. Does the word wrapping.
	ld e, a						; Saves the char
	ld d, 0						; Inits counter (no words longer than 255, please.)
	
	push hl						; Saves current char pointer
SAM_DisplayBuffer_WordSize_Loop:
	ld a, (hl)
	cp (' ' + 1)
	jr c, SAM_DisplayBuffer_WordSize_Loop_End
	inc d
	inc hl
	jr SAM_DisplayBuffer_WordSize_Loop
SAM_DisplayBuffer_WordSize_Loop_End:
	pop hl						; Restores char pointer
	
	ld a, d
	cp TextArea_Width
	jr nc, SAM_DisplayBuffer_WordSize_TooBig	; Entire word is too big for a single line: let it be.
	
	dec hl

	ld a, c
	cp d
	jr c, SAM_DisplayBuffer_Char_Is_LF			; Word does not fit the line; do the line break 

	inc hl

SAM_DisplayBuffer_WordSize_TooBig:	
	ld a, e						; Restores the char
	
SAM_DisplayBuffer_Char_Display:
	; Outputs char
	add a, -32
    out ($be),a
    ld a, $08					; Use sprite palette
    out ($be),a

SAM_DisplayBuffer_Char_Done:
	; Line loop control
	dec c
	ld a, c
	or a
	jr nz, SAM_DisplayBuffer_LineLoop

SAM_DisplayBuffer_EOL:
	; Skips right column
    xor a
    out ($be),a
    out ($be),a

	; Text area loop control
	dec b
	ld a, b
	or a
	jr nz, SAM_DisplayBuffer_AreaLoop

	; Wait for button press
	call WaitForButton

	jr SAM_DisplayBuffer_Loop
SAM_DisplayBuffer_Loop_End:

	; Wait for button press
	call WaitForButton
	
	; Resets the buffer for next time
	call SAM_ResetBuffer
	ret

	; Just a subroutine for the above.
	; Does the line break by filling the remainder of the line with blanks
SAM_DisplayBuffer_LF_Loop:
	    xor a
	    out ($be),a
	    out ($be),a
		
		dec c
		ld a, c
		or a
	jr nz, SAM_DisplayBuffer_LF_Loop
	ret


;================================================
SAM_DisplayMenu:
;================================================
	;  Gets pointer to the end of the buffer
	ld hl, SAM_Buffer.top
	call SAM_Dereference_HL

	; Places a string terminator at the end of the buffer
	xor a
	ld (hl), a
	
	call SAM_ClearTextArea

	; Points to the start of the text box
    ld hl,TextArea_NameTableAddress
    call VRAMToHL

	;  Gets pointer to the beginning of the buffer
	ld hl, SAM_Buffer.buffer

	; Initializes option counter
	ld b, 0								; Menu item counter (Will go wrong if number of items is zero, but it doesn't matter.)

	; Outputs the buffer contents
SAM_DisplayMenu_Loop:
	; Skips left column
    xor a
    out ($be),a
    out ($be),a
    out ($be),a
    out ($be),a

	ld c, TextArea_Width
SAM_DisplayMenu_Line_Loop:
	ld a, (hl)
	or a
	jr z, SAM_DisplayMenu_Loop_End	; Ends loop if char is ASCII 0

	; Checks for line feed
	cp 10								; Line feed
	jr z, SAM_DisplayMenu_Char_Is_LF
	cp 13								; Carriage return
	jr z, SAM_DisplayMenu_Char_Is_CR
	jr SAM_DisplayMenu_Char_Not_LF
	
SAM_DisplayMenu_Char_Is_CR:
	inc hl								; Skips a char (assumes it's LF (CRLF))
SAM_DisplayMenu_Char_Is_LF:
	inc b								; Increments option count
	; Does the line break by filling the remainder of the line with blanks
	call SAM_DisplayBuffer_LF_Loop
	inc hl
	jr SAM_DisplayMenu_Loop
	
SAM_DisplayMenu_Char_Not_LF:
		
	add a, -32
	out ($be),a
    ld a, $08					; Use sprite palette
	out ($be),a

	inc hl
	dec c
	jr SAM_DisplayMenu_Line_Loop
SAM_DisplayMenu_Loop_End:

	ld c, 0
SAM_DisplayMenu_Select_Loop:
	; Shows the menu cursor
	ld a, c
	add a, a
	add a, a
	add a, a
	add a, 136
	ld (hw_sprites_y), a
	ld a, 8
	ld (hw_sprites_xc), a
	ld a, '>' - 32
	ld (hw_sprites_xc+1), a
	
	push bc
	call UpdateSprites
	pop bc
	
	ld a, (joypad_1)
	and $05
	jr z, SAM_DisplayMenu_Select_Loop_NotUp
SAM_DisplayMenu_Select_Loop_Up:
	; Up is pressed

	ld a, c
	or a
	jr z, SAM_DisplayMenu_Select_Loop_Wait_Release	; If it's at the top of the menu, don't do anything

	dec c											; Decrements menu index
	jr SAM_DisplayMenu_Select_Loop_Wait_Release	

SAM_DisplayMenu_Select_Loop_NotUp:
	ld a, (joypad_1)
	and $0A
	jr z, SAM_DisplayMenu_Select_Loop_NotDown
SAM_DisplayMenu_Select_Loop_Down:
	; Down is pressed
	
	ld a, c
	cp b
	jr nc, SAM_DisplayMenu_Select_Loop_Wait_Release		; If it's at the bottom of the menu, don't go further down.

	inc c
	
SAM_DisplayMenu_Select_Loop_Wait_Release:
	ld a, (joypad_1)
	and $0F
	jr nz, SAM_DisplayMenu_Select_Loop_Wait_Release

SAM_DisplayMenu_Select_Loop_NotDown:

	ld a, (joypad_1)
	and $30
	jr nz, SAM_DisplayMenu_Select_Loop_End

	jr SAM_DisplayMenu_Select_Loop
SAM_DisplayMenu_Select_Loop_End:

	; Wait for button press
	call WaitForButton

	; Hides the cursor sprite
	add a, -16
	ld (hw_sprites_y), a
	xor a
	ld (hw_sprites_xc + 1), a
	push bc
	call UpdateSprites
	pop bc
	
	; Resets the buffer for next time
	call SAM_ResetBuffer
	
	; Places option number in HL
	ld h, 0
	ld l, c
	ret

	
;================================================
SAM_ResetBuffer:
;================================================
	; Sets the top pointer to the start of the buffer
	ld hl, SAM_Buffer.top
	ld de, SAM_Buffer.buffer
	ld (hl), e
	inc hl
	ld (hl), d
	ret

	
;================================================
SAM_DisplayImage:
;================================================
	push ix
	push iy
	
		ld de, Picture_Resource_Table
		ld b, 2
		call SAM_Resource_Open
		
		push hl
		pop iy

SAM_DisplayImage_Load_Tileset:
		ld de, (128 * 32) | $4000
		ld l, (iy + SAM_Picture_Header.tileset)
		ld h, (iy + SAM_Picture_Header.tileset+1)
		call LoadTiles4BitRLE
;		ld hl,128                         ; tile index to load at
;		ld e, (iy + SAM_Picture_Header.tileset)
;		ld d, (iy + SAM_Picture_Header.tileset+1)
;		push de
;		pop ix
;	    ld bc,280                        ; number of tiles
;	    ld d,4                          ; bits per pixel
;	    call LoadTiles

SAM_DisplayImage_Load_Tile_Numbers:
	    ld hl,NameTableAddress
	    call VRAMToHL
		ld e, (iy + SAM_Picture_Header.map)
		ld d, (iy + SAM_Picture_Header.map+1)
		ex de, hl
		ld bc, 1152
	  -:ld a,(hl)  
	    out ($be), a
		inc hl
		dec bc
		ld a, b
		or c
	    jr nz, -

SAM_DisplayImage_Load_Palette:
		ld e, (iy + SAM_Picture_Header.palette)
		ld d, (iy + SAM_Picture_Header.palette+1)
		ex de, hl
	    ld b,16 						; size
	    ld c,$00                        ; index to load at
	    call LoadPalette

	pop iy
	pop ix
	ret


;================================================
SAM_PlayMusic:
;================================================
	ld de, Music_Resource_Table
	ld b, 2
	call SAM_Resource_Open
	; Load a module and start the player.
	; Music is only played by PSGMOD_Play().
	ld a, ($FFFF)			; Load bank # at slot 2
	call PSGMOD_LoadModule
	call PSGMOD_Start
	ret


;================================================
SAM_Call:
;================================================
	SAM_PUSH_SLOT_1			; Pushes bank #
	
	exx
		push hl				; Pushes program counter
	exx

	call SAM_Exec			; Calls subroutine

	exx
		pop hl				; Restores program counter
	exx
	
	SAM_POP_SLOT_1			; Pops bank #
	
	jr SAM_Fetch

;================================================
SAM_Start:
;================================================
	ld ix, SAM_Processes.data_stack
	call SAM_ResetBuffer
	ld hl, 0 					; Start script #0
	; Falls through to...
;================================================
SAM_Exec:
;================================================
	ld de, Script_Resource_Table
	ld b, 1
	call SAM_Resource_Open

	push hl
	exx
		pop hl					; HL' is the code pointer
		ld de, 0
		ld bc, 0
	exx
	; Falls through to...
;================================================
SAM_Fetch:
;================================================
	SAM_FETCH_BYTE
	
	ld c, a

	call SAM_CheckNumber
	
	ld a, c
	add a, -32
	jp nc, SAM_INS_SPACE		; Control chars are treated as spaces 
	
	add a, a
	ld h, 0
	ld l, a
	ld de, SAM_InstructionTable
	add hl, de
	
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	
	jp (hl)

SAM_Fetch_End:
	ret;
		 
.ends

;==============================================================
; Data
;==============================================================

.define TextArea_Width				30
.define TextArea_Height				6
.define TextArea_BorderBottom		1
.define TextArea_Top				24 - TextArea_Height - TextArea_BorderBottom
.define TextArea_NameTableAddress	NameTableAddress + (32*TextArea_Top*2)	; Doesn't work if you declare it at the top.

.STRUCT Fvm_Process
prog_id		dw
.ENDST

.STRUCT Fvm_Sprite
width		db
height		db
x		db
y		db
tile		dw
.ENDST

.STRUCT Fvm_Stream
slot		db
bank		db
addr		dw
.ENDST

.RAMSECTION "Variables" SLOT 3
process_data	INSTANCEOF	Fvm_Process	; FVM Process information (single process, for now)
.ENDS

.DEFINE Fvm_Sprite_Count 32
.DEFINE Fvm_Stream_Count 6

.DEFINE Program_Stream Fvm_Stream_Count-1
.DEFINE Internal_Stream Fvm_Stream_Count-2

.RAMSECTION "Video data" SLOT 3
hw_sprites_y	dsb		64
hw_sprites_xc	dsw		64
hw_page		db
.ENDS

.RAMSECTION "Temp vars" SLOT 3
temp_vars	dsb		16
.ENDS

.RAMSECTION "Femto VM RAM" SLOT 3
fvm_background	dsw		32*28
fvm_bkg_ptr	dw
fvm_sprites	INSTANCEOF	Fvm_Sprite	Fvm_Sprite_Count

fvm_joypad_1	db
fvm_joypad_2	db

fvm_streams	INSTANCEOF	Fvm_Stream	Fvm_Stream_Count

fvm_vars 	dsw		256
.ENDS

.DEFINE stackBase $df00
.DEFINE codeStackBase $de00

.bank 0 slot 0
.org $0000
;==============================================================
; Boot section
;==============================================================
.SECTION "Boot" FORCE
    di              ; disable interrupts
    im 1            ; Interrupt mode 1
    jp main         ; jump to main program
.ENDS    

.org $0038
;==============================================================
; VBL handler
;==============================================================
.SECTION "VBL handler" FORCE
_VBL_Handler:
    push af
    push hl
    push de
    
_VBL_Handler_Joypad:
    ; Joypad reading
    in a, ($DD)
    ld h, a
    in a, ($DC)
    ld l, a

    ; Joypad 1
    cpl
    and $7F
    ld (fvm_joypad_1), a
    
    ; Joypad 2
    add hl, hl
    add hl, hl		; Shifts top two bits from l (U/D Joypad 2) to h.
    ld a, h
    cpl
    and $7F
    ld (fvm_joypad_2), a
    
_VBL_Handler_Flipping:    
    ; Screen flipping
    ld a, (hw_page)
    or a
    jr nz, +
+    
        
_VBL_Handler_End:
    in a,($bf)		; Read VDP status to acknowledge interrupt.

    pop de
    pop hl
    pop af
    
    ei
    reti
.ENDS    

.org $0066
;==============================================================
; Pause button handler
;==============================================================
.SECTION "Pause button handler" FORCE
    ; Do nothing
    retn
.ENDS    



.SECTION "Main" FREE

;==============================================================
; Main program
;==============================================================
main:
    ld sp, stackBase
    
    call InitializeHardware

    ld hl, 0			; Resource number
    ld b, 1			; Slot number
    ld c, Program_Stream	; Stream number    
    call OpenResource_Read    
    call SelectStream
;    ld hl, FemtoVMTestCode
    call RunFemtoVM

    ; Infinite loop to stop program
    Loop:
         jp Loop
         
InitializeHardware:
    ;==============================================================
    ; Set up VDP registers
    ;==============================================================
    ld hl,VdpData
    ld b,VdpDataEnd-VdpData
    ld c,$bf
    otir

    ;==============================================================
    ; Clear VRAM
    ;==============================================================
    ; 1. Set VRAM write address to 0 by outputting $4000 ORed with $0000
    ld a,$00
    out ($bf),a
    ld a,$40
    out ($bf),a
    ; 2. Output 16KB of zeroes
    ld bc, $4000    ; Counter for 16KB of VRAM
    ld a,$00        ; Value to write
    ClearVRAMLoop:
        out ($be),a ; Output to VRAM address, which is auto-incremented after each write
        dec c
        jp nz,ClearVRAMLoop
        dec b
        jp nz,ClearVRAMLoop

    ;==============================================================
    ; Load palette
    ;==============================================================
    ; 1. Set VRAM write address to CRAM (palette) address 0 (for palette index 0)
    ; by outputting $c000 ORed with $0000
    ld a,$00
    out ($bf),a
    ld a,$c0
    out ($bf),a
    ; 2. Output colour data
    ld hl,PaletteData
    ld b,(PaletteDataEnd-PaletteData)
    ld c,$be
    otir
  
    ; Main screen turn on!
    ld a,%11100110
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
    ret
    
LoadTiles:    
;==============================================================
; Tile loader
;==============================================================
; Parameters:
; hl = tile number to start at
; ix = location of tile data
; bc = No. of tiles to load
; d  = bits per pixel
;==============================================================
        ; Tell VDP where I want to write (hl<<5)
        sla l
        rl h
        sla l
        rl h
        sla l
        rl h
        sla l
        rl h
        sla l
        rl h
        ld a,l
        out ($bf),a
        ld a,h
        or $40
        out ($bf),a

        ; I need to output bc*8 bytes so I need to modify bc (<<3)
        sla c
        rl b
        sla c
        rl b
        sla c
        rl b

        ; Write data
        _Loop:
            ; Restore counter
            ld e,d

            _DataLoop:
                ; Write byte
                ld a,(ix+0)
                out ($be),a
                dec e
                inc ix
                jp nz,_DataLoop

            ; Restore counter
            ld e,d
            _BlankLoop:
                ; Write blank data to fill up the rest of the tile definition
                inc e
                ld a,e
                cp 5
                jp z,_NoMoreBlanks

                ld a,0
                out ($be),a
                jp _BlankLoop

            _NoMoreBlanks:

            dec bc
            ld a,b
            or c
            jp nz,_Loop
    
    ret
    
PrepareSprites:
    ; Hides hardware sprites
    ld bc, 64
    ld hl, hw_sprites_y
    ld a, 217
    call FillRAM
    
    ld a, Fvm_Sprite_Count
    ld (temp_vars+1), a				; temp_vars+1 holds the sprite countdown
    
    ld ix, fvm_sprites
    ld hl, hw_sprites_y
    ld iy, hw_sprites_xc

_PrepareSprites_SpriteLoop:
    ld a, (ix+0)		
    or a
    jr z, _PrepareSprites_Skip

    ld e, (ix + Fvm_Sprite.x)			; e holds the x position
    ld c, (ix + Fvm_Sprite.tile)		; c holds the current tile number

    ld a, (ix + Fvm_Sprite.width) 
    ld (temp_vars), a				; temp_vars is used as the column counter
_PrepareSprites_ColLoop:
    	ld d, (ix + Fvm_Sprite.y)			; e holds the y position

    	ld b, (ix + Fvm_Sprite.height)		; b is used as the row counter
_PrepareSprites_RowLoop:
            ld (hl), d
    
            ld (iy+0), e			; (iy+0) receives sprite x position
            ld (iy+1), c			; (iy+1) receives tile number
            
            inc c
            inc c
    
            inc hl
            inc iy
            inc iy
            
        ld a, d
        add a, 16
        ld d, a					; Increments Y position by 16		
                        
        dec b
        jr nz, _PrepareSprites_RowLoop
        
    ld a, e
    add a, 8
    ld e, a					; Increments X position by 8
        
    ld a, (temp_vars)
    dec a
    ld (temp_vars), a				; Column countdown
    jr nz, _PrepareSprites_ColLoop

_PrepareSprites_Skip:
    ; Next FVM sprite
    ld de, _sizeof_Fvm_Sprite
    add ix, de
    
    ld a, (temp_vars+1)
    dec a
    ld (temp_vars+1), a				; Sprite countdown
    jr nz, _PrepareSprites_SpriteLoop

_PrepareSprites_End:
    ret
    
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

UpdateBackground:
    ;==============================================================
    ; Writes the contents of fvm_background to name table
    ;==============================================================
    ; 1. Set VRAM write address to name table index 0
    ; by outputting $4000 ORed with $3800+0
    ld a,$00
    out ($bf),a
    ld a,$38|$40
    out ($bf),a
    ; 2. Loop through text data, converting from ASCII ans writing tile indices
    ; to name table. Stop when a zero byte is found.
    ld hl, fvm_background   
    ld a, 28
-   ld bc, $32BE
    otir
    dec a
    or a
    jr nz, -
;    WriteTextLoop:
;        ld a,(hl)    ; Get data byte
;        cp $00       ; Is it zero?
;        jp z,EndWriteTextLoop    ; If so, exit loop
;        sub $20      ; In ASCII, space=$20 and the rest follow on. We want space=$00 so we subtract $20.
;        out ($be),a
;        ld a,$00
;        out ($be),a
;        inc hl       ; Point to next letter
;        jp WriteTextLoop

;    EndWriteTextLoop:
    
    ret

    
FillRAM:
    ld e, a
-   ld (hl), e
    inc hl
    
    dec bc
    ld a, b
    or c
    jr nz, -

    ret
    
.MACRO SELECT_STREAM_IY_FROM_C
    ld h, 0
    ld l, c				
    add hl, hl
    add hl, hl				; hl *= 4 (Stream header pointer offset)
    ld d, h
    ld e, l
    ld iy, fvm_streams
    add iy, de				; Pointer to stream header
.ENDM
    
OpenResource_Read:
    ;==============================================================
    ; Opens a stream for reading
    ; hl	: Resource number
    ; b		: Slot number
    ; c		: Stream number
    ;==============================================================
    
    add hl, hl
    add hl, hl				; hl *= 4 (Resource pointer offset)
    ld d, h
    ld e, l
    ld ix, FemtoVMResTable
    add ix, de				; Pointer to effective resource
    
    SELECT_STREAM_IY_FROM_C
       
    ld (iy+Fvm_Stream.slot), b		; Stream slot
    ld a, (ix+Fvm_Stream.bank)
    ld (iy+Fvm_Stream.bank), a		; Stream bank
    
    ld e, (ix+Fvm_Stream.addr)
    ld d, (ix+Fvm_Stream.addr+1)	; Gets resource pointer
    
    ld a, d
    and $3F				
    ld d, a				; Clears top two bits of the resource pointer
    
    ld a, b
    rrca
    rrca				; Equivalent to a = b << 6
    or d				
    ld d, a				; de = (addr & 0x3FFF) | (b << 14)

    ld (iy+Fvm_Stream.addr), e
    ld (iy+Fvm_Stream.addr+1), d	; Resource pointer

    ret
    
SelectStream:
    ;==============================================================
    ; Selects one of the open streams for accessing
    ; c	: Stream number
    ; Automatically selects the correct bank for the streams's slot
    ; Returns stream pointer in hl
    ;==============================================================
    
    SELECT_STREAM_IY_FROM_C
    
    ld h, $FF
    ld a, (iy+Fvm_Stream.slot)
    add a, $FD
    ld l, a				; Calculates address of the bankswitching port
    
    ld a, (iy+Fvm_Stream.bank)
    ld (hl), a				; Selects the correct bank
    
    ld a, (iy+Fvm_Stream.addr)
    ld l, a
    ld a, (iy+Fvm_Stream.addr+1)
    ld h, a				; Gets the address
    
    ret
    

.ENDS    ; Main



.SECTION "Math" FREE

;====================================
; HL *= DE
; Based on Z88DK runtime library
;====================================
Multiply:
        ld      b,16
        ld      a,h
        ld      c,l
        ld      hl,0
-
        add     hl,hl
        rl      c
        rla                  
        jr      nc, +
        add     hl,de
+
        djnz    -
        ret

;====================================
; hl = de/hl   de=de % hl
; Based on Z88DK runtime library
;====================================
Divide:
; Check for dividing by zero beforehand
        ld      a,h
        or      l
        ret     z
        ex      de,hl
;First have to obtain signs for quotient and remainder
        ld      a,h     ;dividend
        and     128
        ld      b,a     ;keep it safe
        jr      z,l_div0
;if -ve make into positive number!
        sub     a
        sub     l
        ld      l,a
        sbc     a,a
        sub     h
        ld      h,a
l_div0:
        ld      a,d     ;divisor
        and     128
        xor     b       
        ld      c,a     ;keep it safe (Quotient)
        bit     7,d
        jr      z,l_div01
        sub     a
        sub     e
        ld      e,a
        sbc     a,a
        sub     d
        ld      d,a
l_div01:
;Check for dividing by zero...
        ex      de,hl
        ld      a,h
        or      l
        ret     z       ;return hl=0, de=divisor
        ex      de,hl
        push    bc      ;keep the signs safe
;Now, we have two positive numbers so can do division no problems..
        ld      a,16    ;counter
        ld      b,h     ;arg1
        ld      c,l
        ld      hl,0    ;res1
; hl=res1 de=arg2 bc=arg1
        and     a
l_div1:
        rl      c       ;arg1 << 1 -> arg1
        rl      b
        rl      l       ;res1 << 1 -> res1
        rl      h
        sbc     hl,de   ;res1 - arg2 -> res1
        jr      nc,l_div2
        add     hl,de   ;res1 + arg2 -> res1
l_div2:
        ccf
        dec     a
        jr      nz,l_div1
        rl      c       ;arg1 << 1 -> arg1
        rl      b
;Have to return arg1 in hl and res1 in de
        ld      d,b
        ld      e,c
;Now do the signs..
        pop     bc      ;c holds quotient, b holds remainder
;de holds quotient, hl holds remainder
        ld      a,c
        call    dosign  ;quotient
        ld      a,b
        ex      de,hl   ;remainder (into de)
;Do the signs - de holds number to sign, a holds sign
dosign:
        and     128
        ret     z       ;not negative so okay..
        sub     a
        sub     e
        ld      e,a
        sbc     a,a
        sub     d
        ld      d,a
        ret

.ENDS    ; Math





.SECTION "Femto VM core" FREE

;=================================================
;
; Macro definitions
;
;=================================================

;====================================
; Fetches a byte from the program
;====================================
.MACRO FVM_FETCH
    exx
    	ld a, (hl)	; Fetches next instruction byte at hl'
    	inc hl
    exx
.ENDM
    
;====================================
; Pushes hl into data stack
;====================================
.MACRO FVM_PUSH_HL_DATA
    push hl
.ENDM
    
;====================================
; Pops hl from data stack
;====================================
.MACRO FVM_POP_HL_DATA
    pop hl
.ENDM
    
;====================================
; Pushes de into data stack
;====================================
.MACRO FVM_PUSH_DE_DATA
    push de
.ENDM
    
;====================================
; Pops de from data stack
;====================================
.MACRO FVM_POP_DE_DATA
    pop de
.ENDM
    
;====================================
; Pushes code pointer into code stack
;====================================
.MACRO FVM_PUSH_CODE
    exx			; Code SP is in bc'
        ld a, l
        ld (bc), a
        inc bc

        ld a, h
        ld (bc), a
        inc bc
    exx
.ENDM

;====================================
; Pops code pointer from code stack
;====================================    
.MACRO FVM_POP_CODE
    exx			; Code SP is in bc'
        dec bc
        ld a, (bc)
        ld h, a

        dec bc
        ld a, (bc)
        ld l, a
    exx
.ENDM
    
;====================================
; Pushes prog_id to the code stack
;====================================
.MACRO FVM_PUSH_PROGID
    ld a, (process_data.prog_id)	; LSB
    exx
        ld (bc), a
	inc bc
    exx

    ld a, (process_data.prog_id + 1)	; MSB
    exx
        ld (bc), a
	inc bc
    exx
.ENDM

;====================================
; Reads running prog_id into hl
;====================================
.MACRO FVM_POP_PROGID_HL
    exx
	dec bc
        ld a, (bc)			; MSB
    exx
    ld h, a

    exx
	dec bc
        ld a, (bc)			; LSB
    exx
    ld l, a
.ENDM

;====================================
; Sets running prog_id to hl
;====================================
.MACRO FVM_SET_PROGID_HL
    ld (process_data.prog_id), hl
    ; TODO: Do whatever post-processing is needed after a prog_id is selected
.ENDM

;====================================
; Jump to the address pointed by the
; data stack
;====================================
.MACRO FVM_JUMP
    exx
        FVM_POP_HL_DATA	; hl' receives destination address from data stack
	add hl, de	; de' contains base address of the program        
    exx
.ENDM

;====================================
; Returns program base address in de
;====================================
.MACRO FVM_GET_PROGBASE_DE
    exx
	push de	; de' contains base address of the program        
    exx
    pop de	; de = de'
.ENDM

;====================================
; Used to read and write to and from
; VM's memory.
; Takes the virtual address in hl and
; decodes it into the actual address,
; returning it in hl
;====================================
.MACRO FVM_MAP_MEM
    ld a, h
    and $40			; Checks if hl bit 14 is set
    jr nz, +			; If it's set, it's a RAM access
    
    ; Code access
    FVM_GET_PROGBASE_DE
    add hl, de			; offset + code base    
    jr ++			; Okay, done.
    
    ; RAM access
+   ld de, fvm_vars - $4000	; The $4000 compensates for the fact that bit 14 is set
    add hl, de

++
.ENDM

;====================================
; Asks to process next instruction
;====================================
.MACRO FVM_NEXT_INSTRUCTION
    jp FemtoVMNextInstruction
.ENDM

;====================================
; HL -= DE
;====================================
.MACRO SUB_HL_DE
    xor a		; Just to clear the carry flag
    sbc hl, de
.ENDM
    
;====================================
; HL >>= 1
;====================================
.MACRO SHR_HL
    xor a		; Resets carry flag
    rr h
    rr l
.ENDM
    
;====================================
; [HL] = DE; HL += 2;
;====================================
.MACRO LDI_HL_DE
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
.ENDM
    
;====================================
; DE = [HL]; HL += 2;
;====================================
.MACRO STI_HL_DE
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
.ENDM
    
;====================================
; Compares de with hl
; Taken from Z88DK
; signed compare of DE and HL
;   carry is sign of difference 
;          [set => DE < HL]
;   zero is zero/non-zero
;====================================
.MACRO CP_DE_HL
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
.ENDM

;====================================
; HL = (Carry flag ? 1 : 0)
;====================================
.MACRO SET_CARRY_HL
    jr nc, +		; If carry is not set, HL > DE is false
    
    ld l, 1    		; Else, HL > DE
    jr ++
    
+   ld l, 0

++  ld h, 0
.ENDM


;=================================================
;
; Main program and tables
;
;=================================================

;====================================
; Runs FemtoVM program starting at hl
;====================================
RunFemtoVM:
    push hl
    
    exx
        pop de			; de' points to program's base address
        ld h, d
        ld l, e			; hl' contains the current PC
        ld bc, codeStackBase	; bc' contains the current code SP
    exx

;====================================
; Executes next instruction
;====================================
FemtoVMNextInstruction:
    FVM_FETCH

    ld h, a
    and $80
    jr nz, +
    
    ; == Instruction is data ==
    
    FVM_FETCH
    
    ld l, a
    
    FVM_PUSH_HL_DATA	; Pushes data into the stack
    FVM_NEXT_INSTRUCTION

+
    ; == Instruction is code ==
    
    ld a, h
    and $7F
    add a, a		; Each entry is two bytes
    ld h, 0
    ld l, a
    ld de, FemtoVMJumpTable
    add hl, de		; Calcs jump table destination
    
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    jp (hl)		; Jumps to destination
	
StopFemtoVM:
    ret
    
;====================================
; Jump table
;====================================
FemtoVMJumpTable:

     ; ** Standard instructions ** ;
     
    .dw FvmNOP, FvmWAIT, FvmEND, FvmSYSINFO		; $80..$83
    .dw FvmCALL, FvmRET, FvmLCALL, FvmLRET		; $84..$87
    .dw FvmJUMP, FvmJUMP_Z, FvmJUMP_NZ, FvmINVALID	; $88..$8B
    .dw FvmLOAD, FvmSTORE, FvmINPUT, FvmSELECT		; $8C..$8F
    .dw FvmEQUALS, FvmLT, FvmGT, FvmNOT			; $90..$93
    .dw FvmAND, FvmOR, FvmSHL, FvmSHR			; $94..$97
    .dw FvmADD, FvmSUB, FvmMUL, FvmDIV			; $98..$9B
    .dw FvmMOD, FvmDIVMOD, FvmNEG, FvmXOR		; $9C..$9F
    .REPT $C0-$A0
        .dw FvmINVALID
    .ENDR
    
     ; ** Extended instructions ** ;
    .dw FvmREFRESH, FvmBKG_GOXY, FvmBKG_IN, FvmBKG_OUT			; $C0..$C3
    .dw FvmSPR_GET_XY, FvmSPR_SET_XY, FvmSPR_GET_TILE, FvmSPR_SET_TILE	; $C4..$C7
    .dw FvmSPR_GET_SIZE, FvmSPR_SET_SIZE, FvmSPR_HIDE, FvmSPR_CLEAR	; $C8..$CB
    .dw FvmJOYPAD_1, FvmJOYPAD_2, FvmINVALID, FvmINVALID		; $CC..$CF
    .dw FvmLOAD_TILES, FvmINVALID, FvmINVALID, FvmINVALID		; $D0..$D3
    .dw FvmPAL_GET, FvmPAL_SET, FvmPAL_LOAD, FvmINVALID			; $D4..$D7
    .REPT $100-$D8
        .dw FvmINVALID
    .ENDR


     
;=================================================
;
; Standard instructions
;
; Note that many of the instruction
; implementations are inlined in
; order to increase speed.
;
;=================================================

;====================================
; Invalid instruction implementation 
;====================================
FvmINVALID:
    FVM_NEXT_INSTRUCTION

;==============================        
; NOP implementation 
;==============================        
FvmNOP:
    FVM_NEXT_INSTRUCTION

;==============================        
; WAIT implementation 
;==============================        
FvmWAIT:
    FVM_NEXT_INSTRUCTION

;==============================        
; END implementation 
;==============================        
FvmEND:
    jp StopFemtoVM
;    FVM_NEXT_INSTRUCTION

;==============================        
; SYSINFO implementation 
;==============================        
FvmSYSINFO:
    FVM_NEXT_INSTRUCTION

;==============================        
; CALL implementation 
;==============================        
FvmCALL:    
    FVM_PUSH_CODE
    FVM_JUMP
    FVM_NEXT_INSTRUCTION

;==============================        
; RET implementation 
;==============================        
FvmRET:    
    FVM_POP_CODE
    FVM_NEXT_INSTRUCTION

;==============================        
; LCALL implementation 
;==============================        
FvmLCALL:    
    FVM_PUSH_CODE		; saves PC to the code stack
    FVM_PUSH_PROGID		; saves current prog_id to the code stack
    FVM_POP_HL_DATA		; hl gets new prog_id
    FVM_SET_PROGID_HL		; sets new prog_id
    FVM_JUMP			; jumps to destination address
    FVM_NEXT_INSTRUCTION

;==============================        
; LRET implementation 
;==============================        
FvmLRET:    
    FVM_POP_PROGID_HL		; pops old prog_id from code stack
    FVM_SET_PROGID_HL		; sets new prog_id
    FVM_POP_CODE		; retrieves previous PC from code stack
    FVM_NEXT_INSTRUCTION

;==============================        
; JUMP implementation 
;==============================        
FvmJUMP:
    FVM_JUMP
    FVM_NEXT_INSTRUCTION

;==============================        
; JUMP_Z implementation 
;==============================        
FvmJUMP_Z:
    FVM_POP_DE_DATA		; de gets dest address
    FVM_POP_HL_DATA		; hl gets value
    
    ld a, h
    or l
    jr nz, +			; If not zero, don't jump
    
    FVM_PUSH_DE_DATA
    FVM_JUMP			; Else, jump
    
+   FVM_NEXT_INSTRUCTION

;==============================        
; JUMP_NZ implementation 
;==============================        
FvmJUMP_NZ:
    FVM_POP_DE_DATA		; de gets dest address
    FVM_POP_HL_DATA		; hl gets value
    
    ld a, h
    or l
    jr z, +			; If zero, don't jump
    
    FVM_PUSH_DE_DATA
    FVM_JUMP			; Else, jump
    
+   FVM_NEXT_INSTRUCTION

;==============================        
; INPUT implementation 
;==============================        
FvmINPUT:
    FVM_NEXT_INSTRUCTION

;==============================        
; SELECT implementation 
;==============================        
FvmSELECT:
    FVM_NEXT_INSTRUCTION

;==============================        
; LOAD implementation 
;==============================        
FvmLOAD:
    FVM_POP_HL_DATA			; Source address
    FVM_MAP_MEM				; Maps to physical address
    
    ; de = (hl)
    ; keep in mind that the VM is high endian
    ld d, (hl)
    inc hl
    ld e, (hl)
    
    FVM_PUSH_DE_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; STORE implementation 
;==============================        
FvmSTORE:
    FVM_POP_HL_DATA			; Dest address
    FVM_MAP_MEM				; Maps to physical address
    FVM_POP_DE_DATA			; Data to store
    
    ; (hl) = de
    ; keep in mind that the VM is high endian
    ld (hl), d
    inc hl
    ld (hl), e
    
    FVM_NEXT_INSTRUCTION

;==============================        
; EQUALS implementation 
;==============================        
FvmEQUALS:
    FVM_POP_DE_DATA
    FVM_POP_HL_DATA

    SUB_HL_DE
    
    ld a, h
    or l
    jr z, +		; Result is zero?

    ld hl, 0		; Nope, so they're not equal.
    jr ++    
    
+   ld hl, $FFFF    	; Yup, so they're equal.
    
++  FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; GT implementation 
;==============================        
FvmGT:
    FVM_POP_DE_DATA
    FVM_POP_HL_DATA
    
    CP_DE_HL
    SET_CARRY_HL ; If carry is set, HL > DE
    
    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; LT implementation 
;==============================        
FvmLT:
    FVM_POP_HL_DATA
    FVM_POP_DE_DATA		; Note that they're popped in the reverse order from FvmGT
    
    CP_DE_HL
    SET_CARRY_HL ; If carry is set, HL > DE
    
    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; NOT implementation 
;==============================        
FvmNOT:
    FVM_POP_HL_DATA

    ld a, l
    cpl
    ld l, a

    ld a, h
    cpl
    ld h, a

    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION
        
;==============================        
; AND implementation 
;==============================        
FvmAND:
    FVM_POP_DE_DATA
    FVM_POP_HL_DATA

    ld a, l
    and e
    ld l, a

    ld a, h
    and d
    ld h, a

    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; OR implementation 
;==============================        
FvmOR:
    FVM_POP_DE_DATA
    FVM_POP_HL_DATA

    ld a, l
    or e
    ld l, a

    ld a, h
    or d
    ld h, a

    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; SHL implementation 
;==============================        
FvmSHL:
    FVM_POP_DE_DATA
    FVM_POP_HL_DATA

    ld a, e
    or a
    jr z, +		; If e is zero, there's nothing to do.

    ld b, e
-       add hl, hl
    	djnz -
+

    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; SHR implementation 
;==============================        
FvmSHR:
    FVM_POP_DE_DATA
    FVM_POP_HL_DATA

    ld a, e
    or a
    jr z, +		; If e is zero, there's nothing to do.

    ld b, e
-       SHR_HL
    	djnz -
+

    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; ADD implementation 
;==============================        
FvmADD:
    FVM_POP_DE_DATA
    FVM_POP_HL_DATA
    add hl, de
    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; SUB implementation 
;==============================        
FvmSUB:
    FVM_POP_DE_DATA
    FVM_POP_HL_DATA
    SUB_HL_DE
    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; MUL implementation 
;==============================        
FvmMUL:
    FVM_POP_DE_DATA
    FVM_POP_HL_DATA
    call Multiply
    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; DIV implementation 
;==============================        
FvmDIV:
    FVM_POP_HL_DATA		; Divider
    FVM_POP_DE_DATA		; Dividend
    call Divide
    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; MOD implementation 
;==============================        
FvmMOD:
    FVM_POP_HL_DATA		; Divider
    FVM_POP_DE_DATA		; Dividend
    call Divide
    FVM_PUSH_DE_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; DIVMOD implementation 
;==============================        
FvmDIVMOD:
    FVM_POP_HL_DATA		; Divider
    FVM_POP_DE_DATA		; Dividend
    call Divide
    FVM_PUSH_HL_DATA
    FVM_PUSH_DE_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; NEG implementation 
;==============================        
FvmNEG:
    FVM_POP_DE_DATA
    ld hl, 0
    SUB_HL_DE			; hl = 0 - de
    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION

;==============================        
; XOR implementation 
;==============================        
FvmXOR:
    FVM_POP_DE_DATA
    FVM_POP_HL_DATA

    ld a, l
    xor e
    ld l, a

    ld a, h
    xor d
    ld h, a

    FVM_PUSH_HL_DATA
    FVM_NEXT_INSTRUCTION



;=================================================
;
; Extended instructions
;
;=================================================

.MACRO FVM_CALC_BKG_POINTER
    ld hl, (fvm_bkg_ptr)
    ld bc, fvm_background
    add hl, bc
.ENDM

.MACRO FVM_NEXT_BKG_POINTER
    ld hl, fvm_bkg_ptr
    inc (hl)
    inc (hl)
.ENDM

.MACRO FVM_CALC_SPR_ADDR_IX_DE
    ; Calculates offset (sprite number*6)
    ld h, d
    ld l, e			; hl = de
    add hl, de
    add hl, de			; hl = de * 3
    add hl, hl			; hl = de * 6
    
    ; Calculates starting address
    ld ix, fvm_sprites
    ld d, h
    ld e, l
    add ix, de
.ENDM

;==============================        
; REFRESH implementation 
;==============================        
FvmREFRESH:
    call UpdateBackground
    call PrepareSprites
    call UpdateSprites
    FVM_NEXT_INSTRUCTION

;==============================        
; BKG_GOXY implementation 
;==============================        
FvmBKG_GOXY:
    FVM_POP_HL_DATA
    FVM_POP_DE_DATA

    ; HL <<= 6    
    ld h, l
    ld l, 0    
    SHR_HL
    SHR_HL
    
    ; hl += de << 1
    add hl, de
    add hl, de
    
    ld a, l
    ld (fvm_bkg_ptr), a
    ld a, h
    ld (fvm_bkg_ptr + 1), a

    FVM_NEXT_INSTRUCTION

;==============================        
; BKG_IN implementation 
;==============================        
FvmBKG_IN:
    FVM_CALC_BKG_POINTER
    STI_HL_DE
    FVM_PUSH_DE_DATA
    FVM_NEXT_BKG_POINTER
    
    FVM_NEXT_INSTRUCTION

;==============================        
; BKG_OUT implementation 
;==============================        
FvmBKG_OUT:
    FVM_POP_DE_DATA
    
    FVM_CALC_BKG_POINTER
    LDI_HL_DE
    FVM_NEXT_BKG_POINTER

    FVM_NEXT_INSTRUCTION
    
;==============================        
; SPR_GET_XY implementation 
;==============================        
FvmSPR_GET_XY:
    FVM_POP_DE_DATA 		; Gets fvm sprite number
    FVM_CALC_SPR_ADDR_IX_DE     ; Calculates starting address
    
    ld d, 0
    ld e, (ix + Fvm_Sprite.x)
    FVM_PUSH_DE_DATA
    ld e, (ix + Fvm_Sprite.y)
    FVM_PUSH_DE_DATA
    
    FVM_NEXT_INSTRUCTION
    
;==============================        
; SPR_SET_XY implementation 
;==============================        
FvmSPR_SET_XY:
    FVM_POP_DE_DATA 		; Gets fvm sprite number
    FVM_CALC_SPR_ADDR_IX_DE     ; Calculates starting address
    
    FVM_POP_DE_DATA
    ld (ix + Fvm_Sprite.y), e
    FVM_POP_DE_DATA
    ld (ix + Fvm_Sprite.x), e

    FVM_NEXT_INSTRUCTION
    
;==============================        
; SPR_GET_TILE implementation 
;==============================        
FvmSPR_GET_TILE:
    FVM_POP_DE_DATA 		; Gets fvm sprite number
    FVM_CALC_SPR_ADDR_IX_DE     ; Calculates starting address

    ld e, (ix + Fvm_Sprite.tile)
    ld d, (ix + (Fvm_Sprite.tile+1))
    FVM_PUSH_DE_DATA

    FVM_NEXT_INSTRUCTION
    
;==============================        
; SPR_SET_TILE implementation 
;==============================        
FvmSPR_SET_TILE:
    FVM_POP_DE_DATA 		; Gets fvm sprite number
    FVM_CALC_SPR_ADDR_IX_DE     ; Calculates starting address

    FVM_POP_DE_DATA 		; Gets tile number
    ld (ix + Fvm_Sprite.tile), e
    ld (ix + (Fvm_Sprite.tile+1)), d

    FVM_NEXT_INSTRUCTION
    
;==============================        
; SPR_GET_SIZE implementation 
;==============================        
FvmSPR_GET_SIZE:
    FVM_POP_DE_DATA 		; Gets fvm sprite number
    FVM_CALC_SPR_ADDR_IX_DE     ; Calculates starting address
    
    ld d, 0
    ld e, (ix + Fvm_Sprite.width)
    FVM_PUSH_DE_DATA
    ld e, (ix + Fvm_Sprite.height)
    FVM_PUSH_DE_DATA

    FVM_NEXT_INSTRUCTION
    
;==============================        
; SPR_SET_SIZE implementation 
;==============================        
FvmSPR_SET_SIZE:
    FVM_POP_DE_DATA 		; Gets fvm sprite number
    FVM_CALC_SPR_ADDR_IX_DE     ; Calculates starting address
    
    FVM_POP_DE_DATA
    ld (ix + Fvm_Sprite.height), e
    FVM_POP_DE_DATA
    ld (ix + Fvm_Sprite.width), e

    FVM_NEXT_INSTRUCTION
    
;==============================        
; SPR_HIDE implementation 
;==============================        
FvmSPR_HIDE:
    FVM_POP_DE_DATA 		; Gets fvm sprite number
    FVM_CALC_SPR_ADDR_IX_DE     ; Calculates starting address

    xor a
    ld (ix + 0), a

    FVM_NEXT_INSTRUCTION
    
;==============================        
; SPR_CLEAR implementation 
;==============================        
FvmSPR_CLEAR:
    ld bc, _sizeof_Fvm_Sprite * Fvm_Sprite_Count
    ld hl, fvm_sprites
    xor a
    
    call FillRAM
    
    FVM_NEXT_INSTRUCTION
    
;==============================        
; JOYPAD_1 implementation 
;==============================        
FvmJOYPAD_1:
    ld a, (fvm_joypad_1)
    ld h, 0
    ld l, a
    FVM_PUSH_HL_DATA
    
    FVM_NEXT_INSTRUCTION
    
;==============================        
; JOYPAD_2 implementation 
;==============================        
FvmJOYPAD_2:
    ld a, (fvm_joypad_2)
    ld h, 0
    ld l, a
    FVM_PUSH_HL_DATA
    
    FVM_NEXT_INSTRUCTION
    
;==============================        
; LOAD_TILES implementation 
;==============================        
FvmLOAD_TILES:
    FVM_POP_HL_DATA		; Resource number
    ld b, 2			; Slot number (2)
    ld c, Internal_Stream	; Stream reserved for internal use
    call OpenResource_Read
    call SelectStream
    
    push hl
    pop ix			; ix points to start of tile data
    
    FVM_POP_HL_DATA		; Number of tiles to load
    ld c, l
    ld b, h
    
    FVM_POP_HL_DATA		; Tile number to start at    
    ld d, 4			; Bits per pixel
    
    call LoadTiles

    FVM_NEXT_INSTRUCTION

;==============================        
; PAL_GET implementation 
;==============================        
FvmPAL_GET:
    FVM_NEXT_INSTRUCTION

;==============================        
; PAL_SET implementation 
;==============================        
FvmPAL_SET:
    FVM_POP_HL_DATA		; Palette entry number
    ld a, l
    out ($bf),a
    ld a,$c0
    out ($bf),a

    FVM_POP_HL_DATA		; Blue
    add hl, hl    
    add hl, hl			; Gets top 2 bits
    ld c, h
    FVM_POP_HL_DATA		; Green
    add hl, hl    
    add hl, hl			; Gets top 2 bits
    ld b, h
    FVM_POP_HL_DATA		; Red
    add hl, hl    
    add hl, hl			; Gets top 2 bits
    ld d, h
	
	ld a, c
	add a, a
	add a, a			; Compute blue
	
	or b
	add a, a
	add a, a			; Compute red+blue
	
	or d				; Compute red+green+blue

	out ($be),a			; Outputs the palette entry

    FVM_NEXT_INSTRUCTION

;==============================        
; PAL_LOAD implementation 
;==============================        
FvmPAL_LOAD:
    FVM_POP_HL_DATA		; Resource number
    ld b, 2			; Slot number (2)
    ld c, Internal_Stream	; Stream reserved for internal use
    call OpenResource_Read
    call SelectStream	; HL now points to start of palette data

    FVM_POP_DE_DATA		; Palette entry count
	ld b, e

    FVM_POP_DE_DATA		; Palette entry number
    ld a, e
    out ($bf),a
    ld a,$c0
    out ($bf),a
	
	ld c, $be
	otir

    FVM_NEXT_INSTRUCTION
    

    
    
.ENDS    ; "FVM_Core"



.SECTION "Init data"
;==============================================================
; Data
;==============================================================

PaletteData:
.db $00,$3f ; Black, White
.db $01, $02, $03, $04, $08, $0C, $10, $20, $30, $0F, $33, $3C, $3F, $2F
.db $00,$3f ; Black, White
.db $01, $02, $03, $04, $08, $0C, $10, $20, $30, $0F, $33, $3C, $3F, $2F
PaletteDataEnd:

; VDP initialisation data
VdpData:
.db $04,$80,$84,$81,$ff,$82,$ff,$85,$ff,$86,$ff,$87,$00,$88,$00,$89,$ff,$8a
VdpDataEnd:

.ENDS ; Init data

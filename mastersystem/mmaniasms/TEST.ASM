; MegaMania para Master System
; por Haroldo de Oliveira Pinheiro
; Baseado no exemplo do GGASM
    
    .include "defines.inc"
    .include "routines.inc"

    SpriteY  = RAM_START    ; to RAM_START+64
    SpriteX  = RAM_START+64 ; to RAM_START+192
    Joystick = RAM_START+192; to RAM_START+193
    Transfer = RAM_START+193; to RAM_START+194

    ; Vari†veis de animaá∆o do fundo
	StarAnim = GAME_RAM_START+194; to GAME_RAM_START+196
	StarAnm2 = GAME_RAM_START+196; to GAME_RAM_START+198
	StarAnCt = GAME_RAM_START+198; to GAME_RAM_START+199
	StarAnC2 = GAME_RAM_START+199; to GAME_RAM_START+200

	; Delay
    Dly_Ctrl = GAME_RAM_START+200; to GAME_RAM_START+201

	; Nave do jogador
	Ply_X	 = GAME_RAM_START+201; to GAME_RAM_START+202
	Ply_Frm	 = GAME_RAM_START+202; to GAME_RAM_START+203

    ; Nave do inimigo
    Enm_Frm	 = GAME_RAM_START+203; to GAME_RAM_START+204

	; Tiro do jogador
	PlySht_X = GAME_RAM_START+204; to GAME_RAM_START+205

	; Energia
	Ply_Enrg = GAME_RAM_START+205; to GAME_RAM_START+206

	; Inimigos est∆o vivos?
	Enm_Enrg = GAME_RAM_START+206; to GAME_RAM_START+230

	; Score do jogador (1 byte por d°gito)
	Ply_Score = GAME_RAM_START+230; to GAME_RAM_START+240

    .module MAIN

    .area _CODE1 (REL)
waitforline::
    in   a, (0H7e)          ; 7eh is the current displayed scanline.
    cp   #0Hb0              ; Waits for line b0h. Assumed to be end of screen.
    jr   nz, waitforline

    in   a,(0Hbf)           ; Reads VDP status.

    ld   hl,#VDPRegsTable   ; Sets hl to point to VDP register values.
    ld   b, #0H0b           ; Sets first 11 VDP registers. Starting at 0.
    ld   c, #0H80           ; High byte is register number + 80h

VDPRegsLoop:
    ld   a,(hl)
    inc  hl
    out  (0Hbf), a          ; bfh selects VDP(80h) register, CRAM(c0h) or VRAM(40h). 
    ld   a, c               ; Transfer data first then register number
    inc  c
    out  (0Hbf), a          ; Selects VDP register.
    dec  b
    jr   nz, VDPRegsLoop

    xor  a                  ; Start at palette entry 0
    ld   hl, #PalData       ; Set up address of palette
    ld   bc, #PalCount      ; Set up number of bytes to transfer

    call TransferPalette    ; Call routine to transfer palette

    ld  hl, #0H4000         ; Set up address of VRAM to clear
    ld  bc, #0H4000         ; Set up number of bytes to clear

    call ClearVRAM          ; Call routine to clear VRAM

    ld   de, #0H4000        ; Load DE with VRAM address 
    ld   hl, #CharData      ; Set up address of char data
    ld   bc, #CharCount     ; Set up number of bytes to transfer

    call TransferCharData   ; Call routine to transfer char data

    ld   de, #0H6000        ; Load DE with VRAM address 
    ld   hl, #SpriteData    ; Set up address of sprite data
    ld   bc, #SpriteCount   ; Set up number of bytes to transfer

    call TransferCharData   ; Call routine to transfer sprite data

    ld   de, #0H7800        ; Load DE with VRAM address 
    ld   hl, #ScreenData    ; Set up address of screen data
    ld   bc, #ScreenCount   ; Set up number of bytes to transfer

    call TransferCharData   ; Call routine to transfer screen data

    ld   hl, #ListData       ; Set the location of the sprite list
    ld   a, #ListCount/3     ; Load a with the number of sprites in the list

    call SetSpriteList
    call Update

    call ScreenOnVB
    ei
    
WaitforEndofScreen:
    in   a, (0H7e)
    cp   #0Hc0
    jr   nz, WaitforEndofScreen

GameStart:
	call ScreenOff
	di

	ld hl,#CharData
	ld a,#0H08
	ld (StarAnim), hl
	ld (StarAnCt), a

	ld hl,#CharData+0H0080
	ld a,#0H04
	ld (StarAnm2), hl
	ld (StarAnC2), a

	xor a
	ld	(Ply_X), a
	ld	(Ply_Frm), a

	ld	a, #0H80
	ld	(Enm_Frm), a

	ld	a, #0H70
	ld	(Ply_Enrg), a

	call InitPlyScore
	call DrawPlyScore

	call InitEnemies

    call ScreenOnVB
	ei
EndlessLoop:
	call MoveStars
	call MovePlayerShip
	call UpdatePlayerShip
	call MoveEnemy
	call UpdateEnemy
	call CheckEnemies
	call UpdatePlayerShot
	call UpdatePlyEnergy
    call Update
    call WaitForTransfer
	call WaitVSyncStart
    
    ld	 a, (Dly_Ctrl)
	inc	 a
	ld	 (Dly_Ctrl), a

    jp   EndlessLoop

; Move as estrelas no fundo
MoveStars:
    push af
    push bc
    push de

; Checa se j† Ç hora de atualizar a animaá∆o
	ld	 a, (Dly_Ctrl)
	bit	 1, a
	jp	 nz, StarAnimDone

; Animaá∆o 1

    ld   de, #0H4000		; Endereáo do 1o caracter de fundo
    ld   hl, (StarAnim)		; Caracter a ser escrito
    ld   bc, #0H20			; N£mero de bytes

    call TransferCharData   ; Call routine to transfer char data

;	ld	 de, #0H0020
;	add	 hl, de				; HL j† foi incrementado por TransferCharData
	ld	 (StarAnim), hl

    ld	 a,(StarAnCt)
	sub	 a, #0H01
	jr	 nz, StarAnimOk

	ld hl,#CharData
	ld a,#0H08
	ld (StarAnim), hl
	ld (StarAnCt), a

StarAnimOk:
	ld	 (StarAnCt), a

; Animaá∆o 2

    ld   de, #0H4020		; Endereáo do 2o caracter de fundo
    ld   hl, (StarAnm2)		; Caracter a ser escrito
    ld   bc, #0H20			; N£mero de bytes

    call TransferCharData   ; Call routine to transfer char data

;	ld	 de, #0H0020
;	add	 hl, de				; HL j† foi incrementado por TransferCharData
	ld	 (StarAnm2), hl

    ld	 a,(StarAnC2)
	sub	 a, #0H01
	jr	 nz, StarAnimOk2

	ld hl,#CharData
	ld a,#0H08
	ld (StarAnm2), hl
	ld (StarAnC2), a

StarAnimOk2:
	ld	 (StarAnC2), a

StarAnimDone:
    pop  de
    pop  bc
    pop  af

	ret

MovePlayerShip:
	xor	 a
	ld	 c, a				; C vai dizer se o jogador moveu o direcional
	ld 	 a, (Joystick)
	cpl
	ld	 b, a
	ld	 hl, #Ply_X

	bit  2, a				; Joystick para a esquerda?
	jr	 nz, NotMovShipL
	ld	 c, #1				; Avisa que moveu o joystick
	dec	 (hl)				; Desloca para a esquerda
	ld	 a, (Ply_Frm)		; Carrega frame atual em A
	cp	 #8					; Checa se n∆o Ç 8
	jr	 z, NotMovShipL
	inc	 a
	ld	 (Ply_Frm), a		; Se n∆o for, incrementa
NotMovShipL:
	ld	 a, b

	bit  3, a				; Joystick para a direita?
	jr	 nz, NotMovShipR
	ld	 c, #1				; Avisa que moveu o joystick
	inc	 (hl)				; Desloca para a direita
	ld	 a, (Ply_Frm)		; Carrega frame atual em A
	or	 a					; Checa se n∆o Ç zero
	jr	 z, NotMovShipR
	dec	 a
	ld	 (Ply_Frm), a		; Se n∆o for, decrementa
NotMovShipR:

	ld	 hl, #Ply_Frm
	ld	 a, c
	or	 a					; Moveu o joystick?
	jr	 nz, MovedShip
;	jr	 NotMovShipL
	ld	 a, (hl)			; Se n∆o moveu, centraliza a nave
	cp	 a, #4
	jr	 z, MovedShip		; Diferente de 4 ?
	jr	 c, NotShipGt4		; Menor que 4 ?
	dec	 (hl)				; Maior que 4: decrementa
	jr	 MovedShip
NotShipGt4:
	inc	 (hl)				; Menor que 4: incrementa
	jr	 MovedShip
MovedShip:

	ld	 a, b
	cpl
	and	 #0H30				; Apertou qualquer bot∆o?
	jr	 z, DontShoot		; N∆o
	ld	 hl, #SpriteY+44
	ld	 a, (hl)
	or	 a					; Coordenada Y = 0?
	jr	 nz, DontShoot		; N∆o
	ld	 a, #126
	ld	 (hl), a			; Fogo!!!
	ld	 a, (Ply_X)
	sub	 a, #4
	ld	 (PlySht_X), a		; Seta a coordenada X
DontShoot:

	ret

UpdatePlayerShip:
	ld	 a, (Ply_X)
	ld	 b, a
	ld	 a, (Ply_Frm)
	add	 a
	add	 a
	add	 a
	ld	 c, a				; c = (Ply_Frm) * 8
	ld	 hl,#SpriteX

	ld	 a, b
	sub	 #8
	ld	 (hl), a			; Atualiza X
	inc  hl
	ld	 a, c
	ld	 (hl), a			; Atualiza caracter
	inc	 c
	inc	 c
	inc  hl

	ld	 a, b
	ld	 (hl), a			; Atualiza X
	inc  hl
	ld	 a, c
	ld	 (hl), a			; Atualiza caracter
	inc	 c
	inc	 c
	inc  hl

	ld	 a, b
	sub	 #8
	ld	 (hl), a			; Atualiza X
	inc  hl
	ld	 a, c
	ld	 (hl), a			; Atualiza caracter
	inc	 c
	inc	 c
	inc  hl

	ld	 a, b
	ld	 (hl), a			; Atualiza X
	inc  hl
	ld	 a, c
	ld	 (hl), a			; Atualiza caracter
	inc	 c
	inc	 c
	inc  hl

	ret

UpdatePlayerShot:
	ld	 hl, #SpriteY+44
	ld	 a, (hl)			; Là a coordenada Y
	or	 a					; Se for zero
	jr	 z, HidePlyShot		; Apenas o oculta
							; Se n∆o for
	dec	 a
	dec	 a
	ld	 (hl), a			; Atualiza Y

	ld	 hl, #SpriteX+88
	ld	 a, (PlySht_X)
	ld	 (hl), a			; Atualiza X

	inc	 hl
	ld	 a, #72
	ld	 (hl), a			; Atualiza Caracter
	jr	 UpdPlyShotDone

HidePlyShot:
	ld	 a,	#0
	ld	 (SpriteX+88), a	; Oculta no canto da tela
UpdPlyShotDone:

	ret

UpdatePlyEnergy:
	ld	 a, (Dly_Ctrl)
	and	 #0H1F				; ê hora de decrementar a energia?
	jr 	 nz, EnrgUpdDone	; N∆o

	ld	 a, (Ply_Enrg)
	ld	 b, a
	srl	 a
	srl	 a
	ld	 e, a
	xor  a
	ld	 d, a
	ld 	 hl, #0H7D46
	add  hl, de
	add  hl, de				; Calcula o endereáo do caracter a ser mudado

	ld	 a, b
	and	 #0H03
	ld	 b, a
	ld	 a, #0H04
	sub	 b
	or	 #0H20
	ld	 b, a				; Calcula o valor do caracter

	di
	ld	 a, l
	out	 (#0HBF), a			; LSB do endereáo do caracter
	ld	 a, h
	out	 (#0HBF), a			; MSB do endereáo do caracter
	ld	 a, b
	out	 (#0HBE), a			; Valor do caracter
	ei

	ld	 a, (Ply_Enrg)
	dec	 a
	ld	 (Ply_Enrg), a
EnrgUpdDone:

	ret

InitPlyScore:
	ld	 hl, #Ply_Score

	ld	 c, #10
PlyScInitLoop:
	xor	 a
	ld	 (hl), a
	inc	 hl
	
	inc	 c
	or	 c					; A j† vale 0
	jr	 nz, PlyScInitLoop

	ret

IncPlyScore:				; Incrementa o score do jogador. A contÇm o inc., em BCD
	ld	 e, a
	srl	 a
	srl	 a
	srl	 a
	srl	 a
	ld	 d, a				; D contÇm o d°gito mais significativo (base 10)
	ld	 a, e
	and	 #0H0F
	ld	 e, a

	ld	 hl, #Ply_Score+2	; O £ltimo zero nunca Ç alterado.

	ld	 c, #2
PlyScoreInc1:
	push hl
	pop	 ix					; Gambiarra FEIA!!!

PlyScoreInc2:
	ld	 a,	(ix)
	add	 e
	cp	 #10				; Checa se deve somar 1 ao pr¢ximo d°gito, tambÇm
	jr	 c, PlyScIncNoCarry
	
	sub	 #10
	ld	 (ix), a
	ld	 e, #1				; "Vai um"
	inc	 ix
	jr	 PlyScoreInc2

PlyScIncNoCarry:
	ld	 (ix), a

	inc	 hl	
	ld	 e, d				; E agora contÇm o d°gito mais significativo

	dec	 c
	xor	 a
	or	 c
	jr	 nz, PlyScoreInc1	

	ret

DrawPlyScore:
	ld	 hl, #Ply_Score+10
	ld	 de, #0H7DA8		; Endereáo inicial do caracter no background

	ld	 c, #9
SkipPlyScoreLoop:			; Salta os zeros Ö esquerda
	ld	 a, (hl)
	or	 a
	jr	 nz, StartPlyScoreDraw

	di
	ld	 a, e
	out	 (#0HBF), a			; LSB do endereáo do caracter
	ld	 a, d
	out	 (#0HBF), a			; MSB do endereáo do caracter
	ld	 a, #0H3A
	out	 (#0HBE), a			; Valor do caracter
	ei

	dec	 hl
	inc	 de
	inc	 de

	dec	 c
	xor	 a
	or	 c
	jr	 nz, SkipPlyScoreLoop

StartPlyScoreDraw:
	inc	 c

DrawPlyScoreLoop:
	ld	 a, (hl)
	or	 a, #0H30
	ld	 b, a

	di
	ld	 a, e
	out	 (#0HBF), a			; LSB do endereáo do caracter
	ld	 a, d
	out	 (#0HBF), a			; MSB do endereáo do caracter
	ld	 a, b
	out	 (#0HBE), a			; Valor do caracter
	ei

	dec	 hl
	inc	 de
	inc	 de

	dec	 c
	xor	 a
	or	 c
	jr	 nz, DrawPlyScoreLoop

	ret

MoveEnemy:
	ld	 hl, #SpriteX+8

    ld	 c, #15*2			; N£mero de inimigos a serem movidos x2
EnMovLoop:
	ld	 a, (hl)			; Atualiza X
	inc	 a
	ld	 (hl), a
	inc	 hl
	inc	 hl

    dec  c
    xor	 a
    or	 c
    jr nz, EnMovLoop

    ret

UpdateEnemy:
	ld	 hl, #SpriteX+8+1

    ld	 c, #15 			; N£mero de inimigos a serem atualizados
EnUpdLoop:
	ld	 a, (Enm_Frm)
	ld	 (hl), a			; Frame do primeiro sprite
	inc	 hl
	inc	 hl
	or	 #0H02
	ld	 (hl), a			; Frame do segundo sprite
	inc	 hl
	inc	 hl

    dec  c
    xor	 a
    or	 c
    jr nz, EnUpdLoop

	ld	 a, (Enm_Frm)
	add	 a, #4
	and	 #0HBF
	ld	 (Enm_Frm), a		; Atualiza o quadro de animaá∆o

    ret

CheckEnemies:				; Oculta os inimigos j† mortos, checa colis‰es, etc...
	ld	 hl, #Enm_Enrg
	ld	 de, #SpriteY+4
	ld	 ix, #SpriteX+8

	ld	 c, #15				; N£mero de inimigos a serem checados
CheckEnmLoop:
	ld	 a, (hl)
	or	 a
	jr	 nz, EnmNotDead

	ld	 a, #194
	ld	 (de), a			; Se o inimigo estiver morto, coloca fora da tela
	inc	 de
	ld	 (de), a
	dec	 de
	jr	 CheckEnmDone

EnmNotDead:					; Inimigo n∆o est† morto: checa colis‰es
	ld	 a, (SpriteY+44)	; Coordenada Y do tiro do jogador
	or	 a
	jr	 z, EnmNotHit		; Se for zero, nem precisa testar a colis∆o

	sub	 a, #16
	ld	 b, a
	ld	 a, (de)
	sub	 a, b
	jr	 c, EnmNotHit		; Tiro est† abaixo do inimigo
	cp	 a, #32
	jr	 nc, EnmNotHit		; Tiro est† acima do inimigo

	ld	 a, (PlySht_X)
	sub	 a, #16
	ld	 b, a
	ld	 a, (ix)
	sub	 a, b
	jr	 c, EnmNotHit		; Tiro est† Ö direita do inimigo
	cp	 a, #24
	jr	 nc, EnmNotHit		; Tiro est† Ö esquerda do inimigo

	xor	 a
	ld	 (hl), a			; Tiro acertou o inimigo, mata o mesmo
	ld	 (SpriteY+44), a	; Elimina o tiro
	ld	 a, #0H21
	call IncPlyScore		; Premia o jogador com pontos
	call DrawPlyScore

EnmNotHit:

CheckEnmDone:
	inc	 hl
	inc	 de
	inc	 de
	inc	 ix
	inc	 ix
	inc	 ix
	inc	 ix

	dec	 c
	xor	 a
	or	 a, c
	jr	 nz, CheckEnmLoop
	
	ret

InitEnemies:
    ld   de, #0H6000+0H1000	; Endereáo dos sprites dos inimigos
    ld   hl, #Enm1Data
    ld   bc, #Enm1Count

    call TransferCharData   ; Call routine to transfer sprite data

	ld	 c, #15				; Total de inimigos
	ld	 hl, #Enm_Enrg
EnmInitLoop:
	ld	 a, #1
	ld	 (hl), a
	inc	 hl

	dec	 c
	xor	 a
	or	 c
	jr	 nz, EnmInitLoop

	ret

WaitForTransfer:
    ld   a, (Transfer)
    or   a
    jr   nz, WaitForTransfer

    ret

WaitVSyncStart:
    in   a, (0H7e)
    cp   #0Hc0
    jr   nz, WaitVSyncStart
	ret

.even
VDPRegsTable:
   .byte    0H24,0H02,0H0e,0Hff,0Hff,0Hff,0H04,0H00,0H08,0H00,0Hff

.even
PalData:
; Fundo
	.byte 0H00,0H10,0H25,0H3A
	.byte 0H10,0H10,0H25,0H3F
	.byte 0H02,0H03,0H01,0H17
	.byte 0H04,0H08,0H0C,0H04
; Sprites
	.byte 0H00,0H10,0H30,0H05
	.byte 0H15,0H35,0H0F,0H1F
	.byte 0H00,0H01,0H02,0H05
	.byte 0H06,0H0A,0H0B,0H03
PalEnd:   
PalCount = PalEnd-PalData

.even
ScreenData:
	.include "map.inc"
ScreenEnd:
ScreenCount = ScreenEnd-ScreenData

.even
CharData:
    INCBIN "tiles.bin"
    INCBIN "numbers.bin"
CharEnd:
CharCount = CharEnd-CharData

.even
SpriteData:
	INCBIN "plyship.bin"
	INCBIN "shots.bin"
SpriteEnd:
SpriteCount = SpriteEnd-SpriteData

Enm1Data:
	INCBIN "enm1.bin"
Enm1End:
Enm1Count = Enm1End-Enm1Data

.even
ListData:
    .byte  240, 130,  0
    .byte  248, 130,  2
    .byte  240, 146,  4
    .byte  248, 146,  6

    .byte    8,  8, 128
    .byte   16,  8, 130

    .byte   60,  8, 128
    .byte   68,  8, 130

    .byte  112,  8, 128
    .byte  120,  8, 130

    .byte  164,  8, 128
    .byte  172,  8, 130

    .byte  216,  8, 128
    .byte  224,  8, 130

    .byte   34, 32, 128
    .byte   42, 32, 130

    .byte   86, 32, 128
    .byte   94, 32, 130

    .byte  138, 32, 128
    .byte  146, 32, 130

    .byte  190, 32, 128
    .byte  198, 32, 130

    .byte  242, 32, 128
    .byte  250, 32, 130

    .byte    8, 56, 128
    .byte   16, 56, 130

    .byte   60, 56, 128
    .byte   68, 56, 130

    .byte  112, 56, 128
    .byte  120, 56, 130

    .byte  164, 56, 128
    .byte  172, 56, 130

    .byte  216, 56, 128
    .byte  224, 56, 130

ListEnd:
ListCount = ListEnd-ListData



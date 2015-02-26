; GameGear Routines
; Adapted for Sega Master System by Haroldo de Oliveira Pinheiro

    .include "defines.inc"
    SpriteY  = RAM_START    ; to RAM_START+64
    SpriteX  = RAM_START+64 ; to RAM_START+192 - Contains Sprite X and characters interleaved
    Joystick = RAM_START+192; to RAM_START+193
    Transfer = RAM_START+193; to RAM_START+194

    .area _CODE2 (REL)
    .module ROUTINES

ClearVRAM::
    push af

    ld   a, l               ; Setup VRAM for write to hl
    out  (0xbf), a
    ld   a, h               ; Transfer LB then HB
    out  (0xbf), a

; Clears VRAM. See routines.inc for full description
ClearVRAMLoop:
    sub  a                  ; Clear a
    out  (0xbe), a          ; Transfer byte to VRAM
    dec  bc                 ; decrement counter
    ld   a, b               ; transfer upper byte of counter to a
    or   c                  ; or with c. Check to see if both are zero
    jr   nz, ClearVRAMLoop  ; If not zero repeat

    ld  hl, #SpriteY
    ld  a,  #64

ClearSpriteY:
    ld  (hl), #0            ; Transfer byte to VRAM
    dec  a                  ; decrement counter
    or   a                  ; or with c. Check to see if both are zero
    jr   nz, ClearSpriteY   ; If not zero repeat

    ld  hl, #SpriteX
    ld  a,  #128

ClearSpriteX:
    ld  (hl), #0            ; Transfer byte to VRAM
    dec  a                  ; decrement counter
    or   a                  ; or with c. Check to see if both are zero
    jr   nz, ClearSpriteX   ; If not zero repeat

    sub  a
    ld   (Transfer), a

    pop  af

    ret

; Transfer Palette to VRAM. See routines.inc for full description
; Modified for Sega Master System
TransferPalette::
;    add  a                  ; Multiply a by 2 since GameGear palette entries are words
    out  (0xbf), a          ; Transfer low byte of palette location
    ld   a, #0xc0           ; CRAM start at $c0xx
    out  (0xbf), a          ; Transfer high byte of palette location

PalLoop:
    ld   a, (hl)            ; Load palette data
    out  (0xbe), a          ; Transfer byte to VRAM
    inc  hl                 ; increment memory location
    dec  bc                 ; decrement counter
    ld   a, b               ; transfer upper byte of counter to a
    or   c                  ; or with c. Check to see if both are zero
    jr   nz, PalLoop        ; If not zero repeat

    ret

; Transfer Character data to VRAM. See routines.inc for full description
TransferCharData::
    push af

    ld   a, e               ; Setup VRAM for write to de
    out  (0xbf), a
    ld   a, d               ; Transfer LB then HB
    out  (0xbf), a

CharLoop:
    ld   a, (hl)            ; Load char data
    out  (0xbe), a          ; Transfer byte to VRAM
    inc  hl                 ; increment memory location
    dec  bc                 ; decrement counter
    ld   a, b               ; transfer upper byte of counter to a
    or   c                  ; or with c. Check to see if both are zero
    jr   nz, CharLoop       ; If not zero repeat

    pop  af

    ret

; Turn on screen. See routines.inc for full description
ScreenOn::
    push af

    ld   a, #0x42           ; Set reigster $81 to $42
    out  (0xbf), a
    ld   a, #0x81
    out  (0xbf), a

    pop  af

    ret

; Turn on screen with vertical blank. See routines.inc for full description
ScreenOnVB::
    push af

    ld   a, #0x62           ; Set reigster $81 to $42
    out  (0xbf), a
    ld   a, #0x81
    out  (0xbf), a

    pop  af

    ret

; Turn off screen. See routines.inc for full description
ScreenOff::
    push af

    ld   a, #0x02           ; Set reigster $81 to $02
    out  (0xbf), a
    ld   a, #0x81
    out  (0xbf), a

    pop  af

    ret

; Set sprite x, y, and character from a memory location.
; See routines.inc for full description
SetSpriteList::
    push bc
    push de
    push IX
    push IY

    ld   I, a
    sub  a

ListLoop:
    ld   b, (hl)
    inc  hl
    ld   c, (hl)
    inc  hl   
    ld   d, (hl)
    inc  hl   
        
    call SetSprite
    inc  a

    ld   e, a

    ld   a, I
    dec  a
    ld   I, a

    or   #0
    ld   a, e
    
    jr   nz, ListLoop       ; If not zero repeat

    pop  iy
    pop  ix
    pop  de
    pop  bc
    ret

; Set sprite x, y, and character. See routines.inc for full description
SetSprite::
    push bc

    call SetSpriteX         ; Already set up for SetSpriteX. Call routine
    ld   b, c               ; Transfer y position into b
    call SetSpriteY         ; Call routine
    ld   b, d               ; Transfer character number into b
    call SetSpriteChar      ; Call routine

    pop  bc

    ret

; Set sprite x. See routines.inc for full description
SetSpriteX::
    push af
    push bc
    push hl

    add  a, a
    ld   hl, #SpriteX
    ld   c, l
    add  a, l
    ld   l, a
    ld   a, h
    adc  #0
    ld   h, a

    ld   (hl), b          ; Transfer x position

    pop  hl
    pop  bc
    pop  af

    ret

; Set sprite y. See routines.inc for full description
SetSpriteY::
    push af
    push bc
    push hl

    ld   hl, #SpriteY
    ld   c, l
    add  a, l
    ld   l, a
    ld   a, h
    adc  #0
    ld   h, a

    ld   (hl), b          ; Transfer y position

    pop  hl
    pop  bc
    pop  af

    ret

; Set sprite character. See routines.inc for full description
SetSpriteChar::
    push af
    push bc
    push hl

    add  a, a
    inc  a
    ld   hl, #SpriteX
    ld   c, l
    add  a, l
    ld   l, a
    ld   a, h
    adc  #0
    ld   h, a

    ld   (hl), b          ; Transfer char number

    pop  hl
    pop  bc
    pop  af

    ret

Update::
    ld  a, #1
    ld  (Transfer), a

    ret

VertBlank::
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    ex   af, af'
    exx
    push af
    push bc
    push de
    push hl
    push ix
    push iy

    call ReadJoystick
    call TransferSprites

    pop  iy
    pop  ix
    pop  hl
    pop  de
    pop  bc
    pop  af
    exx
    ex   af, af'
    pop  iy
    pop  ix
    pop  hl
    pop  de
    pop  bc
    pop  af

    ei
    ret

ReadJoystick:
    in   a, (0x0dc)
    cpl
    ld   (Joystick), a
    ret

TransferSprites:
    ld   a, (Transfer)
    or   a
    jr   z, NoTransfer      ; If not zero repeat    

    sub  a
    out  (0xbf), a
    ld   a, #0x7f
    out  (0xbf), a

    ld   hl, #SpriteY
    ld   b,  #64

SpriteYLoop:
    ld   a, (hl)
    out  (0xbe), a
    inc  hl
    dec  b
    ld   a, b               ; transfer upper byte of counter to a
    or   b                  ; or with c. Check to see if both are zero
    jr   nz, SpriteYLoop    ; If not zero repeat

    ld   a, #0x80
    out  (0xbf), a
    ld   a, #0x7f
    out  (0xbf), a

    ld   hl, #SpriteX
    ld   b, #128

SpriteXLoop:
    ld   a, (hl)
    out  (0xbe), a
    inc  hl
    dec  b
    ld   a, b               ; transfer upper byte of counter to a
    or   b                  ; or with c. Check to see if both are zero
    jr   nz, SpriteXLoop    ; If not zero repeat

    sub  a
    ld   (Transfer), a

NoTransfer:
    ret


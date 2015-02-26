;==============================================================
; WLA-DX banking setup
;==============================================================
.memorymap
defaultslot 0
slotsize $8000
slot 0 $0000
.endme

.rombankmap
bankstotal 1
banksize $8000
banks 1
.endro

;==============================================================
; SDSC tag and SMS rom header
;==============================================================
.sdsctag 1.10,"Hello World!","SMS programming tutorial program (bugfixed)","Maxim"

.bank 0 slot 0
.org $0000
;==============================================================
; Boot section
;==============================================================
    di              ; disable interrupts
    im 1            ; Interrupt mode 1
    jp main         ; jump to main program

.org $0066
;==============================================================
; Pause button handler
;==============================================================
    ; Do nothing
    retn

;==============================================================
; Main program
;==============================================================
main:
    ld sp, $dff0

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

    ;==============================================================
    ; Load tiles (font)
    ;==============================================================
    ; 1. Set VRAM write address to tile index 0
    ; by outputting $4000 ORed with $0000
    ld a,$00
    out ($bf),a
    ld a,$40
    out ($bf),a
    ; 2. Output tile data
    ld hl,FontData              ; Location of tile data
    ld bc,FontDataEnd-FontData  ; Counter for number of bytes to write
    WriteTilesLoop:
        ; Output data byte then three zeroes, because our tile data is 1 bit
        ; and must be increased to 4 bit
        ld a,(hl)        ; Get data byte
        out ($be),a
        ld a,$00
        out ($be),a
        out ($be),a
        out ($be),a
        inc hl           ; Add one to hl so it points to the next data byte
        dec c
        jp nz,WriteTilesLoop
        dec b
        jp nz,WriteTilesLoop

    ;==============================================================
    ; Write text to name table
    ;==============================================================
    ; 1. Set VRAM write address to name table index 0
    ; by outputting $4000 ORed with $3800+0
    ld a,$00
    out ($bf),a
    ld a,$38|$40
    out ($bf),a
    ; 2. Loop through text data, converting from ASCII ans writing tile indices
    ; to name table. Stop when a zero byte is found.
    ld hl,Message
    WriteTextLoop:
        ld a,(hl)    ; Get data byte
        cp $00       ; Is it zero?
        jp z,EndWriteTextLoop    ; If so, exit loop
        sub $20      ; In ASCII, space=$20 and the rest follow on. We want space=$00 so we subtract $20.
        out ($be),a
        ld a,$00
        out ($be),a
        inc hl       ; Point to next letter
        jp WriteTextLoop

    EndWriteTextLoop:

    ; Turn screen on
    ld a,%11000100
;          |||| |`- Zoomed sprites -> 16x16 pixels
;          |||| `-- Doubled sprites -> 2 tiles per sprite, 8x16
;          |||`---- 30 row/240 line mode
;          ||`----- 28 row/224 line mode
;          |`------ VBlank interrupts
;          `------- Enable display
    out ($bf),a
    ld a,$81
    out ($bf),a

    ; Infinite loop to stop program
    Loop:
         jp Loop

;==============================================================
; Data
;==============================================================

Message:
.db "Hello world!",0

PaletteData:
.db $00,$3f ; Black, White
PaletteDataEnd:

; VDP initialisation data
VdpData:
.db $04,$80,$84,$81,$ff,$82,$ff,$85,$ff,$86,$ff,$87,$00,$88,$00,$89,$ff,$8a
VdpDataEnd:

FontData:
; This font data was provided by Mike G and is reproduced here in its entirety:


;------------------------------------------
; In loving memory of Acorn Computers Ltd.
;      Mike G proudly presents the:
;
;       BBC Micro Character Set!
;       ========================
;
; This source was created automatically
; from character data stored in the BBC
; Microcomputer operating system ROM.
;
; The BBC set is a nice, clear font which
; (unlike the classic Namco/Sega font)
; includes lower-case letters as well as
; upper-case.
;
; Being a British micro, there's even a
; Pound Sterling currency symbol, which
; should come in handy when I begin to
; write financial apps on the SMS. (Just
; kidding!)
;
; Hopefully by using binary representation
; it will be obvious how the character
; data is stored.
;
;------------------------------------------


 ; Character 0x20 (space)

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h



 ; Character 0x21 !

.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h



 ; Character 0x22 "

.DB %01101100    ; Hex 6Ch
.DB %01101100    ; Hex 6Ch
.DB %01101100    ; Hex 6Ch
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h



 ; Character 0x23 #

.DB %00110110    ; Hex 36h
.DB %00110110    ; Hex 36h
.DB %01111111    ; Hex 7Fh
.DB %00110110    ; Hex 36h
.DB %01111111    ; Hex 7Fh
.DB %00110110    ; Hex 36h
.DB %00110110    ; Hex 36h
.DB %00000000    ; Hex 00h



 ; Character 0x24 $

.DB %00001100    ; Hex 0Ch
.DB %00111111    ; Hex 3Fh
.DB %01101000    ; Hex 68h
.DB %00111110    ; Hex 3Eh
.DB %00001011    ; Hex 0Bh
.DB %01111110    ; Hex 7Eh
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h



 ; Character 0x25 %

.DB %01100000    ; Hex 60h
.DB %01100110    ; Hex 66h
.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %01100110    ; Hex 66h
.DB %00000110    ; Hex 06h
.DB %00000000    ; Hex 00h



 ; Character 0x26 &

.DB %00111000    ; Hex 38h
.DB %01101100    ; Hex 6Ch
.DB %01101100    ; Hex 6Ch
.DB %00111000    ; Hex 38h
.DB %01101101    ; Hex 6Dh
.DB %01100110    ; Hex 66h
.DB %00111011    ; Hex 3Bh
.DB %00000000    ; Hex 00h



 ; Character 0x27 '

.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h



 ; Character 0x28 (

.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %00110000    ; Hex 30h
.DB %00110000    ; Hex 30h
.DB %00011000    ; Hex 18h
.DB %00001100    ; Hex 0Ch
.DB %00000000    ; Hex 00h



 ; Character 0x29 )

.DB %00110000    ; Hex 30h
.DB %00011000    ; Hex 18h
.DB %00001100    ; Hex 0Ch
.DB %00001100    ; Hex 0Ch
.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %00000000    ; Hex 00h



 ; Character 0x2A *

.DB %00000000    ; Hex 00h
.DB %00011000    ; Hex 18h
.DB %01111110    ; Hex 7Eh
.DB %00111100    ; Hex 3Ch
.DB %01111110    ; Hex 7Eh
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h



 ; Character 0x2B +

.DB %00000000    ; Hex 00h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %01111110    ; Hex 7Eh
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h



 ; Character 0x2C ,

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h



 ; Character 0x2D -

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %01111110    ; Hex 7Eh
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h



 ; Character 0x2E .

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h



 ; Character 0x2F /

.DB %00000000    ; Hex 00h
.DB %00000110    ; Hex 06h
.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %01100000    ; Hex 60h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h



 ; Character 0x30 0

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01101110    ; Hex 6Eh
.DB %01111110    ; Hex 7Eh
.DB %01110110    ; Hex 76h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x31 1

.DB %00011000    ; Hex 18h
.DB %00111000    ; Hex 38h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %01111110    ; Hex 7Eh
.DB %00000000    ; Hex 00h



 ; Character 0x32 2

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %00000110    ; Hex 06h
.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %01111110    ; Hex 7Eh
.DB %00000000    ; Hex 00h



 ; Character 0x33 3

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %00000110    ; Hex 06h
.DB %00011100    ; Hex 1Ch
.DB %00000110    ; Hex 06h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x34 4

.DB %00001100    ; Hex 0Ch
.DB %00011100    ; Hex 1Ch
.DB %00111100    ; Hex 3Ch
.DB %01101100    ; Hex 6Ch
.DB %01111110    ; Hex 7Eh
.DB %00001100    ; Hex 0Ch
.DB %00001100    ; Hex 0Ch
.DB %00000000    ; Hex 00h



 ; Character 0x35 5

.DB %01111110    ; Hex 7Eh
.DB %01100000    ; Hex 60h
.DB %01111100    ; Hex 7Ch
.DB %00000110    ; Hex 06h
.DB %00000110    ; Hex 06h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x36 6

.DB %00011100    ; Hex 1Ch
.DB %00110000    ; Hex 30h
.DB %01100000    ; Hex 60h
.DB %01111100    ; Hex 7Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x37 7

.DB %01111110    ; Hex 7Eh
.DB %00000110    ; Hex 06h
.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %00110000    ; Hex 30h
.DB %00110000    ; Hex 30h
.DB %00000000    ; Hex 00h



 ; Character 0x38 8

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x39 9

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111110    ; Hex 3Eh
.DB %00000110    ; Hex 06h
.DB %00001100    ; Hex 0Ch
.DB %00111000    ; Hex 38h
.DB %00000000    ; Hex 00h



 ; Character 0x3A :

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h



 ; Character 0x3B ;

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h



 ; Character 0x3C <

.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %01100000    ; Hex 60h
.DB %00110000    ; Hex 30h
.DB %00011000    ; Hex 18h
.DB %00001100    ; Hex 0Ch
.DB %00000000    ; Hex 00h



 ; Character 0x3D =

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %01111110    ; Hex 7Eh
.DB %00000000    ; Hex 00h
.DB %01111110    ; Hex 7Eh
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h



 ; Character 0x3E >

.DB %00110000    ; Hex 30h
.DB %00011000    ; Hex 18h
.DB %00001100    ; Hex 0Ch
.DB %00000110    ; Hex 06h
.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %00000000    ; Hex 00h



 ; Character 0x3F ?

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h



 ; Character 0x40 @

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01101110    ; Hex 6Eh
.DB %01101010    ; Hex 6Ah
.DB %01101110    ; Hex 6Eh
.DB %01100000    ; Hex 60h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x41 A

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01111110    ; Hex 7Eh
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00000000    ; Hex 00h



 ; Character 0x42 B

.DB %01111100    ; Hex 7Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01111100    ; Hex 7Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01111100    ; Hex 7Ch
.DB %00000000    ; Hex 00h



 ; Character 0x43 C

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x44 D

.DB %01111000    ; Hex 78h
.DB %01101100    ; Hex 6Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01101100    ; Hex 6Ch
.DB %01111000    ; Hex 78h
.DB %00000000    ; Hex 00h



 ; Character 0x45 E

.DB %01111110    ; Hex 7Eh
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01111100    ; Hex 7Ch
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01111110    ; Hex 7Eh
.DB %00000000    ; Hex 00h



 ; Character 0x46 F

.DB %01111110    ; Hex 7Eh
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01111100    ; Hex 7Ch
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %00000000    ; Hex 00h



 ; Character 0x47 G

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100000    ; Hex 60h
.DB %01101110    ; Hex 6Eh
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x48 H

.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01111110    ; Hex 7Eh
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00000000    ; Hex 00h



 ; Character 0x49 I

.DB %01111110    ; Hex 7Eh
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %01111110    ; Hex 7Eh
.DB %00000000    ; Hex 00h



 ; Character 0x4A J

.DB %00111110    ; Hex 3Eh
.DB %00001100    ; Hex 0Ch
.DB %00001100    ; Hex 0Ch
.DB %00001100    ; Hex 0Ch
.DB %00001100    ; Hex 0Ch
.DB %01101100    ; Hex 6Ch
.DB %00111000    ; Hex 38h
.DB %00000000    ; Hex 00h



 ; Character 0x4B K

.DB %01100110    ; Hex 66h
.DB %01101100    ; Hex 6Ch
.DB %01111000    ; Hex 78h
.DB %01110000    ; Hex 70h
.DB %01111000    ; Hex 78h
.DB %01101100    ; Hex 6Ch
.DB %01100110    ; Hex 66h
.DB %00000000    ; Hex 00h



 ; Character 0x4C L

.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01111110    ; Hex 7Eh
.DB %00000000    ; Hex 00h



 ; Character 0x4D M

.DB %01100011    ; Hex 63h
.DB %01110111    ; Hex 77h
.DB %01111111    ; Hex 7Fh
.DB %01101011    ; Hex 6Bh
.DB %01101011    ; Hex 6Bh
.DB %01100011    ; Hex 63h
.DB %01100011    ; Hex 63h
.DB %00000000    ; Hex 00h



 ; Character 0x4E N

.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01110110    ; Hex 76h
.DB %01111110    ; Hex 7Eh
.DB %01101110    ; Hex 6Eh
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00000000    ; Hex 00h



 ; Character 0x4F O

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x50 P

.DB %01111100    ; Hex 7Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01111100    ; Hex 7Ch
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %00000000    ; Hex 00h



 ; Character 0x51 Q

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01101010    ; Hex 6Ah
.DB %01101100    ; Hex 6Ch
.DB %00110110    ; Hex 36h
.DB %00000000    ; Hex 00h



 ; Character 0x52 R

.DB %01111100    ; Hex 7Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01111100    ; Hex 7Ch
.DB %01101100    ; Hex 6Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00000000    ; Hex 00h



 ; Character 0x53 S

.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100000    ; Hex 60h
.DB %00111100    ; Hex 3Ch
.DB %00000110    ; Hex 06h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x54 T

.DB %01111110    ; Hex 7Eh
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h



 ; Character 0x55 U

.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x56 V

.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h



 ; Character 0x57 W

.DB %01100011    ; Hex 63h
.DB %01100011    ; Hex 63h
.DB %01101011    ; Hex 6Bh
.DB %01101011    ; Hex 6Bh
.DB %01111111    ; Hex 7Fh
.DB %01110111    ; Hex 77h
.DB %01100011    ; Hex 63h
.DB %00000000    ; Hex 00h



 ; Character 0x58 X

.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00011000    ; Hex 18h
.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00000000    ; Hex 00h



 ; Character 0x59 Y

.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h



 ; Character 0x5A Z

.DB %01111110    ; Hex 7Eh
.DB %00000110    ; Hex 06h
.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %01100000    ; Hex 60h
.DB %01111110    ; Hex 7Eh
.DB %00000000    ; Hex 00h



 ; Character 0x5B [

.DB %01111100    ; Hex 7Ch
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01111100    ; Hex 7Ch
.DB %00000000    ; Hex 00h



 ; Character 0x5C \

.DB %00000000    ; Hex 00h
.DB %01100000    ; Hex 60h
.DB %00110000    ; Hex 30h
.DB %00011000    ; Hex 18h
.DB %00001100    ; Hex 0Ch
.DB %00000110    ; Hex 06h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h



 ; Character 0x5D ]

.DB %00111110    ; Hex 3Eh
.DB %00000110    ; Hex 06h
.DB %00000110    ; Hex 06h
.DB %00000110    ; Hex 06h
.DB %00000110    ; Hex 06h
.DB %00000110    ; Hex 06h
.DB %00111110    ; Hex 3Eh
.DB %00000000    ; Hex 00h



 ; Character 0x5E ^

.DB %00011000    ; Hex 18h
.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01000010    ; Hex 42h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h



 ; Character 0x5F (underscore)

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %11111111    ; Hex FFh



 ; Character 0x60 (Pound Sterling)

.DB %00011100    ; Hex 1Ch
.DB %00110110    ; Hex 36h
.DB %00110000    ; Hex 30h
.DB %01111100    ; Hex 7Ch
.DB %00110000    ; Hex 30h
.DB %00110000    ; Hex 30h
.DB %01111110    ; Hex 7Eh
.DB %00000000    ; Hex 00h



 ; Character 0x61 a

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00111100    ; Hex 3Ch
.DB %00000110    ; Hex 06h
.DB %00111110    ; Hex 3Eh
.DB %01100110    ; Hex 66h
.DB %00111110    ; Hex 3Eh
.DB %00000000    ; Hex 00h



 ; Character 0x62 b

.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01111100    ; Hex 7Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01111100    ; Hex 7Ch
.DB %00000000    ; Hex 00h



 ; Character 0x63 c

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100000    ; Hex 60h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x64 d

.DB %00000110    ; Hex 06h
.DB %00000110    ; Hex 06h
.DB %00111110    ; Hex 3Eh
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111110    ; Hex 3Eh
.DB %00000000    ; Hex 00h



 ; Character 0x65 e

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01111110    ; Hex 7Eh
.DB %01100000    ; Hex 60h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x66 f

.DB %00011100    ; Hex 1Ch
.DB %00110000    ; Hex 30h
.DB %00110000    ; Hex 30h
.DB %01111100    ; Hex 7Ch
.DB %00110000    ; Hex 30h
.DB %00110000    ; Hex 30h
.DB %00110000    ; Hex 30h
.DB %00000000    ; Hex 00h



 ; Character 0x67 g

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00111110    ; Hex 3Eh
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111110    ; Hex 3Eh
.DB %00000110    ; Hex 06h
.DB %00111100    ; Hex 3Ch



 ; Character 0x68 h

.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01111100    ; Hex 7Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00000000    ; Hex 00h



 ; Character 0x69 i

.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h
.DB %00111000    ; Hex 38h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x6A j

.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h
.DB %00111000    ; Hex 38h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %01110000    ; Hex 70h



 ; Character 0x6B k

.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100110    ; Hex 66h
.DB %01101100    ; Hex 6Ch
.DB %01111000    ; Hex 78h
.DB %01101100    ; Hex 6Ch
.DB %01100110    ; Hex 66h
.DB %00000000    ; Hex 00h



 ; Character 0x6C l

.DB %00111000    ; Hex 38h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x6D m

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00110110    ; Hex 36h
.DB %01111111    ; Hex 7Fh
.DB %01101011    ; Hex 6Bh
.DB %01101011    ; Hex 6Bh
.DB %01100011    ; Hex 63h
.DB %00000000    ; Hex 00h



 ; Character 0x6E n

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %01111100    ; Hex 7Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00000000    ; Hex 00h



 ; Character 0x6F o

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00000000    ; Hex 00h



 ; Character 0x70 p

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %01111100    ; Hex 7Ch
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01111100    ; Hex 7Ch
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h



 ; Character 0x71 q

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00111110    ; Hex 3Eh
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111110    ; Hex 3Eh
.DB %00000110    ; Hex 06h
.DB %00000111    ; Hex 07h



 ; Character 0x72 r

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %01101100    ; Hex 6Ch
.DB %01110110    ; Hex 76h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %01100000    ; Hex 60h
.DB %00000000    ; Hex 00h



 ; Character 0x73 s

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00111110    ; Hex 3Eh
.DB %01100000    ; Hex 60h
.DB %00111100    ; Hex 3Ch
.DB %00000110    ; Hex 06h
.DB %01111100    ; Hex 7Ch
.DB %00000000    ; Hex 00h



 ; Character 0x74 t

.DB %00110000    ; Hex 30h
.DB %00110000    ; Hex 30h
.DB %01111100    ; Hex 7Ch
.DB %00110000    ; Hex 30h
.DB %00110000    ; Hex 30h
.DB %00110000    ; Hex 30h
.DB %00011100    ; Hex 1Ch
.DB %00000000    ; Hex 00h



 ; Character 0x75 u

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111110    ; Hex 3Eh
.DB %00000000    ; Hex 00h



 ; Character 0x76 v

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h



 ; Character 0x77 w

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %01100011    ; Hex 63h
.DB %01101011    ; Hex 6Bh
.DB %01101011    ; Hex 6Bh
.DB %01111111    ; Hex 7Fh
.DB %00110110    ; Hex 36h
.DB %00000000    ; Hex 00h



 ; Character 0x78 x

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %01100110    ; Hex 66h
.DB %00111100    ; Hex 3Ch
.DB %00011000    ; Hex 18h
.DB %00111100    ; Hex 3Ch
.DB %01100110    ; Hex 66h
.DB %00000000    ; Hex 00h



 ; Character 0x79 y

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %01100110    ; Hex 66h
.DB %00111110    ; Hex 3Eh
.DB %00000110    ; Hex 06h
.DB %00111100    ; Hex 3Ch



 ; Character 0x7A z

.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %01111110    ; Hex 7Eh
.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %01111110    ; Hex 7Eh
.DB %00000000    ; Hex 00h



 ; Character 0x7B {

.DB %00001100    ; Hex 0Ch
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %01110000    ; Hex 70h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00001100    ; Hex 0Ch
.DB %00000000    ; Hex 00h



 ; Character 0x7C (OR symbol)

.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00000000    ; Hex 00h



 ; Character 0x7D }

.DB %00110000    ; Hex 30h
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00001110    ; Hex 0Eh
.DB %00011000    ; Hex 18h
.DB %00011000    ; Hex 18h
.DB %00110000    ; Hex 30h
.DB %00000000    ; Hex 00h



 ; Character 0x7E ~

.DB %00110001    ; Hex 31h
.DB %01101011    ; Hex 6Bh
.DB %01000110    ; Hex 46h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h
.DB %00000000    ; Hex 00h



 ; Character 0x7F (block)

.DB %11111111    ; Hex FFh
.DB %11111111    ; Hex FFh
.DB %11111111    ; Hex FFh
.DB %11111111    ; Hex FFh
.DB %11111111    ; Hex FFh
.DB %11111111    ; Hex FFh
.DB %11111111    ; Hex FFh
.DB %11111111    ; Hex FFh


;------------------------------------------
;
; That's all folks! Now that Acorn is no
; longer with us (RIP), it should be safe
; to use this font in any homebrew 
; projects.
;
; Anyone is welcome to distribute and use
; this source file for whatever purpose
; they wish.
;
;
; Best wishes,
;
; Mike G. (mike@mikeg2.freeserve.co.uk)
;
; 4th March 2001
;
; SMS Power! - www.smspower.org
; SMSReader - www.smspower.org/smsreader/
;
; My Home Page: www.mikeg2.freeserve.co.uk
;
;------------------------------------------


; End of Mike G's font.
FontDataEnd:


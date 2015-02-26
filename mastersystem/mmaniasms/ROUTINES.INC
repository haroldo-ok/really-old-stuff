; Game Gear routines

.globl ClearVRAM
; Clears out VRAM.
; Load HL with the start of VRAM to clear.
; Load BC with the bytes to clear

.globl TransferPalette
; Transfer Palette
; Load A with the index to start at
; Load HL with address of the palette
; Load BC with the bytes to transfer

.globl TransferCharData
; Transfer Palette
; Load DE with the VRAM address
; Load HL with address of the char data
; Load BC with the bytes to transfer

.globl ScreenOnVB
; Turn Screen on with Vertical Blanking interrupts
; No input

.globl ScreenOn
; Turn Screen on
; No input

.globl ScreenOff
; Turn Screen off
; No input

.globl SetSpriteList
; Set sprite x, y, and charcter from a memory list
; Load HL with location of the list.
; Load A with number of sprites in the list.

.globl SetSprite
; Set sprite x, y, and charcter
; Load A with the sprite number.
; Load B with the x position.
; Load C with the y position.
; Load D with the character number.

.globl SetSpriteX
; Set sprite x
; Load A with the sprite number.
; Load B with the x position.

.globl SetSpriteY
; Set sprite y
; Load A with the sprite number.
; Load B with the y position.

.globl SetSpriteChar
; Set sprite character
; Load A with the sprite number.
; Load B with the character number.

.globl Update
; Causes the sprite table to be transferred
; No input

.globl VertBlank
; Internal Vertical Blank routine


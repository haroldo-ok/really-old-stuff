; GameGear Header

    .module HEADER

    .include "routines.inc"
    .globl waitforline

    .area _ABSHEADER (ABS)
    .org 0H0000

    di
    im   1                  ;Interrupt Mode 1
    ld   hl, (0H0fffc)      ;Select Bank 2 by putting bank number at 0Hffff
    xor  a
    ld   (hl), a
    inc  l
    ld   (hl), a
    inc  l
    inc  l
    ld   (hl), #0H02        ; Bank Number
    ld   sp, #0Hc200
    jp   waitforline

    .org 0H0038
    jp  VertBlank

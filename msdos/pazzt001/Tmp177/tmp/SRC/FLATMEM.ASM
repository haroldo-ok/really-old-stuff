;This Code is blatantly derived from:
;----------------------------------------------------------------------------
;                      MASSiVE Flat Real mode routines
;                               (Version 1.0B)
;                                    by
;                               NiX/MASSiVE
;                            Butterfly/MASSiVE
;
;---------------------------------------------------------------------------

.486P   ; 486 Code of course...

.MODEL USE16 LARGE

.DATA

   ; Descriptors and stuff used for setting up FRM
   mem32_GDT       dw      4 dup(0)

   Code16GDT = 8
                   dw      0FFFFh,00FFh,9A00h,0000h
   Data16GDT = 16
                   dw      0FFFFh,00FFh,9200h,0000h
   Data32GDT = 24
                   dw      0FFFFh,0000h,9200h,008Fh
   GDTptr label fword
                   dw      offset GDTptr-1-offset Mem32_GDT
                   dw      offset Mem32_GDT, 0  ; Absolute adress GDTtable
                   dw      0

.CODE

InitFlatMem PROC FAR
PUBLIC InitFlatMem
;-------------------------------------------------------------------------
; This routine sets up a 4Gigabyte limit descriptor with base addres 00000h.
; This is not possible in V86 mode.
; If computer is in V86 mode the carry will be set on return, and you
; are still in RM.
;-------------------------------------------------------------------------
     mov     eax,cr0   ; Check for V86 mode
     ror     eax,1     ;
     jnc     OKFor32   ; If no carry all's OK.
     mov ax,0          ; else exit as false
     retf
OKFor32:
     mov     ax,ds     ; Set up GDT for DATA segment
     movzx   eax,ax
     shl     eax,4
     add     dword ptr ds:GDTptr+2,eax
     lgdt    fword ptr ds:GDTptr

     mov     ax,cs
     and     eax,65535
     shl     eax,4
     mov     word ptr ds:Mem32_GDT[Code16GDT+2],ax
     ror     eax,16
     mov     byte ptr ds:Mem32_GDT[Code16GDT+4],al
     mov     byte ptr ds:Mem32_GDT[Code16GDT+7],ah

     mov     ax,ds
     and     eax,65535
     shl     eax,4
     mov     word ptr ds:Mem32_GDT[Data16GDT+2],ax
     ror     eax,16
     mov     byte ptr ds:Mem32_GDT[Data16GDT+4],al
     mov     byte ptr ds:Mem32_GDT[Data16GDT+7],ah

     mov ax,1
     retf

InitFlatMem ENDP

SetGSto4G PROC FAR
PUBLIC SetGSto4G
;--------------------------------------------------------------
; Sets GS to a 32 bit descriptor with base address 00000h
;--------------------------------------------------------------
     cli    ; No ints
     push eax

; Beam us to PMODE!!
     mov     eax,cr0
     or      al,1
     mov     cr0,eax

     db      0eah               ; Far jump to PMODE label
     dw      offset ESPmode
     dw      Code16GDT

; We're in PMODE!!
ESPmode:
   ; Set GS to 4Gig
     mov     ax,Data32GDT
     mov     gs,ax

; Beaming out!
     mov     eax,cr0
     and     al,0feh
     mov     cr0,eax

     db      0eah           ; Far jump to Rmode label.
     dw      offset ESRmode
     dw      @CODE

; Back in the real world!
ESRmode:
     clc  ; No carry, everything went OK
     pop eax
     sti  ; Ints Back on.
     retf

SetGSto4G endp

ENDS
END



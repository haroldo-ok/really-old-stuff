.IFNDEF PSGMOD_SUPPORT_GG_STEREO
  .PRINTT "psgmod.asm:\n"
  .PRINTT "PSGMOD_SUPPORT_GG_STEREO must be defined.\n"
  .FAIL
.ENDIF
.IFNDEF PSGMOD_START_ADDRESS
  .PRINTT "psgmod.asm:\n"
  .PRINTT "PSGMOD_START_ADDRESS must be defined.\n"
  .FAIL
.ENDIF
.IF PSGMOD_START_ADDRESS & 255 != 0
  .PRINTT "psgmod.asm:\n"
  .PRINTT "PSGMOD_START_ADDRESS must be aligned to 256 bytes.\n"
  .FAIL
.ENDIF

;--------------------------
; PSGMOD_LoadModule(A, HL)
PSGMOD_LoadModule:
  ld   b, a
  ld   a, ($FFFF)
  push af
  ld   a, b
  ld   (PSGMOD_FRAME), a
  ld   ($FFFF), a
  ld   (PSGMOD_ADDRESS), hl
  
  ld   c, (hl)
  inc  hl
  ld   b, (hl)
  inc  hl
  ld   (PSGMOD_LENGTH), bc
  ld   (PSGMOD_LENGTH_CNT), bc
  
  ld   de, PSGMOD_INSTRUMENTS
  ld   bc, 256
  ldir
  
  ld   e, PSGMOD_INITIAL_SPEED & 255
  ldi
  ldi ; INITIAL_GG_STEREO
  ldi ; REPEAT_POINT
  ldi
  
  ld   (PSGMOD_SEQ_LIST_START_PTR), hl
  ld   (PSGMOD_SEQ_LIST_PTR), hl
  call PSGMOD_StartSequences
  
  call PSGMOD_ResetPlayer
  
  pop  af
  ld   ($FFFF), a
  ret

;-------------------
PSGMOD_ResetPlayer:
  ld a, (PSGMOD_INITIAL_SPEED)
  ld (PSGMOD_SPEED), a
  ld a, (PSGMOD_INITIAL_GG_STEREO)
  ld (PSGMOD_GG_STEREO), a
  
  ld   a, 7
  ld   (PSGMOD_SPEED_CNT), a
  xor  a
  ld   (PSGMOD_STARTED), a
  
  ld hl, PSGMOD_INSTRUMENTS
  ld (PSGMOD_INSTR_PTR), hl
  ld (PSGMOD_INSTR_PTR+2), hl
  ld (PSGMOD_INSTR_PTR+4), hl
  ld (PSGMOD_INSTR_PTR+6), hl
  
  ld hl, $0101
  ld (PSGMOD_SEQ_WAIT), hl
  ld (PSGMOD_SEQ_WAIT+2), hl
  dec h
  dec l
  ld (PSGMOD_PHASE_VOLUME), hl
  ld (PSGMOD_PHASE_VOLUME+2), hl
  ld (PSGMOD_VOLUME), hl
  ld (PSGMOD_VOLUME+2), hl
  ld (PSGMOD_PULSE_VIBRATO), hl
  ; A = 0
  ld (PSGMOD_PHASE_VOLUME_ADD_0), a
  ld (PSGMOD_PHASE_VOLUME_ADD_1), a
  ld (PSGMOD_PHASE_VOLUME_ADD_2), a
  ld (PSGMOD_PHASE_VOLUME_ADD_3), a
  ld (PSGMOD_PULSE_VIBRATO + 2), a
  dec a
  ld (PSGMOD_PHASE_DELAY_0), a
  ld (PSGMOD_PHASE_DELAY_1), a
  ld (PSGMOD_PHASE_DELAY_2), a
  ld (PSGMOD_PHASE_DELAY_3), a
  ; H = 0
  ld l, $F0
  ld (PSGMOD_FREQUENCY), hl
  ld (PSGMOD_FREQUENCY + 2), hl
  ld (PSGMOD_FREQUENCY + 4), hl
  ld a, $E0                            ; high periodic noise
  ld (PSGMOD_FREQUENCY+6), a
  ld hl, 13 + (13 << 8)
  ld (PSGMOD_INSTR_PTR), hl
  ld (PSGMOD_INSTR_PTR+2), hl
  ld hl, $8000
  ld (PSGMOD_VIBPOS), hl
  ld (PSGMOD_VIBPOS+2), hl
  ld (PSGMOD_VIBPOS+4), hl
  ld a, $55 ; Eigentlich $AA; wegen erstem TriggerLine
  ld (PSGMOD_PULSE_VIBRATO_MASK), a
  ret

;----------------
; PSGMOD_Start()
PSGMOD_Start:
  ld   a, 1
  jp   +
;----------------
; PSGMOD_Pause()
PSGMOD_Pause:
  xor  a
+:
  ld   (PSGMOD_STARTED), a
;----------------
PSGMOD_ResetPSG:
  ld   bc, (10 << 8) | (PSGMOD_PSG_PORT)
  ld   hl, PSGMOD_ResetPSG_Table
  otir
  
  ld   a, (PSGMOD_FREQUENCY + 6)
  out  (PSGMOD_PSG_PORT), a
  ret
PSGMOD_ResetPSG_Table:
; Set all volumes to 0
.db (15|144),(15|144)+32,(15|144)+64,(15|144)+96
; Set tone channel frequencies to 0
.db 128,0,128+32,0,128+64,0

;---------------
; PSGMOD_Play()
PSGMOD_Play:
  ld   a, (PSGMOD_STARTED)
  and  a
  jp   Z, PSGMOD_ResetPSG
;-------------------------------------------------------
  
  ;
  ; Trigger line
  ;
  ld   a, (PSGMOD_SPEED_CNT)
  sub  8
  jp   C, PSGMOD_Play_TriggerLine
  ld   (PSGMOD_SPEED_CNT), a
PSGMOD_Play_TriggerLine_Cont:
  
  ;
  ; Soundeffekte
  ;
  ld a, (PSGMOD_SFX_2_PRIORITY)
  or a
  jr Z, PSGMOD_Play_NoSFX_2
  
  ld hl, PSGMOD_SFX_2_CNT
  ld a, (hl)
  sub 1                           ; nicht dec, wegen C-Flag
  ld (hl), a
  ;cp -1
  jr NC, PSGMOD_Play_NoSFX_2_End
  
  xor a
  ld (PSGMOD_SFX_2_PRIORITY), a
  
  ;
  ; Frequenz zurücksetzen
  ;
  ld a, (PSGMOD_PULSE_VIBRATO_MASK)
  or a
  ld hl, (PSGMOD_FREQUENCY+4)
  jr Z, PSGMOD_Play_ResetFreq2_NoVib
  ld d, 0
  ld a, (PSGMOD_PULSE_VIBRATO + 2)
  ld e, a
  add hl, de
PSGMOD_Play_ResetFreq2_NoVib:
  
  ld a, l
  and 15
  or 128+64
  out (PSGMOD_PSG_PORT), a
  
  ld a, l
  rrca
  rrca
  rrca
  rrca
  and 15
  ld b, a
  ld a, h
  and 3
  rrca
  rrca
  rrca
  rrca
  or b
  out (PSGMOD_PSG_PORT), a
  ;
  ;
  ;
  jr PSGMOD_Play_NoSFX_2
PSGMOD_Play_NoSFX_2_End:
  
  ld hl, (PSGMOD_SFX_2_ADDRESS)
  outi
  outi
  outi
  ld (PSGMOD_SFX_2_ADDRESS), hl
  
PSGMOD_Play_NoSFX_2:
  
  ld a, (PSGMOD_SFX_3_PRIORITY)
  or a
  jr Z, PSGMOD_Play_NoSFX_3
  
  ld hl, PSGMOD_SFX_3_CNT
  ld a, (hl)
  sub 1                           ; nicht dec, wegen C-Flag
  ld (hl), a
  ;cp -1
  jr NC, PSGMOD_Play_NoSFX_3_End
  
  xor a
  ld (PSGMOD_SFX_3_PRIORITY), a
  ld a, (PSGMOD_FREQUENCY + 6)
  out (PSGMOD_PSG_PORT), a
  jr PSGMOD_Play_NoSFX_3
  
PSGMOD_Play_NoSFX_3_End:
  ld hl, (PSGMOD_SFX_3_ADDRESS)
  ld a, (hl)
  inc hl
  or a
  jr Z, PSGMOD_Play_SFX_3_
  ld a, (hl)
  inc hl
  out (PSGMOD_PSG_PORT), a
  PSGMOD_Play_SFX_3_:
  ld a, (hl)
  inc hl
  out (PSGMOD_PSG_PORT), a
  ld (PSGMOD_SFX_3_ADDRESS), hl
  
PSGMOD_Play_NoSFX_3:
  
;-------------------------------------------------------
  
.MACRO _PSGMOD_SET_TONE_CHANNEL_PSG
  ; \1 == Channel
  ; \2 == Channel * 2
  ; C = 15
  
  ; Volume
  .IF \1 == 2
  ld   a, (PSGMOD_SFX_2_PRIORITY)
  and  a
  jr   NZ, ++
  .ENDIF
  .IF \1 == 3
  ld   a, (PSGMOD_SFX_3_PRIORITY)
  and  a
  jr   NZ, ++
  .ENDIF
  
  ld   a, (PSGMOD_VOLUME + \1)
  ld   d, a
  ld   a, (PSGMOD_PHASE_VOLUME + \1)
  rrca
  rrca
  rrca
  rrca
  and  c
  add  a, d
  sub  c
  jp   NC, +
  xor  a
+:
  xor  ($60 - (32 * \1)) ~ $FF
  out  (PSGMOD_PSG_PORT), a
  
  ; Frequency
  .IF \1 != 3
  ld   hl, (PSGMOD_FREQUENCY + \2)
  
  ld   de, 0
  ld   a, (PSGMOD_PULSE_VIBRATO_MASK)
  rrca
  jp   NC, +
  ld   a, (PSGMOD_PULSE_VIBRATO + \1)
  ld   e, a
+:
  add  hl, de
  ld   a, l
  or   $F0
  ld   l, a
  ld   de, (PSGMOD_VIBPOS + \2)
  ld   a, (de)
  ld   b, a
  inc  e
  ld   a, (de)
  ld   d, a
  inc  e
  ld   a, e
  ld   (PSGMOD_VIBPOS + \2), a
  ld   e, b
  add  hl, de
  
  ld   a, l
  and  c
  or   128 + (32 * \1)
  out  (PSGMOD_PSG_PORT), a
  
  ld   a, h
  and  63
  out  (PSGMOD_PSG_PORT), a
  .ENDIF
  
++:
.ENDM
  
  .IF PSGMOD_SUPPORT_GG_STEREO == 1
  ld   a, (PSGMOD_GG_STEREO)
  out  ($06), a
  .ENDIF
  
  ld   a, :PSGMOD_VIBRATO_TABLES
  ld   ($FFFF), a
  
  ld   c, 15
  _PSGMOD_SET_TONE_CHANNEL_PSG 0, 0
  _PSGMOD_SET_TONE_CHANNEL_PSG 1, 2
  _PSGMOD_SET_TONE_CHANNEL_PSG 2, 4
  _PSGMOD_SET_TONE_CHANNEL_PSG 3, 6
  
;-------------------------------------------------------
  
.MACRO PSGMOD_PLAY_INSTRUMENT
  ld   a, (PSGMOD_PHASE_VOLUME + \1)
  .IF \1 == 0
  ld   hl, PSGMOD_PHASE_VOLUME_ADD_0 + \2
  .ELSE
  ld   l, (PSGMOD_PHASE_VOLUME_ADD_0 + \2) & 255
  .ENDIF
  add  a, (hl)
  ld   (PSGMOD_PHASE_VOLUME + \1), a
  
  .IF PSGMOD_PHASE_DELAY_0 != PSGMOD_PHASE_VOLUME_ADD_0 + 1
    .FAIL
  .ENDIF
  ;ld   l, (PSGMOD_PHASE_DELAY_0 + \2) & 255
  inc  l
  dec  (hl)
  .IF \1 == 3
  ret  NZ                                        ; s.u.
  .ELSE
  jp   NZ, PSGMOD_Play_PhasesDone\1
  .ENDIF
  
  ld   d, h
  dec  h
  ld   a, (PSGMOD_INSTR_PTR + \1)
  ld   l, a
  ld   e, (PSGMOD_PHASE_VOLUME_ADD_0 + \2) & 255
  ldi
  ldi
  .IF \1 != 3
  ld a, (hl)
  ld (PSGMOD_VIBPOS + \2 + 1), a
  .ENDIF
  inc l
  ld a, l
  and 15
  jp  Z, +
  ld a, l
  ld (PSGMOD_INSTR_PTR + \1), a
+:
  inc h
PSGMOD_Play_PhasesDone\1:
.ENDM
  
  PSGMOD_PLAY_INSTRUMENT 0, 0
  PSGMOD_PLAY_INSTRUMENT 1, 2
  PSGMOD_PLAY_INSTRUMENT 2, 4
  PSGMOD_PLAY_INSTRUMENT 3, 6
  ret

PSGMOD_StartSequences: ; (HL)
  ld   de, (PSGMOD_ADDRESS)
  
.MACRO PSGMOD_START_SEQUENCE
  ; \1 = Channel
  ; \2 = Channel * 2
  ; DE = (PSGMOD_ADDRESS)
  
  ; Get pointer to sequence
  ld   c, (hl)
  inc  hl
  .IF \1 != 3
  ld   b, (hl)
  inc  hl
  push hl
  ld   h, b
  .ELSE
  ld   h, (hl)
  .ENDIF
  ld   l, c
  add  hl, de
  ; Get pointer to notes from sequence header
  ld   a, (hl)
  add  a, e
  ld   c, a
  inc  hl
  ld   a, d
  adc  a, (hl)
  ld   b, a
  ld   (PSGMOD_NOTES_PTR + \2), bc
  inc  hl
  .IF \1 == 0
  ; Get sequence length from sequence header
  ld   a, (hl)
  ld   (PSGMOD_SEQ_LENGTH_CNT), a ; nur einmal
  .ENDIF
  inc  hl
  ld   (PSGMOD_SEQ_PTR + \2), hl
  .IF \1 != 3
  pop  hl
  .ENDIF
.ENDM
  
  PSGMOD_START_SEQUENCE 0, 0
  PSGMOD_START_SEQUENCE 1, 2
  PSGMOD_START_SEQUENCE 2, 4
  PSGMOD_START_SEQUENCE 3, 6
  ret
  
PSGMOD_Play_TriggerLine:
  ; A = (PSGMOD_SPEED_CNT)
  ; Schon vorzeitig Speed dazuzählen, obwohl sich die
  ; Geschwindigkeit in dieser Zeile ändern könnte.
  ld   hl, PSGMOD_SPEED
  add  a, (hl)
  .IF PSGMOD_SPEED_CNT != PSGMOD_SPEED + 1
    .FAIL
  .ENDIF
  inc  l
  ld   (hl), a
  
  .IF PSGMOD_PULSE_VIBRATO_MASK != PSGMOD_SPEED_CNT + 1
    .FAIL
  .ENDIF
  inc  l
  rrc  (hl)
  
  ld   a, (PSGMOD_FRAME)
  ld   ($FFFF), a
  
.MACRO _PSGMOD_PLAY_CHANNEL
PSGMOD_Play_Ch\1:
  .IF \1 == 0
  ld   l, (PSGMOD_SEQ_WAIT + \1) & 255
  .ELSE
  ld   hl, PSGMOD_SEQ_WAIT+\1
  .ENDIF
  dec  (hl)
  jp   NZ, PSGMOD_Play_Ch\1_Done
  
PSGMOD_Play_ExecLine\1:
  ld   hl, (PSGMOD_SEQ_PTR + \2)
  ld   b, (hl)
  inc  hl
  ld   (PSGMOD_SEQ_PTR + \2), hl
  
  ld   a, b
  and  $E0
  jr   Z, PSGMOD_Play_NoNote\1
  
  rlca
  rlca
  rlca
  ld   (PSGMOD_SEQ_WAIT + \1), a
  
  ld   hl, (PSGMOD_NOTES_PTR + \2)
  ld   a, b
  and  31
  .IF \1 != 3
    ; * 3
    ld   d, a
    add  a, a
    add  a, d
    ld   e, a
  .ELSE
    ; * 2
    add  a, a
    ld   e, a
  .ENDIF
  ld   d, 0
  add  hl, de
  ld   b, (hl)
  inc  hl
  ld   e, (hl)
  .IF \1 != 3
    inc  hl
    ld   d, (hl)
  .ENDIF
  
  .IF \1 == 3
    ld   a, (PSGMOD_SFX_3_PRIORITY)
    and  a
    ld   a, e
    ld   (PSGMOD_FREQUENCY + \2), a
    jr   NZ, +
    out  (PSGMOD_PSG_PORT), a
  +:
  .ELSE
    ; Frequenz
    ld (PSGMOD_FREQUENCY+\2), de
  .ENDIF
  
  ; Volume
  ld   a, b
  and  $0F
  ld   (PSGMOD_VOLUME+\1), a
  
  ; Instrument
  ld   a, b
  and  $F0
  
  ld   h, PSGMOD_INSTRUMENTS >> 8
  ld   l, a
  ld   a, (hl)
  ld   (PSGMOD_PHASE_VOLUME + \1), a
  inc  l
  .IF PSGMOD_PHASE_DELAY_0 != PSGMOD_PHASE_VOLUME_ADD_0 + 1
    .FAIL
  .ENDIF
  ld   de, PSGMOD_PHASE_VOLUME_ADD_0 + \2
  ldi
  ldi
  .IF \1 != 3
  ld   a, (hl)
  ld   (PSGMOD_VIBPOS + \2 + 1), a
  xor  a
  ld   (PSGMOD_VIBPOS + \2), a
  .ENDIF
  inc  l
  
  ld   a, l
  ld   (PSGMOD_INSTR_PTR + \1), a
  
  jp   PSGMOD_Play_Ch\1_Done
  
PSGMOD_Play_NoNote\1:
  rrc  b
  jp   NC, PSGMOD_Play_NoNote\1_Wait

PSGMOD_Play_NoNote\1_CommandOrEffect:
  ; B = (rotated) command/effect start byte
  .IF \1 == 3
      rrc  b
      jp   NC, PSGMOD_Play_Effect\1_NoSpeedCommand
      
      ld hl, (PSGMOD_SEQ_PTR+\2)
      ld c, (hl)
      inc hl
      ld (PSGMOD_SEQ_PTR+\2), hl
      
      ld a, (PSGMOD_SPEED_CNT)
      ld hl, PSGMOD_SPEED
      sub (hl)
      ld (hl), c
      add a, c
      ld (PSGMOD_SPEED_CNT), a
      
    PSGMOD_Play_Effect\1_NoSpeedCommand:
      rrc  b
    .IF PSGMOD_SUPPORT_GG_STEREO == 1
      jp   NC, PSGMOD_Play_Effect\1_NoStereoCommand
      
      ld hl, (PSGMOD_SEQ_PTR+\2)
      ld a, (hl)
      ld (PSGMOD_GG_STEREO), a
      inc hl
      ld (PSGMOD_SEQ_PTR+\2), hl
    PSGMOD_Play_Effect\1_NoStereoCommand:
    .ENDIF
      rrc  b
      jp   NC, PSGMOD_Play_Effect\1_NoSetVolumeEffect
      ld hl, (PSGMOD_SEQ_PTR+\2)
      ld a, (hl)
      ld (PSGMOD_VOLUME + \1), a
      inc hl
      ld (PSGMOD_SEQ_PTR+\2), hl
    PSGMOD_Play_Effect\1_NoSetVolumeEffect:
      rrc  b
      jp   NC, PSGMOD_Play_Effect\1_NoExt
      
      ld  hl, (PSGMOD_SEQ_PTR+\2)
      ld  b, (hl)
      inc hl
      
      rrc b
      jp  NC, +
      ld  a, (hl)
      inc hl
      ld  (PSGMOD_PULSE_VIBRATO_MASK), a
    +:
      
      rrc  b
      jp   NC, +
      ld   a, (hl)
      inc  hl
      call PSGMOD_CallCallback
    +:
      rrc  b
      jp   NC, +
      ld   a, (hl)
      inc  hl
      call PSGMOD_CallCallback
    +:
      ld (PSGMOD_SEQ_PTR + \2), hl
    PSGMOD_Play_Effect\1_NoExt:
  .ELSE
    ld   hl, (PSGMOD_SEQ_PTR + \2)
    ld   a, (hl)
    inc  hl
    ld   (PSGMOD_SEQ_PTR + \2), hl
    rrc  b
    jp   C, +
    ld (PSGMOD_PULSE_VIBRATO + \1), a
    jp   ++
    +:
    ld (PSGMOD_VOLUME + \1), a
    ++:
  .ENDIF
  
  jp   PSGMOD_Play_ExecLine\1
  
PSGMOD_Play_NoNote\1_Wait:
  ld   a, b
  inc  a
  ld   (PSGMOD_SEQ_WAIT+\1), a
  
;-------------------------------------------------------
PSGMOD_Play_Ch\1_Done:
.ENDM
  
  _PSGMOD_PLAY_CHANNEL 0, 0
  _PSGMOD_PLAY_CHANNEL 1, 2
  _PSGMOD_PLAY_CHANNEL 2, 4
  _PSGMOD_PLAY_CHANNEL 3, 6
  
;-------------------------------------------------------
  ;
  ; Next sequence
  ;
  ld   hl, PSGMOD_SEQ_LENGTH_CNT
  dec  (hl)
  jp   NZ, PSGMOD_Play_TriggerLine_Cont
  
  ld   hl, (PSGMOD_LENGTH_CNT)
  dec  hl
  ld   (PSGMOD_LENGTH_CNT), hl
  ld   a, l
  or   h
  jr   Z, PSGMOD_Play_Repeat
  
  ld   hl, (PSGMOD_SEQ_LIST_PTR)
  ld   de, 8
  add  hl, de
  ld   (PSGMOD_SEQ_LIST_PTR), hl
  call PSGMOD_StartSequences
  jp   PSGMOD_Play_TriggerLine_Cont
  
PSGMOD_Play_Repeat:
  ld   hl, (PSGMOD_LENGTH)
  ld   de, (PSGMOD_REPEAT_POINT)
  and  a                                         ; Clear C-flag
  sbc  hl, de
  ld   (PSGMOD_LENGTH_CNT), hl
  
  ld   a, 7
  ld   (PSGMOD_SPEED_CNT), a
  
  ld   hl, (PSGMOD_REPEAT_POINT)
  add  hl, hl
  add  hl, hl
  add  hl, hl
  ld   de, (PSGMOD_SEQ_LIST_START_PTR)
  add  hl, de
  ld   (PSGMOD_SEQ_LIST_PTR), hl
  
  call PSGMOD_StartSequences
  jp   PSGMOD_Play_TriggerLine_Cont
  
;----------------------------------------------------------
; PSGMOD_PlaySFX_2(B = length, C = priority, HL = address)
PSGMOD_PlaySFX_2:
  ld a, (PSGMOD_SFX_2_PRIORITY)
  cp c
  jr Z, PSGMOD_PlaySFX_2_OK
  ret NC
PSGMOD_PlaySFX_2_OK:
  
  ld a, b
  ld (PSGMOD_SFX_2_CNT), a
  ld a, c
  ld (PSGMOD_SFX_2_PRIORITY), a
  ld (PSGMOD_SFX_2_ADDRESS), hl
  ret

;----------------------------------------------------------
; PSGMOD_PlaySFX_3(B = length, C = priority, HL = address)
PSGMOD_PlaySFX_3:
  ld a, (PSGMOD_SFX_3_PRIORITY)
  cp c
  jr Z, PSGMOD_PlaySFX_3_OK
  ret NC
PSGMOD_PlaySFX_3_OK:
  
  ld a, b
  ld (PSGMOD_SFX_3_CNT), a
  ld a, c
  ld (PSGMOD_SFX_3_PRIORITY), a
  ld (PSGMOD_SFX_3_ADDRESS), hl
  ret

;----------------------------------------------------------
; PSGMOD_PlaySFX_23(B = length, C = priority, HL = address)
PSGMOD_PlaySFX_23:
  ld a, (PSGMOD_SFX_3_PRIORITY)
  cp c
  jr Z, PSGMOD_PlaySFX_23_OK_3
  ret NC
PSGMOD_PlaySFX_23_OK_3:
  
  ld a, (PSGMOD_SFX_2_PRIORITY)
  cp c
  jr Z, PSGMOD_PlaySFX_23_OK_2
  ret NC
PSGMOD_PlaySFX_23_OK_2:
  
  ld a, b
  ld (PSGMOD_SFX_2_CNT), a
  ld (PSGMOD_SFX_3_CNT), a
  ld a, c
  ld (PSGMOD_SFX_2_PRIORITY), a
  ld (PSGMOD_SFX_3_PRIORITY), a
  
  ld (PSGMOD_SFX_2_ADDRESS), hl
  ld c, b
  ld b, 0
  add hl, bc
  add hl, bc
  add hl, bc
  ld (PSGMOD_SFX_3_ADDRESS), hl
  ret

;------------------
; PSGMOD_StopSFX()
PSGMOD_StopSFX:
  ld a, (PSGMOD_SFX_2_PRIORITY)
  or a
  jr Z, PSGMOD_StopSFX_2
  
  xor a
  ld (PSGMOD_SFX_2_PRIORITY), a
  
  ld a, (PSGMOD_PULSE_VIBRATO_MASK)
  or a
  ld hl, (PSGMOD_FREQUENCY+4)
  jr Z, PSGMOD_StopSFX_ResetFreq2_NoVib
  ld d, 0
  ld a, (PSGMOD_PULSE_VIBRATO + 2)
  ld e, a
  add hl, de
PSGMOD_StopSFX_ResetFreq2_NoVib:
  
  ld a, l
  and 15
  or 128+64
  out (PSGMOD_PSG_PORT), a
  
  ld a, l
  rrca
  rrca
  rrca
  rrca
  and 15
  ld b, a
  ld a, h
  and 3
  rrca
  rrca
  rrca
  rrca
  or b
  out (PSGMOD_PSG_PORT), a
  ;
  ;
  ;
PSGMOD_StopSFX_2:
  
  ld   a, (PSGMOD_SFX_3_PRIORITY)
  or   a
  ret  Z
  
  xor  a
  ld   (PSGMOD_SFX_3_PRIORITY), a
  
  ld   a, (PSGMOD_FREQUENCY + 6)
  out  (PSGMOD_PSG_PORT), a
  ret

;--------------------
PSGMOD_CallCallback:
; (A)
  push hl
  push bc
  ld   hl, (PSGMOD_CALLBACK_FUNCTION)
  call PSGMOD_JumpHL
  pop  bc
  pop  hl
  ret
  
PSGMOD_JumpHL:
  jp   (hl)

;------------------------------
; PSGMOD_SetCallbackFunction()
PSGMOD_SetCallbackFunction:
  ld   (PSGMOD_CALLBACK_FUNCTION), hl
  ret

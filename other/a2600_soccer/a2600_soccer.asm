;---------------------------------------------------------------------------

; Soccer kernel, by Haroldo O. Pinheiro 2006-07-20
; Heavily based on "How to Draw A Playfield" by Nick S Bensema
; And "6 digit score" by Robin Harbron

;---------------------------------------------------------------------------

;
; Compile with DASM
;
        processor 6502
        include includes/vcs.h

	SEG.U Variables
	org $80

TempVar     ds 1
StackSave   ds 1
PlayfieldY  ds 1
YCounter    ds 1
RelativeY   ds 1
PlayerAnim  ds 1
Player1X    ds 1
Player2X    ds 1
BallX       ds 1
BallY       ds 1
BallXSpd    ds 1
BallYSpd    ds 1
Player2XOfs ds 1
GoalAlignH  ds 1
GoalDelay   ds 1
ScoredBy    ds 1
BgColPtr    ds 2
Score       ds 4
ScPtr0      ds 2
ScPtr1      ds 2
ScPtr2      ds 2
ScPtr3      ds 2
ScClrPtr    ds 2

	SEG Bank0
        org $F000

Start
;
; The 2600 powers up in a completely random state, except for the PC which
; is set to the location at $FFC.  Therefore the first thing we must do is
; to set everything up inside the 6502.
;
        SEI  ; Disable interrupts, if there are any.
        CLD  ; Clear BCD math bit.
;
; You may feel the need to use the stack, in which case:
;
        LDX  #$FF
        TXS  ; Set stack to beginning.
;
; Now the memory and TIA registers must be cleared.  You may feel the
; need to write a subroutine that only clears out a certain section of
; memory, but for now a simple loop will suffice.
;
; Since X is already loaded to 0xFF, our task becomes simply to ocunt
; everything off.
;
        LDA #0
B1      STA 0,X
        DEX
        BNE B1
;
; The above routine does not clear location 0, which is VSYNC.  We will
; take care of that later.
;
; At this point in the code we would set up things like the data
; direction registers for the joysticks and such.
;
        JSR  GameInit
;
; Here is a representation of our program flow.
;
MainLoop
        JSR  VerticalBlank ;Execute the vertical blank.
        JSR  CheckSwitches ;Check console switches.
        JSR  GameCalc      ;Do calculations during Vblank
        JSR  DrawScreen    ;Draw the screen
        JSR  OverScan      ;Do more calculations during overscan
        JMP  MainLoop      ;Continue forever.
;
; VBlank routine.
;
VerticalBlank
        LDX  #0
        LDA  #2
	
        STA  WSYNC
        STA  WSYNC
        STA  WSYNC
        STA  VSYNC ;Begin vertical sync.
        STA  WSYNC ; First line of VSYNC
        STA  WSYNC ; Second line of VSYNC.
        
;
; But before we finish off the third line of VSYNC, why don't we
; use this time to set the timer?  This will save us a few cycles
; which would be more useful in the overscan area.
;
        LDA  #44
        STA  TIM64T
;
; And now's as good a time as any to clear the collision latches.
;
        LDA #0
        STA CXCLR
;
; Now we can end the VSYNC period.
;
        STA  WSYNC ; Third line of VSYNC.
        STA  VSYNC ; (0)

        RTS

; 
; Check game swithces
;
CheckSwitches
;       LDA #$C4
;       STA COLUBK        ; Background will be green.
       LDA #$0E          ; Foreground will be white.
       STA COLUPF             
       RTS
;
; Minimal game calculations, just to get the ball rolling.
;
GameCalc
;        INC PlayfieldY   ;Inch up the playfield
	LDA #0
	STA HMP0

        LDA SWCHA
        TAY
        BMI M0
;move right, P1
	LDA #83
	CMP Player1X
	BMI M0
	INC Player1X
;	JMP M1
M0
	AND #$40
	BNE M1
;move left, P1
	LDA #10
	CMP Player1X
	BPL M1
	DEC Player1X
M1
	TYA
	AND #$20
	BNE M2
;move down, P1
	LDA PlayfieldY
	BEQ M2
    	INC PlayfieldY
M2
	TYA
	AND #$10
	BNE M3
;move up, P1
	LDA #94
	CMP PlayfieldY
	BEQ M3
	DEC PlayfieldY
M3

	TYA
	AND #$08
	BNE M4
;move right, P2
	LDA #83
;	INC BallX ; *** DEBUG ***
	CMP Player2X
	BMI M4
	INC Player2X
M4
	TYA
	AND #$04
	BNE M5
;move left, P2
	LDA #10
;	DEC BallX ; *** DEBUG ***
	CMP Player2X
	BPL M5
	DEC Player2X
M5
	TYA
	AND #$02
	BNE M6
;move down, P2
M6
	TYA
	AND #$01
	BNE M7
;move up, P2
M7

	LDA GoalDelay
	BEQ NormalMovement
	JMP GoalMovement
	
NormalMovement
; Ball's horizontal movement

;	JMP DoneBallSpd ; *** DEBUG ***

	LDA BallXSpd
	BMI NegBallSpd
	; Positive speed
	INC BallX
	LDA BallX
	SEC
	SBC #160
	BNE DoneBallSpd
	LDA #$FF
	STA BallXSpd
	JSR KickSound
	JMP DoneBallSpd
NegBallSpd
	; Negative speed
	DEC BallX
	LDA BallX
	SEC
	SBC #4
	BNE DoneBallSpd
	LDA #1
	STA BallXSpd
	JSR KickSound
DoneBallSpd

; Checks if the ball is horizontally aligned with the goal
	LDA #0
	STA GoalAlignH
	LDA BallX
	LSR
	SEC
	SBC #29
	BMI NoGAlign
	SEC
	SBC #24
	BPL NoGAlign
	LDA #1
	STA GoalAlignH
NoGAlign

; Debug hack - uncomment the two lines below to be able to
; scroll the playfield with the left joystick.
;	LDA PlayfieldY
;	JMP PfYDone

; Playfield's vertical scrolling
	LDA BallY
	LSR
	; Clip bottom
	SEC
	SBC #10
	BMI PfYBottom
	; Clip top
	SEC
	SBC #43
	BPL PfyTop
	; Otherwise..
	LDA #20
	SEC
	SBC BallY
	ASL
	JMP PfYDone
PfyTop
	LDA #86
	JMP PfYDone	
PfYBottom
	LDA #0	
PfYDone
	STA PlayfieldY


; Ball's vertical movement
	LDA BallYSpd
	BMI NegBallSpdY
	; Positive speed
	INC BallY
	LDA BallY
	SEC
	SBC #128
	BNE DoneBallSpdY
	; Hit the top?
	LDA #$FF
	STA BallYSpd
	JSR KickSound
	LDA GoalAlignH
	BEQ DoneBallSpdY
	; Hit the goal?
	LDX #1
	JSR IncreaseScore
	LDA #0
	STA ScoredBy
	JSR ServeBall
NegBallSpdY
	; Negative speed
	DEC BallY
	LDA BallY
	SEC
	SBC #4
	BNE DoneBallSpdY
	; Hit the bottom?
	LDA #1
	STA BallYSpd
	JSR KickSound
	LDA GoalAlignH
	BEQ DoneBallSpdY
	; Hit the goal?
	LDX #3
	JSR IncreaseScore
	LDA #1
	STA ScoredBy
	JSR ServeBall
DoneBallSpdY
	
	LDA #20
	STA AUDF1
	LDA #8
	STA AUDC1
	LDA #1
	STA AUDV1

	JMP DoneMovement


GoalMovement

; Scrolls playfield to center
;	LDA GoalDelay
;	AND #1
;	BNE ScoredDone

        LDA ScoredBy
        BNE NotScoredByP1

	LDA #<DigColorsP1
	STA ScClrPtr
	LDA #>DigColorsP1
	STA ScClrPtr+1

	LDA PlayfieldY
	CMP #166
	BEQ ScoredDone
	INC PlayfieldY
	JMP ScoredDone

NotScoredByP1
	LDA #<DigColorsP2
	STA ScClrPtr
	LDA #>DigColorsP2
	STA ScClrPtr+1

	LDA PlayfieldY
	CMP #166 ; (20-BallX) * 2
	BEQ ScoredDone
	DEC PlayfieldY
	
ScoredDone

	LDA GoalDelay
	AND #7
	CLC
	ADC #<GoalBgColors
	STA BgColPtr
	LDA #>GoalBgColors
	STA BgColPtr+1
        
	DEC GoalDelay

	LDA #10
	STA AUDF1
	LDA #8
	STA AUDC1
	LDA #$F
	STA AUDV1
	
DoneMovement

; Player 2 X offset (Ugly, ROM space wasting, but will do for now)
	LDA PlayfieldY
	LSR
	TAX
	LDA Ply2XOfs,X
	STA Player2XOfs
	
; Prepares score pointers
	JSR SetScorePtrs	
	
        RTS
        
ServeBall        
	LDA #82
	STA BallX
	LDA #65
	STA BallY
	LDA #100
	STA GoalDelay
	RTS
	
KickSound
	LDA #$F
	STA AUDV0
	RTS

DrawScreen
        LDA INTIM
        BNE DrawScreen ; Whew!
        STA WSYNC
        STA HMOVE
        STA VBLANK

; 
; Sets up the playfield (Mirrored, 4px ball)
;
        LDA  #$21
        STA  CTRLPF

;
; Initialize some display variables.
;
        ;There aren't any display variables!

;
; This will be used to count the scanlines.
;

	LDA #87
;	STA YCounter ; YCounter is being reused for the score counter
	
        SEC
        SBC PlayfieldY
        STA RelativeY

	LDA #1
	STA VDELP0		;VDEL!

; Draws the score at the top of the screen
	LDA GoalDelay
	BNE DrawGoalScore	
	JSR NormalScore	
	JMP DrawScoreDone
DrawGoalScore
	JSR GoalScore
DrawScoreDone
	
; Disable sprites	
	LDA #0
	STA GRP0
	STA GRP1	
	
	JSR PlaceTeams

; Animate players
	LDA PlayerAnim
	LSR
	STA REFP0
	EOR #$FF
	STA REFP1
	INC PlayerAnim
;
; Main screen drawing loop
;

	LDA #87
	STA YCounter

ScanLoop

; Due to timing problems, the loop had to be unrolled.

; Duplicate 1

        LDA RelativeY
        LSR
        TAY		; Y now contains the relative playfield position.
        
        SEC
        SBC BallY
        BMI NoBall        
        SEC
        SBC #2
        BPL NoBall        
        LDA #2
        BNE DoBall
NoBall        
        LDA #0
DoBall
	STA ENABL      
        
        STA WSYNC

	TYA        
        AND #$1F
        TAX

        LDA GrassColors,X
        STA COLUBK

	LDA #00
        STA PF0
        STA PF1
        STA PF2

        LDA SpriteColors1,X
        STA COLUP0
        STA COLUP1
        LDA Sprite1,X
        STA GRP0
        LDA Sprite2,X
        STA GRP1

; Result of the following math is:
;  X = ( (Y-PlayfieldY) /4 ) mod 64
        TYA
        LSR   ;Divide by 2
        AND #$3F  ;modulo 64
        TAX
        LDA PFData0,X           ;Load ahead of time.
; WSYNC is placed BEFORE all of this action takes place.
        STA WSYNC
        STA PF0                 ;[0] +3 = *3*   < 23
        LDA PFData1,X           ;[13]+4
        STA PF1                 ;[17]+3 = *20*  < 29
        LDA PFData2,X           ;[27]+4
        STA PF2                 ;[31]+3 = *34*  < 40

        DEC RelativeY
        DEC YCounter
        BEQ LoopEnd

; Duplicate 2

        LDA RelativeY
        LSR
        TAY		; Y now contains the relative playfield position.
 
        LSR
        LSR
        LSR
        TAX
        LDA TblNusizPly1,X
        STA NUSIZ0
        STA NUSIZ1

        LDA TblHmpPly1,X
        STA HMP0
        
        LDA TblHmpPly2,X
        STA HMP1
                       
        STA WSYNC
        STA HMOVE

	TYA        
        AND #$1F
        TAX

        LDA GrassColors,X
        STA COLUBK

	LDA #00
        STA PF0
        STA PF1
        STA PF2

        LDA SpriteColors1,X
        STA COLUP0
        STA COLUP1
        LDA Sprite1,X
        STA GRP0
        LDA Sprite2,X
        STA GRP1

; Result of the following math is:
;  X = ( (Y-PlayfieldY) /4 ) mod 64
        TYA
        LSR   ;Divide by 2
        AND #$3F  ;modulo 64
        TAX
        LDA PFData0,X           ;Load ahead of time.
; WSYNC is placed BEFORE all of this action takes place.
        STA WSYNC
        STA PF0                 ;[0] +3 = *3*   < 23
        LDA PFData1,X           ;[13]+4
        STA PF1                 ;[17]+3 = *20*  < 29
        LDA PFData2,X           ;[27]+4
        STA PF2                 ;[31]+3 = *34*  < 40

        DEC RelativeY
        DEC YCounter
        BEQ LoopEnd
        
        JMP ScanLoop
LoopEnd
        
;
; Clear all registers here to prevent any possible bleeding.
;
        LDA #2
        STA WSYNC  ;Finish this scanline.
        STA VBLANK ; Make TIA output invisible,

        LDA #0
        STA PF0
        STA PF1
        STA PF2
        STA GRP0
        STA GRP1
        STA ENAM0
        STA ENAM1
        STA ENABL
        RTS
        

;
; Score drawing loop
;	
NormalScore
	LDY #8
ScoreLoop
	LDA (ScPtr0),y 
	

	STA WSYNC
	STA GRP0    
	
	LDA DigColorsP1,y
	STA COLUP0
	STA COLUP1
	
	LDA (ScPtr1),y 
	STA GRP1     
	
	LDA (ScPtr3),y 
	TAX          
	LDA (ScPtr2),y 
	
	NOP

	STA GRP0
	STX GRP1

	LDA DigColorsP2,y
	STA COLUP0
	STA COLUP1

        
	DEY
	BNE ScoreLoop	
	RTS        

;
; "Goal" score drawing loop
;
GoalScore
	LDY #8	
GoalScoreLoop
	LDA (ScClrPtr),y
	STA COLUP0
	STA COLUP1

	LDA (BgColPtr),y

	STA WSYNC
	STA COLUBK

	LDA GoalG,Y
	STA GRP0    
	
	LDA GoalO,Y
	STA GRP1	

	LDA GoalL,y 
	TAX          
	LDA GoalA,y 
	
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP

	STA GRP0
	STX GRP1

	DEY
	BNE GoalScoreLoop	

	RTS

;
; Overscan routine
;
OverScan   ;We've got 30 scanlines to kill.

	LDA #34		;use the timer here.
	STA TIM64T

; Resets kick sound	
	LDA #0
	STA AUDV0
	LDA #31
	STA AUDF0
	LDA #$F
	STA AUDC0

; Ball's horizontal position
	LDA BallX
	JSR CalcPos
	STA HMBL
	INY
	INY
	INY
	STA WSYNC
ResLoop2
	DEY
	BPL ResLoop2
	STA RESBL
;	LDA #$FF
;        STA ENABL
	STA WSYNC
	
	STA HMOVE

	LDA #00
	STA HMP0
	STA HMP1
	STA HMBL

	LDA #$00
	STA COLUBK        ; Background will be black.
	
;
; Prepare for displaying the score in the next frame
;

        LDA #$FF
        STA COLUP0
        STA COLUP1
	STA HMCLR

	LDA #0
        STA GRP0
        STA GRP1

	LDA GoalDelay
	BNE PlaceGoalScore
	
	LDA #4
        STA NUSIZ0
        STA NUSIZ1 ;2 copies wide

        LDX #21
	JMP PlaceScore        
        
PlaceGoalScore	
	LDA #1
        STA NUSIZ0
        STA NUSIZ1 ;2 copies close
        STA WSYNC

        LDX #23
        
PlaceScore
        STA WSYNC
ResLoopScore
	DEX
        BNE ResLoopScore
        STA RESP0
        STA RESP1

	LDA GoalDelay
	BNE TweakPosGoalScore

        LDA #$80
        STA HMP0

        LDA #$C0
        STA HMP1
        
        JMP DoneTweakPosScore
        
TweakPosGoalScore        

        LDA #$C0
        STA HMP0

        LDA #$E0
        STA HMP1

DoneTweakPosScore

        STA WSYNC
        STA HMOVE
	
	LDA #0
	STA REFP0
	STA REFP1

; Ball/Player collision
	LDA CXP0FB
	AND #$40
	BEQ NoBallP1
	LDA BallYSpd
	BPL NoBallP1
	LDA #1
	STA BallYSpd
	JSR KickSound
NoBallP1	
	LDA CXP1FB
	AND #$40
	BEQ NoBallP2
	LDA BallYSpd
	BMI NoBallP2
	LDA #$FF
	STA BallYSpd
	JSR KickSound
NoBallP2	

; Skip remaining lines
KillLines
	lda INTIM
	BNE KillLines
	RTS

;
; GameInit could conceivably be called when the Select key is pressed,
; or some other event.
;
GameInit
        LDA #0
        STA PlayfieldY
        LDA #48
        STA Player1X
        STA Player2X
        STA BallX
        STA BallY
        
        LDA #$FF
        STA BallXSpd
        STA BallYSpd

	LDA #$06
	STA NUSIZ0
	STA NUSIZ1
	
;	LDY #4
;TestScoreLoop
;	TYA
;	STA Score,y
;	DEY
;	BNE TestScoreLoop

        RTS

;        
; Increases score
;
; If X = #1 then increases score for player 1
; If X = #3 then increases score for player 2
IncreaseScore
         inc Score,x
         lda Score,x
         cmp #10
         bne IncreaseScoreDone
         lda #0
         sta Score,x
         dex
         bpl IncreaseScore
IncreaseScoreDone

;
; Set score pointers
;        

SetScorePtrs
	LDX #3
	LDY #6
ScorePtLoop
	LDA Score,x
	ASL
	ASL
	ASL

	ADC #<DigZero
	STA ScPtr0,y
	LDA #0
	LDA #>DigZero
	STA ScPtr0+1,y
	DEY
	DEY
	DEX
	BPL ScorePtLoop

	RTS
        
;
; Place team sprites
;	

	align 256

PlaceTeams

; Player1 horizontal position
	LDA  Player1X
	JSR CalcPos
	STA HMP0
	INY
	INY
	INY
	STA WSYNC
ResLoop0
	DEY
	BPL ResLoop0
	STA RESP0
;	STA WSYNC
;	STA HMOVE

; Player2 horizontal position
	LDA Player2X
	CLC
	ADC Player2XOfs
	JSR CalcPos
	STA HMP1
	INY
	INY
	INY
	STA WSYNC
ResLoop1
	DEY
	BPL ResLoop1
	STA RESP1
	STA WSYNC
	STA HMOVE

	RTS

;
; Calculate sprite position
;
CalcPos
    TAY            ;2
    INY            ;2
    TYA            ;2
    AND    #$0F    ;2
    STA    TempVar  ;3
    TYA            ;2
    LSR            ;2
    LSR            ;2
    LSR            ;2
    LSR            ;2
    TAY            ;2
    CLC            ;2
    ADC    TempVar  ;3
    CMP    #$0F    ;2
    BCC    NextPos ;2
    SBC    #$0F    ;2
    INY            ;2

NextPos
    EOR    #$07    ;2
    ASL            ;2
    ASL            ;2
    ASL            ;2
    ASL            ;2
    RTS            ;6

;
; GFX data / Tables
;
	align 256
        
Ply2XOfs
	.byte 00,00,00,00,00,00,00,00 ; 0
	.byte 00,00,00,00,00,00,00,00 ; 8
	.byte 00,00,00,00,00,00,00,00 ; 16
	.byte 00,00,00,00,00,00,00,00 ; 24
	.byte 00,00,00,00,00,00,00,00 ; 32
	.byte 00,32,32,32,32,32,32,32 ; 40
	.byte 32,32,32,32,32,32,32,32 ; 48
	.byte 32,32,32,32,32,32,32,32 ; 56
	.byte 28,24,20,16,12,8,4,00 ; 64
	.byte 00,00,00,00,00,00,00,00 ; 72
	.byte 00,00,00,00,00,00,00,00 ; 80
	.byte 00,00,00,00,00,00,00,00 ; 88
	.byte 00,00,00,00,00,00,00,00 ; 96
	.byte 00,00,00,00,00,00,00,00 ; 104
	.byte 00,00,00,00,00,00,00,00 ; 112
	.byte 00,00,00,00,00,00,00,00 ; 120	


	align 256
	
DigZero     
	.byte %00000000 ; Alignment problems. Solve later.

	.byte %00111100
	.byte %01100010
	.byte %01010010
	.byte %01010010
	.byte %01001010
	.byte %01001010
	.byte %01000110
	.byte %00111100

DigOne
	.byte %01111110
	.byte %00011000
	.byte %00011000
	.byte %00011000
	.byte %00011000
	.byte %00011000
	.byte %00111000
	.byte %00011000

DigTwo      
	.byte %01111110
	.byte %00100000
	.byte %00010000
	.byte %00001000
	.byte %00000100
	.byte %00000010
	.byte %01000010
	.byte %00111100

DigThree
	.byte %00111100
	.byte %01000010
	.byte %00000010
	.byte %00000010
	.byte %00011100
	.byte %00000010
	.byte %01000010
	.byte %00111100

DigFour
	.byte %00001100
	.byte %00001100
	.byte %00001100
	.byte %01111110
	.byte %01001100
	.byte %00101100
	.byte %00011100
	.byte %00001100

DigFive
	.byte %00011000
	.byte %01100100
	.byte %00000010
	.byte %00000010
	.byte %01100100
	.byte %01011000
	.byte %01000000
	.byte %01111110

DigSix
	.byte %00111100
	.byte %01000010
	.byte %01000010
	.byte %01111100
	.byte %00100000
	.byte %00010000
	.byte %00001000
	.byte %00000100

DigSeven
	.byte %00001000
	.byte %00001000
	.byte %00001000
	.byte %00000100
	.byte %00000100
	.byte %00000010
	.byte %00000010
	.byte %01111110

DigEight
	.byte %00111100
	.byte %01000010
	.byte %01000010
	.byte %01000010
	.byte %00111100
	.byte %01000010
	.byte %01000010
	.byte %00111100

DigNine
	.byte %00111100
	.byte %00000010
	.byte %00000010
	.byte %00000010
	.byte %00111110
	.byte %01000010
	.byte %01000010
	.byte %00111100
	
GoalG
	.byte %00000000 ; Alignment problems. Solve later.

	.byte %00111100
	.byte %01111110
	.byte %01100110
	.byte %01101110
	.byte %01101110
	.byte %01100000
	.byte %01111110
	.byte %00111100
	
GoalO
	.byte %00000000 ; Alignment problems. Solve later.

	.byte %01111000
	.byte %11111100
	.byte %11001100
	.byte %11001100
	.byte %11001100
	.byte %11001100
	.byte %11111100
	.byte %01111000
	
GoalA
	.byte %00000000 ; Alignment problems. Solve later.

	.byte %01100110
	.byte %01100110
	.byte %01100110
	.byte %01111110
	.byte %01111110
	.byte %01100110
	.byte %01111110
	.byte %00111100
	
GoalL
	.byte %00000000 ; Alignment problems. Solve later.

	.byte %11111100
	.byte %11111100
	.byte %11000000
	.byte %11000000
	.byte %11000000
	.byte %11000000
	.byte %11000000
	.byte %11000000
	
DigColorsP1
	.byte $00,$40,$44,$48,$4C,$4C,$48,$44,$40

DigColorsP2
	.byte $00,$80,$84,$88,$8C,$8C,$88,$84,$80

GoalBgColors
	.byte $10,$14,$18,$1C,$1E,$1A,$16,$12
	.byte $10,$14,$18,$1C,$1E,$1A,$16,$12

	align 256

TblNusizPly1
	.byte $00,$00
	.byte $06,$06
	.byte $06,$06
	.byte $06,$06
	.byte $06,$06
	.byte $06,$06
	.byte $06,$06
	.byte $00,$00

TblHmpPly1
	.byte $00,$00
	.byte $C0,$00
	.byte $00,$00
	.byte $00,$00
	.byte $00,$00
	.byte $00,$00
	.byte $00,$00
	.byte $00,$00

TblHmpPly2
	.byte $00,$00
	.byte $00,$00
	.byte $00,$00
	.byte $00,$00
	.byte $00,$00
	.byte $00,$00
	.byte $00,$40
	.byte $00,$00


Sprite2
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000 ;-15
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000 ;-11
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000 ;-7
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000 ;-3
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000
Sprite1
        .byte  %00000000 ;0
        .byte  %00000000
        .byte  %00000110
        .byte  %01100110    
        .byte  %01100110 ;4
        .byte  %01100110
        .byte  %01111110
        .byte  %10111100
        .byte  %11111111 ;8
        .byte  %11111111
        .byte  %00111100
        .byte  %00111100
        .byte  %00111100 ;12
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000 ;16
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000 ;20
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000 ;24
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000 ;28
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000
        .byte  %00000000

SpriteColors1
	.byte $40,$40,$40,$40,$4E,$0F,$0F,$40,$40,$40,$4E,$4E,$20,$20

SpriteColorsFiller
	.byte $00,$00,$00,$00,$00,$00
	
SpriteColors2
	.byte $70,$70,$70,$4E,$00,$00,$70,$70,$70,$4E,$4E,$1F,$1F
    
	align 256

PFData0  ;H       4 5 6 7
       .byte $00,$E0,$20,$20,$20,$20,$20,$20
       .byte $20,$20,$20,$20,$20,$20,$20,$20
       .byte $20,$20,$20,$20,$20,$20,$20,$20
       .byte $20,$20,$20,$20,$20,$20,$20,$20
       .byte $E0,$20,$20,$20,$20,$20,$20,$20
       .byte $20,$20,$20,$20,$20,$20,$20,$20
       .byte $20,$20,$20,$20,$20,$20,$20,$20
       .byte $20,$20,$20,$20,$20,$60,$A0,$E0
PFData1  ;EL      7 6 5 4 3 2 1 0
       .byte $00,$FF,$08,$08,$08,$08,$08,$08
       .byte $08,$08,$08,$08,$0F,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $FF,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$0F,$08,$08,$08
       .byte $08,$08,$08,$08,$08,$08,$08,$FF
PFData2  ;LO      0 1 2 3 4 5 6 7
       .byte $00,$FF,$02,$02,$02,$02,$02,$FE
       .byte $00,$00,$00,$00,$FF,$10,$E0,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$E0,$18,$04,$02,$01,$01,$81
       .byte $FF,$81,$01,$01,$02,$04,$18,$E0
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$E0,$10,$FF,$00,$00,$00
       .byte $00,$FE,$02,$02,$02,$02,$02,$FF

GrassColors
	.byte $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4
	.byte $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4
	.byte $C8,$C8,$C8,$C8,$C8,$C8,$C8,$C8
	.byte $C8,$C8,$C8,$C8,$C8,$C8,$C8,$C8
	
        org $FFFC
        .word Start
        .word Start
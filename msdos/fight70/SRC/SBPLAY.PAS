{$OUTPUT_FORMAT AS}
{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
  sbPlay.pas - Sound player
  27 Jan 1999

  Copyright (C) 1999 Richard C. Mulder

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; see the file COPYING.LIB.
  If not, write to the Free Software Foundation,
  59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
  = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
unit sbPlay;
{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
interface
{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
uses
  Go32;

const
  plrCopyrightBlurb	= 'sbPlay v0.6.4 - R.C. Mulder/BanderLabs';

  BlockLength		= 1024;
  BufferLength		= 1024;
  MaxVolume		= 63;
  MaxChannel		= 16;

  FixedPointShift	= 12;

  SampleRate		: Word		= {22050}	44100;
  UpdateRate		: Word		= 50;

type
  pSound		= ^tSound;
  tSound		= record
    ptr 		  : Pointer;
    size		  : Longint;
  end;

var
  dspReset		: Word;
  dspReadData		: Word;
  dspWriteData		: Word;
  dspWriteStatus	: Word;
  dspDataAvail		: Word;
  dspAckPort		: Word;

  dspVersion		: Word;

  irqValue		: Byte;
  dmaValue		: Byte;

  dmaMaskPort		: Word;
  dmaClrPtrPort 	: Word;
  dmaModePort		: Word;
  dmaBaseAddrPort	: Word;
  dmaCountPort		: Word;
  dmaPagePort		: Word;
  dmaRequestPort	: Word;

  irqIntVector		: Byte;
  irqOldHandler 	: tSegInfo;
  irqOurHandler 	: tSegInfo;
  irqCounter		: Longint;

  irqOldMask		: Byte;

  dmaStartMask		: Byte;
  dmaStopMask		: Byte;
  dmaMode		: Byte;
  dmaLength		: Word;

  BufferHandle		: array [1..2] of Longint;
  BufferAddr		: array [1..2] of Longint;
  BufferPage		: array [1..2] of Byte;
  BufferOfs		: array [1..2] of Word;

  bufActive		: Byte;
  bufMixing		: Byte;

  MixingBuffer		: array [0..BufferLength-1] of Integer;
  OutputBuffer		: array [0..BufferLength-1] of Byte;

  sbStatus		: array [1..MaxChannel] of Byte;
  sbVolume		: array [1..MaxChannel] of Byte;
  sbStart		: array [1..MaxChannel] of Longint; { Address }
  sbPos 		: array [1..MaxChannel] of Longint; { Fixed point }
  sbLoopStart 		: array [1..MaxChannel] of Longint; { Fixed point }
  sbLoopEnd 		: array [1..MaxChannel] of Longint; { Fixed point }
  sbEnd 		: array [1..MaxChannel] of Longint; { Fixed point }
  sbAdder		: array [1..MaxChannel] of Longint; { Fixed point }

  tabVolume		: array [-128..127, 0..MaxVolume] of ShortInt;
  tabPostProc		: array [(-128*MaxChannel)..(127*MaxChannel)] of Byte;

const
  stStop		= 1;
  stOnce		= 2;
  stLoop		= 3;

  function  InitSB(BaseIO: Word; IRQ: Byte; DMA: Byte): Boolean;
  procedure ShutdownSB;

  procedure StartPlayer;
  procedure StartBlockSingle;
  procedure StopPlayer;

  function  LoadRaw(name: string): pSound;
  procedure PlaySound(chan: Byte; sound: pSound; freq: Word; vol, status: Byte);
  procedure FreeSound(var sound: pSound);

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
implementation
{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
  const
    irqEnable		= 0;
    irqDisable		= 1;

  function GetIRQMask(irq: byte): byte; assembler;
  {$I386_DIRECT}
    asm
      inb	$0xA1, %al
      movb	%al, %ah
      inb	$0x21, %al
      movb	irq, %cl
      shrw	%cl, %ax
      andb	$1, %al
    end ['EAX','ECX'];

  procedure SetIRQMask(irq, status: byte); assembler;
  {$I386_DIRECT}
    asm
      movb	irq, %cl
      movw	$0xFFFE, %bx
      movzbw	status, %dx
      rolw	%cl, %bx
      shlw	%cl, %dx
      inb	$0xA1, %al
      movb	%al, %ah
      inb	$0x21, %al
      andw	%bx, %ax
      orw	%dx, %ax
      outb	%al, $0x21
      movb	%ah, %al
      outb	%al, $0xA1
    end ['EAX','EBX','ECX','EDX'];

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
  procedure WriteDSP(value: Byte);
  begin
    repeat until (inportb(dspWriteData) and $80) = 0;
    outportb(dspWriteData, value);
  end;

  function ReadDSP: byte;
  begin
    while InPortB(dspDataAvail) and $80 = 0 do { Nothing };
    ReadDSP := InPortB(dspReadData);
  end;

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
  procedure sbDelay(count: Word);
  begin
    while (count > 0) do begin inportb(dspReset); Dec(count); end;
  end;

  function ResetDSP: Boolean;
  var
    TimeWaited	  : Byte;
    Status	  : Byte;
  begin
    { - Toggle DSP Reset port }
    outportb(dspReset, 1);  sbDelay(100);
    outportb(dspReset, 0);  sbDelay(100);

    { - See if there is any response }
    TimeWaited := 0;  Status := 0;
    while (Status <> $AA) and (TimeWaited < 100) do begin
      Status := inportb(dspDataAvail);
      Status := inportb(dspReadData);
      sbDelay(100);
      Inc(TimeWaited);
    end;

    ResetDSP := (Status = $AA);
  end;

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
  function TimeConstant(Rate: Word): Byte;
  begin
    TimeConstant := 256 - (1000000 div Rate);
  end;

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
  function InitSB(BaseIO: Word; IRQ: Byte; DMA: Byte): Boolean;
  begin
    InitSB := False;

    { - Sound card IO ports }
    dspReset	   := BaseIO + $06;
    dspReadData    := BaseIO + $0A;
    dspWriteData   := BaseIO + $0C;
    dspWriteStatus := BaseIO + $0C;
    dspDataAvail   := BaseIO + $0E;

    { - Reset DSP, get version, and pick output mode }
    if not(ResetDSP) then Exit;

    { - Get DSP version number }
    WriteDSP($E1);
    dspVersion	 := ReadDSP shl 8;  dspVersion := dspVersion + ReadDSP;

    { - Compute interrupt ports and parameters }
    if (IRQ <= 7) then begin
      irqIntVector  := $08+IRQ;
    end else begin
      irqIntVector  := $70+IRQ-8;
    end;

    { - Compute DMA ports and parameters }
    dmaRequestPort  := $09;
    dmaMaskPort     := $0A;
    dmaClrPtrPort   := $0C;
    dmaModePort     := $0B;
    dmaBaseAddrPort := $00 + (2*DMA);
    dmaCountPort    := $01 + (2*DMA);
    case DMA of
      0:  dmaPagePort := $87;
      1:  dmaPagePort := $83;
      2:  dmaPagePort := $81;
      3:  dmaPagePort := $82;
    end;
    dmaStopMask  := DMA + $04;			{000001xx}
    dmaStartMask := DMA + $00;			{000000xx}
    dmaMode	 := DMA + $48;			{010010xx}
    dspAckPort	 := BaseIO + $0E;

    dmaLength := BlockLength;

    SampleRate := 1000000 div (256 - timeConstant(SampleRate));
    dmaLength  := SampleRate div UpdateRate;
    UpdateRate := SampleRate div dmaLength;

    irqValue	 := IRQ;
    dmaValue	 := DMA;

    InitSB := True;
  end;

  procedure ShutdownSB;
  begin
    ResetDSP;
  end;

  procedure SetSampleRate(Rate: word);
  begin
    SampleRate := Rate;

    WriteDSP($D0);			{Pause 8-bit DMA mode digitized sound}
    WriteDSP($40);			   {Set digitized sound time constant}
    WriteDSP(TimeConstant(Rate));
    WriteDSP($D4);		     {Continue 8-bit DMA mode digitized sound}
  end;

  procedure Mixer;
  begin
  {$I386_ATT}
    asm
    { for i := 0 to dmaLength-1 do MixingBuffer[i] := 0; }
      pushw	%es
      movw	%ds, %ax
      movw	%ax, %es
      leal	MixingBuffer, %edi
      xorw	%ax, %ax
      movzwl	dmaLength, %ecx
      cld
      rep
      stosw
      popw	%es

      movl	$16, %eax		{ @NOTE: $16 = MaxChannel }
					{ eax = channel counter }
.LChannelLoop:
    { for j := 1 to MaxChannel do begin }
    { if (sbStatus[j] <> stStop) then begin }
      cmpl	$0, %eax		{ Only happens when all channels }
      je	.LChannelLoopExit	{ have stStop status }

      decl	%eax

      movb	sbStatus(,%eax,1), %bl
      cmpb	$1, %bl 		{ @NOTE: $1 = stStop }
      je	.LChannelLoop

    { for i := 0 to dmaLength-1 do begin }
      					{ ecx = buffer counter }
      movl	$0, %ecx
.LBufferLoop:
    { Inc(MixingBuffer[i], tabVolume[sPtr(sbPos[j] shr FixedPointShift)^, sbVolume[j]]); }
      movl	sbPos(,%eax,4), %edi
      shrl	$12, %edi		{ @NOTE: $12 = FixedPointShift }
      addl	sbStart(,%eax,4), %edi		{ add start of sample }

      movb	(%edi), %bl
      movsbl	%bl, %edi

      shll	$6, %edi
      movzbl	sbVolume(,%eax,1), %ebx

      addl	$8192, %edi
      movb	tabVolume(%edi,%ebx,1), %bl
      movsbw	%bl, %bx			{+8192}

      addw	MixingBuffer(,%ecx,2), %bx
      movw	%bx, MixingBuffer(,%ecx,2)

    { Inc(sbPos[j], sbAdder[j]); }
      movl	sbAdder(,%eax,4), %ebx
      addl	%ebx, sbPos(,%eax,4)

    { if (sbPos[j] > sbEnd[j]) then }
      movl	sbEnd(,%eax,4), %edx
      movl	sbPos(,%eax,4), %ebx
      cmpl	%edx, %ebx
      jae	.LBufferWrap			{ ja -> jae ! }

.LNoBufferWrap:
      incl	%ecx
      cmpw	dmaLength, %cx	{ ecx = (dmaLength-1) to _0_ }
      jae	.LBufferLoopExit
      jmp	.LBufferLoop

.LBufferWrap:
    { if (sbStatus[j] = stLoop) then begin }
      movb	sbStatus(,%eax,1), %bl
      cmpb	$3, %bl 		{ @NOTE: $3 = stLoop }
      je	.LBufferWrapLoop

    { sbStatus[j] := stStop;  Exit; }
{|}   leal	sbStatus, %ebx
      addl	%eax, %ebx
      movb	$1, (%ebx)
      {movb	$1, sbStatus(,%eax,1)}	{ Stop the presses! } 
      {jmp	.LChannelLoop}		{ next -channel- }
      jmp	.LBufferLoopExit

.LBufferWrapLoop:
    { sbPos[j] := sbStart[j] }
{|}   movl	sbLoopStart(,%eax,4), %ebx
{|}   movl	%ebx, sbPos(,%eax,4)
{|}   movl	sbLoopEnd(,%eax,4), %ebx
{|}   movl	%ebx, sbEnd(,%eax,4)

      incl	%ecx
      cmpw	dmaLength, %cx		{ ecx = (dmaLength-1) to _0_ }
      jae	.LBufferLoopExit
      jmp	.LBufferLoop

.LBufferLoopExit:
      cmpw	$0, %ax			{ eax = MaxChannel-1 to _0_ }
      jbe	.LChannelLoopExit
      jmp	.LChannelLoop
.LChannelLoopExit:


    { for i := 0 to dmaLength-1 do OutputBuffer[i] := tabPostProc[MixingBuffer[i]]; }
      movzwl	dmaLength, %eax
.LOutputLoop:
      decl	%eax

      movw	MixingBuffer(,%eax,2), %dx
      movswl	%dx, %edx			{ EDX = MixingBuffer[i] }

{|}   addl	$2048, %edx                     { @NOTE: MaxChannel * 128 }
      movb	tabPostProc(,%edx,1), %bl	{  BL = tabPostProc[EDX] }
      movb	%bl, OutputBuffer(,%eax,1);	{ OutputBuffer[i] = BL }

      cmpw	$0, %ax
      jbe	.LOutputLoopExit
      jmp	.LOutputLoop
.LOutputLoopExit:
    end ['EAX','EBX','ECX','EDX','ESI','EDI'];

    dosmemput(Hi(BufferHandle[bufMixing]), 0, OutputBuffer, dmaLength);
  end;

  procedure StartBlockSingle;
  begin
  {$I386_ATT}
    asm
    { outportb(dmaRequestPort , dmaValue); }
      movw	dmaRequestPort, %dx
      movb	dmaValue, %al
      outb	%al, %dx
    { outportb(dmaMaskPort    , dmaStopMask); }
      movw	dmaMaskPort, %dx
      movb	dmaStopMask, %al
      outb	%al, %dx
    { outportb(dmaClrPtrPort  , $00);}
      movw	dmaClrPtrPort, %dx
      xorb	%al, %al
      outb	%al, %dx
    { outportb(dmaModePort    , dmaMode); }
      movw	dmaModePort, %dx
      movb	dmaMode, %al
      outb	%al, %dx
    { outportb(dmaBaseAddrPort, Lo(BufferOfs[bufActive])); }
      movw	dmaBaseAddrPort, %dx
      movzbl	bufActive, %eax
      decl	%eax					{ 1-based array }
      movw	BufferOfs(,%eax,2), %ax			{-2}
      outb	%al, %dx
    { outportb(dmaBaseAddrPort, Hi(BufferOfs[bufActive])); }
      shrw	$8, %ax
      outb	%al, %dx
    { outportb(dmaPagePort    , BufferPage[bufActive]); }
      movw	dmaPagePort, %dx
      movzbl	bufActive, %eax
      decl	%eax					{ 1-based array }
      movb	BufferPage(,%eax,1), %al		{-1}
      outb	%al, %dx
    { outportb(dmaCountPort   , Lo(Word(dmaLength-1)) ); }
      movw	dmaCountPort, %dx
      movw	dmaLength, %ax
      decw	%ax
      outb	%al, %dx
    { outportb(dmaCountPort   , Hi(Word(dmaLength-1)) ); }
      shrw	$8, %ax
      outb	%al, %dx
    { outportb(dmaMaskPort    , dmaStartMask); }
      movw	dmaMaskPort, %dx
      movb	dmaStartMask, %al
      outb	%al, %dx
    end ['EAX','EDX'];

    WriteDSP($40);			    {Set digitized sound time constant}
    WriteDSP(TimeConstant(SampleRate));
    WriteDSP($14);		       {8-bit single-cycle DMA sound output   }
    WriteDSP(Lo(Word(dmaLength - 1)) );
    WriteDSP(Hi(Word(dmaLength - 1)) );
  end;

  procedure IntHandler; interrupt;
  begin
  {$I386_DIRECT}
    asm
      movw	%cs:DATASEL, %ax
      movw	%ax, %ds
    end;
  {$I386_ATT}
    asm
      incl	irqCounter
    end;
    StartBlockSingle;
    Mixer;
    asm
      movb	bufActive, %al
      movb	bufMixing, %bl
      movb	%al, bufMixing
      movb	%bl, bufActive

      movw	dspAckPort, %dx
      inb	%dx, %al
      movb	$0x20, %al
      outb	%al, $0x20

      cmpb	$8, irqValue
      jb	.LNo16BitEOI
      outb	 %al, $0xA0
.LNo16BitEOI:
    end;
  end;

  procedure DataSelData; assembler;
  {$I386_DIRECT}
    asm
DATASEL:	.word	0
    end;

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
  procedure StartPlayer;
  var
    i,j : Integer;
    vol : Byte;
    k	: Integer;
  begin
    { - Touch MixingBuffer so we won't get a 'var not used' warning }
    MixingBuffer[0] := 0;
    irqCounter      := 0;

    for i := 1 to MaxChannel do begin
      sbStatus[i] := stStop;
    end;
    for j := -128 to 127 do begin
      for vol := 0 to MaxVolume do begin
	tabVolume[j, vol] := ShortInt((j * vol) div MaxVolume);
      end;
    end;
    for k := (-128*MaxChannel) to (127*MaxChannel) do begin
      if (k < -128) then tabPostProc[k] :=   0 else
      if (k >  127) then tabPostProc[k] := 255 else
			 tabPostProc[k] := k+128;
    end;

    for i := 1 to 2 do begin
      BufferHandle[i] := global_dos_alloc(BufferLength);
      BufferAddr[i]   := Hi(BufferHandle[i]) shl 4;
      BufferPage[i]   := (BufferAddr[i] div 65536);
      BufferOfs[i]    := (BufferAddr[i] mod 65536);

      dosmemfillchar(Hi(BufferHandle[i]), 0, BufferLength, #0);
    end;

    irqOldMask := GetIRQMask(irqValue);
    SetIRQMask(irqValue, irqEnable);

    irqOurHandler.segment := get_cs;
    irqOurHandler.offset  := @IntHandler;
    get_pm_interrupt(irqIntVector, irqOldHandler);
    set_pm_interrupt(irqIntVector, irqOurHandler);
    {$I386_DIRECT}
    asm
      movw	%ds, %ax
      movw	%ax, DATASEL
    end;
    bufActive := 1;
    bufMixing := 2;

    WriteDSP($D1); { - SpeakerOn }

    StartBlockSingle;
  end;

  procedure StopPlayer;
  begin
    SetIRQMask(irqValue, irqOldMask);

    set_pm_interrupt(irqIntVector, irqOldHandler);

    global_dos_free(Lo(BufferHandle[1]));
    global_dos_free(Lo(BufferHandle[2]));

    WriteDSP($D3); { - SpeakerOff }
  end;

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
  function LoadRaw(name: string): pSound;
  var
    f		: file;
    Sound	: pSound;
  begin
    New(Sound);

    Assign(f, name);
    Reset(f, 1);

    with Sound^ do begin
      size := FileSize(f);
      GetMem(ptr, size);
      BlockRead(f, ptr^, size);
    end;

    Close(f);
    LoadRaw := Sound;
  end;

  procedure PlaySound(chan: Byte; sound: pSound; freq: Word; vol, status: Byte);
  begin
{|} if (vol > MaxVolume) then vol := MaxVolume;

    sbAdder [chan] := (freq shl FixedPointShift) div SampleRate;
    sbVolume[chan] := vol;
    sbStatus[chan] := status;

    if (status = stStop) then Exit;

    sbStart [chan] := Longint(sound^.ptr);
    sbPos   [chan] := 0;
    sbEnd   [chan] := sound^.size shl FixedPointShift;
    
{|} sbLoopStart [chan] := 0;
{|} sbLoopEnd   [chan] := sbEnd [chan];
  end;

  procedure FreeSound(var sound: pSound);
  begin
    if (sound <> nil) then begin
      FreeMem(sound^.ptr, sound^.size);
      Dispose(sound);
      sound := nil;
    end;
  end;

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
end.

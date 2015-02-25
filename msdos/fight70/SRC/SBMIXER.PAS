{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
  sbMixer.pas - Control SB-compatible mixer chip
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
unit sbMixer;
{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
interface
{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
var
  mixAddr	: Word;
  mixData	: Word;
  dspSB16	: Boolean;
  mixMaxVolume	: Byte;

  function  InitMixer		(BaseIO: Word): Boolean;
  procedure SetDacVolume	(Left, Right: Byte);
  procedure SetMicVolume	(Volume: Byte);
  procedure SetMasterVolume	(Left, Right: Byte);
  procedure SetFMVolume		(Left, Right: Byte);
  procedure SetCDVolume		(Left, Right: Byte);
  procedure SetLineVolume	(Left, Right: Byte);

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
implementation
{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
uses
  Go32;

function InitMixer(BaseIO: Word): Boolean;
var
  dspVersion	: Word;
  count		: Integer;
begin
  InitMixer := False;

  mixAddr := BaseIO + $04;
  mixData := BaseIO + $05;

  { - Get DSP version number }
  repeat until (inportb(BaseIO + $0C) and $80) = 0;
  outportb(BaseIO + $0C, $E1);
  while inportb(BaseIO + $0E) and $80 = 0 do { Nothing };
  dspVersion := inportb(BaseIO + $0A) shl 8;
  while inportb(BaseIO + $0E) and $80 = 0 do { Nothing };
  dspVersion := dspVersion + inportb(BaseIO + $0A);

  if (dspVersion >= $0300) then begin	{ - Only Pro or better has mixer }
    InitMixer := True;
    dspSB16   := (dspVersion >= $0400);
    if (dspSB16) then mixMaxVolume := $0F else mixMaxVolume := $07;
    outportb(mixAddr, 0);
    for count := 1 to 200 do inportb(BaseIO + $06);
    outportb(mixData, 0);
  end;
end;

procedure WriteMixer(Register, Value : byte);
begin
  outportb(mixAddr, Register);
  outportb(mixData, Value);
end;

function ReadMixer(Register : byte) : byte;
begin
  outportb(mixAddr, Register);
  ReadMixer := inportb(mixData);
end;

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
procedure SetDACVolume(Left, Right : byte);
begin
  if (dspSB16) then
    WriteMixer($04, (Left shl 4) + Right)
  else
    WriteMixer($04, (Left shl 5) + (Right shl 1));
end;

procedure SetMicVolume(Volume : byte);
begin
  if (dspSB16) then
    WriteMixer($0A, Volume)
  else
    WriteMixer($0A, Volume shl 1);
end;

procedure SetMasterVolume(Left, Right : byte);
begin
  if (dspSB16) then
    WriteMixer($22, (Left shl 4) + Right)
  else
    WriteMixer($22, (Left shl 5) + (Right shl 1));
end;

procedure SetFMVolume(Left, Right : byte);
begin
  if (dspSB16) then
    WriteMixer($26, (Left shl 4) + Right)
  else
    WriteMixer($26, (Left shl 5) + (Right shl 1));
end;

procedure SetCDVolume(Left, Right : byte);
begin
  if (dspSB16) then
    WriteMixer($28, (Left shl 4) + Right)
  else
    WriteMixer($28, (Left shl 5) + (Right shl 1));
end;

procedure SetLineVolume(Left, Right : byte);
begin
  if (dspSB16) then
    WriteMixer($2E, (Left shl 4) + Right)
  else
    WriteMixer($2E, (Left shl 5) + (Right shl 1));
end;


end.

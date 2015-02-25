{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
  sbDetect.pas - Detect SB-compatible sound card
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
unit sbDetect;
{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
interface
{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
  function  DetectSB(var BaseIO: Word; var IRQ: Byte; var DMA: Byte): Boolean;

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
implementation
{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
uses
  Dos;

  function UnHex(str: string): Word;
  const
    HexStr	: string[16]	= '0123456789ABCDEF';
  var
    i		: Integer;
    mult	: Word;
    value	: Word;
  begin
    value := 0;  mult := 1;
    for i := Length(str) downto 1 do begin
      value := value + ((pos(str[i], HexStr)-1) * mult);
      mult := mult * 16;
    end;
    UnHex := value;
  end;

  function DetectSB(var BaseIO: Word; var IRQ: Byte; var DMA: Byte): Boolean;
  var
    envStr	: string;
    eleStr	: string;
    sepPos	: Word;
  begin
    BaseIO   := $FFFF;
    IRQ	     := $FF;
    DMA      := $FF;

    DetectSB := False;
    envStr   := getenv('BLASTER');

    while (envStr <> '') do begin
      { - Dike out an element (Axxx,Ix,Dx,Hx,Tx) }
      sepPos := pos(' ', envStr);
      if (pos(' ', envStr) = 0) then begin
	eleStr := envStr;
	envStr := '';
      end else begin
	eleStr := copy(envStr, 1, sepPos-1);
	envStr := copy(envStr, sepPos+1, Length(envStr));
      end;
      if (Length(eleStr) > 1 ) then begin
	case eleStr[1] of
	  'A': BaseIO := UnHex(copy(eleStr,2,Length(eleStr)));
	  'I': IRQ    := UnHex(copy(eleStr,2,Length(eleStr)));
	  'D': DMA    := UnHex(copy(eleStr,2,Length(eleStr)));
	  { - We're not interested in the rest }
	end;
      end;
    end;
    DetectSB := ((BaseIO <> $FFFF) and (IRQ <> $FF) and (DMA <> $FF));
  end;

{ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = }
end.

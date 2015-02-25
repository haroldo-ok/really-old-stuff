(*  setup.c - Digital Sound Interface Kit V1.01a setup program.

	Copyright 1993,94 Carlos Hasan
*)
{Modified by Haroldo de Oliveira Pinheiro for use in STORMER}

{$B-,R-}

program SoundSetup;

const
  ID_NONE       = 0;
  ID_SB         = 1;
  ID_SB201      = 2;
  ID_SBPRO      = 3;
  ID_SB16       = 4;
  ID_GUS        = 5;

type
  DSMCard = record
	ID          : byte;
	Flags       : byte;
	IOAddr      : word;
	IRQNum      : byte;
	DRQNum      : byte;
	MixRate     : word;
  end;


const
  VideoSeg      = $B800;
  VideoWidth    = 80;
  VideoHeight   = 25;

const
  Black        = 0;
  Blue         = 1;
  Green        = 2;
  Cyan         = 3;
  Red          = 4;
  Magenta      = 5;
  Brown        = 6;
  LightGray    = 7;
  DarkGray     = 8;
  LightBlue    = 9;
  LightGreen   = 10;
  LightCyan    = 11;
  LightRed     = 12;
  LightMagenta = 13;
  Yellow       = 14;
  White        = 15;
  Blink        = 128;

const
  kbEsc        = $001B;
  kbEnter      = $000D;
  kbUp         = $4800;
  kbDown       = $5000;

type
  TFrame = array [0..5] of char;

  TMenu = record
    Title  : PChar;
    Option : Word;
    Items  : array [0..7] of PChar;
  end;

const
  SingleFrame: TFrame = #218#191#192#217#196#179;
  DoubleFrame: TFrame = #201#187#200#188#205#186;


procedure hide_cursor; assembler;
asm
  mov  ax,0100h
  mov  cx,2607h
  int  10h
end;

procedure SetTextMode; assembler;
asm
		mov     ax,0003h
		int     10h
end;

procedure WaitVR; assembler;
asm
        mov     dx,3DAh
@0:     in      al,dx
        test    al,08h
        jne     @0
@1:     in      al,dx
        test    al,08h
        je      @1
end;

procedure DrawRect(XLeft,YTop,XRight,YBottom:Integer; C:Char; Color:Byte); assembler;
asm
		push    si
        push    di
        push    ds
        push    es
        mov     ax,VideoSeg
        mov     es,ax
        mov     ax,[Ytop]
        mov     dx,VideoWidth
        mul     dx
        add     ax,[XLeft]
        add     ax,ax
        mov     di,ax
        mov     bx,[XRight]
        sub     bx,[XLeft]
        jl      @0
        mov     dx,[YBottom]
        sub     dx,[YTop]
        jl      @0
        inc     bx
        inc     dx
		mov     al,[C]
        mov     ah,[Color]
        cld
@1:     push    di
        mov     cx,bx
        rep     stosw
        pop     di
        add     di,2*VideoWidth
        dec     dx
        jne     @1
@0:     pop     es
        pop     ds
        pop     di
        pop     si
end;

procedure DrawBox(XLeft,YTop,XRight,YBottom:Integer; Frame:PChar; Color:Byte); assembler;
asm
        push    si
        push    di
		push    ds
        push    es
        lds     si,[Frame]
        mov     ax,VideoSeg
        mov     es,ax
        mov     ax,[YTop]
        mov     dx,VideoWidth
        mul     dx
        add     ax,[XLeft]
        add     ax,ax
        mov     di,ax
        mov     bx,[XRight]
        sub     bx,[XLeft]
        dec     bx
        jl      @0
        mov     dx,[YBottom]
        sub     dx,[YTop]
        dec     dx
        jl      @0
        mov     ah,[Color]
		cld
        push    di
        mov     al,[si+0]
        stosw
        mov     al,[si+4]
        mov     cx,bx
        rep     stosw
        mov     al,[si+1]
        stosw
        pop     di
        add     di,2*VideoWidth
@1:     push    di
        mov     al,[si+5]
        stosw
        mov     al,20h
        mov     cx,bx
        rep     stosw
        mov     al,[si+5]
        stosw
        pop     di
		add     di,2*VideoWidth
        dec     dx
        jne     @1
        mov     al,[si+2]
        stosw
        mov     al,[si+4]
        mov     cx,bx
        rep     stosw
        mov     al,[si+3]
        stosw
@0:     pop     es
        pop     ds
        pop     di
        pop     si
end;

procedure DrawText(X,Y:Integer; Text:PChar; Color:Byte); assembler;
asm
        push    si
        push    di
		push    ds
        push    es
        lds     si,[Text]
        mov     ax,VideoSeg
        mov     es,ax
        mov     ax,[Y]
        mov     dx,VideoWidth
        mul     dx
        add     ax,[X]
        add     ax,ax
        mov     di,ax
        mov     ah,[Color]
@1:     mov     al,[si]
        inc     si
        test    al,al
        je      @0
        mov     [es:di],ax
        add     di,2
        jmp     @1
@0:     pop     es
		pop     ds
        pop     di
        pop     si
end;

function StrLen(S:PChar):Integer; assembler;
asm
        push    di
        push    es
        les     di,[S]
        xor     ax,ax
@1:     mov     dl,[es:di]
        test    dl,dl
        je      @0
        inc     di
        inc     ax
        jne     @1
@0:     pop     es
        pop     di
end;

function ReadKey: word; assembler;
asm
        mov     ah,00h
        int     16h
        test    al,al
        je      @0
        xor     ah,ah
@0:
end;


procedure DrawDesktop;
begin
  DrawRect(0,0,79,24,#178,LightGray);
  DrawBox(0,0,79,2,DoubleFrame,White or Blue shl 4);
  DrawRect(0,24,79,24,#32,White or Blue shl 4);
  DrawText(22,1,'Digital Sound System Setup Program',White or Blue shl 4);
  DrawText(33,24,'STORMER SETUP',White or Blue shl 4);
end;

procedure DrawMenu(const Menu:TMenu);
var
  I,J,X,Y,Width,Height: Integer;
begin
  Width  := StrLen(Menu.Title);
  Height := 0;
  for I := 0 to 7 do begin
    if Menu.Items[I] = nil then break;
    J := StrLen(Menu.Items[I]);
    if Width < J then Width := J;
    inc(Height);
  end;
  inc(Width,6);
  inc(Height,2);

  X := (VideoWidth-Width) shr 1;
  Y := (VideoHeight-Height) shr 1;
  DrawBox(X,Y,X+Width-1,Y+Height-1,SingleFrame,White or Blue shl 4);
  DrawText(X+(Width-StrLen(Menu.Title)) shr 1,Y,Menu.Title,White or Blue shl 4);

  for I := 0 to 7 do begin
    if Menu.Items[I] = nil then break;
    J := StrLen(Menu.Items[I]);
    if Menu.Option = I then begin
      DrawRect(X+1,Y+1+I,X+Width-2,Y+1+I,#32,Blue or LightGray shl 4);
      DrawText(X+(Width-J) shr 1,Y+1+I,Menu.Items[I],Blue or LightGray shl 4);
    end
    else begin
      DrawText(X+(Width-J) shr 1,Y+1+I,Menu.Items[I],White or Blue shl 4);
    end;
  end;
end;

function DoMenu(var Menu:TMenu): Boolean;
var
  Key,Option : Word;
begin
  Option := Menu.Option;
  repeat
	WaitVR;
    DrawMenu(Menu);
    Key := ReadKey;
    case Key of
      kbUp   : if Menu.Option > 0 then dec(Menu.Option);
	  kbDown : if (Menu.Option < 7) and (Menu.Items[Succ(Menu.Option)] <> nil) then inc(Menu.Option);
	end;
  until (Key=kbEsc) or (Key=kbEnter);
  if Key=kbEsc then Menu.Option := Option;
  DoMenu := (Key=kbEsc);
end;



const
  MainMenu : TMenu =
	( Title  : ' Main Menu ';
	  Option : 0;
	  Items  : ( 'Select Soundcard',
				 'About Stormer',
				 'Save and Exit',
				 nil,
				 nil,
				 nil,
				 nil,
				 nil )
	);

  AboutMenu : TMenu =
	( Title  : ' About Stormer ';
	  Option : 0;
	  Items  : ( 'STORMER',
				 '',
				 'Programmed by',
				 'Haroldo de Oliveira Pinheiro',
				 '',
				 'Sound system:',
				 'Digital Sound Interface Kit',
				 '' )
	);

  CardMenu : TMenu =
	( Title  : ' Select Soundcard ';
	  Option : 1;
	  Items  : ( 'None               ',
				 'Sound Blaster      ',
				 'Sound Blaster 2.01 ',
				 'Sound Blaster Pro  ',
				 'Sound Blaster 16   ',
				 'Gravis Ultrasound  ',
				 nil,
				 nil )
	);

  PortMenu : TMenu =
	( Title  : ' Select I/O Port ';
	  Option : 1;
	  Items  : ( '210',
				 '220',
				 '230',
				 '240',
                 '250',
				 '260',
                 '270',
                 '280' )
    );

  IRQLineMenu : TMenu =
    ( Title  : ' Select IRQ Line ';
      Option : 3;
      Items  : ( 'IRQ 2 ',
                 'IRQ 3 ',
                 'IRQ 5 ',
				 'IRQ 7 ',
                 'IRQ 10',
                 'IRQ 11',
                 'IRQ 12',
                 'IRQ 15' )
	);

  DMAChanMenu : TMenu =
    ( Title  : ' Select DMA Channel ';
	  Option : 1;
      Items  : ( 'DMA 0',
                 'DMA 1',
                 'DMA 3',
                 nil,
				 nil,
                 nil,
                 nil,
				 nil )
	);

  MixRateMenu : TMenu =
	( Title  : ' Select Mixing Rate ';
	  Option : 2;
	  Items  : ( ' 8000 Hz',
				 '12000 Hz',
				 '16000 Hz',
				 '20000 hz',
				 '22000 Hz',
				 '28000 Hz',
				 '36000 Hz',
				 '44100 Hz' )
	);

var
  SoundCard : DSMCard;
  SoundFile : File;
begin
  SetTextMode;
  Hide_Cursor;

  while true do begin
	DrawDesktop;
	if DoMenu(MainMenu) then begin
	  MainMenu.Option := 3;
	  break;
	end;
	if MainMenu.Option = 2 then break;
	if MainMenu.Option = 1 then
		DoMenu(AboutMenu);
	if MainMenu.Option = 0 then
		begin
			if DoMenu(CardMenu) then continue;
			if CardMenu.Option = 0 then continue;
			if DoMenu(PortMenu) then continue;
			if DoMenu(IRQLineMenu) then continue;
			if DoMenu(DMAChanMenu) then continue;
			if (CardMenu.Option <> 5) then if DoMenu(MixRateMenu) then continue;
		end;
	MainMenu.Option := 1;
  end;

  SetTextMode;

  if MainMenu.Option = 2 then begin
	case CardMenu.Option of
	  0: SoundCard.ID := ID_NONE;
	  1: SoundCard.ID := ID_SB;
	  2: SoundCard.ID := ID_SB201;
	  3: SoundCard.ID := ID_SBPRO;
	  4: SoundCard.ID := ID_SB16;
	  5: SoundCard.ID := ID_GUS;
	end;
	case PortMenu.Option of
	  0: SoundCard.IOAddr := $210;
	  1: SoundCard.IOAddr := $220;
	  2: SoundCard.IOAddr := $230;
	  3: SoundCard.IOAddr := $240;
	  4: SoundCard.IOAddr := $250;
	  5: SoundCard.IOAddr := $260;
	  6: SoundCard.IOAddr := $270;
	  7: SoundCard.IOAddr := $280;
	end;
	case IRQLineMenu.Option of
	  0: SoundCard.IRQNum := 2;
	  1: SoundCard.IRQNum := 3;
	  2: SoundCard.IRQNum := 5;
	  3: SoundCard.IRQNum := 7;
	  4: SoundCard.IRQNum := 10;
	  5: SoundCard.IRQNum := 11;
	  6: SoundCard.IRQNum := 12;
	  7: SoundCard.IRQNum := 15;
	end;
	case DMAChanMenu.Option of
	  0: SoundCard.DRQNum := 0;
	  1: SoundCard.DRQNum := 1;
	  2: SoundCard.DRQNum := 3;
	end;
	case MixRateMenu.Option of
	  0: SoundCard.MixRate := 8000;
	  1: SoundCard.MixRate := 12000;
	  2: SoundCard.MixRate := 16000;
	  3: SoundCard.MixRate := 20000;
	  4: SoundCard.MixRate := 22000;
	  5: SoundCard.MixRate := 28000;
	  6: SoundCard.MixRate := 36000;
	  7: SoundCard.MixRate := 44100;
	end;

	if (SoundCard.ID = ID_SB) or (SoundCard.ID = ID_SBPro) then begin
	  if SoundCard.MixRate >= 22050 then SoundCard.MixRate := 22050;
	end;

	{$I-}
	Assign(SoundFile,'SOUND.CFG');
	Rewrite(SoundFile,1);
	BlockWrite(SoundFile,SoundCard,sizeof(SoundCard));
	Close(SoundFile);
	{$I+}

	if IOResult <> 0 then writeln('Error saving SOUND.CFG file.')
	else writeln('Setup file saved.');
  end
  else begin
	writeln('Setup aborted.');
  end;
end.

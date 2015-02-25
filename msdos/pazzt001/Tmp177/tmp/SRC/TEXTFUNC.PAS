unit TextFuncs;
interface
	const
		Default_VGA_Font:Pointer=nil;

	procedure TextMode80x25_Char8;
	procedure LoadVGAFont(Font: Pointer);
	procedure RestoreTextMode;
implementation
	uses Crt;

	{$L 8x16.OBJ}
	procedure VGA_Font8x16;external;

	var VGA_Old_Font: Pointer;

	procedure LoadVGAFont(Font: Pointer);
		var Segm, Offs: word;
		begin
			Segm := Seg(Font^);
			Offs := Ofs(Font^);

			asm
				push 	bp
				mov		ax, 1100h
				mov		es, [Segm]
				mov		bp, [Offs]
				mov		cx, 256
				mov		dx, 0
				mov		bl, 0
				mov		bh, 16
				int		10h
				pop		bp
			end;
		end;

	procedure SaveOldFont;
		var Segm, Offs: word;
		begin
			TextMode(co80);

			{Salva a antiga fonte}
			asm
				push	bp
				mov		ax, 1130h
				mov		bh, 06h
				int		10h
				mov		ax, bp
				pop		bp
				mov		[Segm], es
				mov		[Offs], ax
			end;

			VGA_Old_Font := Ptr(Segm,Offs);
		end;

	procedure TextMode80x25_Char8;
		var Segm, Offs: word;
		begin
			{Ajusta a fonte para 8x16}
			asm
				push	bp
				mov		ax, 1202h
				mov		bx, 0030h
				int		10h
				pop		bp
			end;

			TextMode(co80);

			{The six lines below were taken from ZIG.}
			Port[$3C4] := $01;
			Port[$3C5] := $01;{     -- char width of 8}
			Port[$3C2] := $63;{     -- use 25.175MHz dotclock}
			Offs := Port[$3DA];{       -- reset attrib control}
			Port[$3C0] := $33;
			Port[$3C0] := $00;{    -- reset}

			{Configura a fonte nova}
			LoadVGAFont(Addr(VGA_Font8x16));
		end;

	procedure RestoreTextMode;
		begin
			{Ajusta a fonte para 8x16}
			asm
				push	bp
				mov		ax, 1202h
				mov		bx, 0030h
				int		10h
				pop		bp
			end;
			TextMode(co80);

			{Restaura a antiga fonte}
			LoadVGAFont(VGA_Old_Font);
		end;

	var OldExit:pointer;

	procedure NewExitProc;Far; {Uma salvaguarda para o caso do programa dar erro.}
		begin
			RestoreTextMode;
			ExitProc := OldExit;
		end;
Begin
	SaveOldFont;
	Default_VGA_Font := Addr(VGA_Font8x16);
	OldExit := ExitProc;
	ExitProc := @NewExitProc;
End.
program PalMake;
	uses Utils;

	const
		MAX_TILES = 128;

		TILESET_ATR_BLOCK_UP    = $0001;
		TILESET_ATR_BLOCK_DOWN  = $0002;
		TILESET_ATR_BLOCK_LEFT  = $0004;
		TILESET_ATR_BLOCK_RIGHT = $0008;
		TILESET_ATR_PALETTE     = $6000;
		TILESET_ATR_PRIORITY    = $8000;

		TILESET_ATR_SOLID = TILESET_ATR_BLOCK_UP or
							TILESET_ATR_BLOCK_DOWN or
							TILESET_ATR_BLOCK_LEFT or
							TILESET_ATR_BLOCK_RIGHT;
		TILESET_ATR_BLOCK_LR = TILESET_ATR_BLOCK_LEFT or
							   TILESET_ATR_BLOCK_RIGHT;
		TILESET_ATR_BLOCK_UD = TILESET_ATR_BLOCK_UP or
							   TILESET_ATR_BLOCK_DOWN;

		TILESET_ATR_PAL_SHIFT = 13;

	type
		StrAtr= record
					S: String[10];
					A: Word;
				end;

	const
		AttrList : array [0..16] of StrAtr=(
			(S:'CLOSED';A:TILESET_ATR_SOLID),
			(S:'SOLID';A:TILESET_ATR_SOLID),
			(S:'BLOCK';A:TILESET_ATR_SOLID),
			(S:'SIDES';A:TILESET_ATR_BLOCK_LR),
			(S:'LR';A:TILESET_ATR_BLOCK_LR),
			(S:'TOPDOWN';A:TILESET_ATR_BLOCK_UD),
			(S:'UPDOWN';A:TILESET_ATR_BLOCK_LR),
			(S:'LEFT';A:TILESET_ATR_BLOCK_LEFT),
			(S:'WEST';A:TILESET_ATR_BLOCK_LEFT),
			(S:'RIGHT';A:TILESET_ATR_BLOCK_RIGHT),
			(S:'EAST';A:TILESET_ATR_BLOCK_RIGHT),
			(S:'UP';A:TILESET_ATR_BLOCK_UP),
			(S:'TOP';A:TILESET_ATR_BLOCK_UP),
			(S:'NORTH';A:TILESET_ATR_BLOCK_UP),
			(S:'DOWN';A:TILESET_ATR_BLOCK_DOWN),
			(S:'BOTTOM';A:TILESET_ATR_BLOCK_DOWN),
			(S:'SOUTH';A:TILESET_ATR_BLOCK_DOWN)
			);

	var
		Attributes: array[0..Pred(MAX_TILES)] of Word;
		InFileName: String;
		OutFileName: String;

	function FindAttr(S: String): Word;
		var i : Integer;
		begin
			i := 0;
			while (i < 17) and (AttrList[i].S <> S) do
				Inc(i);
			if i < 17 then
				FindAttr := AttrList[i].A
			else
				FindAttr := 0;
		end;

	function ParseAttrs(S: String): Word;
		var Token : String;
			Attr, N: Word;
		begin
			Attr := 0;
			while S <> '' do
				begin
					Token := UpperCase(GetToken(S));
					if (Token = 'CLEAR') or (Token = 'OPEN') then
						Attr := 0
					else if Token = 'FRONT' then
						Attr := Attr or TILESET_ATR_PRIORITY
					else if Token = 'BACK' then
						Attr := Attr and not TILESET_ATR_PRIORITY
					else if Copy(Token, 1, 3) = 'PAL' then
						Attr := (Attr and not TILESET_ATR_PALETTE) or
								((ReadNumber(Copy(Token, 4, 5)) shl TILESET_ATR_PAL_SHIFT) and TILESET_ATR_PALETTE)
					else
						begin
							N := FindAttr(Token);
							if N = 0 then
								begin
									Writeln('Invalid attribute: "' + Token + '"');
									Halt(1);
								end
							else
								Attr := Attr or N;
						end;
				end;

			ParseAttrs := Swap(Attr);
		end;

	procedure ReadScript(FileName: String);
		var T : Text;
			S : String;
			TileNum : Integer;
		begin
			Assign(T, FileName);
			Reset(T);
			while not Eof(T) do
				begin
					Readln(T, S);
					if (S <> '') and not (S[1] in [';', '#']) then
						begin
							TileNum := ReadNumber(GetToken(S));
							Attributes[TileNum] := ParseAttrs(S);
						end;
				end;
			Close(T);
		end;

	procedure SaveAttributes(FileName: String);
		var F: File;
		begin
			Assign(F, FileName);
			Rewrite(F, 1);
			BlockWrite(F, Attributes, SizeOf(Attributes));
			Close(F);
		end;

Begin
	if (ParamCount < 2) then
		begin
			Writeln('Attribute Maker v0.01 by Haroldo de Oliveira Pinheiro');
			Writeln('USAGE: ATRMAKE <dest tile attribute file> <source file>');
			Halt(255);
		end;

	Writeln('Attribute Maker v0.01 by Haroldo de Oliveira Pinheiro');

	InFileName  := ParamStr(2);
	OutFileName := ParamStr(1);

	if not FileExists(InFileName) then
		begin
			Writeln('File "', InFileName, '" not found.');
			Halt(255);
		end;

	Write('Generating ', OutFileName, ' from ', InFileName, '... ');
	FillChar(Attributes, SizeOf(Attributes), 0);
	ReadScript(InFileName);
	SaveAttributes(OutFileName);
	Writeln('Done.');
End.
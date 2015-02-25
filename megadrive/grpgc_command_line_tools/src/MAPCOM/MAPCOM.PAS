{
Genesis RPG Creator map compiler
by Haroldo de Oliveira Pinheiro

You may do wathever you want with these sources, as long as
you give proper credit.
}

{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V-,X+}
{$M 16384,0,655360}
program MapCom;
	uses Utils, RDCUnit;

	const
		MAX_TILESETS = 1;
		MAX_PALETTES = 4;
		MAX_SPRITES  = 16;
		MAX_ACTORS = 64;
		MAX_EXITS = 16;

		COMPRESSION_NONE = 0;
		COMPRESSION_RDC  = 1;
		COMPRESSION_RLE  = 2;

		DEST_SAME   = -1;
		DEST_MIRROR = -2;

	type
		PByte = ^Byte;
		Actor = record
					X, Y : Integer;
					PalNum : Byte;
					SprNum : Byte;
					Ref : String[8];
				end;
		ExitCoord = record
						X, Y: Integer;
						W, H: Integer;
						DestX, DestY : Integer;
						Ref : String[8];
					end;

	var InFileName : String;
		OutFileName: String;
		LineNumber : Integer;

		MapWidth, MapHeight    : Word;
		PlayerPosX, PlayerPosY : Integer;
		MapData                : PByte;
		Compression            : Byte;
		WrapX, WrapY           : Boolean;
		TileSetRefs            : array [0..Pred(MAX_TILESETS)] of string[8];
		TileSetCount           : Integer;
		PaletteRefs            : array [0..Pred(MAX_PALETTES)] of string[8];
		PalCount               : Integer;
		SpriteRefs             : array [0..Pred(MAX_SPRITES)] of string[8];
		SprCount               : Integer;
		Actors                 : array [0..Pred(MAX_ACTORS)] of Actor;
		ActCount               : Integer;
		Exits                  : array [0..Pred(MAX_EXITS)] of ExitCoord;
		ExitCount              : Integer;

	procedure ParsingError(Msg: String);
		begin
			Writeln('Error at line ', LineNumber, ': ', Msg);
			Halt(2);
		end;

	function  ParseInt(var S: String): Integer;
		var Token : String;
			N     : Integer;
			Error : Integer;
		begin
			Token := GetToken(S);
            Val(Token, N, Error);
			if Error <> 0 then
				ParsingError('"' + Token + '" is not a valid numeric value.');
			ParseInt := N;
		end;

	function  ParseMapDest(var S: String): Integer;
		var Token : String;
			N     : Integer;
    	begin
    		Token := UpperCase(GetToken(S));

			if Token = 'SAME' then
				N := DEST_SAME
			else if Token = 'MIRROR' then
				N := DEST_MIRROR
            else
				N := ParseInt(Token);

			ParseMapDest := N;
		end;

	{Routine designed to simplify handling of strings longer than 255 chars}
	function NextChar(var T: Text; var S: String): Char;
		begin
			if (S = '') and not Eoln(T) then
				Read(T, S);

			if S <> '' then
				begin
					NextChar := S[1];
					Delete(S, 1, 1);
				end
			else
				NextChar := #0;
		end;

	procedure ParseHexData(var T: Text; var S: String; var Data; MaxSize: Longint);
		var
			P    : PByte;
			B    : Byte;
			Step : Byte;
			Ch   : Char;
		begin
			P := Addr(Data);

			B    := 0;
			Step := 0;
			Ch   := UpCase(NextChar(T, S));
			while Ch <> #0 do
				begin
					while not (Ch in [#0, #9, ' ']) do
						begin
							if Ch in ['0'..'9', 'A'..'F'] then
								B := (B shl 4) or ReadNumber('$' + Ch)
							else
                                ParsingError('Invalid character in hex data: "' + Ch + '"');

							Inc(Step);
							if Step = 2 then
								begin
									P^   := B;
									B    := 0;
									Step := 0;
									Inc(P);
								end;

							Ch := UpCase(NextChar(T, S));
						end;

					if Step <> 0 then {Writes any remaining half-bytes to the buffer}
						begin
							P^   := B;
							B    := 0;
							Step := 0;
							Inc(P);
						end;

					Ch := UpCase(NextChar(T, S));
				end;

			Readln(T);
			Inc(LineNumber);
		end;

	procedure ParseMapSize(var S: String);
		begin
			MapWidth  := ParseInt(S);
			MapHeight := ParseInt(S);
		end;

	procedure ParseCompression(var S: String);
		var Token : String;
		begin
			Token := UpperCase(GetToken(S));
			if Token = 'NONE' then
				Compression := COMPRESSION_NONE
			else if Token = 'RDC' then
				Compression := COMPRESSION_RDC
			else if Token = 'RLE' then
				Compression := COMPRESSION_RLE
			else
				ParsingError('Unknown compression type: "' + Token + '"');
		end;

	procedure ParsePlayerPos(var S: String);
		begin
			PlayerPosX := ParseInt(S);
			PlayerPosY := ParseInt(S);
		end;

	procedure ParseTileSet(var S: String);
		var TsNum  : Integer;
			TsName : String[8];
		begin
			TsNum := ParseInt(S);
			if (TsNum < 0) or (TsNum >= MAX_TILESETS) then
				ParsingError('Invalid tileset number: "' + IntToStr(TsNum) + '"');
            TsName := UpperCase(GetToken(S));
			if TsName = '' then
				ParsingError('Tileset name not specified');
			TileSetRefs[TsNum] := TsName;
			if (TsNum+1) > TileSetCount then
				TileSetCount := TsNum + 1;
		end;

	procedure ParsePalette(var S: String);
		var PalNum  : Integer;
			PalName : String[8];
		begin
			PalNum := ParseInt(S);
			if (PalNum < 0) or (PalNum >= MAX_PALETTES) then
				ParsingError('Invalid palette number: "' + IntToStr(PalNum) + '"');
            PalName := UpperCase(GetToken(S));
			if PalName = '' then
				ParsingError('Palette name not specified');
			PaletteRefs[PalNum] := PalName;
			if (PalNum+1) > PalCount then
				PalCount := PalNum + 1;
		end;

	procedure ParseSprite(var S: String);
		var SprNum  : Integer;
			SprName : String[8];
		begin
			SprNum := ParseInt(S);
			if (SprNum < 0) or (SprNum >= MAX_SPRITES) then
				ParsingError('Invalid sprite number: "' + IntToStr(SprNum) + '"');
            SprName := UpperCase(GetToken(S));
			if SprName = '' then
				ParsingError('Sprite name not specified');
			SpriteRefs[SprNum] := SprName;
			if (SprNum+1) > SprCount then
				SprCount := SprNum + 1;
		end;

	procedure ParseActor(var S: String);
		begin
			if ActCount = MAX_ACTORS then
				ParsingError('Maximum number of actors exceeded.');

            Actors[ActCount].X      := ParseInt(S);
            Actors[ActCount].Y      := ParseInt(S);
            Actors[ActCount].PalNum := ParseInt(S);
            Actors[ActCount].SprNum := ParseInt(S);
            Actors[ActCount].Ref    := UpperCase(GetToken(S));

			Inc(ActCount);
		end;

	procedure ParseExit(var S: String);
		var	Token : String[16];
		begin
			if ExitCount = MAX_EXITS then
				ParsingError('Maximum number of exits exceeded.');

			Token := UpperCase(GetToken(S));

            if (Token = 'LEFT') or (Token = 'WEST') then
				begin
					Exits[ExitCount].X := 0;
					Exits[ExitCount].Y := 0;
					Exits[ExitCount].W := 1;
					Exits[ExitCount].H := MapHeight;

					Exits[ExitCount].DestX := DEST_MIRROR;
					Exits[ExitCount].DestY := DEST_SAME;
				end
			else if (Token = 'RIGHT') or (Token = 'EAST') then
				begin
					Exits[ExitCount].X := MapWidth-1;
					Exits[ExitCount].Y := 0;
					Exits[ExitCount].W := 1;
					Exits[ExitCount].H := MapHeight;

					Exits[ExitCount].DestX := DEST_MIRROR;
					Exits[ExitCount].DestY := DEST_SAME;
				end
			else if (Token = 'TOP') or (Token = 'NORTH') then
				begin
					Exits[ExitCount].X := 0;
					Exits[ExitCount].Y := 0;
					Exits[ExitCount].W := MapWidth;
					Exits[ExitCount].H := 1;

					Exits[ExitCount].DestX := DEST_SAME;
					Exits[ExitCount].DestY := DEST_MIRROR;
				end
			else if (Token = 'BOTTOM') or (Token = 'SOUTH') then
				begin
					Exits[ExitCount].X := 0;
					Exits[ExitCount].Y := MapHeight-1;
					Exits[ExitCount].W := MapWidth;
					Exits[ExitCount].H := 1;

					Exits[ExitCount].DestX := DEST_SAME;
					Exits[ExitCount].DestY := DEST_MIRROR;
				end
			else
				begin
					Exits[ExitCount].X := ParseInt(Token);
					Exits[ExitCount].Y := ParseInt(S);
					Exits[ExitCount].W := ParseInt(S);
					Exits[ExitCount].H := ParseInt(S);

					Exits[ExitCount].DestX := DEST_SAME;
					Exits[ExitCount].DestY := DEST_SAME;
				end;

			Exits[ExitCount].Ref := UpperCase(GetToken(S));

			Token := GetToken(S);
			if Token <> '' then
				begin
					Exits[ExitCount].DestX := ParseMapDest(Token);
					Exits[ExitCount].DestY := ParseMapDest(S);
				end;

			Inc(ExitCount);
		end;

	procedure ParseMap(var T: Text; var S: String);
		var Finished  : Boolean;
			Step      : Byte;
			MapLine   : PByte;
			LinesToGo : Word;
			Token     : String[8];
		begin
			Finished := False;
			GetMem(MapData, MapWidth*MapHeight);
			FillChar(MapData^, MapWidth*MapHeight, 0);
			MapLine   := MapData;
			LinesToGo := MapHeight;
			while not Finished do
				begin
					Read(T, S); {Since the line may be longer than 255 chars, it will require special treatment}
					if (S <> '') and (S[1] = '#') then
						begin
							Token := UpperCase(GetToken(S));
							if Token <> '#END' then
								ParsingError('Invalid command: Expected "#END", but found "' + Token + '"');
							Finished := True;
						end
					else if LinesToGo <> 0 then
						begin
							ParseHexData(T, S, MapLine^, MapWidth);
							Inc(MapLine, MapWidth);
							Dec(LinesToGo);

							if Eof(T) then
                                ParsingError('Unexpected end of file');
						end;
				end;
		end;

	procedure ParseString(var T: Text; var S: String);
		var CurrToken : String[64];
		begin
			S := LTrim(S);
			if (S <> '') then
				begin
				if (S[1] = '''') then {Comment}
					begin
					end
				else
				if (S[1] = '#') then {Command}
					begin
						CurrToken := UpperCase(GetToken(S));
						if CurrToken = '#MAPSIZE' then
							ParseMapSize(S)
						else if CurrToken = '#COMPRESSION' then
							ParseCompression(S)
						else if CurrToken = '#PLAYERPOS' then
							ParsePlayerPos(S)
						else if CurrToken = '#TILESET' then
							ParseTileSet(S)
						else if CurrToken = '#PALETTE' then
							ParsePalette(S)
						else if CurrToken = '#SPRITE' then
							ParseSprite(S)
						else if CurrToken = '#ACTOR' then
							ParseActor(S)
						else if CurrToken = '#EXIT' then
							ParseExit(S)
						else if CurrToken = '#MAP' then
							ParseMap(T, S)
						else
							begin
								ParsingError('Unknown command: "' + CurrToken + '"');
							end;
					end
				else
					begin
						ParsingError('Unknown command: "' + GetToken(S) + '"');
					end;
				end;
		end;

	procedure ParseInputFile(FileName: String);
		var T: Text;
			S: String;
		begin
			Assign(T, FileName);
			Reset(T);

			LineNumber := 1;
			while not Eof(T) do
				begin
					Readln(T, S);
					ParseString(T, S);
					Inc(LineNumber);
				end;

			Close(T);
		end;

	procedure SetDefaults;
		var i : Integer;
		begin
			MapWidth    := 64;
			MapHeight   := 64;
			Compression := COMPRESSION_NONE;
			WrapX       := False;
			WrapY       := False;

			for i := 0 to Pred(MAX_TILESETS) do
				TileSetRefs[i] := 'DEFAULT';
			TileSetCount := 0;

			for i := 0 to Pred(MAX_PALETTES) do
				PaletteRefs[i] := 'DEFAULT';
			PalCount := 0;

			for i := 0 to Pred(MAX_SPRITES) do
				SpriteRefs[i] := '';
			SprCount := 0;

			for i := 0 to Pred(MAX_ACTORS) do
				begin
					Actors[i].X      := 0;
					Actors[i].Y      := 0;
					Actors[i].SprNum := 0;
					Actors[i].PalNum := 0;
					Actors[i].Ref    := '';
				end;
			ActCount := 0;

			for i := 0 to Pred(MAX_EXITS) do
				begin
					Exits[i].X      := 0;
					Exits[i].Y      := 0;
					Exits[i].W      := 0;
					Exits[i].H      := 0;
					Exits[i].DestX  := 0;
					Exits[i].DestY  := 0;
					Exits[i].Ref    := '';
				end;
			ExitCount := 0;
		end;

	procedure WriteWord(var F: File; W: Word); {Writes a word, MSB first}
		var
			Buf : array [0..1] of Byte;
		begin
			Buf[0] := W shr 8;
			Buf[1] := W and $FF;
			BlockWrite(F, Buf, SizeOf(Buf));
		end;

	procedure WriteString(var F: File; S: String; Size: Byte); {Writes a string in the required format}
		begin
			while Length(S) <> Size do
				S := S + #0;
			BlockWrite(F, S[1], Size);
		end;

	procedure WriteEntryHeader(var F: File; var Sig; Size, Recs: Word);
		var
			Buf : array [0..1] of Byte;
		begin
			BlockWrite(F, Sig, 4);
			WriteWord(F, Size);
			WriteWord(F, Recs);
		end;

	procedure WriteMapHeader(var F: File);
		const
			MAP_SIGNATURE : array[0..3] of Char = 'MAP'#0;
			VERSION = $0100;

		var Flags: Word;
		begin
			BlockWrite(F, MAP_SIGNATURE, SizeOf(MAP_SIGNATURE));
			WriteWord(F, VERSION);

			{Write flags}
			Flags := Compression;
			WriteWord(F, Flags);

			WriteWord(F, MapWidth);
			WriteWord(F, MapHeight);
		end;

	procedure WriteMapExits(var F: File);
		const
			SIGNATURE : array[0..3] of Char = 'EXI'#0;
			RECSIZE = 20;
		var i : Integer;
		begin
			WriteEntryHeader(F, SIGNATURE, ExitCount*RECSIZE, ExitCount);

        	for i := 0 to Pred(ExitCount) do
				begin
					WriteWord(F, Exits[i].X);
					WriteWord(F, Exits[i].Y);
					WriteWord(F, Exits[i].W);
					WriteWord(F, Exits[i].H);
					WriteWord(F, Exits[i].DestX);
					WriteWord(F, Exits[i].DestY);
					WriteString(F, Exits[i].Ref, 8);
				end;
		end;

	procedure WriteMapPalettes(var F: File);
		const
			SIGNATURE : array[0..3] of Char = 'PAL'#0;
			RECSIZE = 8;
		var i : Integer;
		begin
			WriteEntryHeader(F, SIGNATURE, PalCount*RECSIZE, PalCount);

			for i := 0 to Pred(PalCount) do
				WriteString(F, PaletteRefs[i], 8);
		end;

	procedure WriteMapTileSets(var F: File);
		const
			SIGNATURE : array[0..3] of Char = 'TIL'#0;
			RECSIZE = 8;
		var i : Integer;
		begin
			WriteEntryHeader(F, SIGNATURE, TileSetCount*RECSIZE, TileSetCount);

			for i := 0 to Pred(TileSetCount) do
				WriteString(F, TileSetRefs[i], 8);
		end;

	procedure WriteMapSprites(var F: File);
		const
			SIGNATURE : array[0..3] of Char = 'SPR'#0;
			RECSIZE = 8;
		var i : Integer;
		begin
			WriteEntryHeader(F, SIGNATURE, SprCount*RECSIZE, SprCount);

			for i := 0 to Pred(SprCount) do
				WriteString(F, SpriteRefs[i], 8);
		end;

	procedure WriteMapActors(var F: File);
		const
			SIGNATURE : array[0..3] of Char = 'ACT'#0;
			RECSIZE = 16;
		var i : Integer;
		begin
			WriteEntryHeader(F, SIGNATURE, ActCount*RECSIZE, ActCount);

			for i := 0 to Pred(ActCount) do
				begin
					WriteWord(F, Actors[i].X);
					WriteWord(F, Actors[i].Y);
					WriteWord(F, Actors[i].PalNum);
					WriteWord(F, Actors[i].SprNum);
					WriteString(F, Actors[i].Ref, 8);
				end;
		end;

	procedure WriteMapData(var F: File);
		const
			SIGNATURE_CMP_NONE : array[0..3] of Char = 'RAW'#0;
			SIGNATURE_CMP_RDC  : array[0..3] of Char = 'RDC'#0;
			SIGNATURE_CMP_RLE  : array[0..3] of Char = 'RLE'#0;
		var Buffer: PByte;
			Size  : Word;
		begin
			case Compression of
				COMPRESSION_NONE:
					begin
						BlockWrite(F, MapData^, MapWidth*MapHeight);
						WriteEntryHeader(F, SIGNATURE_CMP_NONE, MapWidth*MapHeight, 0);
					end;

				COMPRESSION_RDC:
					begin
						GetMem(Buffer, 65528);
						Size := Comp_BufferToBuffer(MapData^, MapWidth*MapHeight, Buffer^);
						WriteEntryHeader(F, SIGNATURE_CMP_RDC, Size, 0);
						BlockWrite(F, Buffer^, Size);
						FreeMem(Buffer, 65528);
					end;

				COMPRESSION_RLE:
					begin
						WriteEntryHeader(F, SIGNATURE_CMP_RLE, 0, 0);
					end;
			end;
		end;

	procedure WriteMapTrailer(var F: file);
		const
			SIGNATURE : array[0..3] of Char = 'END'#0;
		begin
			WriteEntryHeader(F, SIGNATURE, 0, 0);
		end;

	procedure WriteOutputFile(FileName: String);
		var F: File;
		begin
			Assign(F, FileName);
			Rewrite(F, 1);

			WriteMapHeader(F);
			WriteMapPalettes(F);
			WriteMapTileSets(F);
			WriteMapSprites(F);
			WriteMapActors(F);
			WriteMapExits(F);
			WriteMapData(F);
			WriteMapTrailer(F);

			Close(F);
		end;
Begin
	if (ParamCount < 2) then
		begin
			Writeln('Map Compiler v0.01 by Haroldo de Oliveira Pinheiro');
			Writeln('USAGE: MAPCOM <dest map> <source text>');
			Halt(255);
		end;

	Writeln('Map Compiler v0.01 by Haroldo de Oliveira Pinheiro');

	InFileName  := ParamStr(2);
	OutFileName := ParamStr(1);

	if not FileExists(InFileName) then
		begin
			Writeln('File "', InFileName, '" not found.');
			Halt(255);
		end;

	SetDefaults;
	Writeln('Parsing "' + InFileName + '"');
	ParseInputFile(InFileName);
	Writeln('Generating "' + OutFileName + '"');
	WriteOutputFile(OutFileName);
	Writeln('Done.');
End.
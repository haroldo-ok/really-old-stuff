program PalMake;
	uses Utils;

	const
		MAX_COLORS = 16;

	type
		RGB=record
				R, G, B: byte;
			end;

	var InFileName : String;
		OutFileName: String;
		Pal: array[0..Pred(MAX_COLORS)] of RGB;

	procedure ReadRGB(var Triplet: RGB; S: String);
		begin
			S := LTrim(S);
			Triplet.R := ReadNumber('$' + GetToken(S)) shl 4;
			Triplet.G := ReadNumber('$' + GetToken(S)) shl 4;
			Triplet.B := ReadNumber('$' + GetToken(S)) shl 4;
		end;

	procedure ReadRGBPSP(var Triplet: RGB; S: String);
		begin
			S := LTrim(S);
			Triplet.R := ReadNumber(GetToken(S));
			Triplet.G := ReadNumber(GetToken(S));
			Triplet.B := ReadNumber(GetToken(S));
		end;

	procedure ReadPal(FileName: String);
		var T: Text;
			S: String;
			i: integer;
			IsPSP: Boolean;
		begin
			Assign(T, FileName);
			Reset(T);

			FillChar(Pal, SizeOf(Pal), 0);

			IsPSP := False;

			Readln(T, S);
			IsPSP := (S = 'JASC-PAL');
			if IsPSP then
				begin
					Readln(T);
					Readln(T);

					i := 0;
				end
			else
				begin
					ReadRGB(Pal[0], S);
					i := 1;
				end;

			while not Eof(T) and (i < MAX_COLORS) do
				begin
					Readln(T, S);
					if IsPSP then
						ReadRGBPSP(Pal[i], S)
					else
						ReadRGB(Pal[i], S);
					Inc(i);
				end;

			Close(T);
		end;

	function EncodeRGB(Triplet: RGB): Word;
		var W: Word;
		begin
			W := (Triplet.B shr 4) and $0E;
			W := (W shl 4) or ((Triplet.G shr 4) and $0E);
			W := (W shl 4) or ((Triplet.R shr 4) and $0E);

			EncodeRGB := Swap(W);
		end;

	procedure WritePal(FileName: String);
		var F: File;
			i: Integer;
			W: Word;
		begin
			Assign(F, FileName);
			Rewrite(F, 1);

			for i := 0 to Pred(MAX_COLORS) do
				begin
					W := EncodeRGB(Pal[i]);
					BlockWrite(F, W, 2);
				end;

			Close(F);
		end;
Begin
	if (ParamCount < 2) then
		begin
			Writeln('Palette Maker v0.01 by Haroldo de Oliveira Pinheiro');
			Writeln('USAGE: PALMAKE <dest bin palette> <source palette>');
			Writeln('Source may be either a simple text, or a Paint Shop Pro palette.');
			Halt(255);
		end;

	Writeln('Palette Maker v0.01 by Haroldo de Oliveira Pinheiro');

	InFileName  := ParamStr(2);
	OutFileName := ParamStr(1);

	if not FileExists(InFileName) then
		begin
			Writeln('File "', InFileName, '" not found.');
			Halt(255);
		end;

	Write('Converting palette ', InFileName, ' to ', OutFileName, '... ');
	ReadPal(InFileName);
	WritePal(OutFileName);
	Writeln('Done.');
End.
{
Nested text routines
by Haroldo de Oliveira Pinheiro

You may do wathever you want with these sources, as long as
you give proper credit.
}
unit NestText;
interface
	const
		NTXT_MAX_DEPTH = 8;

	type
		NTextRec=record
					CurrDepth: byte;
					Files: array[0..Pred(NTXT_MAX_DEPTH)] of Text;
				 end;

	procedure NTxtOpen(var Txt: NTextRec; FileName: String);
	procedure NTxtInclude(var Txt: NTextRec; FileName: String);
	procedure NTxtClose(var Txt: NTextRec);
	function NTxtReadLn(var Txt: NTextRec): String;
	function NTxtEof(var Txt: NTextRec): Boolean;
implementation
	procedure NTxtOpen(var Txt: NTextRec; FileName: String);
		begin
			Txt.CurrDepth := 1;
			Assign(Txt.Files[0], FileName);
			Reset(Txt.Files[0]);
		end;

	procedure NTxtInclude(var Txt: NTextRec; FileName: String);
		begin
			Inc(Txt.CurrDepth);
			if Txt.CurrDepth > NTXT_MAX_DEPTH then
				begin
					Writeln('Maximum include depth overrun.');
					RunError(4);
				end;

			Assign(Txt.Files[Pred(Txt.CurrDepth)], FileName);
			Reset(Txt.Files[Pred(Txt.CurrDepth)]);
		end;

	procedure NTxtClose(var Txt: NTextRec);
		var i: byte;
		begin
			if Txt.CurrDepth <> 0 then
				for i := 0 to Pred(Txt.CurrDepth) do
					Close(Txt.Files[i]);
			Txt.CurrDepth := 0;
		end;

	function NTxtReadLn(var Txt: NTextRec): String;
		var S: String;
		begin
			If NTxtEof(Txt) Then
				RunError(100);
			Readln(Txt.Files[Pred(Txt.CurrDepth)], S);

			NTxtReadLn := S;
		end;

	function NTxtEof(var Txt: NTextRec): Boolean;
		begin
			while (Txt.CurrDepth <> 0)                and
				  Eof(Txt.Files[Pred(Txt.CurrDepth)]) do
				begin
					Close(Txt.Files[Pred(Txt.CurrDepth)]);
					Dec(Txt.CurrDepth);
				end;

			NTxtEof := (Txt.CurrDepth = 0);
		end;
End.
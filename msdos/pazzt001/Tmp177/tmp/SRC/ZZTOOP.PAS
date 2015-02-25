unit ZZTOOP;
interface
	uses ZZTLoad;

	function GetObjLine(Prog: PChar; var Position, Size: word): string;

	procedure SendObjectToLabel(ObjNum: word; Lbl: string);
	procedure ExecuteObjectScript(ObjNum: word);

implementation
	uses Utils, Strings;

	function GetObjLine(Prog: PChar; var Position, Size: word): string;
		var C: PChar;
			OldPos: word;
			S: string;
		begin
			C := Prog;
			Inc(C,Position);
			OldPos := Position;
			S := '';

			while (Position < Size) and not(C^ in [#10,#13]) do {Reads the line to the end}
				begin
					S := S + C^;
					Inc(C);
					Inc(Position);
				end;

			if C^ = #10 then
				begin
					Inc(C);
					Inc(Position);
					if C^ = #13 then
						begin
							Inc(C);
							Inc(Position);
						end;
				end
			else if C^ = #13 then
				begin
					Inc(C);
					Inc(Position);
					if C^ = #10 then
						begin
							Inc(C);
							Inc(Position);
						end;
				end;

			while (S <> '') and (S[Length(S)] = ' ') do
				Delete(S,Length(S),1);

			GetObjLine := S;
		end;

	procedure SendObjectToLabel(ObjNum: word; Lbl: string);
		var
			Obj: ^ZZTObjHeader;
			C: PChar;
			CurrPos,LastPos: word;
			S: string;
			Found: boolean;
		begin
			if Lbl = '' Then
				exit;

			Obj := Addr(CurrentBoard.Objects[ObjNum]);
			C := CurrentBoard.Programs[ObjNum];
			CurrPos := 0;
			LastPos := $FFFF;
			Found := False;

			while (CurrPos <= Obj^.Length) and not(LastPos = CurrPos) and not(Found) do
				begin
					LastPos := CurrPos;
					S := GetObjLine(C,CurrPos,Obj^.Length);
					Found := (UpperCase(S) = ':' + UpperCase(Lbl));
				end;

			if Found then
				Obj^.CurrIns := CurrPos;
		end;

	procedure ExecuteObjectScript(ObjNum: word);
		var
			Obj: ^ZZTObjHeader;
			C: PChar;
			CurrPos,LastPos: word;
			S: string;
			Done: boolean;
		begin
			Obj := Addr(CurrentBoard.Objects[ObjNum]);
			C := CurrentBoard.Programs[ObjNum];
			CurrPos := Obj^.CurrIns;
			LastPos := $FFFF;
			Done := False;

			while (CurrPos <= Obj^.Length) and not(LastPos = CurrPos) and not(Done) do
				begin
					LastPos := CurrPos;
					S := GetObjLine(C,CurrPos,Obj^.Length);

					if S <> '' Then
						begin
							case S[1] of
								'''':
									begin
									end;
								'@':begin
									end;
								'#':begin
										if UpperCase(S) = '#END' then
											begin
												CurrPos := LastPos;
												Done := True;
											end;
									end;
								'/':begin
										CurrPos := LastPos;
										Done := True;
									end;
							else
								WriteZZTTextLine(S);
							end;
						end
					else
						begin
							WriteZZTTextLine('');
						end;
				end;

			Obj^.CurrIns := CurrPos;

			If TextBuffer[0] <> #0 then
				begin
					if TextBufferLines > 1 then
						begin
							S := ShowZZTText('Oi!');
							SendObjectToLabel(ObjNum,S);
						end
					else
						begin
							CurrentBoard.Info.Message := StrPas(TextBuffer);
						end;
					ClearZZTText;
				end;
		end;
End.
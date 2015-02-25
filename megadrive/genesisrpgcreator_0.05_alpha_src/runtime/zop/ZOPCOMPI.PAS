{
Zop compiler - The compiling routines themselves
by Haroldo de Oliveira Pinheiro

You may do wathever you want with these sources, as long as
you give proper credit.
}
unit ZopCompiler;
interface
	uses ZopLinker;

	function ZopCompile(var Buffer; var LinkInfo: ZopLinkerInfo; FileName: String): longint;
implementation
	uses Utils, NestText, ZopUnit;

	type
		SetOfChar = set of Char;

	const
		SCHR_BLANK : SetOfChar = [' ', #9];

	var LinkerInfo : ZopLinkerInfo;
		CurrLabel  : word;

	function ParseLine(S: String; var P: PChar): longint; forward;

	function ScanString(var S: string; StartPos: byte; Match: SetOfChar): byte;
		var i : word;
		begin
			i := StartPos;
			while (i <= Length(S)) and not(S[i] in Match) do
				Inc(i);
			ScanString := i - 1;
		end;

	function ParseBoolExpr(var S: String; var P: PChar): longint;
		var Size : longint;
			Idx  : integer;
			N	 : integer;
			S2   : string[32];
		begin
			Size := 0;

			Idx := ScanString(S, 1, SCHR_BLANK);
			S2  := UpperCase(Copy(S, 1, Idx));
			Delete(S, 1, Idx);
			S   := LTrim(S);

			if S2 = 'NOT' then
				begin
					Inc(Size, ParseBoolExpr(S, P));
					Inc(Size, ZopOpAddFlag(P, ZOP_OP_NOT, 0));
				end
			else if Copy(S2, 1, 2) = 'FL' then
				begin
					Delete(S2, 1, 2);
					Val(S2, N, Idx);
					if (Idx = 0) and (N >= 0) and (N < 1024) then
						begin
							if N <> 0 then {The instruction below won't be needed for flag0}
								Inc(Size, ZopOpAddFlag(P, ZOP_OP_TFZ, N));
						end
					else
						begin
							Writeln('Unknown flag: ', S2);
							Halt(255);
						end;
				end;

			ParseBoolExpr := Size;
		end;

	function ParseString(var S: String; var P: PChar): longint;
		var Size : longint;
			Idx	 : integer;
			Idx2 : integer;
			N 	 : integer;
			N2   : integer;
			S2	 : string;
			Ch	 : char;
			Ch2	 : char;
			P2	 : PChar;
		begin
			Size := 0;
			Idx	 := 1;
			if S <> '' then
				case S[Idx] of
					'''': S := ''; {Comment}

					':':begin {label}
							Inc(Idx);
							Idx2 := ScanString(S, Idx, SCHR_BLANK);
							S2   := UpperCase(Copy(S, Idx, Idx2 - Idx + 1));
							ZopLabelAdd(LinkerInfo.Labels, S2, P);
							Idx  := Idx2;
						end;

					'/', '?': {walk, try walking}
						begin
							Ch := S[Idx];
							Inc(Idx);
							if Idx <= Length(S) then
								begin
									Ch2 := UpCase(S[Idx]);

									if Ch2 = 'I' then
										begin
											Inc(Size, ZopOpAddSimple(P, ZOP_OP_NOP, ZOP_PR_NOP_DELAY));
										end
									else
										begin
											case Ch2 of
												'N': Idx2 := ZOP_PR_DIR_NORTH;
												'S': Idx2 := ZOP_PR_DIR_SOUTH;
												'E': Idx2 := ZOP_PR_DIR_EAST;
												'W': Idx2 := ZOP_PR_DIR_WEST;
											end;

											case Ch of
												'/': Inc(Size, ZopOpAddSimple(P, ZOP_OP_WLK_WALK, Idx2));
												'?': Inc(Size, ZopOpAddSimple(P, ZOP_OP_WLK_TRY, Idx2));
											end;
										end
								end;
						end;

					'#':begin {Command}
							Inc(Idx);
							Idx2 := ScanString(S, Idx, SCHR_BLANK);
							S2   := UpperCase(Copy(S, Idx, Idx2 - Idx + 1));

							if (S2 = 'SEND') or (S2 = 'GOTO') then
								begin
									Delete(S, 1, Idx2);
									S    := LTrim(S);
									Idx  := 1;
									Idx2 := ScanString(S, Idx, SCHR_BLANK);
									S2   := UpperCase(Copy(S, Idx, Idx2 - Idx + 1));

									P2 := P;

									Inc(Size, ZopOpAddBranch(P, ZOP_OP_BRA, ZOP_PR_BRA_ALWAYS, 0));

									Inc(P2); {Positions P2 at the place where the jump address will be placed at link time}
									ZopLabelAdd(LinkerInfo.Refs, S2, P2);
								end
							else if (S2 = 'SET') or (S2 = 'CLEAR') then
								begin
									Ch := S2[1];

									Delete(S, 1, Idx2);
									S    := LTrim(S);
									Idx  := 1;
									Idx2 := ScanString(S, Idx, SCHR_BLANK);
									S2   := UpperCase(Copy(S, Idx, Idx2 - Idx + 1));

									if Copy(S2, 1, 2) = 'FL' then
										begin
											Val(Copy(S2, 3, Length(S2)), N, N2);
											if (N2 <> 0) or (N > 1023) then
												begin
													Writeln('SET/CLEAR: Unknown flag: ', S2);
													Halt(255);
												end;

											if Ch = 'S' then
												Inc(Size, ZopOpAddFlag(P, ZOP_OP_SET, N))
											else
												Inc(Size, ZopOpAddFlag(P, ZOP_OP_CLR, N));
										end
									else
										begin
											Writeln('SET/CLEAR: Unknown flag: ', S2);
											Halt(255);
										end;
								end
							else if S2 = 'IF' then
								begin
									Delete(S, 1, Idx2);
									S    := LTrim(S);
									Idx  := 1;
									Idx2 := CurrLabel;

									Inc(CurrLabel);

									{Parses the condition}
									Inc(Size, ParseBoolExpr(S, P));

									{Skips the instructions if condition is false}
									P2 := P;
									Inc(Size, ZopOpAddBranch(P, ZOP_OP_BRA, ZOP_PR_BRA_NOTSET, 0));
									Inc(P2); {Positions P2 at the place where the jump address will be placed at link time}
									ZopLabelAdd(LinkerInfo.Refs, '.if' + HexWord(Idx2), P2);

									{Only executed when the condition checked above is true}
									Inc(Size, ParseLine(S, P));

									{If the condition is false, the program will skip to here}
									ZopLabelAdd(LinkerInfo.Labels, '.if' + HexWord(Idx2), P);

									S := '';
								end;

							Idx  := Idx2;
						end;

					'!':begin {Menu}
							Inc(Idx);
							Idx2 := ScanString(S, Idx, [';']);
							S2   := UpperCase(Copy(S, Idx, Idx2 - Idx + 1));
							Idx  := Idx2;

							Inc(Idx);
							Delete(S, 1, Idx);

							P2 := P;

							Inc(Size, ZopOpAddMenu(P, ZOP_OP_MNU, ZOP_PR_MNU_ADD, 0, S));

							Inc(P2); {Positions P2 at the place where the jump address will be placed at link time}
							ZopLabelAdd(LinkerInfo.Refs, S2, P2);

							S := '';
						end;
				else {Simple text}
					Inc(Size, ZopOpAddText(P, ZOP_OP_TXT, ZOP_PR_TXT_WRITE, S));
					S := '';
				end;
			Delete(S, 1, Idx);
			ParseString := Size;
		end;

	function ParseLine(S: String; var P: PChar): longint;
		var Size : longint;
		begin
			Size := 0;
			while S <> '' do
				begin
					Inc(Size, ParseString(S, P));
					S := LTrim(S);
				end;
			ParseLine := Size;
		end;

	function ZopCompile(var Buffer; var LinkInfo: ZopLinkerInfo; FileName: String): longint;
		var Txt  : NTextRec;
			S    : String;
			P    : PChar;
			Size : longint;
			Line : longint;
			Cnt  : longint;
			N	 : longint;
		begin
			LinkerInfo := LinkInfo;
			CurrLabel  := 0;

			P    := Addr(Buffer);
			Size := 0;
			Line := 1;
			NTxtOpen(Txt, FileName);
			while not NTxtEof(Txt) do
				begin
					S := NTxtReadLn(Txt);
					N := ScanString(S, 1, SCHR_BLANK);

					if UpperCase(Copy(S, 1, N)) = '#INCLUDE' then
						begin
							NTxtInclude(Txt, LTrim(Copy(S, N+1, Length(S))));
						end
					else
						begin
							Cnt := ParseLine(S, P);
							Inc(Size, Cnt);
							Inc(Line);
						end;
				end;
			NTxtClose(Txt);

			LinkInfo := LinkerInfo;

			ZopCompile := Size;
		end;
End.
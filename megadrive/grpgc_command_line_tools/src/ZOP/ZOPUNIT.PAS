{
Zop compiler - General opcode definitions/routines
by Haroldo de Oliveira Pinheiro

You may do wathever you want with these sources, as long as
you give proper credit.
}
unit ZopUnit;
interface
	{Bytecode constants}
	const
		ZOP_MAX_PROGSIZE = $8000; {32k}

		{Upper six bits represent the main opcode}
		ZOP_BTC_OP_MASK  = $FC;
		ZOP_BTC_OP_SHIFT = 2;
		{Lower six bits represent the opcode param, but can work as part of the opcode in some cases.}
		ZOP_BTC_PR_MASK  = $03;
		ZOP_BTC_PR_SHIFT = 0;

		ZOP_OP_NOP       = $00;
		ZOP_PR_NOP_NOP   = $00; {No operation}
		ZOP_PR_NOP_DELAY = $01; {Stop for a cycle}
		ZOP_PR_NOP_WAIT  = $02; {Wait for event}
		ZOP_PR_NOP_END   = $03; {End program}

		ZOP_OP_WLK_WALK  = $20; {Walk in a direction}
		ZOP_OP_WLK_TRY   = $24; {Try walking in a direction}
		ZOP_OP_FACE      = $28; {Turn to face a direction}
		ZOP_PR_DIR_NORTH = $00;
		ZOP_PR_DIR_SOUTH = $01;
		ZOP_PR_DIR_EAST  = $02;
		ZOP_PR_DIR_WEST  = $03;

		ZOP_OP_TXT         = $40; {Text-related commands}
		ZOP_PR_TXT_CLEAR   = $00; {Clears the current text buffer}
		ZOP_PR_TXT_WRITE   = $01; {Add line to the text buffer. Must be followed by a null-terminated string.}
		ZOP_PR_TXT_DISPLAY = $02; {Displays the text contained in the buffer}
		ZOP_PR_TXT_DISCLR  = $03; {Displays the text contained in the buffer, and then clears it}

		ZOP_OP_MNU         = $44; {Menu-related commands}
		ZOP_PR_MNU_CLEAR   = $00; {Clears the current menu buffer}
		ZOP_PR_MNU_ADD     = $01; {Adds option to menu. Followed by a 16-bit jump address (MSB First) and a null-terminated string}
		ZOP_PR_MNU_DISPLAY = $02; {Displays the menu}
		ZOP_PR_MNU_DISCLR  = $03; {Displays the menu, and then clears it}

		ZOP_OP_SET = $60; {Sets a flag. Must be followed by a single byte. Flag number = (Op Param shl 8) + Following byte}
		ZOP_OP_CLR = $64; {Clears a flag. Same as above.}
		ZOP_OP_TFZ = $68; {Transfers state of the flag to flag 0. Same as above.}
		ZOP_OP_TZF = $6C; {Transfers state of flag 0 to flag. Same as above.}
		ZOP_OP_NOT = $70; {Inverts the state of a flag. Same as above.}

		ZOP_OP_BRA        = $80; {Branch command. Must be followed by a 16-bit address (MSB First). Op Param defines jump condition}
		ZOP_PR_BRA_ALWAYS = $00; {Unconditional jump}
		ZOP_PR_BRA_SET    = $01; {Jump if flag 0 is set}
		ZOP_PR_BRA_NOTSET = $02; {Jump if flag 0 is not set}

		ZOP_OP_SYS     = $FC; {System commands}
		ZOP_PR_SYS_EXT = $01; {Extended command}

	function ZopOpAddSimple(var P: PChar; Op, Parm: Byte): word;
	function ZopOpAddText(var P: PChar; Op, Parm: Byte; S: String): word;
	function ZopOpAddMenu(var P: PChar; Op, Parm: Byte; Addr: Word; Txt: String): word;
	function ZopOpAddFlag(var P: PChar; Op: Byte; Flag: Word): word;
	function ZopOpAddBranch(var P: PChar; Op, Parm: Byte; Addr: Word): word;
implementation
	function ZopOpAddSimple(var P: PChar; Op, Parm: Byte): word;
		begin
			P^ := Chr((Op and ZOP_BTC_OP_MASK) Or (Parm and ZOP_BTC_PR_MASK));
			Inc(P);

			ZopOpAddSimple := 1;
		end;

	function ZopOpAddText(var P: PChar; Op, Parm: Byte; S: String): word;
		var i  : byte;
			P2 : PChar;
		begin
			P^ := Chr((Op and ZOP_BTC_OP_MASK) Or (Parm and ZOP_BTC_PR_MASK));
			Inc(P);

			P2 := P;

			for i := 1 to Length(S) do
				begin
					P^ := S[i];
					Inc(P);
				end;
			P^ := #0;
			Inc(P);

			ZopOpAddText := Length(S) + 2;
		end;

	function ZopOpAddMenu(var P: PChar; Op, Parm: Byte; Addr: Word; Txt: String): word;
		var i : byte;
		begin
			P^ := Chr((Op and ZOP_BTC_OP_MASK) Or (Parm and ZOP_BTC_PR_MASK));
			Inc(P);

			P^ := Chr(Addr shr 8);
			Inc(P);
			P^ := Chr(Addr and $00FF);
			Inc(P);

			for i := 1 to Length(Txt) do
				begin
					P^ := Txt[i];
					Inc(P);
				end;
			P^ := #0;
			Inc(P);

			ZopOpAddMenu := Length(Txt) + 4;
		end;

	function ZopOpAddFlag(var P: PChar; Op: Byte; Flag: Word): word;
		begin
			P^ := Chr((Op and ZOP_BTC_OP_MASK) Or ((Flag shr 8) and ZOP_BTC_PR_MASK));
			Inc(P);
			P^ := Chr(Flag and $00FF);
			Inc(P);

			ZopOpAddFlag := 2;
		end;

	function ZopOpAddBranch(var P: PChar; Op, Parm: Byte; Addr: Word): word;
		begin
			P^ := Chr((Op and ZOP_BTC_OP_MASK) Or (Parm and ZOP_BTC_PR_MASK));
			Inc(P);

			P^ := Chr(Addr shr 8);
			Inc(P);
			P^ := Chr(Addr and $00FF);
			Inc(P);

			ZopOpAddBranch := 3;
		end;
End.